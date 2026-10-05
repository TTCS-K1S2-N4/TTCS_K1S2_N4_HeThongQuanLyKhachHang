<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE jsp>
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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- AUTH MODULE STYLES -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/auth.css">

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

            /* Lỗi đăng nhập: chỉ hiển thị chữ đỏ đơn giản */
            .login-error {
                color: #dc2626;
                font-size: 0.9rem;
                margin-bottom: 1rem;
                text-align: center;
            }
        </style>
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
                    <p class="auth-description">
                        Nhập thông tin tài khoản để truy cập vào hệ thống
                    </p>
                </div>

                <!-- LOGIN ERROR HAS BEEN MOVED TO TOAST -->

                        <form action="${pageContext.request.contextPath}/auth/login" method="post">

                            <div class="form-group">
                                <label class="form-label" for="username">
                                    Tên đăng nhập / Email
                                </label>

                                <input id="username" name="username" class="form-control" type="text"
                                    value="<%= request.getAttribute(" username") !=null ?
                                    request.getAttribute("username") : "" %>"
                                placeholder="admin@company.com"
                                required
                                autofocus>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="password">
                                    Mật khẩu
                                </label>

                                <div class="password-wrapper">
                                    <input id="password" name="password" class="form-control" type="password"
                                        placeholder="••••••••" style="padding-right: 2.5rem;" required>

                                    <button type="button" class="toggle-password-btn"
                                        onclick="togglePassword('password', this)" title="Hiện/Ẩn mật khẩu">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                </div>

                                <div style="text-align: right; margin-top: 0.5rem;">
                                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="auth-link"
                                        style="font-size: 0.85rem;">
                                        Quên mật khẩu?
                                    </a>
                                </div>
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

        <script>
            function togglePassword(inputId, btn) {
                const input = document.getElementById(inputId);

                if (!input) {
                    return;
                }

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

        <jsp:include page="/WEB-INF/views/fragments/toast.jsp"/>
    </body>

    </html>