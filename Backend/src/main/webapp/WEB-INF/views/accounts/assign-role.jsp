<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><title>Gán vai trò | CRM</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
<main class="main-content"><div class="content-container"><h1>Gán vai trò và nhóm</h1><p><c:out value="${account.fullName}"/> — <c:out value="${account.email}"/></p>
<form action="${pageContext.request.contextPath}/accounts/assign-role" method="post">
<input type="hidden" name="accountId" value="${account.accountId}">
<div class="form-group"><label for="roleIds">Vai trò</label><select id="roleIds" name="roleIds" class="form-control" multiple required>
<c:forEach var="role" items="${roles}"><option value="${role.id}" ${account.roleIds.contains(role.id) ? 'selected' : ''}><c:out value="${role.name}"/></option></c:forEach>
</select></div><div class="form-group"><label for="teamId">Nhóm</label><select id="teamId" name="teamId" class="form-control"><option value="">-- Không thuộc nhóm --</option>
<c:forEach var="team" items="${teams}"><option value="${team.id}" ${account.teamId == team.id ? 'selected' : ''}><c:out value="${team.name}"/></option></c:forEach>
</select></div><a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/detail?accountId=${account.accountId}">Hủy</a><button class="btn btn-primary" type="submit">Lưu thay đổi</button>
</form></div></main></div></body></html>
