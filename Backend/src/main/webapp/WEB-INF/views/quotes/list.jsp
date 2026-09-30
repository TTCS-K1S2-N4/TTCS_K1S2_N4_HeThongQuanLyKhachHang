<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><title>Báo giá | CRM</title><jsp:include page="/WEB-INF/views/fragments/head.jsp"/></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/><main class="main-content"><div class="content-container"><h1>Báo giá</h1>
<form method="get" action="${pageContext.request.contextPath}/quotes"><input name="keyword" value="<c:out value='${keyword}'/>"><button class="btn btn-primary">Tìm kiếm</button></form>
<table class="table"><thead><tr><th>ID</th><th>Số báo giá</th><th></th></tr></thead><tbody><c:forEach var="item" items="${list}"><tr><td>${item.quoteId}</td><td><c:out value="${item.quoteNumber}"/></td><td><a href="${pageContext.request.contextPath}/quotes/detail?id=${item.quoteId}">Chi tiết</a></td></tr></c:forEach></tbody></table>
<c:if test="${totalPages > 1}"><c:forEach begin="1" end="${totalPages}" var="i"><a href="?page=${i}&amp;keyword=${keyword}">${i}</a></c:forEach></c:if></div></main></div></body></html>
