<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- S3-02 / S30-03: Form thêm người liên hệ (GET/POST /contacts/create) --%>
<c:if test="${not empty errors.system}">
    <c:set var="errorMessage" value="${errors.system}" scope="request"/>
</c:if>
<c:set var="form" value="${contactRequest}"/>
<c:set var="selectedRole" value="${empty form ? '' : form.buyingRole}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thêm người liên hệ | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .contact-form-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
        .contact-check { display: flex; align-items: center; gap: 8px; }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <c:url var="listUrl" value="/contacts">
                <c:param name="customerId" value="${customerId}"/>
            </c:url>

            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <c:if test="${not empty customerId}">
                    <a href="${listUrl}">Người liên hệ</a>
                    <span>/</span>
                </c:if>
                <span class="breadcrumb-current">Thêm mới</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Thêm người liên hệ</h1>
                    <p class="page-description">
                        <c:choose>
                            <c:when test="${not empty customer}">Khách hàng: <c:out value="${customer.customerName}"/></c:when>
                            <c:when test="${not empty customerId}">Mã khách hàng: <c:out value="${customerId}"/></c:when>
                        </c:choose>
                    </p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty customerId}">
                    <section class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <div class="empty-state-icon"><i class="fas fa-exclamation-triangle"></i></div>
                                <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa xác định khách hàng</h3>
                                <p>Vui lòng mở chức năng thêm người liên hệ từ danh sách người liên hệ của một khách hàng.</p>
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers" style="margin-top: 16px;">Về danh sách khách hàng</a>
                            </div>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="card">
                        <div class="card-header">
                            <h2 class="card-title">Thông tin người liên hệ</h2>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/contacts/create" method="post">
                                <input type="hidden" name="customerId" value="<c:out value='${customerId}'/>">
                                <c:if test="${not empty errors.customerId}">
                                    <p class="form-error"><c:out value="${errors.customerId}"/></p>
                                </c:if>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label" for="fullName">Họ và tên <span class="form-required">*</span></label>
                                        <input id="fullName" name="fullName" class="form-control" type="text" required
                                               value="<c:out value='${form.fullName}'/>">
                                        <c:if test="${not empty errors.fullName}">
                                            <p class="form-error"><c:out value="${errors.fullName}"/></p>
                                        </c:if>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label" for="title">Chức danh</label>
                                        <input id="title" name="title" class="form-control" type="text"
                                               value="<c:out value='${form.title}'/>">
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label" for="email">Email</label>
                                        <input id="email" name="email" class="form-control" type="email"
                                               value="<c:out value='${form.email}'/>">
                                        <c:if test="${not empty errors.email}">
                                            <p class="form-error"><c:out value="${errors.email}"/></p>
                                        </c:if>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label" for="phone">Số điện thoại</label>
                                        <input id="phone" name="phone" class="form-control" type="tel"
                                               value="<c:out value='${form.phone}'/>">
                                        <c:if test="${not empty errors.phone}">
                                            <p class="form-error"><c:out value="${errors.phone}"/></p>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label" for="buyingRole">Vai trò trong quyết định mua <span class="form-required">*</span></label>
                                        <select id="buyingRole" name="buyingRole" class="form-control" required>
                                            <option value="">-- Chọn vai trò --</option>
                                            <c:choose>
                                                <c:when test="${not empty buyingRoles}">
                                                    <c:forEach var="code" items="${buyingRoles}">
                                                        <option value="<c:out value='${code}'/>" ${code == selectedRole ? 'selected' : ''}>
                                                            <c:choose>
                                                                <c:when test="${code == 'DECIDER' or code == 'DECISION_MAKER'}">Người quyết định</c:when>
                                                                <c:when test="${code == 'INFLUENCER'}">Người ảnh hưởng</c:when>
                                                                <c:when test="${code == 'END_USER'}">Người dùng cuối</c:when>
                                                                <c:when test="${code == 'BLOCKER'}">Người cản trở</c:when>
                                                                <c:otherwise><c:out value="${code}"/></c:otherwise>
                                                            </c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="DECISION_MAKER" ${selectedRole == 'DECISION_MAKER' ? 'selected' : ''}>Người quyết định</option>
                                                    <option value="INFLUENCER" ${selectedRole == 'INFLUENCER' ? 'selected' : ''}>Người ảnh hưởng</option>
                                                    <option value="END_USER" ${selectedRole == 'END_USER' ? 'selected' : ''}>Người dùng cuối</option>
                                                    <option value="BLOCKER" ${selectedRole == 'BLOCKER' ? 'selected' : ''}>Người cản trở</option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                        <c:if test="${not empty errors.buyingRole}">
                                            <p class="form-error"><c:out value="${errors.buyingRole}"/></p>
                                        </c:if>
                                    </div>
                                    <div class="form-group">
                                        <span class="form-label">Đầu mối chính</span>
                                        <label class="contact-check" for="isPrimary">
                                            <input id="isPrimary" name="isPrimary" type="checkbox" value="true"
                                                ${not empty form and form.primary ? 'checked' : ''}>
                                            Đặt làm đầu mối chính của khách hàng
                                        </label>
                                        <p class="form-help">Mỗi khách hàng chỉ có một đầu mối chính; đầu mối hiện tại (nếu có) sẽ bị thay thế.</p>
                                    </div>
                                </div>

                                <div class="contact-form-actions">
                                    <a class="btn btn-secondary" href="${listUrl}">Hủy</a>
                                    <button class="btn btn-primary" type="submit">Lưu người liên hệ</button>
                                </div>
                            </form>
                        </div>
                    </section>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
</body>
</html>
