<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- S3-02 / S30-03: Danh sách người liên hệ của một khách hàng (GET /contacts?customerId={id}) --%>
<c:if test="${not empty sessionScope.message}">
    <c:set var="successMessage" value="${sessionScope.message}" scope="request"/>
    <c:remove var="message" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <c:set var="errorMessage" value="${sessionScope.errorMessage}" scope="request"/>
    <c:remove var="errorMessage" scope="session"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Người liên hệ | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .contact-name { font-weight: 600; }
        .contact-sub { display: block; font-size: 0.85rem; color: #64748b; }
        .contact-actions { display: flex; flex-wrap: wrap; gap: 6px; }
        .contact-actions form { display: inline; margin: 0; }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <c:url var="customerDetailUrl" value="/customers/detail">
                <c:param name="id" value="${customerId}"/>
            </c:url>
            <c:url var="createUrl" value="/contacts/create">
                <c:param name="customerId" value="${customerId}"/>
            </c:url>

            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <a href="${customerDetailUrl}">Chi tiết</a>
                <span>/</span>
                <span class="breadcrumb-current">Người liên hệ</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        Người liên hệ
                        <c:if test="${not empty customer}">: <c:out value="${customer.customerName}"/></c:if>
                    </h1>
                    <p class="page-description">
                        Mã khách hàng: <c:out value="${customerId}"/> — vai trò trong quyết định mua và đầu mối chính.
                    </p>
                </div>
                <div class="page-actions">
                    <a class="btn btn-secondary" href="${customerDetailUrl}">Quay lại khách hàng</a>
                    <a class="btn btn-primary" href="${createUrl}"><i class="fas fa-user-plus"></i> Thêm người liên hệ</a>
                </div>
            </div>

            <section class="card">
                <div class="table-container table-responsive">
                    <table class="table">
                        <thead style="background: #f8fafc;">
                        <tr>
                            <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Họ và tên</th>
                            <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Email</th>
                            <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Số điện thoại</th>
                            <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Vai trò quyết định mua</th>
                            <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Đầu mối chính</th>
                            <th style="width: 120px; color: var(--color-text-secondary); font-weight: 600; text-transform: none; text-align: center;">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty contacts}">
                                <c:forEach var="ct" items="${contacts}">
                                    <c:url var="detailUrl" value="/contacts/detail">
                                        <c:param name="id" value="${ct.contactId}"/>
                                    </c:url>
                                    <c:url var="editUrl" value="/contacts/edit">
                                        <c:param name="id" value="${ct.contactId}"/>
                                    </c:url>
                                    <c:url var="transferUrl" value="/contacts/transfer">
                                        <c:param name="contactId" value="${ct.contactId}"/>
                                    </c:url>
                                    <tr>
                                        <td>
                                            <a class="contact-name" href="${detailUrl}"><c:out value="${ct.fullName}"/></a>
                                            <c:if test="${not empty ct.title}">
                                                <span class="contact-sub"><c:out value="${ct.title}"/></span>
                                            </c:if>
                                        </td>
                                        <td><c:out value="${empty ct.email ? '—' : ct.email}"/></td>
                                        <td><c:out value="${empty ct.phone ? '—' : ct.phone}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ct.buyingRole == 'DECIDER' or ct.buyingRole == 'DECISION_MAKER'}">
                                                    <span class="badge badge-success">Người quyết định</span>
                                                </c:when>
                                                <c:when test="${ct.buyingRole == 'INFLUENCER'}">
                                                    <span class="badge badge-info">Người ảnh hưởng</span>
                                                </c:when>
                                                <c:when test="${ct.buyingRole == 'END_USER'}">
                                                    <span class="badge badge-neutral">Người dùng cuối</span>
                                                </c:when>
                                                <c:when test="${ct.buyingRole == 'BLOCKER'}">
                                                    <span class="badge badge-danger">Người cản trở</span>
                                                </c:when>
                                                <c:otherwise><c:out value="${ct.buyingRole}"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ct.primary}">
                                                    <span class="badge badge-warning"><i class="fas fa-star"></i> Đầu mối chính</span>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="contact-actions">
                                                <a class="btn btn-secondary btn-sm" href="${detailUrl}">Xem</a>
                                                <a class="btn btn-secondary btn-sm" href="${editUrl}">Sửa</a>
                                                <c:if test="${not ct.primary}">
                                                    <form method="post" action="${pageContext.request.contextPath}/contacts/primary"
                                                          onsubmit="return confirm('Đặt người này làm đầu mối chính? Đầu mối chính hiện tại (nếu có) sẽ bị thay thế.');">
                                                        <input type="hidden" name="contactId" value="<c:out value='${ct.contactId}'/>">
                                                        <input type="hidden" name="customerId" value="<c:out value='${ct.customerId}'/>">
                                                        <button type="submit" class="btn btn-secondary btn-sm">Đặt đầu mối chính</button>
                                                    </form>
                                                </c:if>
                                                <a class="btn btn-secondary btn-sm" href="${transferUrl}">Chuyển công ty</a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <div class="empty-state-icon"><i class="fas fa-user-times"></i></div>
                                            <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa có người liên hệ</h3>
                                            <p>Khách hàng này chưa có người liên hệ. Thêm người liên hệ để ghi nhận vai trò của họ trong quyết định mua.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
