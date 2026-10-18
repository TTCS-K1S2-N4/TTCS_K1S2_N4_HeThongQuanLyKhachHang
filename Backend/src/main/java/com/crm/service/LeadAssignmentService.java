package com.crm.service;

import com.crm.dao.LeadAssignmentRuleDAO;
import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.model.LeadAssignmentRule;
import com.crm.model.LeadAssignmentHistory;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadAssignmentService - Quản lý phân bổ Lead tự động (S4-06) theo Region, Industry, Round-Robin.
 * Sử dụng Single JDBC Connection Transaction, Pessimistic Row Locking và lưu trạng thái bền vững trong CSDL.
 */
public class LeadAssignmentService {
    private static final Logger LOGGER = Logger.getLogger(LeadAssignmentService.class.getName());
    
    private final LeadAssignmentRuleDAO ruleDAO;
    private final LeadAssignmentHistoryDAO historyDAO;
    
    // Background worker quét các Lead trong hàng đợi phân bổ
    private ScheduledExecutorService scheduler;

    public LeadAssignmentService() {
        this.ruleDAO = new LeadAssignmentRuleDAO();
        this.historyDAO = new LeadAssignmentHistoryDAO();
    }

    public LeadAssignmentService(LeadAssignmentRuleDAO ruleDAO, LeadAssignmentHistoryDAO historyDAO) {
        this.ruleDAO = ruleDAO;
        this.historyDAO = historyDAO;
    }

    /**
     * Khởi động background worker chạy nền mỗi 5 phút.
     */
    public synchronized void startBackgroundWorker() {
        if (scheduler == null || scheduler.isShutdown()) {
            scheduler = Executors.newSingleThreadScheduledExecutor();
            scheduler.scheduleAtFixedRate(this::processUnassignedLeads, 1, 5, TimeUnit.MINUTES);
            LOGGER.info("Lead Assignment Background Worker started.");
        }
    }

