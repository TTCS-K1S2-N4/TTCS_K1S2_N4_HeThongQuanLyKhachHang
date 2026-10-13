<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Bộ lọc Lead đã lưu | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
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
                <a href="${pageContext.request.contextPath}/leads">Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Bộ lọc Lead đã lưu</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Bộ lọc Lead đã lưu (Saved Filters)</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                        Danh sách các bộ lọc cá nhân đã lưu, giúp Nhân viên kinh doanh mở máy buổi sáng là biết ngay cần gọi ai.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 8px;">
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-primary">
                        <i class="fas fa-filter"></i> Quay lại Danh sách Lead
                    </a>
                </div>
            </div>

            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-bookmark" style="color: var(--color-primary);"></i>
                        Danh sách bộ lọc đã lưu của bạn
                    </h2>
                </div>

                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">#</th>
                                <th>Tên bộ lọc</th>
                                <th>Chi tiết tiêu chí lọc</th>
                                <th>Ngày tạo</th>
                                <th style="width: 180px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty savedFilters}">
                                    <c:forEach var="filter" items="${savedFilters}" varStatus="status">
                                        <tr>
                                            <td>${status.count}</td>
                                            <td>
                                                <strong><c:out value="${filter.filterName != null ? filter.filterName : filter.name}"/></strong>
                                            </td>
                                            <td>
                                                <div style="font-size: 13px; color: var(--color-gray-700); line-height: 1.4;">
                                                    <c:out value="${filter.filterQuery != null ? filter.filterQuery : filter.criteria}"/>
                                                </div>
                                            </td>
                                            <td>
                                                <span style="font-size: 12px; color: var(--color-text-secondary);">
                                                    <c:out value="${filter.createdAt != null ? filter.createdAt : 'Mặc định'}"/>
                                                </span>
                                            </td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/leads?${filter.filterQuery != null ? filter.filterQuery : filter.criteria}" class="btn btn-primary btn-sm" style="margin-right: 4px;">
                                                    <i class="fas fa-check"></i> Áp dụng
                                                </a>
                                                <form method="post" action="${pageContext.request.contextPath}/leads/filters/delete" class="d-inline" style="display: inline-block;">
                                                    <input type="hidden" name="filterId" value="${filter.filterId != null ? filter.filterId : filter.id}">
                                                    <button type="submit" class="btn btn-secondary btn-sm" onclick="return confirm('Bạn có chắc muốn xóa bộ lọc này?');" title="Xóa bộ lọc">
                                                        <i class="fas fa-trash-alt" style="color: #dc2626;"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <!-- Hiển thị các mẫu bộ lọc gợi ý khi chưa có trong CSDL -->
                                    <tr>
                                        <td>1</td>
                                        <td><strong>Lead Nóng cần gọi sáng nay</strong></td>
                                        <td><span class="badge badge-hot">Phân loại: Nóng</span> | <span class="badge badge-neutral">Trạng thái: Mới tạo</span></td>
                                        <td>Hệ thống gợi ý</td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/leads?classification=HOT&status=NEW" class="btn btn-primary btn-sm">
                                                <i class="fas fa-check"></i> Áp dụng
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>2</td>
                                        <td><strong>Lead quá SLA phản hồi</strong></td>
                                        <td><span class="badge badge-sla-overdue">Quá SLA: Có</span></td>
                                        <td>Hệ thống gợi ý</td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/leads?overdue=true" class="btn btn-primary btn-sm">
                                                <i class="fas fa-check"></i> Áp dụng
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>3</td>
                                        <td><strong>Lead của tôi phụ trách tuần này</strong></td>
                                        <td><span class="badge badge-neutral">Người phụ trách: Tôi</span> | <span class="badge badge-neutral">Thời gian: Tuần này</span></td>
                                        <td>Hệ thống gợi ý</td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/leads?ownerScope=MY" class="btn btn-primary btn-sm">
                                                <i class="fas fa-check"></i> Áp dụng
                                            </a>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
<script>
    (function() {
        try {
            var urlParams = new URLSearchParams(window.location.search);
            var urlErr = urlParams.get('error');
            var urlSuccess = urlParams.get('success');
            var urlMsg = urlParams.get('msg');
            var hasParamToast = false;

            if (urlErr) {
                if (typeof window.showToast === 'function') {
                    window.showToast('error', urlErr === '1' ? 'Đã xảy ra lỗi khi xử lý bộ lọc.' : urlErr);
                }
                urlParams.delete('error');
                hasParamToast = true;
            } else if (urlSuccess) {
                if (typeof window.showToast === 'function') {
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
</script>
</body>
</html>
