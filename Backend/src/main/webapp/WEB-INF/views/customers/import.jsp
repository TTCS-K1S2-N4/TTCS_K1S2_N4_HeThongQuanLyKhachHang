<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Import Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h1 class="page-title" style="margin: 0;">Nhập dữ liệu khách hàng từ Excel</h1>
                <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary" style="background: white; border: 1px solid #cbd5e1; padding: 8px 16px; border-radius: 6px; color: #334155; text-decoration: none; font-weight: 500; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách khách hàng
                </a>
            </div>

            <div class="card mb-4">
                <div class="card-header">
                    <h4>Bước 1: Tải template</h4>
                </div>
                <div class="card-body">
                    <p>Vui lòng tải xuống file mẫu (template) và điền dữ liệu khách hàng theo đúng định dạng.</p>
                    <a href="${pageContext.request.contextPath}/customers/import/template" class="btn btn-info">Tải Template Excel</a>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h4>Bước 2: Tải lên file Excel</h4>
                </div>
                <div class="card-body">
                    <form method="post" action="${pageContext.request.contextPath}/customers/import/preview" enctype="multipart/form-data">
                        <div class="form-group mb-3">
                            <label for="importFile" class="form-label">Chọn file Excel (.xlsx)</label>
                            <input type="file" name="file" id="importFile" class="form-control" accept=".xlsx" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Xem trước (Preview)</button>
                    </form>
                </div>
            </div>

        </div>
    </main>
</div>
<c:if test="${not empty error}">
    <input type="hidden" id="toast-import-err" value="<c:out value='${error}'/>">
</c:if>
<script>
    (function() {
        var errInput = document.getElementById('toast-import-err');
        if (errInput && errInput.value && typeof window.showToast === 'function') {
            window.showToast('error', errInput.value);
        }

        var form = document.querySelector('form');
        var fileInput = document.getElementById('importFile');
        if (form && fileInput) {
            form.addEventListener('submit', function(e) {
                if (fileInput.files && fileInput.files.length > 0) {
                    var fileName = fileInput.files[0].name;
                    if (!fileName.toLowerCase().endsWith('.xlsx')) {
                        e.preventDefault();
                        if (typeof window.showToast === 'function') {
                            window.showToast('warning', 'Vui lòng chọn file Excel đúng định dạng (.xlsx)');
                        } else {
                            alert('Vui lòng chọn file Excel đúng định dạng (.xlsx)');
                        }
                    }
                }
            });
        }
    })();
</script>
</body>
</html>
