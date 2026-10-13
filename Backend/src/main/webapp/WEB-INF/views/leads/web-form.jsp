<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Web Forms | CRM System</title>
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
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a> / <a href="${pageContext.request.contextPath}/leads">Lead</a> / <span class="breadcrumb-current">Web Forms</span>
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
                    <h1 class="page-title">Cấu hình Web Form (Thu thập Lead)</h1>
                </div>
                
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success">${successMessage}</div>
                </c:if>

                <div class="card form-card">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/lead-forms" method="post">
                            <div class="form-group">
                                <label for="formName">Tên biểu mẫu <span class="required">*</span></label>
                                <input type="text" id="formName" name="formName" class="form-control" value="${not empty formName ? formName : 'Biểu mẫu mặc định'}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="source">Nguồn Lead tự động gán <span class="required">*</span></label>
                                <select id="source" name="source" class="form-control" required>
                                    <option value="">-- Chọn nguồn --</option>
                                    <c:forEach var="src" items="${sources}">
                                        <option value="${src.id}" ${source == src.id ? 'selected' : ''}>${src.name}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">Lưu cấu hình</button>
                            </div>
                        </form>
                    </div>
                </div>

                <c:if test="${not empty webForms}">
                    <h2 class="section-title" style="margin-top: 30px;">Danh sách biểu mẫu đã lưu</h2>
                    <div class="card">
                        <div class="card-body">
                            <table class="table leads-table">
                                <thead>
                                    <tr>
                                        <th>Tên biểu mẫu</th>
                                        <th>Nguồn liên kết</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="f" items="${webForms}">
                                        <tr>
                                            <td>${f.name}</td>
                                            <td>${f.sourceName}</td>
                                            <td class="actions">
                                                <a href="${pageContext.request.contextPath}/lead-forms/embed?formId=${f.id}" class="btn btn-sm btn-secondary">Lấy mã nhúng</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:if>
            </div>
        </main>
    </div>
</body>
</html>
