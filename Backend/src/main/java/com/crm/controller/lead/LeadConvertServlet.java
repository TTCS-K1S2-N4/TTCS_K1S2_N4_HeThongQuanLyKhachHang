package com.crm.controller.lead;

import com.crm.dto.LeadConversionRequest;
import com.crm.dto.LeadResponse;
import com.crm.service.LeadConversionService;
import com.crm.service.LeadService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/leads/convert")
public class LeadConvertServlet extends HttpServlet {
    
    private final LeadConversionService conversionService = new LeadConversionService();
    private final LeadService leadService = new LeadService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String leadIdStr = req.getParameter("leadId");
        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            leadIdStr = req.getParameter("id");
        }

        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/leads");
            return;
        }

        try {
            int leadId = Integer.parseInt(leadIdStr.trim());
            LeadResponse lead = leadService.getLeadById(leadId);
            if (lead == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy Lead (ID: #" + leadId + ").");
                return;
            }

            String defaultOppName = "Cơ hội từ " + (lead.getCompany() != null && !lead.getCompany().trim().isEmpty() 
                    ? lead.getCompany().trim() 
                    : lead.getFullName());

            req.setAttribute("lead", lead);
            req.setAttribute("leadId", leadId);
            req.setAttribute("defaultOppName", defaultOppName);
            req.getRequestDispatcher("/WEB-INF/views/leads/convert.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Lead không hợp lệ.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionUserId = session != null ? (Integer) session.getAttribute("userId") : null;
        String userIdStr = req.getHeader("X-User-Id");
        int userId;

        if (userIdStr != null && !userIdStr.trim().isEmpty()) {
            try {
                userId = Integer.parseInt(userIdStr.trim());
            } catch (NumberFormatException e) {
                userId = sessionUserId != null ? sessionUserId : 1;
            }
        } else if (sessionUserId != null) {
            userId = sessionUserId;
        } else {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\": \"User not authenticated\"}");
            return;
        }

        String leadIdStr = req.getParameter("leadId");
        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            leadIdStr = req.getParameter("id");
        }

        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"leadId is required\"}");
            return;
        }

        LeadConversionRequest request = new LeadConversionRequest();
        try {
            request.setLeadId(Integer.parseInt(leadIdStr.trim()));
            request.setOpportunityName(req.getParameter("opportunityName"));
            
            String revenueStr = req.getParameter("expectedRevenue");
            if (revenueStr != null && !revenueStr.trim().isEmpty()) {
                try {
                    request.setExpectedRevenue(Double.parseDouble(revenueStr.trim()));
                } catch (NumberFormatException ignore) {}
            }

            // Execute business logic mapping, atomic transaction, and activity transfer
            LeadConversionService.ConversionResult result = conversionService.convertLead(request, userId);
            
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(String.format(
                    "{\"message\": \"Conversion successful\", \"customerId\": %d, \"contactId\": %d, \"opportunityId\": %d, \"activityCount\": 0}", 
                    result.customerId, result.contactId, result.opportunityId));
        } catch (IllegalArgumentException | IllegalStateException | SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Conversion failed due to system error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
