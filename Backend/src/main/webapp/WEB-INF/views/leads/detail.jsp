<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Lead | CRM System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
</head>
<body>
    <div class="app">
        <header class="app-header">
            <div class="header-left">
                <a class="header-brand" href="${pageContext.request.contextPath}/">CRM System</a>
                <div class="header-divider"></div>
                <nav class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a> / <a href="${pageContext.request.contextPath}/leads">Lead</a> / <span class="breadcrumb-current">Chi tiết</span>
                </nav>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/leads/edit?id=${lead.id}" class="btn btn-primary">Chỉnh sửa</a>
            </div>
        </header>
        <aside class="sidebar">
            <nav aria-label="Điều hướng chính">
                <div class="sidebar-section">
                    <a class="nav-item active" href="${pageContext.request.contextPath}/leads">Lead</a>
                </div>
            </nav>
        </aside>
        <main class="main-content">
            <div class="content-container">
                <div class="page-header">
                    <h1 class="page-title">Chi tiết Lead: ${lead.fullName}</h1>
                    <span class="badge status-${lead.status}">${lead.status}</span>
                    
                    <!-- S4-05 Scoring Badges -->
                    <c:if test="${not empty lead.score}">
                        <span class="badge score-${lead.classification}">Điểm: ${lead.score} (${lead.classification})</span>
                    </c:if>
                </div>

                <div class="card detail-card">
                    <div class="card-body">
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label class="detail-label">Họ tên</label>
                                <div class="detail-value">${lead.fullName}</div>
                            </div>
                            <div class="detail-item">
                                <label class="detail-label">Email</label>
                                <div class="detail-value">${lead.email}</div>
                            </div>
                            <div class="detail-item">
                                <label class="detail-label">Số điện thoại</label>
                                <div class="detail-value">${lead.phone}</div>
                            </div>
                            <div class="detail-item">
                                <label class="detail-label">Công ty</label>
                                <div class="detail-value">${lead.company}</div>
                            </div>
                            <div class="detail-item full-width">
                                <label class="detail-label">Nhu cầu quan tâm</label>
                                <div class="detail-value">${lead.interest}</div>
                            </div>
                            <div class="detail-item">
                                <label class="detail-label">Nguồn Lead</label>
                                <div class="detail-value">${lead.source}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
