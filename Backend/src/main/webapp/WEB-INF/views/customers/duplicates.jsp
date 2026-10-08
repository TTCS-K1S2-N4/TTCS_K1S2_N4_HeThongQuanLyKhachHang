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
            <c:if test="${param.error == '1'}">
                <div class="alert alert-danger">Thao tác gộp khách hàng không thành công. Vui lòng thử lại.</div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success"><c:out value="${successMessage}"/></div>
            </c:if>

            <table class="table" style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <thead>
                    <tr>
                        <th>ID (Khách hàng 1)</th>
                        <th>Tên (Khách hàng 1)</th>
                        <th>ID (Khách hàng 2)</th>
                        <th>Tên (Khách hàng 2)</th>
                        <th>Lý do trùng lặp</th>
                        <th style="text-align: center;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty duplicateCandidates}">
                            <c:forEach var="item" items="${duplicateCandidates}">
                                <tr>
                                    <td>${not empty item.left ? item.left.customerId : item.customerId}</td>
                                    <td><c:out value="${not empty item.left ? item.left.customerName : item.customerName}"/></td>
                                    <td>${not empty item.right ? item.right.customerId : item.customerId}</td>
                                    <td><c:out value="${not empty item.right ? item.right.customerName : item.customerName}"/></td>
                                    <td><c:out value="${not empty item.reason ? item.reason : (not empty item.phone ? 'Trùng SĐT' : 'Trùng tên')}"/></td>
                                    <td style="text-align: center;">
                                        <c:set var="lId" value="${not empty item.left ? item.left.customerId : item.customerId}" />
                                        <c:set var="rId" value="${not empty item.right ? item.right.customerId : item.customerId}" />
                                        <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${lId}&secondaryId=${rId}" class="btn btn-primary" style="padding: 4px 12px; font-size: 13px;">
                                            <i class="fas fa-code-branch"></i> So sánh & Gộp
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:when test="${not empty duplicates}">
                            <c:forEach var="cust" items="${duplicates}" varStatus="status">
                                <tr>
                                    <td>${cust.customerId}</td>
                                    <td><c:out value="${cust.customerName}"/></td>
                                    <td>${cust.phone}</td>
                                    <td><c:out value="${cust.email}"/></td>
                                    <td>Phát hiện thông tin trùng lặp (Tên / SĐT)</td>
                                    <td style="text-align: center;">
                                        <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${cust.customerId}" class="btn btn-primary" style="padding: 4px 12px; font-size: 13px;">
                                            <i class="fas fa-code-branch"></i> Chọn làm Khách chính
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6" class="text-center" style="padding: 24px; color: var(--color-text-secondary);">Không tìm thấy dữ liệu trùng lặp.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
            <div style="margin-top: 16px; display: flex; gap: 12px;">
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers" style="background: white; border: 1px solid var(--color-border);"><i class="fas fa-arrow-left"></i> Quay lại danh sách</a>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/customers/merge"><i class="fas fa-compress-alt"></i> Gộp theo ID nhập tay</a>
            </div>
        </div>
    </main>
</div>
</body>
</html>
