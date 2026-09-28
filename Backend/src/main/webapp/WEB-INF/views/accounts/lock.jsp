<%@ page contentType="text/html;charset=UTF-8" language="java" %><%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><title>Khóa tài khoản | CRM</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/><main class="main-content"><div class="content-container"><h1>Khóa tài khoản và bàn giao dữ liệu</h1>
<p>Bạn đang khóa <strong><c:out value="${account.fullName}"/></strong> (<c:out value="${account.email}"/>). Tài khoản đang sở hữu ${ownedCount} bản ghi.</p>
<form method="post" action="${pageContext.request.contextPath}/accounts/transfer-data"><input type="hidden" name="accountId" value="${account.accountId}">
<div class="form-group"><label for="reason">Lý do khóa</label><textarea id="reason" name="reason" class="form-control" required></textarea></div>
<div class="form-group"><label for="receiverId">Người nhận bàn giao</label><select id="receiverId" name="receiverId" class="form-control" required><option value="">-- Chọn tài khoản --</option><c:forEach var="receiver" items="${receivers}"><option value="${receiver.accountId}"><c:out value="${receiver.fullName}"/> — <c:out value="${receiver.email}"/></option></c:forEach></select></div>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/detail?accountId=${account.accountId}">Hủy</a><button class="btn btn-danger" type="submit">Khóa và bàn giao</button></form>
</div></main></div></body></html>
