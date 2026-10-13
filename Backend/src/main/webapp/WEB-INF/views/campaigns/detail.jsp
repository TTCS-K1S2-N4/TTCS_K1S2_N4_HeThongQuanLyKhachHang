<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết Chiến dịch | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <style>
        .metric-card {
            background: white;
            border: 1px solid var(--color-border);
            border-radius: 8px;
            padding: 16px;
            text-align: center;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        .metric-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--color-primary);
            margin: 8px 0;
        }
        .metric-label {
            font-size: 13px;
            color: var(--color-text-secondary);
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
                    <a href="${pageContext.request.contextPath}/campaigns">Chiến dịch</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Chi tiết</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;">
                    <h1 class="page-title"><c:out value="${campaign.name}" /></h1>
                    <a href="${pageContext.request.contextPath}/campaigns/edit?id=${campaign.id}" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);"><i class="fas fa-edit"></i> Sửa</a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px; padding: 12px; background: #fee2e2; color: #dc2626; border-radius: 6px;">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <!-- Metrics Section -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
                    <div class="metric-card">
                        <div class="metric-label">Tổng số Lead sinh ra</div>
                        <div class="metric-value">
                            <c:choose>
                                <c:when test="${not empty leadCount}">${leadCount}</c:when>
                                <c:otherwise><span style="color: #94a3b8; font-size: 16px;">(Đang cập nhật)</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Tổng số Cơ hội (Opportunity)</div>
                        <div class="metric-value">
                            <c:choose>
                                <c:when test="${not empty opportunityCount}">${opportunityCount}</c:when>
                                <c:otherwise><span style="color: #94a3b8; font-size: 16px;">(Đang cập nhật)</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Doanh thu đạt được (Closed Value)</div>
                        <div class="metric-value" style="color: #16a34a;">
                            <c:choose>
                                <c:when test="${not empty closedValue}">
                                    <fmt:formatNumber value="${closedValue}" pattern="#,##0" /> đ
                                </c:when>
                                <c:otherwise><span style="color: #94a3b8; font-size: 16px;">(Đang cập nhật)</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title" style="font-size: 16px;"><i class="fas fa-info-circle"></i> Thông tin chung</h2>
                    </div>
                    <div class="card-body">
                        <table style="width: 100%; border-collapse: collapse;">
                            <tbody>
                                <tr style="border-bottom: 1px solid var(--color-border);">
                                    <td style="padding: 12px 0; font-weight: 500; color: var(--color-text-secondary); width: 150px;">Kênh</td>
                                    <td style="padding: 12px 0;"><c:out value="${campaign.channel}" /></td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--color-border);">
                                    <td style="padding: 12px 0; font-weight: 500; color: var(--color-text-secondary);">Ngân sách</td>
                                    <td style="padding: 12px 0;"><fmt:formatNumber value="${campaign.budget}" pattern="#,##0" /></td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--color-border);">
                                    <td style="padding: 12px 0; font-weight: 500; color: var(--color-text-secondary);">Ngày bắt đầu</td>
                                    <td style="padding: 12px 0;"><fmt:formatDate value="${campaign.startDate}" pattern="dd/MM/yyyy" /></td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px 0; font-weight: 500; color: var(--color-text-secondary);">Ngày kết thúc</td>
                                    <td style="padding: 12px 0;"><fmt:formatDate value="${campaign.endDate}" pattern="dd/MM/yyyy" /></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>
</body>
</html>
