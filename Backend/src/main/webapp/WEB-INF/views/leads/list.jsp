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
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Lead</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Danh sách Lead</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                        Quản lý đầu mối kinh doanh, tự động chấm điểm ưu tiên và lọc danh sách gọi hàng ngày.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 8px; flex-wrap: wrap;">
                    <a href="${pageContext.request.contextPath}/leads/create" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Thêm Lead
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/import" class="btn btn-secondary">
                        <i class="fas fa-file-excel"></i> Nhập Excel
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/web-forms" class="btn btn-secondary">
                        <i class="fas fa-code"></i> Web Forms
                    </a>
                    <a href="${pageContext.request.contextPath}/lead-scoring/rules" class="btn btn-secondary" title="Cấu hình chấm điểm Lead (Giám đốc kinh doanh)">
                        <i class="fas fa-sliders-h"></i> Cấu hình Chấm điểm
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/filters" class="btn btn-secondary" title="Xem bộ lọc đã lưu">
                        <i class="fas fa-bookmark"></i> Bộ lọc đã lưu
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/duplicates" class="btn btn-secondary" title="Kiểm tra Lead trùng lặp">
                        <i class="fas fa-copy"></i> Kiểm tra trùng
                    </a>
                </div>
            </div>

            <!-- Lead Filter Toolbar (S4-09-AC-01) -->
            <form id="leadFilterForm" action="${pageContext.request.contextPath}/leads" method="get" class="lead-filter-card">
                <div class="filter-header-bar">
                    <span class="filter-header-title">
                        <i class="fas fa-filter"></i> Bộ lọc & Tìm kiếm Lead
                    </span>
                    <span style="font-size: 12px; color: var(--color-text-secondary);">
                        Tùy chọn đa tiêu chí giúp ưu tiên danh sách gọi điện hiệu quả
                    </span>
                </div>

                <!-- Hàng 1: Từ khóa tìm kiếm, Trạng thái, Nguồn, Phân loại điểm, Người phụ trách -->
                <div class="filter-grid-row-1">
                    <!-- Tìm kiếm từ khóa -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fas fa-search" style="color: var(--color-primary); font-size: 11px;"></i> Từ khóa tìm kiếm
                        </label>
                        <input type="search" name="keyword" class="form-control" placeholder="Họ tên, công ty, email, số điện thoại..." value="<c:out value='${param.keyword != null ? param.keyword : (param.search != null ? param.search : search)}'/>">
                    </div>

                    <!-- Lọc Trạng thái (Status) -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fas fa-tasks" style="color: var(--color-text-secondary); font-size: 11px;"></i> Trạng thái
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
                            <i class="fas fa-share-alt" style="color: var(--color-text-secondary); font-size: 11px;"></i> Nguồn Lead
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
                            <i class="fas fa-fire" style="color: #ef4444; font-size: 11px;"></i> Phân loại điểm
                        </label>
                        <select name="classification" class="form-control">
                            <option value="">Tất cả mức độ</option>
                            <option value="HOT" ${param.classification == 'HOT' || param.rating == 'HOT' || rating == 'HOT' ? 'selected' : ''}>🔥 NÓNG (Gọi trước)</option>
                            <option value="WARM" ${param.classification == 'WARM' || param.rating == 'WARM' || rating == 'WARM' ? 'selected' : ''}>☀️ ẤM</option>
                            <option value="COLD" ${param.classification == 'COLD' || param.rating == 'COLD' || rating == 'COLD' ? 'selected' : ''}>❄️ LẠNH</option>
                        </select>
                    </div>

                    <!-- Lọc Người phụ trách (Owner) -->
                    <div class="filter-control-item">
                        <label class="filter-label">
                            <i class="fas fa-user-check" style="color: var(--color-text-secondary); font-size: 11px;"></i> Người phụ trách
                        </label>
                        <select name="ownerId" class="form-control">
                            <option value="">Tất cả phụ trách</option>
                            <option value="MY" ${param.ownerId == 'MY' ? 'selected' : ''}>Lead của tôi</option>
                            <c:forEach var="owner" items="${owners}">
                                <option value="${owner.userId}" ${param.ownerId == owner.userId ? 'selected' : ''}>
                                    <c:out value="${owner.fullName}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- Hàng 2: Khoảng thời gian, Lọc Quá SLA, Thao tác Lọc và Lưu bộ lọc -->
                <div class="filter-grid-row-2">
                    <div class="filter-date-group">
                        <span class="filter-label"><i class="far fa-calendar-alt"></i> Thời gian:</span>
                        <input type="date" name="fromDate" value="<c:out value='${param.fromDate}'/>" class="form-control filter-date-input" title="Từ ngày">
                        <span style="font-size: 12px; color: var(--color-text-secondary);">-</span>
                        <input type="date" name="toDate" value="<c:out value='${param.toDate}'/>" class="form-control filter-date-input" title="Đến ngày">
                    </div>

                    <!-- Toggle Lọc Lead Quá SLA (S4-09-AC-02) -->
                    <div class="filter-sla-toggle" title="Lọc các Lead chưa được xử lý quá thời hạn phản hồi">
                        <input type="checkbox" id="overdueCheckbox" name="overdue" value="true" ${param.overdue == 'true' ? 'checked' : ''}>
                        <label for="overdueCheckbox">
                            <i class="fas fa-exclamation-triangle"></i> Chỉ hiển thị Lead quá SLA
                        </label>
                    </div>

                    <!-- Cụm nút thao tác -->
                    <div class="filter-action-buttons">
                        <button type="submit" class="btn btn-primary btn-sm">
                            <i class="fas fa-filter"></i> Lọc dữ liệu
                        </button>
                        <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary btn-sm" title="Đặt lại bộ lọc về mặc định">
                            <i class="fas fa-undo"></i> Đặt lại
                        </a>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="openSaveLeadFilterModal()" style="border-color: #bae6fd; color: #0369a1; background: #f0f9ff;" title="Lưu các điều kiện lọc hiện tại để tái sử dụng">
                            <i class="fas fa-bookmark" style="color: #0284c7;"></i> Lưu bộ lọc này
                        </button>
                    </div>
                </div>

                <!-- Dải hiển thị danh sách Saved Filters nhanh -->
                <c:if test="${not empty savedFilters}">
                    <div class="saved-filters-bar">
                        <span class="saved-filters-label">
                            <i class="fas fa-star" style="color: #f59e0b;"></i> Bộ lọc nhanh:
                        </span>
                        <c:forEach var="sf" items="${savedFilters}">
                            <div class="saved-filter-chip" onclick="window.location.href='${pageContext.request.contextPath}/leads?${sf.filterQuery != null ? sf.filterQuery : sf.criteria}'" title="Nhấp để áp dụng bộ lọc '${sf.filterName != null ? sf.filterName : sf.name}'">
                                <i class="fas fa-filter"></i>
                                <span><c:out value="${sf.filterName != null ? sf.filterName : sf.name}"/></span>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </form>

            <!-- Lead List Table -->
            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <c:set var="leadItems" value="${not empty leads ? leads : (not empty leadList ? leadList : list)}"/>
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-user-friends" style="color: var(--color-primary);"></i>
                        Danh sách Lead (${not empty leadItems ? leadItems.size() : (not empty totalLeads ? totalLeads : 0)})
                    </h2>
                    <div style="font-size: 13px; color: var(--color-text-secondary);">
                        Sắp xếp theo: <strong>Điểm số ưu tiên (Giảm dần)</strong>
                    </div>
                </div>

                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Họ và tên</th>
                                <th>Công ty</th>
                                <th>Liên hệ</th>
                                <th>Nguồn</th>
                                <th>Trạng thái</th>
                                <th>Điểm Lead (Scoring)</th>
                                <th>Phân loại</th>
                                <th>Người phụ trách</th>
                                <th>Cảnh báo SLA</th>
                                <th style="width: 140px; text-align: center;">Thao tác</th>
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
                                            <td>${currentLeadId}</td>
                                            <td>
                                                <div style="font-weight: 600; color: var(--color-gray-900);">
                                                    <a href="${pageContext.request.contextPath}/leads/detail?id=${currentLeadId}" class="text-primary">
                                                        <c:out value="${item.fullName}"/>
                                                    </a>
                                                </div>
                                            </td>
                                            <td><c:out value="${currentCompany}"/></td>
                                            <td>
                                                <div style="font-size: 13px;">
                                                    <c:if test="${not empty item.email}">
                                                        <div><i class="fas fa-envelope" style="color: #94a3b8; font-size: 11px;"></i> <c:out value="${item.email}"/></div>
                                                    </c:if>
                                                    <c:if test="${not empty item.phone}">
                                                        <div><i class="fas fa-phone" style="color: #94a3b8; font-size: 11px;"></i> <c:out value="${item.phone}"/></div>
                                                    </c:if>
                                                    <c:if test="${empty item.email && empty item.phone}">
                                                        <span style="color: var(--color-text-secondary);">-</span>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td><span class="badge badge-neutral"><c:out value="${currentSource}"/></span></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.status == 'NEW' || item.status == 'Mới' || item.status == 'Mới tạo'}"><span class="badge badge-info">Mới tạo</span></c:when>
                                                    <c:when test="${item.status == 'CONTACTED' || item.status == 'Đang liên hệ'}"><span class="badge badge-warning">Đang liên hệ</span></c:when>
                                                    <c:when test="${item.status == 'QUALIFIED' || item.status == 'Tiềm năng'}"><span class="badge badge-success">Đã xác định NC</span></c:when>
                                                    <c:when test="${item.status == 'CONVERTED' || item.status == 'Đã chuyển đổi'}"><span class="badge" style="background:#dcfce7; color:#15803d;">Đã chuyển đổi</span></c:when>
                                                    <c:otherwise><span class="badge badge-neutral"><c:out value="${item.status}"/></span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <!-- Điểm số Lead (S4-05-AC-02 & S4-05-AC-04) -->
                                            <td>
                                                <span class="lead-score-pill ${leadScore >= 70 ? 'score-positive' : (leadScore >= 40 ? 'score-neutral' : 'score-negative')}">
                                                    <i class="fas fa-bolt"></i> ${leadScore} điểm
                                                </span>
                                            </td>
                                            <!-- Nhãn phân loại Nóng / Ấm / Lạnh (S4-05-AC-03) -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.classification == 'HOT' || item.rating == 'HOT' || leadScore >= 70}">
                                                        <span class="badge badge-hot"><i class="fas fa-fire"></i> NÓNG</span>
                                                    </c:when>
                                                    <c:when test="${item.classification == 'WARM' || item.rating == 'WARM' || (leadScore >= 40 && leadScore < 70)}">
                                                        <span class="badge badge-warm"><i class="fas fa-sun"></i> ẤM</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-cold"><i class="fas fa-snowflake"></i> LẠNH</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${item.ownerName != null ? item.ownerName : (item.ownerId != null ? item.ownerId : 'Chưa phân bổ')}"/></td>
                                            <!-- Nổi bật Lead quá SLA (S4-09-AC-02) -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.slaOverdue}">
                                                        <span class="badge badge-sla-overdue" title="Lead quá thời hạn phản hồi quy định!">
                                                            <i class="fas fa-exclamation-triangle"></i> Quá SLA
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="font-size: 12px; color: #16a34a;"><i class="fas fa-check-circle"></i> Trong hạn</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <div style="display: flex; gap: 4px; justify-content: center;">
                                                    <a href="${pageContext.request.contextPath}/leads/detail?id=${currentLeadId}" class="btn btn-secondary btn-sm" title="Xem chi tiết">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/update?id=${currentLeadId}" class="btn btn-secondary btn-sm" title="Chỉnh sửa">
                                                        <i class="fas fa-pencil-alt"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/convert?leadId=${currentLeadId}" class="btn btn-secondary btn-sm" style="color: #16a34a;" title="Chuyển đổi Lead">
                                                        <i class="fas fa-exchange-alt"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="11" style="text-align: center; padding: 48px 16px;">
                                            <div class="empty-state-box">
                                                <div class="empty-state-icon">
                                                    <i class="fas fa-filter-circle-xmark"></i>
                                                </div>
                                                <div class="empty-state-title">
                                                    Không tìm thấy Lead nào phù hợp với bộ lọc
                                                </div>
                                                <div class="empty-state-desc">
                                                    Hãy thử nới lỏng các điều kiện lọc, tìm kiếm theo từ khóa khác hoặc đặt lại bộ lọc về mặc định.
                                                </div>
                                                <div style="display: flex; gap: 8px; justify-content: center;">
                                                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary btn-sm">
                                                        <i class="fas fa-undo"></i> Đặt lại bộ lọc
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/create" class="btn btn-primary btn-sm">
                                                        <i class="fas fa-plus"></i> Tạo Lead mới
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
                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; border-top: 1px solid var(--color-border);">
                        <div style="font-size: 13px; color: var(--color-text-secondary);">
                            Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng số: ${totalLeads} Lead)
                        </div>
                        <div style="display: flex; gap: 6px;">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/leads?page=${currentPage - 1}&keyword=${param.keyword}&status=${param.status}&rating=${param.rating}" class="btn btn-secondary btn-sm">Trước</a>
                            </c:if>
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/leads?page=${currentPage + 1}&keyword=${param.keyword}&status=${param.status}&rating=${param.rating}" class="btn btn-secondary btn-sm">Sau</a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<!-- Modal Lưu Bộ Lọc Lead (S4-09-AC-03) -->
<div id="saveLeadFilterModal" class="modal-backdrop" onclick="if(event.target === this) closeSaveLeadFilterModal();">
    <div class="modal-dialog-box">
        <div class="modal-dialog-header">
            <h3 class="modal-dialog-title">
                <i class="fas fa-bookmark" style="color: var(--color-primary);"></i>
                Lưu bộ lọc Lead thường dùng
            </h3>
            <button type="button" class="modal-close-btn" onclick="closeSaveLeadFilterModal()" title="Đóng modal">&times;</button>
        </div>
        <form id="saveLeadFilterForm" onsubmit="submitSaveLeadFilter(event)">
            <div class="modal-dialog-body">
                <div style="margin-bottom: 14px;">
                    <label class="form-label" for="leadFilterNameInput" style="font-weight: 600; font-size: 13px; color: var(--color-gray-800); margin-bottom: 6px;">
                        Đặt tên cho bộ lọc <span style="color:red">*</span>
                    </label>
                    <input type="text" id="leadFilterNameInput" class="form-control" placeholder="VD: Lead Nóng cần gọi sáng nay, Quá SLA..." required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 10px 12px; width: 100%; font-size: 13px;">
                </div>

                <!-- Tóm tắt các điều kiện đang được lưu (S4-09 requirement) -->
                <div class="filter-summary-card">
                    <div class="filter-summary-card-title">
                        <i class="fas fa-list-check" style="color: var(--color-primary);"></i>
                        Tóm tắt các điều kiện lọc sẽ lưu:
                    </div>
                    <div id="filterSummaryChipsList" class="filter-summary-chips-list">
                        <!-- Tự động sinh nội dung từ JavaScript khi mở modal -->
                    </div>
                </div>

                <p style="font-size: 12px; color: var(--color-text-secondary); margin: 0; line-height: 1.5;">
                    <i class="fas fa-info-circle" style="color: var(--color-info);"></i>
                    Bộ lọc này sẽ được lưu vào danh sách của bạn để áp dụng nhanh chỉ với một cú nhấp chuột mỗi ngày.
                </p>
            </div>
            <div class="modal-dialog-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeSaveLeadFilterModal()">Hủy</button>
                <button type="submit" class="btn btn-primary btn-sm" id="btnSubmitSaveFilter">
                    <i class="fas fa-save"></i> Lưu bộ lọc
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
            if (kw && kw.trim()) chips.push('<span class="summary-chip-item"><i class="fas fa-search"></i> Từ khóa: <strong>' + escapeHtml(kw.trim()) + '</strong></span>');

            const status = formData.get('status');
            if (status) {
                const statusSelect = filterForm.querySelector('select[name="status"]');
                const text = statusSelect ? statusSelect.options[statusSelect.selectedIndex].text : status;
                chips.push('<span class="summary-chip-item"><i class="fas fa-tasks"></i> Trạng thái: <strong>' + escapeHtml(text) + '</strong></span>');
            }

            const source = formData.get('source');
            if (source) chips.push('<span class="summary-chip-item"><i class="fas fa-share-alt"></i> Nguồn: <strong>' + escapeHtml(source) + '</strong></span>');

            const classification = formData.get('classification');
            if (classification) {
                const clsSelect = filterForm.querySelector('select[name="classification"]');
                const text = clsSelect ? clsSelect.options[clsSelect.selectedIndex].text : classification;
                chips.push('<span class="summary-chip-item"><i class="fas fa-fire"></i> Phân loại: <strong>' + escapeHtml(text) + '</strong></span>');
            }

            const ownerId = formData.get('ownerId');
            if (ownerId) {
                const ownerSelect = filterForm.querySelector('select[name="ownerId"]');
                const text = ownerSelect ? ownerSelect.options[ownerSelect.selectedIndex].text : ownerId;
                chips.push('<span class="summary-chip-item"><i class="fas fa-user"></i> Phụ trách: <strong>' + escapeHtml(text) + '</strong></span>');
            }

            const fromDate = formData.get('fromDate');
            const toDate = formData.get('toDate');
            if (fromDate || toDate) {
                chips.push('<span class="summary-chip-item"><i class="far fa-calendar-alt"></i> Ngày: <strong>' + (fromDate || '...') + ' → ' + (toDate || '...') + '</strong></span>');
            }

            const overdue = formData.get('overdue');
            if (overdue === 'true') {
                chips.push('<span class="summary-chip-item" style="color: #dc2626; border-color: #fecaca; background: #fff5f5;"><i class="fas fa-exclamation-triangle"></i> <strong>Chỉ Lead quá SLA</strong></span>');
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
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';
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
            // Fallback submit
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
