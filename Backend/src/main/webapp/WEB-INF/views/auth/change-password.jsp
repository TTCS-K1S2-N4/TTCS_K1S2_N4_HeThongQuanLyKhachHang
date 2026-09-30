<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi Mật Khẩu | CRM System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/auth.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .password-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }
        .toggle-password-btn {
            position: absolute;
            right: 0.75rem;
            background: none;
            border: none;
            cursor: pointer;
            color: #64748b;
            font-size: 1rem;
            padding: 4px;
            z-index: 5;
        }
        .toggle-password-btn:hover {
            color: #4f46e5;
        }
    </style>
</head>
<body class="auth-page">
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1 class="auth-title">Đổi mật khẩu</h1>
                <p class="auth-description">Vui lòng nhập mật khẩu hiện tại và mật khẩu mới của bạn.</p>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="auth-message auth-message-error" role="alert">
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>

            <% if (request.getAttribute("successMessage") != null) { %>
                <div class="auth-message auth-message-success" role="status">
                    <%= request.getAttribute("successMessage") %>
                </div>
            <% } %>

            <script>
                function togglePassword(inputId, btn) {
                    const input = document.getElementById(inputId);
                    if (!input) return;
                    const icon = btn.querySelector('i');
                    if (input.type === 'password') {
                        input.type = 'text';
                        if (icon) {
                            icon.className = 'fa-solid fa-eye-slash';
                        }
                    } else {
                        input.type = 'password';
                        if (icon) {
                            icon.className = 'fa-solid fa-eye';
                        }
                    }
                }
            </script>

            <form action="${pageContext.request.contextPath}/auth/change-password" method="post">
                <div class="form-group" style="margin-bottom: 1rem;">
                    <label class="form-label" for="oldPassword">Mật khẩu hiện tại</label>
                    <div class="password-wrapper">
                        <input id="oldPassword" name="oldPassword" class="form-control" type="password" style="padding-right: 2.5rem;" required autocomplete="current-password">
                        <button type="button" class="toggle-password-btn" onclick="togglePassword('oldPassword', this)" title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 1rem;">
                    <label class="form-label" for="newPassword">Mật khẩu mới</label>
                    <div class="password-wrapper">
                        <input id="newPassword" name="newPassword" class="form-control" type="password" style="padding-right: 2.5rem;" required autocomplete="new-password">
                        <button type="button" class="toggle-password-btn" onclick="togglePassword('newPassword', this)" title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                    <small style="color: #6b7280; font-size: 0.8rem; display: block; margin-top: 0.25rem;">
                        Tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ cái, 1 chữ số và 1 ký tự đặc biệt.
                    </small>
                </div>

                <div class="form-group" style="margin-bottom: 1.5rem;">
                    <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <div class="password-wrapper">
                        <input id="confirmPassword" name="confirmPassword" class="form-control" type="password" style="padding-right: 2.5rem;" required autocomplete="new-password">
                        <button type="button" class="toggle-password-btn" onclick="togglePassword('confirmPassword', this)" title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>

                <button class="btn btn-primary btn-block" type="submit">
                    Lưu mật khẩu mới
                </button>
            </form>

            <div class="auth-footer" style="margin-top: 1.5rem;">
                <a href="${pageContext.request.contextPath}/" class="auth-link">Quay lại trang chủ</a>
            </div>
        </div>
    </div>
</body>
</html>
