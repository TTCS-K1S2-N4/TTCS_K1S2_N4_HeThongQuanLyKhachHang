<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Bộ lọc Lead đã lưu | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/leads"><i class="fas fa-user-friends"></i> Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Bộ lọc Lead đã lưu</span>
            </nav>

            <!-- Page Header -->
            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <h1 class="page-title" style="margin: 0;">Bộ lọc Lead đã lưu (Saved Filters)</h1>
                        <span class="badge badge-info" style="font-size: 11px;"><i class="fas fa-bookmark"></i> S4-09</span>
                    </div>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin: 0; line-height: 1.5;">
                        Quản lý các bộ lọc cá nhân giúp Nhân viên kinh doanh mở máy buổi sáng là biết ngay cần gọi ai.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-primary">
                        <i class="fas fa-arrow-left"></i> Quay lại Danh sách Lead
                    </a>
                </div>
            </div>

            <!-- Global Feedback Notifications -->
            <c:if test="${not empty errorMessage and empty param.error and empty param.err}">
                <div class="alert alert-danger scoring-notification-banner" style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><c:out value="${errorMessage}"/></span>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty successMessage and empty param.success}">
                <div class="alert alert-success scoring-notification-banner" style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-check-circle"></i>
                        <span><c:out value="${successMessage}"/></span>
                    </div>
                </div>
            </c:if>

            <!-- Saved Filters Card -->
            <div class="scoring-card">
                <div class="scoring-card-header">
                    <div>
                        <h2 class="scoring-card-title">
                            <i class="fas fa-bookmark" style="color: var(--color-primary);"></i>
                            Danh sách bộ lọc đã lưu của bạn
                        </h2>
                        <div class="scoring-card-subtitle">
                            Nhấp "Áp dụng" để chuyển trực tiếp đến Danh sách Lead với đầy đủ các điều kiện đã chọn.
                        </div>
                    </div>
                    <div>
                        <span class="rule-table-count" style="font-size: 13px; padding: 4px 10px;">
                            ${not empty savedFilters ? savedFilters.size() : 0} bộ lọc
                        </span>
                    </div>
                </div>

                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 50px; text-align: center;">#</th>
                                <th style="width: 240px;">Tên bộ lọc</th>
                                <th>Chi tiết tiêu chí lọc</th>
                                <th style="width: 160px;">Ngày tạo</th>
                                <th style="width: 170px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty savedFilters}">
                                    <c:forEach var="filter" items="${savedFilters}" varStatus="status">
                                        <c:set var="rawQuery" value="${filter.filterQuery != null ? filter.filterQuery : filter.criteria}"/>
                                        <tr>
                                            <td style="text-align: center; color: var(--color-text-secondary); font-weight: 500;">
                                                ${status.count}
                                            </td>
                                            <td>
                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <i class="fas fa-star" style="color: #f59e0b; font-size: 13px;"></i>
                                                    <strong style="color: var(--color-gray-900); font-size: 14px;">
                                                        <c:out value="${filter.filterName != null ? filter.filterName : filter.name}"/>
                                                    </strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="saved-filter-criteria-chips" data-query="<c:out value='${rawQuery}'/>" style="display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">
                                                    <c:choose>
                                                        <c:when test="${rawQuery.contains('classification=HOT') || filter.classification == 'HOT'}">
                                                            <span class="badge badge-hot"><i class="fas fa-fire"></i> Phân loại: Nóng</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('classification=WARM') || filter.classification == 'WARM'}">
                                                            <span class="badge badge-warm"><i class="fas fa-sun"></i> Phân loại: Ấm</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('classification=COLD') || filter.classification == 'COLD'}">
                                                            <span class="badge badge-cold"><i class="fas fa-snowflake"></i> Phân loại: Lạnh</span>
                                                        </c:when>
                                                    </c:choose>
                                                    <c:if test="${rawQuery.contains('overdue=true') || filter.overdue}">
                                                        <span class="badge badge-sla-overdue"><i class="fas fa-exclamation-triangle"></i> Quá SLA</span>
                                                    </c:if>
                                                    <c:choose>
                                                        <c:when test="${rawQuery.contains('status=NEW') || filter.status == 'NEW'}">
                                                            <span class="badge badge-info"><i class="fas fa-plus-circle"></i> Trạng thái: Mới tạo</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('status=CONTACTED') || filter.status == 'CONTACTED'}">
                                                            <span class="badge badge-warning"><i class="fas fa-phone"></i> Trạng thái: Đang liên hệ</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('status=QUALIFIED') || filter.status == 'QUALIFIED'}">
                                                            <span class="badge badge-success"><i class="fas fa-check-circle"></i> Trạng thái: Đã xác định NC</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('status=CONVERTED') || filter.status == 'CONVERTED'}">
                                                            <span class="badge" style="background:#dcfce7; color:#15803d; border: 1px solid #86efac;"><i class="fas fa-exchange-alt"></i> Trạng thái: Đã chuyển đổi</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('status=UNQUALIFIED') || filter.status == 'UNQUALIFIED'}">
                                                            <span class="badge badge-neutral"><i class="fas fa-ban"></i> Trạng thái: Không tiềm năng</span>
                                                        </c:when>
                                                    </c:choose>
                                                    <c:if test="${rawQuery.contains('ownerId=MY') || rawQuery.contains('ownerScope=MY')}">
                                                        <span class="badge badge-neutral"><i class="fas fa-user"></i> Phụ trách: Của tôi</span>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <span style="font-size: 12px; color: var(--color-text-secondary); display: flex; align-items: center; gap: 6px;">
                                                    <i class="far fa-clock" style="color: #94a3b8;"></i>
                                                    <c:out value="${filter.createdAt != null ? filter.createdAt : 'Gần đây'}"/>
                                                </span>
                                            </td>
                                            <td style="text-align: center;">
                                                <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                                                    <a href="${pageContext.request.contextPath}/leads?${rawQuery}" class="btn btn-primary btn-sm" title="Áp dụng bộ lọc này ngay">
                                                        <i class="fas fa-check"></i> Áp dụng
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/leads/filters/delete" style="display: inline-block; margin: 0;">
                                                        <input type="hidden" name="filterId" value="${filter.filterId != null ? filter.filterId : filter.id}">
                                                        <button type="submit" class="btn btn-secondary btn-sm" onclick="return confirm('Bạn có chắc muốn xóa bộ lọc này?');" title="Xóa bộ lọc" style="padding: 6px 10px;">
                                                            <i class="fas fa-trash-alt" style="color: #dc2626;"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" style="text-align: center; padding: 48px 16px;">
                                            <div class="empty-state-box" style="display: flex; flex-direction: column; align-items: center; justify-content: center;">
                                                <div class="empty-state-icon" style="font-size: 40px; color: #94a3b8; margin-bottom: 12px;">
                                                    <i class="fas fa-bookmark"></i>
                                                </div>
                                                <div class="empty-state-title" style="font-size: 16px; font-weight: 600; color: var(--color-gray-900); margin-bottom: 6px;">
                                                    Chưa có bộ lọc nào được lưu
                                                </div>
                                                <div class="empty-state-desc" style="font-size: 13px; color: var(--color-text-secondary); max-width: 480px; margin: 0 auto 16px; line-height: 1.5;">
                                                    Hãy vào trang <strong>Danh sách Lead</strong>, tùy chọn các điều kiện lọc mong muốn và bấm <strong>"Lưu bộ lọc này"</strong> để tái sử dụng nhanh chóng mỗi ngày.
                                                </div>
                                                <a href="${pageContext.request.contextPath}/leads" class="btn btn-primary btn-sm">
                                                    <i class="fas fa-filter"></i> Đến trang lọc Lead ngay
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Guidance footer -->
                <div style="margin-top: 20px; padding: 14px 18px; background: #f8fafc; border: 1px dashed var(--color-border); border-radius: 8px; font-size: 13px; color: var(--color-text-secondary); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <i class="fas fa-lightbulb" style="color: #f59e0b; margin-right: 6px;"></i>
                        <strong>Mẹo:</strong> Để lưu bộ lọc mới, truy cập trang <em>Danh sách Lead</em>, chọn các tiêu chí tìm kiếm mong muốn rồi bấm nút <strong>"Lưu bộ lọc này"</strong>.
                    </div>
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary btn-sm">
                        <i class="fas fa-search"></i> Đến trang lọc Lead
                    </a>
                </div>
            </div>
        </div>
    </main>
