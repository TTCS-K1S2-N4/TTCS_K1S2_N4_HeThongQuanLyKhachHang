<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.Account" %>
<%@ page import="com.crm.model.Role" %>
<%@ page import="com.crm.model.Team" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý tài khoản người dùng | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css?v=<%= System.currentTimeMillis() %>">
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
            if (currentPage == null || currentPage < 1) currentPage = 1;
            
            Integer pageSize = (Integer) request.getAttribute("pageSize");
            if (pageSize == null || pageSize < 1) pageSize = 20; // Mặc định 20 dòng theo backlog

            Integer totalPages = (Integer) request.getAttribute("totalPages");
            if (totalPages == null || totalPages < 1) totalPages = 1;

            Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
            if (totalAccounts == null) totalAccounts = 0;
            
            List<Role> roles = (List<Role>) request.getAttribute("roles");
            List<Team> teams = (List<Team>) request.getAttribute("teams");
            List<Account> accountList = (List<Account>) request.getAttribute("accountList");

            // Đếm thống kê nhanh trên trang hiện tại
            int activeCount = 0;
            int lockedCount = 0;
            if (accountList != null) {
                for (Account a : accountList) {
                    if ("ACTIVE".equals(a.getStatus())) {
                        activeCount++;
                    } else if ("LOCKED".equals(a.getStatus())) {
                        lockedCount++;
                    }
                }
            }

            String encodedKeyword = java.net.URLEncoder.encode(keyword, "UTF-8");
            String qParams = "&keyword=" + encodedKeyword + "&teamId=" + teamIdStr + "&roleId=" + roleIdStr + "&status=" + status + "&pageSize=" + pageSize;
            
            String msg = request.getParameter("msg");
            String errorParam = request.getParameter("error");

            int startItem = totalAccounts > 0 ? (currentPage - 1) * pageSize + 1 : 0;
            int endItem = Math.min(currentPage * pageSize, totalAccounts);

            boolean hasFilter = !keyword.trim().isEmpty() || !teamIdStr.isEmpty() || !roleIdStr.isEmpty() || !status.isEmpty();
        %>

        <div class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Quản trị hệ thống</a>
                <span>/</span>
                <span class="breadcrumb-current">Quản lý tài khoản</span>
            </nav>

            <!-- Page Title & Actions -->
            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title" style="display: flex; align-items: center; gap: 10px;">
                        <i class="fa-solid fa-users-gear" style="color: var(--frost-blue-600); font-size: 24px;"></i>
                        Quản lý tài khoản người dùng
                    </h1>
                    <p class="page-description" style="color: var(--frost-slate-600); margin-top: 4px;">
                        Cấp quyền cho nhân viên kinh doanh mới ngay ngày đầu nhận địa bàn và điều phối tài khoản hệ thống.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 10px; align-items: center;">
                    <a href="${pageContext.request.contextPath}/import/excel" class="btn-secondary-frost">
                        <i class="fa-solid fa-file-excel" style="color: #107c41;"></i> Nhập từ Excel
                    </a>
                    <a href="${pageContext.request.contextPath}/accounts/create" class="btn-primary-frost">
                        <i class="fas fa-user-plus"></i> Tạo tài khoản mới
                    </a>
                </div>
            </div>

            <!-- Stats Overview Cards -->
            <div class="accounts-stats-grid">
                <div class="account-stat-card">
                    <div class="account-stat-info">
                        <span class="account-stat-label">Tổng người dùng</span>
                        <span class="account-stat-value"><%= totalAccounts %></span>
                    </div>
                    <div class="account-stat-icon-wrapper icon-blue">
                        <i class="fa-solid fa-users"></i>
                    </div>
                </div>

                <div class="account-stat-card">
                    <div class="account-stat-info">
                        <span class="account-stat-label">Đang hoạt động</span>
                        <span class="account-stat-value" style="color: var(--frost-emerald-600);"><%= activeCount %></span>
                    </div>
                    <div class="account-stat-icon-wrapper icon-emerald">
                        <i class="fa-solid fa-user-check"></i>
                    </div>
                </div>

                <div class="account-stat-card">
                    <div class="account-stat-info">
                        <span class="account-stat-label">Đang bị khóa</span>
                        <span class="account-stat-value" style="color: var(--frost-rose-600);"><%= lockedCount %></span>
                    </div>
                    <div class="account-stat-icon-wrapper icon-rose">
                        <i class="fa-solid fa-user-lock"></i>
                    </div>
                </div>

                <div class="account-stat-card">
                    <div class="account-stat-info">
                        <span class="account-stat-label">Nhóm kinh doanh</span>
                        <span class="account-stat-value"><%= teams != null ? teams.size() : 0 %></span>
                    </div>
                    <div class="account-stat-icon-wrapper icon-amber">
                        <i class="fa-solid fa-sitemap"></i>
                    </div>
                </div>
            </div>

            <!-- Status Alerts & Notifications -->
            <% if ("created".equals(msg) || "created_email_sent".equals(msg)) { %>
                <div class="frost-alert frost-alert-success">
                    <i class="fas fa-circle-check frost-alert-icon"></i>
                    <div>
                        <strong>Tạo tài khoản thành công!</strong> Email kích hoạt kèm mật khẩu tạm thời đã được tự động gửi tới hòm thư của nhân viên.
                    </div>
                </div>
            <% } else if ("created_no_email".equals(msg) || "created_email_failed".equals(msg)) { %>
                <div class="frost-alert frost-alert-warning">
                    <i class="fas fa-triangle-exclamation frost-alert-icon"></i>
                    <div>
                        <strong>Tạo tài khoản thành công, nhưng chưa gửi được Email!</strong> Hệ thống chưa kết nối được máy chủ SMTP. Bạn có thể sử dụng nút <strong>Gửi lại Email</strong> ở cột thao tác bên dưới sau khi kiểm tra cấu hình mạng.
                    </div>
                </div>
            <% } else if ("email_resent_success".equals(msg)) { %>
                <div class="frost-alert frost-alert-success">
                    <i class="fas fa-paper-plane frost-alert-icon"></i>
                    <div>
                        <strong>Đã cấp mật khẩu tạm mới!</strong> Email hướng dẫn kích hoạt tài khoản đã được gửi thành công tới người dùng.
                    </div>
                </div>
            <% } else if ("email_resent_failed".equals(msg)) { %>
                <div class="frost-alert frost-alert-danger">
                    <i class="fas fa-circle-xmark frost-alert-icon"></i>
                    <div>
                        <strong>Gửi lại email thất bại!</strong> Không thể kết nối tới dịch vụ gửi thư SMTP. Vui lòng kiểm tra lại cấu hình hệ thống.
                    </div>
                </div>
            <% } else if ("unlocked".equals(msg)) { %>
                <div class="frost-alert frost-alert-success">
                    <i class="fas fa-unlock frost-alert-icon"></i>
                    <div>
                        <strong>Mở khóa tài khoản thành công!</strong> Tài khoản đã được khôi phục trạng thái Hoạt động và có thể đăng nhập bình thường.
                    </div>
                </div>
            <% } else if ("transferred_and_locked".equals(msg)) { %>
                <div class="frost-alert frost-alert-success">
                    <i class="fas fa-shield-halved frost-alert-icon"></i>
                    <div>
                        <strong>Bàn giao và khóa tài khoản thành công!</strong> Dữ liệu khách hàng đã được bàn giao cho nhân sự mới và tài khoản đã được khóa an toàn.
                    </div>
                </div>
            <% } else if ("unlock_failed".equals(errorParam)) { %>
                <div class="frost-alert frost-alert-danger">
                    <i class="fas fa-circle-xmark frost-alert-icon"></i>
                    <div>
                        <strong>Thao tác mở khóa thất bại!</strong> Tài khoản không tồn tại hoặc có lỗi trong quá trình xử lý.
                    </div>
                </div>
            <% } %>

            <!-- Main Content Card -->
            <section class="accounts-list-card">
                <!-- Filter Toolbar -->
                <div class="accounts-toolbar-container">
                    <form class="accounts-filter-form" action="${pageContext.request.contextPath}/accounts/list" method="get">
                        <!-- Search Keyword (Name or Email) -->
                        <div class="filter-search-box">
                            <i class="fas fa-search filter-search-icon"></i>
                            <input class="filter-search-input" name="keyword" type="search" 
                                   placeholder="Tìm theo tên hoặc email người dùng..." value="<%= keyword %>">
                        </div>

                        <!-- Team Filter -->
                        <select class="filter-select" name="teamId" title="Lọc theo nhóm kinh doanh">
                            <option value="">Tất cả nhóm</option>
                            <% if (teams != null) { for (Team t : teams) { %>
                                <option value="<%= t.getId() %>" <%= teamIdStr.equals(String.valueOf(t.getId())) ? "selected" : "" %>><%= t.getName() %></option>
                            <% } } %>
                        </select>

                        <!-- Role Filter -->
                        <select class="filter-select" name="roleId" title="Lọc theo vai trò">
                            <option value="">Tất cả vai trò</option>
                            <% if (roles != null) { for (Role r : roles) { %>
                                <option value="<%= r.getId() %>" <%= roleIdStr.equals(String.valueOf(r.getId())) ? "selected" : "" %>><%= r.getName() %></option>
                            <% } } %>
                        </select>

                        <!-- Status Filter -->
                        <select class="filter-select" name="status" title="Lọc theo trạng thái">
                            <option value="">Tất cả trạng thái</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>Hoạt động</option>
                            <option value="LOCKED" <%= "LOCKED".equals(status) ? "selected" : "" %>>Bị khóa</option>
                        </select>

                        <!-- Page Size Dropdown (Default 20 per backlog) -->
                        <select class="filter-select filter-select-sm" name="pageSize" onchange="this.form.submit()" title="Số dòng mỗi trang">
                            <option value="10" <%= pageSize == 10 ? "selected" : "" %>>10 / trang</option>
                            <option value="20" <%= pageSize == 20 ? "selected" : "" %>>20 / trang (mặc định)</option>
                            <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50 / trang</option>
                        </select>

                        <!-- Filter Submit & Reset -->
                        <div class="filter-actions">
                            <button class="btn-filter-submit" type="submit">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                            <% if (hasFilter) { %>
                                <a href="${pageContext.request.contextPath}/accounts/list?pageSize=<%= pageSize %>" class="btn-filter-reset" title="Xóa tất cả bộ lọc">
                                    <i class="fas fa-rotate-left"></i> Đặt lại
                                </a>
                            <% } %>
                        </div>
                    </form>
                </div>

                <!-- Account Table Container -->
                <div class="table-responsive">
                    <table class="accounts-table">
                        <thead>
                            <tr>
                                <th style="width: 280px;">Người dùng</th>
                                <th style="width: 140px;">Số điện thoại</th>
                                <th style="width: 180px;">Vai trò</th>
                                <th style="width: 200px;">Nhóm kinh doanh</th>
                                <th style="width: 130px;">Trạng thái</th>
                                <th style="width: 120px;">Ngày tạo</th>
                                <th style="width: 150px; text-align: right;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (accountList != null && !accountList.isEmpty()) {
                                    for (Account account : accountList) {
                                        boolean isActive = "ACTIVE".equals(account.getStatus());
                                        String fullName = account.getFullName() != null ? account.getFullName() : "N/A";
                                        String initial = fullName.length() > 0 ? fullName.substring(0, 1).toUpperCase() : "?";
                                        String phone = account.getPhone() != null && !account.getPhone().trim().isEmpty() ? account.getPhone() : "—";
                            %>
                            <tr>
                                <!-- User Identity -->
                                <td>
                                    <div class="user-identity-cell">
                                        <div class="user-avatar-circle"><%= initial %></div>
                                        <div class="user-identity-info">
                                            <a href="${pageContext.request.contextPath}/accounts/detail?accountId=<%= account.getAccountId() %>" 
                                               class="user-full-name" style="text-decoration: none; color: inherit;">
                                                <%= fullName %>
                                            </a>
                                            <span class="user-email-address">
                                                <i class="fa-regular fa-envelope" style="font-size: 11px;"></i>
                                                <%= account.getEmail() %>
                                            </span>
                                        </div>
                                    </div>
                                </td>

                                <!-- Phone -->
                                <td>
                                    <span style="color: var(--frost-slate-700); font-size: 13px;">
                                        <%= phone %>
                                    </span>
                                </td>

                                <!-- Role -->
                                <td>
                                    <span class="badge-role">
                                        <i class="fa-solid fa-shield-halved" style="font-size: 11px;"></i>
                                        <%= account.getRoleName() != null ? account.getRoleName() : "Chưa phân vai trò" %>
                                    </span>
                                </td>

                                <!-- Team -->
                                <td>
                                    <% if (account.getTeamName() != null && !account.getTeamName().isEmpty()) { %>
                                        <span class="badge-team">
                                            <i class="fa-solid fa-user-group" style="font-size: 11px;"></i>
                                            <%= account.getTeamName() %>
                                        </span>
                                    <% } else { %>
                                        <span style="color: #94a3b8; font-style: italic; font-size: 13px;">Chưa phân nhóm</span>
                                    <% } %>
                                </td>

                                <!-- Status -->
                                <td>
                                    <% if (isActive) { %>
                                        <span class="status-badge status-active">
                                            <span class="status-dot-active"></span> Hoạt động
                                        </span>
                                    <% } else { %>
                                        <span class="status-badge status-locked">
                                            <i class="fas fa-lock" style="font-size: 10px;"></i> Bị khóa
                                        </span>
                                    <% } %>
                                </td>

                                <!-- Created Date -->
                                <td>
                                    <span style="color: var(--frost-slate-600); font-size: 13px;">
                                        <%= account.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(account.getCreatedAt()) : "—" %>
                                    </span>
                                </td>

                                <!-- Actions -->
                                <td>
                                    <div class="account-actions-group" style="justify-content: flex-end;">
                                        <!-- View Detail -->
                                        <a href="${pageContext.request.contextPath}/accounts/detail?accountId=<%= account.getAccountId() %>" 
                                           class="btn-table-action action-view" title="Xem chi tiết hồ sơ">
                                            <i class="fas fa-eye"></i>
                                        </a>

                                        <!-- Edit -->
                                        <a href="${pageContext.request.contextPath}/accounts/edit?accountId=<%= account.getAccountId() %>" 
                                           class="btn-table-action action-edit" title="Chỉnh sửa tài khoản & phân quyền">
                                            <i class="fas fa-pen-to-square"></i>
                                        </a>

                                        <!-- Resend Temporary Password Email -->
                                        <form action="${pageContext.request.contextPath}/accounts/resend-email" method="post" style="display:inline; margin: 0;" 
                                              onsubmit="return confirm('Hệ thống sẽ tạo mật khẩu tạm mới và gửi email kích hoạt tới địa chỉ <%= account.getEmail() %>. Tiếp tục?');">
                                            <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">
                                            <button type="submit" class="btn-table-action action-resend" title="Gửi lại Email mật khẩu tạm thời">
                                                <i class="fas fa-paper-plane"></i>
                                            </button>
                                        </form>

                                        <!-- Lock or Unlock -->
                                        <% if (isActive) { %>
                                            <a href="${pageContext.request.contextPath}/accounts/lock?accountId=<%= account.getAccountId() %>" 
                                               class="btn-table-action action-lock" title="Khóa tài khoản & Bàn giao địa bàn">
                                                <i class="fas fa-lock"></i>
                                            </a>
                                        <% } else { %>
                                            <a href="${pageContext.request.contextPath}/accounts/unlock?accountId=<%= account.getAccountId() %>" 
                                               class="btn-table-action action-unlock" title="Mở khóa tài khoản" 
                                               onclick="return confirm('Bạn có chắc chắn muốn mở khóa tài khoản cho <%= account.getFullName() %>?');">
                                                <i class="fas fa-unlock"></i>
                                            </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7">
                                    <div class="accounts-empty-state">
                                        <div class="empty-state-icon">
                                            <i class="fa-solid fa-user-slash"></i>
                                        </div>
                                        <div class="empty-state-title">Không tìm thấy tài khoản người dùng nào</div>
                                        <div class="empty-state-desc">
                                            <% if (hasFilter) { %>
                                                Không có tài khoản nào phù hợp với điều kiện tìm kiếm. Vui lòng thử từ khóa khác hoặc đặt lại bộ lọc.
                                            <% } else { %>
                                                Hiện tại chưa có người dùng nào trong hệ thống. Bạn có thể nhấn nút "Tạo tài khoản mới" để bắt đầu.
                                            <% } %>
                                        </div>
                                        <% if (hasFilter) { %>
                                            <a href="${pageContext.request.contextPath}/accounts/list?pageSize=<%= pageSize %>" class="btn-secondary-frost" style="margin-top: 10px;">
                                                <i class="fas fa-rotate-left"></i> Xóa bộ lọc tìm kiếm
                                            </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer -->
                <div class="accounts-pagination-footer">
                    <div class="pagination-text">
                        Hiển thị <strong><%= startItem %>–<%= endItem %></strong> trong tổng số <strong><%= totalAccounts %></strong> người dùng
                    </div>
                    
                    <% if (totalPages > 1) { %>
                    <ul class="frost-pagination-nav">
                        <!-- Previous Page Link -->
                        <li class="frost-page-item <%= currentPage == 1 ? "disabled" : "" %>">
                            <% if (currentPage == 1) { %>
                                <span class="frost-page-link"><i class="fas fa-chevron-left" style="font-size: 11px;"></i> Trước</span>
                            <% } else { %>
                                <a class="frost-page-link" href="?page=<%= currentPage - 1 %><%= qParams %>">
                                    <i class="fas fa-chevron-left" style="font-size: 11px;"></i> Trước
                                </a>
                            <% } %>
                        </li>
                        
                        <% 
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);

                            if (startPage > 1) {
                        %>
                            <li class="frost-page-item"><a class="frost-page-link" href="?page=1<%= qParams %>">1</a></li>
                            <% if (startPage > 2) { %>
                                <li class="frost-page-item disabled"><span class="frost-page-link">...</span></li>
                            <% } %>
                        <%  } %>

                        <% for (int i = startPage; i <= endPage; i++) { %>
                            <li class="frost-page-item <%= i == currentPage ? "active" : "" %>">
                                <% if (i == currentPage) { %>
                                    <span class="frost-page-link"><%= i %></span>
                                <% } else { %>
                                    <a class="frost-page-link" href="?page=<%= i %><%= qParams %>"><%= i %></a>
                                <% } %>
                            </li>
                        <% } %>

                        <% if (endPage < totalPages) { %>
                            <% if (endPage < totalPages - 1) { %>
                                <li class="frost-page-item disabled"><span class="frost-page-link">...</span></li>
                            <% } %>
                            <li class="frost-page-item"><a class="frost-page-link" href="?page=<%= totalPages %><%= qParams %>"><%= totalPages %></a></li>
                        <% } %>

                        <!-- Next Page Link -->
                        <li class="frost-page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                            <% if (currentPage == totalPages) { %>
                                <span class="frost-page-link">Sau <i class="fas fa-chevron-right" style="font-size: 11px;"></i></span>
                            <% } else { %>
                                <a class="frost-page-link" href="?page=<%= currentPage + 1 %><%= qParams %>">
                                    Sau <i class="fas fa-chevron-right" style="font-size: 11px;"></i>
                                </a>
                            <% } %>
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
