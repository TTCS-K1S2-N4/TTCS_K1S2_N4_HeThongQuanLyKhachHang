<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Khai báo trường tùy chỉnh | Quản trị Hệ thống CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/custom-fields.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="cf-page-container">
            
            <!-- Breadcrumbs -->
            <nav class="exec-breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span>Hệ thống &amp; Quản trị</span>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current">Trường tùy chỉnh (Custom Fields)</span>
            </nav>

            <!-- Toast Messages -->
            <div id="toastMessage" class="toast-banner" style="display: none;">
                <span id="toastText"></span>
                <button type="button" class="btn-modal-close" onclick="hideToast()">&times;</button>
            </div>

            <!-- Executive Hero Header -->
            <div class="exec-hero">
                <div class="hero-title-group">
                    <h1>
                        <i class="fa-solid fa-sliders"></i>
                        Khai báo trường tùy chỉnh (Custom Fields)
                    </h1>
                    <p>
                        Thiết lập các trường dữ liệu động cho Khách hàng và Cơ hội kinh doanh. 
                        Dễ dàng đưa các cột nhân viên đang tự tạo trên Excel vào hệ thống, tự động xuất hiện trong biểu mẫu, bộ lọc và xuất Excel.
                    </p>
                </div>
                <div class="hero-actions">
                    <button type="button" class="btn-exec-secondary" onclick="reloadCurrentEntity()">
                        <i class="fa-solid fa-arrows-rotate"></i> Làm mới
                    </button>
                    <button type="button" class="btn-exec-primary" onclick="openCreateModal()">
                        <i class="fa-solid fa-plus"></i> Tạo trường mới
                    </button>
                </div>
            </div>

            <!-- KPI Statistics Cards -->
            <div class="kpi-grid">
                <div class="kpi-card blue">
                    <div class="kpi-icon-wrap">
                        <i class="fa-solid fa-sliders"></i>
                    </div>
                    <div class="kpi-content">
                        <div class="kpi-label">Tổng số trường</div>
                        <div class="kpi-value" id="kpi-total-fields">${totalFields}</div>
                        <div class="kpi-desc">Đang quản lý trên toàn hệ thống</div>
                    </div>
                </div>

                <div class="kpi-card purple">
                    <div class="kpi-icon-wrap">
                        <i class="fa-solid fa-layer-group"></i>
                    </div>
                    <div class="kpi-content">
                        <div class="kpi-label">Phân bổ đối tượng</div>
                        <div class="kpi-value">
                            <span id="kpi-cust-fields">${customerFieldsCount}</span> KH / <span id="kpi-opp-fields">${opportunityFieldsCount}</span> CH
                        </div>
                        <div class="kpi-desc">Khách hàng vs Cơ hội</div>
                    </div>
                </div>

                <div class="kpi-card rose">
                    <div class="kpi-icon-wrap">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <div class="kpi-content">
                        <div class="kpi-label">Trường bắt buộc</div>
                        <div class="kpi-value" id="kpi-req-fields">${requiredCount}</div>
                        <div class="kpi-desc">Ràng buộc kiểm tra khi lưu hồ sơ</div>
                    </div>
                </div>

                <div class="kpi-card emerald">
                    <div class="kpi-icon-wrap">
                        <i class="fa-solid fa-database"></i>
                    </div>
                    <div class="kpi-content">
                        <div class="kpi-label">Lượt gán dữ liệu</div>
                        <div class="kpi-value" id="kpi-usage-count">${totalUsageCount}</div>
                        <div class="kpi-desc">Bản ghi giá trị đã lưu thực tế</div>
                    </div>
                </div>
            </div>

            <!-- Entity Segmented Tabs & Filters -->
            <div class="entity-nav-bar">
                <div class="entity-tabs" role="tablist">
                    <button type="button" class="entity-tab-btn active" id="tab-customer" onclick="switchEntity('CUSTOMER')">
                        <i class="fa-solid fa-building-user"></i>
                        <span>Khách hàng (Customer)</span>
                        <span class="tab-count-badge" id="badge-cust-count">${customerFieldsCount}</span>
                    </button>
                    <button type="button" class="entity-tab-btn" id="tab-opportunity" onclick="switchEntity('OPPORTUNITY')">
                        <i class="fa-solid fa-chart-line"></i>
                        <span>Cơ hội (Opportunity)</span>
                        <span class="tab-count-badge" id="badge-opp-count">${opportunityFieldsCount}</span>
                    </button>
                </div>
            </div>

            <!-- Search and Filter Bar -->
            <div class="filter-card">
                <div class="filter-search-wrap">
                    <i class="fa-solid fa-magnifying-glass filter-search-icon"></i>
                    <input type="text" id="filterSearch" class="filter-search-input" 
                           placeholder="Tìm theo tên hiển thị hoặc mã trường (key)..." 
                           oninput="filterFields()">
                </div>

                <select id="filterType" class="filter-select" onchange="filterFields()">
                    <option value="">Tất cả loại dữ liệu</option>
                    <option value="TEXT">Văn bản (TEXT)</option>
                    <option value="NUMBER">Số (NUMBER)</option>
                    <option value="DATE">Ngày tháng (DATE)</option>
                    <option value="SELECT">Danh sách chọn (SELECT)</option>
                </select>

                <select id="filterRequired" class="filter-select" onchange="filterFields()">
                    <option value="">Tất cả ràng buộc</option>
                    <option value="true">Bắt buộc nhập</option>
                    <option value="false">Tùy chọn nhập</option>
                </select>

                <select id="filterStatus" class="filter-select" onchange="filterFields()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="ACTIVE">Đang kích hoạt (ACTIVE)</option>
                    <option value="INACTIVE">Ngừng áp dụng (INACTIVE)</option>
                </select>

                <button type="button" class="btn-reset-filters" onclick="resetFilters()">
                    <i class="fa-solid fa-arrow-rotate-left"></i> Đặt lại
                </button>
            </div>

            <!-- Data Table Card -->
            <div class="table-card">
                <div class="table-card-header">
                    <h2 class="table-card-title" id="tableHeaderTitle">
                        <i class="fa-solid fa-table-list" style="color: var(--crm-accent-blue);"></i>
                        Danh sách trường tùy chỉnh - Khách hàng
                    </h2>
                    <span class="table-card-count" id="tableResultCount">Đang tải...</span>
                </div>

                <div class="table-responsive">
                    <table class="cf-table" id="fieldsTable">
                        <thead>
                            <tr>
                                <th style="width: 70px; text-align: center;">Thứ tự</th>
                                <th style="width: 170px;">Mã trường (Key)</th>
                                <th>Tên hiển thị (Label)</th>
                                <th style="width: 150px;">Loại dữ liệu</th>
                                <th style="width: 130px;">Ràng buộc</th>
                                <th>Tùy chọn danh sách / Mặc định</th>
                                <th style="width: 130px; text-align: center;">Sử dụng</th>
                                <th style="width: 130px; text-align: center;">Trạng thái</th>
                                <th style="width: 110px; text-align: right;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="fieldsTbody">
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 40px; color: #94a3b8;">
                                    <i class="fa-solid fa-spinner fa-spin" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
                                    Đang tải dữ liệu cấu hình trường tùy chỉnh...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>
