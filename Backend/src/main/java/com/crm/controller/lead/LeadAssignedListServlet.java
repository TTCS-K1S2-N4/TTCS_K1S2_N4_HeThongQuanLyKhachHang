package com.crm.controller.lead;

import com.crm.dto.LeadResponse;
import com.crm.service.LeadService;
import com.crm.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadAssignedListServlet - Hiển thị danh sách Lead được phân bổ cho nhân viên kinh doanh hiện tại (S4-07).
 * Endpoint: GET /leads/assigned hoặc /leads/my-assigned
 * Cho phép xem danh sách, nhận Lead (POST /leads/accept) và từ chối Lead (POST /leads/reject).
 */
@WebServlet(urlPatterns = {"/leads/assigned", "/leads/my-assigned"})
public class LeadAssignedListServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LeadAssignedListServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = (session != null && session.getAttribute("userId") instanceof Integer)
                ? (Integer) session.getAttribute("userId")
                : null;

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        List<LeadResponse> assignedLeads = new ArrayList<>();
        String sql = "SELECT l.lead_id, l.full_name, l.company, l.email, l.phone, l.status, " +
                     "l.owner_id, u.full_name AS owner_name, l.created_at, l.assigned_at, " +
                     "l.sla_due_date, l.is_overdue, l.sla_status " +
                     "FROM leads l " +
                     "LEFT JOIN users u ON l.owner_id = u.user_id " +
                     "WHERE l.owner_id = ? AND l.status IN ('ASSIGNED', 'IN_PROGRESS', 'OVERDUE') " +
                     "ORDER BY l.is_overdue DESC, l.assigned_at DESC, l.lead_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LeadResponse lr = new LeadResponse();
                    lr.setLeadId(rs.getInt("lead_id"));
                    lr.setFullName(rs.getString("full_name"));
                    lr.setCompany(rs.getString("company"));
                    lr.setEmail(rs.getString("email"));
                    lr.setPhone(rs.getString("phone"));
                    lr.setStatus(rs.getString("status"));
                    lr.setOwnerId((Integer) rs.getObject("owner_id"));
                    lr.setOwnerName(rs.getString("owner_name"));
                    lr.setCreatedAt(rs.getTimestamp("created_at"));
                    lr.setAssignedAt(rs.getTimestamp("assigned_at"));
                    lr.setSlaDueDate(rs.getTimestamp("sla_due_date"));
                    lr.setSlaStatus(rs.getString("sla_status"));
                    lr.setSlaOverdue(rs.getBoolean("is_overdue") || "OVERDUE".equalsIgnoreCase(rs.getString("status")));
                    assignedLeads.add(lr);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn danh sách Lead được phân cho user #" + userId, e);
        }

        req.setAttribute("leads", assignedLeads);
        req.getRequestDispatcher("/WEB-INF/views/leads/accept-reject.jsp").forward(req, resp);
    }
}
