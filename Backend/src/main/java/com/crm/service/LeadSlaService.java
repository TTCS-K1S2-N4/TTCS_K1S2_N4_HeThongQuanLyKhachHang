package com.crm.service;

import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.model.LeadAssignmentHistory;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadSlaService - Quản lý nghiệp vụ tiếp nhận Lead, từ chối Lead và Response SLA (S4-07).
 * Sử dụng JDBC Transaction với Pessimistic Locking (FOR UPDATE) kết nối trực tiếp MySQL.
 */
public class LeadSlaService {
    private static final Logger LOGGER = Logger.getLogger(LeadSlaService.class.getName());

    private final LeadAssignmentHistoryDAO historyDAO;
    private ScheduledExecutorService scheduler;

    public LeadSlaService() {
        this.historyDAO = new LeadAssignmentHistoryDAO();
    }

    public LeadSlaService(LeadAssignmentHistoryDAO historyDAO) {
        this.historyDAO = (historyDAO != null) ? historyDAO : new LeadAssignmentHistoryDAO();
    }

    public static class LeadRecord {
        private final int leadId;
        private final Integer ownerId;
        private final String status;
        private final Timestamp assignedAt;
        private final Timestamp slaDueDate;
        private final boolean overdue;

        public LeadRecord(int leadId, Integer ownerId, String status, Timestamp assignedAt, Timestamp slaDueDate, boolean overdue) {
            this.leadId = leadId;
            this.ownerId = ownerId;
            this.status = status;
            this.assignedAt = assignedAt;
            this.slaDueDate = slaDueDate;
            this.overdue = overdue;
        }

        public int getLeadId() { return leadId; }
        public Integer getOwnerId() { return ownerId; }
        public String getStatus() { return status; }
        public Timestamp getAssignedAt() { return assignedAt; }
        public Timestamp getSlaDueDate() { return slaDueDate; }
        public boolean isOverdue() { return overdue; }
    }

    /**
     * 1. Nhân viên tiếp nhận Lead đã được phân bổ.
     */
    public boolean acceptLead(int leadId, int userId) throws SQLException {
        return acceptLead(leadId, userId, false);
    }

    public boolean acceptLead(int leadId, int userId, boolean isElevatedRole) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // BƯỚC 1: Khóa bi quan Lead mục tiêu (Pessimistic Locking)
            LeadRecord lead = getLeadForUpdate(conn, leadId);
            if (lead == null) {
                throw new IllegalArgumentException("Lead #" + leadId + " không tồn tại trong hệ thống.");
            }

            // BƯỚC 2: Kiểm tra trạng thái Lead
            if ("CONVERTED".equalsIgnoreCase(lead.getStatus())) {
                throw new IllegalStateException("Lead #" + leadId + " đã được chuyển đổi thành khách hàng, không thể tiếp nhận.");
            }

            // Kiểm tra quyền sở hữu (Ownership)
            if (!isElevatedRole && (lead.getOwnerId() == null || !lead.getOwnerId().equals(userId))) {
                throw new SecurityException("Bạn không phải người sở hữu Lead #" + leadId + " (Ownership vi phạm).");
            }

            // Kiểm tra tính Idempotent: Nếu đã IN_PROGRESS
            if ("IN_PROGRESS".equalsIgnoreCase(lead.getStatus())) {
                LOGGER.info("Lead #" + leadId + " đã ở trạng thái IN_PROGRESS. Bỏ qua ghi nhận lặp.");
                conn.commit();
                return true;
            }

            // Chỉ cho phép nhận khi đang ASSIGNED hoặc OVERDUE
            if (!"ASSIGNED".equalsIgnoreCase(lead.getStatus()) && !"OVERDUE".equalsIgnoreCase(lead.getStatus())) {
                throw new IllegalStateException("Lead #" + leadId + " đang ở trạng thái '" + lead.getStatus() + "', chỉ có thể nhận khi ở trạng thái ASSIGNED hoặc OVERDUE.");
            }

