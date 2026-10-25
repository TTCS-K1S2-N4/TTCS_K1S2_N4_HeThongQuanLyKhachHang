<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Rủi ro rời bỏ | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <h1 class="page-title">Phân tích rủi ro <c:if test="${not empty customer}">- <c:out value="${customer.customerName}"/></c:if></h1>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success"><c:out value="${successMessage}"/></div>
            </c:if>

            <c:if test="${not empty customer}">
                <div style="margin-top: 20px; padding: 30px; border: 1px solid #e0e0e0; border-radius: 8px; background: #fafafa;">
                    <c:choose>
                        <c:when test="${riskFlag == true}">
                            <div style="color: #d32f2f; display: flex; align-items: center; gap: 10px;">
                                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                <h3 style="margin: 0;">CẢNH BÁO RỦI RO CAO (RISK FLAG: TRUE)</h3>
                            </div>
                            <p style="margin-top: 15px; font-size: 1.1em;"><strong>Khách hàng này có nguy cơ rời bỏ hệ thống cao.</strong></p>
                            <div style="background: #fff3f3; padding: 15px; border-left: 4px solid #d32f2f; margin-top: 15px;">
                                <p style="margin: 0;"><strong>Lý do:</strong> <c:out value="${riskReason}"/></p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="color: #2e7d32; display: flex; align-items: center; gap: 10px;">
                                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                                <h3 style="margin: 0;">TÌNH TRẠNG BÌNH THƯỜNG (RISK FLAG: FALSE)</h3>
                            </div>
                            <p style="margin-top: 15px; font-size: 1.1em;">Không phát hiện rủi ro rời bỏ từ khách hàng này.</p>
                            <c:if test="${not empty riskReason}">
                                <div style="background: #e8f5e9; padding: 15px; border-left: 4px solid #2e7d32; margin-top: 15px;">
                                    <p style="margin: 0;"><strong>Ghi chú:</strong> <c:out value="${riskReason}"/></p>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <div style="margin-top: 20px;">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers/detail?id=${customer.customerId}">Quay lại chi tiết</a>
                </div>
            </c:if>
            <c:if test="${empty customer}">
                <div class="alert alert-warning">Không tìm thấy thông tin khách hàng.</div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>
