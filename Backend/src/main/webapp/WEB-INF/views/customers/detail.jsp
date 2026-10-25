<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${not empty customer.customerName ? customer.customerName : 'Chi tiết khách hàng'}"/> | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Customer Detail Experience
           ========================================================================== */
        :root {
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-accent-blue: #2563eb;
            --crm-accent-blue-light: #eff6ff;
            --crm-surface: #ffffff;
            --crm-border: #e2e8f0;
            --crm-text-heading: #0f172a;
            --crm-text-body: #334155;
            --crm-text-muted: #64748b;
            --crm-radius-sm: 8px;
            --crm-radius-md: 12px;
            --crm-radius-lg: 16px;
            --crm-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --crm-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.06), 0 2px 4px -2px rgba(15, 23, 42, 0.04);
            --crm-shadow-lg: 0 10px 25px -3px rgba(30, 58, 138, 0.08);
        }

        .customer-detail-container {
            max-width: 1240px;
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

        /* Hero Header Card */
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
            gap: 20px;
        }

        .exec-avatar-squircle {
            width: 62px;
            height: 62px;
            border-radius: 16px;
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            box-shadow: 0 8px 18px rgba(30, 58, 138, 0.25);
            flex-shrink: 0;
        }

        .exec-hero-title h1 {
            font-size: 23px;
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
        }

        .exec-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12.5px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 999px;
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
        }
        .exec-pill-id {
            background: #eff6ff;
            color: #1e40af;
            border-color: #bfdbfe;
        }

        /* Status Pills */
        .status-badge-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12.5px;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 999px;
        }
        .status-potential { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .status-dealing { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .status-customer { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        .status-stopped { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }

        .exec-hero-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn-exec-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 18px;
            border-radius: var(--crm-radius-sm);
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn-action-back {
            background: #ffffff;
            color: #334155 !important;
            border: 1px solid var(--crm-border);
            box-shadow: var(--crm-shadow-sm);
        }
        .btn-action-back:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: var(--crm-primary) !important;
        }

        .btn-action-edit {
            background: #ffffff;
            color: #1e3a8a !important;
            border: 1px solid #bfdbfe;
            box-shadow: var(--crm-shadow-sm);
        }
        .btn-action-edit:hover {
            background: #eff6ff;
            border-color: #93c5fd;
        }

        .btn-action-360 {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            border: none;
            box-shadow: 0 4px 14px rgba(30, 58, 138, 0.28);
        }
        .btn-action-360:hover {
            background: linear-gradient(135deg, #172554 0%, #1d4ed8 100%);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(30, 58, 138, 0.38);
        }

        /* Risk Banner */
        .exec-risk-banner {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            border-left: 4px solid #f43f5e;
            border-radius: var(--crm-radius-md);
            padding: 16px 20px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 16px;
            color: #9f1239;
        }

        /* Content Grid */
        .exec-layout-grid {
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 24px;
            align-items: start;
        }
        @media (max-width: 1024px) {
            .exec-layout-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Cards */
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

        .exec-card-body {
            padding: 24px;
        }

        /* Key-Value Grid */
        .prop-grid-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        @media (max-width: 640px) {
            .prop-grid-2col {
                grid-template-columns: 1fr;
            }
        }

        .prop-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .prop-item.full {
            grid-column: 1 / -1;
        }

        .prop-label {
            font-size: 11.5px;
            font-weight: 700;
            color: var(--crm-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .prop-value {
            font-size: 15px;
            font-weight: 500;
            color: var(--crm-text-heading);
            word-break: break-word;
            margin: 0;
        }

        .prop-value.strong {
            font-weight: 600;
        }

        .prop-value a {
            color: var(--crm-accent-blue);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: color 0.15s ease;
        }
        .prop-value a:hover {
            color: #1d4ed8;
            text-decoration: underline;
        }

        .val-empty {
            color: #94a3b8;
            font-style: italic;
            font-weight: 400;
            font-size: 13.5px;
        }

        /* Account Owner Box */
        .owner-card-chip {
            display: flex;
            align-items: center;
            gap: 14px;
            background: #f8fafc;
            border: 1px solid var(--crm-border);
            padding: 14px 16px;
            border-radius: var(--crm-radius-md);
        }
        .owner-avatar-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: #dbeafe;
            color: #1e40af;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .owner-info h5 {
            margin: 0;
            font-size: 14.5px;
            font-weight: 700;
            color: var(--crm-text-heading);
        }
        .owner-info p {
            margin: 2px 0 0 0;
            font-size: 12px;
            color: var(--crm-text-muted);
        }

        /* Custom Fields Cards */
        .custom-fields-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 14px;
        }
        .cf-item-card {
            background: #f8fafc;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-sm);
            padding: 12px 14px;
        }
        .cf-item-card .cf-name {
            font-size: 11px;
            font-weight: 700;
            color: var(--crm-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 4px;
        }
        .cf-item-card .cf-val {
            font-size: 14px;
            font-weight: 600;
            color: var(--crm-text-heading);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="content-container">
            <div class="customer-detail-container">
                
                <!-- Modern Breadcrumb -->
                <nav class="exec-breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> CRM</a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="current">Hồ sơ chi tiết</span>
                </nav>

                <c:choose>
                    <c:when test="${not empty customer}">
                        
                        <!-- Hero Identification Header -->
                        <div class="exec-hero-header">
                            <div class="exec-hero-left">
                                <div class="exec-avatar-squircle">
                                    <i class="fa-solid fa-building"></i>
                                </div>
                                <div class="exec-hero-title">
                                    <h1><c:out value="${customer.customerName}"/></h1>
                                    <div class="exec-hero-meta">
                                        <span class="exec-pill exec-pill-id">
                                            <i class="fa-solid fa-hashtag"></i> ${customer.customerId}
                                        </span>
                                        
                                        <!-- Status Badge -->
                                        <c:choose>
                                            <c:when test="${customer.status == 'POTENTIAL'}">
                                                <span class="status-badge-pill status-potential">
                                                    <i class="fa-solid fa-seedling"></i> Tiềm năng
                                                </span>
                                            </c:when>
                                            <c:when test="${customer.status == 'DEALING'}">
                                                <span class="status-badge-pill status-dealing">
                                                    <i class="fa-solid fa-handshake"></i> Đang giao dịch
                                                </span>
                                            </c:when>
                                            <c:when test="${customer.status == 'CUSTOMER'}">
                                                <span class="status-badge-pill status-customer">
                                                    <i class="fa-solid fa-circle-check"></i> Khách hàng chính thức
                                                </span>
                                            </c:when>
                                            <c:when test="${customer.status == 'STOPPED'}">
                                                <span class="status-badge-pill status-stopped">
                                                    <i class="fa-solid fa-ban"></i> Ngừng hợp tác
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge-pill">
                                                    <c:out value="${customer.status}"/>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>

                                        <c:if test="${not empty customer.industry}">
                                            <span class="exec-pill">
                                                <i class="fa-solid fa-layer-group"></i> <c:out value="${customer.industry}"/>
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <div class="exec-hero-actions">
                                <a href="${pageContext.request.contextPath}/customers" class="btn-exec-action btn-action-back">
                                    <i class="fa-solid fa-arrow-left"></i> Quay lại
                                </a>
                                <a href="${pageContext.request.contextPath}/customers/edit?id=${customer.customerId}" class="btn-exec-action btn-action-edit">
                                    <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa
                                </a>
                                <a href="${pageContext.request.contextPath}/customers/360?id=${customer.customerId}" class="btn-exec-action btn-action-360">
                                    <i class="fa-solid fa-chart-pie"></i> Xem 360°
                                </a>
                            </div>
                        </div>

                        <!-- Risk Alert Banner if marked -->
                        <c:if test="${customer.riskFlag}">
                            <div class="exec-risk-banner">
                                <i class="fa-solid fa-triangle-exclamation" style="font-size: 26px;"></i>
                                <div>
                                    <h4 style="margin: 0 0 2px 0; font-size: 14.5px; font-weight: 700;">Cảnh báo rủi ro khách hàng</h4>
                                    <p style="margin: 0; font-size: 13.5px;"><c:out value="${not empty customer.riskReason ? customer.riskReason : 'Khách hàng có cảnh báo rủi ro trong giao dịch.'}"/></p>
                                </div>
                            </div>
                        </c:if>

                        <!-- Layout Grid: 1fr : 380px -->
                        <div class="exec-layout-grid">
                            
                            <!-- Left Column: Core Legal & Contact Data -->
                            <div class="exec-col-main">
                                
                                <div class="exec-card">
                                    <div class="exec-card-header">
                                        <h3 class="exec-card-title">
                                            <i class="fa-solid fa-address-book"></i> Thông tin liên hệ &amp; Pháp lý
                                        </h3>
                                    </div>
                                    <div class="exec-card-body">
                                        <div class="prop-grid-2col">
                                            
                                            <!-- Phone -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-phone"></i> Số điện thoại</span>
                                                <div class="prop-value strong">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.phone}">
                                                            <a href="tel:${customer.phone}">
                                                                <c:out value="${customer.phone}"/>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Email -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-envelope"></i> Hòm thư điện tử</span>
                                                <div class="prop-value">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.email}">
                                                            <a href="mailto:${customer.email}">
                                                                <c:out value="${customer.email}"/>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Tax Code -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-receipt"></i> Mã số thuế</span>
                                                <div class="prop-value">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.taxCode}">
                                                            <code style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-weight: 600;"><c:out value="${customer.taxCode}"/></code>
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Website -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-globe"></i> Trang web (Website)</span>
                                                <div class="prop-value">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.website}">
                                                            <a href="${customer.website}" target="_blank" rel="noopener noreferrer">
                                                                <c:out value="${customer.website}"/> <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 11px;"></i>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Address -->
                                            <div class="prop-item full">
                                                <span class="prop-label"><i class="fa-solid fa-location-dot"></i> Địa chỉ trụ sở chính</span>
                                                <div class="prop-value">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.address}">
                                                            <c:out value="${customer.address}"/>
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Region -->
                                            <c:if test="${not empty customer.region}">
                                                <div class="prop-item">
                                                    <span class="prop-label"><i class="fa-solid fa-map-location-dot"></i> Vùng / Khu vực</span>
                                                    <div class="prop-value">
                                                        <c:out value="${customer.region}"/>
                                                    </div>
                                                </div>
                                            </c:if>

                                        </div>
                                    </div>
                                </div>

                                <!-- Custom Fields (if any) -->
                                <c:if test="${not empty customFieldValues}">
                                    <div class="exec-card">
                                        <div class="exec-card-header">
                                            <h3 class="exec-card-title">
                                                <i class="fa-solid fa-sliders"></i> Thuộc tính mở rộng (Custom Fields)
                                            </h3>
                                        </div>
                                        <div class="exec-card-body">
                                            <div class="custom-fields-cards">
                                                <c:forEach var="cf" items="${customFieldValues}">
                                                    <div class="cf-item-card">
                                                        <div class="cf-name"><c:out value="${cf.fieldLabel}"/></div>
                                                        <div class="cf-val">
                                                            <c:choose>
                                                                <c:when test="${not empty cf.fieldValue}">
                                                                    <c:out value="${cf.fieldValue}"/>
                                                                </c:when>
                                                                <c:otherwise><span class="val-empty">---</span></c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                            </div>

                            <!-- Right Column: Governance, Owner & Timestamps -->
                            <div class="exec-col-side">
                                
                                <!-- Card: Business Profile -->
                                <div class="exec-card">
                                    <div class="exec-card-header">
                                        <h3 class="exec-card-title">
                                            <i class="fa-solid fa-briefcase"></i> Phân loại &amp; Quản trị
                                        </h3>
                                    </div>
                                    <div class="exec-card-body">
                                        <div style="display: flex; flex-direction: column; gap: 18px;">
                                            
                                            <!-- Industry -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-industry"></i> Ngành nghề</span>
                                                <div class="prop-value">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.industry}">
                                                            <span style="font-weight: 600;"><c:out value="${customer.industry}"/></span>
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Size -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-users"></i> Quy mô nhân sự</span>
                                                <div class="prop-value">
                                                    <c:choose>
                                                        <c:when test="${not empty customer.size}">
                                                            <c:out value="${customer.size}"/> nhân sự
                                                        </c:when>
                                                        <c:otherwise><span class="val-empty">Chưa cập nhật</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Owner Box -->
                                            <div class="prop-item">
                                                <span class="prop-label"><i class="fa-solid fa-user-shield"></i> Nhân sự phụ trách</span>
                                                <div class="owner-card-chip" style="margin-top: 4px;">
                                                    <div class="owner-avatar-circle">
                                                        <i class="fa-solid fa-user-tie"></i>
                                                    </div>
                                                    <div class="owner-info">
                                                        <h5>
                                                            <c:out value="${not empty customer.ownerName ? customer.ownerName : customer.ownerId}"/>
                                                        </h5>
                                                        <p>Tài khoản quản lý hồ sơ</p>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Created At -->
                                            <c:if test="${not empty customer.createdAt}">
                                                <div class="prop-item" style="border-top: 1px solid var(--crm-border); padding-top: 14px;">
                                                    <span class="prop-label"><i class="fa-regular fa-calendar-plus"></i> Thời gian tạo hồ sơ</span>
                                                    <div class="prop-value" style="font-size: 13.5px; color: #475569;">
                                                        <fmt:formatDate value="${customer.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <!-- Updated At -->
                                            <c:if test="${not empty customer.updatedAt}">
                                                <div class="prop-item">
                                                    <span class="prop-label"><i class="fa-regular fa-clock"></i> Cập nhật gần nhất</span>
                                                    <div class="prop-value" style="font-size: 13.5px; color: #475569;">
                                                        <fmt:formatDate value="${customer.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </div>
                                                </div>
                                            </c:if>

                                        </div>
                                    </div>
                                </div>

                            </div>

                        </div>

                    </c:when>
                    <c:otherwise>
                        <div class="exec-card" style="text-align: center; padding: 48px 24px;">
                            <div style="font-size: 48px; color: #cbd5e1; margin-bottom: 16px;">
                                <i class="fa-solid fa-user-slash"></i>
                            </div>
                            <h3 style="color: #0f172a; margin: 0 0 8px 0;">Không tìm thấy khách hàng</h3>
                            <p style="color: #64748b; margin: 0 0 20px 0;">Khách hàng không tồn tại hoặc bạn không có quyền xem thông tin này.</p>
                            <a href="${pageContext.request.contextPath}/customers" class="btn-exec-action btn-action-360">
                                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách khách hàng
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </div>
    </main>
</div>
</body>
</html>
