<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- S3-02 / S30-03: Chuyển người liên hệ sang khách hàng mới, giữ lịch sử (GET/POST /contacts/transfer) --%>
<c:if test="${not empty errors.system}">
    <c:set var="errorMessage" value="${errors.system}" scope="request"/>
</c:if>
<c:if test="${not empty errors.contactId}">
    <c:set var="errorMessage" value="${errors.contactId}" scope="request"/>
</c:if>
<c:set var="transferContactId" value="${not empty contact ? contact.contactId : contactId}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chuyển công ty người liên hệ | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .contact-form-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
        .transfer-current { margin-bottom: 16px; padding: 12px 16px; background: #f8fafc; border-radius: 6px; }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <c:url var="detailUrl" value="/contacts/detail">
                <c:param name="id" value="${transferContactId}"/>
            </c:url>

            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <c:if test="${not empty transferContactId}">
                    <a href="${detailUrl}">Người liên hệ</a>
                    <span>/</span>
                </c:if>
                <span class="breadcrumb-current">Chuyển công ty</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chuyển người liên hệ sang khách hàng mới</h1>
                    <p class="page-description">Người liên hệ được gắn sang khách hàng mới; lịch sử với khách hàng cũ được giữ nguyên.</p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty transferContactId}">
                    <section class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <div class="empty-state-icon"><i class="fas fa-exclamation-triangle"></i></div>
                                <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa xác định người liên hệ cần chuyển</h3>
                                <p>Vui lòng chọn người liên hệ hợp lệ từ danh sách.</p>
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers" style="margin-top: 16px;">Về danh sách khách hàng</a>
                            </div>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="card">
                        <div class="card-header">
                            <h2 class="card-title">Thông tin chuyển công ty</h2>
                        </div>
                        <div class="card-body">
                            <c:if test="${not empty contact}">
                                <div class="transfer-current">
                                    <strong><c:out value="${contact.fullName}"/></strong>
                                    <c:if test="${not empty contact.title}"> — <c:out value="${contact.title}"/></c:if>
                                    <br>
                                    Khách hàng hiện tại:
                                    <c:choose>
                                        <c:when test="${not empty currentCustomer}"><c:out value="${currentCustomer.customerName}"/></c:when>
                                        <c:otherwise>Mã <c:out value="${contact.customerId}"/></c:otherwise>
                                    </c:choose>
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/contacts/transfer" method="post"
                                  onsubmit="return confirm('Xác nhận chuyển người liên hệ sang khách hàng mới?');">
                                <input type="hidden" name="contactId" value="<c:out value='${transferContactId}'/>">

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label" for="newCustomerId">Khách hàng mới <span class="form-required">*</span></label>
                                        <c:choose>
                                            <c:when test="${not empty customers}">
                                                <select id="newCustomerId" name="newCustomerId" class="form-control" required>
                                                    <option value="">-- Chọn khách hàng --</option>
                                                    <c:forEach var="cus" items="${customers}">
                                                        <c:if test="${empty currentCustomer or cus.customerId != currentCustomer.customerId}">
                                                            <option value="<c:out value='${cus.customerId}'/>" ${param.newCustomerId == cus.customerId ? 'selected' : ''}>
                                                                <c:out value="${cus.customerName}"/> (Mã <c:out value="${cus.customerId}"/>)
                                                            </option>
                                                        </c:if>
                                                    </c:forEach>
                                                </select>
                                            </c:when>
                                            <c:otherwise>
                                                <input id="newCustomerId" name="newCustomerId" class="form-control" type="number"
                                                       min="1" step="1" required value="<c:out value='${param.newCustomerId}'/>">
                                                <p class="form-help">Nhập mã khách hàng mới mà bạn có quyền truy cập.</p>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty errors.newCustomerId}">
                                            <p class="form-error"><c:out value="${errors.newCustomerId}"/></p>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="reason">Lý do chuyển công ty <span class="form-required">*</span></label>
                                    <textarea id="reason" name="reason" class="form-control" rows="3" required><c:out value="${param.reason}"/></textarea>
                                </div>

                                <div class="contact-form-actions">
                                    <a class="btn btn-secondary" href="${detailUrl}">Hủy</a>
                                    <button class="btn btn-primary" type="submit">Chuyển công ty</button>
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
