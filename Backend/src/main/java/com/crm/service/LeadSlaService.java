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

            // BƯỚC 3: Cập nhật trạng thái Lead sang IN_PROGRESS
            String updateSql = "UPDATE leads SET status = 'IN_PROGRESS', is_overdue = 0, sla_status = 'RESPONDED', updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
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

            // BƯỚC 2: Cập nhật Lead về hàng chờ (owner_id = NULL, status = 'QUEUED')
            String updateSql = "UPDATE leads SET owner_id = NULL, status = 'QUEUED', assigned_at = NULL, is_overdue = 0, sla_status = 'REJECTED', updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
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
    // RESPONSE SLA MANAGEMENT
    // =========================================================================

    /**
     * Lấy thời hạn phản hồi SLA (phút) từ bảng cấu hình lead_sla_configs.
     * Tuyệt đối không tự ý gán cứng 24 giờ nếu CSDL chưa có cấu hình.
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

    /**
     * Quét và gắn cờ quá hạn is_overdue = 1 cho các Lead quá hạn phản hồi.
     * Tuân thủ quy định: Không tự ý chuyển đổi trạng thái Lead, chỉ gắn cờ is_overdue và sla_status = 'OVERDUE'.
     */
    public int checkAndFlagOverdueLeads() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            return checkAndFlagOverdueLeads(conn);
        }
    }

    public int checkAndFlagOverdueLeads(Connection conn) throws SQLException {
        String sql = "UPDATE leads SET is_overdue = 1, sla_status = 'OVERDUE', updated_at = CURRENT_TIMESTAMP " +
                     "WHERE status = 'ASSIGNED' AND is_overdue = 0 " +
                     "AND sla_due_date IS NOT NULL AND sla_due_date < CURRENT_TIMESTAMP";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int flaggedCount = ps.executeUpdate();
            if (flaggedCount > 0) {
                LOGGER.info("Đã phát hiện và gắn cờ quá hạn SLA cho " + flaggedCount + " Lead.");
            }
            return flaggedCount;
        }
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
