<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.model.Account" %>
<%@ page import="com.crm.model.Role" %>
<%@ page import="com.crm.model.Team" %>
<%@ page import="java.util.List" %>

<%
    Account account = (Account) request.getAttribute("account");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa tài khoản người dùng | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Quản lý tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Chỉnh sửa tài khoản</span>
            </nav>

            <!-- Page Title -->
            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title" style="display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-user-pen" style="color: var(--frost-blue-600); font-size: 24px;"></i>
                        Chỉnh sửa tài khoản người dùng
                    </h1>
                    <p class="page-description" style="color: var(--frost-slate-600); margin-top: 4px;">
                        Cập nhật hồ sơ nhân sự, điều chỉnh phân quyền vai trò và nhóm phụ trách địa bàn.
                    </p>
                </div>
                <div class="page-actions">
                    <a href="${pageContext.request.contextPath}/accounts/detail?accountId=<%= account != null ? account.getAccountId() : "" %>" class="btn-secondary-frost">
                        <i class="fas fa-eye"></i> Xem hồ sơ
                    </a>
                    <a href="${pageContext.request.contextPath}/accounts/list" class="btn-secondary-frost">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>

            <!-- Form Card -->
            <div class="account-form-card">
                <div class="account-form-header">
                    <h2>
                        <i class="fa-solid fa-user-gear" style="color: var(--frost-blue-600);"></i>
                        Thông tin cập nhật: <%= account != null && account.getFullName() != null ? account.getFullName() : "" %>
                    </h2>
                    <p>Thay đổi thông tin nhân viên hoặc điều chuyển nhóm kinh doanh nhận địa bàn mới.</p>
                </div>

                <div class="account-form-body">
                    <!-- Error Alert -->
                    <% if (error != null && !error.trim().isEmpty()) { %>
                        <div class="frost-alert frost-alert-danger" role="alert">
                            <i class="fas fa-triangle-exclamation frost-alert-icon"></i>
                            <div>
                                <strong style="display: block; margin-bottom: 2px;">Cập nhật thất bại!</strong>
                                <span><%= error %></span>
                            </div>
                        </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/accounts/edit" method="post">
                        <input type="hidden" name="accountId" value="<%= account != null ? account.getAccountId() : 0 %>">

                        <!-- Full Name & Email Grid -->
                        <div class="form-grid-2">
                            <div class="form-group-custom">
                                <label class="form-label-custom" for="editFullName">
                                    Họ và tên <span class="required-star">*</span>
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-regular fa-user input-icon"></i>
                                    <input id="editFullName" name="fullName" class="form-input-custom" type="text" 
                                           value="<%= account != null && account.getFullName() != null ? account.getFullName() : "" %>" required>
                                </div>
                                <span class="form-hint">Họ và tên hiển thị trong hệ thống và các báo cáo.</span>
                            </div>

                            <div class="form-group-custom">
                                <label class="form-label-custom" for="editEmail">
                                    Email công ty (Tên đăng nhập)
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-regular fa-envelope input-icon"></i>
                                    <input id="editEmail" name="email" class="form-input-custom" type="email" 
                                           value="<%= account != null && account.getEmail() != null ? account.getEmail() : "" %>" disabled>
                                </div>
                                <span class="form-hint">Định danh đăng nhập duy nhất của tài khoản (cố định).</span>
                            </div>
                        </div>

                        <!-- Phone & Team Grid -->
                        <div class="form-grid-2">
                            <div class="form-group-custom">
                                <label class="form-label-custom" for="editPhone">
                                    Số điện thoại
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-solid fa-phone input-icon"></i>
                                    <input id="editPhone" name="phone" class="form-input-custom" type="tel" 
                                           placeholder="Ví dụ: 0912 345 678"
                                           value="<%= account != null && account.getPhone() != null ? account.getPhone() : "" %>">
                                </div>
                                <span class="form-hint">Số điện thoại liên hệ công tác của nhân viên.</span>
                            </div>

                            <div class="form-group-custom">
                                <label class="form-label-custom" for="teamId">
                                    Nhóm kinh doanh (Địa bàn)
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-solid fa-user-group input-icon"></i>
                                    <select id="teamId" name="teamId" class="form-select-custom">
                                        <option value="">-- Chọn nhóm kinh doanh --</option>
                                        <% 
                                        List<Team> teams = (List<Team>) request.getAttribute("teams");
                                        if (teams != null) {
                                            for (Team t : teams) {
                                                boolean selected = account != null && account.getTeamId() != null && account.getTeamId() == t.getId();
                                        %>
                                            <option value="<%= t.getId() %>" <%= selected ? "selected" : "" %>><%= t.getName() %> (<%= t.getRegion() != null ? t.getRegion() : "Toàn quốc" %>)</option>
                                        <% 
                                            }
                                        } 
                                        %>
                                    </select>
                                </div>
                                <span class="form-hint">Điều chuyển nhóm khi nhân viên nhận địa bàn thị trường mới.</span>
                            </div>
                        </div>

                        <!-- Role Selection -->
                        <div class="form-group-custom">
                            <label class="form-label-custom" for="roleIds">
                                Vai trò hệ thống <span class="required-star">*</span>
                            </label>
                            <div class="input-with-icon">
                                <i class="fa-solid fa-shield-halved input-icon"></i>
                                <select id="roleIds" name="roleIds" class="form-select-custom" required>
                                    <option value="">-- Chọn vai trò --</option>
                                    <% 
                                    List<Role> roles = (List<Role>) request.getAttribute("roles");
                                    if (roles != null) {
                                        for (Role r : roles) {
                                            boolean selected = account != null && account.getRoleIds() != null && account.getRoleIds().contains(r.getId());
                                    %>
                                        <option value="<%= r.getId() %>" <%= selected ? "selected" : "" %>><%= r.getName() %></option>
                                    <% 
                                        }
                                    } 
                                    %>
                                </select>
                            </div>
                            <span class="form-hint">Quyết định quyền hạn thao tác dữ liệu khách hàng và cơ hội bán hàng.</span>
                        </div>

                        <!-- Form Actions Bar -->
                        <div class="form-actions-bar">
                            <a class="btn-secondary-frost" href="${pageContext.request.contextPath}/accounts/list">
                                <i class="fas fa-times"></i> Hủy bỏ
                            </a>
                            <button class="btn-primary-frost" type="submit">
                                <i class="fas fa-floppy-disk"></i> Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