            // BƯỚC 3: Cập nhật trạng thái Lead sang IN_PROGRESS (Đang chăm sóc)
            // Lưu ý nghiệp vụ: Tiếp nhận Lead không đồng nghĩa với đã liên hệ khách hàng. sla_status chuyển sang IN_PROGRESS.
            String updateSql = "UPDATE leads SET status = 'IN_PROGRESS', is_overdue = 0, sla_status = 'IN_PROGRESS', updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, leadId);
                int updatedRows = ps.executeUpdate();
                if (updatedRows <= 0) {
                    throw new SQLException("Cập nhật trạng thái Lead #" + leadId + " thất bại.");
                }
            }

            // BƯỚC 4: Ghi nhận lịch sử kiểm toán
            LeadAssignmentHistory history = new LeadAssignmentHistory();
            history.setLeadId(leadId);
            history.setAssignedTo(userId);
            history.setPerformedBy(userId);
            history.setStatus("IN_PROGRESS");
            history.setAssignedAt(new Timestamp(System.currentTimeMillis()));

            boolean historySaved = historyDAO.saveHistory(conn, history);
            if (!historySaved) {
                throw new SQLException("Ghi nhận lịch sử tiếp nhận Lead #" + leadId + " thất bại.");
            }

            // BƯỚC 5: Commit Transaction
            conn.commit();
            LOGGER.info("User #" + userId + " đã tiếp nhận Lead #" + leadId + " thành công (Status -> IN_PROGRESS).");
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.info("Rollback transaction tiếp nhận Lead #" + leadId + " thành công.");
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
     * 2. Nhân viên từ chối Lead kèm lý do hợp lệ.
     */
    public boolean rejectLead(int leadId, int userId, String rejectReason) throws SQLException {
        return rejectLead(leadId, userId, rejectReason, false);
    }

    public boolean rejectLead(int leadId, int userId, String rejectReason, boolean isElevatedRole) throws SQLException {
        if (rejectReason == null || rejectReason.trim().isEmpty()) {
            throw new IllegalArgumentException("Lý do từ chối Lead là bắt buộc.");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // BƯỚC 1: Khóa bi quan Lead
            LeadRecord lead = getLeadForUpdate(conn, leadId);
            if (lead == null) {
                throw new IllegalArgumentException("Lead #" + leadId + " không tồn tại trong hệ thống.");
            }

            if ("CONVERTED".equalsIgnoreCase(lead.getStatus())) {
                throw new IllegalStateException("Lead #" + leadId + " đã được chuyển đổi, không thể từ chối.");
            }

            if (!isElevatedRole && (lead.getOwnerId() == null || !lead.getOwnerId().equals(userId))) {
                throw new SecurityException("Bạn không có quyền từ chối Lead #" + leadId + " (Ownership vi phạm).");
            }

            if ("QUEUED".equalsIgnoreCase(lead.getStatus()) && lead.getOwnerId() == null) {
                LOGGER.info("Lead #" + leadId + " đã ở hàng chờ QUEUED. Bỏ qua ghi nhận lặp.");
                conn.commit();
                return true;
            }

            if (!"ASSIGNED".equalsIgnoreCase(lead.getStatus()) && !"OVERDUE".equalsIgnoreCase(lead.getStatus())) {
                throw new IllegalStateException("Lead #" + leadId + " đang ở trạng thái '" + lead.getStatus() + "', chỉ có thể từ chối khi ở trạng thái ASSIGNED hoặc OVERDUE.");
            }

            // BƯỚC 2: Cập nhật Lead về hàng chờ (owner_id = NULL, status = 'QUEUED', sla_due_date = NULL)
            String updateSql = "UPDATE leads SET owner_id = NULL, status = 'QUEUED', assigned_at = NULL, sla_due_date = NULL, is_overdue = 0, sla_status = 'REJECTED', updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, leadId);
                int updated = ps.executeUpdate();
                if (updated <= 0) {
                    throw new SQLException("Cập nhật trạng thái từ chối Lead #" + leadId + " thất bại.");
                }
            }

            // BƯỚC 3: Ghi nhận lịch sử kèm reject_reason
            LeadAssignmentHistory history = new LeadAssignmentHistory();
            history.setLeadId(leadId);
            history.setAssignedTo(userId);
            history.setPerformedBy(userId);
            history.setStatus("REJECTED");
            history.setRejectReason(rejectReason.trim());
            history.setAssignedAt(new Timestamp(System.currentTimeMillis()));

            boolean historySaved = historyDAO.saveHistory(conn, history);
            if (!historySaved) {
                throw new SQLException("Ghi nhận lịch sử từ chối Lead #" + leadId + " thất bại.");
            }

            conn.commit();
            LOGGER.info("User #" + userId + " đã từ chối Lead #" + leadId + " (Lý do: " + rejectReason.trim() + "). Lead quay lại QUEUED.");
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.info("Rollback transaction từ chối Lead #" + leadId + " thành công.");
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
     * Khóa bi quan bản ghi Lead trong Transaction.
     */
    public LeadRecord getLeadForUpdate(Connection conn, int leadId) throws SQLException {
        String sql = "SELECT lead_id, owner_id, status, assigned_at, sla_due_date, is_overdue " +
                     "FROM leads WHERE lead_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Integer ownerId = (rs.getObject("owner_id") != null) ? rs.getInt("owner_id") : null;
                    boolean overdue = rs.getBoolean("is_overdue");
                    return new LeadRecord(
                            rs.getInt("lead_id"),
                            ownerId,
                            rs.getString("status"),
                            rs.getTimestamp("assigned_at"),
                            rs.getTimestamp("sla_due_date"),
                            overdue
                    );
                }
            }
        }
        return null;
    }

    // =========================================================================
    // RESPONSE SLA MANAGEMENT & OVERDUE NOTIFICATION
    // =========================================================================

    /**
     * Ghi nhận phản hồi / liên hệ khách hàng thực tế (TC09).
     * Khi có tương tác thực tế, Lead chuyển sang CONTACTED / RESPONDED và không bị cảnh báo quá hạn.
     */
    public boolean recordLeadContact(int leadId, int userId, String note) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            LeadRecord lead = getLeadForUpdate(conn, leadId);
            if (lead == null) {
                throw new IllegalArgumentException("Lead #" + leadId + " không tồn tại.");
            }

            String sql = "UPDATE leads SET status = 'CONTACTED', sla_status = 'RESPONDED', is_overdue = 0, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, leadId);
                ps.executeUpdate();
            }

            String actSql = "INSERT INTO activities (lead_id, owner_id, title, description, activity_type, created_at) " +
                            "VALUES (?, ?, 'Liên hệ phản hồi khách hàng', ?, 'CALL', CURRENT_TIMESTAMP)";
            try (PreparedStatement ps = conn.prepareStatement(actSql)) {
                ps.setInt(1, leadId);
                ps.setInt(2, userId);
                ps.setString(3, (note != null && !note.trim().isEmpty()) ? note.trim() : "Đã liên hệ phản hồi khách hàng theo SLA");
                ps.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Lead #" + leadId + " đã được ghi nhận liên hệ khách hàng thành công (sla_status -> RESPONDED).");
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback thất bại", ex); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignore) {}
            }
        }
    }

    /**
     * Lấy thời hạn phản hồi SLA (phút) từ bảng cấu hình lead_sla_configs.
     * Tuyệt đối không tự ý gán cứng nếu CSDL chưa có cấu hình.
     */
    public Integer getSlaResponseTimeMinutes(Connection conn, String priorityLevel) throws SQLException {
        String sql;
        if (priorityLevel != null && !priorityLevel.trim().isEmpty()) {
            sql = "SELECT response_time_minutes FROM lead_sla_configs WHERE priority_level = ? AND is_active = 1 LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, priorityLevel.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("response_time_minutes");
                    }
                }
            }
        }

        // Lấy cấu hình active mặc định đầu tiên nếu có
        sql = "SELECT response_time_minutes FROM lead_sla_configs WHERE is_active = 1 ORDER BY sla_id ASC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("response_time_minutes");
            }
        }

        // Không có cấu hình SLA trong CSDL
        return null;
    }

    /**
     * Tính toán thời hạn hạn chót SLA (sla_due_date) dựa trên mốc assigned_at và số phút phản hồi.
     */
    public Timestamp calculateSlaDueDate(Timestamp assignedAt, int responseTimeMinutes) {
        if (assignedAt == null || responseTimeMinutes <= 0) return null;
        return new Timestamp(assignedAt.getTime() + (responseTimeMinutes * 60L * 1000L));
    }

    public static class OverdueLeadInfo {
        private final int leadId;
        private final Integer ownerId;
        private final String leadName;
        private final String repName;
        private final Integer teamId;
        private final Integer leaderId;
        private final Timestamp slaDueDate;

        public OverdueLeadInfo(int leadId, Integer ownerId, String leadName, String repName, Integer teamId, Integer leaderId, Timestamp slaDueDate) {
            this.leadId = leadId;
            this.ownerId = ownerId;
            this.leadName = leadName;
            this.repName = repName;
            this.teamId = teamId;
            this.leaderId = leaderId;
            this.slaDueDate = slaDueDate;
        }

        public int getLeadId() { return leadId; }
        public Integer getOwnerId() { return ownerId; }
        public String getLeadName() { return leadName; }
        public String getRepName() { return repName; }
        public Integer getTeamId() { return teamId; }
        public Integer getLeaderId() { return leaderId; }
        public Timestamp getSlaDueDate() { return slaDueDate; }
    }

    public static class LeadSlaNotification {
        private final int notificationId;
        private final int leadId;
        private final int salesRepId;
        private final Integer teamId;
        private final int leaderId;
        private final String message;
        private final Timestamp slaDueDate;
        private final boolean read;
        private final Timestamp createdAt;

        public LeadSlaNotification(int notificationId, int leadId, int salesRepId, Integer teamId, int leaderId, String message, Timestamp slaDueDate, boolean read, Timestamp createdAt) {
            this.notificationId = notificationId;
            this.leadId = leadId;
            this.salesRepId = salesRepId;
            this.teamId = teamId;
            this.leaderId = leaderId;
            this.message = message;
            this.slaDueDate = slaDueDate;
            this.read = read;
            this.createdAt = createdAt;
        }

        public int getNotificationId() { return notificationId; }
        public int getLeadId() { return leadId; }
        public int getSalesRepId() { return salesRepId; }
        public Integer getTeamId() { return teamId; }
        public int getLeaderId() { return leaderId; }
        public String getMessage() { return message; }
        public Timestamp getSlaDueDate() { return slaDueDate; }
        public boolean isRead() { return read; }
        public Timestamp getCreatedAt() { return createdAt; }
    }

    /**
     * Quét và gắn cờ quá hạn is_overdue = 1 cho các Lead quá hạn phản hồi.
     * Cảnh báo tới đúng Trưởng nhóm phụ trách (teams.leader_id) qua bảng lead_sla_notifications và audit_logs.
     * Không gửi lặp lại thông báo cho cùng một sự kiện quá hạn (idempotent / unique constraint).
     */
    public int checkAndFlagOverdueLeads() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            return checkAndFlagOverdueLeads(conn);
        }
    }

    public int checkAndFlagOverdueLeads(Connection conn) throws SQLException {
        // Tìm các Lead quá hạn phản hồi:
        // 1. Status là ASSIGNED hoặc IN_PROGRESS (đã nhận nhưng chưa liên hệ)
        // 2. Chưa bị gắn cờ quá hạn (is_overdue = 0 hoặc NULL)
        // 3. sla_due_date đã quá hạn (sla_due_date < CURRENT_TIMESTAMP)
        // 4. Chưa có hoạt động liên hệ thực tế trong bảng activities và sla_status chưa phải là RESPONDED
        String selectSql = "SELECT l.lead_id, l.owner_id, COALESCE(l.contact_name, l.full_name) AS lead_name, " +
                           "l.status, l.sla_due_date, u.full_name AS rep_name, u.team_id, t.team_name, t.leader_id " +
                           "FROM leads l " +
                           "LEFT JOIN users u ON l.owner_id = u.user_id " +
                           "LEFT JOIN teams t ON u.team_id = t.team_id " +
                           "WHERE (l.status IN ('ASSIGNED', 'IN_PROGRESS') OR l.status IS NULL) " +
                           "  AND (l.is_overdue = 0 OR l.is_overdue IS NULL) " +
                           "  AND l.sla_due_date IS NOT NULL AND l.sla_due_date < CURRENT_TIMESTAMP " +
                           "  AND (l.sla_status IS NULL OR l.sla_status NOT IN ('RESPONDED')) " +
                           "  AND NOT EXISTS (SELECT 1 FROM activities a WHERE a.lead_id = l.lead_id)";

        List<OverdueLeadInfo> overdueList = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(selectSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                overdueList.add(new OverdueLeadInfo(
                    rs.getInt("lead_id"),
                    (Integer) rs.getObject("owner_id"),
                    rs.getString("lead_name"),
                    rs.getString("rep_name"),
                    (Integer) rs.getObject("team_id"),
                    (Integer) rs.getObject("leader_id"),
                    rs.getTimestamp("sla_due_date")
                ));
            }
        }

        if (overdueList.isEmpty()) {
            return 0;
        }

        String updateLeadSql = "UPDATE leads SET is_overdue = 1, sla_status = 'OVERDUE', updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
        String insertNotifSql = "INSERT IGNORE INTO lead_sla_notifications (lead_id, sales_rep_id, team_id, leader_id, message, sla_due_date) VALUES (?, ?, ?, ?, ?, ?)";
        String insertAuditSql = "INSERT INTO audit_logs (action_type, performed_by, target_user_id, description, created_at) VALUES ('LEAD_SLA_BREACH', 1, ?, ?, CURRENT_TIMESTAMP)";

        int count = 0;
        try (PreparedStatement psUpdate = conn.prepareStatement(updateLeadSql);
             PreparedStatement psNotif = conn.prepareStatement(insertNotifSql);
             PreparedStatement psAudit = conn.prepareStatement(insertAuditSql)) {

            for (OverdueLeadInfo info : overdueList) {
                // 1. Cập nhật Lead cờ quá hạn
                psUpdate.setInt(1, info.getLeadId());
                psUpdate.addBatch();

                // 2. Xác định người nhận thông báo (Trưởng nhóm phụ trách theo quan hệ nhóm thực tế)
                int leaderId = (info.getLeaderId() != null && info.getLeaderId() > 0) ? info.getLeaderId() : 1;
                int repId = (info.getOwnerId() != null) ? info.getOwnerId() : 0;
                String repName = (info.getRepName() != null) ? info.getRepName() : "Chưa phân bổ";
                String leadName = (info.getLeadName() != null) ? info.getLeadName() : ("Lead #" + info.getLeadId());
                String message = String.format("CẢNH BÁO QUÁ HẠN SLA: Lead #%d (%s) đã quá hạn phản hồi khách hàng. Nhân viên phụ trách: %s.",
                        info.getLeadId(), leadName, repName);

                psNotif.setInt(1, info.getLeadId());
                psNotif.setInt(2, repId);
                if (info.getTeamId() != null) psNotif.setInt(3, info.getTeamId()); else psNotif.setNull(3, Types.INTEGER);
                psNotif.setInt(4, leaderId);
                psNotif.setString(5, message);
                psNotif.setTimestamp(6, info.getSlaDueDate());
                psNotif.addBatch();

                // 3. Ghi audit log
                psAudit.setInt(1, leaderId);
                psAudit.setString(2, message);
                psAudit.addBatch();

                count++;
            }

            psUpdate.executeBatch();
            try {
                psNotif.executeBatch();
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "Không thể lưu thông báo lead_sla_notifications", ex);
            }
            try {
                psAudit.executeBatch();
            } catch (Exception ex) {
                LOGGER.log(Level.FINE, "Bỏ qua ghi audit log nếu bảng audit_logs chưa tương thích", ex);
            }
        }

        LOGGER.info("Đã phát hiện, gắn cờ quá hạn SLA và tạo thông báo cho " + count + " Lead.");
        return count;
    }

    /**
     * Lấy danh sách thông báo quá hạn SLA cho Trưởng nhóm.
     */
    public List<LeadSlaNotification> getNotificationsForLeader(int leaderId) throws SQLException {
        List<LeadSlaNotification> list = new ArrayList<>();
        String sql = "SELECT * FROM lead_sla_notifications WHERE leader_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leaderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new LeadSlaNotification(
                        rs.getInt("notification_id"),
                        rs.getInt("lead_id"),
                        rs.getInt("sales_rep_id"),
                        (Integer) rs.getObject("team_id"),
                        rs.getInt("leader_id"),
                        rs.getString("message"),
                        rs.getTimestamp("sla_due_date"),
                        rs.getBoolean("is_read"),
                        rs.getTimestamp("created_at")
                    ));
                }
            }
        }
        return list;
    }

    // =========================================================================
    // BACKGROUND WORKER LIFECYCLE
    // =========================================================================

    public synchronized void startSlaMonitor() {
        if (scheduler == null || scheduler.isShutdown()) {
            scheduler = Executors.newSingleThreadScheduledExecutor();
            scheduler.scheduleAtFixedRate(() -> {
                try {
                    checkAndFlagOverdueLeads();
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Lỗi quét kiểm tra định kỳ SLA", e);
                }
            }, 1, 5, TimeUnit.MINUTES);
            LOGGER.info("Lead SLA Monitor Background Worker đã khởi động.");
        }
    }

    public synchronized void stopSlaMonitor() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            LOGGER.info("Lead SLA Monitor Background Worker đã dừng.");
        }
    }
}
