package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dao.LeadSavedFilterDAO;
import com.crm.dto.LeadFilterRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Lead;
import com.crm.model.LeadSavedFilter;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý Lọc danh sách Lead, kiểm soát Data Scope, gắn cờ quá hạn SLA và Lưu bộ lọc cá nhân (S4-09).
 * - S4-09-AC-01: Lọc theo trạng thái, nguồn, phân loại nóng/ấm/lạnh, người phụ trách, thời gian.
 * - S4-09-AC-02: Lead quá SLA hiển thị nổi bật trên danh sách.
 * - S4-09-AC-03: Lưu và đặt tên cho bộ lọc hay dùng.
 */
public class LeadFilterService {

    private static final Logger LOGGER = Logger.getLogger(LeadFilterService.class.getName());
    private static final long SLA_DURATION_MS = 24 * 60 * 60 * 1000L; // 24 giờ

    private final LeadDAO leadDAO;
    private final LeadSavedFilterDAO savedFilterDAO;
    private final PermissionService permissionService;
    private final LeadScoringService scoringService;

    public LeadFilterService() {
        this.leadDAO = new LeadDAO();
        this.savedFilterDAO = new LeadSavedFilterDAO();
        this.permissionService = new PermissionService();
        this.scoringService = new LeadScoringService();
    }

    public LeadFilterService(LeadDAO leadDAO, LeadSavedFilterDAO savedFilterDAO,
                             PermissionService permissionService, LeadScoringService scoringService) {
        this.leadDAO = Objects.requireNonNull(leadDAO, "LeadDAO không được để null");
        this.savedFilterDAO = Objects.requireNonNull(savedFilterDAO, "LeadSavedFilterDAO không được để null");
        this.permissionService = Objects.requireNonNull(permissionService, "PermissionService không được để null");
        this.scoringService = Objects.requireNonNull(scoringService, "LeadScoringService không được để null");
    }

