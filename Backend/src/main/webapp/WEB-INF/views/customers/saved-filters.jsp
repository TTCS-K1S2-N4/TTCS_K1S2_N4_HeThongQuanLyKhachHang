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

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>
            <c:if test="${not empty message}">
                <div class="alert alert-success">${message}</div>
            </c:if>

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
</body>
</html>
