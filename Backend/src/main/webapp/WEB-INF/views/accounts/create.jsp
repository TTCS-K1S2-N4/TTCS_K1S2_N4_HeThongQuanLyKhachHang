<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.Role" %>
<%@ page import="com.crm.model.Team" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo mới tài khoản | CRM System</title>
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
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Tạo mới</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Tạo mới tài khoản</h1>
                    <p class="page-description">Thêm mới tài khoản người dùng vào hệ thống.</p>
                </div>
            </div>

            <section class="card account-form">
                <div class="card-header">
                    <h2 class="card-title">Thông tin tài khoản</h2>
                </div>

                <div class="card-body">
                    <% String error = (String) request.getAttribute("error"); if (error != null) { %><div class="alert alert-danger"><%= error %></div><% } %>
                    <form action="${pageContext.request.contextPath}/accounts/create" method="post">
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="editFullName">Họ và tên <span class="form-required">*</span></label>
                                <input id="editFullName" name="fullName" class="form-control" type="text" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="editEmail">Email <span class="form-required">*</span></label>
                                <input id="editEmail" name="email" class="form-control" type="email" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="editPhone">Số điện thoại</label>
                                <input id="editPhone" name="phone" class="form-control" type="text">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="roleIds">Vai trò <span class="form-required">*</span></label>
                                <select id="roleIds" name="roleIds" class="form-control" multiple required style="height: 120px;">
                                    
                                    <% 
                                    List<Role> roles = (List<Role>) request.getAttribute("roles");
                                    if (roles != null) {
                                        for (Role r : roles) {
                                    %>
                                    <option value="<%= r.getId() %>"><%= r.getName() %></option>
                                    <% 
                                        }
                                    } 
                                    %>
                                </select>
                                <small class="text-muted">Giữ Ctrl (hoặc Cmd) để chọn nhiều vai trò</small>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="teamId">Nhóm</label>
                                <select id="teamId" name="teamId" class="form-control">
                                    <option value="">-- Chọn nhóm (Không bắt buộc) --</option>
                                    <% 
                                    List<Team> teams = (List<Team>) request.getAttribute("teams");
                                    if (teams != null) {
                                        for (Team t : teams) {
                                    %>
                                    <option value="<%= t.getId() %>"><%= t.getName() %></option>
                                    <% 
                                        }
                                    } 
                                    %>
                                </select>
                                <small class="text-muted">Giữ Ctrl (hoặc Cmd) để chọn nhiều vai trò</small>
                            </div>
                        </div>

                        <p style="color: #666; font-size: 14px; margin-bottom: 20px;">
                            Mật khẩu tạm thời sẽ được tự động sinh và gửi qua Email sau khi tạo.
                        </p>

                        <div class="account-form-actions">
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/list">Hủy</a>
                            <button class="btn btn-primary" type="submit">Tạo tài khoản</button>
                        </div>
                    </form>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>

