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
                        <c:if test="${empty importResult}">
                            <form action="${pageContext.request.contextPath}/leads/import" method="post" enctype="multipart/form-data" id="importForm">
                                <div class="form-group">
                                    <label for="excelFile">Chọn file Excel (.xlsx, .xls) <span class="required">*</span></label>
                                    <input type="file" id="excelFile" name="file" class="form-control" accept=".xlsx, .xls" required>
                                </div>
                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary" id="btnPreview">Xem trước dữ liệu</button>
                                </div>
                            </form>
                        </c:if>

                        <!-- Preview Results & Commit Phase -->
                        <c:if test="${not empty importResult}">
                            <div class="preview-stats" style="display:flex; gap:16px; margin-bottom:16px;">
                                <div class="stat-item" style="color:#28a745;">Tổng dòng: <strong>${importResult.totalRows}</strong></div>
                                <div class="stat-item" style="color:#007bff;">Hợp lệ: <strong>${importResult.validRows}</strong></div>
                                <div class="stat-item" style="color:#dc3545;">Lỗi: <strong>${importResult.failedRows}</strong></div>
                                <div class="stat-item" style="color:#ffc107;">Trùng lặp: <strong>${importResult.duplicateRows}</strong></div>
                            </div>

                            <div class="table-responsive">
                                <table class="table leads-table preview-table">
                                    <thead>
                                        <tr>
                                            <th>Dòng</th>
                                            <th>Họ tên</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Nguồn</th>
                                            <th>Trạng thái</th>
                                            <th>Lỗi / Ghi chú</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="row" items="${importResult.details}">
                                            <c:choose>
                                                <c:when test="${not row.valid}">
                                                    <tr class="row-error" style="background:#fff3f3;">
                                                </c:when>
                                                <c:when test="${row.duplicate}">
                                                    <tr class="row-duplicate" style="background:#fffbe6;">
                                                </c:when>
                                                <c:otherwise>
                                                    <tr class="row-valid">
                                                </c:otherwise>
                                            </c:choose>
                                                <td>${row.rowIndex}</td>
                                                <td>${row.fullName}</td>
                                                <td>${row.email}</td>
                                                <td>${row.phone}</td>
                                                <td>${row.sourceName}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not row.valid}"><span style="color:#dc3545;">&#x2716; Lỗi</span></c:when>
                                                        <c:when test="${row.duplicate}"><span style="color:#ffc107;">&#x26A0; Trùng lặp</span></c:when>
                                                        <c:otherwise><span style="color:#28a745;">&#x2714; Hợp lệ</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="error-text" style="color:#dc3545; font-size:0.85em;">
                                                    ${row.error}
                                                    <c:if test="${not empty row.duplicateReason}">
                                                        <em style="color:#856404;">${row.duplicateReason}</em>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <form action="${pageContext.request.contextPath}/leads/import" method="post" id="commitForm">
                                <input type="hidden" name="action" value="execute">
                                <input type="hidden" name="skipDuplicates" value="true">
                                <div class="form-actions" style="margin-top: 20px; display:flex; gap:12px;">
                                    <button type="submit" class="btn btn-primary" ${importResult.validRows == 0 ? 'disabled' : ''} id="btnCommit">
                                        Lưu ${importResult.validRows} dòng hợp lệ
                                    </button>
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
