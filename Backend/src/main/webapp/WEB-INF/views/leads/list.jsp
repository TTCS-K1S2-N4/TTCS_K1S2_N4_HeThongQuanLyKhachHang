<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách Lead | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container lead-page-container">
            
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px;">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Quản lý Lead</span>
            </nav>

            <!-- Page Header Banner & Action Toolbar -->
            <div class="lead-header-banner">
                <div class="lead-header-left">
                    <div class="lead-header-icon-box">
                        <i class="fa-solid fa-bullseye"></i>
                    </div>
                    <div class="lead-header-titles">
                        <h1 class="lead-page-title">
                            Danh sách Lead
                        </h1>
                        <p class="lead-page-subtitle">
                            Quản lý đầu mối kinh doanh, tự động chấm điểm ưu tiên và lọc danh sách gọi hàng ngày.
                        </p>
                    </div>
                </div>

                <div class="lead-header-actions">
                    <a href="${pageContext.request.contextPath}/leads/create" class="btn-lead-primary" id="btn-add-lead">
                        <i class="fa-solid fa-plus"></i> Thêm Lead
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/import" class="btn-lead-action" title="Nhập danh sách Lead từ file Excel">
                        <i class="fa-solid fa-file-excel"></i> Nhập Excel
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/web-forms" class="btn-lead-action" title="Quản lý biểu mẫu thu thập Lead nhúng trên website">
                        <i class="fa-solid fa-code"></i> Web Forms
                    </a>
                    <a href="${pageContext.request.contextPath}/lead-scoring/rules" class="btn-lead-action" title="Cấu hình chấm điểm Lead (Giám đốc kinh doanh)">
                        <i class="fa-solid fa-sliders"></i> Cấu hình Chấm điểm
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/saved-filters" class="btn-lead-action" title="Xem danh sách các bộ lọc đã lưu">
                        <i class="fa-solid fa-bookmark"></i> Bộ lọc đã lưu
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/duplicates" class="btn-lead-action" title="Kiểm tra và gộp Lead trùng lặp">
                        <i class="fa-solid fa-clone"></i> Kiểm tra trùng
                    </a>
                </div>
            </div>

            <c:set var="leadItems" value="${not empty leads ? leads : (not empty leadList ? leadList : list)}"/>
            <c:set var="leadCountDisplay" value="${not empty totalLeads ? totalLeads : (not empty leadItems ? leadItems.size() : 0)}"/>

            <!-- Quick Metrics Overview Cards -->
            <div class="lead-kpi-row">
                <div class="lead-kpi-box lead-kpi-blue">
                    <div class="lead-kpi-info">
                        <span class="lead-kpi-label">Tổng số Lead</span>
                        <span class="lead-kpi-val">${leadCountDisplay}</span>
                    </div>
                    <div class="lead-kpi-icon">
                        <i class="fa-solid fa-users-viewfinder"></i>
                    </div>
                </div>

                <div class="lead-kpi-box lead-kpi-amber">
                    <div class="lead-kpi-info">
                        <span class="lead-kpi-label">Trạng thái lọc</span>
                        <span class="lead-kpi-val" style="font-size: 1.05rem; font-weight: 700;">
                            <c:choose>
                                <c:when test="${param.status == 'NEW' || status == 'NEW'}">Mới tạo</c:when>
                                <c:when test="${param.status == 'CONTACTED' || status == 'CONTACTED'}">Đang liên hệ</c:when>
                                <c:when test="${param.status == 'QUALIFIED' || status == 'QUALIFIED'}">Đã xác định NC</c:when>
                                <c:when test="${param.status == 'CONVERTED' || status == 'CONVERTED'}">Đã chuyển đổi</c:when>
                                <c:otherwise>Tất cả trạng thái</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="lead-kpi-icon">
                        <i class="fa-solid fa-filter"></i>
                    </div>
                </div>

                <div class="lead-kpi-box lead-kpi-emerald">
                    <div class="lead-kpi-info">
                        <span class="lead-kpi-label">Phân loại điểm</span>
                        <span class="lead-kpi-val" style="font-size: 1.05rem; font-weight: 700;">
                            <c:choose>
                                <c:when test="${param.classification == 'HOT' || classification == 'HOT'}">🔥 Lead Nóng</c:when>
                                <c:when test="${param.classification == 'WARM' || classification == 'WARM'}">☀️ Lead Ấm</c:when>
                                <c:when test="${param.classification == 'COLD' || classification == 'COLD'}">❄️ Lead Lạnh</c:when>
                                <c:otherwise>Toàn bộ mức độ</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="lead-kpi-icon">
                        <i class="fa-solid fa-fire-flame-curved"></i>
                    </div>
                </div>

                <div class="lead-kpi-box lead-kpi-rose">
                    <div class="lead-kpi-info">
                        <span class="lead-kpi-label">Cảnh báo SLA</span>
                        <span class="lead-kpi-val" style="font-size: 1.05rem; font-weight: 700;">
                            <c:choose>
                                <c:when test="${param.overdue == 'true'}">⚠️ Chỉ Lead Quá SLA</c:when>
                                <c:otherwise>Giám sát chủ động</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="lead-kpi-icon">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                </div>
            </div>

            <!-- Lead Filter Toolbar Form (S4-09-AC-01) -->
            <form id="leadFilterForm" action="${pageContext.request.contextPath}/leads" method="get" class="lead-filter-card">
                <div class="filter-header-bar">
                    <div class="filter-header-title">
                        <i class="fa-solid fa-filter"></i> Bộ lọc & Tìm kiếm Lead
                    </div>
                    <div class="filter-header-hint">
                        Tùy chọn đa tiêu chí giúp ưu tiên danh sách gọi điện hiệu quả
                    </div>
                </div>

                <!-- Hàng 1: Từ khóa tìm kiếm, Trạng thái, Nguồn, Phân loại điểm, Người phụ trách -->
                <div class="filter-grid-row-1">
                    <!-- Tìm kiếm từ khóa -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fa-solid fa-magnifying-glass" style="color: #2563eb;"></i> Từ khóa tìm kiếm
                        </label>
                        <input type="search" name="keyword" class="form-control" placeholder="Họ tên, công ty, email, SĐT..." value="<c:out value='${param.keyword != null ? param.keyword : (param.search != null ? param.search : search)}'/>">
                    </div>

                    <!-- Lọc Trạng thái (Status) -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fa-solid fa-list-check" style="color: #64748b;"></i> Trạng thái
                        </label>
                        <select name="status" class="form-control">
                            <option value="">Tất cả trạng thái</option>
                            <option value="NEW" ${param.status == 'NEW' || status == 'NEW' ? 'selected' : ''}>Mới tạo</option>
                            <option value="CONTACTED" ${param.status == 'CONTACTED' || status == 'CONTACTED' ? 'selected' : ''}>Đang liên hệ</option>
                            <option value="QUALIFIED" ${param.status == 'QUALIFIED' || status == 'QUALIFIED' ? 'selected' : ''}>Đã xác định nhu cầu</option>
                            <option value="UNQUALIFIED" ${param.status == 'UNQUALIFIED' || status == 'UNQUALIFIED' ? 'selected' : ''}>Không tiềm năng</option>
                            <option value="CONVERTED" ${param.status == 'CONVERTED' || status == 'CONVERTED' ? 'selected' : ''}>Đã chuyển đổi</option>
                        </select>
                    </div>

                    <!-- Lọc Nguồn Lead (Source) -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fa-solid fa-share-nodes" style="color: #64748b;"></i> Nguồn Lead
                        </label>
                        <select name="source" class="form-control">
                            <option value="">Tất cả nguồn</option>
                            <option value="Website" ${param.source == 'Website' ? 'selected' : ''}>Website</option>
                            <option value="Facebook" ${param.source == 'Facebook' ? 'selected' : ''}>Facebook</option>
                            <option value="Google Ads" ${param.source == 'Google Ads' ? 'selected' : ''}>Google Ads</option>
                            <option value="Giới thiệu" ${param.source == 'Giới thiệu' ? 'selected' : ''}>Giới thiệu</option>
                            <option value="Sự kiện" ${param.source == 'Sự kiện' ? 'selected' : ''}>Sự kiện</option>
                            <option value="Khác" ${param.source == 'Khác' ? 'selected' : ''}>Khác</option>
                        </select>
                    </div>

                    <!-- Lọc Phân loại Nóng / Ấm / Lạnh (Classification S4-05 & S4-09) -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fa-solid fa-fire" style="color: #ef4444;"></i> Phân loại điểm
                        </label>
                        <select name="classification" class="form-control">
                            <option value="">Tất cả mức độ</option>
                            <option value="HOT" ${param.classification == 'HOT' || param.rating == 'HOT' || rating == 'HOT' ? 'selected' : ''}>🔥 NÓNG (Ưu tiên gọi)</option>
                            <option value="WARM" ${param.classification == 'WARM' || param.rating == 'WARM' || rating == 'WARM' ? 'selected' : ''}>☀️ ẤM</option>
                            <option value="COLD" ${param.classification == 'COLD' || param.rating == 'COLD' || rating == 'COLD' ? 'selected' : ''}>❄️ LẠNH</option>
                        </select>
                    </div>

                    <!-- Lọc Người phụ trách (Owner) -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fa-solid fa-user-check" style="color: #64748b;"></i> Người phụ trách
                        </label>
                        <select name="ownerId" class="form-control">
                            <option value="">Tất cả phụ trách</option>
                            <option value="MY" ${param.ownerId == 'MY' ? 'selected' : ''}>Lead của tôi</option>
                            <c:forEach var="owner" items="${owners}">
                                <option value="${owner.accountId}" ${param.ownerId == owner.accountId ? 'selected' : ''}>
                                    <c:out value="${owner.fullName}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- Hàng 2: Khoảng thời gian, Lọc Quá SLA, Thao tác Lọc và Lưu bộ lọc -->
                <div class="filter-grid-row-2">
                    <div class="filter-date-group">
                        <span class="filter-label"><i class="fa-regular fa-calendar-days"></i> Thời gian:</span>
                        <input type="date" name="fromDate" value="<c:out value='${param.fromDate}'/>" class="form-control filter-date-input" title="Từ ngày">
                        <span style="font-size: 13px; color: #94a3b8;">→</span>
                        <input type="date" name="toDate" value="<c:out value='${param.toDate}'/>" class="form-control filter-date-input" title="Đến ngày">
                    </div>

                    <!-- Toggle Lọc Lead Quá SLA (S4-09-AC-02) -->
                    <div class="filter-sla-toggle" title="Lọc các Lead chưa được xử lý quá thời hạn phản hồi quy định">
                        <input type="checkbox" id="overdueCheckbox" name="overdue" value="true" ${param.overdue == 'true' ? 'checked' : ''}>
                        <label for="overdueCheckbox">
                            <i class="fa-solid fa-triangle-exclamation"></i> Chỉ hiển thị Lead quá SLA
                        </label>
                    </div>

                    <!-- Cụm nút thao tác -->
                    <div class="filter-action-buttons">
                        <button type="submit" class="btn-filter-submit" id="btn-submit-filter">
                            <i class="fa-solid fa-filter"></i> Lọc dữ liệu
                        </button>
                        <a href="${pageContext.request.contextPath}/leads" class="btn-filter-reset" title="Đặt lại bộ lọc về mặc định">
                            <i class="fa-solid fa-rotate-left"></i> Đặt lại
                        </a>
                        <button type="button" class="btn-filter-save" onclick="openSaveLeadFilterModal()" title="Lưu các điều kiện lọc hiện tại để tái sử dụng mỗi ngày">
                            <i class="fa-solid fa-bookmark"></i> Lưu bộ lọc này
                        </button>
                    </div>
                </div>

                <!-- Dải hiển thị danh sách Saved Filters nhanh -->
                <c:if test="${not empty savedFilters}">
                    <div class="saved-filters-bar">
                        <span class="saved-filters-label">
                            <i class="fa-solid fa-star" style="color: #f59e0b;"></i> Bộ lọc nhanh:
                        </span>
                        <c:forEach var="sf" items="${savedFilters}">
                            <div class="saved-filter-chip" onclick="window.location.href='${pageContext.request.contextPath}/leads?${sf.filterQuery != null ? sf.filterQuery : sf.criteria}'" title="Nhấp để áp dụng bộ lọc '${sf.filterName != null ? sf.filterName : sf.name}'">
                                <i class="fa-solid fa-filter"></i>
                                <span><c:out value="${sf.filterName != null ? sf.filterName : sf.name}"/></span>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </form>

            <!-- Lead List Table Card -->
            <div class="lead-table-card">
                <div class="lead-table-header">
                    <h2 class="lead-table-title">
                        <i class="fa-solid fa-users-viewfinder" style="color: #2563eb;"></i>
                        Danh sách Lead
                        <span class="lead-badge-count">${leadCountDisplay}</span>
                    </h2>
                    <div class="lead-sort-pill">
                        <i class="fa-solid fa-arrow-down-wide-short"></i>
                        <span>Sắp xếp theo: <strong>Điểm số ưu tiên (Giảm dần)</strong></span>
                    </div>
                </div>

                <div class="table-container" style="overflow-x: auto;">
                    <table class="lead-modern-table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Họ và tên</th>
                                <th>Công ty</th>
                                <th>Liên hệ</th>
                                <th>Nguồn</th>
                                <th>Trạng thái</th>
                                <th>Điểm Lead</th>
                                <th>Phân loại</th>
                                <th>Người phụ trách</th>
                                <th>Cảnh báo SLA</th>
                                <th style="width: 130px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty leadItems}">
                                    <c:forEach var="item" items="${leadItems}">
                                        <c:set var="currentLeadId" value="${item.leadId}"/>
                                        <c:set var="currentCompany" value="${not empty item.company ? item.company : '-'}"/>
                                        <c:set var="currentSource" value="${not empty item.sourceName ? item.sourceName : 'Chưa rõ'}"/>
                                        <c:set var="leadScore" value="${item.score != null ? item.score : 0}"/>
                                        <tr class="${item.slaOverdue ? 'row-sla-overdue' : ''}">
                                            <td style="font-weight: 600; color: #64748b;">#${currentLeadId}</td>
                                            <td>
                                                <div class="lead-avatar-cell">
                                                    <div class="lead-avatar-circle">
                                                        <c:choose>
                                                            <c:when test="${not empty item.fullName}">
                                                                ${item.fullName.substring(0, 1).toUpperCase()}
                                                            </c:when>
                                                            <c:otherwise>L</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="lead-name-box">
                                                        <a href="${pageContext.request.contextPath}/leads/detail?id=${currentLeadId}" class="lead-name-link" title="Xem hồ sơ chi tiết Lead #${currentLeadId}">
                                                            <c:out value="${item.fullName}"/>
                                                        </a>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div style="display: flex; align-items: center; gap: 6px;">
                                                    <i class="fa-regular fa-building" style="color: #94a3b8; font-size: 0.8rem;"></i>
                                                    <span><c:out value="${currentCompany}"/></span>
                                                </div>
                                            </td>
                                            <td>
                                                <c:if test="${not empty item.email}">
                                                    <div class="lead-contact-item">
                                                        <i class="fa-regular fa-envelope"></i>
                                                        <a href="mailto:${item.email}" class="lead-contact-link"><c:out value="${item.email}"/></a>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty item.phone}">
                                                    <div class="lead-contact-item">
                                                        <i class="fa-solid fa-phone"></i>
                                                        <a href="tel:${item.phone}" class="lead-contact-link"><c:out value="${item.phone}"/></a>
                                                    </div>
                                                </c:if>
                                                <c:if test="${empty item.email && empty item.phone}">
                                                    <span style="color: #94a3b8;">-</span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="badge" style="background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; border-radius: 6px; padding: 3px 8px; font-weight: 600; font-size: 0.76rem;">
                                                    <c:out value="${currentSource}"/>
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.status == 'NEW' || item.status == 'Mới' || item.status == 'Mới tạo'}">
                                                        <span class="lead-status-pill status-new"><span class="lead-status-dot"></span> Mới tạo</span>
                                                    </c:when>
                                                    <c:when test="${item.status == 'CONTACTED' || item.status == 'Đang liên hệ'}">
                                                        <span class="lead-status-pill status-contacted"><span class="lead-status-dot"></span> Đang liên hệ</span>
                                                    </c:when>
                                                    <c:when test="${item.status == 'QUALIFIED' || item.status == 'Tiềm năng'}">
                                                        <span class="lead-status-pill status-qualified"><span class="lead-status-dot"></span> Đã xác định NC</span>
                                                    </c:when>
                                                    <c:when test="${item.status == 'CONVERTED' || item.status == 'Đã chuyển đổi'}">
                                                        <span class="lead-status-pill status-converted"><span class="lead-status-dot"></span> Đã chuyển đổi</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="lead-status-pill status-unqualified"><span class="lead-status-dot"></span> <c:out value="${item.status}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <!-- Điểm số Lead (Scoring) -->
                                            <td>
                                                <span class="lead-score-badge ${leadScore >= 70 ? 'score-high' : (leadScore >= 40 ? 'score-med' : 'score-low')}">
                                                    <i class="fa-solid fa-bolt"></i> ${leadScore} đ
                                                </span>
                                            </td>
                                            <!-- Nhãn phân loại Nóng / Ấm / Lạnh -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.classification == 'HOT' || item.rating == 'HOT' || leadScore >= 70}">
                                                        <span class="lead-rating-badge rating-hot"><i class="fa-solid fa-fire"></i> NÓNG</span>
                                                    </c:when>
                                                    <c:when test="${item.classification == 'WARM' || item.rating == 'WARM' || (leadScore >= 40 && leadScore < 70)}">
                                                        <span class="lead-rating-badge rating-warm"><i class="fa-solid fa-sun"></i> ẤM</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="lead-rating-badge rating-cold"><i class="fa-solid fa-snowflake"></i> LẠNH</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div style="display: flex; align-items: center; gap: 6px; font-weight: 500;">
                                                    <i class="fa-solid fa-circle-user" style="color: #64748b; font-size: 0.85rem;"></i>
                                                    <span><c:out value="${item.ownerName != null ? item.ownerName : (item.ownerId != null ? item.ownerId : 'Chưa phân bổ')}"/></span>
                                                </div>
                                            </td>
                                            <!-- Nổi bật Lead quá SLA (S4-09-AC-02) -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.slaOverdue}">
                                                        <span class="lead-sla-badge lead-sla-overdue" title="Lead quá thời hạn phản hồi quy định!">
                                                            <i class="fa-solid fa-triangle-exclamation"></i> Quá SLA
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="lead-sla-ok"><i class="fa-solid fa-circle-check"></i> Trong hạn</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <div class="lead-action-group">
                                                    <a href="${pageContext.request.contextPath}/leads/detail?id=${currentLeadId}" class="btn-lead-icon btn-lead-icon-view" title="Xem chi tiết hồ sơ Lead">
                                                        <i class="fa-solid fa-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/update?id=${currentLeadId}" class="btn-lead-icon btn-lead-icon-edit" title="Chỉnh sửa thông tin">
                                                        <i class="fa-solid fa-pen-to-square"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/convert?leadId=${currentLeadId}" class="btn-lead-icon btn-lead-icon-convert" title="Chuyển đổi sang Khách hàng / Cơ hội">
                                                        <i class="fa-solid fa-arrow-right-arrow-left"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="11">
                                            <div class="lead-empty-container">
                                                <div class="lead-empty-icon-glow">
                                                    <i class="fa-solid fa-filter-circle-xmark"></i>
                                                </div>
                                                <div class="lead-empty-title">
                                                    Không tìm thấy Lead nào phù hợp với bộ lọc
                                                </div>
                                                <div class="lead-empty-desc">
                                                    Hãy thử nới lỏng các điều kiện lọc, tìm kiếm theo từ khóa khác hoặc đặt lại bộ lọc để xem toàn bộ danh sách.
                                                </div>
                                                <div class="lead-empty-actions">
                                                    <a href="${pageContext.request.contextPath}/leads" class="btn-filter-reset">
                                                        <i class="fa-solid fa-rotate-left"></i> Đặt lại bộ lọc
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/create" class="btn-lead-primary">
                                                        <i class="fa-solid fa-plus"></i> Tạo Lead mới
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Phân trang (Pagination) -->
                <c:if test="${not empty totalPages && totalPages > 1}">
                    <div class="lead-pagination-bar">
                        <div class="lead-page-info">
                            Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng: <strong>${totalLeads}</strong> Lead)
                        </div>
                        <div class="lead-page-nav">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/leads?page=${currentPage - 1}&keyword=${param.keyword}&status=${param.status}&rating=${param.rating}&classification=${param.classification}&ownerId=${param.ownerId}&source=${param.source}&fromDate=${param.fromDate}&toDate=${param.toDate}&overdue=${param.overdue}" class="btn-page-step">
                                    <i class="fa-solid fa-chevron-left"></i> Trang trước
                                </a>
                            </c:if>
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/leads?page=${currentPage + 1}&keyword=${param.keyword}&status=${param.status}&rating=${param.rating}&classification=${param.classification}&ownerId=${param.ownerId}&source=${param.source}&fromDate=${param.fromDate}&toDate=${param.toDate}&overdue=${param.overdue}" class="btn-page-step">
                                    Trang sau <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<!-- Modal Lưu Bộ Lọc Lead (S4-09-AC-03) -->
