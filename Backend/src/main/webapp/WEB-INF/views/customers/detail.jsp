<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .page-title {
            font-size: 1.75rem;
            font-family: var(--font-heading, 'Georgia', serif);
            font-weight: 600;
            color: var(--color-gray-900);
        }
        .detail-card {
            background: var(--color-surface);
            border: 1px solid var(--color-border);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            overflow: hidden;
            max-width: 600px;
        }
        .detail-header {
            padding: 24px;
            background: var(--color-gray-50);
            border-bottom: 1px solid var(--color-border);
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .detail-avatar {
            width: 64px;
            height: 64px;
            background: var(--color-primary-light);
            color: var(--color-primary);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .detail-body {
            padding: 24px;
        }
        .detail-row {
            display: flex;
            padding: 12px 0;
            border-bottom: 1px solid var(--color-gray-100);
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            width: 140px;
            color: var(--color-text-secondary);
            font-weight: 500;
        }
        .detail-value {
            color: var(--color-text-primary);
            font-weight: 600;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="content-container">
            <!-- Toolbar -->
            <div class="toolbar" style="margin-bottom: 32px; display: flex; align-items: center; gap: 16px;">
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers" style="width: 40px; height: 40px; padding: 0; display: flex; align-items: center; justify-content: center; border-radius: 50%;">
                    <i class="fa-solid fa-arrow-left"></i>
                </a>
                <div>
                    <h1 class="page-title mb-0">Hồ sơ khách hàng</h1>
                    <p class="text-secondary mt-1" style="font-size: 0.95rem;">Xem chi tiết thông tin khách hàng</p>
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="max-width: 600px;"><c:out value="${errorMessage}"/></div>
            </c:if>

            <c:if test="${not empty customer}">
                <div class="detail-card">
                    <div class="detail-header">
                        <div class="detail-avatar">
                            <i class="fa-solid fa-user"></i>
                        </div>
                        <div>
                            <h2 style="margin: 0; font-size: 1.25rem; font-weight: 700; color: var(--color-gray-900);"><c:out value="${customer.customerName}"/></h2>
                            <span class="badge badge-neutral" style="margin-top: 8px; display: inline-block;">ID: #${customer.customerId}</span>
                        </div>
                    </div>
                    <div class="detail-body">
                        <div class="detail-row">
                            <div class="detail-label">Tên khách hàng</div>
                            <div class="detail-value"><c:out value="${customer.customerName}"/></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">Số điện thoại</div>
                            <div class="detail-value"><i class="fa-solid fa-phone" style="color: var(--color-primary); margin-right: 6px;"></i><c:out value="${customer.phone}"/></div>
                        </div>
                        <!-- Thêm các trường khác tại đây -->
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>
