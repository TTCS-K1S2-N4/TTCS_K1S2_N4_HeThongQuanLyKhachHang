<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa: <c:out value="${not empty customer.customerName ? customer.customerName : 'Khách hàng'}"/> | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Customer Edit Experience
           ========================================================================== */
        :root {
            --crm-navy-900: #0f172a;
            --crm-navy-800: #1e293b;
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-accent-blue: #2563eb;
            --crm-accent-blue-light: #eff6ff;
            --crm-emerald: #10b981;
            --crm-emerald-light: #ecfdf5;
            --crm-amber: #f59e0b;
            --crm-amber-light: #fffbeb;
            --crm-slate: #64748b;
            --crm-slate-light: #f1f5f9;
            --crm-rose: #f43f5e;
            --crm-rose-light: #fff1f2;
            
            --crm-surface: #ffffff;
            --crm-bg-subtle: #f8fafc;
            --crm-border: #e2e8f0;
            --crm-border-focus: #3b82f6;
            --crm-text-heading: #0f172a;
            --crm-text-body: #334155;
            --crm-text-muted: #64748b;
            
            --crm-radius-sm: 8px;
            --crm-radius-md: 12px;
            --crm-radius-lg: 16px;
            
            --crm-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --crm-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.06), 0 2px 4px -2px rgba(15, 23, 42, 0.04);
            --crm-shadow-lg: 0 10px 25px -3px rgba(30, 58, 138, 0.08), 0 4px 6px -4px rgba(15, 23, 42, 0.03);
        }

        .customer-edit-container {
            max-width: 1220px;
            margin: 0 auto;
            padding-bottom: 50px;
        }

        /* Modern Breadcrumbs */
        .exec-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--crm-text-muted);
            margin-bottom: 16px;
        }
        .exec-breadcrumb a {
            color: var(--crm-text-muted);
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .exec-breadcrumb a:hover {
            color: var(--crm-primary);
        }
        .exec-breadcrumb .sep {
            color: #cbd5e1;
            font-size: 11px;
        }
        .exec-breadcrumb .current {
            color: var(--crm-accent-blue);
            font-weight: 600;
        }

        /* Top Hero Header Card */
        .exec-hero-header {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            padding: 24px 28px;
            box-shadow: var(--crm-shadow-sm);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            overflow: hidden;
        }

        .exec-hero-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(180deg, #1e3a8a 0%, #2563eb 100%);
        }

        .exec-hero-left {
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .exec-avatar-squircle {
            width: 58px;
            height: 58px;
            border-radius: 16px;
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 8px 18px rgba(30, 58, 138, 0.25);
            flex-shrink: 0;
        }

        .exec-hero-title h1 {
            font-size: 22px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 6px 0;
            letter-spacing: -0.01em;
            line-height: 1.25;
        }

        .exec-hero-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            font-size: 13px;
            color: var(--crm-text-muted);
        }

        .exec-badge-id {
            background: var(--crm-accent-blue-light);
            color: var(--crm-primary);
            font-weight: 700;
            font-size: 12px;
            padding: 3px 9px;
            border-radius: 6px;
            border: 1px solid #bfdbfe;
        }

        .exec-hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-exec-outline {
            background: #ffffff;
            color: #334155 !important;
            border: 1px solid var(--crm-border);
            padding: 9px 18px;
            border-radius: var(--crm-radius-sm);
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            box-shadow: var(--crm-shadow-sm);
            cursor: pointer;
        }
        .btn-exec-outline:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: var(--crm-primary) !important;
        }

        .btn-exec-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            border: none;
            padding: 10px 22px;
            border-radius: var(--crm-radius-sm);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 4px 14px rgba(30, 58, 138, 0.28);
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-exec-primary:hover {
            background: linear-gradient(135deg, #172554 0%, #1d4ed8 100%);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(30, 58, 138, 0.38);
        }

        /* Alert */
        .exec-alert-danger {
            background: var(--crm-rose-light);
            border: 1px solid #fecdd3;
            border-left: 4px solid var(--crm-rose);
            border-radius: var(--crm-radius-md);
            padding: 14px 18px;
            color: #9f1239;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 500;
        }

        /* Layout Grid: 8fr : 4fr */
        .exec-layout-grid {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 24px;
            align-items: start;
        }

        @media (max-width: 1024px) {
            .exec-layout-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Section Cards */
        .exec-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            box-shadow: var(--crm-shadow-sm);
            margin-bottom: 24px;
            overflow: hidden;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .exec-card:hover {
            border-color: #cbd5e1;
            box-shadow: var(--crm-shadow-md);
        }

        .exec-card-header {
            padding: 18px 24px;
            background: #ffffff;
            border-bottom: 1px solid var(--crm-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .exec-card-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 15.5px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0;
        }
        .exec-card-title i {
            color: var(--crm-accent-blue);
            font-size: 16px;
        }

        .exec-card-subtitle {
            font-size: 12px;
            color: var(--crm-text-muted);
        }

        .exec-card-body {
            padding: 24px;
        }

        /* Form Controls */
        .exec-field-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        @media (max-width: 640px) {
            .exec-field-grid-2 {
                grid-template-columns: 1fr;
            }
        }

        .exec-form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .exec-form-group.full {
            grid-column: 1 / -1;
        }

        .exec-label {
            font-size: 13px;
            font-weight: 600;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .exec-label .req {
            color: #e11d48;
            font-weight: 700;
        }

        .exec-input-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }

        .exec-input-icon {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 14px;
            pointer-events: none;
            transition: color 0.15s ease;
        }

        .exec-input {
            width: 100%;
            height: 42px;
            padding: 0 14px 0 38px;
            font-size: 14px;
            color: #0f172a;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: var(--crm-radius-sm);
            transition: all 0.2s ease;
            box-sizing: border-box;
            outline: none;
        }
        .exec-input:hover {
            border-color: #94a3b8;
        }
        .exec-input:focus {
            border-color: var(--crm-accent-blue);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.14);
            background: #ffffff;
        }
        .exec-input:focus + .exec-input-icon,
        .exec-input-wrap:focus-within .exec-input-icon {
            color: var(--crm-accent-blue);
        }

        .exec-input.no-icon {
            padding-left: 14px;
        }

        .exec-hint {
            font-size: 12px;
            color: var(--crm-text-muted);
            margin-top: 2px;
        }

        .exec-error {
            color: #e11d48;
            font-size: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 3px;
        }

        /* Preset Chips for Industry & Size */
        .exec-presets-row {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 6px;
        }
        .preset-chip {
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 11.5px;
            font-weight: 500;
            padding: 2px 8px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.15s ease;
            user-select: none;
        }
        .preset-chip:hover {
            background: #e2e8f0;
            color: #0f172a;
            border-color: #cbd5e1;
        }

        /* Status Visual Cards Selector */
        .status-cards-container {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .status-option-card {
            border: 1.5px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            padding: 12px 14px;
            background: #ffffff;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .status-option-card:hover {
            border-color: #cbd5e1;
            background: #fafafa;
            transform: translateX(2px);
        }

        .status-card-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .status-dot-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .status-card-text h5 {
            margin: 0;
            font-size: 13.5px;
            font-weight: 700;
            color: var(--crm-text-heading);
        }
        .status-card-text p {
            margin: 2px 0 0 0;
            font-size: 11.5px;
            color: var(--crm-text-muted);
        }

        .status-check-circle {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            border: 1.5px solid #cbd5e1;
            display: flex;
            align-items: center;
            justify-content: center;
            color: transparent;
            font-size: 10px;
            transition: all 0.2s ease;
        }

        /* Specific Status Active States */
        .status-option-card[data-status="POTENTIAL"].active {
            border-color: #3b82f6;
            background: #eff6ff;
            box-shadow: 0 0 0 1px #3b82f6;
        }
        .status-option-card[data-status="POTENTIAL"] .status-dot-icon { background: #dbeafe; color: #1d4ed8; }
        .status-option-card[data-status="POTENTIAL"].active .status-check-circle {
            background: #2563eb;
            border-color: #2563eb;
            color: #ffffff;
        }

        .status-option-card[data-status="DEALING"].active {
            border-color: #f59e0b;
            background: #fffbeb;
            box-shadow: 0 0 0 1px #f59e0b;
        }
        .status-option-card[data-status="DEALING"] .status-dot-icon { background: #fef3c7; color: #b45309; }
        .status-option-card[data-status="DEALING"].active .status-check-circle {
            background: #f59e0b;
            border-color: #f59e0b;
            color: #ffffff;
        }

        .status-option-card[data-status="CUSTOMER"].active {
            border-color: #10b981;
            background: #ecfdf5;
            box-shadow: 0 0 0 1px #10b981;
        }
        .status-option-card[data-status="CUSTOMER"] .status-dot-icon { background: #d1fae5; color: #047857; }
        .status-option-card[data-status="CUSTOMER"].active .status-check-circle {
            background: #10b981;
            border-color: #10b981;
            color: #ffffff;
        }

        .status-option-card[data-status="STOPPED"].active {
            border-color: #64748b;
            background: #f8fafc;
            box-shadow: 0 0 0 1px #64748b;
        }
        .status-option-card[data-status="STOPPED"] .status-dot-icon { background: #e2e8f0; color: #475569; }
        .status-option-card[data-status="STOPPED"].active .status-check-circle {
            background: #64748b;
            border-color: #64748b;
            color: #ffffff;
        }

        /* Owner ID Card */
        .owner-preview-box {
            background: #f8fafc;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            padding: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 10px;
        }
        .owner-avatar-icon {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: #dbeafe;
            color: #1e40af;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
        }
        .owner-info-text h6 {
            margin: 0;
            font-size: 13.5px;
            font-weight: 700;
            color: var(--crm-text-heading);
        }
        .owner-info-text p {
            margin: 2px 0 0 0;
            font-size: 12px;
            color: var(--crm-text-muted);
        }

        /* Audit Info Tip */
        .audit-info-tip {
            background: #f8fafc;
            border: 1px dashed var(--crm-border);
            border-radius: var(--crm-radius-md);
            padding: 14px 16px;
            font-size: 12.5px;
            color: var(--crm-text-muted);
            line-height: 1.45;
        }
        .audit-info-tip strong {
            color: var(--crm-text-heading);
        }

        /* Floating / Sticky Footer */
        .exec-sticky-footer {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            padding: 18px 26px;
            box-shadow: var(--crm-shadow-md);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-top: 8px;
        }

        .footer-status-indicator {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--crm-text-muted);
        }
        .pulse-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.2);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="content-container">
            <div class="customer-edit-container">
                
                <!-- Modern Breadcrumb -->
                <nav class="exec-breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> CRM</a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/customers/detail?id=${not empty customer.customerId ? customer.customerId : param.id}">
                        <c:out value="${not empty customer.customerName ? customer.customerName : param.customerName}"/>
                    </a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="current">Chỉnh sửa</span>
                </nav>

                <!-- Hero Header Card -->
                <div class="exec-hero-header">
                    <div class="exec-hero-left">
                        <div class="exec-avatar-squircle">
                            <i class="fa-solid fa-building"></i>
                        </div>
                        <div class="exec-hero-title">
                            <h1><c:out value="${not empty customer.customerName ? customer.customerName : (not empty param.customerName ? param.customerName : 'Chỉnh sửa khách hàng')}"/></h1>
                            <div class="exec-hero-meta">
                                <span class="exec-badge-id">ID: #${not empty customer.customerId ? customer.customerId : (not empty param.id ? param.id : param.customerId)}</span>
                                <span>•</span>
                                <span>Chế độ cập nhật hồ sơ khách hàng doanh nghiệp</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="exec-hero-actions">
                        <a href="${pageContext.request.contextPath}/customers/detail?id=${not empty customer.customerId ? customer.customerId : (not empty param.id ? param.id : param.customerId)}" class="btn-exec-outline">
                            <i class="fa-solid fa-xmark"></i> Hủy bỏ
                        </a>
                        <button type="button" class="btn-exec-primary" onclick="document.getElementById('customerEditForm').requestSubmit();">
                            <i class="fa-solid fa-check"></i> Lưu thay đổi
                        </button>
                    </div>
                </div>

                <!-- Error Alert -->
                <c:if test="${not empty message}">
                    <div class="exec-alert-danger">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 20px;"></i>
                        <div><c:out value="${message}"/></div>
                    </div>
                </c:if>

                <!-- Form Beginning -->
                <form action="${pageContext.request.contextPath}/customers/edit" method="post" id="customerEditForm">
                    
                    <!-- Hidden ID (Passed as both id and customerId to prevent any mismatch) -->
                    <input type="hidden" name="id" value="${not empty customer.customerId ? customer.customerId : (not empty param.id ? param.id : param.customerId)}">
                    <input type="hidden" name="customerId" value="${not empty customer.customerId ? customer.customerId : (not empty param.customerId ? param.customerId : param.id)}">
                    
                    <!-- Hidden Status Input (synced with visual status selector) -->
                    <c:set var="statusValue" value="${not empty param.status ? param.status : customer.status}" />
                    <input type="hidden" name="status" id="selectedStatusInput" value="${not empty statusValue ? statusValue : 'POTENTIAL'}">

                    <!-- Master Layout: 2 Columns -->
                    <div class="exec-layout-grid">
                        
                        <!-- Left Column: Core Fields -->
                        <div class="exec-col-main">
                            
                            <!-- Card 1: Legal & Contact Information -->
                            <div class="exec-card">
                                <div class="exec-card-header">
                                    <h3 class="exec-card-title">
                                        <i class="fa-solid fa-address-card"></i> Thông tin pháp lý &amp; Liên hệ
                                    </h3>
                                    <span class="exec-card-subtitle">Các trường thông tin giao dịch chính</span>
                                </div>
                                <div class="exec-card-body">
                                    <div class="exec-field-grid-2">
                                        
                                        <!-- Customer Name -->
                                        <div class="exec-form-group full">
                                            <label class="exec-label" for="customerName">
                                                Tên công ty / Doanh nghiệp <span class="req">*</span>
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="text" id="customerName" name="customerName" class="exec-input" 
                                                       value="<c:out value='${not empty param.customerName ? param.customerName : customer.customerName}'/>" 
                                                       required maxlength="200" placeholder="Nhập tên doanh nghiệp đầy đủ">
                                                <i class="fa-solid fa-building exec-input-icon"></i>
                                            </div>
                                            <c:if test="${not empty errors['customerName']}">
                                                <div class="exec-error">
                                                    <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${errors['customerName']}"/>
                                                </div>
                                            </c:if>
                                        </div>

                                        <!-- Tax Code -->
                                        <div class="exec-form-group">
                                            <label class="exec-label" for="taxCode">
                                                Mã số thuế doanh nghiệp
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="text" id="taxCode" name="taxCode" class="exec-input" 
                                                       value="<c:out value='${not empty param.taxCode ? param.taxCode : customer.taxCode}'/>" 
                                                       maxlength="50" placeholder="0101234567">
                                                <i class="fa-solid fa-receipt exec-input-icon"></i>
                                            </div>
                                            <c:if test="${not empty errors['taxCode']}">
                                                <div class="exec-error">
                                                    <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${errors['taxCode']}"/>
                                                </div>
                                            </c:if>
                                        </div>

                                        <!-- Phone -->
                                        <div class="exec-form-group">
                                            <label class="exec-label" for="phone">
                                                Số điện thoại liên lạc
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="tel" id="phone" name="phone" class="exec-input" 
                                                       value="<c:out value='${not empty param.phone ? param.phone : customer.phone}'/>" 
                                                       maxlength="30" placeholder="02473008888">
                                                <i class="fa-solid fa-phone exec-input-icon"></i>
                                            </div>
                                            <c:if test="${not empty errors['phone']}">
                                                <div class="exec-error">
                                                    <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${errors['phone']}"/>
                                                </div>
                                            </c:if>
                                        </div>

                                        <!-- Website -->
                                        <div class="exec-form-group full">
                                            <label class="exec-label" for="website">
                                                Website công ty
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="url" id="website" name="website" class="exec-input" 
                                                       value="<c:out value='${not empty param.website ? param.website : customer.website}'/>" 
                                                       placeholder="https://example.com">
                                                <i class="fa-solid fa-globe exec-input-icon"></i>
                                            </div>
                                            <c:if test="${not empty errors['website']}">
                                                <div class="exec-error">
                                                    <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${errors['website']}"/>
                                                </div>
                                            </c:if>
                                        </div>

                                        <!-- Address -->
                                        <div class="exec-form-group full">
                                            <label class="exec-label" for="address">
                                                Địa chỉ trụ sở chính / Chi nhánh
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="text" id="address" name="address" class="exec-input" 
                                                       value="<c:out value='${not empty param.address ? param.address : customer.address}'/>" 
                                                       placeholder="Tầng, số nhà, tòa nhà, quận/huyện, tỉnh/thành phố">
                                                <i class="fa-solid fa-location-dot exec-input-icon"></i>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>

                            <!-- Card 2: Business Profile & Classification -->
                            <div class="exec-card">
                                <div class="exec-card-header">
                                    <h3 class="exec-card-title">
                                        <i class="fa-solid fa-briefcase"></i> Hồ sơ ngành &amp; Quy mô doanh nghiệp
                                    </h3>
                                    <span class="exec-card-subtitle">Hỗ trợ phân nhóm và chiến lược tiếp cận</span>
                                </div>
                                <div class="exec-card-body">
                                    <div class="exec-field-grid-2">
                                        
                                        <!-- Industry -->
                                        <div class="exec-form-group">
                                            <label class="exec-label" for="industry">
                                                Ngành nghề kinh doanh
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="text" id="industry" name="industry" class="exec-input" 
                                                       value="<c:out value='${not empty param.industry ? param.industry : customer.industry}'/>" 
                                                       placeholder="Nhập hoặc bấm gợi ý bên dưới">
                                                <i class="fa-solid fa-layer-group exec-input-icon"></i>
                                            </div>
                                            <!-- Quick Presets -->
                                            <div class="exec-presets-row">
                                                <span class="preset-chip" onclick="applyPreset('industry', 'Công nghệ thông tin')">CNTT</span>
                                                <span class="preset-chip" onclick="applyPreset('industry', 'Sản xuất')">Sản xuất</span>
                                                <span class="preset-chip" onclick="applyPreset('industry', 'Bán lẻ & Thương mại')">Bán lẻ</span>
                                                <span class="preset-chip" onclick="applyPreset('industry', 'Tài chính - Ngân hàng')">Tài chính</span>
                                                <span class="preset-chip" onclick="applyPreset('industry', 'Bất động sản')">BĐS</span>
                                            </div>
                                        </div>

                                        <!-- Size -->
                                        <div class="exec-form-group">
                                            <label class="exec-label" for="size">
                                                Quy mô nhân sự
                                            </label>
                                            <div class="exec-input-wrap">
                                                <input type="text" id="size" name="size" class="exec-input" 
                                                       value="<c:out value='${not empty param.size ? param.size : customer.size}'/>" 
                                                       placeholder="Ví dụ: 50-100 nhân sự">
                                                <i class="fa-solid fa-users exec-input-icon"></i>
                                            </div>
                                            <!-- Quick Presets -->
                                            <div class="exec-presets-row">
                                                <span class="preset-chip" onclick="applyPreset('size', '1 - 10')">1-10</span>
                                                <span class="preset-chip" onclick="applyPreset('size', '10 - 50')">10-50</span>
                                                <span class="preset-chip" onclick="applyPreset('size', '50 - 100')">50-100</span>
                                                <span class="preset-chip" onclick="applyPreset('size', '100 - 500')">100-500</span>
                                                <span class="preset-chip" onclick="applyPreset('size', '> 500')">&gt; 500</span>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>

                            <!-- Card: Dynamic Custom Fields (Trường dữ liệu mở rộng) -->
                            <c:if test="${not empty customFieldDefinitions}">
                                <div class="exec-card" style="margin-top: 24px;">
                                    <div class="exec-card-header">
                                        <h3 class="exec-card-title">
                                            <i class="fa-solid fa-sliders"></i> Trường dữ liệu mở rộng
                                        </h3>
                                        <span class="exec-card-subtitle">Các trường tùy chỉnh bổ sung cho hồ sơ khách hàng</span>
                                    </div>
                                    <div class="exec-card-body">
                                        <div class="exec-field-grid-2">
                                            <c:forEach var="def" items="${customFieldDefinitions}">
                                                <c:set var="curVal" value="${customFieldValuesMap[def.fieldId]}" />
                                                <div class="exec-form-group">
                                                    <label class="exec-label" for="cf_${def.fieldId}">
                                                        <c:out value="${def.fieldLabel}"/>
                                                        <c:if test="${def.required}"><span class="req">*</span></c:if>
                                                    </label>
                                                    <div class="exec-input-wrap">
                                                        <c:choose>
                                                            <c:when test="${def.fieldType == 'SELECT'}">
                                                                <select id="cf_${def.fieldId}" name="customField_${def.fieldId}" class="exec-input no-icon" ${def.required ? 'required' : ''}>
                                                                    <option value="">-- Chọn ${def.fieldLabel} --</option>
                                                                    <c:forEach var="opt" items="${def.optionArray}">
                                                                        <option value="${opt.trim()}" ${opt.trim() eq curVal ? 'selected' : ''}><c:out value="${opt.trim()}"/></option>
                                                                    </c:forEach>
                                                                </select>
                                                            </c:when>
                                                            <c:when test="${def.fieldType == 'DATE'}">
                                                                <input type="date" id="cf_${def.fieldId}" name="customField_${def.fieldId}" class="exec-input no-icon" 
                                                                       value="<c:out value='${not empty curVal ? curVal : def.defaultValue}'/>" 
                                                                       ${def.required ? 'required' : ''}>
                                                            </c:when>
                                                            <c:when test="${def.fieldType == 'NUMBER'}">
                                                                <input type="number" step="any" id="cf_${def.fieldId}" name="customField_${def.fieldId}" class="exec-input no-icon" 
                                                                       value="<c:out value='${not empty curVal ? curVal : def.defaultValue}'/>" 
                                                                       placeholder="Nhập số" ${def.required ? 'required' : ''}>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <input type="text" id="cf_${def.fieldId}" name="customField_${def.fieldId}" class="exec-input no-icon" 
                                                                       value="<c:out value='${not empty curVal ? curVal : def.defaultValue}'/>" 
                                                                       placeholder="Nhập <c:out value='${def.fieldLabel}'/>" ${def.required ? 'required' : ''}>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                        </div>

                        <!-- Right Column: Status & Governance Sidebar -->
                        <div class="exec-col-side">
                            
                            <!-- Card 3: Interactive Visual Status Pipeline -->
                            <div class="exec-card">
                                <div class="exec-card-header">
                                    <h3 class="exec-card-title">
                                        <i class="fa-solid fa-signal"></i> Trạng thái quan hệ <span class="req" style="color: #e11d48;">*</span>
                                    </h3>
                                </div>
                                <div class="exec-card-body">
                                    <div class="status-cards-container">
                                        
                                        <!-- POTENTIAL -->
                                        <div class="status-option-card ${statusValue == 'POTENTIAL' ? 'active' : ''}" data-status="POTENTIAL" onclick="selectStatus('POTENTIAL')">
                                            <div class="status-card-left">
                                                <div class="status-dot-icon">
                                                    <i class="fa-solid fa-seedling"></i>
                                                </div>
                                                <div class="status-card-text">
                                                    <h5>Tiềm năng (Potential)</h5>
                                                    <p>Khách hàng mới tiếp cận, quan tâm</p>
                                                </div>
                                            </div>
                                            <div class="status-check-circle"><i class="fa-solid fa-check"></i></div>
                                        </div>

                                        <!-- DEALING -->
                                        <div class="status-option-card ${statusValue == 'DEALING' ? 'active' : ''}" data-status="DEALING" onclick="selectStatus('DEALING')">
                                            <div class="status-card-left">
                                                <div class="status-dot-icon">
                                                    <i class="fa-solid fa-handshake"></i>
                                                </div>
                                                <div class="status-card-text">
                                                    <h5>Đang giao dịch (Dealing)</h5>
                                                    <p>Đang đàm phán hợp đồng, báo giá</p>
                                                </div>
                                            </div>
                                            <div class="status-check-circle"><i class="fa-solid fa-check"></i></div>
                                        </div>

                                        <!-- CUSTOMER -->
                                        <div class="status-option-card ${statusValue == 'CUSTOMER' ? 'active' : ''}" data-status="CUSTOMER" onclick="selectStatus('CUSTOMER')">
                                            <div class="status-card-left">
                                                <div class="status-dot-icon">
                                                    <i class="fa-solid fa-circle-check"></i>
                                                </div>
                                                <div class="status-card-text">
                                                    <h5>Khách hàng (Customer)</h5>
                                                    <p>Đã ký hợp đồng &amp; hợp tác chính thức</p>
                                                </div>
                                            </div>
                                            <div class="status-check-circle"><i class="fa-solid fa-check"></i></div>
                                        </div>

                                        <!-- STOPPED -->
                                        <div class="status-option-card ${statusValue == 'STOPPED' ? 'active' : ''}" data-status="STOPPED" onclick="selectStatus('STOPPED')">
                                            <div class="status-card-left">
                                                <div class="status-dot-icon">
                                                    <i class="fa-solid fa-ban"></i>
                                                </div>
                                                <div class="status-card-text">
                                                    <h5>Ngừng hợp tác (Stopped)</h5>
                                                    <p>Tạm ngưng hoặc đã thanh lý</p>
                                                </div>
                                            </div>
                                            <div class="status-check-circle"><i class="fa-solid fa-check"></i></div>
                                        </div>

                                    </div>
                                    <c:if test="${not empty errors['status']}">
                                        <div class="exec-error" style="margin-top: 8px;">
                                            <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${errors['status']}"/>
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <!-- Card 4: Account Ownership -->
                            <div class="exec-card">
                                <div class="exec-card-header">
                                    <h3 class="exec-card-title">
                                        <i class="fa-solid fa-user-shield"></i> Phân quyền phụ trách <span class="req" style="color: #e11d48;">*</span>
                                    </h3>
                                </div>
                                <div class="exec-card-body">
                                    <div class="exec-form-group">
                                        <label class="exec-label" for="ownerId">
                                            Nhân viên kinh doanh phụ trách
                                        </label>
                                        <div class="exec-input-wrap">
                                            <select id="ownerId" name="ownerId" class="exec-input" required onchange="updateOwnerPreview(this)">
                                                <c:choose>
                                                    <c:when test="${not empty salesUsers}">
                                                        <c:forEach var="u" items="${salesUsers}">
                                                            <option value="${u.accountId}" 
                                                                    data-name="${u.fullName}" 
                                                                    data-team="${not empty u.teamName ? u.teamName : 'Phòng kinh doanh'}"
                                                                    ${((not empty param.ownerId and param.ownerId == u.accountId) or (empty param.ownerId and customer.ownerId == u.accountId)) ? 'selected' : ''}>
                                                                <c:out value="${u.fullName}"/> — ${not empty u.teamName ? u.teamName : 'Kinh doanh'}
                                                            </option>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <option value="${not empty customer.ownerId ? customer.ownerId : 1}" selected>
                                                            <c:out value="${not empty customer.ownerName ? customer.ownerName : 'Tài khoản hiện tại'}"/>
                                                        </option>
                                                    </c:otherwise>
                                                </c:choose>
                                            </select>
                                            <i class="fa-solid fa-user-tie exec-input-icon"></i>
                                        </div>
                                        <c:if test="${not empty errors['ownerId']}">
                                            <div class="exec-error">
                                                <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${errors['ownerId']}"/>
                                            </div>
                                        </c:if>

                                        <div class="owner-preview-box">
                                            <div class="owner-avatar-icon">
                                                <i class="fa-solid fa-user-check"></i>
                                            </div>
                                            <div class="owner-info-text">
                                                <h6 id="previewOwnerName">
                                                    <c:out value="${not empty customer.ownerName ? customer.ownerName : 'Tài khoản người phụ trách'}"/>
                                                </h6>
                                                <p id="previewOwnerTeam">Đang nắm quyền quản lý hồ sơ</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Card 5: Tips & Safety Callout -->
                            <div class="audit-info-tip">
                                <div style="font-weight: 700; color: #1e293b; margin-bottom: 6px; display: flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-shield-halved" style="color: #2563eb;"></i> An toàn dữ liệu CRM
                                </div>
                                Mọi thay đổi về thông tin công ty và trạng thái khách hàng sẽ được ghi nhận vào <strong>Nhật ký kiểm toán (Audit Log)</strong> để bảo đảm tính minh bạch.
                            </div>

                        </div>

                    </div>

                    <!-- Bottom Sticky Actions Bar -->
                    <div class="exec-sticky-footer">
                        <div class="footer-status-indicator">
                            <div class="pulse-dot"></div>
                            <span>Bạn đang chỉnh sửa hồ sơ của <strong><c:out value="${not empty customer.customerName ? customer.customerName : param.customerName}"/></strong></span>
                        </div>
                        <div style="display: flex; gap: 12px; align-items: center;">
                            <a href="${pageContext.request.contextPath}/customers/detail?id=${not empty customer.customerId ? customer.customerId : (not empty param.id ? param.id : param.customerId)}" class="btn-exec-outline">
                                <i class="fa-solid fa-xmark"></i> Hủy thay đổi
                            </a>
                            <button type="submit" class="btn-exec-primary" id="btnSubmitForm">
                                <i class="fa-solid fa-check"></i> Cập nhật hồ sơ khách hàng
                            </button>
                        </div>
                    </div>

                </form>

            </div>
        </div>
    </main>
</div>

<script>
function selectStatus(statusKey) {
    document.getElementById('selectedStatusInput').value = statusKey;
    document.querySelectorAll('.status-option-card').forEach(function(card) {
        if (card.getAttribute('data-status') === statusKey) {
            card.classList.add('active');
        } else {
            card.classList.remove('active');
        }
    });
}

function applyPreset(inputId, value) {
    const el = document.getElementById(inputId);
    if (el) {
        el.value = value;
        el.focus();
    }
}

function updateOwnerPreview(selectEl) {
    const selectedOption = selectEl.options[selectEl.selectedIndex];
    if (selectedOption) {
        const name = selectedOption.getAttribute('data-name');
        const team = selectedOption.getAttribute('data-team');
        if (name) document.getElementById('previewOwnerName').textContent = name;
        if (team) document.getElementById('previewOwnerTeam').textContent = team;
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const ownerSelect = document.getElementById('ownerId');
    if (ownerSelect) {
        updateOwnerPreview(ownerSelect);
    }
});

document.getElementById('customerEditForm').addEventListener('submit', function() {
    const btn = document.getElementById('btnSubmitForm');
    if (btn) {
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
        btn.disabled = true;
    }
});
</script>
</body>
</html>
