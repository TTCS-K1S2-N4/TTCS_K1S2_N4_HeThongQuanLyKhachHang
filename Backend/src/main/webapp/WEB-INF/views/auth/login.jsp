<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | Frostline CRM</title>
    <meta name="description" content="Frostline CRM - Hệ thống Quản lý Khách hàng Doanh nghiệp bảo mật cấp cao.">

    <!-- GOOGLE FONTS -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Space+Grotesk:wght@600;700&display=swap" rel="stylesheet">

    <!-- FONT AWESOME ICONS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        :root {
            --frost-primary: #0284c7;
            --frost-primary-hover: #0369a1;
            --frost-primary-light: #f0f9ff;
            --frost-cyan: #0ea5e9;
            --frost-bg: #f8fafc;
            --frost-card-bg: #ffffff;
            --frost-border: #e2e8f0;
            --frost-border-hover: #cbd5e1;
            --frost-border-focus: #0284c7;
            --frost-text: #0f172a;
            --frost-text-muted: #64748b;
            --frost-text-dim: #94a3b8;
            --frost-danger: #e11d48;
            --frost-danger-bg: #fff1f2;
            --frost-danger-border: #fecdd3;
            --frost-danger-text: #9f1239;
            --frost-success: #10b981;
            --font-main: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            --font-display: 'Space Grotesk', system-ui, -apple-system, sans-serif;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: var(--font-main);
            -webkit-font-smoothing: antialiased;
        }

        body.frost-login-body {
            min-height: 100vh;
            background: 
                radial-gradient(at 10% 10%, rgba(224, 242, 254, 0.8) 0px, transparent 50%),
                radial-gradient(at 90% 15%, rgba(224, 231, 255, 0.7) 0px, transparent 50%),
                radial-gradient(at 50% 90%, rgba(240, 249, 255, 0.9) 0px, transparent 60%),
                linear-gradient(135deg, #f0f9ff 0%, #f8fafc 40%, #eef2ff 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
            position: relative;
            overflow-x: hidden;
            color: var(--frost-text);
        }

        /* Ambient soft glow orbs */
        .ambient-orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(80px);
            pointer-events: none;
            z-index: 0;
            opacity: 0.75;
        }
        .ambient-orb-1 {
            width: 480px;
            height: 480px;
            background: rgba(186, 230, 253, 0.65);
            top: -120px;
            left: -100px;
        }
        .ambient-orb-2 {
            width: 420px;
            height: 420px;
            background: rgba(224, 231, 255, 0.75);
            bottom: -100px;
            right: -100px;
        }

        /* Centered Auth Card Container */
        .frost-auth-container {
            width: 100%;
            max-width: 470px;
            position: relative;
            z-index: 1;
        }

        .frost-auth-card {
            background: var(--frost-card-bg);
            border: 1px solid rgba(226, 232, 240, 0.95);
            border-radius: 24px;
            box-shadow: 
                0 25px 50px -12px rgba(15, 23, 42, 0.08),
                0 4px 18px -2px rgba(15, 23, 42, 0.04),
                0 0 0 1px rgba(255, 255, 255, 0.8) inset;
            padding: 3rem 2.6rem 2.5rem 2.6rem;
            position: relative;
        }

        /* BRAND LOGO HEADER */
        .frost-brand-header {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 1.85rem;
        }

        .frost-logo-icon {
            width: 50px;
            height: 50px;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            filter: drop-shadow(0 4px 12px rgba(2, 132, 199, 0.2));
            transition: transform 0.3s ease;
        }
        .frost-logo-icon:hover {
            transform: scale(1.08) rotate(3deg);
        }
        .frost-logo-icon svg {
            width: 100%;
            height: 100%;
        }

        .frost-brand-text {
            display: flex;
            flex-direction: column;
        }

        .frost-brand-name-row {
            display: flex;
            align-items: center;
            gap: 0.55rem;
        }

        .frost-brand-title {
            font-family: var(--font-display);
            font-size: 1.75rem;
            font-weight: 700;
            letter-spacing: -0.02em;
            color: #0f172a;
        }

        .frost-brand-badge {
            font-size: 0.72rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            color: #0284c7;
            background: rgba(2, 132, 199, 0.1);
            border: 1px solid rgba(2, 132, 199, 0.28);
            padding: 0.2rem 0.55rem;
            border-radius: 6px;
            text-transform: uppercase;
        }

        .frost-brand-tagline {
            font-size: 0.78rem;
            color: var(--frost-text-muted);
            letter-spacing: 0.02em;
            font-weight: 500;
            margin-top: -1px;
        }

        /* CARD TITLE & SUBTITLE */
        .auth-card-intro {
            text-align: center;
            margin-bottom: 1.75rem;
            padding-bottom: 1.25rem;
            border-bottom: 1px solid #f1f5f9;
        }

        .auth-card-title {
            font-size: 1.35rem;
            font-weight: 700;
            color: #0f172a;
            letter-spacing: -0.015em;
            margin-bottom: 0.35rem;
        }

        .auth-card-subtitle {
            font-size: 0.88rem;
            color: var(--frost-text-muted);
            line-height: 1.45;
        }

        /* INLINE ERROR ALERT */
        .frost-alert-card {
            display: flex;
            align-items: flex-start;
            gap: 0.85rem;
            padding: 0.95rem 1.1rem;
            border-radius: 12px;
            background: var(--frost-danger-bg);
            border: 1px solid var(--frost-danger-border);
            color: var(--frost-danger-text);
            margin-bottom: 1.5rem;
            animation: slideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .frost-alert-icon {
            font-size: 1.15rem;
            color: var(--frost-danger);
            margin-top: 1px;
            flex-shrink: 0;
        }

        .frost-alert-body {
            flex: 1;
        }
        .frost-alert-title {
            font-size: 0.88rem;
            font-weight: 700;
            color: #9f1239;
            margin-bottom: 0.15rem;
        }
        .frost-alert-message {
            font-size: 0.84rem;
            line-height: 1.45;
            color: #be123c;
        }

        /* FORM INPUT GROUPS */
        .frost-form-group {
            margin-bottom: 1.35rem;
        }

        .frost-label-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 0.55rem;
        }

        .frost-label {
            font-size: 0.875rem;
            font-weight: 600;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 0.45rem;
        }

        .frost-forgot-link {
            font-size: 0.825rem;
            font-weight: 600;
            color: var(--frost-primary);
            text-decoration: none;
            transition: color 0.2s ease;
        }
        .frost-forgot-link:hover {
            color: var(--frost-primary-hover);
            text-decoration: underline;
        }

        .frost-input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .frost-input-icon {
            position: absolute;
            left: 1.1rem;
            color: #94a3b8;
            font-size: 1rem;
            pointer-events: none;
            transition: color 0.2s ease;
            z-index: 2;
        }

        .frost-input {
            width: 100%;
            height: 48px;
            padding: 0 2.85rem 0 2.85rem;
            background: #ffffff;
            border: 1.5px solid var(--frost-border);
            border-radius: 12px;
            color: #0f172a;
            font-size: 0.95rem;
            font-weight: 400;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            outline: none;
        }

        .frost-input::placeholder {
            color: #94a3b8;
            font-size: 0.9rem;
        }

        .frost-input:hover {
            border-color: var(--frost-border-hover);
            background: #fafafa;
        }

        .frost-input:focus {
            border-color: var(--frost-primary);
            background: #ffffff;
            box-shadow: 0 0 0 3.5px rgba(2, 132, 199, 0.15);
        }

        .frost-input-wrapper:focus-within .frost-input-icon {
            color: var(--frost-primary);
        }

        /* TOGGLE PASSWORD BUTTON */
        .frost-toggle-pwd {
            position: absolute;
            right: 0.85rem;
            background: none;
            border: none;
            color: #94a3b8;
            font-size: 0.95rem;
            cursor: pointer;
            padding: 0.5rem;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
            z-index: 3;
        }
        .frost-toggle-pwd:hover {
            color: #334155;
            background: #f1f5f9;
        }


        /* PRIMARY SUBMIT BUTTON */
        .frost-btn-submit {
            width: 100%;
            height: 50px;
            margin-top: 0.5rem;
            border: none;
            border-radius: 12px;
            background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%);
            color: #ffffff;
            font-size: 0.98rem;
            font-weight: 600;
            letter-spacing: 0.01em;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.65rem;
            cursor: pointer;
            box-shadow: 0 10px 25px -4px rgba(2, 132, 199, 0.35);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
        }

        .frost-btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 14px 28px -4px rgba(2, 132, 199, 0.45);
            background: linear-gradient(135deg, #0369a1 0%, #1d4ed8 100%);
        }

        .frost-btn-submit:active {
            transform: translateY(1px);
            box-shadow: 0 4px 12px -2px rgba(2, 132, 199, 0.3);
        }

        .frost-btn-submit i {
            transition: transform 0.2s ease;
        }
        .frost-btn-submit:hover i {
            transform: translateX(3px);
        }

        /* LOADING SPINNER */
        .frost-btn-submit.is-loading {
            pointer-events: none;
            opacity: 0.85;
        }
        .btn-spinner {
            display: none;
            width: 18px;
            height: 18px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: #ffffff;
            border-radius: 50%;
            animation: spin 0.75s linear infinite;
        }
        .is-loading .btn-spinner {
            display: inline-block;
        }
        .is-loading .btn-text-normal,
        .is-loading i.fa-arrow-right-to-bracket {
            display: none;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* CARD FOOTER */
        .frost-card-footer {
            margin-top: 1.85rem;
            padding-top: 1.25rem;
            border-top: 1px solid #f1f5f9;
            text-align: center;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            align-items: center;
        }

        .system-status-indicator {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            font-size: 0.78rem;
            color: var(--frost-text-muted);
            font-weight: 500;
        }
        .status-dot-active {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #10b981;
            box-shadow: 0 0 6px #10b981;
        }

        .copyright-text {
            font-size: 0.76rem;
            color: var(--frost-text-dim);
            line-height: 1.4;
        }

        @media (max-width: 480px) {
            body.frost-login-body {
                padding: 1rem;
            }
            .frost-auth-card {
                padding: 2.25rem 1.6rem 2rem 1.6rem;
                border-radius: 20px;
            }
            .frost-brand-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body class="frost-login-body">

    <!-- Ambient glowing backdrop orbs -->
    <div class="ambient-orb ambient-orb-1"></div>
    <div class="ambient-orb ambient-orb-2"></div>

    <div class="frost-auth-container">
        <main class="frost-auth-card">

            <!-- BRAND LOGO HEADER -->
            <div class="frost-brand-header">
                <div class="frost-logo-icon" aria-label="Frostline Logo">
                    <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <defs>
                            <linearGradient id="frostGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#0284c7" />
                                <stop offset="100%" stop-color="#0369a1" />
                            </linearGradient>
                            <linearGradient id="frostGrad2" x1="100%" y1="0%" x2="0%" y2="100%">
                                <stop offset="0%" stop-color="#38bdf8" />
                                <stop offset="100%" stop-color="#0284c7" />
                            </linearGradient>
                            <linearGradient id="frostFacet" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#38bdf8" stop-opacity="0.95" />
                                <stop offset="100%" stop-color="#0284c7" stop-opacity="0.3" />
                            </linearGradient>
                        </defs>
                        <!-- Geometric Hexagonal Crystal Prism -->
                        <path d="M24 3L43 14V34L24 45L5 34V14L24 3Z" stroke="url(#frostGrad1)" stroke-width="2.5" fill="#f0f9ff" />
                        <!-- Facets -->
                        <path d="M24 3V45" stroke="url(#frostGrad2)" stroke-width="1.5" stroke-dasharray="2 2" />
                        <path d="M5 14L43 34" stroke="url(#frostGrad1)" stroke-width="1.2" stroke-opacity="0.35" />
                        <path d="M5 34L43 14" stroke="url(#frostGrad1)" stroke-width="1.2" stroke-opacity="0.35" />
                        <!-- Center Crystal Core -->
                        <polygon points="24,13 34,24 24,35 14,24" fill="url(#frostFacet)" />
                        <circle cx="24" cy="24" r="3.5" fill="#0284c7" />
                    </svg>
                </div>
                <div class="frost-brand-text">
                    <div class="frost-brand-name-row">
                        <span class="frost-brand-title">Frostline</span>
                        <span class="frost-brand-badge">CRM</span>
                    </div>
                    <span class="frost-brand-tagline">Enterprise Customer Intelligence</span>
                </div>
            </div>

            <!-- TITLE & SUBTITLE -->
            <div class="auth-card-intro">
                <h1 class="auth-card-title">Đăng nhập hệ thống</h1>
                <p class="auth-card-subtitle">Nhập email công ty và mật khẩu để truy cập danh mục khách hàng.</p>
            </div>

            <!-- INLINE ERROR ALERT IF LOGIN FAILED -->
            <c:if test="${not empty loginError}">
                <div class="frost-alert-card" role="alert">
                    <div class="frost-alert-icon">
                        <i class="fa-solid fa-circle-exclamation"></i>
                    </div>
                    <div class="frost-alert-body">
                        <div class="frost-alert-title">Đăng nhập không thành công</div>
                        <div class="frost-alert-message"><c:out value="${loginError}"/></div>
                    </div>
                </div>
            </c:if>

            <!-- AUTH FORM -->
            <form id="frostLoginForm" action="${pageContext.request.contextPath}/auth/login" method="post" autocomplete="on">

                <!-- EMAIL / USERNAME INPUT -->
                <div class="frost-form-group">
                    <div class="frost-label-row">
                        <label class="frost-label" for="username">
                            <i class="fa-regular fa-envelope" style="color: var(--frost-primary);"></i> Email công ty
                        </label>
                    </div>
                    <div class="frost-input-wrapper">
                        <i class="fa-regular fa-envelope frost-input-icon"></i>
                        <input 
                            id="username" 
                            name="username" 
                            class="frost-input" 
                            type="text" 
                            value="<c:out value='${not empty username ? username : param.username}'/>" 
                            placeholder="ten.nhanvien@congty.com" 
                            required 
                            autofocus 
                            autocomplete="username">
                    </div>
                </div>

                <!-- PASSWORD INPUT -->
                <div class="frost-form-group">
                    <div class="frost-label-row">
                        <label class="frost-label" for="password">
                            <i class="fa-solid fa-key" style="color: var(--frost-primary);"></i> Mật khẩu
                        </label>
                        <a href="${pageContext.request.contextPath}/auth/forgot-password" class="frost-forgot-link">
                            Quên mật khẩu?
                        </a>
                    </div>
                    <div class="frost-input-wrapper">
                        <i class="fa-solid fa-lock frost-input-icon"></i>
                        <input 
                            id="password" 
                            name="password" 
                            class="frost-input" 
                            type="password" 
                            placeholder="Nhập mật khẩu truy cập" 
                            required 
                            autocomplete="current-password">
                        <button 
                            type="button" 
                            class="frost-toggle-pwd" 
                            onclick="togglePassword('password', this)" 
                            aria-label="Hiện hoặc ẩn mật khẩu" 
                            title="Hiện/Ẩn mật khẩu">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>



                <!-- SUBMIT BUTTON -->
                <button id="frostSubmitBtn" class="frost-btn-submit" type="submit">
                    <span class="btn-spinner"></span>
                    <span class="btn-text-normal">Đăng nhập vào Frostline CRM</span>
                    <i class="fa-solid fa-arrow-right-to-bracket"></i>
                </button>

            </form>

            <!-- CARD FOOTER -->
            <div class="frost-card-footer">
                <div class="system-status-indicator">
                    <span class="status-dot-active"></span>
                    <span>Bảo mật cấp doanh nghiệp • TLS 256-bit</span>
                </div>
                <div class="copyright-text">
                    &copy; 2026 <strong>Frostline CRM</strong>. Tất cả quyền được bảo lưu.
                </div>
            </div>

        </main>
    </div>

    <!-- SCRIPTS -->
    <script>
        // Password Visibility Toggle
        function togglePassword(inputId, btn) {
            const input = document.getElementById(inputId);
            if (!input) return;

            const icon = btn.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                if (icon) {
                    icon.className = 'fa-solid fa-eye-slash';
                }
                btn.setAttribute('aria-label', 'Ẩn mật khẩu');
            } else {
                input.type = 'password';
                if (icon) {
                    icon.className = 'fa-solid fa-eye';
                }
                btn.setAttribute('aria-label', 'Hiện mật khẩu');
            }
        }

        // Form Submit Loading Feedback
        document.getElementById('frostLoginForm').addEventListener('submit', function(e) {
            const btn = document.getElementById('frostSubmitBtn');
            const usernameInput = document.getElementById('username');
            const passwordInput = document.getElementById('password');

            if (usernameInput.value.trim() && passwordInput.value.trim()) {
                btn.classList.add('is-loading');
            }
        });
    </script>

    <!-- Include Toast notifications system -->
    <jsp:include page="/WEB-INF/views/fragments/toast.jsp"/>

</body>
</html>