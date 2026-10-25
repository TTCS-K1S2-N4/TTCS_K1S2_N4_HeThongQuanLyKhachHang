<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhập Lead từ Excel | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="content-container lead-page-container">
                
                <!-- Breadcrumb Navigation -->
                <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px;">
                    <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Quản lý Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Nhập Excel</span>
                </nav>

                <!-- Page Header Banner -->
                <div class="lead-header-banner">
                    <div class="lead-header-left">
                        <div class="lead-header-icon-box" style="background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%); border-color: #a7f3d0; color: #059669;">
                            <i class="fa-solid fa-file-excel"></i>
                        </div>
                        <div class="lead-header-titles">
                            <h1 class="lead-page-title">
                                Nhập dữ liệu Lead từ Excel
                                <span class="badge" style="background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; border-radius: 6px; font-size: 0.72rem; padding: 3px 8px; font-weight: 700;">
                                    Batch Import
                                </span>
                            </h1>
                            <p class="lead-page-subtitle">
                                Tải lên danh sách Lead từ file Excel (.xlsx, .xls) để xem trước, kiểm tra tính hợp lệ và nhập vào hệ thống.
                            </p>
                        </div>
                    </div>

                    <div class="lead-header-actions">
                        <a href="${pageContext.request.contextPath}/leads/import/template" class="btn-lead-action" title="Tải file Excel mẫu (.xlsx)">
                            <i class="fa-solid fa-file-arrow-down"></i> Tải file mẫu
                        </a>
                        <a href="${pageContext.request.contextPath}/leads" class="btn-lead-action" title="Quay lại danh sách Lead">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Alert Notifications -->
                <c:if test="${not empty error}">
                    <div class="alert" style="background: #fef2f2; border: 1px solid #fecaca; border-left: 4px solid #ef4444; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #991b1b; display: flex; align-items: center; gap: 10px; font-weight: 500;">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.1rem; color: #ef4444;"></i>
                        <span><c:out value="${error}"/></span>
                    </div>
                </c:if>

                <c:if test="${not empty importedCount}">
                    <div class="alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; border-left: 4px solid #10b981; border-radius: 10px; padding: 16px 20px; margin-bottom: 20px; color: #065f46;">
                        <div style="display: flex; align-items: center; gap: 10px; font-weight: 600; font-size: 0.95rem;">
                            <i class="fa-solid fa-circle-check" style="font-size: 1.2rem; color: #10b981;"></i>
                            <span>Import thành công <strong><c:out value="${importedCount}"/></strong> Lead vào hệ thống Frostline CRM!</span>
                        </div>
                        <div style="margin-top: 12px; margin-left: 30px;">
                            <a href="${pageContext.request.contextPath}/leads" class="btn-lead-primary" style="padding: 7px 16px; font-size: 0.82rem;">
                                <i class="fa-solid fa-list"></i> Xem danh sách Lead ngay
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- PHASE 1: FILE UPLOAD (When no preview result) -->
                <c:if test="${empty importResult}">
                    <div class="import-card-wrapper" style="max-width: 860px; margin: 0 auto;">
                        <!-- Upload Card with Drag & Drop Zone -->
                        <div class="import-dropzone-card">
                            <div style="margin-bottom: 20px;">
                                <h3 style="font-size: 1.1rem; font-weight: 700; color: #0f172a; margin: 0 0 6px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fa-solid fa-cloud-arrow-up" style="color: #2563eb;"></i> Tải lên file dữ liệu
                                </h3>
                                <p style="font-size: 0.85rem; color: #64748b; margin: 0;">
                                    Chọn file Excel (.xlsx, .xls) chứa danh sách khách hàng tiềm năng để bắt đầu xem trước và phân tích.
                                </p>
                            </div>

                            <form action="${pageContext.request.contextPath}/leads/import" method="post" enctype="multipart/form-data" id="importForm">
                                <!-- Hidden Real Input for Browser Form Handling -->
                                <input type="file" id="excelFile" name="file" accept=".xlsx, .xls" required style="position: absolute; opacity: 0; width: 0; height: 0; pointer-events: none;">

                                <!-- Modern Dropzone -->
                                <div class="import-dropzone" id="dropzoneBox" onclick="document.getElementById('excelFile').click();">
                                    <div class="import-dropzone-icon">
                                        <i class="fa-solid fa-file-excel"></i>
                                    </div>
                                    <div class="import-dropzone-title">
                                        Kéo thả file Excel vào đây hoặc <span>chọn từ máy tính</span>
                                    </div>
                                    <div class="import-dropzone-subtitle">
                                        Hệ thống sẽ quét cấu trúc cột, kiểm tra dữ liệu và phát hiện trùng lặp tự động
                                    </div>
                                    <div class="import-file-tags">
                                        <span class="import-badge-tag"><i class="fa-solid fa-check"></i> .XLSX</span>
                                        <span class="import-badge-tag"><i class="fa-solid fa-check"></i> .XLS</span>
                                        <span class="import-badge-tag">Tối đa 10 MB</span>
                                    </div>
                                </div>

                                <!-- File Preview Bar (Shown when a file is selected) -->
                                <div class="import-file-preview-bar" id="filePreviewBar">
                                    <div class="import-file-preview-left">
                                        <div class="import-file-icon-box">
                                            <i class="fa-solid fa-file-excel"></i>
                                        </div>
                                        <div>
                                            <div class="import-file-meta-name" id="fileNameDisplay">lead_template.xlsx</div>
                                            <div class="import-file-meta-size" id="fileSizeDisplay">Sẵn sàng phân tích</div>
                                        </div>
                                    </div>
                                    <button type="button" class="btn-lead-action" style="padding: 5px 12px; font-size: 0.78rem;" onclick="document.getElementById('excelFile').click();">
                                        <i class="fa-solid fa-arrows-rotate"></i> Thay đổi file
                                    </button>
                                </div>

                                <!-- Default Source Selection (Particularly helpful for seminar/event imports) -->
                                <div style="margin-top: 18px; padding-top: 14px; border-top: 1px dashed #e2e8f0;">
                                    <label for="defaultSourceId" style="display: block; font-size: 0.85rem; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                        <i class="fa-solid fa-tag" style="color: #2563eb;"></i> Nguồn Lead mặc định cho tệp <span style="color: #dc2626;">*</span>
                                    </label>
                                    <select id="defaultSourceId" name="defaultSourceId" style="width: 100%; max-width: 360px; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.875rem; background: #ffffff; color: #0f172a;">
                                        <c:forEach var="src" items="${sources}">
                                            <option value="${src.sourceId}" ${src.sourceCode == 'EVENT' || src.sourceId == selectedSourceId ? 'selected' : ''}>
                                                <c:out value="${src.sourceName}"/> (${src.sourceCode})
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <div style="font-size: 0.78rem; color: #64748b; margin-top: 4px;">
                                        Áp dụng tự động cho các dòng chưa điền nguồn (Ví dụ: chọn <strong>Hội thảo / Sự kiện</strong> khi nhập danh sách thu được từ hội thảo).
                                    </div>
                                </div>

                                <div class="form-actions" style="display: flex; gap: 12px; margin-top: 24px; align-items: center;">
                                    <button type="submit" class="btn-lead-primary" id="btnPreview" style="padding: 10px 22px;">
                                        <i class="fa-solid fa-eye"></i> Xem trước dữ liệu
                                    </button>
                                    <a href="${pageContext.request.contextPath}/leads" class="btn-filter-reset">
                                        Hủy bỏ
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:if>

                <!-- PHASE 2: PREVIEW RESULTS & COMMIT PHASE (When importResult is present) -->
                <c:if test="${not empty importResult}">
                    
                    <!-- 4 Summary KPI Metrics -->
                    <div class="lead-kpi-row" style="margin-bottom: 20px;">
                        <div class="lead-kpi-box lead-kpi-blue">
                            <div class="lead-kpi-info">
                                <span class="lead-kpi-label">Tổng số dòng</span>
                                <span class="lead-kpi-val">${importResult.totalRows}</span>
                            </div>
                            <div class="lead-kpi-icon">
                                <i class="fa-solid fa-list-ol"></i>
                            </div>
                        </div>

                        <div class="lead-kpi-box lead-kpi-emerald">
                            <div class="lead-kpi-info">
                                <span class="lead-kpi-label">Dòng hợp lệ</span>
                                <span class="lead-kpi-val" style="color: #059669;">${importResult.validRows}</span>
                            </div>
                            <div class="lead-kpi-icon">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                        </div>

                        <div class="lead-kpi-box lead-kpi-rose">
                            <div class="lead-kpi-info">
                                <span class="lead-kpi-label">Dòng lỗi</span>
                                <span class="lead-kpi-val" style="color: #dc2626;">${importResult.failedRows}</span>
                            </div>
                            <div class="lead-kpi-icon">
                                <i class="fa-solid fa-circle-xmark"></i>
                            </div>
                        </div>

                        <div class="lead-kpi-box lead-kpi-amber">
                            <div class="lead-kpi-info">
                                <span class="lead-kpi-label">Dòng trùng lặp</span>
                                <span class="lead-kpi-val" style="color: #d97706;">${importResult.duplicateRows}</span>
                            </div>
                            <div class="lead-kpi-icon">
                                <i class="fa-solid fa-clone"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Preview Table Card -->
                    <div class="lead-table-card" style="margin-bottom: 24px;">
                        <div class="lead-table-header">
                            <h2 class="lead-table-title">
                                <i class="fa-solid fa-table-list" style="color: #2563eb;"></i>
                                Bảng kiểm tra trước khi ghi dữ liệu (${importResult.totalRows} dòng)
                            </h2>
                            <div class="lead-sort-pill">
                                <i class="fa-solid fa-shield-halved" style="color: #059669;"></i>
                                <span>Kiểm tra tính toàn vẹn hoàn tất</span>
                            </div>
                        </div>

                        <div class="table-container" style="overflow-x: auto; max-height: 480px;">
                            <table class="lead-modern-table">
                                <thead style="position: sticky; top: 0; z-index: 2;">
                                    <tr>
                                        <th style="width: 60px;">Dòng</th>
                                        <th>Họ tên</th>
                                        <th>Công ty</th>
                                        <th>Email</th>
                                        <th>Số điện thoại</th>
                                        <th>Nguồn</th>
                                        <th>Trạng thái</th>
                                        <th>Kết quả</th>
                                        <th>Lỗi / Ghi chú chi tiết</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="row" items="${importResult.details}">
                                        <tr class="${not row.valid ? 'row-error' : (row.duplicate ? 'row-duplicate' : 'row-valid')}">
                                            <td style="font-weight: 700; color: #64748b;">#${row.rowIndex}</td>
                                            <td style="font-weight: 600; color: #0f172a;"><c:out value="${not empty row.fullName ? row.fullName : '-'}"/></td>
                                            <td><c:out value="${not empty row.company ? row.company : '-'}"/></td>
                                            <td><c:out value="${not empty row.email ? row.email : '-'}"/></td>
                                            <td><c:out value="${not empty row.phone ? row.phone : '-'}"/></td>
                                            <td><span class="badge" style="background:#f1f5f9; color:#475569; border-radius:6px; padding:3px 8px; font-weight:600;"><c:out value="${not empty row.sourceName ? row.sourceName : '-'}"/></span></td>
                                            <td><c:out value="${not empty row.status ? row.status : '-'}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not row.valid}">
                                                        <span class="lead-status-pill" style="background: #fee2e2; color: #dc2626; border: 1px solid #fecaca;">
                                                            <i class="fa-solid fa-circle-xmark"></i> Lỗi
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${row.duplicate}">
                                                        <span class="lead-status-pill" style="background: #fef3c7; color: #d97706; border: 1px solid #fde68a;">
                                                            <i class="fa-solid fa-triangle-exclamation"></i> Trùng lặp
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="lead-status-pill" style="background: #dcfce7; color: #16a34a; border: 1px solid #bbf7d0;">
                                                            <i class="fa-solid fa-circle-check"></i> Hợp lệ
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size: 0.8rem;">
                                                <c:if test="${not empty row.error}">
                                                    <div style="color: #dc2626; font-weight: 500;"><c:out value="${row.error}"/></div>
                                                </c:if>
                                                <c:if test="${not empty row.duplicateReason}">
                                                    <div style="color: #b45309; font-style: italic;"><c:out value="${row.duplicateReason}"/></div>
                                                </c:if>
                                                <c:if test="${empty row.error && empty row.duplicateReason}">
                                                    <span style="color: #16a34a;"><i class="fa-solid fa-check"></i> Đạt chuẩn</span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Commit Actions Card -->
                    <div class="lead-filter-card">
                        <form action="${pageContext.request.contextPath}/leads/import" method="post" id="commitForm">
                            <input type="hidden" name="action" value="execute">
                            
                            <div style="margin-bottom: 18px; padding-bottom: 16px; border-bottom: 1px solid #f1f5f9;">
                                <label style="display: inline-flex; align-items: center; gap: 10px; cursor: pointer; font-size: 0.9rem; font-weight: 600; color: #0f172a; user-select: none;">
                                    <input type="checkbox" name="skipDuplicates" value="true" checked style="width: 18px; height: 18px; accent-color: #2563eb; cursor: pointer;">
                                    <span>Bỏ qua các dòng trùng lặp (khuyên dùng để bảo vệ dữ liệu hiện có)</span>
                                </label>
                            </div>

                            <div style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
                                <button type="submit" class="btn-lead-primary" ${importResult.validRows == 0 ? 'disabled' : ''} id="btnCommit" style="${importResult.validRows == 0 ? 'opacity: 0.5; cursor: not-allowed;' : ''}">
                                    <i class="fa-solid fa-cloud-arrow-up"></i> Lưu ${importResult.validRows} dòng hợp lệ vào hệ thống
                                </button>
                                <a href="${pageContext.request.contextPath}/leads/import" class="btn-lead-action">
                                    <i class="fa-solid fa-arrows-rotate"></i> Tải lên file khác
                                </a>
                                <a href="${pageContext.request.contextPath}/leads" class="btn-filter-reset">
                                    Hủy bỏ
                                </a>
                            </div>
                        </form>
                    </div>

                </c:if>

            </div>
        </main>
    </div>

    <!-- UI Interactions Script -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var fileInput = document.getElementById("excelFile");
            var dropzone = document.getElementById("dropzoneBox");
            var previewBar = document.getElementById("filePreviewBar");
            var nameDisplay = document.getElementById("fileNameDisplay");
            var sizeDisplay = document.getElementById("fileSizeDisplay");

            if (fileInput && dropzone) {
                // Drag & Drop events
                ["dragenter", "dragover"].forEach(function(eventName) {
                    dropzone.addEventListener(eventName, function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        dropzone.classList.add("dragover");
                    }, false);
                });

                ["dragleave", "drop"].forEach(function(eventName) {
                    dropzone.addEventListener(eventName, function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        dropzone.classList.remove("dragover");
                    }, false);
                });

                dropzone.addEventListener("drop", function(e) {
                    var dt = e.dataTransfer;
                    var files = dt.files;
                    if (files && files.length > 0) {
                        fileInput.files = files;
                        updateFilePreview(files[0]);
                    }
                }, false);

                // File selected via dialog
                fileInput.addEventListener("change", function() {
                    if (fileInput.files && fileInput.files.length > 0) {
                        updateFilePreview(fileInput.files[0]);
                    }
                });

                function updateFilePreview(file) {
                    if (!file) return;
                    if (nameDisplay) nameDisplay.textContent = file.name;
                    if (sizeDisplay) {
                        var sizeKb = Math.round(file.size / 1024);
                        var sizeStr = sizeKb >= 1024 ? (sizeKb / 1024).toFixed(2) + " MB" : sizeKb + " KB";
                        sizeDisplay.textContent = sizeStr + " • Sẵn sàng tải lên";
                    }
                    if (previewBar) previewBar.classList.add("show");
                }
            }
        });

        // Function to download official sample Excel template
        function downloadSampleTemplate() {
            window.location.href = "${pageContext.request.contextPath}/leads/import/template";
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-import.js"></script>
</body>
</html>
