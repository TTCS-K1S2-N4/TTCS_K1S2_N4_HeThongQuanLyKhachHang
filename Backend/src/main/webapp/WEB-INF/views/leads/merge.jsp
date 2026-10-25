<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <title>So sánh & Gộp Lead | CRM Pro</title>
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
            --crm-radius-lg: 16px;
            --crm-radius-md: 12px;
            --crm-radius-sm: 8px;
            --crm-card-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.05);
        }

        body {
            font-family: var(--crm-font) !important;
            background-color: #f4f6fa !important;
            color: var(--crm-navy-800);
        }

        .merge-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px 28px 48px;
        }

        .merge-hero {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            padding: 22px 28px;
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
            gap: 10px;
        }

        .merge-hero-info p {
            margin: 0;
            font-size: 13.5px;
            color: var(--crm-slate-500);
        }

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
            padding: 18px 24px;
            background: #ffffff;
            border-bottom: 1px solid var(--crm-slate-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .merge-box-title {
            font-size: 15.5px;
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
            padding: 20px 24px;
            flex-grow: 1;
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
        }

        .merge-info-label {
            color: var(--crm-slate-500);
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .merge-info-val {
            font-weight: 600;
            color: var(--crm-navy-800);
            text-align: right;
        }

        /* Field Selection Table */
        .selection-card {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            box-shadow: var(--crm-card-shadow);
            padding: 24px;
            margin-bottom: 24px;
        }

        .selection-title {
            font-size: 16px;
            font-weight: 800;
            color: var(--crm-navy-900);
            margin: 0 0 16px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .field-table {
            width: 100%;
            border-collapse: collapse;
        }

        .field-table th {
            text-align: left;
            padding: 10px 14px;
            background: var(--crm-slate-50);
            color: var(--crm-navy-700);
            font-size: 12.5px;
            font-weight: 700;
            border-bottom: 1px solid var(--crm-slate-200);
        }

        .field-table td {
            padding: 12px 14px;
            border-bottom: 1px solid var(--crm-slate-200);
            font-size: 13.5px;
        }

        .field-table tr:last-child td {
            border-bottom: none;
        }

        .radio-option {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            font-weight: 600;
        }

        /* Assurance Banner */
        .assurance-banner {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: var(--crm-radius-md);
            padding: 16px 20px;
            margin-bottom: 24px;
            font-size: 13px;
            color: #1e40af;
            line-height: 1.6;
        }

        .assurance-item {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
        }

        .assurance-item:last-child {
            margin-bottom: 0;
        }

        .merge-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--crm-slate-200);
            border-radius: var(--crm-radius-md);
            font-size: 13.5px;
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

        .btn-merge-cancel {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #ffffff;
            color: var(--crm-navy-700);
            border: 1px solid var(--crm-slate-200);
            border-radius: var(--crm-radius-md);
            font-weight: 700;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-merge-cancel:hover {
            background: var(--crm-slate-100);
            color: var(--crm-navy-900);
        }

        .btn-merge-confirm {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 24px;
            background: linear-gradient(135deg, var(--crm-blue-600) 0%, #1d4ed8 100%);
            color: #ffffff;
            border: none;
            border-radius: var(--crm-radius-md);
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
            transition: all 0.2s;
        }

        .btn-merge-confirm:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.35);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
    <main class="main-content">
        <div class="merge-container">

            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px;">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/leads">Quản lý Lead</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/leads/duplicates?leadId=${primaryId}">Phát hiện trùng lặp</a>
                <span>/</span>
                <span class="breadcrumb-current">So sánh & Gộp Lead</span>
            </nav>

            <!-- Hero Banner -->
            <div class="merge-hero">
                <div class="merge-hero-info">
                    <h1><i class="fa-solid fa-code-merge" style="color: var(--crm-blue-600);"></i> So sánh & Gộp Lead Trùng</h1>
                    <p>Hợp nhất thông tin liên hệ, tự động bảo toàn toàn bộ lịch sử hoạt động và đánh dấu lưu trữ an toàn.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/leads/duplicates?leadId=${primaryId}" class="btn-merge-cancel">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="margin-bottom: 20px; padding: 14px 18px; background: #fee2e2; color: #dc2626; border-radius: 8px; border: 1px solid #fecdd3; font-weight: 600;">
                    <i class="fa-solid fa-triangle-exclamation"></i> <c:out value="${error}"/>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/leads/merge" method="post" id="mergeForm">
                <input type="hidden" name="primaryLeadId" value="${primaryId}" />
                <input type="hidden" name="duplicateLeadId" value="${duplicateId}" />

                <!-- 1. Comparison Grid -->
                <div class="merge-compare-grid">

                    <!-- PRIMARY LEAD CARD -->
                    <div class="merge-box merge-box-primary">
                        <div class="merge-box-header">
                            <h3 class="merge-box-title" style="color: var(--crm-blue-700);">
                                <i class="fa-solid fa-star"></i> Lead CHÍNH #${primaryId}
                            </h3>
                            <span class="merge-tag-keep"><i class="fa-solid fa-check"></i> Được giữ lại</span>
                        </div>
                        <div class="merge-box-body">
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-user"></i> Họ tên:</span>
                                <span class="merge-info-val" style="color: var(--crm-blue-700); font-size: 14.5px;">
                                    <c:out value="${not empty primaryLead.fullName ? primaryLead.fullName : primaryLead.name}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-building"></i> Công ty:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty primaryLead.companyName ? primaryLead.companyName : (not empty primaryLead.company ? primaryLead.company : '---')}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-envelope"></i> Email:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty primaryLead.email ? primaryLead.email : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-phone"></i> SĐT:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty primaryLead.phone ? primaryLead.phone : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-bullhorn"></i> Chiến dịch:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty primaryLead.campaignName ? primaryLead.campaignName : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-user-tie"></i> Phụ trách:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty primaryLead.ownerName ? primaryLead.ownerName : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-regular fa-clock"></i> Ngày tạo:</span>
                                <span class="merge-info-val">
                                    <fmt:formatDate value="${primaryLead.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- ARROW COLUMN -->
                    <div class="merge-arrow-col">
                        <i class="fa-solid fa-angles-left" title="Dữ liệu gộp từ phải sang trái"></i>
                    </div>

                    <!-- DUPLICATE LEAD CARD -->
                    <div class="merge-box merge-box-secondary">
                        <div class="merge-box-header">
                            <h3 class="merge-box-title" style="color: var(--crm-rose-600);">
                                <i class="fa-solid fa-clone"></i> Lead PHỤ #${duplicateId}
                            </h3>
                            <span class="merge-tag-absorb"><i class="fa-solid fa-box-archive"></i> Sẽ gộp vào</span>
                        </div>
                        <div class="merge-box-body">
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-user"></i> Họ tên:</span>
                                <span class="merge-info-val" style="color: var(--crm-rose-600); font-size: 14.5px;">
                                    <c:out value="${not empty duplicateLead.fullName ? duplicateLead.fullName : duplicateLead.name}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-building"></i> Công ty:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty duplicateLead.companyName ? duplicateLead.companyName : (not empty duplicateLead.company ? duplicateLead.company : '---')}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-envelope"></i> Email:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty duplicateLead.email ? duplicateLead.email : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-phone"></i> SĐT:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty duplicateLead.phone ? duplicateLead.phone : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-bullhorn"></i> Chiến dịch:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty duplicateLead.campaignName ? duplicateLead.campaignName : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-solid fa-user-tie"></i> Phụ trách:</span>
                                <span class="merge-info-val">
                                    <c:out value="${not empty duplicateLead.ownerName ? duplicateLead.ownerName : '---'}" />
                                </span>
                            </div>
                            <div class="merge-info-row">
                                <span class="merge-info-label"><i class="fa-regular fa-clock"></i> Ngày tạo:</span>
                                <span class="merge-info-val">
                                    <fmt:formatDate value="${duplicateLead.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- 2. Field Retention Selection -->
                <div class="selection-card">
                    <h3 class="selection-title">
                        <i class="fa-solid fa-sliders" style="color: var(--crm-blue-600);"></i> Lựa chọn thông tin giữ lại sau khi gộp
                    </h3>
                    <p style="font-size: 13px; color: var(--crm-slate-500); margin: -8px 0 16px 0;">
                        Bạn có thể chọn giữ giá trị từ Lead chính hoặc Lead phụ cho từng trường dữ liệu.
                    </p>

                    <table class="field-table">
                        <thead>
                            <tr>
                                <th style="width: 25%;">Trường dữ liệu</th>
                                <th style="width: 37.5%;">Giá trị từ Lead chính (#${primaryId})</th>
                                <th style="width: 37.5%;">Giá trị từ Lead phụ (#${duplicateId})</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Họ tên -->
                            <tr>
                                <td><strong><i class="fa-solid fa-user"></i> Họ và tên</strong></td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedFullName" value="<c:out value='${not empty primaryLead.fullName ? primaryLead.fullName : primaryLead.name}' />" checked>
                                        <span><c:out value="${not empty primaryLead.fullName ? primaryLead.fullName : primaryLead.name}" /></span>
                                    </label>
                                </td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedFullName" value="<c:out value='${not empty duplicateLead.fullName ? duplicateLead.fullName : duplicateLead.name}' />">
                                        <span><c:out value="${not empty duplicateLead.fullName ? duplicateLead.fullName : duplicateLead.name}" /></span>
                                    </label>
                                </td>
                            </tr>

                            <!-- Công ty -->
                            <tr>
                                <td><strong><i class="fa-solid fa-building"></i> Tên công ty</strong></td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedCompany" value="<c:out value='${not empty primaryLead.companyName ? primaryLead.companyName : primaryLead.company}' />" checked>
                                        <span><c:out value="${not empty primaryLead.companyName ? primaryLead.companyName : (not empty primaryLead.company ? primaryLead.company : '---')}" /></span>
                                    </label>
                                </td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedCompany" value="<c:out value='${not empty duplicateLead.companyName ? duplicateLead.companyName : duplicateLead.company}' />">
                                        <span><c:out value="${not empty duplicateLead.companyName ? duplicateLead.companyName : (not empty duplicateLead.company ? duplicateLead.company : '---')}" /></span>
                                    </label>
                                </td>
                            </tr>

                            <!-- Email -->
                            <tr>
                                <td><strong><i class="fa-solid fa-envelope"></i> Email</strong></td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedEmail" value="<c:out value='${primaryLead.email}' />" checked>
                                        <span><c:out value="${not empty primaryLead.email ? primaryLead.email : '---'}" /></span>
                                    </label>
                                </td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedEmail" value="<c:out value='${duplicateLead.email}' />">
                                        <span><c:out value="${not empty duplicateLead.email ? duplicateLead.email : '---'}" /></span>
                                    </label>
                                </td>
                            </tr>

                            <!-- SĐT -->
                            <tr>
                                <td><strong><i class="fa-solid fa-phone"></i> Số điện thoại</strong></td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedPhone" value="<c:out value='${primaryLead.phone}' />" checked>
                                        <span><c:out value="${not empty primaryLead.phone ? primaryLead.phone : '---'}" /></span>
                                    </label>
                                </td>
                                <td>
                                    <label class="radio-option">
                                        <input type="radio" name="retainedPhone" value="<c:out value='${duplicateLead.phone}' />">
                                        <span><c:out value="${not empty duplicateLead.phone ? duplicateLead.phone : '---'}" /></span>
                                    </label>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- Ghi chú kiểm toán -->
                    <div style="margin-top: 20px;">
                        <label for="mergeNote" style="font-size: 13px; font-weight: 700; color: var(--crm-navy-700); display: block; margin-bottom: 6px;">
                            <i class="fa-solid fa-note-sticky"></i> Lý do hoặc Ghi chú gộp Lead:
                        </label>
                        <textarea id="mergeNote" name="note" class="merge-input" rows="2" placeholder="Nhập lý do thực hiện gộp hai bản ghi Lead này (được lưu vào lịch sử kiểm toán)..."></textarea>
                    </div>
                </div>

                <!-- 3. Assurance & Integrity Notice -->
                <div class="assurance-banner">
                    <div class="assurance-item">
                        <i class="fa-solid fa-shield-halved" style="color: var(--crm-blue-600); font-size: 16px;"></i>
                        <strong>Cam kết bảo toàn toàn vẹn dữ liệu và lịch sử:</strong>
                    </div>
                    <div class="assurance-item">
                        <i class="fa-solid fa-check" style="color: var(--crm-emerald-600);"></i>
                        Toàn bộ <strong>lịch sử chăm sóc & hoạt động</strong> (cuộc gọi, họp, email, hoạt động) của Lead #${duplicateId} sẽ tự động chuyển sang Lead #${primaryId}.
                    </div>
                    <div class="assurance-item">
                        <i class="fa-solid fa-check" style="color: var(--crm-emerald-600);"></i>
                        Toàn bộ <strong>ghi chú (Notes)</strong> của Lead phụ sẽ tự động được kết hợp đầy đủ vào Lead chính mà không bị mất.
                    </div>
                    <div class="assurance-item">
                        <i class="fa-solid fa-check" style="color: var(--crm-emerald-600);"></i>
                        Bản ghi Lead phụ #${duplicateId} được chuyển sang trạng thái <strong>MERGED</strong> để lưu trữ an toàn, truy vết kiểm toán và không bị xóa khỏi cơ sở dữ liệu.
                    </div>
                </div>

                <!-- 4. Action Buttons -->
                <div style="display: flex; gap: 14px; align-items: center; justify-content: flex-end;">
                    <a href="${pageContext.request.contextPath}/leads/duplicates?leadId=${primaryId}" class="btn-merge-cancel">
                        Hủy bỏ
                    </a>
                    <button type="submit" class="btn-merge-confirm" onclick="return confirm('Xác nhận GỘP Lead #${duplicateId} vào Lead chính #${primaryId}?\nThao tác này sẽ hợp nhất thông tin và chuyển giao toàn bộ hoạt động.');">
                        <i class="fa-solid fa-compress-alt"></i> Xác nhận Gộp Lead
                    </button>
                </div>

            </form>

        </div>
    </main>
</div>
</body>
</html>
