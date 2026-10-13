package com.crm.controller.lead;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/leads/accept")
public class LeadAcceptServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Authenticate user
        String userIdStr = req.getHeader("X-User-Id");
        if (userIdStr == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not authenticated");
            return;
        }
        int userId = Integer.parseInt(userIdStr);

        String leadIdStr = req.getParameter("leadId");
        if (leadIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing leadId");
            return;
        }
        int leadId = Integer.parseInt(leadIdStr);

        // Use LeadSlaService to process acceptance
        com.crm.service.LeadSlaService slaService = new com.crm.service.LeadSlaService();
        boolean accepted = slaService.acceptLead(leadId, userId);

        if (!accepted) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot accept lead. Lead not found, already accepted, or not assigned to you.");
            return;
        }
        
        // Record history
        com.crm.dao.LeadAssignmentHistoryDAO historyDAO = new com.crm.dao.LeadAssignmentHistoryDAO();
        com.crm.model.LeadAssignmentHistory history = new com.crm.model.LeadAssignmentHistory();
        history.setLeadId(leadId);
        history.setStatus("IN_PROGRESS");
        history.setAssignedTo(userId);
        history.setAssignedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        historyDAO.saveHistory(history);

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write("{\"message\": \"Lead accepted successfully. Status changed to IN_PROGRESS.\"}");
    }
}
