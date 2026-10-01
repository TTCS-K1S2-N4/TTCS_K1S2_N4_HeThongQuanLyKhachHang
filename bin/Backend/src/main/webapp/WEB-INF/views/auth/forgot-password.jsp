<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isResetStep ? 'Đặt lại mật khẩu' : 'Quên mật khẩu'} | CRM System</title>
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
            max-width: 440px;
            background: var(--card-bg);
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            padding: 2.5rem 2rem;
            backdrop-filter: blur(10px);
        }

        .auth-header {
            text-align: center;
            margin-bottom: 2rem;
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

        .token-box {
            background: #f1f5f9;
            border: 1px dashed #cbd5e1;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            font-family: monospace;
            font-size: 0.9rem;
            word-break: break-all;
            margin-top: 0.5rem;
            color: #0f172a;
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

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem 0.75rem 2.75rem;
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
            margin-top: 1.75rem;
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
    </style>
</head>
<body>

<div class="auth-container">
    <div class="auth-header">
        <div class="auth-icon">
            <i class="fa-solid ${isResetStep ? 'fa-key' : 'fa-lock'}"></i>
        </div>
        <h1 class="auth-title">${isResetStep ? 'Đặt lại mật khẩu' : 'Quên mật khẩu?'}</h1>
        <p class="auth-subtitle">
            ${isResetStep 
                ? 'Vui lòng nhập mật khẩu mới và mã token xác nhận của bạn.' 
                : 'Nhập địa chỉ email đăng ký để nhận mã token đặt lại mật khẩu.'}
        </p>
    </div>

    <!-- Alert Thông báo Lỗi -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger">
            <i class="fa-solid fa-triangle-exclamation" style="margin-top: 2px;"></i>
            <div>${errorMessage}</div>
        </div>
    </c:if>

    <!-- Alert Thông báo Thành công -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check" style="margin-top: 2px;"></i>
            <div>
                ${successMessage}
                <c:if test="${not empty resetToken}">
                    <div class="token-box">
                        <strong>Token:</strong> ${resetToken}
                    </div>
                    <div style="margin-top: 0.5rem;">
                        <a href="${resetUrl}" class="auth-link">
                            <i class="fa-solid fa-arrow-right"></i> Chuyển tới trang đổi mật khẩu với Token
                        </a>
                    </div>
                </c:if>
            </div>
        </div>
    </c:if>

    <c:choose>
        <%-- FORM BƯỚC 2: ĐẶT LẠI MẬT KHẨU MỚI BẰNG TOKEN --%>
        <c:when test="${isResetStep}">
            <form action="${pageContext.request.contextPath}/auth/forgot-password" method="post">
                <input type="hidden" name="action" value="reset">

                <div class="form-group">
                    <label class="form-label" for="token">Mã Token khôi phục</label>
                    <div class="input-group">
                        <i class="fa-solid fa-ticket input-icon"></i>
                        <input type="text" id="token" name="token" class="form-control" 
                               value="${token}" placeholder="Nhập mã token..." required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="newPassword">Mật khẩu mới</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock input-icon"></i>
                        <input type="password" id="newPassword" name="newPassword" class="form-control" 
                               placeholder="Tối thiểu 6 ký tự..." required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <div class="input-group">
                        <i class="fa-solid fa-shield-halved input-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                               placeholder="Nhập lại mật khẩu mới..." required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-rotate"></i> Cập nhật mật khẩu
                </button>
            </form>

            <div class="auth-footer">
                Chưa nhận được mã Token? 
                <a href="${pageContext.request.contextPath}/auth/forgot-password" class="auth-link">Gửi lại yêu cầu</a>
            </div>
        </c:when>

        <%-- FORM BƯỚC 1: GỬI YÊU CẦU LẤY TOKEN KHÔI PHỤC THEO EMAIL --%>
        <c:otherwise>
            <form action="${pageContext.request.contextPath}/auth/forgot-password" method="post">
                <input type="hidden" name="action" value="request">

                <div class="form-group">
                    <label class="form-label" for="email">Địa chỉ Email</label>
                    <div class="input-group">
                        <i class="fa-regular fa-envelope input-icon"></i>
                        <input type="email" id="email" name="email" class="form-control" 
                               value="${email}" placeholder="example@company.com" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu khôi phục
                </button>
            </form>

            <div class="auth-footer">
                Đã có mã Token? 
                <a href="${pageContext.request.contextPath}/auth/forgot-password?token=" class="auth-link">Nhập Token đổi mật khẩu</a>
            </div>
        </c:otherwise>
    </c:choose>

    <div class="auth-footer" style="margin-top: 1rem;">
        <a href="${pageContext.request.contextPath}/auth/login" class="auth-link">
            <i class="fa-solid fa-arrow-left"></i> Quay lại Đăng nhập
        </a>
    </div>
</div>

</body>
</html>
