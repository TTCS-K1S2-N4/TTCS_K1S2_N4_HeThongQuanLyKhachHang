<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.AuditLog" %>
<%@ page import="com.crm.model.Account" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhật ký kiểm toán dữ liệu nhạy cảm | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/audit-log.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Audit Trail & Sensitive Data Monitoring
           ========================================================================== */
        :root {
            --audit-navy-900: #0f172a;
            --audit-navy-800: #1e293b;
            --audit-primary: #1e3a8a;
            --audit-accent-blue: #2563eb;
            --audit-accent-blue-light: #eff6ff;
            --audit-emerald: #10b981;
            --audit-emerald-light: #ecfdf5;
            --audit-amber: #f59e0b;
            --audit-amber-light: #fffbeb;
            --audit-purple: #8b5cf6;
            --audit-purple-light: #f5f3ff;
            --audit-rose: #f43f5e;
            --audit-rose-light: #fff1f2;
            --audit-slate: #64748b;
            --audit-slate-light: #f8fafc;
            
            --audit-border: #e2e8f0;
            --audit-text-heading: #0f172a;
            --audit-text-body: #334155;
            --audit-text-muted: #64748b;
            
            --audit-radius-sm: 8px;
            --audit-radius-md: 12px;
            --audit-radius-lg: 16px;
            
            --audit-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --audit-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.06), 0 2px 4px -2px rgba(15, 23, 42, 0.04);
            --audit-shadow-lg: 0 10px 25px -3px rgba(30, 58, 138, 0.08);
        }

        .audit-container {
            max-width: 1400px;
            margin: 0 auto;
            padding-bottom: 60px;
        }

        /* Modern Breadcrumbs */
        .audit-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--audit-text-muted);
            margin-bottom: 16px;
        }
        .audit-breadcrumb a {
            color: var(--audit-text-muted);
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .audit-breadcrumb a:hover {
            color: var(--audit-primary);
        }
        .audit-breadcrumb .sep {
            color: #cbd5e1;
            font-size: 11px;
        }
        .audit-breadcrumb .current {
            color: var(--audit-accent-blue);
            font-weight: 600;
        }

        /* Top Hero Header Card */
        .audit-hero-header {
            background: #ffffff;
            border: 1px solid var(--audit-border);
            border-radius: var(--audit-radius-lg);
            padding: 24px 28px;
            box-shadow: var(--audit-shadow-sm);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            overflow: hidden;
        }

        .audit-hero-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(180deg, #1e3a8a 0%, #2563eb 100%);
        }

        .audit-hero-left {
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .audit-avatar-squircle {
            width: 58px;
            height: 58px;
            border-radius: 16px;
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 8px 18px rgba(30, 58, 138, 0.25);
            flex-shrink: 0;
        }

        .audit-hero-title h1 {
            font-size: 22px;
            font-weight: 700;
            color: var(--audit-text-heading);
            margin: 0 0 6px 0;
            letter-spacing: -0.01em;
            line-height: 1.25;
        }

        .audit-hero-meta {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            font-size: 13px;
            color: var(--audit-text-muted);
        }

        .audit-badge-gov {
            background: #eff6ff;
            color: #1d4ed8;
            font-weight: 700;
            font-size: 11.5px;
            padding: 3px 9px;
            border-radius: 6px;
            border: 1px solid #bfdbfe;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .audit-hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-audit-outline {
            background: #ffffff;
            color: #334155 !important;
            border: 1px solid var(--audit-border);
            padding: 8px 16px;
            border-radius: var(--audit-radius-sm);
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            box-shadow: var(--audit-shadow-sm);
            cursor: pointer;
        }
        .btn-audit-outline:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: var(--audit-primary) !important;
        }

        .btn-audit-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            border: none;
            padding: 9px 20px;
            border-radius: var(--audit-radius-sm);
            font-size: 13.5px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 4px 14px rgba(30, 58, 138, 0.28);
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        .btn-audit-primary:hover {
            background: linear-gradient(135deg, #172554 0%, #1d4ed8 100%);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(30, 58, 138, 0.38);
        }

        /* 4 Executive Metric Cards */
        .audit-stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 24px;
        }
        @media (max-width: 1024px) {
            .audit-stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 640px) {
            .audit-stats-grid { grid-template-columns: 1fr; }
        }

        .stat-card {
            background: #ffffff;
            border: 1.5px solid var(--audit-border);
            border-radius: var(--audit-radius-md);
            padding: 18px 20px;
            box-shadow: var(--audit-shadow-sm);
            transition: all 0.2s ease;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            overflow: hidden;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--audit-shadow-md);
            border-color: #cbd5e1;
        }
        .stat-card.active {
            border-color: var(--audit-accent-blue);
            background: #f8fbff;
            box-shadow: 0 0 0 1px var(--audit-accent-blue);
        }

        .stat-card-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
        }
        .stat-icon.discount { background: #fef3c7; color: #b45309; }
        .stat-icon.kpi { background: #f3e8ff; color: #7e22ce; }
        .stat-icon.ownership { background: #dbeafe; color: #1d4ed8; }
        .stat-icon.role { background: #ccfbf1; color: #0f766e; }

        .stat-title {
            font-size: 13px;
            font-weight: 600;
            color: var(--audit-text-muted);
            margin: 0;
        }
        .stat-value {
            font-size: 26px;
            font-weight: 700;
            color: var(--audit-text-heading);
            margin: 4px 0 2px 0;
            font-variant-numeric: tabular-nums;
        }
        .stat-desc {
            font-size: 12px;
            color: #64748b;
            margin: 0;
        }

        /* Filter Section Card */
        .audit-card {
            background: #ffffff;
            border: 1px solid var(--audit-border);
            border-radius: var(--audit-radius-lg);
            box-shadow: var(--audit-shadow-sm);
            margin-bottom: 24px;
            overflow: hidden;
        }
        .audit-card-header {
            padding: 18px 24px;
            background: #ffffff;
            border-bottom: 1px solid var(--audit-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
        }
        .audit-card-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 15.5px;
            font-weight: 700;
            color: var(--audit-text-heading);
            margin: 0;
        }
        .audit-card-title i {
            color: var(--audit-accent-blue);
        }

        .audit-card-body {
            padding: 24px;
        }

        /* Filters Layout */
        .filter-controls-grid {
            display: grid;
            grid-template-columns: 2fr 1.8fr 1.5fr 1.5fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        @media (max-width: 1024px) {
            .filter-controls-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 640px) {
            .filter-controls-grid { grid-template-columns: 1fr; }
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .filter-label {
            font-size: 12.5px;
            font-weight: 600;
            color: #334155;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .filter-input {
            width: 100%;
            height: 38px;
            padding: 0 12px;
            font-size: 13.5px;
            color: #0f172a;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: var(--audit-radius-sm);
            box-sizing: border-box;
            outline: none;
            transition: all 0.2s ease;
        }
        .filter-input:focus {
            border-color: var(--audit-accent-blue);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        /* Quick Range Preset Chips */
        .presets-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            padding-top: 14px;
            border-top: 1px dashed #e2e8f0;
        }
        .presets-chips-group {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .preset-tag-label {
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
        }
        .time-chip {
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 12px;
            font-weight: 500;
            padding: 4px 11px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.15s ease;
            user-select: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .time-chip:hover {
            background: #e2e8f0;
            color: #0f172a;
            border-color: #cbd5e1;
        }
        .time-chip.quarter {
            background: #eff6ff;
            color: #1d4ed8;
            border-color: #bfdbfe;
            font-weight: 600;
        }
        .time-chip.quarter:hover {
            background: #dbeafe;
        }

        /* Audit Table Styles */
        .audit-table-wrap {
            overflow-x: auto;
        }
        .audit-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 13.5px;
        }
        .audit-table th {
            background: #f8fafc;
            color: #475569;
            font-weight: 700;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            padding: 12px 16px;
            border-bottom: 1.5px solid var(--audit-border);
            text-align: left;
            white-space: nowrap;
        }
        .audit-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #1e293b;
            vertical-align: middle;
            transition: background 0.1s ease;
        }
        .audit-table tr:hover td {
            background: #f8fafc;
        }

        /* Pill Badges */
        .badge-entity {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }
        .badge-entity.DISCOUNT { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .badge-entity.KPI { background: #f3e8ff; color: #6b21a8; border: 1px solid #e9d5ff; }
        .badge-entity.DATA_OWNERSHIP { background: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; }
        .badge-entity.USER_ROLE { background: #ccfbf1; color: #115e59; border: 1px solid #99f6e4; }
        .badge-entity.SYSTEM { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }

        /* User Performer Pill */
        .performer-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .performer-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0;
        }
        .performer-info h6 {
            margin: 0;
            font-size: 13px;
            font-weight: 600;
            color: #0f172a;
        }
        .performer-info span {
            font-size: 11.5px;
            color: #64748b;
        }

        /* Value Diff Chips */
        .diff-tag-container {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            max-width: 440px;
        }
        .diff-tag {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 11.5px;
            padding: 3px 8px;
            border-radius: 5px;
            word-break: break-all;
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            display: inline-block;
        }
        .diff-tag.old {
            background: #fff1f2;
            color: #9f1239;
            border: 1px solid #fecdd3;
            text-decoration: line-through;
        }
        .diff-tag.new {
            background: #ecfdf5;
            color: #065f46;
            border: 1px solid #a7f3d0;
            font-weight: 600;
        }
        .diff-arrow {
            color: #94a3b8;
            font-size: 11px;
            flex-shrink: 0;
        }

        /* Pagination Footer */
        .audit-pagination-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 24px;
            background: #ffffff;
            border-top: 1px solid var(--audit-border);
            flex-wrap: wrap;
            gap: 16px;
        }
        .pagination-info {
            font-size: 13px;
            color: var(--audit-text-muted);
        }
        .pagination-pages {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .page-btn {
            height: 34px;
            min-width: 34px;
            padding: 0 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #334155;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .page-btn:hover:not(.disabled) {
            background: #f1f5f9;
            border-color: #94a3b8;
            color: #0f172a;
        }
        .page-btn.active {
            background: var(--audit-primary);
            border-color: var(--audit-primary);
            color: #ffffff;
        }
        .page-btn.disabled {
            opacity: 0.4;
            pointer-events: none;
            cursor: not-allowed;
        }

        /* Detail Slide/Modal */
        .audit-modal-backdrop {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 100;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .audit-modal {
            background: #ffffff;
            width: 100%;
            max-width: 760px;
            border-radius: var(--audit-radius-lg);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            animation: modalFadeIn 0.2s ease-out;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.96); }
            to { opacity: 1; transform: scale(1); }
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <%
            String userIdParam = request.getAttribute("userIdParam") != null ? (String) request.getAttribute("userIdParam") : "";
            String entityTypeParam = request.getAttribute("entityTypeParam") != null ? (String) request.getAttribute("entityTypeParam") : "";
            String fromDateParam = request.getAttribute("fromDateParam") != null ? (String) request.getAttribute("fromDateParam") : "";
            String toDateParam = request.getAttribute("toDateParam") != null ? (String) request.getAttribute("toDateParam") : "";

            Integer currentPage = (Integer) request.getAttribute("currentPage");
            if (currentPage == null) currentPage = 1;

            Integer totalPages = (Integer) request.getAttribute("totalPages");
            if (totalPages == null) totalPages = 1;

            Integer totalItems = (Integer) request.getAttribute("totalItems");
            if (totalItems == null) totalItems = 0;

            Integer pageSize = (Integer) request.getAttribute("pageSize");
            if (pageSize == null) pageSize = 20;

            Integer discountCount = (Integer) request.getAttribute("discountCount");
            if (discountCount == null) discountCount = 0;

            Integer targetCount = (Integer) request.getAttribute("targetCount");
            if (targetCount == null) targetCount = 0;

            Integer ownershipCount = (Integer) request.getAttribute("ownershipCount");
            if (ownershipCount == null) ownershipCount = 0;

            Integer roleCount = (Integer) request.getAttribute("roleCount");
            if (roleCount == null) roleCount = 0;

            List<Account> userList = (List<Account>) request.getAttribute("userList");
            List<AuditLog> auditLogs = (List<AuditLog>) request.getAttribute("auditLogs");

            String baseFilterQuery = "userId=" + java.net.URLEncoder.encode(userIdParam, "UTF-8")
                    + "&fromDate=" + java.net.URLEncoder.encode(fromDateParam, "UTF-8")
                    + "&toDate=" + java.net.URLEncoder.encode(toDateParam, "UTF-8")
                    + "&pageSize=" + pageSize;
        %>

        <div class="content-container audit-container">
            
            <!-- Breadcrumbs -->
            <nav class="audit-breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span>Quản trị hệ thống</span>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current">Nhật ký kiểm toán dữ liệu</span>
            </nav>

            <!-- Hero Header Card -->
            <div class="audit-hero-header">
                <div class="audit-hero-left">
                    <div class="audit-avatar-squircle">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <div class="audit-hero-title">
                        <h1>Nhật ký kiểm toán &amp; Giám sát dữ liệu nhạy cảm</h1>
                        <div class="audit-hero-meta">
                            <span class="audit-badge-gov">
                                <i class="fa-solid fa-fingerprint"></i> Kiểm soát an toàn (Nhật ký thay đổi dữ liệu - Audit Trail)
                            </span>
                            <span>Truy vết ai đã sửa đổi chiết khấu, chỉ tiêu, chuyển giao dữ liệu &amp; vai trò tài khoản</span>
                        </div>
                    </div>
                </div>
                <div class="audit-hero-actions">
                    <a href="${pageContext.request.contextPath}/audit/list" class="btn-audit-outline">
                        <i class="fa-solid fa-rotate-right"></i> Làm mới
                    </a>
                </div>
            </div>

            <!-- 4 Executive Metric Cards (Quick Filter Category Click) -->
            <div class="audit-stats-grid">
                
                <!-- Card 1: Discounts -->
                <a href="${pageContext.request.contextPath}/audit/list?entityType=DISCOUNT" 
                   class="stat-card <%= "DISCOUNT".equalsIgnoreCase(entityTypeParam) ? "active" : "" %>"
                   title="Xem tất cả biến động chiết khấu">
                    <div class="stat-card-top">
                        <div class="stat-icon discount">
                            <i class="fa-solid fa-tags"></i>
                        </div>
                        <span style="font-size: 11px; font-weight: 700; color: #b45309; background: #fef3c7; padding: 2px 7px; border-radius: 4px;">Chiết khấu</span>
                    </div>
                    <div>
                        <h4 class="stat-title">Biến động Chiết khấu</h4>
                        <div class="stat-value"><%= discountCount %></div>
                        <p class="stat-desc">Sửa giá niêm yết, giá sàn &amp; chiết khấu SP</p>
                    </div>
                </a>

                <!-- Card 2: Targets & KPI -->
                <a href="${pageContext.request.contextPath}/audit/list?entityType=KPI" 
                   class="stat-card <%= ("KPI".equalsIgnoreCase(entityTypeParam) || "TARGET".equalsIgnoreCase(entityTypeParam)) ? "active" : "" %>"
                   title="Xem tất cả biến động chỉ tiêu doanh số">
                    <div class="stat-card-top">
                        <div class="stat-icon kpi">
                            <i class="fa-solid fa-bullseye"></i>
                        </div>
                        <span style="font-size: 11px; font-weight: 700; color: #7e22ce; background: #f3e8ff; padding: 2px 7px; border-radius: 4px;">Chỉ tiêu</span>
                    </div>
                    <div>
                        <h4 class="stat-title">Chỉ tiêu &amp; Doanh số</h4>
                        <div class="stat-value"><%= targetCount %></div>
                        <p class="stat-desc">Điều chỉnh doanh số &amp; chỉ tiêu cơ hội</p>
                    </div>
                </a>

                <!-- Card 3: Data Ownership -->
                <a href="${pageContext.request.contextPath}/audit/list?entityType=DATA_OWNERSHIP" 
                   class="stat-card <%= "DATA_OWNERSHIP".equalsIgnoreCase(entityTypeParam) ? "active" : "" %>"
                   title="Xem tất cả chuyển giao quyền sở hữu dữ liệu">
                    <div class="stat-card-top">
                        <div class="stat-icon ownership">
                            <i class="fa-solid fa-arrow-right-arrow-left"></i>
                        </div>
                        <span style="font-size: 11px; font-weight: 700; color: #1d4ed8; background: #dbeafe; padding: 2px 7px; border-radius: 4px;">Sở hữu</span>
                    </div>
                    <div>
                        <h4 class="stat-title">Chuyển giao Quyền sở hữu</h4>
                        <div class="stat-value"><%= ownershipCount %></div>
                        <p class="stat-desc">Bàn giao khách hàng &amp; cơ hội kinh doanh</p>
                    </div>
                </a>

                <!-- Card 4: User Roles -->
                <a href="${pageContext.request.contextPath}/audit/list?entityType=USER_ROLE" 
                   class="stat-card <%= "USER_ROLE".equalsIgnoreCase(entityTypeParam) ? "active" : "" %>"
                   title="Xem tất cả thay đổi phân quyền & vai trò">
                    <div class="stat-card-top">
                        <div class="stat-icon role">
                            <i class="fa-solid fa-user-shield"></i>
                        </div>
                        <span style="font-size: 11px; font-weight: 700; color: #0f766e; background: #ccfbf1; padding: 2px 7px; border-radius: 4px;">Phân quyền</span>
                    </div>
                    <div>
                        <h4 class="stat-title">Phân quyền &amp; Vai trò</h4>
                        <div class="stat-value"><%= roleCount %></div>
                        <p class="stat-desc">Cấp phát &amp; thay đổi vai trò tài khoản</p>
                    </div>
                </a>

            </div>

            <!-- Smart Filter Card -->
            <div class="audit-card">
                <div class="audit-card-header">
                    <h3 class="audit-card-title">
                        <i class="fa-solid fa-filter"></i> Bộ lọc tra cứu kiểm toán
                    </h3>
                    <div style="font-size: 13px; color: #64748b;">
                        Tìm thấy <strong><%= totalItems %></strong> bản ghi phù hợp
                    </div>
                </div>
                <div class="audit-card-body">
                    <form id="auditFilterForm" action="${pageContext.request.contextPath}/audit/list" method="get">
                        <div class="filter-controls-grid">
                            
                            <!-- Performed By Dropdown -->
                            <div class="filter-group">
                                <label class="filter-label" for="filterUserId">
                                    <i class="fa-solid fa-user" style="color: #64748b;"></i> Người thực hiện
                                </label>
                                <select id="filterUserId" name="userId" class="filter-input">
                                    <option value="">-- Tất cả người thực hiện --</option>
                                    <% if (userList != null) {
                                        for (Account u : userList) {
                                            String selected = String.valueOf(u.getAccountId()).equals(userIdParam) ? "selected" : "";
                                    %>
                                        <option value="<%= u.getAccountId() %>" <%= selected %>>
                                            <%= u.getFullName() %> (<%= u.getTeamName() != null ? u.getTeamName() : "Hệ thống" %>)
                                        </option>
                                    <% } } %>
                                </select>
                            </div>

                            <!-- Entity Type Dropdown -->
                            <div class="filter-group">
                                <label class="filter-label" for="filterEntityType">
                                    <i class="fa-solid fa-layer-group" style="color: #64748b;"></i> Phân loại đối tượng
                                </label>
                                <select id="filterEntityType" name="entityType" class="filter-input">
                                    <option value="" <%= "".equals(entityTypeParam) ? "selected" : "" %>>-- Tất cả loại đối tượng --</option>
                                    <option value="DISCOUNT" <%= "DISCOUNT".equalsIgnoreCase(entityTypeParam) ? "selected" : "" %>>Chiết khấu &amp; Bảng giá</option>
                                    <option value="KPI" <%= ("KPI".equalsIgnoreCase(entityTypeParam) || "TARGET".equalsIgnoreCase(entityTypeParam)) ? "selected" : "" %>>Chỉ tiêu doanh số / KPI</option>
                                    <option value="DATA_OWNERSHIP" <%= "DATA_OWNERSHIP".equalsIgnoreCase(entityTypeParam) ? "selected" : "" %>>Quyền sở hữu dữ liệu</option>
                                    <option value="USER_ROLE" <%= "USER_ROLE".equalsIgnoreCase(entityTypeParam) ? "selected" : "" %>>Vai trò &amp; Quyền người dùng</option>
                                    <option value="SYSTEM" <%= "SYSTEM".equalsIgnoreCase(entityTypeParam) ? "selected" : "" %>>Bảo mật &amp; Hệ thống</option>
                                </select>
                            </div>

                            <!-- From Date -->
                            <div class="filter-group">
                                <label class="filter-label" for="filterFromDate">
                                    <i class="fa-solid fa-calendar-day" style="color: #64748b;"></i> Từ ngày
                                </label>
                                <input type="date" id="filterFromDate" name="fromDate" class="filter-input" value="<%= fromDateParam %>">
                            </div>

                            <!-- To Date -->
                            <div class="filter-group">
                                <label class="filter-label" for="filterToDate">
                                    <i class="fa-solid fa-calendar-check" style="color: #64748b;"></i> Đến ngày
                                </label>
                                <input type="date" id="filterToDate" name="toDate" class="filter-input" value="<%= toDateParam %>">
                            </div>

                        </div>

                        <input type="hidden" name="page" value="1">
                        <input type="hidden" name="pageSize" value="<%= pageSize %>">

                        <!-- Quick Presets Row for Quarter, Month, etc. -->
                        <div class="presets-bar">
                            <div class="presets-chips-group">
                                <span class="preset-tag-label"><i class="fa-solid fa-bolt"></i> Chọn nhanh kỳ:</span>
                                <span class="time-chip quarter" onclick="setQuarterPreset()" title="Lọc theo toàn bộ quý hiện tại để đối soát số liệu">
                                    <i class="fa-solid fa-calendar-days"></i> Quý này (Đối soát cuối quý)
                                </span>
                                <span class="time-chip" onclick="setThisMonthPreset()">Tháng này</span>
                                <span class="time-chip" onclick="setDaysPreset(30)">30 ngày qua</span>
                                <span class="time-chip" onclick="setDaysPreset(7)">7 ngày qua</span>
                                <span class="time-chip" onclick="setTodayPreset()">Hôm nay</span>
                                <span class="time-chip" onclick="clearDatePresets()">Tất cả thời gian</span>
                            </div>

                            <div style="display: flex; gap: 10px; align-items: center;">
                                <a href="${pageContext.request.contextPath}/audit/list" class="btn-audit-outline" style="padding: 7px 14px; font-size: 13px;">
                                    <i class="fa-solid fa-xmark"></i> Xóa lọc
                                </a>
                                <button type="submit" class="btn-audit-primary" style="padding: 8px 18px; font-size: 13px;">
                                    <i class="fa-solid fa-magnifying-glass"></i> Áp dụng bộ lọc
                                </button>
                            </div>
                        </div>

                    </form>
                </div>
            </div>

            <!-- Audit Logs Data Table -->
            <div class="audit-card">
                <div class="audit-table-wrap">
                    <table class="audit-table">
                        <thead>
                            <tr>
                                <th style="width: 70px;">Mã</th>
                                <th style="width: 140px;">Thời điểm</th>
                                <th style="width: 190px;">Người thực hiện</th>
                                <th style="width: 150px;">Phân loại</th>
                                <th style="width: 190px;">Đối tượng tác động</th>
                                <th style="min-width: 280px;">Giá trị trước &amp; sau thay đổi (Diff)</th>
                                <th style="width: 90px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (auditLogs != null && !auditLogs.isEmpty()) {
                                    for (AuditLog log : auditLogs) {
                                        String performerName = log.getPerformedByName() != null ? log.getPerformedByName() : (log.getUserId() > 0 ? "User #" + log.getUserId() : "Hệ thống");
                                        String initial = performerName.length() > 0 ? performerName.substring(0, 1).toUpperCase() : "U";
                                        String timeStr = log.getFormattedCreatedAt();
                                        String entityType = log.getEntityType() != null ? log.getEntityType() : "SYSTEM";
                                        String entityName = log.getTargetEntityName() != null ? log.getTargetEntityName() : ("Mã #" + log.getEntityId());
                                        String oldVal = log.getOldValue() != null ? log.getOldValue().trim() : "-";
                                        String newVal = log.getNewValue() != null ? log.getNewValue().trim() : "-";
                            %>
                            <tr>
                                <td>
                                    <span style="font-family: monospace; font-weight: 700; color: #64748b; font-size: 12.5px;">
                                        #<%= log.getLogId() %>
                                    </span>
                                </td>
                                <td>
                                    <div style="font-size: 12.5px; font-weight: 600; color: #1e293b;"><%= timeStr %></div>
                                    <div style="font-size: 11px; color: #94a3b8;"><i class="fa-regular fa-clock"></i> GMT+7</div>
                                </td>
                                <td>
                                    <div class="performer-wrap">
                                        <div class="performer-avatar"><%= initial %></div>
                                        <div class="performer-info">
                                            <h6><%= performerName %></h6>
                                            <span>Mã NV: <%= log.getUserId() %></span>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge-entity <%= entityType %>">
                                        <% if ("DISCOUNT".equals(entityType)) { %>
                                            <i class="fa-solid fa-tags"></i> Chiết khấu
                                        <% } else if ("KPI".equals(entityType)) { %>
                                            <i class="fa-solid fa-bullseye"></i> Chỉ tiêu / KPI
                                        <% } else if ("DATA_OWNERSHIP".equals(entityType)) { %>
                                            <i class="fa-solid fa-arrow-right-arrow-left"></i> Quyền sở hữu
                                        <% } else if ("USER_ROLE".equals(entityType)) { %>
                                            <i class="fa-solid fa-user-shield"></i> Vai trò tài khoản
                                        <% } else { %>
                                            <i class="fa-solid fa-server"></i> <%= log.getEntityTypeDisplay() %>
                                        <% } %>
                                    </span>
                                </td>
                                <td>
                                    <div style="font-weight: 600; font-size: 13px; color: #0f172a;"><%= entityName %></div>
                                    <div style="font-size: 11.5px; color: #64748b;"><%= log.getActionDisplay() %></div>
                                </td>
                                <td>
                                    <div class="diff-tag-container">
                                        <span class="diff-tag old" title="<%= oldVal %>">
                                            <i class="fa-solid fa-minus" style="font-size: 9px;"></i> <%= oldVal %>
                                        </span>
                                        <i class="fa-solid fa-arrow-right diff-arrow"></i>
                                        <span class="diff-tag new" title="<%= newVal %>">
                                            <i class="fa-solid fa-plus" style="font-size: 9px;"></i> <%= newVal %>
                                        </span>
                                    </div>
                                    <% if (log.getDetails() != null && !log.getDetails().trim().isEmpty()) { %>
                                        <div style="font-size: 11.5px; color: #64748b; margin-top: 3px; max-width: 420px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                            <i class="fa-regular fa-comment-dots"></i> <%= log.getDetails() %>
                                        </div>
                                    <% } %>
                                </td>
                                <td style="text-align: center;">
                                    <a href="${pageContext.request.contextPath}/audit/detail?auditLogId=<%= log.getLogId() %>" 
                                       class="btn-audit-outline" 
                                       style="padding: 5px 10px; font-size: 12px;"
                                       title="Xem toàn bộ thông tin bản ghi">
                                        Chi tiết
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 48px 20px;">
                                    <div style="font-size: 40px; color: #cbd5e1; margin-bottom: 12px;">
                                        <i class="fa-solid fa-folder-open"></i>
                                    </div>
                                    <h4 style="margin: 0 0 6px 0; color: #334155; font-size: 16px;">Không tìm thấy bản ghi kiểm toán phù hợp</h4>
                                    <p style="margin: 0; color: #94a3b8; font-size: 13px;">Hãy thử điều chỉnh lại bộ lọc đối tượng, người thực hiện hoặc khoảng thời gian tra cứu.</p>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer -->
                <div class="audit-pagination-bar">
                    <div class="pagination-info">
                        Hiển thị <strong><%= auditLogs != null ? auditLogs.size() : 0 %></strong> trên tổng số <strong><%= totalItems %></strong> sự kiện kiểm toán
                    </div>
                    <div class="pagination-pages">
                        <% if (currentPage > 1) { %>
                            <a class="page-btn" href="${pageContext.request.contextPath}/audit/list?<%= baseFilterQuery %>&entityType=<%= java.net.URLEncoder.encode(entityTypeParam, "UTF-8") %>&page=<%= currentPage - 1 %>">
                                <i class="fa-solid fa-chevron-left"></i>
                            </a>
                        <% } else { %>
                            <span class="page-btn disabled"><i class="fa-solid fa-chevron-left"></i></span>
                        <% } %>

                        <%
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);
                            for (int p = startPage; p <= endPage; p++) {
                        %>
                            <a class="page-btn <%= p == currentPage ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/audit/list?<%= baseFilterQuery %>&entityType=<%= java.net.URLEncoder.encode(entityTypeParam, "UTF-8") %>&page=<%= p %>">
                                <%= p %>
                            </a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                            <a class="page-btn" href="${pageContext.request.contextPath}/audit/list?<%= baseFilterQuery %>&entityType=<%= java.net.URLEncoder.encode(entityTypeParam, "UTF-8") %>&page=<%= currentPage + 1 %>">
                                <i class="fa-solid fa-chevron-right"></i>
                            </a>
                        <% } else { %>
                            <span class="page-btn disabled"><i class="fa-solid fa-chevron-right"></i></span>
                        <% } %>
                    </div>
                </div>

            </div>

        </div>
    </main>
</div>

<script>
function formatDate(d) {
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return year + '-' + month + '-' + day;
}

// Preset: This Quarter (Quý này - rất quan trọng để đối soát cuối quý)
function setQuarterPreset() {
    const now = new Date();
    const currentMonth = now.getMonth(); // 0-11
    const quarterStartMonth = Math.floor(currentMonth / 3) * 3;
    const startDate = new Date(now.getFullYear(), quarterStartMonth, 1);
    const endDate = new Date(now.getFullYear(), quarterStartMonth + 3, 0);

    document.getElementById('filterFromDate').value = formatDate(startDate);
    document.getElementById('filterToDate').value = formatDate(endDate);
    document.getElementById('auditFilterForm').submit();
}

function setThisMonthPreset() {
    const now = new Date();
    const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    document.getElementById('filterFromDate').value = formatDate(startDate);
    document.getElementById('filterToDate').value = formatDate(endDate);
    document.getElementById('auditFilterForm').submit();
}

function setDaysPreset(days) {
    const now = new Date();
    const past = new Date();
    past.setDate(now.getDate() - days);

    document.getElementById('filterFromDate').value = formatDate(past);
    document.getElementById('filterToDate').value = formatDate(now);
    document.getElementById('auditFilterForm').submit();
}

function setTodayPreset() {
    const today = formatDate(new Date());
    document.getElementById('filterFromDate').value = today;
    document.getElementById('filterToDate').value = today;
    document.getElementById('auditFilterForm').submit();
}

function clearDatePresets() {
    document.getElementById('filterFromDate').value = '';
    document.getElementById('filterToDate').value = '';
    document.getElementById('auditFilterForm').submit();
}
</script>
</body>
</html>
