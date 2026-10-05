<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Khách hàng trùng lặp | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <h1 class="page-title">Danh sách khách hàng trùng lặp</h1>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success"><c:out value="${successMessage}"/></div>
            </c:if>

            <table class="table">
                <thead>
                    <tr>
                        <th>ID (Gốc)</th>
                        <th>Tên (Gốc)</th>
                        <th>ID (Trùng)</th>
                        <th>Tên (Trùng)</th>
                        <th>Lý do</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty duplicateCandidates}">
                            <c:forEach var="item" items="${duplicateCandidates}">
                                <tr>
                                    <td>${not empty item.left ? item.left.customerId : param.customerId}</td>
                                    <td><c:out value="${not empty item.left ? item.left.customerName : customer.customerName}"/></td>
                                    <td>${not empty item.right ? item.right.customerId : item.customerId}</td>
                                    <td><c:out value="${not empty item.right ? item.right.customerName : item.customerName}"/></td>
                                    <td><c:out value="${not empty item.reason ? item.reason : item.duplicateReason}"/></td>
                                    <td>
                                        <c:set var="lId" value="${not empty item.left ? item.left.customerId : param.customerId}" />
                                        <c:set var="rId" value="${not empty item.right ? item.right.customerId : item.customerId}" />
                                        <a href="${pageContext.request.contextPath}/customers/duplicates/compare?leftId=${lId}&rightId=${rId}" class="btn btn-primary">So sánh</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6" class="text-center">Không có dữ liệu trùng lặp.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers">Quay lại danh sách</a>
        </div>
    </main>
</div>
</body>
</html>
