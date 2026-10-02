package com.crm.controller.audit;

import com.crm.model.AuditLog;
import com.crm.service.AuditLogService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/audit/list", "/audit/detail"})
public class AuditLogPageServlet extends HttpServlet {

    private AuditLogService auditLogService;

    @Override
    public void init() {
        this.auditLogService = new AuditLogService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        if ("/audit/detail".equalsIgnoreCase(path)) {
            handleDetail(request, response);
        } else {
            handleList(request, response);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");
        Integer userId = parseOptionalInt(userIdStr);

        String entityType = request.getParameter("entityType");
        if (entityType != null) {
            entityType = entityType.trim();
        }

        String fromDate = request.getParameter("fromDate");
        if (fromDate != null) {
            fromDate = fromDate.trim();
        }

        String toDate = request.getParameter("toDate");
        if (toDate != null) {
            toDate = toDate.trim();
        }

        String pageStr = request.getParameter("page");
        Integer requestedPage = parseOptionalInt(pageStr);
        int page = (requestedPage != null && requestedPage > 0) ? requestedPage : 1;

        String pageSizeStr = request.getParameter("pageSize");
        Integer requestedPageSize = parseOptionalInt(pageSizeStr);
        int pageSize = (requestedPageSize != null && requestedPageSize > 0 && requestedPageSize <= 100) ? requestedPageSize : 20;

        List<AuditLog> auditLogs = auditLogService.getAuditLogs(userId, entityType, fromDate, toDate, page, pageSize);
        int totalItems = auditLogService.getTotalAuditLogs(userId, entityType, fromDate, toDate);
        int totalPages = (pageSize > 0) ? (int) Math.ceil((double) totalItems / pageSize) : 1;
        if (totalPages <= 0) totalPages = 1;

        request.setAttribute("auditLogs", auditLogs);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);

        request.setAttribute("userIdParam", userIdStr != null ? userIdStr : "");
        request.setAttribute("entityTypeParam", entityType != null ? entityType : "");
        request.setAttribute("fromDateParam", fromDate != null ? fromDate : "");
        request.setAttribute("toDateParam", toDate != null ? toDate : "");

        request.getRequestDispatcher("/WEB-INF/views/audit/list.jsp").forward(request, response);
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String auditLogIdStr = request.getParameter("auditLogId");
        if (auditLogIdStr == null || auditLogIdStr.trim().isEmpty()) {
            auditLogIdStr = request.getParameter("id");
        }

        Integer auditLogId = parseOptionalInt(auditLogIdStr);
        if (auditLogId == null || auditLogId <= 0) {
            request.setAttribute("errorMessage", "Mã bản ghi nhật ký không hợp lệ.");
            request.setAttribute("auditLog", null);
            request.getRequestDispatcher("/WEB-INF/views/audit/detail.jsp").forward(request, response);
            return;
        }

        AuditLog auditLog = auditLogService.getAuditLogById(auditLogId);
        if (auditLog == null) {
            request.setAttribute("errorMessage", "Không tìm thấy bản ghi nhật ký thay đổi với mã: " + auditLogId);
            request.setAttribute("auditLog", null);
        } else {
            request.setAttribute("auditLog", auditLog);
        }

        request.getRequestDispatcher("/WEB-INF/views/audit/detail.jsp").forward(request, response);
    }

    private Integer parseOptionalInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
