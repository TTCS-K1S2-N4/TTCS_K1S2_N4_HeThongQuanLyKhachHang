<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><title>Chi tiết tài khoản | CRM</title>
<jsp:include page="/WEB-INF/views/fragments/head.jsp"/><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css"></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
<main class="main-content"><div class="content-container"><h1>Chi tiết tài khoản</h1>
<dl><dt>Họ tên</dt><dd><c:out value="${account.fullName}"/></dd><dt>Email</dt><dd><c:out value="${account.email}"/></dd><dt>Điện thoại</dt><dd><c:out value="${account.phone}"/></dd><dt>Vai trò</dt><dd><c:out value="${account.roleName}"/></dd><dt>Nhóm</dt><dd><c:out value="${account.teamName}"/></dd><dt>Trạng thái</dt><dd><c:out value="${account.status}"/></dd></dl>
<a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/list">Quay lại</a>
<a class="btn btn-primary" href="${pageContext.request.contextPath}/accounts/edit?accountId=${account.accountId}">Chỉnh sửa</a>
<a class="btn btn-primary" href="${pageContext.request.contextPath}/accounts/assign-role?accountId=${account.accountId}">Gán vai trò</a>
<c:if test="${account.status == 'ACTIVE'}"><a class="btn btn-danger" href="${pageContext.request.contextPath}/accounts/lock?accountId=${account.accountId}">Khóa và bàn giao</a></c:if>
<c:if test="${account.status != 'ACTIVE'}"><a class="btn btn-success" href="${pageContext.request.contextPath}/accounts/unlock?accountId=${account.accountId}" onclick="return confirm('Bạn có chắc chắn muốn mở khóa tài khoản này?');">Mở khóa tài khoản</a></c:if>
</div></main></div></body></html>
