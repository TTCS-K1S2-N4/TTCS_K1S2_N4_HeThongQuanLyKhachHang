<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhập Lead từ Excel | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
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
                    <span class="breadcrumb-current">Nhập Excel</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h1 class="page-title">Nhập dữ liệu Lead từ Excel</h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                            Tải lên danh sách Lead từ file Excel (.xlsx, .xls) để xem trước, kiểm tra tính hợp lệ và nhập vào hệ thống.
                        </p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px;">
                        <i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/>
                    </div>
                </c:if>

                <c:if test="${not empty importedCount}">
                    <div class="alert alert-success" style="margin-bottom: 16px;">
                        <i class="fas fa-check-circle"></i> Import thành công <strong><c:out value="${importedCount}"/></strong> Lead vào hệ thống!
                        <div style="margin-top: 8px;">
                            <a href="${pageContext.request.contextPath}/leads" class="btn btn-primary btn-sm">Xem danh sách Lead</a>
                        </div>
                    </div>
                </c:if>

                <div class="card form-card" style="max-width: ${not empty importResult ? '100%' : '700px'};">
                    <div class="card-body">
                        <!-- File Upload Form (Preview Phase) -->
                        <c:if test="${empty importResult}">
                            <form action="${pageContext.request.contextPath}/leads/import" method="post" enctype="multipart/form-data" id="importForm">
                                <div class="form-group">
                                    <label for="excelFile">Chọn file Excel (.xlsx, .xls) <span class="required">*</span></label>
                                    <input type="file" id="excelFile" name="file" class="form-control" accept=".xlsx, .xls" required>
                                    <small style="color: var(--color-text-secondary); display: block; margin-top: 6px;">
                                        Hỗ trợ định dạng .xlsx, .xls. Dung lượng tối đa 10MB.
                                    </small>
                                </div>
                                <div class="form-actions" style="display: flex; gap: 8px; margin-top: 20px;">
                                    <button type="submit" class="btn btn-primary" id="btnPreview">
                                        <i class="fas fa-eye"></i> Xem trước dữ liệu
                                    </button>
                                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">Hủy</a>
                                </div>
                            </form>
                        </c:if>

                        <!-- Preview Results & Commit Phase -->
                        <c:if test="${not empty importResult}">
                            <div class="preview-stats">
                                <div class="stat-item" style="background: #f1f5f9; color: #334155;">Tổng dòng: <strong>${importResult.totalRows}</strong></div>
                                <div class="stat-item valid">Hợp lệ: <strong>${importResult.validRows}</strong></div>
                                <div class="stat-item invalid">Lỗi: <strong>${importResult.failedRows}</strong></div>
                                <div class="stat-item" style="background: #fffbeb; color: #b45309;">Trùng lặp: <strong>${importResult.duplicateRows}</strong></div>
                            </div>

                            <div class="table-responsive">
                                <table class="table leads-table preview-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 50px;">Dòng</th>
                                            <th>Họ tên</th>
                                            <th>Công ty</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Nguồn</th>
                                            <th>Trạng thái</th>
                                            <th>Kết quả</th>
                                            <th>Lỗi / Ghi chú</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="row" items="${importResult.details}">
                                            <c:choose>
                                                <c:when test="${not row.valid}">
                                                    <tr class="row-error">
                                                </c:when>
                                                <c:when test="${row.duplicate}">
                                                    <tr class="row-duplicate" style="background:#fffbe6;">
                                                </c:when>
                                                <c:otherwise>
                                                    <tr class="row-valid">
                                                </c:otherwise>
                                            </c:choose>
                                                <td>${row.rowIndex}</td>
                                                <td><c:out value="${not empty row.fullName ? row.fullName : '-'}"/></td>
                                                <td><c:out value="${not empty row.company ? row.company : '-'}"/></td>
                                                <td><c:out value="${not empty row.email ? row.email : '-'}"/></td>
                                                <td><c:out value="${not empty row.phone ? row.phone : '-'}"/></td>
                                                <td><c:out value="${not empty row.sourceName ? row.sourceName : '-'}"/></td>
                                                <td><c:out value="${not empty row.status ? row.status : '-'}"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not row.valid}"><span class="badge" style="background:#fee2e2; color:#dc2626;"><i class="fas fa-times-circle"></i> Lỗi</span></c:when>
                                                        <c:when test="${row.duplicate}"><span class="badge" style="background:#fef3c7; color:#d97706;"><i class="fas fa-exclamation-triangle"></i> Trùng lặp</span></c:when>
                                                        <c:otherwise><span class="badge" style="background:#dcfce7; color:#16a34a;"><i class="fas fa-check-circle"></i> Hợp lệ</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="error-text">
                                                    <c:if test="${not empty row.error}">
                                                        <div><c:out value="${row.error}"/></div>
                                                    </c:if>
                                                    <c:if test="${not empty row.duplicateReason}">
                                                        <div style="color:#b45309; font-style: italic;"><c:out value="${row.duplicateReason}"/></div>
                                                    </c:if>
                                                    <c:if test="${empty row.error && empty row.duplicateReason}">
                                                        <span style="color: #16a34a;">-</span>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <form action="${pageContext.request.contextPath}/leads/import" method="post" id="commitForm">
                                <input type="hidden" name="action" value="execute">
                                <div style="margin-top: 16px; margin-bottom: 16px;">
                                    <label style="display: flex; align-items: center; gap: 8px; font-weight: normal; cursor: pointer;">
                                        <input type="checkbox" name="skipDuplicates" value="true" checked>
                                        Bỏ qua các dòng trùng lặp (không ghi đè dữ liệu hiện có)
                                    </label>
                                </div>
                                <div class="form-actions" style="margin-top: 20px; display:flex; gap:12px; flex-wrap: wrap;">
                                    <button type="submit" class="btn btn-primary" ${importResult.validRows == 0 ? 'disabled' : ''} id="btnCommit">
                                        <i class="fas fa-upload"></i> Lưu ${importResult.validRows} dòng hợp lệ
                                    </button>
                                    <a href="${pageContext.request.contextPath}/leads/import" class="btn btn-secondary">Tải lên file khác</a>
                                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">Hủy bỏ</a>
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
