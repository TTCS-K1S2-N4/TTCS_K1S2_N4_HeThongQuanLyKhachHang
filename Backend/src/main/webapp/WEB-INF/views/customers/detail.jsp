<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><title>Chi tiết khách hàng | CRM</title><jsp:include page="/WEB-INF/views/fragments/head.jsp"/></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/><main class="main-content"><div class="content-container"><h1>Chi tiết khách hàng</h1>
<c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if><c:if test="${not empty customer}"><p>ID: ${customer.customerId}</p><p>Tên: <c:out value="${customer.customerName}"/></p><p>Điện thoại: <c:out value="${customer.phone}"/></p></c:if>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers">Quay lại</a></div></main></div></body></html>
