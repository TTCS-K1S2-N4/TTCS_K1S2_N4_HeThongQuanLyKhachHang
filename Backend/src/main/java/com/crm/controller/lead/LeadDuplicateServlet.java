package com.crm.controller.lead;

import com.crm.service.LeadDuplicateService;
import com.crm.service.LeadDuplicateService.CustomerCandidate;
import com.crm.service.LeadDuplicateService.LeadDuplicateCandidate;
import com.crm.service.LeadDuplicateService.LeadRecord;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller xử lý phát hiện Lead trùng và so sánh chi tiết.
 * Ánh xạ API D01 (GET /leads/duplicates?leadId={id}) và API D02 (GET /leads/duplicates/compare?leftId={id}&rightId={id}).
 */
@WebServlet(urlPatterns = {"/leads/duplicates", "/leads/duplicates/compare"})
public class LeadDuplicateServlet extends HttpServlet {

    private LeadDuplicateService duplicateService = new LeadDuplicateService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        boolean isJson = isJsonRequest(req);

        if (userId == null) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String path = req.getServletPath();
        if (path != null && path.endsWith("/compare")) {
            handleCompare(req, resp, isJson);
        } else {
            handleDuplicates(req, resp, isJson);
        }
    }

    private void handleDuplicates(HttpServletRequest req, HttpServletResponse resp, boolean isJson) throws ServletException, IOException {
        String leadIdStr = req.getParameter("leadId");

        if (leadIdStr != null && !leadIdStr.trim().isEmpty()) {
            try {
                int leadId = Integer.parseInt(leadIdStr.trim());
                LeadRecord lead = duplicateService.findLeadById(leadId);
                List<LeadDuplicateCandidate> leadCandidates = duplicateService.findDuplicatesForLead(leadId);
                List<CustomerCandidate> customerCandidates = duplicateService.findMatchingCustomersForLead(leadId);

                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print(buildSingleLeadDuplicatesJson(lead, leadCandidates, customerCandidates));
                    out.flush();
                } else {
                    req.setAttribute("lead", lead);
                    req.setAttribute("leadCandidates", leadCandidates);
                    req.setAttribute("customerCandidates", customerCandidates);
                    req.getRequestDispatcher("/WEB-INF/views/leads/duplicates.jsp").forward(req, resp);
                }
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Lead không hợp lệ.");
            }
        } else {
            List<LeadDuplicateCandidate> allPairs = duplicateService.findAllDuplicatePairs();

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(buildAllPairsJson(allPairs));
                out.flush();
            } else {
                req.setAttribute("duplicatePairs", allPairs);
                req.getRequestDispatcher("/WEB-INF/views/leads/duplicates.jsp").forward(req, resp);
            }
        }
    }

    private void handleCompare(HttpServletRequest req, HttpServletResponse resp, boolean isJson) throws ServletException, IOException {
        String leftIdStr = req.getParameter("leftId");
        String rightIdStr = req.getParameter("rightId");

        if (leftIdStr == null || rightIdStr == null || leftIdStr.trim().isEmpty() || rightIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cần cung cấp đủ leftId và rightId để so sánh.");
            return;
        }

        try {
            int leftId = Integer.parseInt(leftIdStr.trim());
            int rightId = Integer.parseInt(rightIdStr.trim());

            if (leftId == rightId) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Không thể so sánh một bản ghi với chính nó.");
                return;
            }

            LeadRecord leftLead = duplicateService.findLeadById(leftId);
            LeadRecord rightLead = duplicateService.findLeadById(rightId);

            if (leftLead == null || rightLead == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đủ 2 Lead để so sánh.");
                return;
            }

            List<String> reasons = duplicateService.evaluateDuplicateReasons(leftLead, rightLead);

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(buildCompareJson(leftLead, rightLead, reasons));
                out.flush();
            } else {
                req.setAttribute("leftLead", leftLead);
                req.setAttribute("rightLead", rightLead);
                req.setAttribute("reasons", reasons);
                req.getRequestDispatcher("/WEB-INF/views/leads/merge.jsp").forward(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số ID không hợp lệ.");
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        return "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private String buildSingleLeadDuplicatesJson(LeadRecord lead, List<LeadDuplicateCandidate> leadCandidates, List<CustomerCandidate> customerCandidates) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"status\":\"success\",");
        sb.append("\"lead\":").append(lead != null ? leadToJson(lead) : "null").append(",");
        sb.append("\"leadCandidates\":[");
        for (int i = 0; i < leadCandidates.size(); i++) {
            LeadDuplicateCandidate c = leadCandidates.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"lead\":").append(leadToJson(c.getRight())).append(",");
            sb.append("\"reasons\":[\"").append(String.join("\",\"", c.getReasons())).append("\"]}");
        }
        sb.append("],");
        sb.append("\"customerCandidates\":[");
        for (int i = 0; i < customerCandidates.size(); i++) {
            CustomerCandidate c = customerCandidates.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"customerId\":").append(c.getCustomer().getCustomerId()).append(",");
            sb.append("\"customerName\":\"").append(escapeJson(c.getCustomer().getCustomerName())).append("\",");
            sb.append("\"phone\":\"").append(escapeJson(c.getCustomer().getPhone())).append("\",");
            sb.append("\"email\":\"").append(escapeJson(c.getCustomer().getEmail())).append("\",");
            sb.append("\"reasons\":[\"").append(String.join("\",\"", c.getReasons())).append("\"]}");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String buildAllPairsJson(List<LeadDuplicateCandidate> pairs) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"status\":\"success\",\"total\":").append(pairs.size()).append(",\"data\":[");
        for (int i = 0; i < pairs.size(); i++) {
            LeadDuplicateCandidate c = pairs.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"left\":").append(leadToJson(c.getLeft())).append(",");
            sb.append("\"right\":").append(leadToJson(c.getRight())).append(",");
            sb.append("\"reasons\":[\"").append(String.join("\",\"", c.getReasons())).append("\"]}");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String buildCompareJson(LeadRecord left, LeadRecord right, List<String> reasons) {
        return "{\"status\":\"success\",\"left\":" + leadToJson(left) +
                ",\"right\":" + leadToJson(right) +
                ",\"reasons\":[\"" + String.join("\",\"", reasons) + "\"]}";
    }

    private String leadToJson(LeadRecord l) {
        if (l == null) return "null";
        return "{" +
                "\"leadId\":" + l.getLeadId() + "," +
                "\"fullName\":\"" + escapeJson(l.getFullName()) + "\"," +
                "\"companyName\":\"" + escapeJson(l.getCompanyName()) + "\"," +
                "\"email\":\"" + escapeJson(l.getEmail()) + "\"," +
                "\"phone\":\"" + escapeJson(l.getPhone()) + "\"," +
                "\"status\":\"" + escapeJson(l.getStatus()) + "\"" +
                "}";
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
