<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cơ cấu Tổ chức Kinh doanh | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Organization Hierarchy & Data Scoping Architecture
           ========================================================================== */
        :root {
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-primary-light: #eff6ff;
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

        .org-page-container {
            max-width: 1380px;
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
            color: var(--crm-primary);
            font-weight: 600;
        }

        /* Hero Header */
        .org-hero-header {
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

        .org-hero-info h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            gap: 12px;
            letter-spacing: -0.02em;
        }
        .org-hero-info h1 i {
            color: var(--crm-primary);
            font-size: 22px;
        }
        .org-hero-desc {
            font-size: 14px;
            color: var(--crm-text-muted);
            margin: 0;
            max-width: 820px;
            line-height: 1.5;
        }

        .org-hero-actions {
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
            font-size: 13.5px;
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
        .exec-kpi-icon.blue { background: #eff6ff; color: #2563eb; }
        .exec-kpi-icon.emerald { background: #ecfdf5; color: #059669; }
        .exec-kpi-icon.amber { background: #fffbeb; color: #d97706; }
        .exec-kpi-icon.purple { background: #faf5ff; color: #7c3aed; }

        .exec-kpi-content {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .exec-kpi-label {
            font-size: 12.5px;
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

        /* Policy & Backlog Callout */
        .org-policy-callout {
            background: linear-gradient(135deg, #eff6ff 0%, #f0fdf4 100%);
            border: 1px solid #bfdbfe;
            border-left: 4px solid #2563eb;
            border-radius: 0 var(--crm-radius-md) var(--crm-radius-md) 0;
            padding: 16px 20px;
            margin-bottom: 24px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 16px;
        }
        .policy-rule-box {
            display: flex;
            gap: 10px;
            font-size: 13px;
            color: #1e3a8a;
            line-height: 1.45;
        }
        .policy-rule-box i {
            font-size: 16px;
            color: #2563eb;
            margin-top: 2px;
            flex-shrink: 0;
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

        /* 2-Column Main Workspace */
        .org-workspace-grid {
            display: grid;
            grid-template-columns: 1.15fr 1fr;
            gap: 24px;
            align-items: start;
        }
        @media (max-width: 1080px) {
            .org-workspace-grid {
                grid-template-columns: 1fr;
            }
        }

        .org-col-stack {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* Generic Card */
        .exec-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            box-shadow: var(--crm-shadow-sm);
            overflow: hidden;
        }
        .exec-card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--crm-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
        }
        .exec-card-header h2 {
            font-size: 16px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .exec-card-header h2 i {
            color: var(--crm-primary);
        }
        .exec-card-body {
            padding: 24px;
        }

        /* Tree View Styling */
        .tree-scroll-container {
            max-height: 640px;
            overflow-y: auto;
            padding-right: 6px;
        }

        .tree-node-wrapper {
            position: relative;
        }

        .tree-node-item {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            padding: 14px 16px;
            margin-bottom: 12px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            transition: all 0.2s ease;
            position: relative;
        }
        .tree-node-item:hover {
            border-color: #2563eb;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.08);
            transform: translateX(2px);
        }
        .tree-node-item.is-root {
            border-left: 4px solid var(--crm-primary);
            background: #ffffff;
        }
        .tree-node-item.is-level-1 {
            border-left: 4px solid #2563eb;
            background: #fafcff;
        }
        .tree-node-item.is-level-2 {
            border-left: 4px solid #d97706;
            background: #fffdfa;
        }
        .tree-node-item.is-level-deep {
            border-left: 4px solid #7c3aed;
            background: #fdfcff;
        }

        .tree-node-left {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            flex: 1;
            min-width: 240px;
        }

        .tree-node-folder-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
            background: #eff6ff;
            color: #1e3a8a;
            border: 1px solid #dbeafe;
        }

        .tree-node-meta h3 {
            font-size: 15px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 5px 0;
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .badge-team-id {
            font-family: monospace;
            font-size: 11px;
            font-weight: 600;
            padding: 2px 6px;
            background: #f1f5f9;
            color: #475569;
            border-radius: 4px;
            border: 1px solid #e2e8f0;
        }

        .badge-geo-region {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11.5px;
            font-weight: 600;
            padding: 2px 8px;
            background: #eff6ff;
            color: #1d4ed8;
            border-radius: 20px;
            border: 1px solid #bfdbfe;
        }

        .tree-sub-details {
            font-size: 12.5px;
            color: var(--crm-text-body);
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            align-items: center;
        }
        .tree-sub-leader {
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .tree-sub-members {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: var(--crm-text-muted);
        }

        .tree-node-actions {
            display: flex;
            gap: 6px;
            align-items: center;
        }

        .btn-tree-action {
            padding: 6px 10px;
            font-size: 12px;
            font-weight: 600;
            border-radius: var(--crm-radius-sm);
            border: 1px solid var(--crm-border);
            background: #ffffff;
            color: var(--crm-text-body);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.15s ease;
            text-decoration: none;
        }
        .btn-tree-action:hover {
            border-color: #2563eb;
            color: #2563eb;
            background: #f8fafc;
        }
        .btn-tree-action.primary {
            background: #eff6ff;
            border-color: #bfdbfe;
            color: #1e3a8a;
        }
        .btn-tree-action.primary:hover {
            background: #dbeafe;
        }

        /* Tree Indentation Lines */
        .tree-children-container {
            margin-left: 24px;
            padding-left: 14px;
            border-left: 2px solid #e2e8f0;
            position: relative;
        }
        .tree-children-container.level-2 {
            border-left-style: dashed;
            border-left-color: #cbd5e1;
        }

        /* Form Controls */
        .exec-form-group {
            margin-bottom: 18px;
        }
        .exec-form-group label {
            display: block;
            font-size: 13.5px;
            font-weight: 600;
            color: var(--crm-text-heading);
            margin-bottom: 6px;
        }
        .exec-form-group label .req {
            color: #dc2626;
            margin-left: 2px;
        }

        .exec-input-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            font-size: 13.5px;
            color: var(--crm-text-heading);
            background: #ffffff;
            transition: all 0.15s ease;
            box-sizing: border-box;
        }
        .exec-input-control:focus {
            border-color: #2563eb;
            outline: none;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .exec-field-hint {
            font-size: 12px;
            color: var(--crm-text-muted);
            margin-top: 5px;
            line-height: 1.4;
        }

        /* Quick Region Chips */
        .region-chips-wrapper {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 8px;
        }
        .region-chip {
            padding: 3px 10px;
            font-size: 12px;
            border-radius: 14px;
            background: #f1f5f9;
            color: #334155;
            border: 1px solid #e2e8f0;
            cursor: pointer;
            transition: all 0.15s ease;
            user-select: none;
        }
        .region-chip:hover {
            background: #eff6ff;
            border-color: #93c5fd;
            color: #1d4ed8;
        }

        /* Member Table Roster */
        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }
        .roster-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            text-align: left;
        }
        .roster-table th {
            background: #f8fafc;
            color: var(--crm-text-muted);
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 12px 16px;
            border-bottom: 1px solid var(--crm-border);
            white-space: nowrap;
        }
        .roster-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13.5px;
            color: var(--crm-text-body);
            vertical-align: middle;
        }
        .roster-table tbody tr:hover td {
            background-color: #f8fafc;
        }

        .user-avatar-initial {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #eff6ff;
            color: #2563eb;
            font-weight: 700;
            font-size: 13px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid #bfdbfe;
            margin-right: 8px;
        }

        /* Transfer workflow box */
        .transfer-workflow-box {
            background: linear-gradient(135deg, #f8fafc 0%, #eff6ff 100%);
            border: 1px solid #bfdbfe;
            border-radius: var(--crm-radius-md);
            padding: 20px;
        }
        .workflow-step-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 700;
            color: #1e3a8a;
            background: #dbeafe;
            padding: 2px 8px;
            border-radius: 12px;
            margin-bottom: 8px;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container org-page-container">
            
            <!-- Breadcrumb Navigation -->
            <nav class="exec-breadcrumb" aria-label="Đường dẫn">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> CRM</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span>Hệ thống & Quản trị</span>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current">Cơ cấu Tổ chức Kinh doanh</span>
            </nav>

            <!-- Page Hero Header -->
            <div class="org-hero-header">
                <div class="org-hero-info">
                    <h1>
                        <i class="fa-solid fa-sitemap"></i>
                        Cơ cấu Tổ chức Kinh doanh & Phân cấp Cây Đội ngũ
                    </h1>
                    <p class="org-hero-desc">
                        Khai báo cơ cấu cây tổ chức kinh doanh, phân định khu vực địa lý và bổ nhiệm trưởng nhóm để hệ thống tự động xác định phạm vi dữ liệu (Data Scoping) cho từng cấp bậc quản lý.
                    </p>
                </div>
                <div class="org-hero-actions">
                    <button type="button" class="btn-exec-primary" onclick="resetTeamForm(); document.getElementById('teamFormCard').scrollIntoView({ behavior: 'smooth' });">
                        <i class="fa-solid fa-plus"></i> Khai báo nhóm mới
                    </button>
                    <button type="button" class="btn-exec-secondary" onclick="document.getElementById('transferSectionCard').scrollIntoView({ behavior: 'smooth' });">
                        <i class="fa-solid fa-right-left"></i> Điều chuyển nhân sự
                    </button>
                </div>
            </div>

            <!-- Backlog Policy Rules Callout -->
            <div class="org-policy-callout">
                <div class="policy-rule-box">
                    <i class="fa-solid fa-folder-tree"></i>
                    <div>
                        <strong>Cấu trúc cây phân cấp:</strong>
                        Nhóm kinh doanh tổ chức theo mô hình cây Cha - Con; mỗi nhóm có đúng 1 Trưởng nhóm chịu trách nhiệm.
                    </div>
                </div>
                <div class="policy-rule-box">
                    <i class="fa-solid fa-user-check"></i>
                    <div>
                        <strong>Trực thuộc duy nhất:</strong>
                        Mỗi nhân viên thuộc đúng một nhóm tại một thời điểm (`users.team_id`), đảm bảo trách nhiệm và KPI rõ ràng.
                    </div>
                </div>
                <div class="policy-rule-box">
                    <i class="fa-solid fa-shield-halved"></i>
                    <div>
                        <strong>Phạm vi Data Scope bám cây thật:</strong>
                        Trưởng nhóm nhìn thấy dữ liệu của nhóm mình và tự động kế thừa toàn bộ các nhóm con cấp dưới.
                    </div>
                </div>
                <div class="policy-rule-box">
                    <i class="fa-solid fa-map-location-dot"></i>
                    <div>
                        <strong>Địa bàn & Khu vực:</strong>
                        Khai báo khu vực địa lý để gán địa bàn kinh doanh, hỗ trợ chia địa bàn và chăm sóc khách hàng theo vùng miền.
                    </div>
                </div>
            </div>

            <!-- Toast / Alert Feedback Banners -->
            <c:if test="${param.success == 'update'}">
                <div class="exec-alert success" id="alert-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <div>
                        <strong>Thành công!</strong> Đã cập nhật cơ cấu nhóm kinh doanh và đồng bộ tài khoản Trưởng nhóm vào CSDL.
                    </div>
                    <button type="button" class="exec-alert-close" onclick="this.parentElement.remove()">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.success == 'transfer'}">
                <div class="exec-alert success" id="alert-transfer-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <div>
                        <strong>Điều chuyển thành công!</strong> Đã cập nhật nhóm kinh doanh của nhân viên (`users.team_id`) và tự động điều chỉnh Data Scoping.
                    </div>
                    <button type="button" class="exec-alert-close" onclick="this.parentElement.remove()">&times;</button>
                </div>
            </c:if>
            <c:if test="${not empty errors}">
                <div class="exec-alert error" id="alert-error">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <div>
                        <strong>Không thể lưu thay đổi:</strong>
                        <ul style="margin: 6px 0 0 16px; padding: 0;">
                            <c:forEach var="err" items="${errors}">
                                <li><c:out value="${err}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                    <button type="button" class="exec-alert-close" onclick="this.parentElement.remove()">&times;</button>
                </div>
            </c:if>

            <!-- Executive KPI Metric Stat Cards -->
            <div class="exec-kpi-grid">
                <!-- KPI 1: Total Teams -->
                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon blue">
                        <i class="fa-solid fa-sitemap"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Tổng nhóm kinh doanh</span>
                        <span class="exec-kpi-value">${teams.size()}</span>
                        <span class="exec-kpi-sub">Định hình trong cây tổ chức</span>
                    </div>
                </div>

                <!-- KPI 2: Leader Assignment -->
                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon emerald">
                        <i class="fa-solid fa-user-tie"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Đã bổ nhiệm Trưởng nhóm</span>
                        <c:set var="leadCount" value="0"/>
                        <c:forEach var="t" items="${teams}">
                            <c:if test="${not empty t.leaderId}">
                                <c:set var="leadCount" value="${leadCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        <span class="exec-kpi-value">${leadCount} / ${teams.size()}</span>
                        <span class="exec-kpi-sub">Mỗi nhóm có 1 trưởng nhóm</span>
                    </div>
                </div>

                <!-- KPI 3: Geographic Coverage -->
                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon amber">
                        <i class="fa-solid fa-map-location-dot"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Khu vực địa lý (Regions)</span>
                        <span class="exec-kpi-value" style="color: #d97706;">Đã phân bổ</span>
                        <span class="exec-kpi-sub">Miền Bắc, Trung, Nam, Toàn quốc</span>
                    </div>
                </div>

                <!-- KPI 4: Data Scope Protection -->
                <div class="exec-kpi-card">
                    <div class="exec-kpi-icon purple">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <div class="exec-kpi-content">
                        <span class="exec-kpi-label">Cơ chế Data Scoping</span>
                        <span class="exec-kpi-value" style="color: #7c3aed; font-size: 17px;">Bám cây tổ chức</span>
                        <span class="exec-kpi-sub">Bao quát nhóm & nhóm con</span>
                    </div>
                </div>
            </div>

            <!-- Main Interactive Workspace -->
            <div class="org-workspace-grid">
                
                <!-- LEFT COLUMN: Tree Hierarchy View & Team Members Roster -->
                <div class="org-col-stack">
                    
                    <!-- CARD: Hierarchical Tree of Business Teams -->
                    <div class="exec-card">
                        <div class="exec-card-header">
                            <h2>
                                <i class="fa-solid fa-folder-tree"></i>
                                Cây Phân cấp Nhóm Kinh doanh
                            </h2>
                            <div style="font-size: 13px; color: var(--crm-text-muted);">
                                <span>Phân tầng Cha - Con</span>
                            </div>
                        </div>
                        <div class="exec-card-body" style="padding: 16px;">
                            <div class="tree-scroll-container" id="treeViewContainer">
                                <!-- Hierarchical Rendering -->
                                <c:forEach var="root" items="${teams}">
                                    <c:if test="${empty root.parentTeamId || root.parentTeamId == 0}">
                                        
                                        <!-- Level 0: Root Team -->
                                        <div class="tree-node-wrapper">
                                            <div class="tree-node-item is-root">
                                                <div class="tree-node-left">
                                                    <div class="tree-node-folder-icon">
                                                        <i class="fa-solid fa-building"></i>
                                                    </div>
                                                    <div class="tree-node-meta">
                                                        <h3>
                                                            <c:out value="${root.name}"/>
                                                            <span class="badge-team-id">ID: ${root.id}</span>
                                                            <c:if test="${not empty root.region}">
                                                                <span class="badge-geo-region">
                                                                    <i class="fa-solid fa-location-dot"></i> <c:out value="${root.region}"/>
                                                                </span>
                                                            </c:if>
                                                        </h3>
                                                        <div class="tree-sub-details">
                                                            <span class="tree-sub-leader">
                                                                <i class="fa-solid fa-user-tie" style="color: #1e3a8a;"></i>
                                                                <strong><c:out value="${root.leaderName != null ? root.leaderName : 'Chưa bổ nhiệm'}"/></strong>
                                                            </span>
                                                            <span class="tree-sub-members" id="memberCount_${root.id}">
                                                                <i class="fa-solid fa-users"></i> Đang tính...
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="tree-node-actions">
                                                    <button type="button" class="btn-tree-action" 
                                                            onclick="editTeamData(${root.id}, '<c:out value="${root.name}"/>', '${root.parentTeamId}', '${root.leaderId}', '<c:out value="${root.region}"/>', '<c:out value="${root.description}"/>')"
                                                            title="Sửa thông tin nhóm">
                                                        <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                    </button>
                                                    <button type="button" class="btn-tree-action primary" 
                                                            onclick="createChildTeam(${root.id}, '<c:out value="${root.name}"/>')"
                                                            title="Thêm nhóm con trực thuộc">
                                                        <i class="fa-solid fa-plus"></i> Thêm con
                                                    </button>
                                                    <button type="button" class="btn-tree-action" 
                                                            onclick="filterByTeam(${root.id})"
                                                            title="Xem thành viên">
                                                        <i class="fa-solid fa-users-viewfinder"></i>
                                                    </button>
                                                </div>
                                            </div>

                                            <!-- Sub-teams Level 1 -->
                                            <div class="tree-children-container">
                                                <c:forEach var="sub1" items="${teams}">
                                                    <c:if test="${sub1.parentTeamId == root.id}">
                                                        <div class="tree-node-item is-level-1">
                                                            <div class="tree-node-left">
                                                                <div class="tree-node-folder-icon" style="background: #faf5ff; color: #7c3aed; border-color: #e9d5ff;">
                                                                    <i class="fa-solid fa-users-line"></i>
                                                                </div>
                                                                <div class="tree-node-meta">
                                                                    <h3>
                                                                        <c:out value="${sub1.name}"/>
                                                                        <span class="badge-team-id">ID: ${sub1.id}</span>
                                                                        <c:if test="${not empty sub1.region}">
                                                                            <span class="badge-geo-region">
                                                                                <i class="fa-solid fa-location-dot"></i> <c:out value="${sub1.region}"/>
                                                                            </span>
                                                                        </c:if>
                                                                    </h3>
                                                                    <div class="tree-sub-details">
                                                                        <span class="tree-sub-leader">
                                                                            <i class="fa-solid fa-user-tie" style="color: #7c3aed;"></i>
                                                                            <strong><c:out value="${sub1.leaderName != null ? sub1.leaderName : 'Chưa bổ nhiệm'}"/></strong>
                                                                        </span>
                                                                        <span class="tree-sub-members" id="memberCount_${sub1.id}">
                                                                            <i class="fa-solid fa-users"></i> Đang tính...
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="tree-node-actions">
                                                                <button type="button" class="btn-tree-action" 
                                                                        onclick="editTeamData(${sub1.id}, '<c:out value="${sub1.name}"/>', '${sub1.parentTeamId}', '${sub1.leaderId}', '<c:out value="${sub1.region}"/>', '<c:out value="${sub1.description}"/>')">
                                                                    <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                                </button>
                                                                <button type="button" class="btn-tree-action primary" 
                                                                        onclick="createChildTeam(${sub1.id}, '<c:out value="${sub1.name}"/>')">
                                                                    <i class="fa-solid fa-plus"></i> Thêm con
                                                                </button>
                                                                <button type="button" class="btn-tree-action" 
                                                                        onclick="filterByTeam(${sub1.id})">
                                                                    <i class="fa-solid fa-users-viewfinder"></i>
                                                                </button>
                                                            </div>
                                                        </div>

                                                        <!-- Sub-teams Level 2 -->
                                                        <div class="tree-children-container level-2">
                                                            <c:forEach var="sub2" items="${teams}">
                                                                <c:if test="${sub2.parentTeamId == sub1.id}">
                                                                    <div class="tree-node-item is-level-2">
                                                                        <div class="tree-node-left">
                                                                            <div class="tree-node-folder-icon" style="background: #fffbeb; color: #d97706; border-color: #fde68a;">
                                                                                <i class="fa-solid fa-user-group"></i>
                                                                            </div>
                                                                            <div class="tree-node-meta">
                                                                                <h3>
                                                                                    <c:out value="${sub2.name}"/>
                                                                                    <span class="badge-team-id">ID: ${sub2.id}</span>
                                                                                    <c:if test="${not empty sub2.region}">
                                                                                        <span class="badge-geo-region">
                                                                                            <i class="fa-solid fa-location-dot"></i> <c:out value="${sub2.region}"/>
                                                                                        </span>
                                                                                    </c:if>
                                                                                </h3>
                                                                                <div class="tree-sub-details">
                                                                                    <span class="tree-sub-leader">
                                                                                        <i class="fa-solid fa-user-tie" style="color: #d97706;"></i>
                                                                                        <strong><c:out value="${sub2.leaderName != null ? sub2.leaderName : 'Chưa bổ nhiệm'}"/></strong>
                                                                                    </span>
                                                                                    <span class="tree-sub-members" id="memberCount_${sub2.id}">
                                                                                        <i class="fa-solid fa-users"></i> Đang tính...
                                                                                    </span>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="tree-node-actions">
                                                                            <button type="button" class="btn-tree-action" 
                                                                                    onclick="editTeamData(${sub2.id}, '<c:out value="${sub2.name}"/>', '${sub2.parentTeamId}', '${sub2.leaderId}', '<c:out value="${sub2.region}"/>', '<c:out value="${sub2.description}"/>')">
                                                                                <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                                            </button>
                                                                            <button type="button" class="btn-tree-action" 
                                                                                    onclick="filterByTeam(${sub2.id})">
                                                                                <i class="fa-solid fa-users-viewfinder"></i>
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                </c:if>
                                                            </c:forEach>
                                                        </div>

                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                        </div>

                                    </c:if>
                                </c:forEach>
                                <c:if test="${empty teams}">
                                    <div style="text-align: center; color: var(--crm-text-muted); padding: 40px 20px;">
                                        <i class="fa-solid fa-sitemap" style="font-size: 38px; color: #cbd5e1; margin-bottom: 10px;"></i>
                                        <p>Chưa có nhóm kinh doanh nào được khai báo.</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- CARD: Member Roster per Team -->
                    <div class="exec-card" id="memberRosterCard">
                        <div class="exec-card-header">
                            <h2>
                                <i class="fa-solid fa-users"></i>
                                Danh sách Thành viên Thuộc Nhóm
                            </h2>
                            <div style="display: flex; gap: 8px; align-items: center;">
                                <label for="teamFilterSelect" style="font-size: 13px; color: var(--crm-text-muted); margin: 0;">Lọc nhóm:</label>
                                <select id="teamFilterSelect" class="exec-input-control" style="padding: 6px 12px; font-size: 13px; width: 200px;" onchange="renderMembersForTeam(this.value)">
                                    <option value="">-- Tất cả nhân viên --</option>
                                    <c:forEach var="t" items="${teams}">
                                        <option value="${t.id}">[ID: ${t.id}] <c:out value="${t.name}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="exec-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="roster-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 70px;">Mã NV</th>
                                            <th>Họ và tên</th>
                                            <th>Nhóm hiện tại</th>
                                            <th>Email</th>
                                            <th style="text-align: right;">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody id="memberRosterBody">
                                        <!-- Dynamically generated via JavaScript -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- RIGHT COLUMN: Form Khai báo / Cập nhật & Hub Điều chuyển -->
                <div class="org-col-stack">
                    
                    <!-- CARD: Form Khai báo / Hiệu chỉnh Nhóm kinh doanh -->
                    <div class="exec-card" id="teamFormCard">
                        <div class="exec-card-header">
                            <h2 id="formHeaderTitle">
                                <i class="fa-solid fa-folder-plus"></i>
                                Khai báo / Cập nhật Nhóm kinh doanh
                            </h2>
                            <button type="button" class="btn-exec-secondary" style="padding: 6px 12px; font-size: 12px;" onclick="resetTeamForm()">
                                <i class="fa-solid fa-rotate-left"></i> Làm mới
                            </button>
                        </div>
                        <div class="exec-card-body">
                            <form action="${pageContext.request.contextPath}/organization/teams/update" method="POST" id="teamEditForm">
                                <input type="hidden" id="teamId" name="teamId" value="">

                                <div class="exec-form-group">
                                    <label for="displayTeamId">Mã nhóm (ID)</label>
                                    <input type="text" id="displayTeamId" class="exec-input-control" readonly 
                                           style="background-color: #f8fafc; font-weight: 600; color: #64748b;"
                                           placeholder="Tự động sinh khi tạo mới">
                                </div>

                                <div class="exec-form-group">
                                    <label for="teamName">Tên nhóm kinh doanh <span class="req">*</span></label>
                                    <input type="text" id="teamName" name="teamName" class="exec-input-control" required
                                           placeholder="VD: Phòng Kinh doanh Miền Bắc, Nhóm Dự án 1...">
                                    <div class="exec-field-hint">Tên định danh duy nhất trong toàn hệ thống.</div>
                                </div>

                                <div class="exec-form-group">
                                    <label for="parentTeamId">Nhóm cấp trên trong cây (Parent Team)</label>
                                    <select id="parentTeamId" name="parentTeamId" class="exec-input-control">
                                        <option value="">(Không có - Nhóm cấp gốc cao nhất)</option>
                                        <c:forEach var="pt" items="${teams}">
                                            <option value="${pt.id}">[ID: ${pt.id}] <c:out value="${pt.name}"/></option>
                                        </c:forEach>
                                    </select>
                                    <div class="exec-field-hint">Quyết định quan hệ cây phân cấp và kế thừa dữ liệu cho Trưởng nhóm cấp trên.</div>
                                </div>

                                <div class="exec-form-group">
                                    <label for="leaderId">Trưởng nhóm (Team Leader) <span style="font-weight: normal; color: var(--crm-text-muted);">(Mỗi nhóm có 1 trưởng nhóm)</span></label>
                                    <select id="leaderId" name="leaderId" class="exec-input-control">
                                        <option value="">(Chưa bổ nhiệm)</option>
                                        <c:forEach var="u" items="${not empty leaderCandidates ? leaderCandidates : users}">
                                            <option value="${u.accountId}">
                                                <c:out value="${u.fullName}"/> (<c:out value="${u.email}"/>)
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <div class="exec-field-hint">
                                        Trưởng nhóm sẽ có quyền xem dữ liệu của nhóm mình và toàn bộ nhóm con trực thuộc.
                                    </div>
                                </div>

                                <div class="exec-form-group">
                                    <label for="region">Khu vực địa lý phụ trách (Region) <span class="req">*</span></label>
                                    <input type="text" id="region" name="region" class="exec-input-control" required
                                           placeholder="VD: Miền Bắc, Miền Trung, Miền Nam, Toàn quốc...">
                                    <!-- Quick selection chips -->
                                    <div class="region-chips-wrapper">
                                        <span class="region-chip" onclick="setRegionValue('Miền Bắc')"><i class="fa-solid fa-location-dot"></i> Miền Bắc</span>
                                        <span class="region-chip" onclick="setRegionValue('Miền Trung')"><i class="fa-solid fa-location-dot"></i> Miền Trung</span>
                                        <span class="region-chip" onclick="setRegionValue('Miền Nam')"><i class="fa-solid fa-location-dot"></i> Miền Nam</span>
                                        <span class="region-chip" onclick="setRegionValue('Hà Nội')"><i class="fa-solid fa-location-dot"></i> Hà Nội</span>
                                        <span class="region-chip" onclick="setRegionValue('TP. Hồ Chí Minh')"><i class="fa-solid fa-location-dot"></i> TP. HCM</span>
                                        <span class="region-chip" onclick="setRegionValue('Toàn quốc')"><i class="fa-solid fa-globe"></i> Toàn quốc</span>
                                    </div>
                                    <div class="exec-field-hint">Khai báo địa bàn phụ trách để liên kết dữ liệu khách hàng theo vùng miền.</div>
                                </div>

                                <div class="exec-form-group">
                                    <label for="description">Mô tả nhiệm vụ nhóm</label>
                                    <textarea id="description" name="description" class="exec-input-control" style="height: 70px;" 
                                              placeholder="Mô tả chức năng, đối tượng khách hàng mục tiêu hoặc địa bàn..."></textarea>
                                </div>

                                <div style="display: flex; gap: 10px; margin-top: 20px;">
                                    <button type="submit" class="btn-exec-primary" style="flex: 1; justify-content: center;" id="btnSubmitTeam">
                                        <i class="fa-solid fa-floppy-disk"></i> Lưu thông tin nhóm
                                    </button>
                                    <button type="button" class="btn-exec-secondary" onclick="resetTeamForm()">
                                        Làm mới
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- CARD: Hub Điều chuyển Nhân sự (Staff Transfer) -->
                    <div class="exec-card" id="transferSectionCard">
                        <div class="exec-card-header" style="background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);">
                            <h2>
                                <i class="fa-solid fa-right-left" style="color: #2563eb;"></i>
                                Điều chuyển Nhân viên sang Nhóm khác
                            </h2>
                            <span style="font-size: 12px; font-weight: 600; color: #2563eb; background: #eff6ff; padding: 2px 8px; border-radius: 12px;">
                                Duy nhất 1 nhóm / thời điểm
                            </span>
                        </div>
                        <div class="exec-card-body">
                            <form action="${pageContext.request.contextPath}/organization/teams/update" method="POST" id="transferForm" onsubmit="return validateTransferForm();">
                                <input type="hidden" name="action" value="transferUser">

                                <div class="transfer-workflow-box">
                                    
                                    <!-- Step 1: Chọn nhóm nguồn -->
                                    <div class="exec-form-group">
                                        <div class="workflow-step-badge">Bước 1</div>
                                        <label for="sourceTeamId">Chọn Nhóm nguồn (Nhóm hiện tại) <span class="req">*</span></label>
                                        <select id="sourceTeamId" name="sourceTeamId" class="exec-input-control" onchange="onSourceTeamSelected(this.value)" required>
                                            <option value="">-- Chọn nhóm hiện tại của nhân viên --</option>
                                            <c:forEach var="t" items="${teams}">
                                                <option value="${t.id}">[ID: ${t.id}] <c:out value="${t.name}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- Step 2: Chọn nhân viên trong nhóm nguồn -->
                                    <div class="exec-form-group">
                                        <div class="workflow-step-badge">Bước 2</div>
                                        <label for="transferUserId">Chọn Nhân viên cần chuyển <span class="req">*</span></label>
                                        <select id="transferUserId" name="transferUserId" class="exec-input-control" required>
                                            <option value="">-- Vui lòng chọn Nhóm nguồn trước --</option>
                                        </select>
                                        <div class="exec-field-hint">
                                            ⚠️ Nhân viên đang là Trưởng nhóm đương nhiệm sẽ không được phép điều chuyển trước khi bổ nhiệm Trưởng nhóm mới.
                                        </div>
                                    </div>

                                    <!-- Step 3: Chọn nhóm đích -->
                                    <div class="exec-form-group">
                                        <div class="workflow-step-badge">Bước 3</div>
                                        <label for="targetTeamId">Chọn Nhóm đích (Chuyển đến) <span class="req">*</span></label>
                                        <select id="targetTeamId" name="targetTeamId" class="exec-input-control" required>
                                            <option value="">-- Chọn nhóm đích tiếp nhận --</option>
                                            <c:forEach var="t" items="${teams}">
                                                <option value="${t.id}">[ID: ${t.id}] <c:out value="${t.name}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <button type="submit" class="btn-exec-primary" style="width: 100%; justify-content: center; margin-top: 10px;">
                                        <i class="fa-solid fa-arrow-right-arrow-left"></i> Xác nhận Điều chuyển Nhân sự
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                </div>

            </div>

        </div>
    </main>
</div>

<!-- Interactive Logic Scripts -->
<script>
    // In-memory accounts dataset from server
    var userAccounts = [
        <c:forEach var="u" items="${users}" varStatus="loop">
            {
                userId: ${u.accountId},
                fullName: '<c:out value="${u.fullName}"/>',
                email: '<c:out value="${u.email}"/>',
                teamId: ${u.teamId != null ? u.teamId : 'null'},
                teamName: '<c:out value="${u.teamName}"/>'
            }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];

    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/&/g, "&amp;")
                   .replace(/</g, "&lt;")
                   .replace(/>/g, "&gt;")
                   .replace(/"/g, "&quot;")
                   .replace(/'/g, "&#039;");
    }

    // Set region quick chip
    function setRegionValue(val) {
        var input = document.getElementById('region');
        if (input) {
            input.value = val;
            input.focus();
        }
    }

    // Calculate member counts for all team nodes in tree
    function updateTreeMemberCounts() {
        var counts = {};
        userAccounts.forEach(function(u) {
            if (u.teamId) {
                counts[u.teamId] = (counts[u.teamId] || 0) + 1;
            }
        });

        for (var tId in counts) {
            var el = document.getElementById('memberCount_' + tId);
            if (el) {
                el.innerHTML = '<i class="fa-solid fa-users"></i> ' + counts[tId] + ' thành viên';
            }
        }

        // Teams with 0 members
        document.querySelectorAll('[id^="memberCount_"]').forEach(function(el) {
            var id = el.id.replace('memberCount_', '');
            if (!counts[id]) {
                el.innerHTML = '<i class="fa-solid fa-users"></i> 0 thành viên';
            }
        });
    }

    // Render roster table
    function renderMembersForTeam(teamIdFilter) {
        var tbody = document.getElementById('memberRosterBody');
        if (!tbody) return;
        tbody.innerHTML = '';

        var filtered = userAccounts;
        if (teamIdFilter && teamIdFilter !== '') {
            var tid = parseInt(teamIdFilter);
            filtered = userAccounts.filter(function(u) {
                return u.teamId === tid;
            });
        }

        if (filtered.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: var(--crm-text-muted); padding: 30px;">Không có thành viên nào trong nhóm này.</td></tr>';
            return;
        }

        filtered.forEach(function(u) {
            var initial = u.fullName ? u.fullName.trim().charAt(0).toUpperCase() : 'U';
            var teamBadge = u.teamName 
                ? '<span class="badge-geo-region"><i class="fa-solid fa-users-line"></i> ' + escapeHtml(u.teamName) + '</span>'
                : '<span style="color: #94a3b8; font-size: 12.5px;">Chưa phân nhóm</span>';

            var tr = document.createElement('tr');
            tr.innerHTML = '<td><span class="badge-team-id">#' + u.userId + '</span></td>' +
                           '<td>' +
                               '<div style="display: flex; align-items: center;">' +
                                   '<span class="user-avatar-initial">' + initial + '</span>' +
                                   '<strong>' + escapeHtml(u.fullName) + '</strong>' +
                               '</div>' +
                           '</td>' +
                           '<td>' + teamBadge + '</td>' +
                           '<td style="color: var(--crm-text-muted); font-size: 13px;">' + escapeHtml(u.email) + '</td>' +
                           '<td style="text-align: right;">' +
                               '<button type="button" class="btn-tree-action" onclick="quickTransfer(' + u.userId + ', ' + (u.teamId ? u.teamId : 'null') + ')" title="Chuyển sang nhóm khác">' +
                                   '<i class="fa-solid fa-right-left"></i> Chuyển' +
                               '</button>' +
                           '</td>';
            tbody.appendChild(tr);
        });
    }

    function filterByTeam(teamId) {
        var sel = document.getElementById('teamFilterSelect');
        if (sel) {
            sel.value = teamId;
            renderMembersForTeam(teamId);
        }
        document.getElementById('memberRosterCard').scrollIntoView({ behavior: 'smooth' });
    }

    // Source team selected in Transfer form
    function onSourceTeamSelected(sourceTeamId) {
        var userSelect = document.getElementById('transferUserId');
        userSelect.innerHTML = '<option value="">-- Chọn nhân viên --</option>';
        if (!sourceTeamId) {
            userSelect.innerHTML = '<option value="">-- Vui lòng chọn Nhóm nguồn trước --</option>';
            return;
        }

        var sId = parseInt(sourceTeamId);
        var members = userAccounts.filter(function(u) {
            return u.teamId === sId;
        });

        if (members.length === 0) {
            var opt = document.createElement('option');
            opt.value = '';
            opt.textContent = '(Nhóm này hiện chưa có nhân sự nào)';
            userSelect.appendChild(opt);
        } else {
            members.forEach(function(u) {
                var opt = document.createElement('option');
                opt.value = u.userId;
                opt.textContent = u.fullName + ' (' + u.email + ')';
                userSelect.appendChild(opt);
            });
        }
    }

    function quickTransfer(userId, teamId) {
        if (!teamId) {
            alert('Nhân viên này hiện chưa thuộc nhóm nào. Vui lòng phân nhóm trong phần Quản lý tài khoản.');
            return;
        }
        var sourceSel = document.getElementById('sourceTeamId');
        sourceSel.value = teamId;
        onSourceTeamSelected(teamId);

        var userSel = document.getElementById('transferUserId');
        userSel.value = userId;

        document.getElementById('transferSectionCard').scrollIntoView({ behavior: 'smooth' });
    }

    function validateTransferForm() {
        var sourceId = document.getElementById('sourceTeamId').value;
        var targetId = document.getElementById('targetTeamId').value;
        if (sourceId && targetId && sourceId === targetId) {
            alert('Nhóm đích phải khác nhóm nguồn hiện tại.');
            return false;
        }
        return true;
    }

    // Edit Team Data into Form
    function editTeamData(id, name, parentId, leaderId, region, description) {
        document.getElementById('formHeaderTitle').innerHTML = '<i class="fa-solid fa-pen-to-square"></i> Hiệu chỉnh: ' + escapeHtml(name);
        document.getElementById('teamId').value = id;
        document.getElementById('displayTeamId').value = '#' + id;
        document.getElementById('teamName').value = name;
        document.getElementById('parentTeamId').value = parentId && parentId !== 'null' ? parentId : '';
        document.getElementById('leaderId').value = leaderId && leaderId !== 'null' ? leaderId : '';
        document.getElementById('region').value = region && region !== 'null' ? region : '';
        document.getElementById('description').value = description && description !== 'null' ? description : '';

        document.getElementById('btnSubmitTeam').innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi Nhóm';
        document.getElementById('teamFormCard').scrollIntoView({ behavior: 'smooth' });
    }

    // Create Child Team
    function createChildTeam(parentTeamId, parentTeamName) {
        resetTeamForm();
        document.getElementById('parentTeamId').value = parentTeamId;
        document.getElementById('formHeaderTitle').innerHTML = '<i class="fa-solid fa-folder-plus"></i> Thêm nhóm con cho: ' + escapeHtml(parentTeamName);
        document.getElementById('teamFormCard').scrollIntoView({ behavior: 'smooth' });
    }

    // Reset Form
    function resetTeamForm() {
        document.getElementById('formHeaderTitle').innerHTML = '<i class="fa-solid fa-folder-plus"></i> Khai báo Nhóm kinh doanh mới';
        document.getElementById('teamId').value = '';
        document.getElementById('displayTeamId').value = 'Tự động sinh';
        document.getElementById('teamName').value = '';
        document.getElementById('parentTeamId').value = '';
        document.getElementById('leaderId').value = '';
        document.getElementById('region').value = '';
        document.getElementById('description').value = '';
        document.getElementById('btnSubmitTeam').innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Khai báo nhóm';
    }

    // Initialize on page ready
    document.addEventListener('DOMContentLoaded', function() {
        updateTreeMemberCounts();
        renderMembersForTeam('');
    });
</script>
</body>
</html>
