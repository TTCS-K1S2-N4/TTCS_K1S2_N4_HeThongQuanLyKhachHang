<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    Boolean isResetStepObj = (Boolean) request.getAttribute("isResetStep");
    boolean isResetStep = isResetStepObj != null && isResetStepObj;
    String title = isResetStep ? "Đặt lại mật khẩu" : "Quên mật khẩu?";
    String subtitle = isResetStep
            ? "Nhập mật khẩu tạm thời nhận được từ email và mật khẩu mới của bạn."
            : "Nhập địa chỉ email đã đăng ký để nhận mật khẩu tạm thời.";
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String token = (String) request.getAttribute("token");
    String email = (String) request.getAttribute("email");
    if (token == null) token = "";
    if (email == null) email = "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= title %> | CRM System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --bg-gradient: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%);
            --card-bg: rgba(255, 255, 255, 0.96);
            --text-main: #1e293b;
            --text-muted: #64748b;
            --danger: #ef4444;
            --success: #10b981;
            --border: #e2e8f0;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }

        body {
            min-height: 100vh;
            background: var(--bg-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
        }

        .auth-container {
            width: 100%;
            max-width: 460px;
            background: var(--card-bg);
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            padding: 2.5rem 2rem;
            backdrop-filter: blur(10px);
        }

        .auth-header {
            text-align: center;
            margin-bottom: 1.75rem;
        }

        .auth-icon {
            width: 64px;
            height: 64px;
            background: #e0e7ff;
            color: var(--primary);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.75rem;
            margin-bottom: 1rem;
        }

        .auth-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 0.5rem;
        }

        .auth-subtitle {
            font-size: 0.9rem;
            color: var(--text-muted);
            line-height: 1.5;
        }

        .alert {
            padding: 1rem;
            border-radius: 12px;
            font-size: 0.875rem;
            margin-bottom: 1.5rem;
            line-height: 1.5;
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
        }

        .alert-danger {
            background-color: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .alert-success {
            background-color: #ecfdf5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .form-group {
            margin-bottom: 1.25rem;
        }

        .form-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-main);
            margin-bottom: 0.5rem;
        }

        .input-group {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 1rem;
        }

        .toggle-password-btn {
            position: absolute;
            right: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-muted);
            font-size: 1rem;
            padding: 4px;
            z-index: 5;
        }

        .toggle-password-btn:hover {
            color: var(--primary);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 2.5rem 0.75rem 2.75rem;
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-size: 0.95rem;
            color: var(--text-main);
            transition: all 0.2s ease;
            outline: none;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.15);
        }

        .btn-submit {
            width: 100%;
            padding: 0.85rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s ease;
            margin-top: 0.5rem;
        }

        .btn-submit:hover {
            background: var(--primary-hover);
        }

        .auth-footer {
            text-align: center;
            margin-top: 1.5rem;
            font-size: 0.875rem;
            color: var(--text-muted);
        }

        .auth-link {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }

        .auth-link:hover {
            text-decoration: underline;
        }

        .password-hint {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 0.35rem;
        }
    </style>
</head>
<body>

<div class="auth-container">
    <div class="auth-header">
        <div class="auth-icon">
            <i class="fa-solid <%= isResetStep ? "fa-key" : "fa-lock" %>"></i>
        </div>
        <h1 class="auth-title"><%= title %></h1>
        <p class="auth-subtitle">
            <%= subtitle %>
        </p>
    </div>

    <!-- GLOBAL MESSAGES HAVE BEEN MOVED TO TOAST -->

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

    <% if (isResetStep) { %>
        <%-- BƯỚC 2: MÀN HÌNH ĐẶT LẠI MẬT KHẨU --%>
            <form action="${pageContext.request.contextPath}/auth/forgot-password" method="post">
                <input type="hidden" name="action" value="reset">

                <div class="form-group">
                    <label class="form-label" for="token">Mật khẩu tạm thời</label>
                    <div class="input-group">
                        <i class="fa-solid fa-key input-icon"></i>
                        <input type="password" id="token" name="token" class="form-control" 
                               value="<%= token %>" placeholder="Nhập mật khẩu tạm thời từ email..." required>
                        <button type="button" class="toggle-password-btn" onclick="togglePassword('token', this)" title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="newPassword">Mật khẩu mới</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock input-icon"></i>
                        <input type="password" id="newPassword" name="newPassword" class="form-control" 
                               placeholder="Tối thiểu 8 ký tự..." required>
                        <button type="button" class="toggle-password-btn" onclick="togglePassword('newPassword', this)" title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                    <p class="password-hint">Yêu cầu: Tối thiểu 8 ký tự, có ít nhất 1 chữ cái, 1 chữ số và 1 ký tự đặc biệt.</p>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <div class="input-group">
                        <i class="fa-solid fa-shield-halved input-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                               placeholder="Nhập lại mật khẩu mới..." required>
                        <button type="button" class="toggle-password-btn" onclick="togglePassword('confirmPassword', this)" title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-check-circle"></i> Xác nhận đổi mật khẩu
                </button>
            </form>

            <div class="auth-footer">
                Chưa nhận được email hoặc mật khẩu hết hạn? 
                <a href="${pageContext.request.contextPath}/auth/forgot-password" class="auth-link">Gửi lại email</a>
            </div>
    <% } else { %>
        <%-- BƯỚC 1: NHẬP EMAIL ĐỂ NHẬN MẬT KHẨU TẠM THỜI --%>
            <form action="${pageContext.request.contextPath}/auth/forgot-password" method="post">
                <input type="hidden" name="action" value="request">

                <div class="form-group">
                    <label class="form-label" for="email">Địa chỉ Email</label>
                    <div class="input-group">
                        <i class="fa-regular fa-envelope input-icon"></i>
                        <input type="email" id="email" name="email" class="form-control" 
                               value="<%= email %>" placeholder="example@company.com" required style="padding-right: 1rem;">
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-paper-plane"></i> Gửi mật khẩu tạm thời
                </button>
            </form>

            <div class="auth-footer">
                Đã có mật khẩu tạm thời? 
                <a href="${pageContext.request.contextPath}/auth/forgot-password?token=" class="auth-link">Đặt lại mật khẩu ngay</a>
            </div>
    <% } %>

    <div class="auth-footer" style="margin-top: 1.25rem;">
        <a href="${pageContext.request.contextPath}/auth/login" class="auth-link">
            <i class="fa-solid fa-arrow-left"></i> Quay lại Đăng nhập
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/toast.jsp"/>
</body>
</html>
