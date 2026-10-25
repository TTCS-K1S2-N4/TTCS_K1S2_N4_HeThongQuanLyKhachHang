<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết báo giá | CRM</title>
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
                <a href="${pageContext.request.contextPath}/quotes">Báo giá</a>
                <span>/</span>
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chi tiết báo giá</h1>
                </div>
                <div class="page-actions">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/quotes">Quay lại danh sách</a>
                </div>
            </div>

            <!-- GLOBAL MESSAGES HAVE BEEN MOVED TO TOAST -->
            
            <c:if test="${not empty quote}">
                <div class="card">
                    <div class="card-body">
                        <div class="form-group">
                            <label>ID</label>
                            <p>${quote.quoteId}</p>
                        </div>
                        <div class="form-group">
                            <label>Số báo giá</label>
                            <p><c:out value="${quote.quoteNumber}"/></p>
                        </div>
                        <div class="form-group">
                            <label>Ngày tạo</label>
                            <p><fmt:formatDate value="${quote.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>

