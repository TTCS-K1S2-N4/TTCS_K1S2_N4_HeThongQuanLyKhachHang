<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.AuditLog" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhật ký hệ thống | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/audit-log.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content audit-log-page">
        <%
            String userIdParam = request.getAttribute("userIdParam") != null ? (String) request.getAttribute("userIdParam") : "";
            String entityTypeParam = request.getAttribute("entityTypeParam") != null ? (String) request.getAttribute("entityTypeParam") : "";
            String fromDateParam = request.getAttribute("fromDateParam") != null ? (String) request.getAttribute("fromDateParam") : "";
            String toDateParam = request.getAttribute("toDateParam") != null ? (String) request.getAttribute("toDateParam") : "";

            Integer currentPage = (Integer) request.getAttribute("currentPage");
            if (currentPage == null) currentPage = 1;

            Integer totalPages = (Integer) request.getAttribute("totalPages");
            if (totalPages == null) totalPages = 1;

            Integer totalItems = (Integer) request.getAttribute("totalItems");
            if (totalItems == null) totalItems = 0;

            Integer pageSize = (Integer) request.getAttribute("pageSize");
            if (pageSize == null) pageSize = 20;

            List<AuditLog> auditLogs = (List<AuditLog>) request.getAttribute("auditLogs");

            String qParams = "&userId=" + java.net.URLEncoder.encode(userIdParam, "UTF-8")
                    + "&entityType=" + java.net.URLEncoder.encode(entityTypeParam, "UTF-8")
                    + "&fromDate=" + java.net.URLEncoder.encode(fromDateParam, "UTF-8")
                    + "&toDate=" + java.net.URLEncoder.encode(toDateParam, "UTF-8")
                    + "&pageSize=" + pageSize;
        %>

        <div class="content-container">
            <!-- BREADCRUMB -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Nhật ký hệ thống</span>
            </nav>

            <!-- PAGE HEADER -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Nhật ký thay đổi dữ liệu</h1>
                    <p class="page-description">Tra cứu ai đã thay đổi dữ liệu nhạy cảm, vào thời điểm nào và giá trị trước/sau thay đổi.</p>
                </div>
            </div>

            <!-- CARD -->
            <section class="card">
                <div class="card-header">
                    <form id="audit-log-filter-form" class="audit-log-filters" action="${pageContext.request.contextPath}/audit/list" method="get">
                        <div class="audit-log-filter-grid">
                            <div class="form-group">
                                <label class="form-label" for="audit-log-user-id">Người thực hiện (mã người dùng)</label>
                                <input id="audit-log-user-id" class="form-control" type="number" name="userId" min="1" step="1" inputmode="numeric" placeholder="Tất cả người dùng" value="<%= userIdParam %>">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="audit-log-entity-type">Loại đối tượng</label>
                                <select id="audit-log-entity-type" class="form-control" name="entityType">
                                    <option value="" <%= "".equals(entityTypeParam) ? "selected" : "" %>>Tất cả loại đối tượng</option>
                                    <option value="USER_ROLE" <%= "USER_ROLE".equals(entityTypeParam) ? "selected" : "" %>>Vai trò người dùng</option>
                                    <option value="DATA_OWNERSHIP" <%= "DATA_OWNERSHIP".equals(entityTypeParam) ? "selected" : "" %>>Sở hữu dữ liệu</option>
                                    <option value="DISCOUNT" <%= "DISCOUNT".equals(entityTypeParam) ? "selected" : "" %>>Chiết khấu</option>
                                    <option value="KPI" <%= "KPI".equals(entityTypeParam) ? "selected" : "" %>>KPI/Mục tiêu</option>
                                    <option value="SYSTEM" <%= "SYSTEM".equals(entityTypeParam) ? "selected" : "" %>>Hệ thống</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="audit-log-from-date">Từ ngày</label>
                                <input id="audit-log-from-date" class="form-control" type="date" name="fromDate" value="<%= fromDateParam %>">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="audit-log-to-date">Đến ngày</label>
                                <input id="audit-log-to-date" class="form-control" type="date" name="toDate" value="<%= toDateParam %>">
                            </div>
                        </div>

                        <input type="hidden" name="page" value="1">
                        <input type="hidden" name="pageSize" value="<%= pageSize %>">

                        <div class="audit-log-filter-actions">
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/audit/list">Xóa bộ lọc</a>
                            <button class="btn btn-primary" type="submit">Lọc</button>
                        </div>
                    </form>
                </div>

                <div class="card-body">
                    <!-- TABLE -->
                    <div class="table-container">
                        <table class="table audit-log-table">
                            <thead>
                            <tr>
                                <th scope="col">Mã</th>
                                <th scope="col">Thời điểm</th>
                                <th scope="col">Người thực hiện</th>
                                <th scope="col">Đối tượng</th>
                                <th scope="col">Hành động</th>
                                <th scope="col">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody id="audit-log-rows">
                            <%
                                if (auditLogs != null && !auditLogs.isEmpty()) {
                                    for (AuditLog log : auditLogs) {
                                        String performer = log.getPerformedByName() != null ? log.getPerformedByName() : (log.getUserId() > 0 ? "Mã " + log.getUserId() : "N/A");
                                        String timeStr = log.getCreatedAt() != null ? log.getCreatedAt().toString() : "";
                            %>
                            <tr>
                                <td><span class="audit-log-id"><%= log.getLogId() %></span></td>
                                <td><span class="audit-log-time"><%= timeStr %></span></td>
                                <td><span class="audit-log-user"><%= performer %></span></td>
                                <td>
                                    <div class="audit-log-entity">
                                        <span class="badge badge-neutral" style="width: max-content; max-width: 100%; white-space: normal;">
                                            <%= log.getTargetEntityName() != null ? log.getTargetEntityName() : (log.getEntityTypeDisplay() != null ? log.getEntityTypeDisplay() : "") %>
                                        </span>
                                        <span class="audit-log-entity-id">Mã: <%= log.getEntityId() %></span>
                                    </div>
                                </td>
                                <td><span class="badge badge-info audit-log-action" style="width: max-content; max-width: 100%; white-space: normal;"><%= log.getActionDisplay() != null ? log.getActionDisplay() : "" %></span></td>
                                <td>
                                    <div class="table-actions">
                                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/audit/detail?auditLogId=<%= log.getLogId() %>">Chi tiết</a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr class="audit-log-empty-row">
                                <td class="audit-log-empty-cell" colspan="6">Không có nhật ký thay đổi nào phù hợp với bộ lọc.</td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- PAGINATION -->
                    <% if (totalItems > 0 && totalPages > 0) { %>
                    <div id="audit-log-pagination" class="audit-log-pagination">
                        <div class="audit-log-pagination-info">
                            Tổng số <strong><%= totalItems %></strong> bản ghi · Trang <strong><%= currentPage %></strong>/<strong><%= totalPages %></strong>
                        </div>
                        <% if (totalPages > 1) { %>
                        <nav class="pagination" aria-label="Phân trang nhật ký">
                            <% if (currentPage > 1) { %>
                                <a class="pagination-item" href="?page=<%= currentPage - 1 %><%= qParams %>" aria-label="Trang trước">‹</a>
                            <% } else { %>
                                <span class="pagination-item is-disabled" aria-disabled="true">‹</span>
                            <% } %>

                            <%
                                int startPage = Math.max(1, currentPage - 2);
                                int endPage = Math.min(totalPages, currentPage + 2);
                                if (startPage > 1) {
                            %>
                                <a class="pagination-item <%= currentPage == 1 ? "active" : "" %>" href="?page=1<%= qParams %>">1</a>
                                <% if (startPage > 2) { %><span class="pagination-gap">…</span><% } %>
                            <%  } %>

                            <% for (int p = startPage; p <= endPage; p++) { %>
                                <a class="pagination-item <%= currentPage == p ? "active" : "" %>" href="?page=<%= p %><%= qParams %>"><%= p %></a>
                            <% } %>

                            <% if (endPage < totalPages) { %>
                                <% if (endPage < totalPages - 1) { %><span class="pagination-gap">…</span><% } %>
                                <a class="pagination-item <%= currentPage == totalPages ? "active" : "" %>" href="?page=<%= totalPages %><%= qParams %>"><%= totalPages %></a>
                            <% } %>

                            <% if (currentPage < totalPages) { %>
                                <a class="pagination-item" href="?page=<%= currentPage + 1 %><%= qParams %>" aria-label="Trang sau">›</a>
                            <% } else { %>
                                <span class="pagination-item is-disabled" aria-disabled="true">›</span>
                            <% } %>
                        </nav>
                        <% } %>
                    </div>
                    <% } %>

                    <p class="audit-log-timezone-note">Thời điểm hiển thị theo giờ Việt Nam (Asia/Ho_Chi_Minh).</p>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
