<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách khách hàng trùng lặp | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <span class="breadcrumb-current">Kiểm tra trùng lặp</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Danh sách Khách hàng Trùng lặp</h1>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <p>Hệ thống gợi ý các bản ghi có chung <strong>Số điện thoại</strong> hoặc chung <strong>Tên khách hàng</strong>.</p>
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên Khách Hàng</th>
                                <th>Điện Thoại</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty duplicates}">
                                <tr><td colspan="4">Không tìm thấy khách hàng trùng lặp nào.</td></tr>
                            </c:if>
                            <c:forEach var="c" items="${duplicates}">
                                <tr>
                                    <td>${c.customerId}</td>
                                    <td><c:out value="${c.customerName}"/></td>
                                    <td><c:out value="${c.phone}"/></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${c.customerId}&secondaryId=" class="btn btn-primary btn-sm">Gộp dữ liệu vào đây</a>
                                        <a href="${pageContext.request.contextPath}/customers/merge?secondaryId=${c.customerId}&primaryId=" class="btn btn-secondary btn-sm">Gộp dữ liệu từ đây đi</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
