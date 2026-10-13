<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Phát hiện Lead trùng lặp | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <style>
        .duplicate-item {
            background: white;
            border: 1px solid var(--color-border);
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .match-tags {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }
        .match-tag {
            background: #fef3c7;
            color: #d97706;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
        <main class="main-content">
            <div class="content-container">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Phát hiện trùng lặp</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px;">
                    <h1 class="page-title">Kiểm tra Lead trùng lặp</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Lead gốc: <strong><c:out value="${currentLead.name}" /></strong> (${currentLead.email} - ${currentLead.phone})</p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px; padding: 12px; background: #fee2e2; color: #dc2626; border-radius: 6px;">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <div style="margin-bottom: 24px;">
                    <h3 style="font-size: 16px; margin-bottom: 12px;"><i class="fas fa-users" style="color: #f59e0b;"></i> Các Lead nghi ngờ trùng lặp</h3>
                    
                    <c:choose>
                        <c:when test="${not empty duplicateLeads}">
                            <c:forEach var="dup" items="${duplicateLeads}">
                                <div class="duplicate-item">
                                    <div>
                                        <div style="font-weight: 600; color: var(--color-gray-900);"><c:out value="${dup.name}" /></div>
                                        <div style="font-size: 13px; color: var(--color-text-secondary); margin-top: 4px;">
                                            Email: <c:out value="${dup.email}" /> | SĐT: <c:out value="${dup.phone}" /> | Công ty: <c:out value="${dup.company}" />
                                        </div>
                                        <div class="match-tags">
                                            <c:if test="${dup.matchEmail}"><span class="match-tag"><i class="fas fa-envelope"></i> Trùng Email</span></c:if>
                                            <c:if test="${dup.matchPhone}"><span class="match-tag"><i class="fas fa-phone"></i> Trùng SĐT</span></c:if>
                                            <c:if test="${dup.matchCompany}"><span class="match-tag"><i class="fas fa-building"></i> Trùng Công ty</span></c:if>
                                        </div>
                                    </div>
                                    <div>
                                        <a href="${pageContext.request.contextPath}/leads/merge?primaryId=${currentLead.id}&duplicateId=${dup.id}" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);"><i class="fas fa-compress-alt"></i> So sánh & Gộp</a>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 24px; text-align: center; color: var(--color-text-secondary);">
                                <i class="fas fa-check-circle" style="font-size: 32px; color: #10b981; margin-bottom: 12px;"></i>
                                <p>Không tìm thấy Lead nào có nguy cơ trùng lặp với Lead này.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div style="margin-bottom: 24px;">
                    <h3 style="font-size: 16px; margin-bottom: 12px;"><i class="fas fa-user-tie" style="color: #0ea5e9;"></i> Khách hàng (Customer) gợi ý liên kết</h3>
                    <c:choose>
                        <c:when test="${not empty suggestedCustomers}">
                            <c:forEach var="cust" items="${suggestedCustomers}">
                                <div class="duplicate-item">
                                    <div>
                                        <div style="font-weight: 600; color: var(--color-gray-900);"><c:out value="${cust.name}" /></div>
                                        <div style="font-size: 13px; color: var(--color-text-secondary); margin-top: 4px;">
                                            Email: <c:out value="${cust.email}" /> | SĐT: <c:out value="${cust.phone}" />
                                        </div>
                                    </div>
                                    <div>
                                        <form action="${pageContext.request.contextPath}/leads/link-customer" method="post" style="display:inline;">
                                            <input type="hidden" name="leadId" value="${currentLead.id}" />
                                            <input type="hidden" name="customerId" value="${cust.id}" />
                                            <button type="submit" class="btn btn-primary" onclick="return confirm('Bạn có chắc chắn muốn liên kết Lead này vào Khách hàng đã chọn?');"><i class="fas fa-link"></i> Liên kết Customer</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 24px; text-align: center; color: var(--color-text-secondary);">
                                <p>Không có Khách hàng (Customer) nào trùng khớp để liên kết.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </main>
    </div>
</body>
</html>
