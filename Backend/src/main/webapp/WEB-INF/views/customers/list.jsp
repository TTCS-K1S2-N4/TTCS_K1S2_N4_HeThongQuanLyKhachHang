<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><title>Khách hàng | CRM</title>
<jsp:include page="/WEB-INF/views/fragments/head.jsp"/></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
<main class="main-content"><div class="content-container"><h1 class="page-title">Khách hàng</h1>
<form method="get" action="${pageContext.request.contextPath}/customers"><input name="keyword" value="<c:out value='${keyword}'/>" placeholder="Tìm khách hàng"><button class="btn btn-primary">Tìm kiếm</button> <a href="${pageContext.request.contextPath}/customers/export?keyword=<c:out value='${keyword}'/>" class="btn btn-secondary">Xuất CSV</a></form>
<table class="table"><thead><tr><th>ID</th><th>Tên</th><th>Điện thoại</th><th>Thao tác</th></tr></thead><tbody>
<c:forEach var="item" items="${list}"><tr><td>${item.customerId}</td><td><c:out value="${item.customerName}"/></td><td><c:out value="${item.phone}"/></td><td><a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}">Chi tiết</a></td></tr></c:forEach>
</tbody></table><c:if test="${totalPages > 1}"><c:forEach begin="1" end="${totalPages}" var="i"><a href="?page=${i}&amp;keyword=${keyword}">${i}</a></c:forEach></c:if>
</div></main></div></body></html>
