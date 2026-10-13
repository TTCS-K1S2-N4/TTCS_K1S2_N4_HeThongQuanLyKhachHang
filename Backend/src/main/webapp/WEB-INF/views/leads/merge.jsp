<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Gộp Lead | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <style>
        .merge-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
        }
        .lead-card {
            background: white;
            border: 1px solid var(--color-border);
            border-radius: 8px;
            padding: 20px;
        }
        .lead-card.primary {
            border-color: #3b82f6;
            box-shadow: 0 0 0 1px #3b82f6;
        }
        .data-row {
            display: flex;
            border-bottom: 1px solid var(--color-border);
            padding: 12px 0;
        }
        .data-label {
            width: 120px;
            font-weight: 500;
            color: var(--color-text-secondary);
        }
        .data-value {
            flex: 1;
            color: var(--color-gray-900);
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
                    <span class="breadcrumb-current">Gộp Lead</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px;">
                    <h1 class="page-title">Xác nhận Gộp Lead</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Dữ liệu của Lead bị gộp sẽ được hợp nhất vào Lead chính và được lưu trữ lịch sử.</p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px; padding: 12px; background: #fee2e2; color: #dc2626; border-radius: 6px;">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <div class="merge-grid">
                    <!-- Primary Lead -->
                    <div class="lead-card primary">
                        <div style="margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between;">
                            <h3 style="font-size: 16px; margin: 0; color: #1d4ed8;"><i class="fas fa-star" style="color: #3b82f6;"></i> Lead Chính (Giữ lại)</h3>
                        </div>
                        <div class="data-row">
                            <div class="data-label">Tên Lead</div>
                            <div class="data-value"><strong><c:out value="${primaryLead.name}" /></strong></div>
                        </div>
                        <div class="data-row">
                            <div class="data-label">Email</div>
                            <div class="data-value"><c:out value="${primaryLead.email}" /></div>
                        </div>
                        <div class="data-row">
                            <div class="data-label">SĐT</div>
                            <div class="data-value"><c:out value="${primaryLead.phone}" /></div>
                        </div>
                        <div class="data-row">
                            <div class="data-label">Công ty</div>
                            <div class="data-value"><c:out value="${primaryLead.company}" /></div>
                        </div>
                        <div class="data-row" style="border-bottom: none;">
                            <div class="data-label">Nguồn</div>
                            <div class="data-value"><c:out value="${primaryLead.source}" /></div>
                        </div>
                    </div>

                    <!-- Duplicate Lead -->
                    <div class="lead-card">
                        <div style="margin-bottom: 16px;">
                            <h3 style="font-size: 16px; margin: 0; color: var(--color-text-secondary);"><i class="fas fa-copy"></i> Lead Bị gộp (Sẽ ẩn đi)</h3>
                        </div>
                        <div class="data-row">
                            <div class="data-label">Tên Lead</div>
                            <div class="data-value"><strong><c:out value="${duplicateLead.name}" /></strong></div>
                        </div>
                        <div class="data-row">
                            <div class="data-label">Email</div>
                            <div class="data-value"><c:out value="${duplicateLead.email}" /></div>
                        </div>
                        <div class="data-row">
                            <div class="data-label">SĐT</div>
                            <div class="data-value"><c:out value="${duplicateLead.phone}" /></div>
                        </div>
                        <div class="data-row">
                            <div class="data-label">Công ty</div>
                            <div class="data-value"><c:out value="${duplicateLead.company}" /></div>
                        </div>
                        <div class="data-row" style="border-bottom: none;">
                            <div class="data-label">Nguồn</div>
                            <div class="data-value"><c:out value="${duplicateLead.source}" /></div>
                        </div>
                    </div>
                </div>

                <div style="background: white; padding: 24px; border-radius: 8px; border: 1px solid var(--color-border); box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-align: center;">
                    <form action="${pageContext.request.contextPath}/leads/merge" method="post" id="mergeForm">
                        <input type="hidden" name="primaryLeadId" value="${primaryLead.id}" />
                        <input type="hidden" name="duplicateLeadId" value="${duplicateLead.id}" />
                        
                        <p style="margin-bottom: 16px; color: var(--color-gray-900);">Bạn có chắc chắn muốn gộp 2 Lead này không? Quá trình gộp sẽ được lưu vào lịch sử.</p>
                        
                        <div style="display: flex; justify-content: center; gap: 12px;">
                            <a href="${pageContext.request.contextPath}/leads/duplicates?leadId=${primaryLead.id}" class="btn btn-secondary" style="padding: 8px 16px; background: white; border: 1px solid var(--color-border);">Hủy bỏ</a>
                            <button type="submit" class="btn btn-primary" onclick="return confirm('Xác nhận GỘP Lead?');" style="padding: 8px 16px;"><i class="fas fa-compress-alt"></i> Xác nhận Gộp</button>
                        </div>
                    </form>
                </div>

            </div>
        </main>
    </div>
</body>
</html>
