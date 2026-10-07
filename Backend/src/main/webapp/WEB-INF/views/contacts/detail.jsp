<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- S3-02 / S30-03: Chi tiết người liên hệ (GET /contacts/detail?id={id}) --%>
<c:choose>
    <c:when test="${not empty sessionScope.message}">
        <c:set var="successMessage" value="${sessionScope.message}" scope="request"/>
        <c:remove var="message" scope="session"/>
    </c:when>
    <c:when test="${param.success == 'primary'}">
        <c:set var="successMessage" value="Đã đặt người liên hệ làm đầu mối chính." scope="request"/>
    </c:when>
    <c:when test="${param.success == 'transferred'}">
        <c:set var="successMessage" value="Đã chuyển người liên hệ sang khách hàng mới." scope="request"/>
    </c:when>
</c:choose>
<c:if test="${not empty sessionScope.errorMessage}">
    <c:set var="errorMessage" value="${sessionScope.errorMessage}" scope="request"/>
    <c:remove var="errorMessage" scope="session"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết người liên hệ | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .contact-info { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; }
        .contact-info dt { font-size: 0.85rem; color: #64748b; margin-bottom: 4px; }
        .contact-info dd { margin: 0; font-weight: 500; word-break: break-word; }
        .contact-section { margin-top: 20px; }
        .page-actions form { display: inline; margin: 0; }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <c:url var="listUrl" value="/contacts">
                <c:param name="customerId" value="${contact.customerId}"/>
            </c:url>
            <c:url var="editUrl" value="/contacts/edit">
                <c:param name="id" value="${contact.contactId}"/>
            </c:url>
            <c:url var="transferUrl" value="/contacts/transfer">
                <c:param name="contactId" value="${contact.contactId}"/>
            </c:url>

            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <a href="${listUrl}">Người liên hệ</a>
                <span>/</span>
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <c:choose>
                <c:when test="${empty contact}">
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
                    <div class="page-header">
                        <div>
                            <h1 class="page-title">
                                <c:out value="${contact.fullName}"/>
                                <c:if test="${contact.primary}">
                                    <span class="badge badge-warning"><i class="fas fa-star"></i> Đầu mối chính</span>
                                </c:if>
                            </h1>
                            <p class="page-description">
                                <c:choose>
                                    <c:when test="${not empty customer}">Khách hàng: <c:out value="${customer.customerName}"/></c:when>
                                    <c:otherwise>Mã khách hàng: <c:out value="${contact.customerId}"/></c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="page-actions">
                            <a class="btn btn-secondary" href="${listUrl}">Danh sách người liên hệ</a>
                            <a class="btn btn-secondary" href="${editUrl}"><i class="fas fa-pen"></i> Sửa</a>
                            <c:if test="${not contact.primary}">
                                <form method="post" action="${pageContext.request.contextPath}/contacts/primary"
                                      onsubmit="return confirm('Đặt người này làm đầu mối chính? Đầu mối chính hiện tại (nếu có) sẽ bị thay thế.');">
                                    <input type="hidden" name="contactId" value="<c:out value='${contact.contactId}'/>">
                                    <input type="hidden" name="customerId" value="<c:out value='${contact.customerId}'/>">
                                    <button type="submit" class="btn btn-secondary"><i class="fas fa-star"></i> Đặt đầu mối chính</button>
                                </form>
                            </c:if>
                            <a class="btn btn-primary" href="${transferUrl}"><i class="fas fa-right-left"></i> Chuyển công ty</a>
                        </div>
                    </div>

                    <section class="card">
                        <div class="card-header">
                            <h2 class="card-title">Thông tin người liên hệ</h2>
                        </div>
                        <div class="card-body">
                            <dl class="contact-info">
                                <div>
                                    <dt>Họ và tên</dt>
                                    <dd><c:out value="${contact.fullName}"/></dd>
                                </div>
                                <div>
                                    <dt>Chức danh</dt>
                                    <dd><c:out value="${empty contact.title ? '—' : contact.title}"/></dd>
                                </div>
                                <div>
                                    <dt>Email</dt>
                                    <dd><c:out value="${empty contact.email ? '—' : contact.email}"/></dd>
                                </div>
                                <div>
                                    <dt>Số điện thoại</dt>
                                    <dd><c:out value="${empty contact.phone ? '—' : contact.phone}"/></dd>
                                </div>
                                <div>
                                    <dt>Vai trò trong quyết định mua</dt>
                                    <dd>
                                        <c:choose>
                                            <c:when test="${contact.buyingRole == 'DECIDER' or contact.buyingRole == 'DECISION_MAKER'}">
                                                <span class="badge badge-success">Người quyết định</span>
                                            </c:when>
                                            <c:when test="${contact.buyingRole == 'INFLUENCER'}">
                                                <span class="badge badge-info">Người ảnh hưởng</span>
                                            </c:when>
                                            <c:when test="${contact.buyingRole == 'END_USER'}">
                                                <span class="badge badge-neutral">Người dùng cuối</span>
                                            </c:when>
                                            <c:when test="${contact.buyingRole == 'BLOCKER'}">
                                                <span class="badge badge-danger">Người cản trở</span>
                                            </c:when>
                                            <c:otherwise><c:out value="${contact.buyingRole}"/></c:otherwise>
                                        </c:choose>
                                    </dd>
                                </div>
                                <div>
                                    <dt>Đầu mối chính</dt>
                                    <dd>${contact.primary ? 'Có' : 'Không'}</dd>
                                </div>
                                <c:if test="${not empty contact.createdAt}">
                                    <div>
                                        <dt>Ngày tạo</dt>
                                        <dd><fmt:formatDate value="${contact.createdAt}" pattern="dd/MM/yyyy HH:mm"/></dd>
                                    </div>
                                </c:if>
                            </dl>
                        </div>
                    </section>

                    <c:if test="${requestScope.history ne null}">
                        <section class="card contact-section">
                            <div class="card-header">
                                <h2 class="card-title">Lịch sử chuyển công ty</h2>
                            </div>
                            <div class="table-container table-responsive">
                                <table class="table">
                                    <thead>
                                    <tr>
                                        <th>Thời điểm</th>
                                        <th>Từ khách hàng</th>
                                        <th>Sang khách hàng</th>
                                        <th>Người thực hiện</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:choose>
                                        <c:when test="${not empty history}">
                                            <c:forEach var="h" items="${history}">
                                                <tr>
                                                    <td><fmt:formatDate value="${h.transferredAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                    <td><c:out value="${empty h.oldCustomerName ? h.oldCustomerId : h.oldCustomerName}"/></td>
                                                    <td><c:out value="${empty h.newCustomerName ? h.newCustomerId : h.newCustomerName}"/></td>
                                                    <td><c:out value="${empty h.transferredByName ? '—' : h.transferredByName}"/></td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="4">
                                                    <div class="empty-state">
                                                        <div class="empty-state-icon"><i class="fas fa-history"></i></div>
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa có lịch sử chuyển công ty</h3>
                                                        <p>Người liên hệ chưa từng chuyển sang khách hàng khác.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
</body>
</html>
