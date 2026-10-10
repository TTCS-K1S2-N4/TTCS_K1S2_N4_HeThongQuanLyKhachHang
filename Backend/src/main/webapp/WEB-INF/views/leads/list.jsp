<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Lead | CRM System</title>
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
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a> / <span class="breadcrumb-current">Lead</span>
                </nav>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/leads/create" class="btn btn-primary">Tạo Lead</a>
                <a href="${pageContext.request.contextPath}/leads/import" class="btn btn-secondary">Nhập Excel</a>
                <a href="${pageContext.request.contextPath}/lead-forms" class="btn btn-outline">Web Forms</a>
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
                    <h1 class="page-title">Danh sách Lead</h1>
                </div>

                <!-- S4-09 Filter block preserved placeholder -->
                <div class="filter-section">
                    <jsp:include page="saved-filters.jsp" failonerror="false" />
                </div>

                <div class="card">
                    <div class="card-body">
                        <c:if test="${empty leadList}">
                            <div class="empty-state">
                                <p>Chưa có dữ liệu Lead nào.</p>
                                <a href="${pageContext.request.contextPath}/leads/create" class="btn btn-primary">Tạo mới ngay</a>
                            </div>
                        </c:if>

                        <c:if test="${not empty leadList}">
                            <div class="table-responsive">
                                <table class="table leads-table">
                                    <thead>
                                        <tr>
                                            <th>Họ tên</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Công ty</th>
                                            <th>Nguồn</th>
                                            <th>Trạng thái</th>
                                            <!-- S4-05 Scoring Column preserved -->
                                            <th>Điểm / Phân loại</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="lead" items="${leadList}">
                                            <tr>
                                                <td><a href="${pageContext.request.contextPath}/leads/detail?id=${lead.id}" class="text-primary">${lead.fullName}</a></td>
                                                <td>${lead.email}</td>
                                                <td>${lead.phone}</td>
                                                <td>${lead.company}</td>
                                                <td>${lead.source}</td>
                                                <td><span class="badge status-${lead.status}">${lead.status}</span></td>
                                                <!-- S4-05 Scoring integration -->
                                                <td>
                                                    <c:if test="${not empty lead.score}">
                                                        <span class="badge score-${lead.classification}">${lead.score} - ${lead.classification}</span>
                                                    </c:if>
                                                </td>
                                                <td class="actions">
                                                    <a href="${pageContext.request.contextPath}/leads/edit?id=${lead.id}" class="btn btn-sm btn-outline">Sửa</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
