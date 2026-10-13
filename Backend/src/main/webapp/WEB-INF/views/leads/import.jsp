<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập Lead từ Excel | CRM System</title>
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
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a> / <a href="${pageContext.request.contextPath}/leads">Lead</a> / <span class="breadcrumb-current">Nhập Excel</span>
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
                    <h1 class="page-title">Nhập dữ liệu Lead</h1>
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">Quay lại</a>
                </div>

                <div class="card form-card">
                    <div class="card-body">
                        <!-- File Upload Form (Preview Phase) -->
                        <c:if test="${empty previewMode}">
                            <form action="${pageContext.request.contextPath}/leads/import/preview" method="post" enctype="multipart/form-data" id="importForm">
                                <div class="form-group">
                                    <label for="excelFile">Chọn file Excel (.xlsx, .xls) <span class="required">*</span></label>
                                    <input type="file" id="excelFile" name="file" class="form-control" accept=".xlsx, .xls" required>
                                </div>
                                <div class="form-group">
                                    <label for="source">Nguồn áp dụng cho tất cả Lead nhập vào <span class="required">*</span></label>
                                    <select id="source" name="source" class="form-control" required>
                                        <option value="">-- Chọn nguồn --</option>
                                        <c:forEach var="src" items="${sources}">
                                            <option value="${src.id}">${src.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary" id="btnPreview">Xem trước dữ liệu</button>
                                </div>
                            </form>
                        </c:if>

                        <!-- Preview Results & Commit Phase -->
                        <c:if test="${not empty previewMode}">
                            <div class="preview-stats">
                                <div class="stat-item valid">Dòng hợp lệ: <strong>${validCount}</strong></div>
                                <div class="stat-item invalid">Dòng lỗi: <strong>${invalidCount}</strong></div>
                            </div>
                            
                            <div class="table-responsive">
                                <table class="table leads-table preview-table">
                                    <thead>
                                        <tr>
                                            <th>Dòng</th>
                                            <th>Họ tên</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Lỗi</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="row" items="${previewRows}">
                                            <tr class="${not empty row.errors ? 'row-error' : 'row-valid'}">
                                                <td>${row.rowNumber}</td>
                                                <td>${row.fullName}</td>
                                                <td>${row.email}</td>
                                                <td>${row.phone}</td>
                                                <td class="error-text">${row.errors}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <form action="${pageContext.request.contextPath}/leads/import/commit" method="post" id="commitForm">
                                <input type="hidden" name="importToken" value="${importToken}">
                                <div class="form-actions" style="margin-top: 20px;">
                                    <button type="submit" class="btn btn-primary" ${validCount == 0 ? 'disabled' : ''} id="btnCommit">Lưu ${validCount} dòng hợp lệ</button>
                                    <a href="${pageContext.request.contextPath}/leads/import" class="btn btn-secondary">Tải lên file khác</a>
                                </div>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-import.js"></script>
</body>
</html>
