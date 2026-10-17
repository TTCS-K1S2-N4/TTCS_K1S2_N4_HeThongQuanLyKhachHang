<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty webForm.formName ? webForm.formName : 'Liên hệ với chúng tôi'}"/> | CRM</title>
    
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --primary: #2563eb;
            --primary-hover: #1d4ed8;
            --primary-light: #eff6ff;
            --primary-ring: rgba(37, 99, 235, 0.16);
            --text-main: #0f172a;
            --text-secondary: #475569;
            --text-muted: #94a3b8;
            --border-color: #e2e8f0;
            --bg-page: linear-gradient(135deg, #f8fafc 0%, #edf2f7 50%, #e2e8f0 100%);
            --card-bg: #ffffff;
            --radius-lg: 20px;
            --radius-md: 12px;
            --radius-sm: 8px;
            --shadow-card: 0 20px 40px -15px rgba(15, 23, 42, 0.08), 0 0 0 1px rgba(226, 232, 240, 0.85);
            --transition: all 0.22s cubic-bezier(0.16, 1, 0.3, 1);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            background: var(--bg-page);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px 16px;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        /* Ambient Background Glow */
        .page-wrapper {
            width: 100%;
            max-width: 600px;
            position: relative;
        }

        .ambient-glow {
            position: absolute;
            top: -20px;
            left: 50%;
            transform: translateX(-50%);
            width: 80%;
            height: 160px;
            background: radial-gradient(circle, rgba(37, 99, 235, 0.18) 0%, rgba(56, 189, 248, 0.08) 50%, transparent 70%);
            filter: blur(40px);
            z-index: 0;
            pointer-events: none;
        }

        /* Main Form Card */
        .form-card {
            position: relative;
            z-index: 1;
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-card);
            padding: 38px 34px;
            transition: var(--transition);
        }

        /* Form Header */
        .form-header {
            text-align: center;
            margin-bottom: 28px;
        }

        .form-icon-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 52px;
            height: 52px;
            border-radius: 16px;
            background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
            border: 1px solid #bfdbfe;
            color: var(--primary);
            font-size: 1.35rem;
            margin-bottom: 16px;
            box-shadow: 0 8px 16px -4px rgba(37, 99, 235, 0.15);
        }

        .form-title {
            font-size: 1.55rem;
            font-weight: 800;
            color: var(--text-main);
            letter-spacing: -0.025em;
            line-height: 1.3;
            margin-bottom: 8px;
        }

        .form-desc {
            font-size: 0.92rem;
            color: var(--text-secondary);
            line-height: 1.55;
            max-width: 460px;
            margin: 0 auto;
        }

        /* Form Layout Grid */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 18px;
        }

        .form-grid-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        @media (max-width: 540px) {
            .form-grid-2col {
                grid-template-columns: 1fr;
                gap: 18px;
            }
            .form-card {
                padding: 28px 20px;
                border-radius: 16px;
            }
            .form-title {
                font-size: 1.35rem;
            }
        }

        /* Input Groups & Labels */
        .input-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .input-label {
            font-size: 0.86rem;
            font-weight: 600;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .input-label .required {
            color: #ef4444;
            font-weight: 700;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            color: var(--text-muted);
            font-size: 0.95rem;
            pointer-events: none;
            transition: var(--transition);
        }

        .form-input {
            width: 100%;
            height: 46px;
            padding: 0 14px 0 42px;
            font-size: 0.92rem;
            font-family: inherit;
            color: var(--text-main);
            background: #f8fafc;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-md);
            outline: none;
            transition: var(--transition);
        }

        .form-input::placeholder {
            color: #94a3b8;
            font-size: 0.88rem;
        }

        .form-textarea {
            width: 100%;
            min-height: 100px;
            padding: 12px 14px 12px 42px;
            font-size: 0.92rem;
            font-family: inherit;
            color: var(--text-main);
            background: #f8fafc;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-md);
            outline: none;
            resize: vertical;
            line-height: 1.5;
            transition: var(--transition);
        }

        .form-textarea::placeholder {
            color: #94a3b8;
            font-size: 0.88rem;
        }

        .input-wrapper-textarea .input-icon {
            top: 14px;
        }

        /* Focus States */
        .form-input:focus,
        .form-textarea:focus {
            background: #ffffff;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px var(--primary-ring);
        }

        .input-wrapper:focus-within .input-icon {
            color: var(--primary);
        }

        /* Submit Button */
        .btn-submit {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
            height: 48px;
            background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
            color: #ffffff;
            font-family: inherit;
            font-size: 0.98rem;
            font-weight: 700;
            border: none;
            border-radius: var(--radius-md);
            cursor: pointer;
            box-shadow: 0 10px 20px -5px rgba(37, 99, 235, 0.4);
            transition: var(--transition);
            margin-top: 8px;
        }

        .btn-submit:hover {
            background: linear-gradient(135deg, #1d4ed8 0%, #1e40af 100%);
            box-shadow: 0 12px 24px -5px rgba(37, 99, 235, 0.5);
            transform: translateY(-2px);
        }

        .btn-submit:active {
            transform: translateY(0);
            box-shadow: 0 6px 12px -3px rgba(37, 99, 235, 0.35);
        }

        .btn-submit:disabled {
            opacity: 0.75;
            cursor: not-allowed;
            transform: none !important;
            box-shadow: none !important;
        }

        /* Trust Footer */
        .form-trust-footer {
            margin-top: 20px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.78rem;
            color: #64748b;
        }

        .form-trust-footer i {
            color: #10b981;
            font-size: 0.85rem;
        }

        /* Success & Error State Views */
        .status-box {
            text-align: center;
            padding: 24px 16px;
        }

        .status-icon-box {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 20px;
            animation: popIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .status-icon-success {
            background: #ecfdf5;
            border: 1px solid #a7f3d0;
            color: #059669;
            box-shadow: 0 10px 25px -5px rgba(16, 185, 129, 0.25);
        }

        .status-icon-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            box-shadow: 0 10px 25px -5px rgba(239, 68, 68, 0.25);
        }

        .status-title {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--text-main);
            margin-bottom: 10px;
        }

        .status-desc {
            font-size: 0.92rem;
            color: var(--text-secondary);
            line-height: 1.6;
            max-width: 440px;
            margin: 0 auto 24px auto;
        }

        .btn-status-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 11px 24px;
            background: #f1f5f9;
            color: #1e293b;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            transition: var(--transition);
        }

        .btn-status-action:hover {
            background: #e2e8f0;
            color: #0f172a;
            transform: translateY(-1px);
        }

        @keyframes popIn {
            0% { transform: scale(0.6); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="page-wrapper">
        <div class="ambient-glow"></div>

        <c:choose>
            <%-- Trạng thái không tìm thấy biểu mẫu hoặc biểu mẫu bị vô hiệu hóa --%>
            <c:when test="${empty webForm}">
                <div class="form-card">
                    <div class="status-box">
                        <div class="status-icon-box status-icon-error">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>
                        <h2 class="status-title">Không tìm thấy biểu mẫu</h2>
                        <p class="status-desc">
                            Biểu mẫu thu thập này không tồn tại hoặc đã tạm dừng tiếp nhận phản hồi từ hệ thống.
                        </p>
                    </div>
                </div>
            </c:when>

            <%-- Trạng thái gửi thành công --%>
            <c:when test="${not empty successMessage}">
                <div class="form-card">
                    <div class="status-box">
                        <div class="status-icon-box status-icon-success">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <h2 class="status-title">Gửi thông tin thành công!</h2>
                        <p class="status-desc">
                            <c:out value="${successMessage}"/>
                        </p>
                        <a href="${pageContext.request.contextPath}/leads/public-form?formId=${webForm.formId}" class="btn-status-action">
                            <i class="fa-solid fa-rotate-left"></i> Gửi thêm phản hồi khác
                        </a>
                    </div>
                </div>
            </c:when>

            <%-- Giao diện biểu mẫu đăng ký tiêu chuẩn --%>
            <c:otherwise>
                <div class="form-card">
                    <!-- Header Lockup -->
                    <div class="form-header">
                        <div class="form-icon-pill">
                            <i class="fa-solid fa-paper-plane"></i>
                        </div>
                        <h1 class="form-title">
                            <c:out value="${not empty webForm.formName ? webForm.formName : 'Đăng ký nhận tư vấn'}"/>
                        </h1>
                        <c:if test="${not empty webForm.description}">
                            <p class="form-desc">
                                <c:out value="${webForm.description}"/>
                            </p>
                        </c:if>
                    </div>

                    <form action="${pageContext.request.contextPath}/leads/public-form" method="post" id="publicLeadForm">
                        <input type="hidden" name="formId" value="${webForm.formId}">
                        <c:if test="${not empty param.campaignId}">
                            <input type="hidden" name="campaignId" value="<c:out value='${param.campaignId}'/>">
                        </c:if>
                        <!-- Honeypot chống spam bot -->
                        <input type="text" name="website_hp" id="website_hp" style="display:none;" tabindex="-1" autocomplete="off" aria-hidden="true">

                        <div class="form-grid">
                            <!-- Họ và tên -->
                            <div class="input-group">
                                <label class="input-label" for="fullName">
                                    Họ và tên <span class="required">*</span>
                                </label>
                                <div class="input-wrapper">
                                    <i class="fa-regular fa-user input-icon"></i>
                                    <input type="text" id="fullName" name="fullName" class="form-input" 
                                           value="<c:out value='${param.fullName}'/>" 
                                           placeholder="Nguyễn Văn A" required>
                                </div>
                            </div>

                            <!-- 2 Columns: Email & Số điện thoại -->
                            <div class="form-grid-2col">
                                <div class="input-group">
                                    <label class="input-label" for="email">
                                        Email liên hệ <span class="required">*</span>
                                    </label>
                                    <div class="input-wrapper">
                                        <i class="fa-regular fa-envelope input-icon"></i>
                                        <input type="email" id="email" name="email" class="form-input" 
                                               value="<c:out value='${param.email}'/>" 
                                               placeholder="email@example.com" required>
                                    </div>
                                </div>

                                <div class="input-group">
                                    <label class="input-label" for="phone">
                                        Số điện thoại <span class="required">*</span>
                                    </label>
                                    <div class="input-wrapper">
                                        <i class="fa-solid fa-phone input-icon"></i>
                                        <input type="tel" id="phone" name="phone" class="form-input" 
                                               value="<c:out value='${param.phone}'/>" 
                                               placeholder="0912 345 678" required>
                                    </div>
                                </div>
                            </div>

                            <!-- Tên Công ty / Tổ chức -->
                            <div class="input-group">
                                <label class="input-label" for="company">
                                    Công ty / Đơn vị công tác
                                </label>
                                <div class="input-wrapper">
                                    <i class="fa-regular fa-building input-icon"></i>
                                    <input type="text" id="company" name="company" class="form-input" 
                                           value="<c:out value='${param.company}'/>" 
                                           placeholder="Tên doanh nghiệp hoặc tổ chức...">
                                </div>
                            </div>

                            <!-- Nhu cầu tư vấn -->
                            <div class="input-group">
                                <label class="input-label" for="notes">
                                    Nội dung cần tư vấn & Ghi chú thêm
                                </label>
                                <div class="input-wrapper input-wrapper-textarea">
                                    <i class="fa-regular fa-comment-dots input-icon"></i>
                                    <textarea id="notes" name="notes" class="form-textarea" rows="3" 
                                              placeholder="Chia sẻ ngắn gọn yêu cầu hoặc thắc mắc của bạn..."><c:out value="${param.notes}"/></textarea>
                                </div>
                            </div>

                            <!-- Nút gửi yêu cầu -->
                            <button type="submit" class="btn-submit" id="btnSubmitLead">
                                <span>Gửi thông tin tư vấn</span>
                                <i class="fa-solid fa-arrow-right"></i>
                            </button>
                        </div>
                    </form>

                    <!-- Trust Badge -->
                    <div class="form-trust-footer">
                        <i class="fa-solid fa-shield-halved"></i>
                        <span>Bảo mật an toàn SSL 256-bit • CRM Frostline Lead Capture</span>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Script tương tác & chống gửi trùng lặp -->
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-web-form.js"></script>
</body>
</html>
