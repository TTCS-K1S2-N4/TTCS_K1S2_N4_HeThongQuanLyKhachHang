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
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger scoring-notification-banner" style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><c:out value="${errorMessage}"/></span>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
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
                            ${not empty savedFilters ? savedFilters.size() : 3} bộ lọc
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
                                                <div style="display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">
                                                    <c:choose>
                                                        <c:when test="${rawQuery.contains('classification=HOT')}">
                                                            <span class="badge badge-hot"><i class="fas fa-fire"></i> Phân loại: Nóng</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('classification=WARM')}">
                                                            <span class="badge badge-warm"><i class="fas fa-sun"></i> Phân loại: Ấm</span>
                                                        </c:when>
                                                        <c:when test="${rawQuery.contains('classification=COLD')}">
                                                            <span class="badge badge-cold"><i class="fas fa-snowflake"></i> Phân loại: Lạnh</span>
                                                        </c:when>
                                                    </c:choose>
                                                    <c:if test="${rawQuery.contains('overdue=true')}">
                                                        <span class="badge badge-sla-overdue"><i class="fas fa-exclamation-triangle"></i> Quá SLA</span>
                                                    </c:if>
                                                    <c:if test="${rawQuery.contains('status=NEW')}">
                                                        <span class="badge badge-neutral">Trạng thái: Mới tạo</span>
                                                    </c:if>
                                                    <c:if test="${rawQuery.contains('status=CONTACTED')}">
                                                        <span class="badge badge-warning">Đang liên hệ</span>
                                                    </c:if>
                                                    <c:if test="${rawQuery.contains('ownerId=MY') || rawQuery.contains('ownerScope=MY')}">
                                                        <span class="badge badge-neutral"><i class="fas fa-user"></i> Của tôi</span>
                                                    </c:if>
                                                    <span style="font-size: 12px; color: var(--color-text-secondary); margin-left: 4px; font-family: ui-monospace, monospace;">
                                                        (<c:out value="${rawQuery}"/>)
                                                    </span>
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
                                    <!-- Hiển thị các mẫu bộ lọc gợi ý khi chưa có trong CSDL -->
                                    <tr>
                                        <td style="text-align: center; color: var(--color-text-secondary);">1</td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <i class="fas fa-star" style="color: #f59e0b; font-size: 13px;"></i>
                                                <strong style="color: var(--color-gray-900); font-size: 14px;">Lead Nóng cần gọi sáng nay</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">
                                                <span class="badge badge-hot"><i class="fas fa-fire"></i> Phân loại: Nóng</span>
                                                <span class="badge badge-neutral">Trạng thái: Mới tạo</span>
                                            </div>
                                        </td>
                                        <td><span class="badge badge-neutral" style="font-size: 11px;">Mẫu gợi ý</span></td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/leads?classification=HOT&status=NEW" class="btn btn-primary btn-sm">
                                                <i class="fas fa-check"></i> Áp dụng
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: center; color: var(--color-text-secondary);">2</td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <i class="fas fa-star" style="color: #f59e0b; font-size: 13px;"></i>
                                                <strong style="color: var(--color-gray-900); font-size: 14px;">Lead quá SLA phản hồi</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">
                                                <span class="badge badge-sla-overdue"><i class="fas fa-exclamation-triangle"></i> Quá SLA: Có</span>
                                            </div>
                                        </td>
                                        <td><span class="badge badge-neutral" style="font-size: 11px;">Mẫu gợi ý</span></td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/leads?overdue=true" class="btn btn-primary btn-sm">
                                                <i class="fas fa-check"></i> Áp dụng
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: center; color: var(--color-text-secondary);">3</td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <i class="fas fa-star" style="color: #f59e0b; font-size: 13px;"></i>
                                                <strong style="color: var(--color-gray-900); font-size: 14px;">Lead của tôi phụ trách</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">
                                                <span class="badge badge-neutral"><i class="fas fa-user"></i> Người phụ trách: Tôi</span>
                                            </div>
                                        </td>
                                        <td><span class="badge badge-neutral" style="font-size: 11px;">Mẫu gợi ý</span></td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/leads?ownerId=MY" class="btn btn-primary btn-sm">
                                                <i class="fas fa-check"></i> Áp dụng
                                            </a>
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
</body>
</html>