    /**
     * Xác định danh sách ID người phụ trách được phép truy cập dựa trên Data Scope (MY, TEAM, ALL).
     */
    public List<Integer> getEffectiveOwnerIds(LeadFilterRequest request, int userId, List<Integer> roleIds) {
        List<Integer> roles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(0);
        // Kiểm tra phân quyền truy cập phạm vi (LEAD)
        List<Integer> accessibleOwnerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roles, "LEAD");
        if (accessibleOwnerIds == null || accessibleOwnerIds.isEmpty()) {
            // Fallback sang ACCOUNT nếu cấu hình quyền dùng chung module ACCOUNT
            accessibleOwnerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roles, "ACCOUNT");
        }

        // Nếu người dùng chọn xem Lead "Của tôi" (MY)
        if (request != null && ("MY".equalsIgnoreCase(request.getOwnerScope()) || (request.getOwnerId() != null && request.getOwnerId() == -1))) {
            return Collections.singletonList(userId);
        }

        // Nếu người dùng chọn lọc theo một Owner cụ thể
        if (request != null && request.getOwnerId() != null && request.getOwnerId() > 0) {
            int requestedOwnerId = request.getOwnerId();
            // Nếu có giới hạn truy cập mà người được yêu cầu không nằm trong danh sách được phép
            if (accessibleOwnerIds != null && !accessibleOwnerIds.contains(requestedOwnerId)) {
                return Collections.emptyList(); // Không có quyền xem owner này
            }
            return Collections.singletonList(requestedOwnerId);
        }

        return accessibleOwnerIds;
    }

    /**
     * Truy vấn danh sách Lead theo bộ lọc với Data Scope và đánh dấu quá hạn SLA (S4-09-AC-01 & S4-09-AC-02).
     */
    public List<LeadResponse> filterLeads(LeadFilterRequest request, int userId, List<Integer> roleIds) {
        List<Integer> effectiveOwnerIds = getEffectiveOwnerIds(request, userId, roleIds);
        if (effectiveOwnerIds != null && effectiveOwnerIds.isEmpty()) {
            return Collections.emptyList();
        }

        StringBuilder sql = new StringBuilder(
            "SELECT l.*, s.source_name, wf.form_name AS web_form_name, u.full_name AS owner_name " +
            "FROM leads l " +
            "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
            "LEFT JOIN lead_web_forms wf ON l.web_form_id = wf.form_id " +
            "LEFT JOIN users u ON l.owner_id = u.user_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        buildFilterConditions(sql, params, request, effectiveOwnerIds);

        // Sắp xếp ưu tiên theo Điểm số giảm dần (S4-05-AC-04) và thời gian tạo mới nhất
        sql.append("ORDER BY l.score DESC, l.created_at DESC ");

        // Phân trang
        sql.append("LIMIT ? OFFSET ? ");
        params.add(request.getPageSize());
        params.add(request.getOffset());

        List<LeadResponse> results = new ArrayList<>();
        long now = System.currentTimeMillis();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Lead lead = mapResultSetToLead(rs);
                    LeadResponse resp = LeadResponse.fromModel(lead);

                    // Đánh giá cờ quá hạn SLA (S4-09-AC-02): Lead chưa xử lý quá 24h
                    boolean overdue = isLeadOverdue(lead, now);
                    resp.setSlaOverdue(overdue);

                    // Đảm bảo phân loại Nóng/Ấm/Lạnh đúng theo điểm hiện tại
                    if (lead.getRating() != null && !lead.getRating().trim().isEmpty()) {
                        resp.setClassification(lead.getRating().trim());
                    } else {
                        resp.setClassification(scoringService.determineClassification(lead.getScore(), scoringService.getHotThreshold(), scoringService.getWarmThreshold()));
                    }

                    results.add(resp);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn filterLeads: " + e.getMessage(), e);
        }

        return results;
    }

    /**
     * Đếm tổng số Lead thỏa mãn bộ lọc để phục vụ phân trang.
     */
    public int countFilteredLeads(LeadFilterRequest request, int userId, List<Integer> roleIds) {
        List<Integer> effectiveOwnerIds = getEffectiveOwnerIds(request, userId, roleIds);
        if (effectiveOwnerIds != null && effectiveOwnerIds.isEmpty()) {
            return 0;
        }

        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) " +
            "FROM leads l " +
            "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        buildFilterConditions(sql, params, request, effectiveOwnerIds);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng filterLeads: " + e.getMessage(), e);
        }

        return 0;
    }

    private void buildFilterConditions(StringBuilder sql, List<Object> params, LeadFilterRequest request, List<Integer> effectiveOwnerIds) {
        if (request == null) return;

        // 1. Tìm kiếm từ khóa (Họ tên, email, số điện thoại, công ty)
        if (request.getKeyword() != null && !request.getKeyword().trim().isEmpty()) {
            String kw = "%" + request.getKeyword().trim() + "%";
            sql.append("AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ? OR l.company LIKE ?) ");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        // 2. Lọc Trạng thái (Status)
        if (request.getStatus() != null && !request.getStatus().trim().isEmpty()) {
            sql.append("AND l.status = ? ");
            params.add(request.getStatus().trim());
        }

        // 3. Lọc Nguồn Lead (Source)
        if (request.getSource() != null && !request.getSource().trim().isEmpty()) {
            String src = request.getSource().trim();
            Integer srcId = null;
            try {
                srcId = Integer.parseInt(src);
            } catch (NumberFormatException ignore) {}

            if (srcId != null && srcId > 0) {
                sql.append("AND (l.lead_source_id = ? OR s.source_name = ?) ");
                params.add(srcId);
                params.add(src);
            } else {
                sql.append("AND (s.source_name = ? OR l.source = ?) ");
                params.add(src);
                params.add(src);
            }
        }

        // 4. Lọc Phân loại Nóng / Ấm / Lạnh (Classification / Rating)
        String classification = request.getClassification();
        if (classification != null && !classification.trim().isEmpty()) {
            sql.append("AND l.rating = ? ");
            params.add(classification.trim());
        }

        // 5. Ràng buộc Người phụ trách theo Data Scope
        if (effectiveOwnerIds != null) {
            boolean isExplicit = (request.getOwnerId() != null && request.getOwnerId() > 0)
                    || "MY".equalsIgnoreCase(request.getOwnerScope())
                    || (request.getOwnerId() != null && request.getOwnerId() == -1);

            if (isExplicit) {
                if (effectiveOwnerIds.size() == 1) {
                    sql.append("AND l.owner_id = ? ");
                    params.add(effectiveOwnerIds.get(0));
                } else if (!effectiveOwnerIds.isEmpty()) {
                    sql.append("AND l.owner_id IN (");
                    for (int i = 0; i < effectiveOwnerIds.size(); i++) {
                        sql.append(i > 0 ? ",?" : "?");
                        params.add(effectiveOwnerIds.get(i));
                    }
                    sql.append(") ");
                }
            } else {
                // Khi không lọc đích danh 1 người phụ trách cụ thể:
                // - Vai trò có phạm vi TEAM (Trưởng nhóm, effectiveOwnerIds.size() > 1): Có quyền xem Lead của nhóm và Lead chưa phân công để phân công công việc
                // - Vai trò có phạm vi MY (Nhân viên, effectiveOwnerIds.size() == 1): Chỉ có quyền xem Lead do chính mình phụ trách. Không nới lỏng xem Lead chưa phân công
                if (effectiveOwnerIds.size() > 1) {
                    sql.append("AND (l.owner_id IN (");
                    for (int i = 0; i < effectiveOwnerIds.size(); i++) {
                        sql.append(i > 0 ? ",?" : "?");
                        params.add(effectiveOwnerIds.get(i));
                    }
                    sql.append(") OR l.owner_id IS NULL) ");
                } else if (effectiveOwnerIds.size() == 1) {
                    sql.append("AND l.owner_id = ? ");
                    params.add(effectiveOwnerIds.get(0));
                }
            }
        }

        // 6. Lọc khoảng thời gian tạo (From Date - To Date)
        String fromDate = request.getFromDate();
        String toDate = request.getToDate();
        if (fromDate != null && toDate != null && fromDate.trim().matches("^\\d{4}-\\d{2}-\\d{2}$") && toDate.trim().matches("^\\d{4}-\\d{2}-\\d{2}$")) {
            String f = fromDate.trim();
            String t = toDate.trim();
            if (f.compareTo(t) > 0) {
                // Đảo ngược ngày an toàn nếu người dùng nhập fromDate > toDate
                String temp = f; f = t; t = temp;
            }
            sql.append("AND l.created_at >= ? AND l.created_at <= ? ");
            params.add(f + " 00:00:00");
            params.add(t + " 23:59:59");
        } else {
            if (fromDate != null && fromDate.trim().matches("^\\d{4}-\\d{2}-\\d{2}$")) {
                sql.append("AND l.created_at >= ? ");
                params.add(fromDate.trim() + " 00:00:00");
            }
            if (toDate != null && toDate.trim().matches("^\\d{4}-\\d{2}-\\d{2}$")) {
                sql.append("AND l.created_at <= ? ");
                params.add(toDate.trim() + " 23:59:59");
            }
        }

        // 7. Lọc Lead quá SLA (S4-09-AC-02 & S4-07)
        if (request.isOverdue()) {
            sql.append("AND (l.is_overdue = 1 OR l.status = 'OVERDUE' OR l.sla_status = 'OVERDUE' " +
                       "OR (l.sla_due_date IS NOT NULL AND l.sla_due_date < NOW() AND (l.sla_status IS NULL OR l.sla_status != 'RESPONDED')) " +
                       "OR (l.status IN ('NEW', 'ASSIGNED', 'Mới tạo', 'QUEUED') AND (l.sla_status IS NULL OR l.sla_status != 'RESPONDED') AND l.created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR))) ");
            sql.append("AND (l.sla_status IS NULL OR l.sla_status != 'RESPONDED') ");
            sql.append("AND (l.status IS NULL OR l.status NOT IN ('CONTACTED', 'CONVERTED')) ");
        }
    }

    public boolean isLeadOverdue(Lead lead, long now) {
        if (lead == null) return false;

        // 1. Lead đã phản hồi hoặc đã chuyển đổi: không bao giờ quá hạn
        if ("RESPONDED".equalsIgnoreCase(lead.getSlaStatus()) || "CONTACTED".equalsIgnoreCase(lead.getStatus()) || "CONVERTED".equalsIgnoreCase(lead.getStatus())) {
            return false;
        }

        // 2. Lead đã được gắn cờ quá hạn trong DB
        if (lead.isOverdue() || "OVERDUE".equalsIgnoreCase(lead.getStatus()) || "OVERDUE".equalsIgnoreCase(lead.getSlaStatus())) {
            return true;
        }

        // 3. Lead có hạn chót sla_due_date và đã quá hạn
        if (lead.getSlaDueDate() != null && lead.getSlaDueDate().getTime() < now) {
            return true;
        }

        // 4. Fallback 24h đối với lead mới tạo chưa tiếp nhận
        if (lead.getCreatedAt() == null) return false;
        String status = lead.getStatus();
        boolean isPending = status == null || "NEW".equalsIgnoreCase(status) || "ASSIGNED".equalsIgnoreCase(status)
                || "Mới tạo".equalsIgnoreCase(status) || "QUEUED".equalsIgnoreCase(status);
        if (!isPending) return false;

        long elapsed = now - lead.getCreatedAt().getTime();
        return elapsed > SLA_DURATION_MS;
    }

    private Lead mapResultSetToLead(ResultSet rs) throws SQLException {
        Lead lead = new Lead();
        lead.setLeadId(rs.getInt("lead_id"));
        lead.setFullName(rs.getString("full_name"));
        lead.setFirstName(rs.getString("first_name"));
        lead.setLastName(rs.getString("last_name"));
        lead.setTitle(rs.getString("title"));
        lead.setCompany(rs.getString("company"));
        lead.setEmail(rs.getString("email"));
        lead.setPhone(rs.getString("phone"));
        lead.setLeadSourceId((Integer) rs.getObject("lead_source_id"));
        lead.setWebFormId((Integer) rs.getObject("web_form_id"));
        lead.setStatus(rs.getString("status"));
        lead.setRating(rs.getString("rating"));
        lead.setScore(rs.getInt("score"));
        lead.setIndustry(rs.getString("industry"));
        lead.setAddress(rs.getString("address"));
        lead.setCity(rs.getString("city"));
        lead.setState(rs.getString("state"));
        lead.setCountry(rs.getString("country"));
        lead.setZipCode(rs.getString("zip_code"));
        lead.setOwnerId((Integer) rs.getObject("owner_id"));
        lead.setNotes(rs.getString("notes"));
        lead.setCreatedAt(rs.getTimestamp("created_at"));
        lead.setUpdatedAt(rs.getTimestamp("updated_at"));

        try { lead.setAssignedAt(rs.getTimestamp("assigned_at")); } catch (SQLException ignore) {}
        try { lead.setSlaDueDate(rs.getTimestamp("sla_due_date")); } catch (SQLException ignore) {}
        try { lead.setSlaStatus(rs.getString("sla_status")); } catch (SQLException ignore) {}
        try { lead.setOverdue(rs.getBoolean("is_overdue")); } catch (SQLException ignore) {}

        try { lead.setSourceName(rs.getString("source_name")); } catch (SQLException ignore) {}
        try { lead.setWebFormName(rs.getString("web_form_name")); } catch (SQLException ignore) {}
        try { lead.setOwnerName(rs.getString("owner_name")); } catch (SQLException ignore) {}

        return lead;
    }

    // ==========================================
    // Quản lý Bộ lọc lưu sẵn (S4-09-AC-03)
    // ==========================================

    public boolean saveFilter(LeadSavedFilter filter, int userId) {
        if (filter == null) return false;
        filter.setUserId(userId);
        filter.setModule("LEAD");
        return savedFilterDAO.createSavedFilter(filter);
    }

    public boolean existsSavedFilterName(int userId, String filterName) {
        return savedFilterDAO.existsByName(userId, filterName);
    }

    public List<LeadSavedFilter> getSavedFilters(int userId) {
        return savedFilterDAO.getSavedFiltersByUserId(userId);
    }

    public boolean deleteSavedFilter(int filterId, int userId) {
        return savedFilterDAO.deleteSavedFilter(filterId, userId);
    }
}
