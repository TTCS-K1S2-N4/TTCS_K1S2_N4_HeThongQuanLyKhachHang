<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | CRM System</title>
    
    <!-- FOUNDATION STYLES -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    
    <!-- AUTH MODULE STYLES -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/auth.css">
</head>
<body class="auth-page">

    <div class="auth-container">
        <!-- BRAND HEADER -->
        <div class="auth-brand">
            <div class="auth-brand-mark">CRM</div>
            <div class="auth-brand-name">CRM System</div>
        </div>

        <!-- AUTH CARD -->
        <div class="auth-card">
            <div class="auth-header">
                <h1 class="auth-title">Đăng nhập hệ thống</h1>
                <p class="auth-description">Nhập thông tin tài khoản để truy cập vào hệ thống</p>
            </div>

            <% if (request.getAttribute("loginError") != null) { %>
                <div class="auth-message auth-message-error" role="alert">
                    <%= request.getAttribute("loginError") %>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth/login" method="post">
                <div class="form-group">
                    <label class="form-label" for="username">Tên đăng nhập / Email</label>
                    <input id="username"
                           name="username"
                           class="form-control"
                           type="text"
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           placeholder="admin@company.com"
                           required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label" for="password">Mật khẩu</label>
                    <input id="password"
                           name="password"
                           class="form-control"
                           type="password"
                           placeholder="••••••••"
                           required>
                </div>

                <button class="btn btn-primary btn-block" type="submit">
                    Đăng nhập
                </button>
            </form>
        </div>

        <div class="auth-footer">
            &copy; 2026 CRM System. Tất cả quyền được bảo lưu.
        </div>
    </div>

</body>
</html>