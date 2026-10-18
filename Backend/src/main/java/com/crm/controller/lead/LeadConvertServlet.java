package com.crm.controller.lead;

import com.crm.dto.LeadConversionRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Account;
import com.crm.service.LeadConversionService;
import com.crm.service.LeadService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadConvertServlet - API xử lý chuyển đổi Lead thành Customer, Contact và Opportunity (S4-08).
 * Endpoint: GET /leads/convert, POST /leads/convert
 */
@WebServlet("/leads/convert")
public class LeadConvertServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LeadConvertServlet.class.getName());

    private LeadConversionService conversionService;
    private final LeadService leadService = new LeadService();

    @Override
    public void init() throws ServletException {
        super.init();
        this.conversionService = new LeadConversionService();
    }

    public void setConversionService(LeadConversionService conversionService) {
        this.conversionService = conversionService;
    }

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
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        try {
            // 1. Xác thực người dùng (Authentication from trusted server-side Session exclusively)
            HttpSession session = req.getSession(false);
            Integer currentUserId = (session != null && session.getAttribute("userId") instanceof Integer)
                    ? (Integer) session.getAttribute("userId")
                    : null;

            if (currentUserId == null) {
                sendJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED, "error", "Yêu cầu đăng nhập để thực hiện chuyển đổi Lead.");
                return;
            }

            // 2. Xác định vai trò đặc quyền (ADMIN / DIRECTOR)
            Account currentUser = (session.getAttribute("currentUser") instanceof Account)
                    ? (Account) session.getAttribute("currentUser")
                    : null;
            Integer roleId = (session.getAttribute("roleId") instanceof Integer)
                    ? (Integer) session.getAttribute("roleId")
                    : (currentUser != null ? currentUser.getRoleId() : null);

            boolean isElevatedRole = false;
            if (currentUser != null && currentUser.getRoleCodes() != null) {
                for (String code : currentUser.getRoleCodes()) {
                    if ("ADMIN".equalsIgnoreCase(code) || "DIRECTOR".equalsIgnoreCase(code)) {
                        isElevatedRole = true;
                        break;
                    }
                }
            }
            if (!isElevatedRole && roleId != null && (roleId == 1 || roleId == 4)) {
                isElevatedRole = true;
            }

            // 3. Đọc dữ liệu đầu vào (Hỗ trợ cả application/x-www-form-urlencoded và application/json)
            String leadIdStr = req.getParameter("leadId");
            if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
                leadIdStr = req.getParameter("id");
            }
            String opportunityName = req.getParameter("opportunityName");
            String revenueStr = req.getParameter("expectedRevenue");
            String accountIdStr = req.getParameter("accountId");

            if ((leadIdStr == null || leadIdStr.trim().isEmpty()) &&
                req.getContentType() != null && req.getContentType().contains("application/json")) {
                StringBuilder sb = new StringBuilder();
                try (BufferedReader reader = req.getReader()) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                String json = sb.toString();
                leadIdStr = LeadAssignServlet.extractJsonField(json, "leadId");
                if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
                    leadIdStr = LeadAssignServlet.extractJsonField(json, "id");
                }
                if (opportunityName == null) opportunityName = LeadAssignServlet.extractJsonField(json, "opportunityName");
                if (revenueStr == null) revenueStr = LeadAssignServlet.extractJsonField(json, "expectedRevenue");
                if (accountIdStr == null) accountIdStr = LeadAssignServlet.extractJsonField(json, "accountId");
            }

            if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Tham số leadId là bắt buộc.");
                return;
            }

            int leadId;
            try {
                leadId = Integer.parseInt(leadIdStr.trim());
            } catch (NumberFormatException e) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Định dạng leadId không hợp lệ.");
                return;
            }

            Double expectedRevenue = null;
            if (revenueStr != null && !revenueStr.trim().isEmpty()) {
                try {
                    expectedRevenue = Double.parseDouble(revenueStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            Integer accountId = null;
            if (accountIdStr != null && !accountIdStr.trim().isEmpty()) {
                try {
                    accountId = Integer.parseInt(accountIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            LeadConversionRequest conversionRequest = new LeadConversionRequest(leadId, opportunityName, expectedRevenue, accountId);

            // 4. Thực thi chuyển đổi nguyên tử qua JDBC Transaction
            LeadConversionService.ConversionResult result = conversionService.convertLead(conversionRequest, currentUserId, isElevatedRole);

            // 5. Trả về kết quả thành công chuẩn theo FE04 contract
            sendSuccessResponse(resp, result);

        } catch (SecurityException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN, "error", e.getMessage());
        } catch (IllegalArgumentException e) {
            int status = (e.getMessage() != null && e.getMessage().contains("không tồn tại"))
                    ? HttpServletResponse.SC_NOT_FOUND
                    : HttpServletResponse.SC_BAD_REQUEST;
            sendJsonResponse(resp, status, "error", e.getMessage());
        } catch (IllegalStateException e) {
            int status = (e.getMessage() != null && e.getMessage().contains("đã được chuyển đổi"))
                    ? HttpServletResponse.SC_CONFLICT
                    : HttpServletResponse.SC_BAD_REQUEST;
            sendJsonResponse(resp, status, "error", e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cơ sở dữ liệu khi chuyển đổi Lead", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi cơ sở dữ liệu khi thực hiện chuyển đổi Lead.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi hệ thống khi chuyển đổi Lead", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi hệ thống nội bộ: " + e.getMessage());
        }
    }

    private void sendSuccessResponse(HttpServletResponse resp, LeadConversionService.ConversionResult result) throws IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        PrintWriter out = resp.getWriter();
        String oppPart = (result.opportunityId != null) ? String.valueOf(result.opportunityId) : "null";
        out.write("{" +
                "\"status\": \"success\"," +
                "\"message\": \"Chuyển đổi Lead thành công.\"," +
                "\"customerId\": " + result.customerId + "," +
                "\"contactId\": " + result.contactId + "," +
                "\"opportunityId\": " + oppPart + "," +
                "\"activityCount\": " + result.activityCount +
                "}");
        out.flush();
    }

    private void sendJsonResponse(HttpServletResponse resp, int statusCode, String status, String message) throws IOException {
        resp.setStatus(statusCode);
        PrintWriter out = resp.getWriter();
        out.write("{\"status\": \"" + status + "\", \"message\": \"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