</div>

<!-- ========================================================================= -->
<!-- MODAL: TẠO TRƯỜNG TÙY CHỈNH MỚI -->
<!-- ========================================================================= -->
<div id="createModal" class="exec-modal-backdrop" onclick="handleBackdropClick(event, 'createModal')">
    <div class="exec-modal-container">
        <div class="exec-modal-header">
            <h3 class="exec-modal-title">
                <i class="fa-solid fa-square-plus" style="color: var(--crm-accent-blue);"></i>
                Tạo trường tùy chỉnh mới
            </h3>
            <button type="button" class="btn-modal-close" onclick="closeModal('createModal')">&times;</button>
        </div>
        <form id="createFieldForm" onsubmit="handleCreateSubmit(event)">
            <div class="exec-modal-body">
                
                <div class="modal-form-group">
                    <label class="modal-form-label" for="createEntityType">
                        Áp dụng cho đối tượng <span class="req">*</span>
                    </label>
                    <select id="createEntityType" class="modal-form-control" required>
                        <option value="CUSTOMER">Khách hàng (Customer)</option>
                        <option value="OPPORTUNITY">Cơ hội kinh doanh (Opportunity)</option>
                    </select>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="createFieldLabel">
                        Tên nhãn hiển thị (Label) <span class="req">*</span>
                    </label>
                    <input type="text" id="createFieldLabel" class="modal-form-control" 
                           placeholder="Ví dụ: Phân nhóm khách hàng, Ngày gia hạn..." 
                           required maxlength="100" oninput="autoGenerateKey(this.value)">
                    <div class="modal-form-hint">Tên xuất hiện trên biểu mẫu tạo/sửa, bộ lọc và tiêu đề cột Excel.</div>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="createFieldKey">
                        Mã trường kỹ thuật (Field Key) <span class="req">*</span>
                    </label>
                    <input type="text" id="createFieldKey" class="modal-form-control" 
                           placeholder="vd: phan_nhom_kh, ngay_gia_han" 
                           required maxlength="50" pattern="[a-zA-Z0-9_]+" 
                           title="Chỉ chứa chữ cái tiếng Anh, chữ số và dấu gạch dưới">
                    <div class="modal-form-hint">Mã định danh duy nhất (chữ thường, không dấu, ngăn cách bằng dấu _).</div>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="createFieldType">
                        Loại kiểu dữ liệu <span class="req">*</span>
                    </label>
                    <select id="createFieldType" class="modal-form-control" required onchange="handleTypeChange('create')">
                        <option value="TEXT">Văn bản ngắn (TEXT)</option>
                        <option value="NUMBER">Số học (NUMBER)</option>
                        <option value="DATE">Ngày tháng (DATE - YYYY-MM-DD)</option>
                        <option value="SELECT">Danh sách lựa chọn (SELECT)</option>
                    </select>
                </div>

                <div class="modal-form-group" id="createOptionsGroup" style="display: none;">
                    <label class="modal-form-label" for="createOptions">
                        Các tùy chọn danh sách (Options) <span class="req">*</span>
                    </label>
                    <textarea id="createOptions" class="modal-form-control" style="height: 80px; padding: 10px;" 
                              placeholder="Nhập các lựa chọn, phân cách bằng dấu phẩy (vd: Hạng A, Hạng B, Hạng C)"></textarea>
                    <div class="modal-form-hint">Phân cách các giá trị bằng dấu phẩy <code>,</code> hoặc xuống dòng.</div>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="createDefaultValue">
                        Giá trị mặc định (Default Value)
                    </label>
                    <input type="text" id="createDefaultValue" class="modal-form-control" 
                           placeholder="Tùy chọn giá trị ban đầu nếu có...">
                </div>

                <div class="modal-form-group">
                    <label class="checkbox-toggle-wrap">
                        <input type="checkbox" id="createIsRequired" value="true">
                        <span class="checkbox-toggle-text">
                            <i class="fa-solid fa-asterisk" style="color: #e11d48; margin-right: 4px; font-size: 11px;"></i>
                            Đặt trường này là BẮT BUỘC NHẬP (Required)
                        </span>
                    </label>
                    <div class="modal-form-hint" style="margin-left: 4px;">Người dùng bắt buộc phải điền trường này trước khi lưu hồ sơ.</div>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="createDisplayOrder">
                        Thứ tự hiển thị (Display Order)
                    </label>
                    <input type="number" id="createDisplayOrder" class="modal-form-control" value="0" min="0" max="999">
                </div>

            </div>
            <div class="exec-modal-footer">
                <button type="button" class="btn-reset-filters" onclick="closeModal('createModal')">Hủy bỏ</button>
                <button type="submit" class="btn-exec-primary">
                    <i class="fa-solid fa-check"></i> Lưu trường
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: CHỈNH SỬA TRƯỜNG TÙY CHỈNH -->
<!-- ========================================================================= -->
<div id="editModal" class="exec-modal-backdrop" onclick="handleBackdropClick(event, 'editModal')">
    <div class="exec-modal-container">
        <div class="exec-modal-header">
            <h3 class="exec-modal-title">
                <i class="fa-solid fa-pen-to-square" style="color: var(--crm-accent-blue);"></i>
                Chỉnh sửa trường tùy chỉnh
            </h3>
            <button type="button" class="btn-modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form id="editFieldForm" onsubmit="handleEditSubmit(event)">
            <input type="hidden" id="editFieldId">
            <input type="hidden" id="editEntityType">
            
            <div class="exec-modal-body">
                
                <div class="modal-form-group">
                    <label class="modal-form-label">Mã trường kỹ thuật (Field Key)</label>
                    <div id="editFieldKeyDisplay" style="padding: 10px 14px; background: #f1f5f9; border-radius: var(--crm-radius-sm); font-family: monospace; font-weight: 700; color: #0f172a; border: 1px solid #e2e8f0;"></div>
                    <div class="modal-form-hint">Mã trường là khóa cố định không thể thay đổi sau khi tạo để đảm bảo toàn vẹn dữ liệu.</div>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editFieldLabel">
                        Tên nhãn hiển thị (Label) <span class="req">*</span>
                    </label>
                    <input type="text" id="editFieldLabel" class="modal-form-control" required maxlength="100">
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editFieldType">
                        Loại kiểu dữ liệu <span class="req">*</span>
                    </label>
                    <select id="editFieldType" class="modal-form-control" required onchange="handleTypeChange('edit')">
                        <option value="TEXT">Văn bản ngắn (TEXT)</option>
                        <option value="NUMBER">Số học (NUMBER)</option>
                        <option value="DATE">Ngày tháng (DATE - YYYY-MM-DD)</option>
                        <option value="SELECT">Danh sách lựa chọn (SELECT)</option>
                    </select>
                </div>

                <div class="modal-form-group" id="editOptionsGroup" style="display: none;">
                    <label class="modal-form-label" for="editOptions">
                        Các tùy chọn danh sách (Options) <span class="req">*</span>
                    </label>
                    <textarea id="editOptions" class="modal-form-control" style="height: 80px; padding: 10px;"></textarea>
                    <div class="modal-form-hint">Phân cách các giá trị bằng dấu phẩy <code>,</code></div>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editDefaultValue">
                        Giá trị mặc định (Default Value)
                    </label>
                    <input type="text" id="editDefaultValue" class="modal-form-control">
                </div>

                <div class="modal-form-group">
                    <label class="checkbox-toggle-wrap">
                        <input type="checkbox" id="editIsRequired" value="true">
                        <span class="checkbox-toggle-text">
                            <i class="fa-solid fa-asterisk" style="color: #e11d48; margin-right: 4px; font-size: 11px;"></i>
                            Đặt trường này là BẮT BUỘC NHẬP (Required)
                        </span>
                    </label>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editDisplayOrder">
                        Thứ tự hiển thị (Display Order)
                    </label>
                    <input type="number" id="editDisplayOrder" class="modal-form-control" min="0" max="999">
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editStatus">
                        Trạng thái áp dụng <span class="req">*</span>
                    </label>
                    <select id="editStatus" class="modal-form-control">
                        <option value="ACTIVE">Kích hoạt (ACTIVE)</option>
                        <option value="INACTIVE">Ngừng áp dụng (INACTIVE)</option>
                    </select>
                </div>

            </div>
            <div class="exec-modal-footer">
                <button type="button" class="btn-reset-filters" onclick="closeModal('editModal')">Hủy bỏ</button>
                <button type="submit" class="btn-exec-primary">
                    <i class="fa-solid fa-check"></i> Cập nhật thay đổi
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: XÁC NHẬN XÓA TRƯỜNG TÙY CHỈNH -->
<!-- ========================================================================= -->
<div id="deleteModal" class="exec-modal-backdrop" onclick="handleBackdropClick(event, 'deleteModal')">
    <div class="exec-modal-container" style="max-width: 480px;">
        <div class="exec-modal-header" style="background: #fff1f2; border-bottom: 1px solid #fecdd3;">
            <h3 class="exec-modal-title" style="color: #991b1b;">
                <i class="fa-solid fa-triangle-exclamation"></i>
                Xác nhận xóa trường tùy chỉnh
            </h3>
            <button type="button" class="btn-modal-close" onclick="closeModal('deleteModal')">&times;</button>
        </div>
        <div class="exec-modal-body">
            <p style="margin-top: 0; font-size: 14.5px; color: var(--crm-text-heading); line-height: 1.5;">
                Bạn có chắc chắn muốn xóa trường tùy chỉnh <strong id="deleteFieldLabelDisplay" style="color: #e11d48;"></strong>?
            </p>
            <div id="deleteUsageWarning" style="display: none; padding: 14px; background: #fff1f2; border: 1px solid #fecdd3; border-radius: var(--crm-radius-sm); font-size: 13px; color: #991b1b; line-height: 1.45; margin-bottom: 12px;">
                <i class="fa-solid fa-circle-exclamation" style="margin-right: 6px;"></i>
                <strong>Cảnh báo dữ liệu:</strong> Trường này đang có <span id="deleteUsageCountText" style="font-weight: 700;"></span> bản ghi giá trị liên kết. Khi xóa, toàn bộ dữ liệu này sẽ bị xóa khỏi cơ sở dữ liệu và không thể hoàn tác!
            </div>
            <p style="font-size: 13px; color: var(--crm-text-muted); margin-bottom: 0;">
                Mẹo: Nếu chỉ muốn tạm thời ẩn trường này khỏi biểu mẫu nhập mới, bạn có thể chuyển trạng thái sang <strong>Ngừng áp dụng (INACTIVE)</strong> thay vì xóa.
            </p>
        </div>
        <div class="exec-modal-footer">
            <input type="hidden" id="deleteFieldId">
            <button type="button" class="btn-reset-filters" onclick="closeModal('deleteModal')">Hủy</button>
            <button type="button" class="btn-exec-primary" style="background: #dc2626;" onclick="confirmDeleteField()">
                <i class="fa-solid fa-trash"></i> Xác nhận xóa vĩnh viễn
            </button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- JAVASCRIPT LOGIC & REACTIVE INTERACTION -->
