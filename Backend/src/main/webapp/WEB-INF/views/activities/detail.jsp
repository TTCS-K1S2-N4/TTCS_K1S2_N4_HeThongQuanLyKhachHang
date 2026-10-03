<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết hoạt động | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/activities.css">
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
                <a href="${pageContext.request.contextPath}/activities">Hoạt động</a>
                <span>/</span>
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chi tiết hoạt động</h1>
                </div>
                <div class="page-actions">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/activities">Quay lại danh sách</a>
                </div>
            </div>

            <!-- GLOBAL MESSAGES HAVE BEEN MOVED TO TOAST -->
            
            <c:if test="${not empty activity}">
                <div class="card">
                    <div class="card-body">
                        <div class="activity-meta">
                            <div class="activity-meta-item">
                                <div class="activity-meta-label">ID</div>
                                <div class="activity-meta-value">${activity.activityId}</div>
                            </div>
                            <div class="activity-meta-item">
                                <div class="activity-meta-label">Tiêu đề</div>
                                <div class="activity-meta-value"><c:out value="${activity.title}"/></div>
                            </div>
                            <c:if test="${not empty activity.createdAt}">
                                <div class="activity-meta-item">
                                    <div class="activity-meta-label">Ngày tạo</div>
                                    <div class="activity-meta-value"><fmt:formatDate value="${activity.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                </div>
                            </c:if>
                        </div>
                        <div class="activity-content-block">
                            <h3 class="activity-content-title">Mô tả</h3>
                            <div class="activity-content-text"><c:out value="${activity.description}"/></div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>

