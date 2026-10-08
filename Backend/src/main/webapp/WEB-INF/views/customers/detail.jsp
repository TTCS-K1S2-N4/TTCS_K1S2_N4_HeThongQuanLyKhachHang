<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết khách hàng | CRM</title>
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
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chi tiết khách hàng</h1>
                </div>
                <div class="page-actions">
                    <a class="btn btn-primary" style="background: #0284c7; border-color: #0284c7;" href="${pageContext.request.contextPath}/customers/360?id=${customer.customerId}"><i class="fas fa-user-check"></i> Hồ sơ 360°</a>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/customers/edit?id=${customer.customerId}"><i class="fas fa-edit"></i> Sửa</a>
                    <a class="btn btn-warning" style="background: #eab308; color: white; border: none;" href="${pageContext.request.contextPath}/customers/merge?primaryId=${customer.customerId}"><i class="fas fa-compress-alt"></i> Gộp KH</a>
                    <a class="btn btn-info" href="${pageContext.request.contextPath}/customers/hierarchy?id=${customer.customerId}"><i class="fas fa-sitemap"></i> Cây quan hệ</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers"><i class="fas fa-arrow-left"></i> Quay lại</a>
                </div>
            </div>

            <!-- GLOBAL MESSAGES HAVE BEEN MOVED TO TOAST -->
            
            <c:choose>
                <c:when test="${not empty customer}">
                    <div class="card">
                        <div class="card-body">
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">ID</label>
                                <p style="margin: 4px 0 0 0;">${customer.customerId}</p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Tên công ty</label>
                                <p style="margin: 4px 0 0 0; font-weight: 500;"><c:out value="${customer.customerName}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Mã số thuế</label>
                                <p style="margin: 4px 0 0 0;"><c:out value="${customer.taxCode}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Điện thoại</label>
                                <p style="margin: 4px 0 0 0;"><c:out value="${customer.phone}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Ngành nghề</label>
                                <p style="margin: 4px 0 0 0;"><c:out value="${customer.industry}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Quy mô</label>
                                <p style="margin: 4px 0 0 0;"><c:out value="${customer.size}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Website</label>
                                <p style="margin: 4px 0 0 0;">
                                    <c:choose>
                                        <c:when test="${not empty customer.website and (customer.website.startsWith('http://') or customer.website.startsWith('https://'))}">
                                            <a href="<c:out value='${customer.website}'/>" target="_blank" rel="noopener noreferrer"><c:out value="${customer.website}"/></a>
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${customer.website}"/>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Địa chỉ</label>
                                <p style="margin: 4px 0 0 0;"><c:out value="${customer.address}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Người sở hữu</label>
                                <p style="margin: 4px 0 0 0;"><c:out value="${not empty customer.ownerName ? customer.ownerName : customer.ownerId}"/></p>
                            </div>
                            <div class="form-group" style="margin-bottom: 12px;">
                                <label style="font-weight: 600; color: var(--color-text-secondary);">Trạng thái</label>
                                <p style="margin: 4px 0 0 0;">
                                    <c:choose>
                                        <c:when test="${customer.status == 'POTENTIAL'}"><span class="badge badge-info">Tiềm năng</span></c:when>
                                        <c:when test="${customer.status == 'DEALING'}"><span class="badge badge-warning">Đang giao dịch</span></c:when>
                                        <c:when test="${customer.status == 'CUSTOMER'}"><span class="badge badge-success">Khách hàng</span></c:when>
                                        <c:when test="${customer.status == 'STOPPED'}"><span class="badge badge-secondary">Ngừng hợp tác</span></c:when>
                                        <c:otherwise><span class="badge"><c:out value="${customer.status}"/></span></c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <c:if test="${not empty customer.createdAt}">
                                <div class="form-group" style="margin-bottom: 12px;">
                                    <label style="font-weight: 600; color: var(--color-text-secondary);">Ngày tạo</label>
                                    <p style="margin: 4px 0 0 0;"><fmt:formatDate value="${customer.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                                </div>
                            </c:if>

                        <c:if test="${not empty customFieldValues}">
                            <div style="margin-top: 24px; border-top: 1px solid var(--color-border); padding-top: 16px;">
                                <h3 style="font-size: 16px; margin-bottom: 16px; color: var(--color-primary);"><i class="fas fa-list-check"></i> Trường tùy chỉnh</h3>
                                <c:forEach var="cf" items="${customFieldValues}">
                                    <div class="form-group" style="margin-bottom: 12px;">
                                        <label style="font-weight: 600; color: var(--color-text-secondary);"><c:out value="${cf.fieldLabel}"/></label>
                                        <p style="margin: 4px 0 0 0; font-size: 15px;"><c:out value="${cf.fieldValue}"/></p>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning">
                        Không tìm thấy thông tin khách hàng hoặc bạn không có quyền truy cập.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
</body>
</html>
