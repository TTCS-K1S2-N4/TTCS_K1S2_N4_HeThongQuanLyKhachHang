<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa Lead: ${lead.fullName} | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="content-container">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Chỉnh sửa</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h1 class="page-title">Chỉnh sửa Lead: <c:out value="${lead.fullName}"/></h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                            Cập nhật thông tin chi tiết đầu mối kinh doanh.
                        </p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}" class="btn btn-outline">
                            <i class="fas fa-arrow-left"></i> Quay lại chi tiết
                        </a>
                    </div>
                </div>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px;">
                        <i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/>
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage and empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px;">
                        <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
                    </div>
                </c:if>

                <div class="card form-card">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/leads/update" method="post" class="lead-form">
                            <input type="hidden" name="id" value="${lead.leadId}">
                            <input type="hidden" name="title" value="${not empty param.title ? param.title : lead.title}">
                            <input type="hidden" name="status" value="${not empty param.status ? param.status : lead.status}">
                            <input type="hidden" name="rating" value="${not empty param.rating ? param.rating : lead.rating}">
                            <input type="hidden" name="industry" value="${not empty param.industry ? param.industry : lead.industry}">
                            <input type="hidden" name="address" value="${not empty param.address ? param.address : lead.address}">
                            <input type="hidden" name="city" value="${not empty param.city ? param.city : lead.city}">
                            <input type="hidden" name="state" value="${not empty param.state ? param.state : lead.state}">
                            <input type="hidden" name="country" value="${not empty param.country ? param.country : lead.country}">
                            <input type="hidden" name="zipCode" value="${not empty param.zipCode ? param.zipCode : lead.zipCode}">
                            <input type="hidden" name="ownerId" value="${not empty param.ownerId ? param.ownerId : lead.ownerId}">
                            
                            <div class="form-group">
                                <label for="fullName">Họ tên <span class="required">*</span></label>
                                <input type="text" id="fullName" name="fullName" class="form-control" value="${not empty param.fullName ? param.fullName : lead.fullName}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" class="form-control" value="${not empty param.email ? param.email : lead.email}">
                            </div>

                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="text" id="phone" name="phone" class="form-control" value="${not empty param.phone ? param.phone : lead.phone}">
                            </div>

                            <div class="form-group">
                                <label for="company">Công ty</label>
                                <input type="text" id="company" name="company" class="form-control" value="${not empty param.company ? param.company : lead.company}">
                            </div>

                            <div class="form-group">
                                <label for="notes">Nhu cầu quan tâm</label>
                                <textarea id="notes" name="notes" class="form-control" rows="3">${not empty param.notes ? param.notes : lead.notes}</textarea>
                            </div>

                            <div class="form-group">
                                <label for="leadSourceId">Nguồn Lead <span class="required">*</span></label>
                                <select id="leadSourceId" name="leadSourceId" class="form-control" required>
                                    <option value="">-- Chọn nguồn --</option>
                                    <c:forEach var="src" items="${sources}">
                                        <option value="${src.sourceId}" ${(not empty param.leadSourceId ? param.leadSourceId : lead.leadSourceId) == src.sourceId ? 'selected' : ''}><c:out value="${src.sourceName}"/></option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-actions" style="display: flex; gap: 8px; margin-top: 20px;">
                                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                                <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}" class="btn btn-secondary">Hủy</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
