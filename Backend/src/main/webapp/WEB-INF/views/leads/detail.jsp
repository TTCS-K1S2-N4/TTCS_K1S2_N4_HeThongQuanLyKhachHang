<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết Lead: <c:out value="${not empty lead.fullName ? lead.fullName : 'CRM'}"/> | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="content-container">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Chi tiết</span>
                </nav>

                <c:if test="${param.updated == 'true'}">
                    <div class="alert alert-success" style="margin-bottom: 16px;">
                        <i class="fas fa-check-circle"></i> Cập nhật thông tin Lead thành công!
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${empty lead or empty lead.leadId}">
                        <div class="card">
                            <div class="card-body" style="text-align: center; padding: 40px 20px;">
                                <i class="fas fa-exclamation-triangle" style="font-size: 48px; color: var(--color-warning, #f59e0b); margin-bottom: 16px;"></i>
                                <h2 style="font-size: 18px; margin-bottom: 8px;">Không tìm thấy thông tin Lead</h2>
                                <p style="color: var(--color-text-secondary); margin-bottom: 20px;">Lead không tồn tại hoặc đã bị xóa khỏi hệ thống.</p>
                                <a href="${pageContext.request.contextPath}/leads" class="btn btn-primary">
                                    <i class="fas fa-arrow-left"></i> Quay lại danh sách Lead
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                            <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                                <h1 class="page-title" style="margin: 0;">Chi tiết Lead: <c:out value="${lead.fullName}"/></h1>
                                <c:if test="${not empty lead.status}">
                                    <span class="badge status-${lead.status}"><c:out value="${lead.status}"/></span>
                                </c:if>
                                
                                <!-- S4-05 Scoring Badges -->
                                <c:if test="${not empty lead.score}">
                                    <span class="badge score-${lead.classification}">Điểm: ${lead.score} (${lead.classification})</span>
                                </c:if>
                            </div>
                            <div class="page-actions" style="display: flex; gap: 8px; flex-wrap: wrap;">
                                <a href="${pageContext.request.contextPath}/leads/update?id=${lead.leadId}" class="btn btn-primary">
                                    <i class="fas fa-edit"></i> Chỉnh sửa
                                </a>
                                <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">
                                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                                </a>
                            </div>
                        </div>

                        <div class="card detail-card">
                            <div class="card-body">
                                <div class="detail-grid">
                                    <div class="detail-item">
                                        <label class="detail-label">Họ tên</label>
                                        <div class="detail-value"><c:out value="${not empty lead.fullName ? lead.fullName : '-'}"/></div>
                                    </div>
                                    <div class="detail-item">
                                        <label class="detail-label">Email</label>
                                        <div class="detail-value"><c:out value="${not empty lead.email ? lead.email : '-'}"/></div>
                                    </div>
                                    <div class="detail-item">
                                        <label class="detail-label">Số điện thoại</label>
                                        <div class="detail-value"><c:out value="${not empty lead.phone ? lead.phone : '-'}"/></div>
                                    </div>
                                    <div class="detail-item">
                                        <label class="detail-label">Công ty</label>
                                        <div class="detail-value"><c:out value="${not empty lead.company ? lead.company : '-'}"/></div>
                                    </div>
                                    <div class="detail-item full-width">
                                        <label class="detail-label">Nhu cầu quan tâm</label>
                                        <div class="detail-value"><c:out value="${not empty lead.notes ? lead.notes : '-'}"/></div>
                                    </div>
                                    <div class="detail-item">
                                        <label class="detail-label">Nguồn Lead</label>
                                        <div class="detail-value"><c:out value="${not empty lead.sourceName ? lead.sourceName : '-'}"/></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
</body>
</html>
