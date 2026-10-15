<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhập dữ liệu khách hàng từ Excel | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/import.css">
    <style>
        .import-page-wrapper {
            max-width: 980px;
            margin: 0 auto;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="content-container">
            <div class="import-page-wrapper">
                
                <!-- Breadcrumb Navigation -->
                <div class="import-breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> CRM</a>
                    <span class="separator"><i class="fa-solid fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                    <span class="separator"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="current">Nhập dữ liệu từ Excel</span>
                </div>

                <!-- Page Header Row -->
                <div class="import-header-card">
                    <div class="import-title-group">
                        <div class="import-title-icon">
                            <i class="fa-solid fa-file-excel"></i>
                        </div>
                        <div class="import-title-content">
                            <h1>Nhập dữ liệu khách hàng từ Excel</h1>
                            <p>Tự động hóa nhập danh sách khách hàng số lượng lớn với tính năng kiểm tra lỗi và phát hiện trùng lặp thông minh.</p>
                        </div>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/customers" class="btn-back-link">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách khách hàng
                        </a>
                    </div>
                </div>

                <!-- Error Alert if present -->
                <c:set var="alertMsg" value="${not empty errorMessage ? errorMessage : error}" />
                <c:if test="${not empty alertMsg}">
                    <div class="import-alert-error">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 20px;"></i>
                        <div style="flex: 1;">
                            <strong>Đã xảy ra lỗi:</strong> <span id="toast-import-err"><c:out value="${alertMsg}"/></span>
                        </div>
                        <button type="button" onclick="this.parentElement.style.display='none'" style="background:none; border:none; color:#991b1b; cursor:pointer; font-size:16px;">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>
                </c:if>

                <!-- Main Content Operations -->
                <div class="import-main-col">
                    
                    <!-- Step 1: Template Download Card -->
                    <div class="import-card">
                        <div class="import-card-header">
                            <div class="import-card-header-title">
                                <span class="step-badge">Bước 1</span>
                                <h3>Tải file mẫu Excel chuẩn</h3>
                            </div>
                            <span style="font-size: 12px; color: #16a34a; background: #ecfdf5; padding: 3px 8px; border-radius: 4px; font-weight: 600;">
                                <i class="fa-solid fa-circle-check"></i> Khuyên dùng
                            </span>
                        </div>
                        <div class="import-card-body">
                            <div class="template-box">
                                <div class="template-details">
                                    <div class="template-icon-wrap">
                                        <i class="fa-solid fa-file-excel"></i>
                                    </div>
                                    <div class="template-text">
                                        <h4>File mẫu thông tin khách hàng (.xlsx)</h4>
                                        <p>Chứa sẵn cấu trúc cột chuẩn và dòng dữ liệu mẫu minh họa giúp việc nhập liệu không bị sai lệch.</p>
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/customers/import/template" class="btn-template-download" id="btnDownloadTemplate">
                                    <i class="fa-solid fa-download"></i> Tải Template Excel
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Step 2: Upload File Card -->
                    <div class="import-card">
                        <div class="import-card-header">
                            <div class="import-card-header-title">
                                <span class="step-badge">Bước 2</span>
                                <h3>Tải lên tệp dữ liệu khách hàng</h3>
                            </div>
                            <span style="font-size: 12px; color: #64748b;">
                                <i class="fa-solid fa-shield-halved" style="color: #2563eb;"></i> Kiểm tra an toàn trước khi lưu
                            </span>
                        </div>
                        <div class="import-card-body">
                            
                            <form id="importUploadForm" method="post" action="${pageContext.request.contextPath}/customers/import/preview" enctype="multipart/form-data">
                                
                                <!-- Drag and Drop Dropzone -->
                                <div class="dropzone-container" id="dropzoneContainer">
                                    <div class="dropzone-icon">
                                        <i class="fa-solid fa-cloud-arrow-up"></i>
                                    </div>
                                    <div class="dropzone-title">Kéo và thả tệp Excel vào đây</div>
                                    <div class="dropzone-subtitle">hoặc bấm vào khu vực này để duyệt tệp từ máy tính của bạn</div>
                                    <div>
                                        <span class="dropzone-btn">
                                            <i class="fa-regular fa-folder-open"></i> Chọn tệp từ máy tính
                                        </span>
                                    </div>
                                    <div class="dropzone-specs">
                                        <span><i class="fa-regular fa-file-excel"></i> Định dạng: .xlsx, .xls</span>
                                        <span><i class="fa-solid fa-weight-hanging"></i> Tối đa: 10 MB</span>
                                    </div>
                                    
                                    <!-- Hidden Native File Input -->
                                    <input type="file" name="file" id="importFileInput" accept=".xlsx, .xls" style="display: none;" required>
                                </div>

                                <!-- Selected File Preview Box -->
                                <div class="selected-file-card" id="selectedFileCard">
                                    <div class="selected-file-content">
                                        <div class="selected-file-left">
                                            <div class="file-badge-icon">
                                                <i class="fa-solid fa-file-excel"></i>
                                            </div>
                                            <div class="file-info-details">
                                                <h5 id="selectedFileName">ten-file-du-lieu.xlsx</h5>
                                                <div class="file-info-meta">
                                                    <span id="selectedFileSize">0 KB</span>
                                                    <span>•</span>
                                                    <span class="badge-ready"><i class="fa-solid fa-check"></i> Sẵn sàng phân tích</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="selected-file-actions">
                                            <button type="button" class="btn-back-link" style="padding: 6px 12px; font-size: 12.5px;" id="btnChangeFile">
                                                <i class="fa-solid fa-arrow-rotate-right"></i> Đổi file khác
                                            </button>
                                            <button type="button" class="btn-remove-file" id="btnRemoveFile">
                                                <i class="fa-solid fa-trash-can"></i> Xóa
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Form Footer Actions -->
                                <div class="import-form-footer">
                                    <div class="submit-hint-text">
                                        <i class="fa-solid fa-info-circle" style="color: #2563eb;"></i>
                                        Dữ liệu sẽ được đối soát cú pháp và kiểm tra trùng lặp trước khi thực thi.
                                    </div>
                                    <button type="submit" class="btn-submit-preview" id="btnSubmitPreview" disabled>
                                        <i class="fa-solid fa-magnifying-glass-chart"></i> Tiếp tục: Xem trước dữ liệu (Preview)
                                    </button>
                                </div>
                                
                            </form>

                        </div>
                    </div>

                </div>

            </div>
        </div>
    </main>
</div>

<!-- Loading Overlay during upload analysis -->
<div class="import-loading-overlay" id="loadingOverlay">
    <div class="import-spinner"></div>
    <div style="font-size: 16px; font-weight: 600;">Đang tải và phân tích dữ liệu Excel...</div>
    <div style="font-size: 13px; color: #cbd5e1; margin-top: 6px;">Vui lòng chờ trong giây lát</div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const dropzone = document.getElementById('dropzoneContainer');
    const fileInput = document.getElementById('importFileInput');
    const selectedFileCard = document.getElementById('selectedFileCard');
    const selectedFileName = document.getElementById('selectedFileName');
    const selectedFileSize = document.getElementById('selectedFileSize');
    const btnRemoveFile = document.getElementById('btnRemoveFile');
    const btnChangeFile = document.getElementById('btnChangeFile');
    const btnSubmit = document.getElementById('btnSubmitPreview');
    const uploadForm = document.getElementById('importUploadForm');
    const loadingOverlay = document.getElementById('loadingOverlay');

    function formatBytes(bytes, decimals = 1) {
        if (!bytes || bytes === 0) return '0 Bytes';
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    function updateFileDisplay(file) {
        if (!file) {
            selectedFileCard.style.display = 'none';
            dropzone.style.display = 'block';
            btnSubmit.disabled = true;
            fileInput.value = '';
            return;
        }

        // Validate extension
        const fileName = file.name;
        const ext = fileName.slice((fileName.lastIndexOf(".") - 1 >>> 0) + 2).toLowerCase();
        if (ext !== 'xlsx' && ext !== 'xls') {
            (typeof window.showToast === 'function' ? window.showToast('warning', 'Vui lòng chỉ chọn tệp Excel (.xlsx hoặc .xls)') : window.alert('Vui lòng chỉ chọn tệp Excel (.xlsx hoặc .xls)'));
            updateFileDisplay(null);
            return;
        }

        // Validate size (10MB)
        if (file.size > 10 * 1024 * 1024) {
            (typeof window.showToast === 'function' ? window.showToast('warning', 'Kích thước tệp vượt quá 10MB cho phép. Vui lòng chọn tệp nhỏ hơn.') : window.alert('Kích thước tệp vượt quá 10MB cho phép. Vui lòng chọn tệp nhỏ hơn.'));
            updateFileDisplay(null);
            return;
        }

        selectedFileName.textContent = file.name;
        selectedFileSize.textContent = formatBytes(file.size);
        selectedFileCard.style.display = 'block';
        dropzone.style.display = 'none';
        btnSubmit.disabled = false;
    }

    // Trigger file chooser
    dropzone.addEventListener('click', function (e) {
        fileInput.click();
    });

    btnChangeFile.addEventListener('click', function () {
        fileInput.click();
    });

    btnRemoveFile.addEventListener('click', function () {
        updateFileDisplay(null);
    });

    // File input change
    fileInput.addEventListener('change', function () {
        if (fileInput.files && fileInput.files.length > 0) {
            updateFileDisplay(fileInput.files[0]);
        } else {
            updateFileDisplay(null);
        }
    });

    // Drag & Drop events
    ['dragenter', 'dragover'].forEach(eventName => {
        dropzone.addEventListener(eventName, function (e) {
            e.preventDefault();
            e.stopPropagation();
            dropzone.classList.add('dragover');
        });
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, function (e) {
            e.preventDefault();
            e.stopPropagation();
            dropzone.classList.remove('dragover');
        });
    });

    dropzone.addEventListener('drop', function (e) {
        if (e.dataTransfer && e.dataTransfer.files.length > 0) {
            const droppedFile = e.dataTransfer.files[0];
            fileInput.files = e.dataTransfer.files;
            updateFileDisplay(droppedFile);
        }
    });

    // Submit handler: show loading overlay
    uploadForm.addEventListener('submit', function (e) {
        if (!fileInput.files || fileInput.files.length === 0) {
            e.preventDefault();
            (typeof window.showToast === 'function' ? window.showToast('warning', 'Vui lòng chọn file Excel trước khi tiếp tục.') : window.alert('Vui lòng chọn file Excel trước khi tiếp tục.'));
            return;
        }
        loadingOverlay.style.display = 'flex';
    });
});
</script>
<c:if test="${empty errorMessage and not empty error}">
<script>
(function() {
    var message = document.getElementById('toast-import-err');
    if (message && message.textContent.trim() && typeof window.showToast === 'function') {
        window.showToast('error', message.textContent.trim());
    }
})();
</script>
</c:if>
</body>
</html>
