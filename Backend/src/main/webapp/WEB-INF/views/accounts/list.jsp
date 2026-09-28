<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.Account" %>
<%@ page import="com.crm.model.Role" %>
<%@ page import="com.crm.model.Team" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản | CRM System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <%
            String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
            String teamIdStr = request.getParameter("teamId") != null ? request.getParameter("teamId") : "";
            String roleIdStr = request.getParameter("roleId") != null ? request.getParameter("roleId") : "";
            String status = request.getParameter("status") != null ? request.getParameter("status") : "";
            Integer currentPage = (Integer) request.getAttribute("currentPage");
            Integer totalPages = (Integer) request.getAttribute("totalPages");
            Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
            
            List<Role> roles = (List<Role>) request.getAttribute("roles");
            List<Team> teams = (List<Team>) request.getAttribute("teams");
            List<Account> accountList = (List<Account>) request.getAttribute("accountList");

            String qParams = "&keyword=" + keyword + "&teamId=" + teamIdStr + "&roleId=" + roleIdStr + "&status=" + status;
            
            String msg = request.getParameter("msg");
        %>

        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Tài khoản</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Quản lý tài khoản</h1>
                    <p class="page-description">Danh sách và thông tin tài khoản nhân viên.</p>
                </div>
                <div class="page-actions">
                    <a href="${pageContext.request.contextPath}/accounts/create" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Tạo tài khoản
                    </a>
                </div>
            </div>

            <% if ("created".equals(msg)) { %>
                <div class="alert alert-success">Tạo tài khoản thành công và đã gửi email.</div>
            <% } %>

            <section class="card accounts-list-card">
                <div class="card-header">
                    <form class="accounts-filters" action="${pageContext.request.contextPath}/accounts/list" method="get">
                        <div class="search-group">
                            <i class="fas fa-search search-icon"></i>
                            <input class="form-control" name="keyword" type="search" placeholder="Tìm kiếm theo tên hoặc email..." value="<%= keyword %>">
                        </div>

                        <div class="filter-group">
                            <select class="form-control" name="teamId">
                                <option value="">Tất cả nhóm</option>
                                <% if (teams != null) { for (Team t : teams) { %>
                                    <option value="<%= t.getId() %>" <%= teamIdStr.equals(String.valueOf(t.getId())) ? "selected" : "" %>><%= t.getName() %></option>
                                <% } } %>
                            </select>

                            <select class="form-control" name="roleId">
                                <option value="">Tất cả vai trò</option>
                                <% if (roles != null) { for (Role r : roles) { %>
                                    <option value="<%= r.getId() %>" <%= roleIdStr.equals(String.valueOf(r.getId())) ? "selected" : "" %>><%= r.getName() %></option>
                                <% } } %>
                            </select>

                            <select class="form-control" name="status">
                                <option value="">Tất cả trạng thái</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>Hoạt động</option>
                                <option value="LOCKED" <%= "LOCKED".equals(status) ? "selected" : "" %>>Bị khóa</option>
                            </select>

                            <button class="btn btn-secondary" type="submit">Lọc</button>
                        </div>
                    </form>
                </div>

                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Người dùng</th>
                                <th>Vai trò</th>
                                <th>Nhóm</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (accountList != null && !accountList.isEmpty()) {
                                    for (Account account : accountList) {
                                        String badgeClass = "ACTIVE".equals(account.getStatus()) ? "badge-success" : "badge-error";
                                        String displayStatus = "ACTIVE".equals(account.getStatus()) ? "Hoạt động" : "Bị khóa";
                            %>
                            <tr>
                                <td>
                                    <div class="user-info-cell">
                                        <div class="user-avatar"><%= account.getFullName().substring(0, 1).toUpperCase() %></div>
                                        <div class="user-details">
                                            <div class="user-name"><%= account.getFullName() %></div>
                                            <div class="user-email"><%= account.getEmail() %></div>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="badge badge-primary"><%= account.getRoleName() != null ? account.getRoleName() : "Chưa có" %></span></td>
                                <td><%= account.getTeamName() != null ? account.getTeamName() : "Chưa thuộc nhóm" %></td>
                                <td><span class="badge <%= badgeClass %>"><%= displayStatus %></span></td>
                                <td><%= account.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(account.getCreatedAt()) : "" %></td>
                                <td>
                                    <div class="table-actions">
                                        <a href="${pageContext.request.contextPath}/accounts/detail?id=<%= account.getAccountId() %>" class="btn-icon" title="Xem chi tiết"><i class="fas fa-eye"></i></a>
                                        <a href="${pageContext.request.contextPath}/accounts/edit?id=<%= account.getAccountId() %>" class="btn-icon" title="Chỉnh sửa"><i class="fas fa-edit"></i></a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="6" class="text-center">Không tìm thấy tài khoản nào.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="card-footer">
                    <div class="pagination-info">Hiển thị <strong><%= accountList != null ? accountList.size() : 0 %></strong> trên tổng số <strong><%= totalAccounts != null ? totalAccounts : 0 %></strong> tài khoản</div>
                    
                    <% if (totalPages != null && totalPages > 1) { %>
                    <ul class="pagination">
                        <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage - 1 %><%= qParams %>"><i class="fas fa-chevron-left"></i></a>
                        </li>
                        
                        <% for (int i = 1; i <= totalPages; i++) { %>
                        <li class="page-item <%= currentPage == i ? "active" : "" %>">
                            <a class="page-link" href="?page=<%= i %><%= qParams %>"><%= i %></a>
                        </li>
                        <% } %>

                        <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage + 1 %><%= qParams %>"><i class="fas fa-chevron-right"></i></a>
                        </li>
                    </ul>
                    <% } %>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