    /**
     * Dừng background worker an toàn khi ứng dụng shutdown.
     */
    public synchronized void stopBackgroundWorker() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            LOGGER.info("Lead Assignment Background Worker stopped.");
        }
    }

    /**
     * Quét và phân bổ tự động các Lead chưa có chủ sở hữu trong CSDL.
     */
    public void processUnassignedLeads() {
        LOGGER.info("Running background unassigned leads processing...");
        String sql = "SELECT lead_id, region, industry FROM leads " +
                     "WHERE owner_id IS NULL AND status IN ('NEW', 'QUEUED') " +
                     "ORDER BY lead_id ASC LIMIT 50";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int leadId = rs.getInt("lead_id");
                String region = rs.getString("region");
                String industry = rs.getString("industry");
                try {
                    assignLead(leadId, region, industry, null);
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Không thể phân bổ Lead #" + leadId, e);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn unassigned leads trong background worker", e);
        }
    }

    /**
     * Thuật toán phân bổ Lead tự động theo Rule Engine và Round-Robin bền vững.
     * Toàn bộ thao tác thực thi trong một Transaction JDBC duy nhất.
     */
    public Integer assignLead(int leadId, String region, String industry) throws SQLException {
        return assignLead(leadId, region, industry, null);
    }

    public Integer assignLead(int leadId, String region, String industry, Integer performedBy) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // BƯỚC 1: Khóa bi quan Lead mục tiêu (Pessimistic Locking)
            LeadAssignmentRuleDAO.LeadLockRecord lead = ruleDAO.getLeadForUpdate(conn, leadId);
            if (lead == null) {
                throw new IllegalArgumentException("Lead #" + leadId + " không tồn tại trong hệ thống.");
            }

            if ("CONVERTED".equalsIgnoreCase(lead.getStatus())) {
                throw new IllegalStateException("Lead #" + leadId + " đã được chuyển đổi thành Khách hàng, không thể phân bổ.");
            }

            // Kiểm tra Idempotency / Concurrency: Nếu Lead đã được phân bổ cho một nhân viên
            if (lead.getOwnerId() != null && lead.getOwnerId() > 0 && "ASSIGNED".equalsIgnoreCase(lead.getStatus())) {
                LOGGER.info("Lead #" + leadId + " đã được phân bổ cho User #" + lead.getOwnerId() + " bởi tiến trình khác.");
                conn.rollback();
                return lead.getOwnerId();
            }

            String effRegion = (region != null && !region.trim().isEmpty()) ? region.trim() : lead.getRegion();
            String effIndustry = (industry != null && !industry.trim().isEmpty()) ? industry.trim() : lead.getIndustry();

            // BƯỚC 2: Nạp danh sách Rules đang active theo thứ tự ưu tiên tăng dần (Priority 1 là cao nhất)
            List<LeadAssignmentRule> rules = ruleDAO.getActiveRules(conn);

            Integer matchedAssigneeId = null;
            Integer matchedRuleId = null;

            // BƯỚC 3: Đối chiếu quy tắc (First-match wins)
            for (LeadAssignmentRule rule : rules) {
                if (!rule.isActive()) continue;

                if (isRuleMatched(rule, effRegion, effIndustry)) {
                    matchedRuleId = rule.getRuleId();

                    if ("ROUND_ROBIN".equalsIgnoreCase(rule.getCriterion())) {
                        if (rule.getTeamId() != null) {
                            // Khóa dòng Rule để cập nhật con trỏ Round-Robin an toàn đa luồng
                            LeadAssignmentRule lockedRule = ruleDAO.getRuleByIdForUpdate(conn, rule.getRuleId());
                            if (lockedRule != null && lockedRule.getTeamId() != null) {
                                List<Integer> teamMembers = ruleDAO.getActiveUserIdsByTeam(conn, lockedRule.getTeamId());
                                if (teamMembers != null && !teamMembers.isEmpty()) {
                                    matchedAssigneeId = calculateNextRoundRobinUser(teamMembers, lockedRule.getLastAssignedUserId());
                                    // Cập nhật con trỏ mới vào CSDL ngay trong transaction
                                    ruleDAO.updateLastAssignedUser(conn, lockedRule.getRuleId(), matchedAssigneeId);
                                }
                            }
                        }
                    } else {
                        matchedAssigneeId = rule.getAssigneeId();
                    }

                    if (matchedAssigneeId != null) {
                        break; // Đã tìm thấy người nhận phù hợp
                    }
                }
            }

            // BƯỚC 4: Cập nhật CSDL & Ghi lịch sử kiểm toán trong cùng Transaction
            if (matchedAssigneeId != null) {
                LeadAssignmentRuleDAO.UserEligibilityRecord candidate = ruleDAO.getUserEligibility(conn, matchedAssigneeId);
                if (candidate == null || !candidate.isEligible()) {
                    LOGGER.warning("Nhân viên #" + matchedAssigneeId + " không còn hoạt động hoặc bị khóa. Đưa Lead #" + leadId + " vào hàng chờ QUEUED.");
                    matchedAssigneeId = null;
                }
            }

            LeadAssignmentHistory history = new LeadAssignmentHistory();
            history.setLeadId(leadId);
            history.setRuleId(matchedRuleId);
            history.setPerformedBy(performedBy);
            history.setAssignedAt(new Timestamp(System.currentTimeMillis()));

            if (matchedAssigneeId != null) {
                ruleDAO.updateLeadOwnerAndStatus(conn, leadId, matchedAssigneeId, "ASSIGNED");
                history.setAssignedTo(matchedAssigneeId);
                history.setStatus("ASSIGNED");
                LOGGER.info("Lead #" + leadId + " đã phân bổ cho User #" + matchedAssigneeId + " theo Rule #" + matchedRuleId);
            } else {
                ruleDAO.updateLeadOwnerAndStatus(conn, leadId, null, "QUEUED");
                history.setAssignedTo(null);
                history.setStatus("QUEUED");
                LOGGER.info("Lead #" + leadId + " không khớp quy tắc nào hoặc nhóm trống, đưa vào hàng chờ QUEUED.");
            }

            historyDAO.saveHistory(conn, history);

            // BƯỚC 5: Commit Transaction thành công
            conn.commit();
            return matchedAssigneeId;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.info("Rollback transaction phân bổ Lead #" + leadId + " thành công.");
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback transaction thất bại", ex);
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    LOGGER.log(Level.WARNING, "Đóng kết nối CSDL thất bại", ex);
                }
            }
        }
    }

    /**
     * Phân bổ Lead thủ công (Manual Assignment) bởi Quản lý / Trưởng nhóm.
     */
    public boolean assignLeadManually(int leadId, int assigneeId, int performedBy) throws SQLException {
        return assignLeadManually(leadId, assigneeId, performedBy, null);
    }

    /**
     * Phân bổ Lead thủ công với kiểm tra phạm vi dữ liệu nhóm (Data Scope TEAM).
     */
    public boolean assignLeadManually(int leadId, int assigneeId, int performedBy, Integer callerTeamId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Khóa bi quan Lead
            LeadAssignmentRuleDAO.LeadLockRecord lead = ruleDAO.getLeadForUpdate(conn, leadId);
            if (lead == null) {
                throw new IllegalArgumentException("Lead #" + leadId + " không tồn tại trong hệ thống.");
            }

            if ("CONVERTED".equalsIgnoreCase(lead.getStatus())) {
                throw new IllegalStateException("Lead #" + leadId + " đã được chuyển đổi, không thể phân bổ.");
            }

            // Kiểm tra tính hợp lệ của nhân viên nhận Lead
            LeadAssignmentRuleDAO.UserEligibilityRecord userRecord = ruleDAO.getUserEligibility(conn, assigneeId);
            if (userRecord == null) {
                throw new IllegalArgumentException("Nhân viên #" + assigneeId + " không tồn tại trong hệ thống.");
            }
            if (!userRecord.isEligible()) {
                throw new IllegalArgumentException("Nhân viên #" + assigneeId + " đã bị vô hiệu hóa hoặc đang bị khóa tài khoản.");
            }

            // Kiểm tra Data Scope nếu người thực hiện thuộc phạm vi TEAM
            if (callerTeamId != null) {
                // 1. Kiểm tra Data Scope trên chính Lead: Không được can thiệp Lead đang thuộc nhân viên nhóm khác
                if (lead.getOwnerId() != null && lead.getOwnerId() > 0) {
                    LeadAssignmentRuleDAO.UserEligibilityRecord currentOwner = ruleDAO.getUserEligibility(conn, lead.getOwnerId());
                    if (currentOwner != null && currentOwner.getTeamId() != null && !currentOwner.getTeamId().equals(callerTeamId)) {
                        throw new SecurityException("Lead #" + leadId + " đang thuộc quản lý của nhóm khác (Data Scope của Lead vi phạm).");
                    }
                }

                // 2. Kiểm tra Data Scope trên nhân viên nhận: Chỉ được phân bổ cho nhân viên trong cùng nhóm
                if (userRecord.getTeamId() == null || !userRecord.getTeamId().equals(callerTeamId)) {
                    throw new SecurityException("Nhân viên #" + assigneeId + " không thuộc nhóm của bạn (Data Scope vi phạm).");
                }
            }

            // Cập nhật Lead
            ruleDAO.updateLeadOwnerAndStatus(conn, leadId, assigneeId, "ASSIGNED");

            // Ghi lịch sử kiểm toán
            LeadAssignmentHistory history = new LeadAssignmentHistory();
            history.setLeadId(leadId);
            history.setAssignedTo(assigneeId);
            history.setPerformedBy(performedBy);
            history.setStatus("MANUAL_ASSIGNED");
            history.setAssignedAt(new Timestamp(System.currentTimeMillis()));
            historyDAO.saveHistory(conn, history);

            conn.commit();
            LOGGER.info("Lead #" + leadId + " được phân bổ thủ công cho User #" + assigneeId + " bởi User #" + performedBy);
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback lỗi", ex); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.WARNING, "Đóng conn lỗi", ex); }
            }
        }
    }

    /**
     * Kiểm tra điều kiện Rule có khớp với thông tin Lead hay không.
     */
    public boolean isRuleMatched(LeadAssignmentRule rule, String region, String industry) {
        if (rule == null || rule.getCriterion() == null) return false;
        
        switch (rule.getCriterion().toUpperCase()) {
            case "REGION":
                return rule.getCriterionValue() != null && rule.getCriterionValue().equalsIgnoreCase(region);
            case "INDUSTRY":
                return rule.getCriterionValue() != null && rule.getCriterionValue().equalsIgnoreCase(industry);
            case "ROUND_ROBIN":
                return rule.getTeamId() != null && rule.getTeamId() > 0;
            default:
                return false;
        }
    }

    /**
     * Thuật toán chọn thành viên kế tiếp theo cơ chế xoay vòng Round-Robin ổn định.
     */
    public static Integer calculateNextRoundRobinUser(List<Integer> memberIds, Integer lastUserId) {
        if (memberIds == null || memberIds.isEmpty()) return null;
        if (lastUserId == null) return memberIds.get(0);

        int currentIndex = memberIds.indexOf(lastUserId);
        if (currentIndex < 0) {
            // Nhân viên vừa được gán trước đó không còn thuộc nhóm này nữa -> reset về người đầu tiên
            return memberIds.get(0);
        }

        int nextIndex = (currentIndex + 1) % memberIds.size();
        return memberIds.get(nextIndex);
    }
}
