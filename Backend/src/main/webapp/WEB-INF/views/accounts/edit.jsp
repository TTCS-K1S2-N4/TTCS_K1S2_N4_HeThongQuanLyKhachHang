<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.model.Account" %>
<%@ page import="com.crm.model.Role" %>
<%@ page import="com.crm.model.Team" %>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa tài khoản | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
<% Account account = (Account) request.getAttribute("account"); %>
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Chỉnh sửa</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chỉnh sửa tài khoản</h1>
                    <p class="page-description">Cập nhật thông tin cơ bản của người dùng.</p>
                </div>
            </div>

            <section class="card account-form">
                <div class="card-header">
                    <h2 class="card-title">Thông tin tài khoản</h2>
                </div>
                <div class="card-body">
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger">
                            <%= request.getAttribute("error") %>
                        </div>
                    <% } %>
                    <form action="${pageContext.request.contextPath}/accounts/edit" method="post">
                        <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="editFullName">Họ và tên <span class="form-required">*</span></label>
                                <input id="editFullName" name="fullName" class="form-control" type="text" value="<%= account != null && account.getFullName() != null ? account.getFullName() : "" %>" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="editEmail">Email</label>
                                <input id="editEmail" name="email" class="form-control" type="email" value="<%= account != null && account.getEmail() != null ? account.getEmail() : "" %>" disabled>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="editPhone">Số điện thoại</label>
                                <input id="editPhone" name="phone" class="form-control" type="text" value="<%= account != null && account.getPhone() != null ? account.getPhone() : "" %>">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="teamId">Nhóm</label>
                                <select id="teamId" name="teamId" class="form-control">
                                    <option value="">-- Chọn nhóm --</option>
                                    <% 
                                    List<Team> teams = (List<Team>) request.getAttribute("teams");
                                    if (teams != null) {
                                        for (Team t : teams) {
                                            boolean selected = account != null && account.getTeamId() != null && account.getTeamId() == t.getId();
                                    %>
                                        <option value="<%= t.getId() %>" <%= selected ? "selected" : "" %>><%= t.getName() %></option>
                                    <% 
                                        }
                                    } 
                                    %>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="roleIds">Vai trò <span class="form-required">*</span></label>
                            <select id="roleIds" name="roleIds" class="form-control" required>
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

                        <div class="account-form-actions">
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/list">Hủy</a>
                            <button class="btn btn-primary" type="submit">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