<!-- ========================================================================= -->
<script>
    const CONTEXT_PATH = '${pageContext.request.contextPath}';
    let currentEntity = 'CUSTOMER';
    let allFields = [];

    document.addEventListener("DOMContentLoaded", function() {
        loadFields(currentEntity);
    });

    function switchEntity(entity) {
        currentEntity = entity;
        document.getElementById('tab-customer').classList.toggle('active', entity === 'CUSTOMER');
        document.getElementById('tab-opportunity').classList.toggle('active', entity === 'OPPORTUNITY');
        document.getElementById('tableHeaderTitle').innerHTML = `
            <i class="fa-solid fa-table-list" style="color: var(--crm-accent-blue);"></i>
            Danh sách trường tùy chỉnh - \${entity === 'CUSTOMER' ? 'Khách hàng' : 'Cơ hội kinh doanh'}
        `;
        resetFilters();
        loadFields(entity);
    }

    function reloadCurrentEntity() {
        loadFields(currentEntity);
        showToast("Đã làm mới dữ liệu trường tùy chỉnh", "success");
    }

    function loadFields(entity) {
        const tbody = document.getElementById('fieldsTbody');
        tbody.innerHTML = `
            <tr>
                <td colspan="9" style="text-align: center; padding: 40px; color: #94a3b8;">
                    <i class="fa-solid fa-spinner fa-spin" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
                    Đang tải danh sách trường tùy chỉnh...
                </td>
            </tr>
        `;

        fetch(`\${CONTEXT_PATH}/api/custom-fields?entityType=\${entity}`)
            .then(res => res.json())
            .then(data => {
                allFields = Array.isArray(data) ? data : [];
                updateCounts();
                renderTable(allFields);
            })
            .catch(err => {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="9" style="text-align: center; padding: 40px; color: #dc2626;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
                            Lỗi kết nối máy chủ khi tải dữ liệu trường tùy chỉnh.
                        </td>
                    </tr>
                `;
            });
    }

    function updateCounts() {
        if (currentEntity === 'CUSTOMER') {
            document.getElementById('badge-cust-count').textContent = allFields.length;
        } else {
            document.getElementById('badge-opp-count').textContent = allFields.length;
        }
    }

    function filterFields() {
        const keyword = (document.getElementById('filterSearch').value || '').trim().toLowerCase();
        const typeFilter = document.getElementById('filterType').value;
        const reqFilter = document.getElementById('filterRequired').value;
        const statusFilter = document.getElementById('filterStatus').value;

        const filtered = allFields.filter(f => {
            if (keyword) {
                const labelMatch = (f.fieldLabel || '').toLowerCase().includes(keyword);
                const keyMatch = (f.fieldKey || '').toLowerCase().includes(keyword);
                if (!labelMatch && !keyMatch) return false;
            }
            if (typeFilter && f.fieldType !== typeFilter) return false;
            if (reqFilter !== '') {
                const isReq = (reqFilter === 'true');
                if (Boolean(f.isRequired) !== isReq) return false;
            }
            if (statusFilter && f.status !== statusFilter) return false;
            return true;
        });

        renderTable(filtered);
    }

    function resetFilters() {
        document.getElementById('filterSearch').value = '';
        document.getElementById('filterType').value = '';
        document.getElementById('filterRequired').value = '';
        document.getElementById('filterStatus').value = '';
        renderTable(allFields);
    }

    function renderTable(list) {
        const tbody = document.getElementById('fieldsTbody');
        const countDisplay = document.getElementById('tableResultCount');
        countDisplay.textContent = `Hiển thị \${list.length} / \${allFields.length} trường`;

        if (!list || list.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9">
                        <div class="empty-state">
                            <div class="empty-state-icon"><i class="fa-solid fa-inbox"></i></div>
                            <div class="empty-state-title">Chưa có trường tùy chỉnh nào</div>
                            <div class="empty-state-desc">
                                Bạn chưa tạo trường tùy chỉnh nào phù hợp với bộ lọc hiện tại cho \${currentEntity === 'CUSTOMER' ? 'Khách hàng' : 'Cơ hội'}.
                            </div>
                            <button type="button" class="btn-exec-primary" onclick="openCreateModal()">
                                <i class="fa-solid fa-plus"></i> Khai báo trường ngay
                            </button>
                        </div>
                    </td>
                </tr>
            `;
            return;
        }

        let html = '';
        list.forEach(item => {
            // Type badge
            let typeBadge = '';
            const t = (item.fieldType || 'TEXT').toUpperCase();
            if (t === 'NUMBER') {
                typeBadge = `<span class="type-badge number"><i class="fa-solid fa-hashtag"></i> Số học</span>`;
            } else if (t === 'DATE') {
                typeBadge = `<span class="type-badge date"><i class="fa-solid fa-calendar-day"></i> Ngày tháng</span>`;
            } else if (t === 'SELECT') {
                typeBadge = `<span class="type-badge select"><i class="fa-solid fa-list-check"></i> Danh sách</span>`;
            } else {
                typeBadge = `<span class="type-badge text"><i class="fa-solid fa-align-left"></i> Văn bản</span>`;
            }

            // Req badge
            const reqBadge = item.isRequired
                ? `<span class="req-pill required"><i class="fa-solid fa-asterisk"></i> Bắt buộc</span>`
                : `<span class="req-pill optional">Tùy chọn</span>`;

            // Options or default
            let optionsHtml = '-';
            if (t === 'SELECT' && item.options) {
                const parts = item.options.split(/[,;\n]+/).filter(Boolean);
                optionsHtml = '<div class="options-wrap">' + parts.map(p => `<span class="option-chip">\${escapeHtml(p.trim())}</span>`).join('') + '</div>';
            } else if (item.defaultValue) {
                optionsHtml = `<span style="color: #64748b; font-size: 12.5px;">Mặc định: <strong>\${escapeHtml(item.defaultValue)}</strong></span>`;
            }

            // Usage count
            const usage = item.usageCount || 0;
            const usageHtml = `
                <span class="usage-badge \${usage > 0 ? 'has-data' : ''}" title="\${usage} bản ghi thực tế đang lưu giá trị của trường này">
                    <i class="fa-solid \${usage > 0 ? 'fa-database' : 'fa-circle-minus'}"></i> \${usage}
                </span>
            `;

            // Status pill
            const isActive = item.status === 'ACTIVE';
            const statusHtml = `
                <span class="status-pill \${isActive ? 'active' : 'inactive'}" 
                      onclick="toggleStatus(\${item.fieldId}, '\${item.status}')" 
                      title="Nhấp để đổi trạng thái">
                    <span class="status-dot"></span>
                    \${isActive ? 'Hoạt động' : 'Đã khóa'}
                </span>
            `;

            // Serialized item for edit modal
            const safeItemJson = encodeURIComponent(JSON.stringify(item));

            html += `
                <tr>
                    <td style="text-align: center; font-weight: 700; color: #64748b;">\${item.displayOrder || 0}</td>
                    <td><span class="key-code">\${escapeHtml(item.fieldKey)}</span></td>
                    <td>
                        <span class="label-primary-text">\${escapeHtml(item.fieldLabel)}</span>
                        <span class="label-sub-text">ID: #\${item.fieldId}</span>
                    </td>
                    <td>\${typeBadge}</td>
                    <td>\${reqBadge}</td>
                    <td>\${optionsHtml}</td>
                    <td style="text-align: center;">\${usageHtml}</td>
                    <td style="text-align: center;">\${statusHtml}</td>
                    <td>
                        <div class="action-buttons">
                            <button type="button" class="btn-icon-action edit" title="Chỉnh sửa trường" onclick="openEditModal('\${safeItemJson}')">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <button type="button" class="btn-icon-action delete" title="Xóa trường" onclick="openDeleteModal(\${item.fieldId}, '\${escapeHtml(item.fieldLabel)}', \${usage})">
                                <i class="fa-solid fa-trash-can"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html;
    }

    // Dynamic field key slug generator
    function autoGenerateKey(label) {
        if (!label) return;
        const keyInput = document.getElementById('createFieldKey');
        // Only auto-generate if user hasn't explicitly customized key
        if (!keyInput.dataset.manual) {
            let slug = label.toLowerCase()
                .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
                .replace(/đ/g, 'd').replace(/Đ/g, 'd')
                .replace(/[^a-z0-9]+/g, '_')
                .replace(/^_+|_+$/g, '');
            keyInput.value = slug;
        }
    }

    document.getElementById('createFieldKey').addEventListener('input', function() {
        this.dataset.manual = "true";
    });

    function handleTypeChange(prefix) {
        const typeSelect = document.getElementById(prefix + 'FieldType');
        const optionsGroup = document.getElementById(prefix + 'OptionsGroup');
        optionsGroup.style.display = (typeSelect.value === 'SELECT') ? 'block' : 'none';
    }

    // Modal control
    function openCreateModal() {
        document.getElementById('createEntityType').value = currentEntity;
        document.getElementById('createFieldLabel').value = '';
        const keyInput = document.getElementById('createFieldKey');
        keyInput.value = '';
        delete keyInput.dataset.manual;
        document.getElementById('createFieldType').value = 'TEXT';
        document.getElementById('createOptions').value = '';
        document.getElementById('createDefaultValue').value = '';
        document.getElementById('createIsRequired').checked = false;
        document.getElementById('createDisplayOrder').value = (allFields.length + 1);
        handleTypeChange('create');
        document.getElementById('createModal').classList.add('active');
        document.getElementById('createFieldLabel').focus();
    }

    function openEditModal(encodedItem) {
        const item = JSON.parse(decodeURIComponent(encodedItem));
        document.getElementById('editFieldId').value = item.fieldId;
        document.getElementById('editEntityType').value = item.entityType;
        document.getElementById('editFieldKeyDisplay').textContent = item.fieldKey;
        document.getElementById('editFieldLabel').value = item.fieldLabel || '';
        document.getElementById('editFieldType').value = item.fieldType || 'TEXT';
        document.getElementById('editOptions').value = item.options || '';
        document.getElementById('editDefaultValue').value = item.defaultValue || '';
        document.getElementById('editIsRequired').checked = Boolean(item.isRequired);
        document.getElementById('editDisplayOrder').value = item.displayOrder || 0;
        document.getElementById('editStatus').value = item.status || 'ACTIVE';
        handleTypeChange('edit');
        document.getElementById('editModal').classList.add('active');
    }

    function openDeleteModal(fieldId, fieldLabel, usageCount) {
        document.getElementById('deleteFieldId').value = fieldId;
        document.getElementById('deleteFieldLabelDisplay').textContent = fieldLabel;
        const usageWarning = document.getElementById('deleteUsageWarning');
        if (usageCount > 0) {
            document.getElementById('deleteUsageCountText').textContent = usageCount;
            usageWarning.style.display = 'block';
        } else {
            usageWarning.style.display = 'none';
        }
        document.getElementById('deleteModal').classList.add('active');
    }

    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove('active');
    }

    function handleBackdropClick(event, modalId) {
        if (event.target === document.getElementById(modalId)) {
            closeModal(modalId);
        }
    }

    // Submit Create
    function handleCreateSubmit(e) {
        e.preventDefault();
        const entityType = document.getElementById('createEntityType').value;
        const fieldKey = document.getElementById('createFieldKey').value.trim();
        const fieldLabel = document.getElementById('createFieldLabel').value.trim();
        const fieldType = document.getElementById('createFieldType').value;
        const options = document.getElementById('createOptions').value.trim();
        const defaultValue = document.getElementById('createDefaultValue').value.trim();
        const isRequired = document.getElementById('createIsRequired').checked;
        const displayOrder = document.getElementById('createDisplayOrder').value;

        if (fieldType === 'SELECT' && !options) {
            alert('Vui lòng nhập các tùy chọn cho kiểu danh sách lựa chọn (SELECT)!');
            return;
        }

        const params = new URLSearchParams();
        params.append('action', 'CREATE');
        params.append('entityType', entityType);
        params.append('fieldKey', fieldKey);
        params.append('fieldLabel', fieldLabel);
        params.append('fieldType', fieldType);
        params.append('options', options);
        params.append('defaultValue', defaultValue);
        params.append('isRequired', isRequired ? 'true' : 'false');
        params.append('displayOrder', displayOrder);
        params.append('status', 'ACTIVE');

        fetch(`\${CONTEXT_PATH}/custom-fields`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Lỗi: ' + data.error);
            } else {
                closeModal('createModal');
                showToast(`Đã thêm trường [ \${fieldLabel} ] thành công!`, 'success');
                loadFields(currentEntity);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ khi tạo trường.'));
    }

    // Submit Edit
    function handleEditSubmit(e) {
        e.preventDefault();
        const fieldId = document.getElementById('editFieldId').value;
        const fieldLabel = document.getElementById('editFieldLabel').value.trim();
        const fieldType = document.getElementById('editFieldType').value;
        const options = document.getElementById('editOptions').value.trim();
        const defaultValue = document.getElementById('editDefaultValue').value.trim();
        const isRequired = document.getElementById('editIsRequired').checked;
        const displayOrder = document.getElementById('editDisplayOrder').value;
        const status = document.getElementById('editStatus').value;

        if (fieldType === 'SELECT' && !options) {
            alert('Vui lòng nhập các tùy chọn cho kiểu danh sách lựa chọn (SELECT)!');
            return;
        }

        const params = new URLSearchParams();
        params.append('action', 'UPDATE');
        params.append('fieldId', fieldId);
        params.append('fieldLabel', fieldLabel);
        params.append('fieldType', fieldType);
        params.append('options', options);
        params.append('defaultValue', defaultValue);
        params.append('isRequired', isRequired ? 'true' : 'false');
        params.append('displayOrder', displayOrder);
        params.append('status', status);

        fetch(`\${CONTEXT_PATH}/custom-fields`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Lỗi: ' + data.error);
            } else {
                closeModal('editModal');
                showToast('Cập nhật trường tùy chỉnh thành công!', 'success');
                loadFields(currentEntity);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ khi cập nhật trường.'));
    }

    // Toggle Status
    function toggleStatus(fieldId, curStatus) {
        const newStatus = (curStatus === 'ACTIVE') ? 'INACTIVE' : 'ACTIVE';
        const params = new URLSearchParams();
        params.append('action', 'STATUS');
        params.append('fieldId', fieldId);
        params.append('status', newStatus);

        fetch(`\${CONTEXT_PATH}/custom-fields`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Lỗi: ' + data.error);
            } else {
                showToast(`Đã chuyển trạng thái sang \${newStatus === 'ACTIVE' ? 'Hoạt động' : 'Đã khóa'}`, 'success');
                loadFields(currentEntity);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ khi đổi trạng thái.'));
    }

    // Confirm Delete
    function confirmDeleteField() {
        const fieldId = document.getElementById('deleteFieldId').value;
        const params = new URLSearchParams();
        params.append('action', 'DELETE');
        params.append('fieldId', fieldId);

        fetch(`\${CONTEXT_PATH}/custom-fields`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Lỗi: ' + data.error);
            } else {
                closeModal('deleteModal');
                showToast('Đã xóa trường tùy chỉnh thành công!', 'success');
                loadFields(currentEntity);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ khi xóa trường.'));
    }

    // Toast banner
    function showToast(text, type) {
        const toast = document.getElementById('toastMessage');
        const toastText = document.getElementById('toastText');
        toast.className = `toast-banner toast-\${type}`;
        toastText.innerHTML = `<i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> \${escapeHtml(text)}`;
        toast.style.display = 'flex';
        setTimeout(hideToast, 4000);
    }

    function hideToast() {
        const toast = document.getElementById('toastMessage');
        if (toast) toast.style.display = 'none';
    }

    function escapeHtml(text) {
        if (!text) return '';
        return text.toString()
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
</script>

</body>
</html>
