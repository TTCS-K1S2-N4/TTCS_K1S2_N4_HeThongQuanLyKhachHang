<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.crm.model.Account" %>
<%@ page import="java.util.List" %>
<%
    Account currentUser = (Account) session.getAttribute("currentUser");
    String userName = (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Người dùng";
    String userRole = (currentUser != null && currentUser.getRoleName() != null) ? currentUser.getRoleName() : "Administrator";
    String userInitial = (userName.length() > 0) ? userName.substring(0, 1).toUpperCase() : "U";

    List<Account> accountList = (List<Account>) request.getAttribute("accountList");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = 1;
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    if (totalPages == null) totalPages = 1;

    String keywordParam = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
    String statusParam = request.getParameter("status") != null ? request.getParameter("status") : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản | CRM System</title>

    <!-- FOUNDATION -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">

    <!-- ACCOUNT MODULE -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body>
<div class="app">

    <!-- ================= HEADER ================= -->
    <header class="app-header">
        <div class="header-left">
            <a class="header-brand" href="${pageContext.request.contextPath}/">
                <span class="brand-mark">CRM</span>
                <span>CRM System</span>
            </a>
        </div>

        <div class="header-right">
            <div class="header-user">
                <div class="user-avatar">
                    <%= userInitial %>
                </div>
                <div class="header-user-info">
                    <div class="user-name">
                        <%= userName %>
                    </div>
                    <div class="user-role">
                        <%= userRole %>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-secondary btn-sm" style="margin-left: 1rem;" title="Đăng xuất">
                    <i class="fa-solid fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </div>
    </header>

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar">
        <nav aria-label="Điều hướng chính">
            <div class="sidebar-section">
                <div class="sidebar-title">Tổng quan</div>
                <a class="nav-item" href="${pageContext.request.contextPath}/">
                    <span class="nav-icon" aria-hidden="true">◫</span>
                    <span>Dashboard</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-title">Kinh doanh</div>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">◎</span>
                    <span>Khách hàng</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">◇</span>
                    <span>Lead</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">△</span>
                    <span>Cơ hội</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">○</span>
                    <span>Hoạt động</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">▣</span>
                    <span>Báo giá & Hợp đồng</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-title">Phân tích</div>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">◈</span>
                    <span>Chỉ tiêu & KPI</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">▤</span>
                    <span>Báo cáo & Dashboard</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-title">Hệ thống</div>
                <a class="nav-item active" href="${pageContext.request.contextPath}/accounts/list" aria-current="page">
                    <span class="nav-icon" aria-hidden="true">□</span>
                    <span>Quản lý tài khoản</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">⚙</span>
                    <span>Vai trò & phân quyền</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">≡</span>
                    <span>Nhật ký hệ thống</span>
                </a>
            </div>
        </nav>
    </aside>

    <!-- ================= CONTENT ================= -->
    <main class="main-content">
        <div class="content-container">

            <!-- BREADCRUMB -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Quản lý tài khoản</span>
            </nav>

            <!-- PAGE HEADER -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Quản lý tài khoản</h1>
                    <p class="page-description">Quản lý tài khoản người dùng và phân quyền trong hệ thống CRM.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/accounts/create">
                        + Tạo tài khoản
                    </a>
                </div>
            </div>

            <!-- CARD -->
            <section class="card">
                <div class="card-header">
                    <div>
                        <h2 class="card-title">Danh sách tài khoản</h2>
                        <p class="card-description">Danh sách người dùng được cấp quyền truy cập hệ thống.</p>
                    </div>
                </div>

                <div class="card-body">
                    <!-- FILTER FORM -->
                    <form action="${pageContext.request.contextPath}/accounts/list" method="get" class="account-toolbar">
                        <div class="account-filters">
                            <input class="form-control account-search"
                                   type="search"
                                   name="keyword"
                                   value="<%= keywordParam %>"
                                   placeholder="Tìm tên, email...">

                            <select class="form-control account-filter" name="status" aria-label="Lọc theo trạng thái">
                                <option value="">Tất cả trạng thái</option>
                                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(statusParam) ? "selected" : "" %>>Hoạt động</option>
                                <option value="LOCKED" <%= "LOCKED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>Đã khóa</option>
                            </select>

                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-search"></i> Tìm kiếm
                            </button>

                            <a href="${pageContext.request.contextPath}/accounts/list" class="btn btn-secondary">
                                Làm mới
                            </a>
                        </div>
                    </form>

                    <!-- TABLE -->
                    <div class="table-container">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Người dùng</th>
                                <th>Email (Tài khoản)</th>
                                <th>Vai trò</th>
                                <th>Nhóm</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (accountList != null && !accountList.isEmpty()) { 
                                for (Account acc : accountList) {
                                    String avatarChar = (acc.getFullName() != null && !acc.getFullName().trim().isEmpty()) ? acc.getFullName().trim().substring(0, 1).toUpperCase() : "U";
                                    String rName = (acc.getRoleName() != null && !acc.getRoleName().trim().isEmpty()) ? acc.getRoleName() : "Chưa phân vai trò";
                                    String tName = (acc.getTeamName() != null && !acc.getTeamName().trim().isEmpty()) ? acc.getTeamName() : "—";
                                    boolean isActive = "ACTIVE".equalsIgnoreCase(acc.getStatus());
                            %>
                                <tr>
                                    <td>
                                        <div class="account-user">
                                            <div class="account-avatar">
                                                <%= avatarChar %>
                                            </div>
                                            <div>
                                                <div class="account-name"><%= acc.getFullName() %></div>
                                                <div class="account-email"><%= acc.getEmail() %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= acc.getEmail() %></td>
                                    <td><%= rName %></td>
                                    <td><%= tName %></td>
                                    <td>
                                        <% if (isActive) { %>
                                            <span class="badge badge-success">Hoạt động</span>
                                        <% } else { %>
                                            <span class="badge badge-danger">Đã khóa</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="table-actions">
                                            <a class="btn btn-secondary btn-sm"
                                               href="${pageContext.request.contextPath}/accounts/detail?id=<%= acc.getAccountId() %>">
                                                Chi tiết
                                            </a>
                                            <a class="btn btn-secondary btn-sm"
                                               href="${pageContext.request.contextPath}/accounts/edit?id=<%= acc.getAccountId() %>">
                                                Sửa
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } 
                            } else { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 2rem; color: #64748b;">
                                        Không tìm thấy tài khoản phù hợp.
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- PAGINATION -->
                    <% if (totalPages > 1) { %>
                        <nav class="pagination" aria-label="Phân trang">
                            <% if (currentPage > 1) { %>
                                <a class="pagination-item"
                                   href="${pageContext.request.contextPath}/accounts/list?page=<%= currentPage - 1 %>&keyword=<%= keywordParam %>&status=<%= statusParam %>">
                                    ‹
                                </a>
                            <% } %>

                            <% for (int p = 1; p <= totalPages; p++) { %>
                                <a class="pagination-item <%= p == currentPage ? "active" : "" %>"
                                   href="${pageContext.request.contextPath}/accounts/list?page=<%= p %>&keyword=<%= keywordParam %>&status=<%= statusParam %>">
                                    <%= p %>
                                </a>
                            <% } %>

                            <% if (currentPage < totalPages) { %>
                                <a class="pagination-item"
                                   href="${pageContext.request.contextPath}/accounts/list?page=<%= currentPage + 1 %>&keyword=<%= keywordParam %>&status=<%= statusParam %>">
                                    ›
                                </a>
                            <% } %>
                        </nav>
                    <% } %>

                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
