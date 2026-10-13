<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <title>Khách hàng trùng lặp | CRM Pro</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --crm-font: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --crm-navy-900: #0f172a;
            --crm-navy-800: #1e293b;
            --crm-blue-600: #2563eb;
            --crm-blue-50: #eff6ff;
            --crm-blue-100: #dbeafe;
            --crm-amber-500: #f59e0b;
            --crm-amber-50: #fffbeb;
            --crm-slate-50: #f8fafc;
            --crm-slate-100: #f1f5f9;
            --crm-slate-200: #e2e8f0;
            --crm-slate-400: #94a3b8;
            --crm-slate-500: #64748b;
            --crm-radius-lg: 16px;
            --crm-radius-md: 10px;
            --crm-card-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.04), 0 8px 10px -6px rgba(15, 23, 42, 0.03);
        }

        body {
            font-family: var(--crm-font) !important;
            background-color: #f4f6fa !important;
            color: var(--crm-navy-800);
        }

        .dup-container {
            max-width: 1360px;
            margin: 0 auto;
            padding: 24px 28px 48px;
        }

        .dup-hero {
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

        .dup-hero::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(180deg, #f59e0b 0%, #d97706 100%);
        }

        .dup-hero-info h1 {
            font-size: 22px;
            font-weight: 800;
            color: var(--crm-navy-900);
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .dup-hero-info p {
            margin: 0;
            font-size: 13.5px;
            color: var(--crm-slate-500);
        }

        .dup-hero-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .btn-dup {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 18px;
            border-radius: var(--crm-radius-md);
            font-size: 13.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            border: 1px solid transparent;
        }

        .btn-dup-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
        }

        .btn-dup-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.3);
        }

        .btn-dup-secondary {
            background: #ffffff;
            color: #475569 !important;
            border-color: var(--crm-slate-200);
        }

        .btn-dup-secondary:hover {
            background: var(--crm-slate-50);
            border-color: var(--crm-slate-400);
        }

        /* Card Table Box */
        .dup-table-card {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            box-shadow: var(--crm-card-shadow);
            overflow: hidden;
        }

        .dup-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .dup-table thead th {
            background: #f8fafc;
            padding: 14px 20px;
            text-align: left;
            font-size: 12.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: var(--crm-slate-500);
            border-bottom: 1px solid var(--crm-slate-200);
        }

        .dup-table tbody td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--crm-slate-200);
            vertical-align: middle;
            color: var(--crm-navy-800);
        }

        .dup-table tbody tr:hover {
            background: #fafbfc;
        }

        .dup-table tbody tr:last-child td {
            border-bottom: none;
        }

        .badge-reason {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            background: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
        }

        .client-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
        }

        .client-id {
            background: #eff6ff;
            color: #1d4ed8;
            font-size: 11.5px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 6px;
            border: 1px solid #bfdbfe;
        }

        .btn-merge-action {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            padding: 7px 14px;
            border-radius: 8px;
            font-size: 12.5px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            transition: all 0.2s ease;
            box-shadow: 0 2px 6px rgba(37, 99, 235, 0.2);
        }

        .btn-merge-action:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.3);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="dup-container">

            <!-- Hero Header -->
            <div class="dup-hero">
                <div class="dup-hero-info">
                    <h1>
                        <i class="fa-solid fa-copy" style="color: #f59e0b;"></i>
                        Phát hiện Khách hàng Trùng lặp
                    </h1>
                    <p>Hệ thống tự động rà soát phát hiện theo Mã số thuế (MST), Tên công ty tương tự và Website</p>
                </div>
                <div class="dup-hero-actions">
                    <a class="btn-dup btn-dup-secondary" href="${pageContext.request.contextPath}/customers">
                        <i class="fa-solid fa-arrow-left"></i> Danh sách khách hàng
                    </a>
                    <a class="btn-dup btn-dup-primary" href="${pageContext.request.contextPath}/customers/merge">
                        <i class="fa-solid fa-code-branch"></i> Gộp theo ID nhập tay
                    </a>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${param.error == '1'}">
                <div class="alert alert-danger" style="margin-bottom: 20px; border-radius: 12px; padding: 14px 20px;">
                    <i class="fa-solid fa-circle-exclamation" style="margin-right: 8px;"></i> Thao tác gộp khách hàng không thành công. Vui lòng thử lại.
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="margin-bottom: 20px; border-radius: 12px; padding: 14px 20px;">
                    <i class="fa-solid fa-circle-exclamation" style="margin-right: 8px;"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success" style="margin-bottom: 20px; border-radius: 12px; padding: 14px 20px;">
                    <i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> <c:out value="${successMessage}"/>
                </div>
            </c:if>

            <!-- Table Card -->
            <div class="dup-table-card">
                <table class="dup-table">
                    <thead>
                        <tr>
                            <th>Khách hàng A</th>
                            <th>Khách hàng B</th>
                            <th>Dấu hiệu trùng lặp</th>
                            <th style="text-align: center;">Hành động nghiệp vụ</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty duplicateCandidates}">
                                <c:forEach var="item" items="${duplicateCandidates}">
                                    <tr>
                                        <td>
                                            <div class="client-pill">
                                                <span class="client-id">#${not empty item.left ? item.left.customerId : item.customerId}</span>
                                                <strong style="color: var(--crm-navy-900);"><c:out value="${not empty item.left ? item.left.customerName : item.customerName}"/></strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="client-pill">
                                                <span class="client-id" style="background: #fef2f2; color: #dc2626; border-color: #fecaca;">#${not empty item.right ? item.right.customerId : item.customerId}</span>
                                                <strong style="color: var(--crm-navy-900);"><c:out value="${not empty item.right ? item.right.customerName : item.customerName}"/></strong>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge-reason">
                                                <i class="fa-solid fa-triangle-exclamation"></i>
                                                <c:out value="${not empty item.reason ? item.reason : (not empty item.phone ? 'Trùng số điện thoại' : 'Trùng tên công ty')}"/>
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <c:set var="lId" value="${not empty item.left ? item.left.customerId : item.customerId}" />
                                            <c:set var="rId" value="${not empty item.right ? item.right.customerId : item.customerId}" />
                                            <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${lId}&secondaryId=${rId}" class="btn-merge-action">
                                                <i class="fa-solid fa-code-compare"></i> So sánh & Gộp hồ sơ
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:when test="${not empty duplicates}">
                                <c:forEach var="cust" items="${duplicates}">
                                    <tr>
                                        <td>
                                            <div class="client-pill">
                                                <span class="client-id">#${cust.customerId}</span>
                                                <strong style="color: var(--crm-navy-900);"><c:out value="${cust.customerName}"/></strong>
                                            </div>
                                        </td>
                                        <td>
                                            <span style="color: var(--crm-slate-500); font-size: 13px;">
                                                <i class="fa-solid fa-phone" style="margin-right: 4px;"></i> ${cust.phone} • <c:out value="${cust.email}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge-reason">
                                                <i class="fa-solid fa-triangle-exclamation"></i> Trùng thông tin liên hệ
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${cust.customerId}" class="btn-merge-action">
                                                <i class="fa-solid fa-check"></i> Chọn làm Khách chính
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" style="text-align: center; padding: 48px 20px; color: var(--crm-slate-400);">
                                        <i class="fa-solid fa-circle-check" style="font-size: 36px; color: #10b981; margin-bottom: 12px; display: block;"></i>
                                        <strong style="font-size: 15px; color: var(--crm-navy-800);">Không có khách hàng trùng lặp nào được phát hiện.</strong>
                                        <div style="font-size: 13px; margin-top: 4px;">Dữ liệu khách hàng hiện tại sạch và chuẩn hóa.</div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div>
    </main>
</div>
</body>
</html>
