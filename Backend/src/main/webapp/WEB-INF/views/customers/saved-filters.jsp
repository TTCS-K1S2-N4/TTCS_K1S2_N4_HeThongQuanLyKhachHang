<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Bộ lọc đã lưu | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <h1 class="page-title">Bộ lọc đã lưu</h1>
            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary">Quay lại danh sách</a>
            </div>
            <table class="table">
                <thead>
                <tr>
                    <th>Tên bộ lọc</th>
                    <th>Tiêu chí</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty savedFilters}">
                        <tr><td colspan="3">Chưa có bộ lọc nào được lưu.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="filter" items="${savedFilters}">
                            <tr>
                                <td><c:out value="${filter.name}"/></td>
                                <td><c:out value="${filter.criteria}"/></td>
                                <td>
                                    <!-- Apply Filter (Assumes criteria contains query params string) -->
                                    <a href="${pageContext.request.contextPath}/customers?${filter.criteria}" class="btn btn-primary btn-sm">Áp dụng</a>
                                    
                                    <!-- Delete Filter -->
                                    <form method="post" action="${pageContext.request.contextPath}/customers/filters/delete" class="d-inline">
                                        <input type="hidden" name="id" value="${filter.id}">
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Bạn có chắc muốn xóa bộ lọc này?');">Xóa</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </main>
</div>
<c:if test="${not empty error}">
    <input type="hidden" id="toast-custfilter-err" value="<c:out value='${error}'/>">
</c:if>
<c:if test="${not empty message}">
    <input type="hidden" id="toast-custfilter-msg" value="<c:out value='${message}'/>">
</c:if>
<script>
    (function() {
        var errInput = document.getElementById('toast-custfilter-err');
        var msgInput = document.getElementById('toast-custfilter-msg');
        if (errInput && errInput.value && typeof window.showToast === 'function') {
            window.showToast('error', errInput.value);
        }
        if (msgInput && msgInput.value && typeof window.showToast === 'function') {
            window.showToast('success', msgInput.value);
        }

        try {
            var urlParams = new URLSearchParams(window.location.search);
            var urlSuccess = urlParams.get('success');
            var urlError = urlParams.get('error');
            var urlMsg = urlParams.get('msg');
            var hasParamToast = false;

            if (urlError) {
                if (typeof window.showToast === 'function') {
                    window.showToast('error', urlError === '1' ? 'Đã xảy ra lỗi khi xử lý bộ lọc.' : urlError);
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
            console.error('Error handling URL params in saved-filters.jsp:', e);
        }
    })();
</script>
</body>
</html>
