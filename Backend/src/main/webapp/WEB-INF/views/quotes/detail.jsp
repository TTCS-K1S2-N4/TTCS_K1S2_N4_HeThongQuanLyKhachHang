<%@ page contentType="text/html;charset=UTF-8" language="java" %><%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><title>Chi tiết báo giá | CRM</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/><main class="main-content"><div class="content-container"><h1>Chi tiết báo giá</h1>
<c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if><c:if test="${not empty quote}"><p>ID: ${quote.quoteId}</p><p>Số báo giá: <c:out value="${quote.quoteNumber}"/></p></c:if>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/quotes">Quay lại</a></div></main></div></body></html>
