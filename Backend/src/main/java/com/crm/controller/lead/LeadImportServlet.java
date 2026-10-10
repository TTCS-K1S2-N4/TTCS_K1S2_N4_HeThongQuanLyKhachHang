package com.crm.controller.lead;

import com.crm.dto.LeadImportRequest;
import com.crm.service.LeadImportService;
import com.crm.service.LeadImportService.ImportResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@WebServlet(urlPatterns = {"/leads/import"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 20 * 1024 * 1024)
public class LeadImportServlet extends HttpServlet {

    private LeadImportService importService = new LeadImportService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            if (isJsonRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        boolean isJson = isJsonRequest(req);

        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String action = req.getParameter("action");

        if ("execute".equalsIgnoreCase(action)) {
            handleExecuteImport(req, resp, session, isJson);
        } else {
            handlePreviewImport(req, resp, session, userId, isJson);
        }
    }

    private void handlePreviewImport(HttpServletRequest req, HttpServletResponse resp, HttpSession session, Integer userId, boolean isJson)
            throws ServletException, IOException {
        Part filePart = null;
        try {
            filePart = req.getPart("file");
        } catch (Exception ignore) {}

        if (filePart == null || filePart.getSize() <= 0) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn file Excel để upload.");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST, "Định dạng file không được hỗ trợ. Vui lòng upload file Excel (.xlsx, .xls).");
            return;
        }

        try (InputStream is = filePart.getInputStream()) {
            ImportResult result = importService.parseAndValidateExcel(is, userId);
            session.setAttribute("pendingLeadImportRequests", result.getDetails());

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(buildPreviewJson(result));
            } else {
                req.setAttribute("importResult", result);
                req.getRequestDispatcher("/WEB-INF/views/leads/import_preview.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi đọc file Excel: " + e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    private void handleExecuteImport(HttpServletRequest req, HttpServletResponse resp, HttpSession session, boolean isJson)
            throws ServletException, IOException {
        List<LeadImportRequest> pendingRequests = (List<LeadImportRequest>) session.getAttribute("pendingLeadImportRequests");
        if (pendingRequests == null || pendingRequests.isEmpty()) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST, "Không có dữ liệu import chờ xử lý. Vui lòng upload lại file Excel.");
            return;
        }

        boolean skipDuplicates = req.getParameter("skipDuplicates") == null || "true".equalsIgnoreCase(req.getParameter("skipDuplicates")) || "on".equalsIgnoreCase(req.getParameter("skipDuplicates"));

        int importedCount = importService.executeImport(pendingRequests, skipDuplicates);
        session.removeAttribute("pendingLeadImportRequests");

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"success\",\"message\":\"Import thành công " + importedCount + " Lead vào hệ thống!\",\"importedCount\":" + importedCount + "}");
        } else {
            req.setAttribute("importedCount", importedCount);
            req.getRequestDispatcher("/WEB-INF/views/leads/import_success.jsp").forward(req, resp);
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private void sendErrorResponse(HttpServletResponse resp, HttpServletRequest req, boolean isJson, int statusCode, String message) throws ServletException, IOException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            req.setAttribute("error", message);
            req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
        }
    }

    private String buildPreviewJson(ImportResult res) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"totalRows\":").append(res.getTotalRows())
          .append(",\"validRows\":").append(res.getValidRows())
          .append(",\"duplicateRows\":").append(res.getDuplicateRows())
          .append(",\"failedRows\":").append(res.getFailedRows())
          .append(",\"details\":[");

        List<LeadImportRequest> details = res.getDetails();
        for (int i = 0; i < details.size(); i++) {
            LeadImportRequest item = details.get(i);
            sb.append("{\"rowIndex\":").append(item.getRowIndex())
              .append(",\"fullName\":\"").append(escapeJson(item.getFullName())).append("\"")
              .append(",\"company\":\"").append(escapeJson(item.getCompany())).append("\"")
              .append(",\"email\":\"").append(escapeJson(item.getEmail())).append("\"")
              .append(",\"phone\":\"").append(escapeJson(item.getPhone())).append("\"")
              .append(",\"sourceName\":\"").append(escapeJson(item.getSourceName())).append("\"")
              .append(",\"valid\":").append(item.isValid())
              .append(",\"duplicate\":").append(item.isDuplicate())
              .append(",\"duplicateReason\":\"").append(escapeJson(item.getDuplicateReason())).append("\"")
              .append(",\"error\":\"").append(escapeJson(item.getError())).append("\"}");
            if (i < details.size() - 1) sb.append(",");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
