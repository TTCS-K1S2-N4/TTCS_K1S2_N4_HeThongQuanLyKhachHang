<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết cơ hội | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/opportunities.css">
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
                <a href="${pageContext.request.contextPath}/deals">Cơ hội kinh doanh</a>
                <span>/</span>
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chi tiết cơ hội</h1>
                </div>
                <div class="page-actions">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/deals">Quay lại danh sách</a>
                </div>
            </div>

            <!-- GLOBAL MESSAGES HAVE BEEN MOVED TO TOAST -->
            
            <c:if test="${not empty opportunity}">
                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 24px;">
                    <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 16px 24px; display: flex; justify-content: space-between; align-items: center;">
                        <h2 class="card-title" style="font-size: 18px; margin: 0; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-handshake" style="color: var(--color-primary);"></i> <c:out value="${opportunity.title}"/>
                        </h2>
                        <c:choose>
                            <c:when test="${opportunity.probability ge 100}">
                                <span class="badge" style="padding: 6px 14px; border-radius: 16px; font-size: 13px; font-weight: 600; background: #dcfce7; color: #166534;">
                                    <c:out value="${opportunity.stageName != null ? opportunity.stageName : 'Chưa chọn stage'}"/> (${opportunity.probability}%)
                                </span>
                            </c:when>
                            <c:when test="${opportunity.probability le 0}">
                                <span class="badge" style="padding: 6px 14px; border-radius: 16px; font-size: 13px; font-weight: 600; background: #fee2e2; color: #991b1b;">
                                    <c:out value="${opportunity.stageName != null ? opportunity.stageName : 'Chưa chọn stage'}"/> (${opportunity.probability}%)
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge" style="padding: 6px 14px; border-radius: 16px; font-size: 13px; font-weight: 600; background: #e0f2fe; color: #0369a1;">
                                    <c:out value="${opportunity.stageName != null ? opportunity.stageName : 'Chưa chọn stage'}"/> (${opportunity.probability}%)
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body" style="padding: 24px;">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px;">
                            <div class="form-group">
                                <label style="font-size: 13px; color: var(--color-text-secondary); font-weight: 600;">MÃ CƠ HỘI (ID)</label>
                                <p style="font-size: 16px; font-weight: 600; margin-top: 4px;">#${opportunity.opportunityId}</p>
                            </div>
                            <div class="form-group">
                                <label style="font-size: 13px; color: var(--color-text-secondary); font-weight: 600;">GIÁ TRỊ DỰ KIẾN</label>
                                <p style="font-size: 18px; font-weight: 700; color: var(--color-primary); margin-top: 4px;">
                                    <fmt:formatNumber value="${opportunity.amount}" type="currency" currencySymbol="₫"/>
                                </p>
                            </div>
                            <div class="form-group">
                                <label style="font-size: 13px; color: var(--color-text-secondary); font-weight: 600;">XÁC SUẤT THÀNH CÔNG</label>
                                <p style="font-size: 16px; font-weight: 600; margin-top: 4px; color: #2563eb;">${opportunity.probability}%</p>
                            </div>
                            <div class="form-group">
                                <label style="font-size: 13px; color: var(--color-text-secondary); font-weight: 600;">NGÀY ĐÓNG DỰ KIẾN / THỰC TẾ</label>
                                <p style="font-size: 15px; margin-top: 4px;">
                                    <c:choose>
                                        <c:when test="${not empty opportunity.closeDate}"><fmt:formatDate value="${opportunity.closeDate}" pattern="dd/MM/yyyy HH:mm"/></c:when>
                                        <c:otherwise><span style="color: #94a3b8;">Đang làm việc</span></c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <div class="form-group">
                                <label style="font-size: 13px; color: var(--color-text-secondary); font-weight: 600;">CHIẾN DỊCH MARKETING</label>
                                <p style="font-size: 15px; margin-top: 4px;">
                                    <c:choose>
                                        <c:when test="${not empty opportunity.campaignName}">
                                            <a href="${pageContext.request.contextPath}/campaigns/detail?id=${opportunity.campaignId}" style="color: var(--color-primary); font-weight: 600; text-decoration: none;">
                                                <i class="fas fa-bullhorn"></i> <c:out value="${opportunity.campaignName}"/>
                                            </a>
                                        </c:when>
                                        <c:when test="${not empty opportunity.campaignId and opportunity.campaignId > 0}">
                                            <a href="${pageContext.request.contextPath}/campaigns/detail?id=${opportunity.campaignId}" style="color: var(--color-primary); font-weight: 600; text-decoration: none;">
                                                <i class="fas fa-bullhorn"></i> Chiến dịch #${opportunity.campaignId}
                                            </a>
                                        </c:when>
                                        <c:otherwise><span style="color: #94a3b8;">Không gắn chiến dịch</span></c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>

                        <!-- Won / Loss Reason & Competitor Info (S2-10) -->
                        <c:if test="${not empty opportunity.reasonName or not empty opportunity.competitorName}">
                            <c:choose>
                                <c:when test="${opportunity.probability ge 100}">
                                    <div style="margin-top: 20px; padding: 16px; border-radius: 8px; background: #f0fdf4; border: 1px solid #bbf7d0;">
                                        <c:if test="${not empty opportunity.reasonName}">
                                            <div style="margin-bottom: 8px;">
                                                <strong style="color: #166534;">
                                                    <i class="fas fa-trophy"></i> Lý do Thắng:
                                                </strong>
                                                <span style="font-size: 15px; font-weight: 500; margin-left: 6px;"><c:out value="${opportunity.reasonName}"/></span>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty opportunity.competitorName}">
                                            <div>
                                                <strong style="color: #991b1b;"><i class="fas fa-user-ninja"></i> Đối thủ cạnh tranh:</strong>
                                                <span style="font-size: 15px; font-weight: 500; margin-left: 6px;"><c:out value="${opportunity.competitorName}"/></span>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="margin-top: 20px; padding: 16px; border-radius: 8px; background: #fef2f2; border: 1px solid #fecaca;">
                                        <c:if test="${not empty opportunity.reasonName}">
                                            <div style="margin-bottom: 8px;">
                                                <strong style="color: #991b1b;">
                                                    <i class="fas fa-times-circle"></i> Lý do Thua:
                                                </strong>
                                                <span style="font-size: 15px; font-weight: 500; margin-left: 6px;"><c:out value="${opportunity.reasonName}"/></span>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty opportunity.competitorName}">
                                            <div>
                                                <strong style="color: #991b1b;"><i class="fas fa-user-ninja"></i> Đối thủ cạnh tranh:</strong>
                                                <span style="font-size: 15px; font-weight: 500; margin-left: 6px;"><c:out value="${opportunity.competitorName}"/></span>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:otherwise>
                            </c:choose>
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
            </c:if>

        </div>
    </main>
</div>
</body>
</html>

