<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><title>Khách hàng | CRM</title>
<jsp:include page="/WEB-INF/views/fragments/head.jsp"/></head>
<body><div class="app"><jsp:include page="/WEB-INF/views/fragments/header.jsp"/><jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
<main class="main-content"><div class="content-container"><h1 class="page-title">Khách hàng</h1>
<form method="get" action="${pageContext.request.contextPath}/customers" class="mb-3">
    <div class="row">
        <div class="col-md-3">
            <input type="text" name="keyword" class="form-control" value="<c:out value='${keyword}'/>" placeholder="Tìm tên, MST, SĐT">
        </div>
        <div class="col-md-2">
            <select name="status" class="form-control">
                <option value="">-- Trạng thái --</option>
                <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>
        <div class="col-md-2">
            <select name="industry" class="form-control">
                <option value="">-- Ngành nghề --</option>
                <option value="IT" ${param.industry == 'IT' ? 'selected' : ''}>IT</option>
                <option value="FINANCE" ${param.industry == 'FINANCE' ? 'selected' : ''}>Tài chính</option>
            </select>
        </div>
        <div class="col-md-2">
            <select name="size" class="form-control">
                <option value="">-- Quy mô --</option>
                <option value="SMALL" ${param.size == 'SMALL' ? 'selected' : ''}>Nhỏ</option>
                <option value="MEDIUM" ${param.size == 'MEDIUM' ? 'selected' : ''}>Vừa</option>
                <option value="LARGE" ${param.size == 'LARGE' ? 'selected' : ''}>Lớn</option>
            </select>
        </div>
        <div class="col-md-2 mt-2">
            <select name="region" class="form-control">
                <option value="">-- Khu vực --</option>
                <option value="NORTH" ${param.region == 'NORTH' ? 'selected' : ''}>Miền Bắc</option>
                <option value="SOUTH" ${param.region == 'SOUTH' ? 'selected' : ''}>Miền Nam</option>
            </select>
        </div>
        <div class="col-md-2 mt-2">
            <input type="text" name="ownerId" class="form-control" value="<c:out value='${param.ownerId}'/>" placeholder="Owner ID">
        </div>
        <div class="col-md-3">
            <button type="submit" class="btn btn-primary">Lọc / Tìm kiếm</button>
            <a href="${pageContext.request.contextPath}/customers/export?keyword=<c:out value='${keyword}'/>" class="btn btn-secondary">Xuất CSV</a>
        </div>
    </div>
</form>
<div class="saved-filters-section mb-3">
    <h4>Bộ lọc đã lưu (DEPENDENCY NOT IMPLEMENTED)</h4>
    <a href="${pageContext.request.contextPath}/customers/filters" class="btn btn-info btn-sm">Quản lý bộ lọc</a>
    <form method="post" action="${pageContext.request.contextPath}/customers/filters" class="d-inline">
        <input type="hidden" name="name" value="Current Filter">
        <input type="hidden" name="criteria" value="">
        <button type="submit" class="btn btn-success btn-sm" disabled>Lưu bộ lọc hiện tại</button>
    </form>
</div>
<table class="table"><thead><tr><th>ID</th><th>Tên</th><th>Điện thoại</th><th>Thao tác</th></tr></thead><tbody>
<c:forEach var="item" items="${list}"><tr><td>${item.customerId}</td><td><c:out value="${item.customerName}"/></td><td><c:out value="${item.phone}"/></td><td><a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}">Chi tiết</a></td></tr></c:forEach>
</tbody></table><c:if test="${totalPages > 1}"><c:forEach begin="1" end="${totalPages}" var="i"><a href="?page=${i}&amp;keyword=${keyword}">${i}</a></c:forEach></c:if>
</div></main></div></body></html>
