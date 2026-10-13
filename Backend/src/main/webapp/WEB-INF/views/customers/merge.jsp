<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <title>So sánh & Gộp khách hàng | CRM Pro</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --crm-font: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --crm-navy-900: #0f172a;
            --crm-navy-800: #1e293b;
            --crm-navy-700: #334155;
            --crm-blue-600: #2563eb;
            --crm-blue-700: #1d4ed8;
            --crm-blue-50: #eff6ff;
            --crm-blue-100: #dbeafe;
            --crm-emerald-600: #059669;
            --crm-emerald-50: #ecfdf5;
            --crm-rose-600: #e11d48;
            --crm-rose-50: #fff1f2;
            --crm-amber-500: #f59e0b;
            --crm-amber-50: #fffbeb;
            --crm-slate-50: #f8fafc;
            --crm-slate-100: #f1f5f9;
            --crm-slate-200: #e2e8f0;
            --crm-slate-400: #94a3b8;
            --crm-slate-500: #64748b;
            --crm-radius-lg: 18px;
            --crm-radius-md: 12px;
            --crm-radius-sm: 8px;
            --crm-card-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.04), 0 8px 10px -6px rgba(15, 23, 42, 0.03);
        }

        body {
            font-family: var(--crm-font) !important;
            background-color: #f4f6fa !important;
            color: var(--crm-navy-800);
        }

        .merge-wrapper {
            max-width: 1360px;
            margin: 0 auto;
            padding: 24px 28px 48px;
        }

        .merge-hero {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            padding: 24px 30px;
            box-shadow: var(--crm-card-shadow);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            position: relative;
            overflow: hidden;
        }

        .merge-hero::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(180deg, var(--crm-blue-600) 0%, #4f46e5 100%);
        }

        .merge-hero-info h1 {
            font-size: 22px;
            font-weight: 800;
            color: var(--crm-navy-900);
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .merge-hero-info p {
            margin: 0;
            font-size: 13.5px;
            color: var(--crm-slate-500);
        }

        .merge-alert-banner {
            background: #fffbeb;
            border: 1px solid #fde68a;
            border-radius: var(--crm-radius-md);
            padding: 16px 20px;
            display: flex;
            align-items: flex-start;
            gap: 14px;
            margin-bottom: 24px;
            font-size: 13.5px;
            color: #92400e;
        }

        .merge-alert-banner i {
            font-size: 20px;
            color: #f59e0b;
            flex-shrink: 0;
            margin-top: 2px;
        }

        /* 2-Columns Side by Side Layout */
        .merge-compare-grid {
            display: grid;
            grid-template-columns: 1fr 60px 1fr;
            gap: 16px;
            align-items: stretch;
            margin-bottom: 24px;
        }

        @media (max-width: 900px) {
            .merge-compare-grid {
                grid-template-columns: 1fr;
            }
        }

        .merge-arrow-col {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: var(--crm-blue-600);
            font-size: 24px;
        }

        .merge-box {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            box-shadow: var(--crm-card-shadow);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .merge-box-primary {
            border-top: 4px solid var(--crm-blue-600);
        }

        .merge-box-secondary {
            border-top: 4px solid var(--crm-rose-600);
        }

        .merge-box-header {
            padding: 20px 24px;
            background: #ffffff;
            border-bottom: 1px solid var(--crm-slate-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .merge-box-title {
            font-size: 16px;
            font-weight: 800;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .merge-tag-keep {
            background: var(--crm-blue-50);
            color: var(--crm-blue-700);
            border: 1px solid var(--crm-blue-100);
            padding: 3px 10px;
            border-radius: 999px;
            font-size: 11.5px;
            font-weight: 700;
        }

        .merge-tag-absorb {
            background: var(--crm-rose-50);
            color: var(--crm-rose-600);
            border: 1px solid #fecdd3;
            padding: 3px 10px;
            border-radius: 999px;
            font-size: 11.5px;
            font-weight: 700;
        }

        .merge-box-body {
            padding: 24px;
            flex-grow: 1;
        }

        .merge-field-group {
            margin-bottom: 18px;
        }

        .merge-field-group label {
            font-size: 13px;
            font-weight: 700;
            color: var(--crm-navy-700);
            display: block;
            margin-bottom: 6px;
        }

        .merge-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--crm-slate-200);
            border-radius: var(--crm-radius-md);
            font-size: 14px;
            font-family: inherit;
            color: var(--crm-navy-900);
            box-sizing: border-box;
            outline: none;
            transition: all 0.2s;
        }

        .merge-input:focus {
            border-color: var(--crm-blue-600);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .merge-info-card {
            background: var(--crm-slate-50);
            border: 1px solid var(--crm-slate-200);
            border-radius: var(--crm-radius-md);
            padding: 18px;
            margin-top: 14px;
        }

        .merge-info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px dashed var(--crm-slate-200);
            font-size: 13.5px;
        }

        .merge-info-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .merge-info-label {
            color: var(--crm-slate-500);
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .merge-info-val {
            font-weight: 700;
            color: var(--crm-navy-900);
            text-align: right;
        }

        .btn-merge-confirm {
            background: linear-gradient(135deg, #e11d48 0%, #be123c 100%);
            color: #ffffff;
            border: none;
            padding: 12px 28px;
            border-radius: var(--crm-radius-md);
            font-size: 14.5px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 14px rgba(225, 29, 72, 0.25);
            transition: all 0.2s ease;
        }

        .btn-merge-confirm:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(225, 29, 72, 0.35);
        }

        .btn-merge-cancel {
            background: #ffffff;
            color: var(--crm-slate-500);
            border: 1px solid var(--crm-slate-200);
            padding: 12px 24px;
            border-radius: var(--crm-radius-md);
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        .btn-merge-cancel:hover {
            background: var(--crm-slate-50);
            border-color: var(--crm-slate-400);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
    <main class="main-content">
        <div class="merge-wrapper">

            <!-- Hero Header -->
            <div class="merge-hero">
                <div class="merge-hero-info">
                    <h1>
                        <i class="fa-solid fa-code-merge" style="color: var(--crm-blue-600);"></i>
                        So sánh và Gộp hồ sơ Khách hàng
                    </h1>
                    <p>Hợp nhất hai bản ghi khách hàng: giữ nguyên toàn bộ người liên hệ, cơ hội và lịch sử tương tác</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/customers/duplicates" class="btn-merge-cancel">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách trùng lặp
                    </a>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="margin-bottom: 20px; border-radius: 12px; padding: 14px 20px;">
                    <i class="fa-solid fa-circle-exclamation" style="margin-right: 8px;"></i> <c:out value="${errorMessage}" />
                </div>
            </c:if>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success" style="margin-bottom: 20px; border-radius: 12px; padding: 14px 20px;">
                    <i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> <c:out value="${successMessage}" />
                </div>
            </c:if>

            <!-- Warning Notice -->
            <div class="merge-alert-banner">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <div>
                    <strong>Cảnh báo nghiệp vụ:</strong>
                    Hành động gộp khách hàng không thể hoàn tác. Toàn bộ người liên hệ, cơ hội bán hàng và dòng thời gian hoạt động của <em>Khách hàng phụ</em> sẽ được gộp nguyên vẹn sang <em>Khách hàng chính</em>.
                </div>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/customers/merge">

                <div class="merge-compare-grid">

                    <!-- 1. PRIMARY CUSTOMER COLUMN -->
                    <div class="merge-box merge-box-primary">
                        <div class="merge-box-header">
                            <h3 class="merge-box-title" style="color: var(--crm-blue-700);">
                                <i class="fa-solid fa-circle-check"></i> Khách hàng CHÍNH
                            </h3>
                            <span class="merge-tag-keep">Được giữ lại</span>
                        </div>
                        <div class="merge-box-body">
                            <div class="merge-field-group">
                                <label for="primaryId">
                                    <i class="fa-solid fa-hashtag" style="color: var(--crm-blue-600);"></i> ID khách hàng chính:
                                </label>
                                <input id="primaryId" type="number" name="primaryId" class="merge-input"
                                       value="<c:out value='${primaryId}' />" required min="1" placeholder="Nhập ID khách hàng chính...">
                            </div>

                            <c:choose>
                                <c:when test="${not empty primaryCustomer}">
                                    <div class="merge-info-card">
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-building"></i> Tên khách hàng:</span>
                                            <span class="merge-info-val" style="color: var(--crm-blue-700); font-size: 15px;">
                                                <c:out value="${primaryCustomer.customerName}" />
                                            </span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-phone"></i> Điện thoại:</span>
                                            <span class="merge-info-val"><c:out value="${not empty primaryCustomer.phone ? primaryCustomer.phone : '---'}" /></span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-envelope"></i> Email:</span>
                                            <span class="merge-info-val"><c:out value="${not empty primaryCustomer.email ? primaryCustomer.email : '---'}" /></span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-id-card"></i> Mã số thuế:</span>
                                            <span class="merge-info-val"><c:out value="${not empty primaryCustomer.taxCode ? primaryCustomer.taxCode : '---'}" /></span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-globe"></i> Website:</span>
                                            <span class="merge-info-val"><c:out value="${not empty primaryCustomer.website ? primaryCustomer.website : '---'}" /></span>
                                        </div>
                                        <c:if test="${not empty primaryCustomer.createdAt}">
                                            <div class="merge-info-row">
                                                <span class="merge-info-label"><i class="fa-regular fa-clock"></i> Ngày tạo:</span>
                                                <span class="merge-info-val">
                                                    <fmt:formatDate value="${primaryCustomer.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </span>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="padding: 24px; text-align: center; color: var(--crm-slate-400); font-size: 13.5px;">
                                        Nhập ID để tải thông tin khách hàng chính
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- 2. MERGE DIRECTION ARROW -->
                    <div class="merge-arrow-col">
                        <i class="fa-solid fa-angles-left" title="Dữ liệu gộp từ phải sang trái"></i>
                    </div>

                    <!-- 3. SECONDARY CUSTOMER COLUMN -->
                    <div class="merge-box merge-box-secondary">
                        <div class="merge-box-header">
                            <h3 class="merge-box-title" style="color: var(--crm-rose-600);">
                                <i class="fa-solid fa-box-archive"></i> Khách hàng PHỤ
                            </h3>
                            <span class="merge-tag-absorb">Sẽ được gộp vào</span>
                        </div>
                        <div class="merge-box-body">
                            <div class="merge-field-group">
                                <label for="secondaryId">
                                    <i class="fa-solid fa-hashtag" style="color: var(--crm-rose-600);"></i> ID khách hàng phụ:
                                </label>
                                <input id="secondaryId" type="number" name="secondaryId" class="merge-input"
                                       value="<c:out value='${secondaryId}' />" required min="1" placeholder="Nhập ID khách hàng phụ...">
                            </div>

                            <c:choose>
                                <c:when test="${not empty secondaryCustomer}">
                                    <div class="merge-info-card">
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-building"></i> Tên khách hàng:</span>
                                            <span class="merge-info-val" style="color: var(--crm-rose-600); font-size: 15px;">
                                                <c:out value="${secondaryCustomer.customerName}" />
                                            </span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-phone"></i> Điện thoại:</span>
                                            <span class="merge-info-val"><c:out value="${not empty secondaryCustomer.phone ? secondaryCustomer.phone : '---'}" /></span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-envelope"></i> Email:</span>
                                            <span class="merge-info-val"><c:out value="${not empty secondaryCustomer.email ? secondaryCustomer.email : '---'}" /></span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-id-card"></i> Mã số thuế:</span>
                                            <span class="merge-info-val"><c:out value="${not empty secondaryCustomer.taxCode ? secondaryCustomer.taxCode : '---'}" /></span>
                                        </div>
                                        <div class="merge-info-row">
                                            <span class="merge-info-label"><i class="fa-solid fa-globe"></i> Website:</span>
                                            <span class="merge-info-val"><c:out value="${not empty secondaryCustomer.website ? secondaryCustomer.website : '---'}" /></span>
                                        </div>
                                        <c:if test="${not empty secondaryCustomer.createdAt}">
                                            <div class="merge-info-row">
                                                <span class="merge-info-label"><i class="fa-regular fa-clock"></i> Ngày tạo:</span>
                                                <span class="merge-info-val">
                                                    <fmt:formatDate value="${secondaryCustomer.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </span>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="padding: 24px; text-align: center; color: var(--crm-slate-400); font-size: 13.5px;">
                                        Nhập ID để tải thông tin khách hàng phụ
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </div>

                <!-- Action Confirmation Buttons -->
                <div style="display: flex; gap: 14px; align-items: center; justify-content: flex-end;">
                    <a href="${pageContext.request.contextPath}/customers/duplicates" class="btn-merge-cancel">
                        Hủy bỏ
                    </a>
                    <button type="submit" class="btn-merge-confirm" onclick="return confirm('Bạn có chắc chắn muốn thực hiện gộp? Toàn bộ cơ hội, người liên hệ và hoạt động của khách hàng phụ sẽ chuyển sang khách hàng chính!');">
                        <i class="fa-solid fa-code-merge"></i> Xác nhận Gộp khách hàng
                    </button>
                </div>

            </form>

        </div>
    </main>
</div>

<script>
(function () {
    const primaryInput = document.getElementById('primaryId');
    const secondaryInput = document.getElementById('secondaryId');
    const form = document.querySelector('form');

    function reloadComparison() {
        const primaryId = primaryInput.value.trim();
        const secondaryId = secondaryInput.value.trim();

        if (!primaryId || !secondaryId) {
            return;
        }

        if (primaryId === secondaryId) {
            alert('Khách hàng chính và khách hàng phụ không được trùng ID nhau!');
            return;
        }

        const contextPath = '${pageContext.request.contextPath}';
        window.location.href = contextPath + '/customers/merge?primaryId=' + encodeURIComponent(primaryId) + '&secondaryId=' + encodeURIComponent(secondaryId);
    }

    if (primaryInput) primaryInput.addEventListener('change', reloadComparison);
    if (secondaryInput) secondaryInput.addEventListener('change', reloadComparison);
    if (form) {
        form.addEventListener('submit', function(e) {
            const p = primaryInput.value.trim();
            const s = secondaryInput.value.trim();
            if (p && s && p === s) {
                e.preventDefault();
                alert('Không thể gộp một khách hàng vào chính nó!');
            }
        });
    }
})();
</script>
</body>
</html>