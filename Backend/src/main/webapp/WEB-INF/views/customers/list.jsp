<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <title>Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        /* Royal Navy & Amber Design System - Enterprise Luxury CRM */
        :root {
            --crm-primary: #1e3a8a;           /* Royal Navy (Blue 900) */
            --crm-primary-hover: #172554;     /* Navy 950 */
            --crm-primary-active: #0f172a;    /* Slate 900 */
            --crm-primary-light: #eff6ff;     /* Blue 50 */
            --crm-primary-border: #bfdbfe;    /* Blue 200 */
            --crm-accent: #d97706;            /* Warm Amber Gold */
            --crm-accent-hover: #b45309;      /* Amber 700 */
            --crm-accent-light: #fffbeb;      /* Amber 50 */
            --crm-accent-border: #fde68a;     /* Amber 200 */
            --crm-surface: #ffffff;
            --crm-bg: #f8fafc;
            --crm-border: #e2e8f0;
            --crm-border-hover: #cbd5e1;
            --crm-text-main: #0f172a;
            --crm-text-muted: #64748b;
            --crm-radius: 12px;
            --crm-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05), 0 1px 2px rgba(15, 23, 42, 0.03);
            --crm-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.06), 0 2px 4px -2px rgba(15, 23, 42, 0.04);
            --crm-shadow-lg: 0 10px 15px -3px rgba(30, 58, 138, 0.08), 0 4px 6px -4px rgba(15, 23, 42, 0.04);
        }

        .customer-page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .page-title-group h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--crm-text-main);
            letter-spacing: -0.02em;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .page-title-group p {
            color: var(--crm-text-muted);
            font-size: 14px;
            margin: 4px 0 0 0;
        }

        /* Modern Action Buttons */
        .page-actions-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            align-items: center;
        }

        .btn-modern-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            padding: 9px 18px;
            font-weight: 600;
            font-size: 13.5px;
            border-radius: 10px;
            border: none;
            box-shadow: 0 4px 14px rgba(30, 58, 138, 0.28);
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-modern-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(30, 58, 138, 0.38);
            background: linear-gradient(135deg, #172554 0%, #1d4ed8 100%);
        }

        .btn-modern-secondary {
            background: #ffffff;
            color: #334155 !important;
            border: 1px solid var(--crm-border);
            padding: 8px 14px;
            font-weight: 500;
            font-size: 13.5px;
            border-radius: 10px;
            box-shadow: var(--crm-shadow-sm);
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-modern-secondary:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: var(--crm-primary-hover) !important;
            transform: translateY(-1px);
        }

        /* Filter Panel Card */
        .filter-panel-card {
            background: #ffffff;
            border-radius: var(--crm-radius);
            border: 1px solid var(--crm-border);
            padding: 20px;
            margin-bottom: 24px;
            box-shadow: var(--crm-shadow-sm);
            transition: box-shadow 0.2s ease;
        }

        .filter-grid-row {
            display: grid;
            grid-template-columns: 2.2fr 1fr 1.2fr 1fr 1fr 1.2fr;
            gap: 12px;
            align-items: center;
            width: 100%;
        }

        @media (max-width: 1200px) {
            .filter-grid-row {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        @media (max-width: 768px) {
            .filter-grid-row {
                grid-template-columns: 1fr;
            }
        }

        .input-with-icon {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-with-icon i {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 14px;
        }
        .input-with-icon input {
            padding-left: 38px !important;
        }

        .custom-filter-input, .custom-filter-select {
            width: 100%;
            height: 40px;
            padding: 8px 14px;
            border: 1px solid var(--crm-border);
            border-radius: 10px;
            background: #f8fafc;
            color: var(--crm-text-main);
            font-size: 13.5px;
            outline: none;
            transition: all 0.2s ease;
            box-sizing: border-box;
        }
        .custom-filter-input:focus, .custom-filter-select:focus {
            background: #ffffff;
            border-color: var(--crm-primary);
            box-shadow: 0 0 0 3px rgba(30, 58, 138, 0.12);
        }

        /* Modern Table Card */
        .table-panel-card {
            background: #ffffff;
            border-radius: var(--crm-radius);
            border: 1px solid var(--crm-border);
            box-shadow: var(--crm-shadow-md);
            overflow: hidden;
        }

        .table-panel-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--crm-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
        }
        .table-panel-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--crm-text-main);
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0;
        }
        .table-badge-counter {
            background: var(--crm-primary-light);
            color: var(--crm-primary);
            font-size: 12px;
            font-weight: 600;
            padding: 3px 11px;
            border-radius: 20px;
            border: 1px solid var(--crm-primary-border);
        }

        /* Modernized Table */
        .modern-crm-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            text-align: left;
        }
        .modern-crm-table thead th {
            background: #f8fafc;
            color: #475569;
            font-size: 12.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 14px 18px;
            border-bottom: 1px solid var(--crm-border);
            white-space: nowrap;
        }
        .modern-crm-table tbody tr {
            transition: background-color 0.15s ease;
        }
        .modern-crm-table tbody tr:hover {
            background-color: #f8fafc;
        }
        .modern-crm-table tbody td {
            padding: 16px 18px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13.5px;
            color: #334155;
            vertical-align: middle;
        }
        .modern-crm-table tbody tr:last-child td {
            border-bottom: none;
        }

        /* Company cell style */
        .company-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .company-avatar {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            color: #1e3a8a;
            font-weight: 700;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            border: 1px solid #93c5fd;
        }
        .company-name {
            font-weight: 600;
            color: #0f172a;
            line-height: 1.4;
        }

        /* Status Badges */
        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.01em;
            white-space: nowrap;
        }
        .status-pill::before {
            content: "";
            width: 6px;
            height: 6px;
            border-radius: 50%;
        }
        .status-potential { background: #eff6ff; color: #1e40af; border: 1px solid #bfdbfe; }
        .status-potential::before { background: #3b82f6; }
        .status-dealing { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .status-dealing::before { background: #d97706; }
        .status-customer { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        .status-customer::before { background: #10b981; }
        .status-active { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
        .status-active::before { background: #22c55e; }
        .status-stopped { background: #f8fafc; color: #64748b; border: 1px solid #e2e8f0; }
        .status-stopped::before { background: #94a3b8; }

        /* Action Icon Buttons */
        .action-btn-group {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            justify-content: center;
        }
        .action-icon-btn {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #64748b;
            background: #f8fafc;
            border: 1px solid var(--crm-border);
            transition: all 0.15s ease;
            text-decoration: none;
            font-size: 13px;
        }
        .action-icon-btn:hover {
            color: var(--crm-primary);
            background: #ffffff;
            border-color: var(--crm-primary-border);
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(30, 58, 138, 0.1);
        }
        .action-360-btn {
            height: 32px;
            padding: 0 10px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: #1e3a8a;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            font-size: 12.5px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .action-360-btn:hover {
            background: #dbeafe;
            color: #172554;
            transform: translateY(-1px);
        }

        /* Empty state */
        .modern-empty-state {
            padding: 60px 20px;
            text-align: center;
        }
        .empty-icon-wrap {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: #f1f5f9;
            color: #94a3b8;
            font-size: 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
        }

        /* Pagination custom styles */
        .pagination .page-item.disabled {
            opacity: 0.5;
            pointer-events: none;
        }
        .pagination .page-link.inactive-link {
            background: white;
            border: 1px solid var(--crm-border);
            color: #475569;
        }
        .pagination .page-item.active .page-link {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%) !important;
            border-color: #1e3a8a !important;
            color: #ffffff !important;
            box-shadow: 0 2px 6px rgba(30, 58, 138, 0.25);
        }
    </style>
</head>

<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
        <main class="main-content">
            <div class="content-container" style="max-width: 1440px; margin: 0 auto; padding: 24px 32px;">
                <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px; font-size: 13px;">
                    <a href="${pageContext.request.contextPath}/dashboard" style="color: var(--crm-text-muted);"><i class="fas fa-home"></i> Trang chủ</a>
                    <span style="color: #cbd5e1; margin: 0 6px;">/</span>
                    <span class="breadcrumb-current" style="color: var(--crm-primary); font-weight: 600;">Khách hàng</span>
                </nav>

                <!-- Page Header -->
                <div class="customer-page-header">
                    <div class="page-title-group">
                        <h1>
                            <i class="fas fa-building" style="color: var(--crm-primary); font-size: 22px;"></i>
                            Khách hàng
                        </h1>
                        <p>Quản lý tập trung, tra cứu và chăm sóc hồ sơ dữ liệu khách hàng.</p>
                    </div>
                    <div class="page-actions-group">
                        <button class="btn-modern-primary" onclick="openCustomerModal()">
                            <i class="fas fa-plus"></i> Thêm khách hàng
                        </button>
                        <a href="${pageContext.request.contextPath}/customers/import" class="btn-modern-secondary" title="Nhập danh sách khách hàng từ Excel">
                            <i class="fas fa-file-import" style="color: #059669;"></i> Import Excel
                        </a>
                        <a href="${pageContext.request.contextPath}/customers/duplicates" class="btn-modern-secondary" title="Danh sách khách hàng trùng lặp">
                            <i class="fas fa-copy" style="color: #d97706;"></i> Khách trùng
                        </a>
                        <a href="${pageContext.request.contextPath}/customers/merge" class="btn-modern-secondary" title="Gộp khách hàng">
                            <i class="fas fa-compress-alt" style="color: #7c3aed;"></i> Gộp KH
                        </a>
                        <a href="${pageContext.request.contextPath}/customers/export?keyword=<c:out value='${keyword}'/>&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>" class="btn-modern-secondary">
                            <i class="fas fa-file-export" style="color: #0284c7;"></i> Xuất CSV
                        </a>
                    </div>
                </div>

                <!-- Filter Panel Card -->
                <form id="filterForm" action="${pageContext.request.contextPath}/customers" method="get" class="filter-panel-card">
                    <!-- Row 1: Filters -->
                    <div class="filter-grid-row">
                        <!-- Keyword Search -->
                        <div class="input-with-icon">
                            <i class="fas fa-search"></i>
                            <input class="custom-filter-input" name="keyword" type="search" placeholder="Tìm tên KH, MST, SĐT liên hệ..." value="<c:out value='${keyword}'/>">
                        </div>

                        <!-- Status Filter -->
                        <div>
                            <select name="status" class="custom-filter-select">
                                <option value="">-- Trạng thái --</option>
                                <option value="POTENTIAL" ${status == 'POTENTIAL' ? 'selected' : ''}>Tiềm năng</option>
                                <option value="DEALING" ${status == 'DEALING' ? 'selected' : ''}>Đang giao dịch</option>
                                <option value="CUSTOMER" ${status == 'CUSTOMER' || status == 'Khách hàng' ? 'selected' : ''}>Khách hàng</option>
                                <option value="ACTIVE" ${status == 'ACTIVE' || status == 'Hoạt động' ? 'selected' : ''}>Hoạt động</option>
                                <option value="STOPPED" ${status == 'STOPPED' || status == 'Ngừng hợp tác' ? 'selected' : ''}>Ngừng hợp tác</option>
                            </select>
                        </div>

                        <!-- Industry Filter -->
                        <div>
                            <select name="industry" class="custom-filter-select">
                                <option value="">-- Ngành nghề --</option>
                                <option value="Công nghệ thông tin" ${industry == 'Công nghệ thông tin' ? 'selected' : ''}>Công nghệ thông tin</option>
                                <option value="Bất động sản" ${industry == 'Bất động sản' ? 'selected' : ''}>Bất động sản</option>
                                <option value="Tài chính / Ngân hàng" ${industry == 'Tài chính / Ngân hàng' ? 'selected' : ''}>Tài chính / Ngân hàng</option>
                                <option value="Sản xuất" ${industry == 'Sản xuất' ? 'selected' : ''}>Sản xuất</option>
                                <option value="Thương mại / Bán lẻ" ${industry == 'Thương mại / Bán lẻ' ? 'selected' : ''}>Thương mại / Bán lẻ</option>
                                <option value="Y tế / Dược phẩm" ${industry == 'Y tế / Dược phẩm' ? 'selected' : ''}>Y tế / Dược phẩm</option>
                                <option value="Giáo dục" ${industry == 'Giáo dục' ? 'selected' : ''}>Giáo dục</option>
                                <option value="Khác" ${industry == 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>

                        <!-- Size / CompanySize Filter -->
                        <div>
                            <select name="companySize" class="custom-filter-select">
                                <option value="">-- Quy mô --</option>
                                <option value="Dưới 10" ${companySize == 'Dưới 10' || size == 'Dưới 10' ? 'selected' : ''}>Dưới 10</option>
                                <option value="10-50" ${companySize == '10-50' || size == '10-50' ? 'selected' : ''}>10-50</option>
                                <option value="50-100" ${companySize == '50-100' || size == '50-100' ? 'selected' : ''}>50-100</option>
                                <option value="100-500" ${companySize == '100-500' || size == '100-500' ? 'selected' : ''}>100-500</option>
                                <option value="Trên 500" ${companySize == 'Trên 500' || size == 'Trên 500' ? 'selected' : ''}>Trên 500</option>
                            </select>
                        </div>

                        <!-- Region Filter -->
                        <div>
                            <select name="region" class="custom-filter-select">
                                <option value="">-- Khu vực --</option>
                                <option value="Miền Bắc" ${region == 'Miền Bắc' ? 'selected' : ''}>Miền Bắc</option>
                                <option value="Miền Trung" ${region == 'Miền Trung' ? 'selected' : ''}>Miền Trung</option>
                                <option value="Miền Nam" ${region == 'Miền Nam' ? 'selected' : ''}>Miền Nam</option>
                                <option value="Toàn quốc" ${region == 'Toàn quốc' ? 'selected' : ''}>Toàn quốc</option>
                                <option value="Nước ngoài" ${region == 'Nước ngoài' ? 'selected' : ''}>Nước ngoài</option>
                            </select>
                        </div>

                        <!-- Owner Filter -->
                        <div>
                            <select name="ownerId" class="custom-filter-select">
                                <option value="">-- Người sở hữu --</option>
                                <c:forEach var="acc" items="${owners}">
                                    <option value="${acc.accountId}" ${ownerId == acc.accountId ? 'selected' : ''}>
                                        <c:out value="${acc.fullName}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <!-- Row 2: Custom fields, Filter Action Buttons -->
                    <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; width: 100%; margin-top: 14px;">
                        <c:if test="${not empty customFieldDefinitions}">
                            <div style="display: flex; gap: 8px; align-items: center; flex: 2; min-width: 280px;">
                                <select name="filterFieldId" class="custom-filter-select" style="flex: 1;">
                                    <option value="">-- Lọc theo trường tùy chỉnh --</option>
                                    <c:forEach var="def" items="${customFieldDefinitions}">
                                        <option value="${def.fieldId}" ${filterFieldId == def.fieldId ? 'selected' : ''}><c:out value="${def.fieldLabel}"/></option>
                                    </c:forEach>
                                </select>
                                <input type="text" name="filterFieldValue" class="custom-filter-input" placeholder="Giá trị..." value="<c:out value='${filterFieldValue}'/>" style="flex: 1; max-width: 200px;">
                            </div>
                        </c:if>

                        <div class="filter-actions" style="display: flex; gap: 8px; margin-left: auto;">
                            <button class="btn btn-primary" type="submit" style="padding: 8px 18px; border-radius: 9px; font-weight: 600; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none; color: #fff;">
                                <i class="fas fa-filter"></i> Lọc dữ liệu
                            </button>
                            <c:if test="${not empty keyword or not empty status or not empty industry or not empty companySize or not empty size or not empty region or not empty ownerId or not empty filterFieldId}">
                                <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary" style="background: white; border: 1px solid var(--crm-border); border-radius: 9px;">Đặt lại</a>
                            </c:if>
                            <button type="button" class="btn btn-secondary" onclick="openSaveFilterModal()" style="background: #ffffff; border: 1px solid var(--crm-border); color: #334155; border-radius: 9px;">
                                <i class="fas fa-bookmark" style="color: var(--crm-accent);"></i> Lưu bộ lọc
                            </button>
                        </div>
                    </div>

                    <!-- Row 3: Saved Filters Pills -->
                    <c:if test="${not empty savedFilters}">
                        <div style="width: 100%; border-top: 1px dashed var(--crm-border); margin-top: 14px; padding-top: 12px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                            <span style="font-size: 13px; font-weight: 600; color: var(--crm-text-muted);"><i class="fas fa-star" style="color: var(--crm-accent);"></i> Bộ lọc đã lưu:</span>
                            <c:forEach var="sf" items="${savedFilters}">
                                <div class="saved-filter-pill" style="display: inline-flex; align-items: center; gap: 6px; background: #eff6ff; color: #1e3a8a; padding: 4px 12px; border-radius: 16px; font-size: 12.5px; border: 1px solid #bfdbfe;">
                                    <span style="cursor: pointer; font-weight: 500;" onclick="applySavedFilter('<c:out value="${sf.keyword}"/>', '<c:out value="${sf.status}"/>', '<c:out value="${sf.industry}"/>', '<c:out value="${sf.companySize}"/>', '<c:out value="${sf.region}"/>', '<c:out value="${sf.ownerId}"/>')">
                                        <c:out value="${sf.filterName}"/>
                                    </span>
                                    <button type="button" onclick="deleteSavedFilter(event, ${sf.filterId})" style="border: none; background: none; color: #2563eb; cursor: pointer; font-weight: bold; padding: 0 2px; font-size: 14px;" title="Xóa bộ lọc">&times;</button>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>
                </form>

                <!-- Modern Table Panel -->
                <div class="table-panel-card">
                    <div class="table-panel-header">
                        <h2 class="table-panel-title">
                            <i class="fas fa-users" style="color: var(--crm-primary);"></i>
                            Danh sách khách hàng
                            <span class="table-badge-counter">${total} khách hàng</span>
                        </h2>
                    </div>

                    <div class="table-container table-responsive" style="overflow-x: auto;">
                        <table class="modern-crm-table">
                            <thead>
                                <tr>
                                    <th style="width: 70px;">ID</th>
                                    <th>Khách hàng / Doanh nghiệp</th>
                                    <th>Mã số thuế</th>
                                    <th>Ngành nghề</th>
                                    <th>Quy mô</th>
                                    <th>Người phụ trách</th>
                                    <th>Trạng thái</th>
                                    <th style="width: 170px; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty list}">
                                        <c:forEach var="item" items="${list}">
                                            <tr>
                                                <td style="font-weight: 600; color: #64748b; font-size: 13px;">#${item.customerId}</td>
                                                <td>
                                                    <div class="company-cell">
                                                        <div class="company-avatar">
                                                            <c:choose>
                                                                <c:when test="${not empty item.customerName}">
                                                                    ${item.customerName.substring(0, 1).toUpperCase()}
                                                                </c:when>
                                                                <c:otherwise>K</c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <div>
                                                            <div class="company-name"><c:out value="${item.customerName}" /></div>
                                                            <c:if test="${not empty item.phone}">
                                                                <div style="font-size: 12px; color: #64748b; margin-top: 2px;">
                                                                    <i class="fas fa-phone-alt" style="font-size: 10px; margin-right: 4px;"></i><c:out value="${item.phone}" />
                                                                </div>
                                                            </c:if>
                                                            <c:if test="${item.riskFlag}">
                                                                <span class="badge" style="background:#fee2e2; color:#dc2626; border:1px solid #fca5a5; padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; margin-top: 4px; display: inline-block;" title="<c:out value='${item.riskReason}'/>">
                                                                    <i class="fas fa-exclamation-triangle"></i> Rủi ro rời bỏ
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.taxCode}">
                                                            <span style="font-family: monospace; font-size: 13px; font-weight: 500; background: #f1f5f9; padding: 2px 6px; border-radius: 4px; color: #334155;">
                                                                <c:out value="${item.taxCode}" />
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise><span style="color: #94a3b8;">--</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.industry}">
                                                            <c:out value="${item.industry}" />
                                                        </c:when>
                                                        <c:otherwise><span style="color: #94a3b8;">--</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.size}">
                                                            <c:out value="${item.size}" />
                                                        </c:when>
                                                        <c:otherwise><span style="color: #94a3b8;">--</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div style="display: flex; align-items: center; gap: 6px;">
                                                        <i class="fas fa-user-circle" style="color: #94a3b8;"></i>
                                                        <span style="font-weight: 500; color: #1e293b;">
                                                            <c:out value="${not empty item.ownerName ? item.ownerName : item.ownerId}" />
                                                        </span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.status == 'POTENTIAL' || item.status == 'Tiềm năng' || item.status == 'Ti?m n?ng'}"><span class="status-pill status-potential">Tiềm năng</span></c:when>
                                                        <c:when test="${item.status == 'DEALING' || item.status == 'Đang giao dịch'}"><span class="status-pill status-dealing">Đang giao dịch</span></c:when>
                                                        <c:when test="${item.status == 'CUSTOMER' || item.status == 'Khách hàng'}"><span class="status-pill status-customer">Khách hàng</span></c:when>
                                                        <c:when test="${item.status == 'ACTIVE' || item.status == 'Hoạt động'}"><span class="status-pill status-active">Hoạt động</span></c:when>
                                                        <c:when test="${item.status == 'STOPPED' || item.status == 'Ngừng hợp tác'}"><span class="status-pill status-stopped">Ngừng hợp tác</span></c:when>
                                                        <c:otherwise><span class="status-pill status-stopped"><c:out value="${item.status}" /></span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <div class="action-btn-group">
                                                        <a href="${pageContext.request.contextPath}/customers/360?id=${item.customerId}"
                                                            class="action-360-btn"
                                                            title="Xem tổng quan 360°">
                                                            <i class="fas fa-chart-pie"></i> 360°
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}"
                                                            class="action-icon-btn"
                                                            title="Xem chi tiết">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${item.customerId}"
                                                            class="action-icon-btn"
                                                            title="Gộp khách hàng">
                                                            <i class="fas fa-compress-alt"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/customers/edit?id=${item.customerId}"
                                                            class="action-icon-btn"
                                                            title="Chỉnh sửa">
                                                            <i class="fas fa-pen"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8">
                                                <div class="modern-empty-state">
                                                    <div class="empty-icon-wrap"><i class="fas fa-users-slash"></i></div>
                                                    <c:choose>
                                                        <c:when test="${not empty keyword or not empty status or not empty industry or not empty companySize or not empty region or not empty ownerId}">
                                                            <h3 style="font-size: 16px; margin: 0 0 6px; color: var(--crm-text-main); font-weight: 600;">Không tìm thấy kết quả phù hợp</h3>
                                                            <p style="color: var(--crm-text-muted); font-size: 13.5px; margin: 0 0 16px;">Vui lòng thử điều chỉnh lại bộ lọc hoặc từ khóa tìm kiếm.</p>
                                                            <a href="${pageContext.request.contextPath}/customers" class="btn-modern-secondary" style="display: inline-flex;">Đặt lại bộ lọc</a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <h3 style="font-size: 16px; margin: 0 0 6px; color: var(--crm-text-main); font-weight: 600;">Chưa có khách hàng trong hệ thống</h3>
                                                            <p style="color: var(--crm-text-muted); font-size: 13.5px; margin: 0 0 16px;">Bắt đầu tạo hồ sơ khách hàng mới đầu tiên của bạn.</p>
                                                            <button class="btn-modern-primary" onclick="openCustomerModal()"><i class="fas fa-plus"></i> Thêm khách hàng ngay</button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <c:if test="${totalPages > 1}">
                        <div class="card-footer"
                            style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--crm-border); padding: 14px 24px; background: #ffffff;">
                            <span style="color: var(--crm-text-muted); font-size: 13px;">Hiển thị trang <strong>${currentPage}</strong> trên tổng số <strong>${totalPages}</strong> trang</span>
                            <ul class="pagination"
                                style="margin: 0; display: flex; gap: 6px; list-style: none; padding: 0;">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link btn btn-secondary inactive-link"
                                        style="padding: 6px 14px; border-radius: 8px; font-size: 13px;"
                                        href="?page=${currentPage - 1}&keyword=<c:out value='${keyword}'/>&status=<c:out value='${status}'/>&industry=<c:out value='${industry}'/>&companySize=<c:out value='${companySize}'/>&region=<c:out value='${region}'/>&ownerId=${ownerId}&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>">‹ Trước</a>
                                </li>
                                <c:forEach begin="${currentPage - 2 > 1 ? currentPage - 2 : 1}"
                                    end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link btn ${currentPage == i ? 'btn-primary' : 'btn-secondary inactive-link'}"
                                            style="padding: 6px 14px; border-radius: 8px; font-size: 13px; font-weight: ${currentPage == i ? '600' : 'normal'};"
                                            href="?page=${i}&keyword=<c:out value='${keyword}'/>&status=<c:out value='${status}'/>&industry=<c:out value='${industry}'/>&companySize=<c:out value='${companySize}'/>&region=<c:out value='${region}'/>&ownerId=${ownerId}&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link btn btn-secondary inactive-link"
                                        style="padding: 6px 14px; border-radius: 8px; font-size: 13px;"
                                        href="?page=${currentPage + 1}&keyword=<c:out value='${keyword}'/>&status=<c:out value='${status}'/>&industry=<c:out value='${industry}'/>&companySize=<c:out value='${companySize}'/>&region=<c:out value='${region}'/>&ownerId=${ownerId}&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>">Sau ›</a>
                                </li>
                            </ul>
                        </div>
                    </c:if>
                </div>
            </div>
        </main>
    </div>

    <!-- Modal Save Filter -->
    <div id="saveFilterModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 2000; align-items: center; justify-content: center;">
        <div class="modal-content" style="background: white; border-radius: 8px; width: 100%; max-width: 440px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0; font-size: 17px; color: var(--crm-text-main);"><i class="fas fa-bookmark" style="color: var(--crm-accent);"></i> Lưu bộ lọc hiện tại</h3>
                <button type="button" onclick="closeSaveFilterModal()" style="border: none; background: none; font-size: 20px; cursor: pointer;">&times;</button>
            </div>
            <form id="saveFilterForm" onsubmit="saveCurrentFilter(event)">
                <div class="form-group" style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên bộ lọc <span style="color:red;">*</span></label>
                    <input type="text" id="filterNameInput" name="filterName" class="form-control" required placeholder="Ví dụ: Khách CNTT Miền Bắc" style="width: 100%; padding: 8px 12px; border: 1px solid var(--crm-border); border-radius: 6px;">
                </div>
                <div style="background: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 20px; font-size: 13px;">
                    <strong style="color: #334155;">Các điều kiện sẽ lưu:</strong>
                    <ul style="margin: 6px 0 0 16px; padding: 0; color: #64748b;">
                        <li>Từ khóa: <span id="summaryKeyword">--</span></li>
                        <li>Trạng thái: <span id="summaryStatus">--</span></li>
                        <li>Ngành nghề: <span id="summaryIndustry">--</span></li>
                        <li>Quy mô: <span id="summarySize">--</span></li>
                        <li>Khu vực: <span id="summaryRegion">--</span></li>
                        <li>Người sở hữu: <span id="summaryOwner">--</span></li>
                    </ul>
                </div>
                <div style="display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" onclick="closeSaveFilterModal()" class="btn btn-secondary" style="padding: 8px 16px; border-radius: 8px;">Hủy</button>
                    <button type="submit" class="btn btn-primary" style="padding: 8px 16px; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none; border-radius: 8px;">Lưu bộ lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Create Customer -->
    <!-- Modal Create Customer - Redesigned Modern UI -->
    <div id="customerModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 2000; align-items: center; justify-content: center; padding: 20px; box-sizing: border-box;">
        <div class="modal-dialog" style="background: #ffffff; border-radius: 14px; width: 100%; max-width: 720px; max-height: 90vh; display: flex; flex-direction: column; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); overflow: hidden; animation: modalFadeIn 0.25s ease-out;">
            
            <!-- Modal Header -->
            <div style="padding: 20px 24px; border-bottom: 1px solid var(--crm-border); display: flex; justify-content: space-between; align-items: center; background: #ffffff;">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(30, 58, 138, 0.08); color: var(--crm-primary); display: flex; align-items: center; justify-content: center; font-size: 18px;">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div>
                        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--crm-text-main);">Thêm mới khách hàng</h3>
                        <p style="margin: 2px 0 0; font-size: 13px; color: var(--crm-text-muted);">Nhập thông tin doanh nghiệp / đối tác vào hệ thống CRM</p>
                    </div>
                </div>
                <button type="button" onclick="closeCustomerModal()" style="border: none; background: #f1f5f9; color: #64748b; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#e2e8f0'; this.style.color='#0f172a'" onmouseout="this.style.background='#f1f5f9'; this.style.color='#64748b'">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- Modal Body (Scrollable) -->
            <form id="customerForm" onsubmit="saveCustomer(event)" style="display: flex; flex-direction: column; overflow: hidden; margin: 0;">
                <div style="padding: 24px; overflow-y: auto; max-height: calc(90vh - 160px); display: flex; flex-direction: column; gap: 20px;">
                    
                    <!-- Alert Error Container -->
                    <div id="modalAlertError" style="display: none; padding: 12px 16px; border-radius: 8px; background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; font-size: 13.5px;">
                        <div style="display: flex; align-items: flex-start; gap: 8px;">
                            <i class="fas fa-exclamation-circle" style="margin-top: 2px;"></i>
                            <div id="modalAlertErrorText" style="flex: 1; line-height: 1.5;"></div>
                        </div>
                    </div>

                    <!-- Section 1: Thông tin cơ bản -->
                    <div>
                        <div style="font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--color-primary); margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                            <i class="fas fa-building"></i> Thông tin doanh nghiệp
                        </div>
                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px;">
                            <div style="grid-column: span 2;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Tên khách hàng / Công ty <span style="color:red;">*</span></label>
                                <input type="text" id="custName" name="customerName" required placeholder="Ví dụ: Công ty TNHH Công nghệ FPT" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; transition: border-color 0.2s;" onfocus="this.style.borderColor='var(--color-primary)'" onblur="this.style.borderColor='var(--color-border)'">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Mã số thuế</label>
                                <input type="text" id="custTaxCode" name="taxCode" placeholder="Ví dụ: 0101234567" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; transition: border-color 0.2s;" onfocus="this.style.borderColor='var(--color-primary)'" onblur="this.style.borderColor='var(--color-border)'">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Trạng thái</label>
                                <select id="custStatus" name="status" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; background: white; outline: none; transition: border-color 0.2s;">
                                    <option value="POTENTIAL" selected>Tiềm năng</option>
                                    <option value="DEALING">Đang giao dịch</option>
                                    <option value="CUSTOMER">Khách hàng</option>
                                    <option value="ACTIVE">Hoạt động</option>
                                    <option value="STOPPED">Ngừng hợp tác</option>
                                </select>
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Ngành nghề</label>
                                <select id="custIndustry" name="industry" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; background: white; outline: none;">
                                    <option value="">-- Chọn ngành nghề --</option>
                                    <option value="Công nghệ thông tin">Công nghệ thông tin</option>
                                    <option value="Bất động sản">Bất động sản</option>
                                    <option value="Tài chính / Ngân hàng">Tài chính / Ngân hàng</option>
                                    <option value="Sản xuất">Sản xuất</option>
                                    <option value="Thương mại / Bán lẻ">Thương mại / Bán lẻ</option>
                                    <option value="Y tế / Dược phẩm">Y tế / Dược phẩm</option>
                                    <option value="Giáo dục">Giáo dục</option>
                                    <option value="Khác">Khác</option>
                                </select>
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Quy mô nhân sự</label>
                                <select id="custSize" name="companySize" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; background: white; outline: none;">
                                    <option value="">-- Chọn quy mô --</option>
                                    <option value="Dưới 10">Dưới 10 nhân sự</option>
                                    <option value="10-50">10-50 nhân sự</option>
                                    <option value="50-100">50-100 nhân sự</option>
                                    <option value="100-500">100-500 nhân sự</option>
                                    <option value="Trên 500">Trên 500 nhân sự</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Section 2: Liên hệ & Quản lý -->
                    <div style="border-top: 1px dashed var(--color-border); padding-top: 16px;">
                        <div style="font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--color-primary); margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                            <i class="fas fa-address-book"></i> Liên hệ & Phụ trách
                        </div>
                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px;">
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Số điện thoại</label>
                                <input type="tel" id="custPhone" name="phone" placeholder="Ví dụ: 0912345678" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; transition: border-color 0.2s;" onfocus="this.style.borderColor='var(--color-primary)'" onblur="this.style.borderColor='var(--color-border)'">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Email doanh nghiệp</label>
                                <input type="email" id="custEmail" name="email" placeholder="contact@company.com" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; transition: border-color 0.2s;" onfocus="this.style.borderColor='var(--color-primary)'" onblur="this.style.borderColor='var(--color-border)'">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Khu vực</label>
                                <select id="custRegion" name="region" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; background: white; outline: none;">
                                    <option value="">-- Chọn khu vực --</option>
                                    <option value="Miền Bắc">Miền Bắc</option>
                                    <option value="Miền Trung">Miền Trung</option>
                                    <option value="Miền Nam">Miền Nam</option>
                                    <option value="Toàn quốc">Toàn quốc</option>
                                    <option value="Nước ngoài">Nước ngoài</option>
                                </select>
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Người sở hữu / Phụ trách</label>
                                <select id="custOwnerId" name="ownerId" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; background: white; outline: none;">
                                    <c:forEach var="acc" items="${owners}">
                                        <option value="${acc.accountId}" ${sessionScope.userId == acc.accountId ? 'selected' : ''}>
                                            <c:out value="${acc.fullName}"/> (${acc.email})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div style="grid-column: span 2;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Website</label>
                                <input type="url" id="custWebsite" name="website" placeholder="https://example.com" style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none;">
                            </div>
                            <div style="grid-column: span 2;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">Địa chỉ chi tiết</label>
                                <textarea id="custAddress" name="address" rows="2" placeholder="Tầng, số nhà, tên đường, quận/huyện, tỉnh/thành..." style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; resize: vertical;"></textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Dynamic Custom Fields -->
                    <c:if test="${not empty customFieldDefinitions}">
                        <div style="border-top: 1px dashed var(--color-border); padding-top: 16px;">
                            <div style="font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--color-primary); margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                                <i class="fas fa-sliders-h"></i> Thông tin bổ sung
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px;">
                                <c:forEach var="def" items="${customFieldDefinitions}">
                                    <div style="<c:if test='${def.fieldType == \"TEXTAREA\"}'>grid-column: span 2;</c:if>">
                                        <label style="display: block; margin-bottom: 6px; font-weight: 600; font-size: 13px; color: var(--color-gray-800);">
                                            <c:out value="${def.fieldLabel}"/>
                                            <c:if test="${def.required}"><span style="color:red;"> *</span></c:if>
                                        </label>
                                        <c:choose>
                                            <c:when test="${def.fieldType == 'SELECT'}">
                                                <select name="customField_${def.fieldId}" ${def.required ? 'required' : ''} style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; background: white; outline: none;">
                                                    <option value="">-- Chọn --</option>
                                                    <c:forEach var="opt" items="${def.options.split('[,;\\\\n]+')}">
                                                        <option value="${opt.trim()}"><c:out value="${opt.trim()}"/></option>
                                                    </c:forEach>
                                                </select>
                                            </c:when>
                                            <c:when test="${def.fieldType == 'DATE'}">
                                                <input type="date" name="customField_${def.fieldId}" ${def.required ? 'required' : ''} style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none;">
                                            </c:when>
                                            <c:when test="${def.fieldType == 'NUMBER'}">
                                                <input type="number" step="any" name="customField_${def.fieldId}" ${def.required ? 'required' : ''} style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none;">
                                            </c:when>
                                            <c:otherwise>
                                                <input type="text" name="customField_${def.fieldId}" ${def.required ? 'required' : ''} style="width: 100%; padding: 9px 12px; border: 1px solid var(--color-border); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none;">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- Modal Footer -->
                <div style="padding: 16px 24px; border-top: 1px solid var(--crm-border); background: #f8fafc; display: flex; justify-content: flex-end; align-items: center; gap: 12px;">
                    <button type="button" onclick="closeCustomerModal()" class="btn btn-secondary" style="padding: 9px 18px; border-radius: 8px; font-weight: 500;">
                        Hủy
                    </button>
                    <button type="submit" id="btnSubmitCustomer" class="btn btn-primary" style="padding: 9px 22px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none; color: white; box-shadow: 0 4px 12px rgba(30, 58, 138, 0.28);">
                        <i class="fas fa-save"></i>
                        <span>Lưu khách hàng</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <style>
        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-16px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
    </style>

    <script>
        function applySavedFilter(kw, status, industry, companySize, region, ownerId) {
            const form = document.getElementById('filterForm');
            form.querySelector('[name="keyword"]').value = kw || '';
            form.querySelector('[name="status"]').value = status || '';
            form.querySelector('[name="industry"]').value = industry || '';
            form.querySelector('[name="companySize"]').value = companySize || '';
            form.querySelector('[name="region"]').value = region || '';
            form.querySelector('[name="ownerId"]').value = (ownerId && ownerId !== 'null') ? ownerId : '';
            form.submit();
        }

        function deleteSavedFilter(e, filterId) {
            e.stopPropagation();
            if (!confirm('Bạn có chắc chắn muốn xóa bộ lọc này?')) return;

            const params = new URLSearchParams();
            params.append('action', 'delete');
            params.append('filterId', filterId);

            fetch('${pageContext.request.contextPath}/customers/filters', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    window.location.reload();
                } else {
                    (typeof window.showToast === 'function' ? window.showToast('error', 'Lỗi: ' + (data.message || 'Không thể xóa bộ lọc.')) : window.alert('Lỗi: ' + (data.message || 'Không thể xóa bộ lọc.')));
                }
            })
            .catch(() => (typeof window.showToast === 'function' ? window.showToast('error', 'Lỗi kết nối máy chủ.') : window.alert('Lỗi kết nối máy chủ.')));
        }

        function openSaveFilterModal() {
            const form = document.getElementById('filterForm');
            const kw = form.querySelector('[name="keyword"]').value.trim();
            const status = form.querySelector('[name="status"]').value;
            const industry = form.querySelector('[name="industry"]').value;
            const size = form.querySelector('[name="companySize"]').value;
            const region = form.querySelector('[name="region"]').value;
            const ownerSelect = form.querySelector('[name="ownerId"]');
            const ownerText = ownerSelect.options[ownerSelect.selectedIndex] ? ownerSelect.options[ownerSelect.selectedIndex].text : '';

            document.getElementById('summaryKeyword').innerText = kw || '(Tất cả)';
            document.getElementById('summaryStatus').innerText = status || '(Tất cả)';
            document.getElementById('summaryIndustry').innerText = industry || '(Tất cả)';
            document.getElementById('summarySize').innerText = size || '(Tất cả)';
            document.getElementById('summaryRegion').innerText = region || '(Tất cả)';
            document.getElementById('summaryOwner').innerText = (ownerSelect.value ? ownerText : '(Tất cả)');

            document.getElementById('filterNameInput').value = '';
            document.getElementById('saveFilterModal').style.display = 'flex';
        }

        function closeSaveFilterModal() {
            document.getElementById('saveFilterModal').style.display = 'none';
        }

        function saveCurrentFilter(e) {
            e.preventDefault();
            const filterName = document.getElementById('filterNameInput').value.trim();
            if (!filterName) {
                (typeof window.showToast === 'function' ? window.showToast('warning', 'Vui lòng nhập tên bộ lọc.') : window.alert('Vui lòng nhập tên bộ lọc.'));
                return;
            }

            const filterForm = document.getElementById('filterForm');
            const params = new URLSearchParams();
            params.append('filterName', filterName);
            params.append('keyword', filterForm.querySelector('[name="keyword"]').value);
            params.append('status', filterForm.querySelector('[name="status"]').value);
            params.append('industry', filterForm.querySelector('[name="industry"]').value);
            params.append('companySize', filterForm.querySelector('[name="companySize"]').value);
            params.append('region', filterForm.querySelector('[name="region"]').value);
            params.append('ownerId', filterForm.querySelector('[name="ownerId"]').value);

            fetch('${pageContext.request.contextPath}/customers/filters', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    closeSaveFilterModal();
                    filterForm.submit();
                } else {
                    (typeof window.showToast === 'function' ? window.showToast('error', 'Lỗi: ' + (data.message || 'Không thể lưu bộ lọc.')) : window.alert('Lỗi: ' + (data.message || 'Không thể lưu bộ lọc.')));
                }
            })
            .catch(() => (typeof window.showToast === 'function' ? window.showToast('error', 'Lỗi kết nối máy chủ.') : window.alert('Lỗi kết nối máy chủ.')));
        }

        function openCustomerModal() {
            document.getElementById('customerForm').reset();
            const alertErr = document.getElementById('modalAlertError');
            if (alertErr) alertErr.style.display = 'none';
            document.getElementById('customerModal').style.display = 'flex';
            setTimeout(() => {
                const nameInput = document.getElementById('custName');
                if (nameInput) nameInput.focus();
            }, 50);
        }

        function closeCustomerModal() {
            document.getElementById('customerModal').style.display = 'none';
        }

        function saveCustomer(e) {
            e.preventDefault();
            const form = document.getElementById('customerForm');
            const submitBtn = document.getElementById('btnSubmitCustomer');
            const alertErr = document.getElementById('modalAlertError');
            const alertText = document.getElementById('modalAlertErrorText');

            if (alertErr) alertErr.style.display = 'none';

            const formData = new FormData(form);
            const params = new URLSearchParams(formData);

            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> <span>Đang lưu...</span>';
            }

            fetch('${pageContext.request.contextPath}/customers/create', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params
            })
            .then(async res => {
                let data = {};
                try {
                    data = await res.json();
                } catch (jsonErr) {
                    data = { error: 'Phản hồi từ máy chủ không hợp lệ' };
                }

                if (!res.ok) {
                    let errMsg = data.error || 'Có lỗi xảy ra khi lưu khách hàng.';
                    if (data.details && data.details.length > 0) {
                        errMsg += '<ul style="margin: 4px 0 0 16px; padding: 0;">' + 
                            data.details.map(d => '<li>' + d + '</li>').join('') + '</ul>';
                    }
                    if (alertErr && alertText) {
                        alertText.innerHTML = errMsg;
                        alertErr.style.display = 'block';
                    } else {
                        (typeof window.showToast === 'function' ? window.showToast('error', 'Lỗi: ' + (data.error || 'Thao tác không hợp lệ')) : window.alert('Lỗi: ' + (data.error || 'Thao tác không hợp lệ')));
                    }
                } else {
                    closeCustomerModal();
                    window.location.reload();
                }
            })
            .catch(err => {
                console.error('Save customer error:', err);
                if (alertErr && alertText) {
                    alertText.innerText = 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.';
                    alertErr.style.display = 'block';
                } else {
                    (typeof window.showToast === 'function' ? window.showToast('error', 'Lỗi kết nối máy chủ.') : window.alert('Lỗi kết nối máy chủ.'));
                }
            })
            .finally(() => {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = '<i class="fas fa-save"></i> <span>Lưu khách hàng</span>';
                }
            });
        }

        // Close modal when click outside dialog
        document.getElementById('customerModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeCustomerModal();
            }
        });
    </script>
</body>
</html>
