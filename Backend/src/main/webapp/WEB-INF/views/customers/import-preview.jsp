<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Xem trước &amp; Xác nhận Import Khách hàng | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/import.css">
    <style>
        .import-page-wrapper {
            max-width: 1200px;
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
                    <a href="${pageContext.request.contextPath}/customers/import">Nhập Excel</a>
                    <span class="separator"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="current">
                        <c:choose>
                            <c:when test="${executed}">Kết quả thực thi</c:when>
                            <c:otherwise>Xem trước &amp; Đối soát</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <!-- Page Header Row -->
                <div class="import-header-card">
                    <div class="import-title-group">
                        <c:choose>
                            <c:when test="${executed}">
                                <div class="import-title-icon" style="background: linear-gradient(135deg, #16a34a 0%, #15803d 100%); box-shadow: 0 8px 16px rgba(22, 163, 74, 0.25);">
                                    <i class="fa-solid fa-square-check"></i>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="import-title-icon" style="background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); box-shadow: 0 8px 16px rgba(30, 58, 138, 0.25);">
                                    <i class="fa-solid fa-magnifying-glass-chart"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        
                        <div class="import-title-content">
                            <c:choose>
                                <c:when test="${executed}">
                                    <h1>Báo cáo kết quả Import Khách hàng</h1>
                                    <p>Dữ liệu đã được xử lý và ghi vào cơ sở dữ liệu hệ thống CRM.</p>
                                </c:when>
                                <c:otherwise>
                                    <h1>Kết quả phân tích &amp; Xem trước dữ liệu</h1>
                                    <p>Kiểm tra chi tiết từng dòng dữ liệu, phát hiện trùng lặp và xác nhận trước khi lưu.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/customers" class="btn-back-link">
                            <i class="fa-solid fa-arrow-left"></i> Danh sách khách hàng
                        </a>
                    </div>
                </div>

                <!-- Error Alert if any -->
                <c:if test="${not empty errorMessage}">
                    <div class="import-alert-error">
                        <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                        <div style="flex: 1;"><c:out value="${errorMessage}"/></div>
                    </div>
                </c:if>

                <!-- When Execution is Complete -->
                <c:if test="${executed}">
                    <div class="execution-result-card">
                        <div class="execution-result-header">
                            <div class="execution-result-icon">
                                <i class="fa-solid fa-check"></i>
                            </div>
                            <div class="execution-result-title">
                                <h3>Hoàn tất quá trình Import Khách hàng!</h3>
                                <p><c:out value="${message}"/></p>
                            </div>
                        </div>

                        <div class="execution-stats-bar">
                            <div class="exec-stat-item">
                                <i class="fa-solid fa-list-ol" style="color: #64748b; margin-right: 4px;"></i>
                                Tổng số dòng: <strong>${total != null ? total : 0}</strong>
                            </div>
                            <div class="exec-stat-item" style="color: #15803d;">
                                <i class="fa-solid fa-circle-check" style="margin-right: 4px;"></i>
                                Nhập thành công: <strong>${success != null ? success : 0}</strong> dòng
                            </div>
                            <div class="exec-stat-item" style="color: #b45309;">
                                <i class="fa-solid fa-clone" style="margin-right: 4px;"></i>
                                Bỏ qua / Trùng lặp: <strong>${skipped != null ? skipped : 0}</strong> dòng
                            </div>
                            <div class="exec-stat-item" style="color: #b91c1c;">
                                <i class="fa-solid fa-circle-xmark" style="margin-right: 4px;"></i>
                                Thất bại: <strong>${failed != null ? failed : 0}</strong> dòng
                            </div>
                        </div>

                        <c:if test="${not empty errors}">
                            <div style="background: #ffffff; border: 1px solid #fecaca; border-radius: 8px; padding: 16px; margin-bottom: 20px;">
                                <h5 style="margin: 0 0 10px 0; color: #b91c1c; font-size: 14px; font-weight: 700;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Chi tiết lỗi / Cảnh báo:
                                </h5>
                                <div style="max-height: 180px; overflow-y: auto;">
                                    <ul style="margin: 0; padding-left: 20px; font-size: 13px; color: #991b1b;">
                                        <c:forEach var="errText" items="${errors}">
                                            <li style="margin-bottom: 4px;"><c:out value="${errText}"/></li>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </div>
                        </c:if>

                        <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                            <a href="${pageContext.request.contextPath}/customers" class="btn-submit-preview" style="text-decoration: none;">
                                <i class="fa-solid fa-users"></i> Xem danh sách khách hàng
                            </a>
                            <a href="${pageContext.request.contextPath}/customers/import" class="btn-back-link">
                                <i class="fa-solid fa-file-excel"></i> Tiếp tục Import tệp khác
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- Statistics Metric Cards (Before Execution) -->
                <c:if test="${not executed}">
                    <c:set var="totalComputed" value="${(validRowsCount != null ? validRowsCount : 0) + (invalidRowsCount != null ? invalidRowsCount : 0) + (duplicateRowsCount != null ? duplicateRowsCount : 0)}"/>
                    <div class="stats-cards-grid">
                        <div class="stat-card-metric total">
                            <div class="stat-info-wrap">
                                <div class="stat-label">Tổng số bản ghi</div>
                                <div class="stat-number">${totalRows != null ? totalRows : totalComputed}</div>
                            </div>
                            <div class="stat-metric-icon">
                                <i class="fa-solid fa-file-lines"></i>
                            </div>
                        </div>

                        <div class="stat-card-metric valid">
                            <div class="stat-info-wrap">
                                <div class="stat-label">Hợp lệ (Sẵn sàng)</div>
                                <div class="stat-number" style="color: #10b981;">${validRowsCount != null ? validRowsCount : 0}</div>
                            </div>
                            <div class="stat-metric-icon">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                        </div>

                        <div class="stat-card-metric duplicate">
                            <div class="stat-info-wrap">
                                <div class="stat-label">Trùng lặp</div>
                                <div class="stat-number" style="color: #f59e0b;">${duplicateRowsCount != null ? duplicateRowsCount : 0}</div>
                            </div>
                            <div class="stat-metric-icon">
                                <i class="fa-solid fa-clone"></i>
                            </div>
                        </div>

                        <div class="stat-card-metric error">
                            <div class="stat-info-wrap">
                                <div class="stat-label">Cú pháp lỗi</div>
                                <div class="stat-number" style="color: #ef4444;">${invalidRowsCount != null ? invalidRowsCount : 0}</div>
                            </div>
                            <div class="stat-metric-icon">
                                <i class="fa-solid fa-circle-exclamation"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Execution Form with Duplicate Strategy Selection -->
                    <form id="executeImportForm" method="post" action="${pageContext.request.contextPath}/customers/import/execute">
                        
                        <c:if test="${duplicateRowsCount gt 0}">
                            <div class="conflict-resolution-card">
                                <div class="conflict-header">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                    <span>Phát hiện ${duplicateRowsCount} bản ghi trùng lặp (Theo MST hoặc Số điện thoại)</span>
                                </div>
                                <p style="font-size: 13px; color: #78350f; margin-top: 0; margin-bottom: 14px;">
                                    Vui lòng chọn cách thức hệ thống xử lý các dòng khách hàng bị trùng lặp:
                                </p>
                                
                                <div class="conflict-options">
                                    <label class="conflict-option-card selected" id="optSkipCard">
                                        <input type="radio" name="duplicateAction" value="SKIP" checked onchange="handleConflictOption(this)">
                                        <div class="conflict-option-label">
                                            <h6>Bỏ qua các bản ghi trùng lặp (SKIP) - Mặc định</h6>
                                            <p>Giữ nguyên dữ liệu khách hàng hiện tại trong CRM, chỉ thêm mới các dòng hợp lệ chưa từng tồn tại.</p>
                                        </div>
                                    </label>

                                    <label class="conflict-option-card" id="optUpdateCard">
                                        <input type="radio" name="duplicateAction" value="UPDATE" onchange="handleConflictOption(this)">
                                        <div class="conflict-option-label">
                                            <h6>Cập nhật thông tin cho khách hàng đã có (UPDATE)</h6>
                                            <p>Ghi đè và cập nhật các trường thông tin mới từ file Excel vào hồ sơ khách hàng hiện tại.</p>
                                        </div>
                                    </label>
                                </div>
                            </div>
                        </c:if>

                        <div class="preview-actions-bar">
                            <div style="font-size: 13px; color: #64748b;">
                                <i class="fa-solid fa-shield-check" style="color: #10b981; margin-right: 4px;"></i>
                                Nhấn xác nhận để bắt đầu ghi các dòng hợp lệ vào cơ sở dữ liệu.
                            </div>
                            <div style="display: flex; gap: 12px; align-items: center;">
                                <a href="${pageContext.request.contextPath}/customers/import" class="btn-back-link">
                                    <i class="fa-solid fa-xmark"></i> Hủy bỏ / Chọn file khác
                                </a>
                                <button type="submit" class="btn-execute-import" <c:if test="${(empty validRowsCount or validRowsCount == 0) and (empty duplicateRowsCount or duplicateRowsCount == 0)}">disabled="disabled"</c:if>>
                                    <i class="fa-solid fa-cloud-arrow-up"></i> Xác nhận Thực hiện Import
                                </button>
                            </div>
                        </div>

                    </form>
                </c:if>

                <!-- Detailed Table Section -->
                <div class="preview-table-card">
                    <div class="import-card-header">
                        <div class="import-card-header-title">
                            <i class="fa-solid fa-table-list" style="color: #1e3a8a; font-size: 18px;"></i>
                            <h3>Chi tiết bảng xem trước dữ liệu</h3>
                        </div>
                        <div style="font-size: 13px; color: #64748b;">
                            Tổng: <strong>${totalRows != null ? totalRows : (not empty allRows ? fn:length(allRows) : 0)}</strong> dòng
                        </div>
                    </div>

                    <div style="padding: 16px 20px 0 20px;">
                        <!-- Filter Tabs -->
                        <div class="table-filter-bar">
                            <div class="table-filter-tabs">
                                <button type="button" class="filter-tab active" data-filter="all">
                                    <i class="fa-solid fa-list"></i> Tất cả
                                    <span class="badge-count">${totalRows != null ? totalRows : (not empty allRows ? fn:length(allRows) : 0)}</span>
                                </button>
                                <button type="button" class="filter-tab" data-filter="valid">
                                    <i class="fa-solid fa-circle-check" style="color: #10b981;"></i> Hợp lệ
                                    <span class="badge-count">${validRowsCount != null ? validRowsCount : 0}</span>
                                </button>
                                <button type="button" class="filter-tab" data-filter="duplicate">
                                    <i class="fa-solid fa-clone" style="color: #f59e0b;"></i> Trùng lặp
                                    <span class="badge-count">${duplicateRowsCount != null ? duplicateRowsCount : 0}</span>
                                </button>
                                <button type="button" class="filter-tab" data-filter="error">
                                    <i class="fa-solid fa-circle-exclamation" style="color: #ef4444;"></i> Cú pháp lỗi
                                    <span class="badge-count">${invalidRowsCount != null ? invalidRowsCount : 0}</span>
                                </button>
                            </div>

                            <!-- Search Input -->
                            <div style="position: relative; min-width: 260px;">
                                <i class="fa-solid fa-magnifying-glass" style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #94a3b8; font-size: 13px;"></i>
                                <input type="text" id="tableSearchInput" placeholder="Tìm kiếm nhanh tên, SĐT, MST..." style="width: 100%; padding: 7px 12px 7px 34px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; transition: border-color 0.2s;">
                            </div>
                        </div>
                    </div>

                    <!-- Table Responsive Scroll Container -->
                    <div class="table-responsive-scroll">
                        <table class="custom-preview-table" id="previewDataTable">
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align: center;">STT</th>
                                    <th>Tên khách hàng</th>
                                    <th>Số điện thoại</th>
                                    <th>Mã số thuế</th>
                                    <th>Ngành nghề</th>
                                    <th>Website</th>
                                    <th style="width: 130px;">Trạng thái</th>
                                    <th>Chi tiết phân tích / Lý do</th>
                                </tr>
                            </thead>
                            <tbody>
                            <c:choose>
                                <c:when test="${not empty allRows}">
                                    <c:forEach var="row" items="${allRows}">
                                        <c:choose>
                                            <c:when test="${row.duplicate}">
                                                <c:set var="rowStatus" value="duplicate"/>
                                            </c:when>
                                            <c:when test="${!row.valid}">
                                                <c:set var="rowStatus" value="error"/>
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="rowStatus" value="valid"/>
                                            </c:otherwise>
                                        </c:choose>
                                        <tr class="data-row row-${rowStatus}" data-status="${rowStatus}">
                                            <td style="text-align: center; font-weight: 600; color: #64748b;">${row.rowIndex}</td>
                                            <td style="font-weight: 700; color: #0f172a;"><c:out value="${row.customerName}"/></td>
                                            <td><c:out value="${not empty row.phone ? row.phone : '---'}"/></td>
                                            <td><c:out value="${not empty row.taxCode ? row.taxCode : '---'}"/></td>
                                            <td><c:out value="${not empty row.industry ? row.industry : '---'}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty row.website}">
                                                        <a href="${row.website}" target="_blank" rel="noopener noreferrer" style="color: #2563eb; text-decoration: none;">
                                                            <c:out value="${row.website}"/> <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 10px;"></i>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>---</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${row.duplicate}">
                                                        <span class="badge-status-pill duplicate"><i class="fa-solid fa-clone"></i> Trùng lặp</span>
                                                    </c:when>
                                                    <c:when test="${!row.valid}">
                                                        <span class="badge-status-pill error"><i class="fa-solid fa-circle-exclamation"></i> Lỗi</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-status-pill valid"><i class="fa-solid fa-circle-check"></i> Hợp lệ</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${row.duplicate}">
                                                        <span style="color: #d97706; font-weight: 500;"><c:out value="${row.duplicateReason}"/></span>
                                                    </c:when>
                                                    <c:when test="${!row.valid}">
                                                        <span style="color: #dc2626; font-weight: 500;"><c:out value="${row.error}"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #16a34a; font-weight: 500;"><i class="fa-solid fa-check"></i> Sẵn sàng nhập mới</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="8" style="text-align: center; padding: 36px 20px; color: #64748b;">
                                            <div style="font-size: 32px; color: #cbd5e1; margin-bottom: 8px;"><i class="fa-regular fa-folder-open"></i></div>
                                            Chưa có dữ liệu preview. Vui lòng tải file Excel từ trang Import.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </main>
</div>

<!-- Loading Overlay during execution -->
<div class="import-loading-overlay" id="execLoadingOverlay">
    <div class="import-spinner"></div>
    <div style="font-size: 16px; font-weight: 600;">Đang thực hiện import vào cơ sở dữ liệu...</div>
    <div style="font-size: 13px; color: #cbd5e1; margin-top: 6px;">Vui lòng không đóng trình duyệt trong khi xử lý</div>
</div>

<script>
function handleConflictOption(radio) {
    document.querySelectorAll('.conflict-option-card').forEach(card => card.classList.remove('selected'));
    if (radio.checked) {
        radio.closest('.conflict-option-card').classList.add('selected');
    }
}

document.addEventListener('DOMContentLoaded', function () {
    const filterTabs = document.querySelectorAll('.filter-tab');
    const rows = document.querySelectorAll('.data-row');
    const searchInput = document.getElementById('tableSearchInput');
    const execForm = document.getElementById('executeImportForm');
    const execOverlay = document.getElementById('execLoadingOverlay');

    let currentFilter = 'all';
    let searchQuery = '';

    function applyFilterAndSearch() {
        rows.forEach(row => {
            const status = row.getAttribute('data-status');
            const rowText = row.textContent.toLowerCase();

            const matchesFilter = (currentFilter === 'all' || status === currentFilter);
            const matchesSearch = (!searchQuery || rowText.includes(searchQuery));

            if (matchesFilter && matchesSearch) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    filterTabs.forEach(tab => {
        tab.addEventListener('click', function () {
            filterTabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            currentFilter = this.getAttribute('data-filter');
            applyFilterAndSearch();
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', function () {
            searchQuery = this.value.trim().toLowerCase();
            applyFilterAndSearch();
        });
    }

    if (execForm) {
        execForm.addEventListener('submit', function () {
            if (execOverlay) {
                execOverlay.style.display = 'flex';
            }
        });
    }
});
</script>
</body>
</html>
