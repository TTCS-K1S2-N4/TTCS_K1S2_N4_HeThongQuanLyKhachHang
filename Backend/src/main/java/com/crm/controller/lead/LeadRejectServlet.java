package com.crm.controller.lead;

import com.crm.dto.LeadRejectRequest;
import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.model.LeadAssignmentHistory;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
// Use simple parsing instead of Jackson for stub to avoid missing dependency errors

@WebServlet("/leads/reject")
public class LeadRejectServlet extends HttpServlet {
    
    private LeadAssignmentHistoryDAO historyDAO = new LeadAssignmentHistoryDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String userIdStr = req.getHeader("X-User-Id");
        if (userIdStr == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not authenticated");
            return;
        }
        
        String leadIdStr = req.getParameter("leadId");
        String rejectReason = req.getParameter("rejectReason");

        if (leadIdStr == null || rejectReason == null || rejectReason.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "leadId and rejectReason are required");
            return;
        }

        int leadId = Integer.parseInt(leadIdStr);

        int userId = Integer.parseInt(userIdStr);

        // Process rejection via SLA service
        com.crm.service.LeadSlaService slaService = new com.crm.service.LeadSlaService();
        boolean rejected = slaService.rejectLead(leadId, userId, rejectReason);
        
        if (!rejected) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot reject lead. Lead not found, or not assigned to you.");
            return;
        }

        // Record history
        LeadAssignmentHistory history = new LeadAssignmentHistory();
        history.setLeadId(leadId);
        history.setStatus("REJECTED");
        history.setRejectReason(rejectReason);
        history.setAssignedTo(userId);
        history.setAssignedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        historyDAO.saveHistory(history);
        
        // Trigger assignment worker to re-assign immediately
        com.crm.service.LeadAssignmentService assignmentService = new com.crm.service.LeadAssignmentService();
        // Just mock a call to re-assign or rely on background worker.
        // assignmentService.assignLead(...) -> Normally we'd put it back into queue so background worker picks it up
        
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write("{\"message\": \"Lead rejected and returned to queue.\"}");
    }
}
