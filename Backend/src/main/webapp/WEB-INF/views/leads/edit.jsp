<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa Lead | CRM System</title>
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
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a> / <a href="${pageContext.request.contextPath}/leads">Lead</a> / <span class="breadcrumb-current">Chỉnh sửa</span>
                </nav>
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
                    <h1 class="page-title">Chỉnh sửa Lead: ${lead.fullName}</h1>
                    <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.id}" class="btn btn-outline">Quay lại chi tiết</a>
                </div>
                
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger">${errorMessage}</div>
                </c:if>

                <div class="card form-card">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/leads/edit" method="post" class="lead-form">
                            <input type="hidden" name="id" value="${lead.id}">
                            
                            <div class="form-group">
                                <label for="fullName">Họ tên <span class="required">*</span></label>
                                <input type="text" id="fullName" name="fullName" class="form-control" value="${not empty param.fullName ? param.fullName : lead.fullName}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" class="form-control" value="${not empty param.email ? param.email : lead.email}">
                            </div>

                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="text" id="phone" name="phone" class="form-control" value="${not empty param.phone ? param.phone : lead.phone}">
                            </div>

                            <div class="form-group">
                                <label for="company">Công ty</label>
                                <input type="text" id="company" name="company" class="form-control" value="${not empty param.company ? param.company : lead.company}">
                            </div>

                            <div class="form-group">
                                <label for="interest">Nhu cầu quan tâm</label>
                                <textarea id="interest" name="interest" class="form-control" rows="3">${not empty param.interest ? param.interest : lead.interest}</textarea>
                            </div>

                            <div class="form-group">
                                <label for="source">Nguồn Lead <span class="required">*</span></label>
                                <select id="source" name="source" class="form-control" required>
                                    <option value="">-- Chọn nguồn --</option>
                                    <c:forEach var="src" items="${sources}">
                                        <option value="${src.id}" ${(not empty param.source ? param.source : lead.source) == src.id ? 'selected' : ''}>${src.name}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
