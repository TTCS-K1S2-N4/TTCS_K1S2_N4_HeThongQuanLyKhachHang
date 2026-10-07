<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhập người dùng từ Excel | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .import-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 24px;
        }
        .import-dropzone {
            border: 2px dashed #cbd5e1;
            border-radius: 12px;
            padding: 40px 20px;
            text-align: center;
            background-color: #f8fafc;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            margin-bottom: 20px;
        }
        .import-dropzone:hover, .import-dropzone.dragover {
            border-color: #4f46e5;
            background-color: #eef2ff;
        }
        .import-icon {
            font-size: 44px;
            color: #4f46e5;
            margin-bottom: 12px;
        }
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 16px;
            text-align: center;
        }
        .stat-number {
            font-size: 28px;
            font-weight: 700;
        }
        .stat-number.valid { color: #16a34a; }
        .stat-number.invalid { color: #dc2626; }
        .stat-number.total { color: #2563eb; }

        .preview-table-container {
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            margin-bottom: 24px;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-badge.valid { background-color: #dcfce7; color: #166534; }
        .status-badge.invalid { background-color: #fee2e2; color: #991b1b; }
        
        .report-box {
            padding: 16px;
            border-radius: 8px;
            margin-top: 20px;
            display: none;
        }
        .report-box.success {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }
        .report-box.error {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #991b1b;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="content-container import-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Nhập người dùng hàng loạt</span>
            </nav>

            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div>
                    <h1 class="page-title" style="margin: 0;">Nhập người dùng hàng loạt từ Excel</h1>
                    <p class="page-description" style="margin: 4px 0 0 0; color: #64748b;">Tạo tài khoản nhanh cho nhân viên từ tệp mẫu .xlsx</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/import/excel/template" class="btn btn-secondary">
                        <i class="fa-solid fa-file-arrow-down"></i> Tải tệp mẫu (.xlsx)
                    </a>
                </div>
            </div>

            <div class="card" style="background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px;">
                <form id="importForm" action="${pageContext.request.contextPath}/import/excel/preview" method="POST" enctype="multipart/form-data">
                    <div class="import-dropzone" id="dropArea">
                        <div class="import-icon"><i class="fa-solid fa-file-excel"></i></div>
                        <h3 style="margin: 0 0 8px 0; font-size: 16px; color: #1e293b;">Kéo thả tệp Excel vào đây hoặc nhấp để chọn</h3>
                        <p style="margin: 0; font-size: 14px; color: #64748b;">Chỉ chấp nhận tệp có định dạng <strong>.xlsx</strong></p>
                        <input type="file" name="file" id="fileInput" accept=".xlsx" style="display: none;" required>
                    </div>

                    <div id="fileInfo" style="text-align: center; margin-bottom: 16px; font-weight: 600; color: #2563eb;"></div>

                    <div style="display: flex; justify-content: center; gap: 12px;">
                        <button type="submit" class="btn btn-primary" id="btnPreview" disabled>
                            <i class="fa-solid fa-magnifying-glass"></i> Xem trước & Kiểm tra dữ liệu
                        </button>
                    </div>
                </form>

                <div id="previewSection" style="display: none; margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 24px;">
                    <h2 style="font-size: 18px; margin-bottom: 16px; color: #0f172a;">Kết quả kiểm tra tệp Excel</h2>

                    <div class="stats-cards">
                        <div class="stat-card">
                            <div style="font-size: 13px; color: #64748b;">Tổng số dòng dữ liệu</div>
                            <div class="stat-number total" id="totalCount">0</div>
                        </div>
                        <div class="stat-card">
                            <div style="font-size: 13px; color: #64748b;">Dòng hợp lệ (Sẽ nhập)</div>
                            <div class="stat-number valid" id="validCount">0</div>
                        </div>
                        <div class="stat-card">
                            <div style="font-size: 13px; color: #64748b;">Dòng lỗi (Sẽ bỏ qua)</div>
                            <div class="stat-number invalid" id="invalidCount">0</div>
                        </div>
                    </div>

                    <div class="preview-table-container">
                        <table class="data-table" id="previewTable" style="width: 100%; border-collapse: collapse;">
                            <thead>
                                <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; text-align: left;">
                                    <th style="padding: 12px; width: 70px;">STT</th>
                                    <th style="padding: 12px;">Họ và tên</th>
                                    <th style="padding: 12px;">Email</th>
                                    <th style="padding: 12px;">Số điện thoại</th>
                                    <th style="padding: 12px; width: 120px;">Trạng thái</th>
                                    <th style="padding: 12px;">Ghi chú / Chi tiết lỗi</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px;">
                        <a href="${pageContext.request.contextPath}/accounts/list" class="btn btn-secondary">Hủy bỏ</a>
                        <button type="button" class="btn btn-success" id="btnExecute" style="background-color: #16a34a; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 600; cursor: pointer;">
                            <i class="fa-solid fa-cloud-arrow-up"></i> Xác nhận Thực hiện Import
                        </button>
                    </div>
                </div>

                <div id="importReportBox" class="report-box">
                    <h3 id="reportTitle" style="margin-top: 0; font-size: 16px;">Báo cáo tổng kết Import</h3>
                    <p id="reportSummary" style="margin-bottom: 8px; font-weight: 600;"></p>
                    <ul id="reportDetails" style="margin: 0; padding-left: 20px; max-height: 200px; overflow-y: auto;"></ul>
                    <div style="margin-top: 16px;">
                        <a href="${pageContext.request.contextPath}/accounts/list" class="btn btn-primary">Chuyển tới Danh sách Tài khoản</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    const dropArea = document.getElementById('dropArea');
    const fileInput = document.getElementById('fileInput');
    const fileInfo = document.getElementById('fileInfo');
    const btnPreview = document.getElementById('btnPreview');
    const btnExecute = document.getElementById('btnExecute');
    const previewSection = document.getElementById('previewSection');
    const reportBox = document.getElementById('importReportBox');
    let currentFile = null;

    dropArea.addEventListener('click', () => fileInput.click());

    dropArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropArea.classList.add('dragover');
    });

    dropArea.addEventListener('dragleave', () => {
        dropArea.classList.remove('dragover');
    });

    dropArea.addEventListener('drop', (e) => {
        e.preventDefault();
        dropArea.classList.remove('dragover');
        if (e.dataTransfer.files.length) {
            fileInput.files = e.dataTransfer.files;
            handleFileSelect();
        }
    });

    fileInput.addEventListener('change', handleFileSelect);

    function handleFileSelect() {
        if (fileInput.files.length > 0) {
            currentFile = fileInput.files[0];
            fileInfo.textContent = 'Đã chọn tệp: ' + currentFile.name + ' (' + (currentFile.size / 1024).toFixed(1) + ' KB)';
            btnPreview.disabled = false;
            previewSection.style.display = 'none';
            reportBox.style.display = 'none';
        }
    }

    document.getElementById('importForm').addEventListener('submit', function(e) {
        e.preventDefault();
        if (!currentFile) return;

        reportBox.style.display = 'none';
        const formData = new FormData();
        formData.append('file', currentFile);

        btnPreview.disabled = true;
        btnPreview.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang phân tích...';

        fetch(contextPath + '/import/excel/preview', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(async res => {
            const data = await res.json();
            if (!res.ok) {
                throw new Error(data.error || data.message || 'Lỗi khi kiểm tra tệp Excel.');
            }
            return data;
        })
        .then(data => {
            previewSection.style.display = 'block';
            const validCount = data.validRows || 0;
            const invalidCount = data.invalidRows || 0;
            const totalCount = validCount + invalidCount;

            document.getElementById('totalCount').textContent = totalCount;
            document.getElementById('validCount').textContent = validCount;
            document.getElementById('invalidCount').textContent = invalidCount;

            btnExecute.disabled = validCount <= 0;

            const tbody = document.querySelector('#previewTable tbody');
            tbody.innerHTML = '';

            const rowsToDisplay = data.allRows && data.allRows.length > 0 ? data.allRows : (data.rowErrors || []);

            if (rowsToDisplay.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: #64748b;">Không tìm thấy dòng dữ liệu nào trong tệp Excel.</td></tr>';
            } else {
                rowsToDisplay.forEach((row, idx) => {
                    const tr = document.createElement('tr');
                    tr.style.borderBottom = '1px solid #f1f5f9';

                    const isValid = row.isValid !== false && (!row.error || row.error.trim() === '');
                    const statusHtml = isValid
                        ? '<span class="status-badge valid"><i class="fa-solid fa-check"></i> Hợp lệ</span>'
                        : '<span class="status-badge invalid"><i class="fa-solid fa-triangle-exclamation"></i> Lỗi</span>';

                    const errorText = isValid ? '<span style="color: #64748b;">Đủ điều kiện nhập</span>' : '<span style="color: #dc2626; font-weight: 500;">' + (row.error || 'Dữ liệu không hợp lệ') + '</span>';

                    tr.innerHTML = `
                        <td style="padding: 10px 12px;">` + (row.rowIndex || (idx + 1)) + `</td>
                        <td style="padding: 10px 12px; font-weight: 500;">` + (row.fullName || '') + `</td>
                        <td style="padding: 10px 12px;">` + (row.email || '') + `</td>
                        <td style="padding: 10px 12px;">` + (row.phone || '') + `</td>
                        <td style="padding: 10px 12px;">` + statusHtml + `</td>
                        <td style="padding: 10px 12px;">` + errorText + `</td>
                    `;
                    tbody.appendChild(tr);
                });
            }
        })
        .catch(err => {
            alert('Lỗi: ' + err.message);
        })
        .finally(() => {
            btnPreview.disabled = false;
            btnPreview.innerHTML = '<i class="fa-solid fa-magnifying-glass"></i> Xem trước & Kiểm tra dữ liệu';
        });
    });

    btnExecute.addEventListener('click', function() {
        if (confirm('Bạn có chắc chắn muốn tiến hành import các dòng dữ liệu hợp lệ vào hệ thống?')) {
            btnExecute.disabled = true;
            btnExecute.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang import...';

            fetch(contextPath + '/import/excel/execute', {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(async res => {
                const data = await res.json();
                if (!res.ok) {
                    throw new Error(data.error || data.message || 'Không thể thực hiện Import.');
                }
                return data;
            })
            .then(data => {
                previewSection.style.display = 'none';
                reportBox.style.display = 'block';
                reportBox.className = 'report-box ' + (data.successCount > 0 ? 'success' : 'error');

                document.getElementById('reportTitle').textContent = 'BÁO CÁO TỔNG KẾT KẾT QUẢ IMPORT';
                document.getElementById('reportSummary').textContent = 
                    'Tổng số dòng trong tệp: ' + data.totalRows + ' | ' +
                    'Thành công: ' + data.successCount + ' dòng | ' +
                    'Thất bại / Bỏ qua: ' + data.failedCount + ' dòng';

                const detailsList = document.getElementById('reportDetails');
                detailsList.innerHTML = '';

                if (data.errors && data.errors.length > 0) {
                    data.errors.forEach(errText => {
                        const li = document.createElement('li');
                        li.textContent = errText;
                        detailsList.appendChild(li);
                    });
                } else if (data.successCount > 0) {
                    const li = document.createElement('li');
                    li.textContent = 'Tất cả các dòng dữ liệu hợp lệ đã được nhập thành công.';
                    detailsList.appendChild(li);
                }

                fileInput.value = '';
                fileInfo.textContent = '';
                btnPreview.disabled = true;
                currentFile = null;
            })
            .catch(err => {
                alert('Lỗi khi thực hiện import: ' + err.message);
                btnExecute.disabled = false;
                btnExecute.innerHTML = '<i class="fa-solid fa-cloud-arrow-up"></i> Xác nhận Thực hiện Import';
            });
        }
    });
</script>
</body>
</html>
