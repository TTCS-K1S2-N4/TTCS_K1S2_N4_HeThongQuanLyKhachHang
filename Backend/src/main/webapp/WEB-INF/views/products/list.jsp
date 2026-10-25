<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Bảng giá Niêm yết & Danh mục Sản phẩm | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/products.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Product & Standard Pricing Management
           ========================================================================== */
        :root {
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-primary-light: #eff6ff;
            --crm-primary-border: #bfdbfe;
            --crm-accent: #d97706;
            --crm-accent-light: #fffbeb;
            --crm-surface: #ffffff;
            --crm-bg: #f8fafc;
            --crm-border: #e2e8f0;
            --crm-border-hover: #cbd5e1;
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

        .products-page-container {
            max-width: 1360px;
            margin: 0 auto;
            padding-bottom: 40px;
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
            color: var(--crm-primary);
            font-weight: 600;
        }

        /* Page Hero Header */
        .products-hero-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 24px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            padding: 24px 28px;
            box-shadow: var(--crm-shadow-sm);
        }

        .products-hero-info h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            gap: 12px;
            letter-spacing: -0.02em;
        }

        .products-hero-info h1 i {
            color: var(--crm-primary);
            font-size: 22px;
        }

        .products-hero-desc {
            font-size: 14px;
            color: var(--crm-text-muted);
            margin: 0;
            max-width: 780px;
            line-height: 1.5;
        }

        .products-hero-actions {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }

        .btn-exec-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            padding: 10px 20px;
            font-weight: 600;
            font-size: 14px;
            border-radius: var(--crm-radius-md);
            border: none;
            box-shadow: 0 4px 14px rgba(30, 58, 138, 0.28);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-exec-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(30, 58, 138, 0.38);
        }

        .btn-exec-secondary {
            background: #ffffff;
            color: var(--crm-text-body) !important;
            padding: 9px 18px;
            font-weight: 600;
            font-size: 13.5px;
            border-radius: var(--crm-radius-md);
            border: 1px solid var(--crm-border);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-exec-secondary:hover {
            background: #f1f5f9;
            border-color: #cbd5e1;
        }

        /* Executive KPI Summary Cards */
        .exec-kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .exec-kpi-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            padding: 20px;
            box-shadow: var(--crm-shadow-sm);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .exec-kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--crm-shadow-md);
        }

        .exec-kpi-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .exec-kpi-icon.blue {
            background: #eff6ff;
            color: #2563eb;
        }
        .exec-kpi-icon.emerald {
            background: #ecfdf5;
            color: #059669;
        }
        .exec-kpi-icon.amber {
            background: #fffbeb;
            color: #d97706;
        }
        .exec-kpi-icon.purple {
            background: #faf5ff;
            color: #7c3aed;
        }

        .exec-kpi-content {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .exec-kpi-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--crm-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .exec-kpi-value {
            font-size: 22px;
            font-weight: 700;
            color: var(--crm-text-heading);
            letter-spacing: -0.02em;
        }
        .exec-kpi-sub {
            font-size: 12px;
            color: var(--crm-text-muted);
        }

        /* Alert Banners */
        .exec-alert {
            display: flex;
            align-items: flex-start;
            gap: 14px;
            padding: 14px 18px;
            border-radius: var(--crm-radius-md);
            font-size: 13.5px;
            margin-bottom: 20px;
            line-height: 1.5;
            position: relative;
        }
        .exec-alert.success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }
        .exec-alert.error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #991b1b;
        }
        .exec-alert i {
            font-size: 18px;
            margin-top: 2px;
            flex-shrink: 0;
        }
        .exec-alert-close {
            margin-left: auto;
            background: none;
            border: none;
            color: inherit;
            opacity: 0.6;
            cursor: pointer;
            font-size: 16px;
        }
        .exec-alert-close:hover {
            opacity: 1;
        }

        /* Filter Section Card */
        .exec-filter-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            padding: 18px 24px;
            margin-bottom: 24px;
            box-shadow: var(--crm-shadow-sm);
        }

        .exec-filter-form {
            display: flex;
            gap: 14px;
            align-items: center;
            flex-wrap: wrap;
        }

        .exec-search-wrapper {
            flex: 1;
            min-width: 260px;
            position: relative;
        }
        .exec-search-wrapper i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--crm-text-muted);
            font-size: 14px;
        }
        .exec-search-input {
            width: 100%;
            padding: 10px 14px 10px 38px;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            font-size: 13.5px;
            color: var(--crm-text-heading);
            background: #f8fafc;
            transition: all 0.15s ease;
        }
        .exec-search-input:focus {
            background: #ffffff;
            border-color: #2563eb;
            outline: none;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .exec-select {
            padding: 10px 14px;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            font-size: 13.5px;
            color: var(--crm-text-heading);
            background: #ffffff;
            min-width: 170px;
            transition: all 0.15s ease;
        }
        .exec-select:focus {
            border-color: #2563eb;
            outline: none;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        /* Table Card Container */
        .exec-table-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            box-shadow: var(--crm-shadow-sm);
            overflow: hidden;
        }

        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }

        .exec-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            text-align: left;
        }

        .exec-table th {
            background: #f8fafc;
            color: var(--crm-text-muted);
            font-size: 12.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 14px 18px;
            border-bottom: 1px solid var(--crm-border);
            white-space: nowrap;
        }

        .exec-table td {
            padding: 16px 18px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13.5px;
            color: var(--crm-text-body);
            vertical-align: middle;
            transition: background 0.15s ease;
        }

        .exec-table tbody tr:hover td {
            background-color: #f8fafc;
        }

        /* Product Code Badge */
        .code-pill {
            display: inline-block;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 12.5px;
            font-weight: 600;
            background: #f1f5f9;
            color: #334155;
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
        }

        /* Type Badges */
        .type-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 11.5px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 20px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        .type-pill.one-time {
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }
        .type-pill.subscription {
            background: #faf5ff;
            color: #6b21a8;
            border: 1px solid #e9d5ff;
        }

        /* Price Formatting & Floor Badge */
        .price-list-cell {
            font-weight: 700;
            color: var(--crm-primary);
            font-size: 14px;
        }

        .floor-price-wrapper {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .floor-price-val {
            font-weight: 700;
            color: #0f172a;
            font-size: 13.5px;
        }
        .floor-threshold-tag {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            color: #d97706;
            background: #fffbeb;
            padding: 2px 7px;
            border-radius: 4px;
            border: 1px solid #fef3c7;
            font-weight: 600;
            width: fit-content;
        }

        .cost-price-wrapper {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .badge-director-cost {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            color: #475569;
            background: #f1f5f9;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
            width: fit-content;
        }

        /* Status Badges */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12.5px;
            font-weight: 600;
        }
        .status-badge.active {
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }
        .status-badge.inactive {
            background: #f8fafc;
            color: #64748b;
            border: 1px solid #e2e8f0;
        }

        /* Action Buttons */
        .actions-cell {
            display: flex;
            gap: 6px;
            align-items: center;
            justify-content: flex-end;
        }

        .btn-action-icon {
            width: 32px;
            height: 32px;
            border-radius: var(--crm-radius-sm);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            border: 1px solid var(--crm-border);
            background: #ffffff;
            color: var(--crm-text-body);
            text-decoration: none;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .btn-action-icon:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: var(--crm-primary);
        }
        .btn-action-icon.edit:hover {
            background: #eff6ff;
            border-color: #bfdbfe;
            color: #2563eb;
        }
        .btn-action-icon.toggle:hover {
            background: #fffbeb;
            border-color: #fde68a;
            color: #d97706;
        }
        .btn-action-icon.delete:hover {
            background: #fef2f2;
            border-color: #fecaca;
            color: #dc2626;
        }

        /* Pagination */
        .exec-pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            border-top: 1px solid var(--crm-border);
            flex-wrap: wrap;
            gap: 12px;
        }
        .pagination-meta {
            font-size: 13px;
            color: var(--crm-text-muted);
        }
        .pagination-btns {
            display: flex;
            gap: 6px;
        }
        .page-btn {
            min-width: 34px;
            height: 34px;
            padding: 0 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 600;
            border-radius: var(--crm-radius-sm);
            border: 1px solid var(--crm-border);
            background: #ffffff;
            color: var(--crm-text-body);
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .page-btn:hover {
            border-color: #2563eb;
            color: #2563eb;
        }
        .page-btn.active {
            background: var(--crm-primary);
            color: #ffffff;
            border-color: var(--crm-primary);
        }

        /* Empty State */
        .empty-state-box {
            text-align: center;
            padding: 60px 20px;
            color: var(--crm-text-muted);
        }
        .empty-state-icon {
            font-size: 44px;
            color: #cbd5e1;
            margin-bottom: 14px;
        }

        /* Backlog Highlight Info Callout */
        .pricing-policy-alert {
            background: #eff6ff;
            border-left: 4px solid #2563eb;
            padding: 12px 18px;
            border-radius: 0 8px 8px 0;
            font-size: 13px;
            color: #1e3a8a;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container products-page-container">
            
            <!-- Breadcrumb Navigation -->
            <nav class="exec-breadcrumb" aria-label="Đường dẫn">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> CRM</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span>Kinh doanh</span>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current">Bảng giá Niêm yết & Sản phẩm</span>
            </nav>

            <!-- Page Hero Header -->
            <div class="products-hero-header">
                <div class="products-hero-info">
                    <h1>
                        <i class="fa-solid fa-boxes-stacked"></i>
                        Danh mục Bảng giá Niêm yết & Sản phẩm
                    </h1>
                    <p class="products-hero-desc">
                        Quản lý bảng giá chuẩn niêm yết tập trung và ngưỡng giá sàn để tự động xác định điều kiện duyệt chiết khấu khi nhân viên kinh doanh chào giá cho khách hàng.
                    </p>
                </div>
                <div class="products-hero-actions">
                    <c:if test="${canManageProducts == null or canManageProducts}">
                        <a href="${pageContext.request.contextPath}/products/create" class="btn-exec-primary" id="btn-create-product">
                            <i class="fa-solid fa-plus"></i> Khai báo sản phẩm mới
                        </a>
                    </c:if>
                </div>
            </div>

            <!-- Backlog Policy Notice Bar -->
            <div class="pricing-policy-alert">
                <i class="fa-solid fa-circle-info" style="font-size: 18px;"></i>
                <div>
                    <strong>Chính sách bảng giá tập trung:</strong> Mọi báo giá của nhân viên kinh doanh đều bắt buộc xuất phát từ bảng giá chuẩn này. Giá sàn là ranh giới tối thiểu; mọi mức giá chào dưới giá sàn sẽ tự động được gửi tới Giám đốc kinh doanh để phê duyệt chiết khấu.
                </div>
            </div>

            <!-- Toast / Alert Message Feedback -->
            <c:if test="${not empty param.success}">
                <div class="exec-alert success" id="alert-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <div>
                        <c:choose>
                            <c:when test="${param.success == 'create'}">
                                <strong>Thành công!</strong> Đã khai báo sản phẩm mới vào danh mục bảng giá chuẩn.
                            </c:when>
                            <c:when test="${param.success == 'status'}">
                                <strong>Thành công!</strong> Đã cập nhật trạng thái kinh doanh của sản phẩm.
                            </c:when>
                            <c:when test="${param.success == 'delete'}">
                                <strong>Thành công!</strong> Đã xóa sản phẩm khỏi danh mục hệ thống.
                            </c:when>
                            <c:otherwise>
                                <strong>Thành công!</strong> Thao tác cập nhật sản phẩm đã được thực hiện.
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <button type="button" class="exec-alert-close" onclick="this.parentElement.remove()">&times;</button>
                </div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="exec-alert error" id="alert-error">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <div>
                        <strong>Không thể thực hiện:</strong>
                        <c:choose>
                            <c:when test="${param.error == 'status'}">
                                Không thể thay đổi trạng thái kinh doanh của sản phẩm. Vui lòng thử lại.
                            </c:when>
                            <c:otherwise>
                                <c:out value="${param.error}"/>
                            </c:otherwise>
                        </c:choose>
                        <div style="margin-top: 4px; font-size: 12.5px; opacity: 0.9;">
                            💡 <em>Quy tắc CRM:</em> Sản phẩm đã từng xuất hiện trong báo giá không được xóa để bảo toàn lịch sử giao dịch. Bạn chỉ có thể chuyển sang trạng thái <strong>Ngừng kinh doanh (INACTIVE)</strong>.
                        </div>
                    </div>
                    <button type="button" class="exec-alert-close" onclick="this.parentElement.remove()">&times;</button>
                </div>
            </c:if>

            <!-- KPI Metric Stat Cards -->
            <div class="exec-kpi-grid">
                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon blue">
                        <i class="fa-solid fa-box-archive"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Tổng số sản phẩm</span>
                        <span class="exec-kpi-value">${totalItems}</span>
                        <span class="exec-kpi-sub">Sản phẩm & dịch vụ đã khai báo</span>
                    </div>
                </div>

                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon emerald">
                        <i class="fa-solid fa-check-to-slot"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Sẵn sàng báo giá</span>
                        <span class="exec-kpi-value">
                            <c:set var="activeCount" value="0"/>
                            <c:forEach var="item" items="${products}">
                                <c:if test="${item.status == 'ACTIVE'}">
                                    <c:set var="activeCount" value="${activeCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${activeCount} <small style="font-size: 13px; font-weight: normal; color: var(--crm-text-muted);">/ trang này</small>
                        </span>
                        <span class="exec-kpi-sub">Trạng thái Đang kinh doanh (ACTIVE)</span>
                    </div>
                </div>

                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon amber">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Kiểm soát Giá sàn</span>
                        <span class="exec-kpi-value" style="color: #d97706; font-size: 18px;">100% Bảo vệ</span>
                        <span class="exec-kpi-sub">Tự động kích hoạt duyệt chiết khấu</span>
                    </div>
                </div>

                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon purple">
                        <i class="fa-solid fa-user-tie"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Phân quyền Giá vốn</span>
                        <c:choose>
                            <c:when test="${canAccessCostPrice}">
                                <span class="exec-kpi-value" style="color: #7c3aed; font-size: 16px;">
                                    <i class="fa-solid fa-lock-open"></i> Đã cấp quyền
                                </span>
                                <span class="exec-kpi-sub">Giám đốc kinh doanh & Quản trị</span>
                            </c:when>
                            <c:otherwise>
                                <span class="exec-kpi-value" style="color: var(--crm-text-muted); font-size: 16px;">
                                    <i class="fa-solid fa-lock"></i> Được bảo mật
                                </span>
                                <span class="exec-kpi-sub">Ẩn đối với nhân viên kinh doanh</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Filter Card -->
            <div class="exec-filter-card">
                <form method="get" action="${pageContext.request.contextPath}/products" class="exec-filter-form" id="productFilterForm">
                    <div class="exec-search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" name="keyword" value="<c:out value='${keyword}'/>" class="exec-search-input" placeholder="Tìm theo mã sản phẩm, tên sản phẩm hoặc dịch vụ...">
                    </div>

                    <select name="productType" class="exec-select">
                        <option value="">-- Tất cả loại hình --</option>
                        <option value="ONE_TIME" ${productType == 'ONE_TIME' ? 'selected' : ''}>Sản phẩm (Bán một lần)</option>
                        <option value="SUBSCRIPTION" ${productType == 'SUBSCRIPTION' ? 'selected' : ''}>Dịch vụ (Thuê bao định kỳ)</option>
                    </select>

                    <select name="status" class="exec-select">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Đang kinh doanh (ACTIVE)</option>
                        <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Ngừng kinh doanh (INACTIVE)</option>
                    </select>

                    <button type="submit" class="btn-exec-primary" style="padding: 10px 18px;">
                        <i class="fa-solid fa-filter"></i> Lọc danh sách
                    </button>
                    
                    <c:if test="${not empty keyword or not empty productType or not empty status}">
                        <a href="${pageContext.request.contextPath}/products" class="btn-exec-secondary" style="padding: 9px 14px;" title="Xóa bộ lọc">
                            <i class="fa-solid fa-arrow-rotate-left"></i> Đặt lại
                        </a>
                    </c:if>
                </form>
            </div>

            <!-- Products Data Table Card -->
            <div class="exec-table-card">
                <div class="table-responsive">
                    <table class="exec-table">
                        <thead>
                            <tr>
                                <th style="width: 110px;">Mã SP</th>
                                <th>Tên sản phẩm / Dịch vụ</th>
                                <th style="width: 140px;">Phân loại</th>
                                <th style="width: 90px;">ĐVT</th>
                                <th style="width: 150px;">Giá niêm yết</th>
                                <th style="width: 170px;">Giá sàn (Ngưỡng duyệt CK)</th>
                                <c:if test="${canAccessCostPrice}">
                                    <th style="width: 140px;">Giá vốn (GĐKD)</th>
                                </c:if>
                                <th style="width: 130px;">Trạng thái</th>
                                <th style="width: 140px; text-align: right;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td>
                                        <span class="code-pill"><c:out value="${p.productCode}"/></span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: var(--crm-text-heading); font-size: 14px;">
                                            <a href="${pageContext.request.contextPath}/products/detail?productId=${p.productId}" style="color: inherit; text-decoration: none;">
                                                <c:out value="${p.productName}"/>
                                            </a>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.productType == 'SUBSCRIPTION'}">
                                                <span class="type-pill subscription">
                                                    <i class="fa-solid fa-repeat"></i> Thuê bao
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="type-pill one-time">
                                                    <i class="fa-solid fa-cube"></i> Một lần
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span style="color: var(--crm-text-body);"><c:out value="${p.unit}"/></span>
                                    </td>
                                    <td>
                                        <span class="price-list-cell">
                                            <fmt:formatNumber value="${p.listPrice}" type="currency" currencySymbol="₫"/>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="floor-price-wrapper">
                                            <span class="floor-price-val">
                                                <fmt:formatNumber value="${p.floorPrice}" type="currency" currencySymbol="₫"/>
                                            </span>
                                            <span class="floor-threshold-tag" title="Giá báo dưới mức này bắt buộc Giám đốc kinh doanh duyệt chiết khấu">
                                                <i class="fa-solid fa-shield"></i> Ngưỡng duyệt CK
                                            </span>
                                        </div>
                                    </td>
                                    <c:if test="${canAccessCostPrice}">
                                        <td>
                                            <div class="cost-price-wrapper">
                                                <c:choose>
                                                    <c:when test="${p.costPrice != null}">
                                                        <span style="font-weight: 600; color: #475569;">
                                                            <fmt:formatNumber value="${p.costPrice}" type="currency" currencySymbol="₫"/>
                                                        </span>
                                                        <span class="badge-director-cost">
                                                            <i class="fa-solid fa-lock"></i> Chỉ GĐKD
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: var(--crm-text-muted);">Chưa nhập</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </c:if>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.status == 'ACTIVE'}">
                                                <span class="status-badge active">
                                                    <i class="fa-solid fa-circle-check"></i> Đang kinh doanh
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge inactive">
                                                    <i class="fa-solid fa-ban"></i> Ngừng kinh doanh
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="actions-cell">
                                            <!-- Xem chi tiết -->
                                            <a href="${pageContext.request.contextPath}/products/detail?productId=${p.productId}" class="btn-action-icon" title="Xem chi tiết sản phẩm">
                                                <i class="fa-solid fa-eye"></i>
                                            </a>

                                            <!-- Sửa thông tin & bảng giá -->
                                            <c:if test="${canManageProducts == null or canManageProducts}">
                                                <a href="${pageContext.request.contextPath}/products/edit?productId=${p.productId}" class="btn-action-icon edit" title="Chỉnh sửa sản phẩm & bảng giá">
                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                </a>

                                                <!-- Chuyển trạng thái kinh doanh -->
                                                <button type="button" 
                                                        onclick="toggleStatus(${p.productId}, '${p.status}', '<c:out value="${p.productName}"/>')" 
                                                        class="btn-action-icon toggle" 
                                                        title="${p.status == 'ACTIVE' ? 'Ngừng kinh doanh (Tạm dừng)' : 'Kích hoạt kinh doanh trở lại'}">
                                                    <i class="fa-solid ${p.status == 'ACTIVE' ? 'fa-pause' : 'fa-play'}"></i>
                                                </button>

                                                <!-- Xóa sản phẩm với thông báo quy tắc báo giá -->
                                                <button type="button" 
                                                        onclick="confirmDelete(${p.productId}, '<c:out value="${p.productName}"/>')" 
                                                        class="btn-action-icon delete" 
                                                        title="Xóa sản phẩm khỏi danh mục">
                                                    <i class="fa-solid fa-trash-can"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty products}">
                                <tr>
                                    <td colspan="${canAccessCostPrice ? 9 : 8}">
                                        <div class="empty-state-box">
                                            <div class="empty-state-icon"><i class="fa-solid fa-box-open"></i></div>
                                            <h3 style="font-size: 16px; font-weight: 600; color: var(--crm-text-heading); margin-bottom: 6px;">Không tìm thấy sản phẩm nào</h3>
                                            <p style="font-size: 13.5px; margin-bottom: 16px;">Chưa có sản phẩm phù hợp với điều kiện tìm kiếm hoặc danh mục đang trống.</p>
                                            <c:if test="${canManageProducts == null or canManageProducts}">
                                                <a href="${pageContext.request.contextPath}/products/create" class="btn-exec-primary">
                                                    <i class="fa-solid fa-plus"></i> Khai báo sản phẩm đầu tiên
                                                </a>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Bar -->
                <c:if test="${totalPages > 1}">
                    <div class="exec-pagination-container">
                        <div class="pagination-meta">
                            Trang <strong>${currentPage}</strong> trên tổng số <strong>${totalPages}</strong> trang (Tổng <strong>${totalItems}</strong> sản phẩm)
                        </div>
                        <div class="pagination-btns">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}&keyword=<c:out value='${keyword}'/>&productType=<c:out value='${productType}'/>&status=<c:out value='${status}'/>" class="page-btn">
                                    <i class="fa-solid fa-chevron-left"></i>
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <a href="?page=${i}&keyword=<c:out value='${keyword}'/>&productType=<c:out value='${productType}'/>&status=<c:out value='${status}'/>" class="page-btn ${i == currentPage ? 'active' : ''}">
                                    ${i}
                                </a>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&keyword=<c:out value='${keyword}'/>&productType=<c:out value='${productType}'/>&status=<c:out value='${status}'/>" class="page-btn">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>

        </div>
    </main>