<div id="saveLeadFilterModal" class="lead-modal-backdrop" onclick="if(event.target === this) closeSaveLeadFilterModal();">
    <div class="lead-modal-box">
        <div class="lead-modal-header">
            <h3 class="lead-modal-title">
                <i class="fa-solid fa-bookmark" style="color: #2563eb;"></i>
                Lưu bộ lọc Lead thường dùng
            </h3>
            <button type="button" class="lead-modal-close" onclick="closeSaveLeadFilterModal()" title="Đóng modal">&times;</button>
        </div>
        <form id="saveLeadFilterForm" onsubmit="submitSaveLeadFilter(event)">
            <div class="lead-modal-body">
                <div style="margin-bottom: 16px;">
                    <label class="filter-label" for="leadFilterNameInput">
                        Đặt tên cho bộ lọc <span style="color:#ef4444">*</span>
                    </label>
                    <input type="text" id="leadFilterNameInput" class="form-control" placeholder="VD: Lead Nóng cần gọi sáng nay, Quá SLA..." required style="height: 42px; border-radius: 9px; padding: 10px 14px; font-size: 0.88rem;">
                </div>

                <!-- Tóm tắt các điều kiện đang được lưu (S4-09 requirement) -->
                <div class="filter-summary-card">
                    <div class="filter-summary-card-title">
                        <i class="fa-solid fa-list-check" style="color: #2563eb;"></i>
                        Tóm tắt các điều kiện lọc sẽ lưu:
                    </div>
                    <div id="filterSummaryChipsList" class="filter-summary-chips-list">
                        <!-- Tự động sinh nội dung từ JavaScript khi mở modal -->
                    </div>
                </div>

                <p style="font-size: 0.78rem; color: #64748b; margin: 0; line-height: 1.5;">
                    <i class="fa-solid fa-circle-info" style="color: #0284c7;"></i>
                    Bộ lọc này sẽ được lưu vào danh sách của bạn để áp dụng nhanh chỉ với một cú nhấp chuột mỗi ngày.
                </p>
            </div>
            <div class="lead-modal-footer">
                <button type="button" class="btn-filter-reset" onclick="closeSaveLeadFilterModal()">Hủy</button>
                <button type="submit" class="btn-filter-submit" id="btnSubmitSaveFilter">
                    <i class="fa-solid fa-floppy-disk"></i> Lưu bộ lọc
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openSaveLeadFilterModal() {
        const input = document.getElementById('leadFilterNameInput');
        if (input) input.value = '';

        // Tóm tắt các điều kiện lọc đang có trong form
        const filterForm = document.getElementById('leadFilterForm');
        const summaryContainer = document.getElementById('filterSummaryChipsList');
        if (filterForm && summaryContainer) {
            summaryContainer.innerHTML = '';
            const formData = new FormData(filterForm);
            const chips = [];

            const kw = formData.get('keyword');
            if (kw && kw.trim()) chips.push('<span class="summary-chip-item"><i class="fa-solid fa-magnifying-glass"></i> Từ khóa: <strong>' + escapeHtml(kw.trim()) + '</strong></span>');

            const status = formData.get('status');
            if (status) {
                const statusSelect = filterForm.querySelector('select[name="status"]');
                const text = statusSelect ? statusSelect.options[statusSelect.selectedIndex].text : status;
                chips.push('<span class="summary-chip-item"><i class="fa-solid fa-list-check"></i> Trạng thái: <strong>' + escapeHtml(text) + '</strong></span>');
            }

            const source = formData.get('source');
            if (source) chips.push('<span class="summary-chip-item"><i class="fa-solid fa-share-nodes"></i> Nguồn: <strong>' + escapeHtml(source) + '</strong></span>');

            const classification = formData.get('classification');
            if (classification) {
                const clsSelect = filterForm.querySelector('select[name="classification"]');
                const text = clsSelect ? clsSelect.options[clsSelect.selectedIndex].text : classification;
                chips.push('<span class="summary-chip-item"><i class="fa-solid fa-fire"></i> Phân loại: <strong>' + escapeHtml(text) + '</strong></span>');
            }

            const ownerId = formData.get('ownerId');
            if (ownerId) {
                const ownerSelect = filterForm.querySelector('select[name="ownerId"]');
                const text = ownerSelect ? ownerSelect.options[ownerSelect.selectedIndex].text : ownerId;
                chips.push('<span class="summary-chip-item"><i class="fa-solid fa-user"></i> Phụ trách: <strong>' + escapeHtml(text) + '</strong></span>');
            }

            const fromDate = formData.get('fromDate');
            const toDate = formData.get('toDate');
            if (fromDate || toDate) {
                chips.push('<span class="summary-chip-item"><i class="fa-regular fa-calendar-days"></i> Ngày: <strong>' + (fromDate || '...') + ' → ' + (toDate || '...') + '</strong></span>');
            }

            const overdue = formData.get('overdue');
            if (overdue === 'true') {
                chips.push('<span class="summary-chip-item" style="color: #dc2626; border-color: #fecaca; background: #fff5f5;"><i class="fa-solid fa-triangle-exclamation"></i> <strong>Chỉ Lead quá SLA</strong></span>');
            }

            if (chips.length === 0) {
                summaryContainer.innerHTML = '<span style="font-size: 12px; color: var(--color-text-secondary); font-style: italic;">Tất cả Lead (không giới hạn tiêu chí)</span>';
            } else {
                summaryContainer.innerHTML = chips.join('');
            }
        }

        const modal = document.getElementById('saveLeadFilterModal');
        if (modal) {
            modal.style.display = 'flex';
            setTimeout(() => { if (input) input.focus(); }, 100);
        }
    }

    function closeSaveLeadFilterModal() {
        const modal = document.getElementById('saveLeadFilterModal');
        if (modal) modal.style.display = 'none';
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeSaveLeadFilterModal();
        }
    });

    function escapeHtml(str) {
        if (!str) return '';
        return String(str).replace(/[&<>"']/g, function (m) {
            return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[m];
        });
    }

    function submitSaveLeadFilter(e) {
        e.preventDefault();
        const filterName = document.getElementById('leadFilterNameInput').value.trim();
        if (!filterName) {
            if (typeof window.showToast === 'function') {
                window.showToast('warning', 'Vui lòng nhập tên cho bộ lọc.');
            }
            return;
        }

        const filterForm = document.getElementById('leadFilterForm');
        const formData = new FormData(filterForm);
        const params = new URLSearchParams(formData);
        params.append('filterName', filterName);

        const btn = document.getElementById('btnSubmitSaveFilter');
        const originalHtml = btn ? btn.innerHTML : '';
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
        }

        fetch('${pageContext.request.contextPath}/leads/filters', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'Accept': 'application/json, text/html, */*'
            },
            body: params
        })
        .then(res => {
            if (res.ok) {
                if (typeof window.showToast === 'function') {
                    window.showToast('success', 'Lưu bộ lọc "' + filterName + '" thành công!');
                }
                closeSaveLeadFilterModal();
                setTimeout(() => window.location.reload(), 800);
            } else {
                throw new Error('HTTP ' + res.status);
            }
        })
        .catch(err => {
            console.warn('Backend endpoint /leads/filters response:', err);
            if (typeof window.showToast === 'function') {
                window.showToast('info', 'Đã gửi yêu cầu lưu bộ lọc tới hệ thống.');
            }
            closeSaveLeadFilterModal();
        })
        .finally(() => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalHtml;
            }
        });
    }
</script>
</body>
</html>
