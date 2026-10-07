<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- S3-02 / S30-03: Form cập nhật người liên hệ (GET /contacts/edit?id={id}, POST /contacts/edit) --%>
<c:if test="${not empty errors.system}">
    <c:set var="errorMessage" value="${errors.system}" scope="request"/>
</c:if>
<c:if test="${not empty errors.contactId}">
    <c:set var="errorMessage" value="${errors.contactId}" scope="request"/>
</c:if>
<c:set var="ownerCustomerId" value="${not empty customer ? customer.customerId : contact.customerId}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cập nhật người liên hệ | CRM</title>
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
                <c:param name="customerId" value="${ownerCustomerId}"/>
            </c:url>
            <c:url var="detailUrl" value="/contacts/detail">
                <c:param name="id" value="${contact.contactId}"/>
            </c:url>

            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <c:if test="${not empty ownerCustomerId}">
                    <a href="${listUrl}">Người liên hệ</a>
                    <span>/</span>
                </c:if>
                <span class="breadcrumb-current">Cập nhật</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Cập nhật người liên hệ</h1>
                    <p class="page-description">
                        <c:if test="${not empty customer}">Khách hàng: <c:out value="${customer.customerName}"/></c:if>
                    </p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty contact or empty contact.contactId}">
                    <section class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <div class="empty-state-icon"><i class="fas fa-exclamation-triangle"></i></div>
                                <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Không tìm thấy người liên hệ</h3>
                                <p>Người liên hệ không tồn tại hoặc đã bị xóa.</p>
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
                            <form action="${pageContext.request.contextPath}/contacts/edit" method="post">
                                <input type="hidden" name="contactId" value="<c:out value='${contact.contactId}'/>">

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label" for="fullName">Họ và tên <span class="form-required">*</span></label>
                                        <input id="fullName" name="fullName" class="form-control" type="text" required
                                               value="<c:out value='${contact.fullName}'/>">
                                        <c:if test="${not empty errors.fullName}">
                                            <p class="form-error"><c:out value="${errors.fullName}"/></p>
                                        </c:if>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label" for="title">Chức danh</label>
                                        <input id="title" name="title" class="form-control" type="text"
                                               value="<c:out value='${contact.title}'/>">
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label" for="email">Email</label>
                                        <input id="email" name="email" class="form-control" type="email"
                                               value="<c:out value='${contact.email}'/>">
                                        <c:if test="${not empty errors.email}">
                                            <p class="form-error"><c:out value="${errors.email}"/></p>
                                        </c:if>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label" for="phone">Số điện thoại</label>
                                        <input id="phone" name="phone" class="form-control" type="tel"
                                               value="<c:out value='${contact.phone}'/>">
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
                                                        <option value="<c:out value='${code}'/>" ${code == contact.buyingRole ? 'selected' : ''}>
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
                                                    <option value="DECISION_MAKER" ${contact.buyingRole == 'DECISION_MAKER' ? 'selected' : ''}>Người quyết định</option>
                                                    <option value="INFLUENCER" ${contact.buyingRole == 'INFLUENCER' ? 'selected' : ''}>Người ảnh hưởng</option>
                                                    <option value="END_USER" ${contact.buyingRole == 'END_USER' ? 'selected' : ''}>Người dùng cuối</option>
                                                    <option value="BLOCKER" ${contact.buyingRole == 'BLOCKER' ? 'selected' : ''}>Người cản trở</option>
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
                                                ${contact.primary ? 'checked' : ''}>
                                            Là đầu mối chính của khách hàng
                                        </label>
                                        <p class="form-help">Bỏ chọn sẽ gỡ vai trò đầu mối chính; chọn sẽ thay thế đầu mối hiện tại (nếu có).</p>
                                    </div>
                                </div>

                                <div class="contact-form-actions">
                                    <a class="btn btn-secondary" href="${detailUrl}">Hủy</a>
                                    <button class="btn btn-primary" type="submit">Lưu thay đổi</button>
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