</div>

<!-- Dynamic Action Script with Backlog Rules Guidance -->
<script>
    function toggleStatus(productId, currentStatus, productName) {
        var isCurrentlyActive = (currentStatus === 'ACTIVE');
        var newStatus = isCurrentlyActive ? 'INACTIVE' : 'ACTIVE';
        var actionText = isCurrentlyActive ? 'NGỪNG KINH DOANH' : 'KÍCH HOẠT LẠI';
        var confirmMsg = 'Bạn có chắc chắn muốn ' + actionText + ' sản phẩm:\n"' + productName + '"?\n\n' +
            (isCurrentlyActive 
                ? '• Lưu ý: Khi ngừng kinh doanh, nhân viên kinh doanh sẽ không thể chọn sản phẩm này vào các báo giá mới.' 
                : '• Sau khi kích hoạt, sản phẩm sẽ lại xuất hiện trong bảng giá để lập báo giá bình thường.');

        if (!confirm(confirmMsg)) {
            return;
        }

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/products/status';

        var inputId = document.createElement('input');
        inputId.type = 'hidden';
        inputId.name = 'productId';
        inputId.value = productId;
        form.appendChild(inputId);

        var inputStatus = document.createElement('input');
        inputStatus.type = 'hidden';
        inputStatus.name = 'status';
        inputStatus.value = newStatus;
        form.appendChild(inputStatus);

        document.body.appendChild(form);
        form.submit();
    }

    function confirmDelete(productId, productName) {
        var warningMsg = 'XÁC NHẬN XÓA SẢN PHẨM: "' + productName + '"\n\n' +
            '⚠️ QUY ĐỊNH BẢO VỆ DỮ LIỆU BÁO GIÁ CRM:\n' +
            '• Nếu sản phẩm này ĐÃ TỪNG XUẤT HIỆN trong bất kỳ báo giá hoặc cơ hội nào, hệ thống sẽ NGĂN CHẶN XÓA để bảo toàn lịch sử số liệu.\n' +
            '• Trường hợp đó, bạn chỉ có thể chuyển sang trạng thái "Ngừng kinh doanh".\n\n' +
            'Bạn có chắc chắn muốn tiến hành xóa không?';

        if (!confirm(warningMsg)) {
            return;
        }

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/products/delete';

        var inputId = document.createElement('input');
        inputId.type = 'hidden';
        inputId.name = 'productId';
        inputId.value = productId;
        form.appendChild(inputId);

        document.body.appendChild(form);
        form.submit();
    }
</script>
</body>
</html>