</div>
<script>
    (function() {
        try {
            var urlParams = new URLSearchParams(window.location.search);
            var urlErr = urlParams.get('error') || urlParams.get('err');
            var urlSuccess = urlParams.get('success');
            var urlMsg = urlParams.get('msg');
            var hasParamToast = false;

            // Tránh hiển thị trùng lặp nếu server đã render thông báo (qua global toast.jsp hoặc inline banner)
            var hasServerSuccess = (document.querySelector('.global-success-message') && document.querySelector('.global-success-message').value.trim() !== '') ||
                                   document.querySelector('.scoring-notification-banner.alert-success');
            var hasServerError = (document.querySelector('.global-error-message') && document.querySelector('.global-error-message').value.trim() !== '') ||
                                 document.querySelector('.scoring-notification-banner.alert-danger');

            if (urlErr) {
                if (!hasServerError && typeof window.showToast === 'function') {
                    window.showToast('error', urlErr === '1' ? 'Đã xảy ra lỗi khi xử lý bộ lọc.' : urlErr);
                }
                urlParams.delete('error');
                urlParams.delete('err');
                hasParamToast = true;
            } else if (urlSuccess) {
                if (!hasServerSuccess && typeof window.showToast === 'function') {
                    window.showToast('success', urlSuccess === '1' || urlSuccess === 'true' ? 'Thao tác bộ lọc thành công!' : urlSuccess);
                }
                urlParams.delete('success');
                hasParamToast = true;
            } else if (urlMsg) {
                if (typeof window.showToast === 'function') {
                    window.showToast('info', urlMsg);
                }
                urlParams.delete('msg');
                hasParamToast = true;
            }

            if (hasParamToast && window.history && window.history.replaceState) {
                var remainingQuery = urlParams.toString();
                var newUrl = window.location.pathname + (remainingQuery ? ('?' + remainingQuery) : '') + window.location.hash;
                window.history.replaceState(null, document.title, newUrl);
            }
        } catch (e) {
            console.error('Error handling URL params in leads/saved-filters.jsp:', e);
        }
    })();

    function renderSavedFilterCriteriaChips() {
        var chipContainers = document.querySelectorAll('.saved-filter-criteria-chips');
        chipContainers.forEach(function(container) {
            var rawQuery = container.getAttribute('data-query');
            if (!rawQuery) {
                if (container.children.length === 0) {
                    var emptySpan = document.createElement('span');
                    emptySpan.className = 'badge badge-neutral';
                    emptySpan.style.color = '#94a3b8';
                    emptySpan.innerHTML = '<i class="fas fa-asterisk"></i> Tất cả Lead (Bộ lọc mặc định)';
                    container.appendChild(emptySpan);
                }
                return;
            }
            try {
                if (rawQuery.charAt(0) === '?') rawQuery = rawQuery.substring(1);
                var params = new URLSearchParams(rawQuery);

                function addChip(html, customClass, style) {
                    var span = document.createElement('span');
                    span.className = customClass || 'badge badge-neutral';
                    if (style) span.style.cssText = style;
                    span.innerHTML = html;
                    container.appendChild(span);
                }

                // Keyword
                var kw = params.get('keyword') || params.get('search');
                if (kw && kw.trim()) {
                    var safeKw = document.createTextNode(kw.trim()).textContent;
                    addChip('<i class="fas fa-search"></i> Từ khóa: <strong>' + safeKw + '</strong>');
                }

                // Source
                var src = params.get('source');
                if (src && src.trim()) {
                    var safeSrc = document.createTextNode(src.trim()).textContent;
                    addChip('<i class="fas fa-share-alt"></i> Nguồn: <strong>' + safeSrc + '</strong>', 'badge badge-neutral', 'background:#f0fdf4; color:#166534; border: 1px solid #bbf7d0;');
                }

                // Dates formatted DD/MM/YYYY
                var fromDate = params.get('fromDate');
                var toDate = params.get('toDate');
                function fmtDate(dStr) {
                    if (!dStr) return '';
                    var parts = dStr.split('-');
                    if (parts.length === 3) return parts[2] + '/' + parts[1] + '/' + parts[0];
                    return dStr;
                }
                if (fromDate) {
                    addChip('<i class="far fa-calendar-alt"></i> Từ: <strong>' + fmtDate(fromDate) + '</strong>');
                }
                if (toDate) {
                    addChip('<i class="far fa-calendar-alt"></i> Đến: <strong>' + fmtDate(toDate) + '</strong>');
                }

                // Specific numeric owner
                var ownerId = params.get('ownerId');
                if (ownerId && ownerId !== 'MY' && !isNaN(ownerId)) {
                    addChip('<i class="fas fa-user-check"></i> Phụ trách ID: <strong>#' + ownerId + '</strong>');
                }

                if (container.children.length === 0) {
                    addChip('<i class="fas fa-asterisk"></i> Tất cả Lead (Bộ lọc mặc định)', 'badge badge-neutral', 'color:#94a3b8;');
                }
            } catch (err) {
                console.error('Lỗi phân tích tiêu chí bộ lọc:', err);
            }
        });
    }

    document.addEventListener('DOMContentLoaded', renderSavedFilterCriteriaChips);
    if (document.readyState === 'interactive' || document.readyState === 'complete') {
        renderSavedFilterCriteriaChips();
    }
</script>
</body>
</html>
