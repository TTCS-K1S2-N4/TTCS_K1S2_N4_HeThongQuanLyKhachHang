package com.crm.controller.lead;

import com.crm.dto.LeadConversionRequest;
import com.crm.service.LeadConversionService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/leads/convert")
public class LeadConvertServlet extends HttpServlet {
    
    private final LeadConversionService conversionService = new LeadConversionService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String userIdStr = req.getHeader("X-User-Id");
        if (userIdStr == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not authenticated");
            return;
        }
        int userId = Integer.parseInt(userIdStr);

        String leadIdStr = req.getParameter("leadId");
        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "leadId is required");
            return;
        }

        LeadConversionRequest request = new LeadConversionRequest();
        request.setLeadId(Integer.parseInt(leadIdStr));
        request.setOpportunityName(req.getParameter("opportunityName"));
        
        try {
            // Execute business logic mapping, atomic transaction, and activity transfer
            LeadConversionService.ConversionResult result = conversionService.convertLead(request, userId);
            
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");
            resp.getWriter().write(String.format("{\"message\": \"Conversion successful\", \"customerId\": %d, \"contactId\": %d, \"opportunityId\": %d}", 
                    result.customerId, result.contactId, result.opportunityId));
        } catch (IllegalArgumentException | IllegalStateException | SecurityException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Conversion failed due to system error: " + e.getMessage());
        }
    }
}
