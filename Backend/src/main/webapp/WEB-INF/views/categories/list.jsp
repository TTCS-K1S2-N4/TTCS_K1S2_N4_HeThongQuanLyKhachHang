<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh mục Dùng chung Bán hàng | Giám đốc Kinh doanh CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/categories.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="category-page-container">
            
            <!-- Breadcrumbs -->
            <div class="exec-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fa fa-home"></i> Trang chủ</a>
                <span class="sep"><i class="fa fa-chevron-right"></i></span>
                <span>Quản trị bán hàng</span>
                <span class="sep"><i class="fa fa-chevron-right"></i></span>
                <span style="color: var(--crm-text-heading); font-weight: 600;">Danh mục dùng chung</span>
            </div>

            <!-- Toast Messages -->
            <c:if test="${param.success eq 'true'}">
                <div class="toast-banner toast-success">
                    <div><i class="fa fa-circle-check" style="margin-right: 8px;"></i> Thao tác cập nhật danh mục thành công!</div>
                    <button type="button" class="modal-close" onclick="this.parentElement.style.display='none'">&times;</button>
                </div>
            </c:if>
            <c:if test="${not empty errors}">
                <div class="toast-banner toast-error">
                    <div>
                        <i class="fa fa-triangle-exclamation" style="margin-right: 8px;"></i>
                        <c:forEach var="err" items="${errors}">
                            <span>${err}</span><br/>
                        </c:forEach>
                    </div>
                    <button type="button" class="modal-close" onclick="this.parentElement.style.display='none'">&times;</button>
                </div>
            </c:if>

            <!-- Hero Header -->
            <div class="exec-hero">
                <div class="hero-title-group">
                    <h1>
                        <i class="fa fa-sitemap"></i> Danh mục Dùng chung Bán hàng
                    </h1>
                    <p>
                        Khai báo chuẩn hóa danh mục nguồn lead, ngành nghề, quy mô và hoạt động cho toàn khối kinh doanh. Đảm bảo dữ liệu đồng nhất phục vụ báo cáo gộp và bảo vệ toàn vẹn lịch sử giao dịch.
                    </p>
                </div>
                <div class="hero-actions">
                    <a href="${pageContext.request.contextPath}/categories" class="btn-exec-secondary">
                        <i class="fa fa-rotate"></i> Tải lại
                    </a>
                    <button type="button" class="btn-exec-primary" onclick="openCreateModal()">
                        <i class="fa fa-plus-circle"></i> + Khai báo danh mục mới
                    </button>
                </div>
            </div>

            <!-- Backlog Policy Assurance Callout -->
            <div class="policy-callout">
                <div class="policy-icon">
                    <i class="fa fa-briefcase"></i>
                </div>
                <div class="policy-content">
                    <h4>Chính sách Quản trị Danh mục Khối Kinh doanh (Giám đốc Bán hàng)</h4>
                    <p>
                        Mọi thành viên khối kinh doanh bắt buộc sử dụng chung bộ từ điển danh mục để phân loại dữ liệu. Hệ thống tự động kích hoạt <strong>cơ chế bảo vệ tham chiếu</strong>: những danh mục đã phát sinh dữ liệu trong Khách hàng, Cơ hội, Báo giá hoặc Hoạt động sẽ <strong>không thể xóa</strong> nhằm đảm bảo tính toàn vẹn số liệu báo cáo gộp. Hãy sắp xếp <strong>thứ tự hiển thị (sort_order)</strong> để tối ưu thao tác nhập liệu của nhân viên.
                    </p>
                    <div class="policy-badges">
                        <span class="policy-pill"><i class="fa fa-tag"></i> 4 Trục danh mục cốt lõi</span>
                        <span class="policy-pill shield"><i class="fa fa-shield-halved"></i> Khóa xóa giá trị đang tham chiếu</span>
                        <span class="policy-pill sort"><i class="fa fa-arrow-down-1-9"></i> Tùy biến thứ tự hiển thị</span>
                    </div>
                </div>
            </div>

            <!-- 4 Metric KPI Cards -->
            <div class="metrics-grid">
                <!-- KPI 1 -->
                <div class="metric-card">
                    <div class="metric-icon-box metric-icon-blue">
                        <i class="fa fa-folder-tree"></i>
                    </div>
                    <div class="metric-meta">
                        <span class="metric-label">Tổng danh mục</span>
                        <span class="metric-value" id="kpiTotalCategories">--</span>
                        <span class="metric-desc">Đã khai báo toàn hệ thống</span>
                    </div>
                </div>

                <!-- KPI 2 -->
                <div class="metric-card">
                    <div class="metric-icon-box metric-icon-indigo">
                        <i class="fa fa-layer-group"></i>
                    </div>
                    <div class="metric-meta">
                        <span class="metric-label">4 Phân hệ cốt lõi</span>
                        <span class="metric-value">4 / 4</span>
                        <span class="metric-desc">Ngành, Quy mô, Lead, Hoạt động</span>
                    </div>
                </div>

                <!-- KPI 3 -->
                <div class="metric-card">
                    <div class="metric-icon-box metric-icon-amber">
                        <i class="fa fa-lock"></i>
                    </div>
                    <div class="metric-meta">
                        <span class="metric-label">Đang có tham chiếu</span>
                        <span class="metric-value" id="kpiReferencedCount">--</span>
                        <span class="metric-desc">Bảo toàn vẹn - Không thể xóa</span>
                    </div>
                </div>

                <!-- KPI 4 -->
                <div class="metric-card">
                    <div class="metric-icon-box metric-icon-emerald">
                        <i class="fa fa-circle-check"></i>
                    </div>
                    <div class="metric-meta">
                        <span class="metric-label">Đang áp dụng (ACTIVE)</span>
                        <span class="metric-value" id="kpiActiveCount">--</span>
                        <span class="metric-desc">Sẵn sàng chọn trên biểu mẫu</span>
                    </div>
                </div>
            </div>

            <!-- Filter & Tabs Section -->
            <div class="filter-section">
                <!-- Navigation Tabs -->
                <div class="tab-nav">
                    <button type="button" class="tab-btn ${empty categoryType ? 'active' : ''}" onclick="switchTab('')">
                        <i class="fa fa-list-check"></i> Tất cả danh mục
                        <span class="tab-count" id="countAll">0</span>
                    </button>
                    <button type="button" class="tab-btn ${categoryType eq 'INDUSTRY' ? 'active' : ''}" onclick="switchTab('INDUSTRY')">
                        <i class="fa fa-building"></i> Ngành nghề khách hàng
                        <span class="tab-count" id="countIndustry">0</span>
                    </button>
                    <button type="button" class="tab-btn ${categoryType eq 'COMPANY_SIZE' ? 'active' : ''}" onclick="switchTab('COMPANY_SIZE')">
                        <i class="fa fa-users"></i> Quy mô doanh nghiệp
                        <span class="tab-count" id="countSize">0</span>
                    </button>
                    <button type="button" class="tab-btn ${categoryType eq 'LEAD_SOURCE' or categoryType eq 'SOURCE' ? 'active' : ''}" onclick="switchTab('LEAD_SOURCE')">
                        <i class="fa fa-bullseye"></i> Nguồn Lead
                        <span class="tab-count" id="countSource">0</span>
                    </button>
                    <button type="button" class="tab-btn ${categoryType eq 'ACTIVITY_TYPE' ? 'active' : ''}" onclick="switchTab('ACTIVITY_TYPE')">
                        <i class="fa fa-bolt"></i> Loại hoạt động
                        <span class="tab-count" id="countActivity">0</span>
                    </button>
                </div>

                <!-- Search & Status Control -->
                <div class="filter-controls">
                    <div class="search-box">
                        <i class="fa fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Tìm nhanh theo tên danh mục, mã loại..." oninput="filterTableRows()">
                    </div>
                    <div class="filter-right">
                        <select id="statusFilter" class="select-filter" onchange="filterTableRows()">
                            <option value="">Tất cả trạng thái</option>
                            <option value="ACTIVE">Chỉ xem: Đang áp dụng (ACTIVE)</option>
                            <option value="INACTIVE">Chỉ xem: Tạm ngưng (INACTIVE)</option>
                        </select>
                        <select id="refFilter" class="select-filter" onchange="filterTableRows()">
                            <option value="">Tất cả tham chiếu</option>
                            <option value="LOCKED">Đang dùng (Có tham chiếu)</option>
                            <option value="SAFE">An toàn (0 tham chiếu)</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Main Categories Data Table -->
            <div class="exec-table-card">
                <div class="table-responsive">
                    <table class="exec-table" id="categoriesTable">
                        <thead>
                            <tr>
                                <th style="width: 100px; text-align: center;">Thứ tự</th>
                                <th style="width: 180px;">Phân hệ / Loại</th>
                                <th>Tên danh mục chuẩn hóa</th>
                                <th style="width: 220px;">Tham chiếu dữ liệu</th>
                                <th style="width: 140px; text-align: center;">Trạng thái</th>
                                <th style="width: 140px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="categoriesTableBody">
                            <c:forEach var="c" items="${categories}">
                                <tr data-id="${c.categoryId}"
                                    data-type="${c.categoryType}"
                                    data-name="${fn:escapeXml(c.categoryName)}"
                                    data-order="${c.displayOrder}"
                                    data-status="${c.status}"
                                    data-refs="${c.usageCount}">
                                    
                                    <!-- Display Order -->
                                    <td style="text-align: center;">
                                        <div class="order-badge-container">
                                            <div class="order-number" title="Thứ tự hiển thị: ${c.displayOrder}">
                                                ${c.displayOrder}
                                            </div>
                                            <div class="order-arrows">
                                                <button type="button" class="order-btn-up" title="Tăng thứ tự ưu tiên (-1)" onclick="quickAdjustOrder(this, -1)">
                                                    <i class="fa fa-chevron-up"></i>
                                                </button>
                                                <button type="button" class="order-btn-down" title="Giảm thứ tự ưu tiên (+1)" onclick="quickAdjustOrder(this, 1)">
                                                    <i class="fa fa-chevron-down"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </td>

                                    <!-- Category Type Badge -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.categoryType eq 'INDUSTRY'}">
                                                <span class="type-badge type-industry">
                                                    <i class="fa fa-building"></i> Ngành nghề
                                                </span>
                                            </c:when>
                                            <c:when test="${c.categoryType eq 'COMPANY_SIZE'}">
                                                <span class="type-badge type-size">
                                                    <i class="fa fa-users"></i> Quy mô DN
                                                </span>
                                            </c:when>
                                            <c:when test="${c.categoryType eq 'LEAD_SOURCE' or c.categoryType eq 'SOURCE'}">
                                                <span class="type-badge type-source">
                                                    <i class="fa fa-bullseye"></i> Nguồn Lead
                                                </span>
                                            </c:when>
                                            <c:when test="${c.categoryType eq 'ACTIVITY_TYPE'}">
                                                <span class="type-badge type-activity">
                                                    <i class="fa fa-bolt"></i> Hoạt động
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="type-badge type-generic">
                                                    <i class="fa fa-tag"></i> <c:out value="${c.categoryType}"/>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Category Name -->
                                    <td>
                                        <div class="category-name-cell">
                                            <span class="category-name-text"><c:out value="${c.categoryName}"/></span>
                                            <span class="category-code-tag">ID: #${c.categoryId} &bull; Phân hệ: <c:out value="${c.categoryType}"/></span>
                                        </div>
                                    </td>

                                    <!-- Data Reference Integrity Badge -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.usageCount gt 0}">
                                                <span class="ref-badge ref-locked" title="Đang có ${c.usageCount} bản ghi tham chiếu trong cơ sở dữ liệu. Theo chính sách bảo toàn số liệu báo cáo gộp, giá trị này không thể xóa.">
                                                    <i class="fa fa-lock"></i> Đang dùng (${c.usageCount} bản ghi)
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="ref-badge ref-safe" title="Chưa có bản ghi nào tham chiếu. Có thể xóa an toàn.">
                                                    <i class="fa fa-shield-halved"></i> An toàn (0 tham chiếu)
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Status -->
                                    <td style="text-align: center;">
                                        <c:choose>
                                            <c:when test="${c.status eq 'ACTIVE'}">
                                                <span class="status-pill active">
                                                    <i class="fa fa-check-circle"></i> Áp dụng
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-pill inactive">
                                                    <i class="fa fa-pause-circle"></i> Tạm ngưng
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Actions -->
                                    <td style="text-align: center;">
                                        <div class="action-btn-group">
                                            <button type="button" class="action-btn action-edit" title="Chỉnh sửa danh mục" onclick="openEditModal(this)">
                                                <i class="fa fa-pen-to-square"></i>
                                            </button>
                                            
                                            <c:choose>
                                                <c:when test="${c.usageCount gt 0}">
                                                    <button type="button" class="action-btn action-delete" disabled style="opacity: 0.4; cursor: not-allowed;" title="Không thể xóa: Đang có ${c.usageCount} bản ghi tham chiếu dữ liệu!">
                                                        <i class="fa fa-lock"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" class="action-btn action-delete" title="Xóa danh mục này" onclick="confirmDelete(this)">
                                                        <i class="fa fa-trash-can"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty categories}">
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 48px; color: var(--crm-text-muted);">
                                        <i class="fa fa-folder-open" style="font-size: 36px; color: #cbd5e1; margin-bottom: 12px; display: block;"></i>
                                        Hiện chưa có danh mục nào trong hệ thống hoặc phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>
</div>

<!-- ==========================================================================
     Modal 1: Khai báo Danh mục mới
     ========================================================================== -->
<div id="createModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3><i class="fa fa-plus-circle" style="color: var(--crm-primary); margin-right: 8px;"></i> Khai báo Danh mục Dùng chung mới</h3>
            <button type="button" class="modal-close" onclick="closeCreateModal()">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/categories/update" onsubmit="return handleFormSubmit(event, this);">
            <input type="hidden" name="action" value="CREATE"/>
            <div class="modal-body">
                
                <div class="form-group">
                    <label class="form-label" for="createType">Phân hệ / Trục Danh mục <span class="req">*</span></label>
                    <select id="createType" name="categoryType" class="form-control" required>
                        <option value="">-- Chọn trục danh mục cốt lõi --</option>
                        <option value="INDUSTRY">🏢 Ngành nghề khách hàng (INDUSTRY)</option>
                        <option value="COMPANY_SIZE">👥 Quy mô doanh nghiệp (COMPANY_SIZE)</option>
                        <option value="LEAD_SOURCE">🎯 Nguồn Lead (LEAD_SOURCE)</option>
                        <option value="ACTIVITY_TYPE">⚡ Loại hoạt động (ACTIVITY_TYPE)</option>
                    </select>
                    <span class="form-hint">Lựa chọn 1 trong 4 phân hệ danh mục dùng chung theo chính sách bán hàng.</span>
                </div>

                <div class="form-group">
                    <label class="form-label" for="createName">Tên danh mục chuẩn hóa <span class="req">*</span></label>
                    <input type="text" id="createName" name="categoryName" class="form-control" placeholder="Ví dụ: Công nghệ thông tin, Hội thảo triển lãm..." required maxlength="100"/>
                    <span class="form-hint">Tên gọi đồng nhất sẽ xuất hiện trên các biểu mẫu nhập liệu và báo cáo gộp.</span>
                </div>

                <div class="form-row">
                    <div class="form-group" style="flex: 1;">
                        <label class="form-label" for="createOrder">Thứ tự hiển thị (sort_order)</label>
                        <input type="number" id="createOrder" name="displayOrder" class="form-control" value="10" min="0" max="9999"/>
                        <span class="form-hint">Số nhỏ hơn ưu tiên hiển thị trước.</span>
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label class="form-label" for="createStatus">Trạng thái sử dụng</label>
                        <select id="createStatus" name="status" class="form-control">
                            <option value="ACTIVE" selected>🟢 Đang áp dụng (ACTIVE)</option>
                            <option value="INACTIVE">⚪ Tạm ngưng (INACTIVE)</option>
                        </select>
                        <span class="form-hint">Tạm ngưng sẽ ẩn khỏi dropdown nhập mới.</span>
                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeCreateModal()">Hủy bỏ</button>
                <button type="submit" class="btn-modal-submit"><i class="fa fa-check"></i> Xác nhận lưu danh mục</button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     Modal 2: Chỉnh sửa Danh mục
     ========================================================================== -->
<div id="editModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3><i class="fa fa-pen-to-square" style="color: var(--crm-primary); margin-right: 8px;"></i> Chỉnh sửa Danh mục Chuẩn hóa</h3>
            <button type="button" class="modal-close" onclick="closeEditModal()">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/categories/update" onsubmit="return handleFormSubmit(event, this);">
            <input type="hidden" name="action" value="UPDATE"/>
            <input type="hidden" id="editCategoryId" name="categoryId"/>
            <div class="modal-body">
                
                <div class="form-group">
                    <label class="form-label">Phân hệ / Trục Danh mục</label>
                    <input type="hidden" id="editCategoryType" name="categoryType"/>
                    <div id="editTypeDisplay" style="padding: 8px 12px; background: #f1f5f9; border-radius: 6px; font-weight: 600; color: var(--crm-text-heading); font-size: 13.5px;">
                        --
                    </div>
                    <span class="form-hint">Phân hệ cố định để đảm bảo quy tắc khóa tham chiếu.</span>
                </div>

                <div class="form-group">
                    <label class="form-label" for="editCategoryName">Tên danh mục chuẩn hóa <span class="req">*</span></label>
                    <input type="text" id="editCategoryName" name="categoryName" class="form-control" required maxlength="100"/>
                    <span class="form-hint">Khi thay đổi tên, các giao dịch và báo cáo gộp sẽ phản ánh tên mới.</span>
                </div>

                <div class="form-row">
                    <div class="form-group" style="flex: 1;">
                        <label class="form-label" for="editDisplayOrder">Thứ tự hiển thị (sort_order)</label>
                        <input type="number" id="editDisplayOrder" name="displayOrder" class="form-control" min="0" max="9999"/>
                        <span class="form-hint">Tùy biến vị trí trên menu dropdown.</span>
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label class="form-label" for="editStatus">Trạng thái</label>
                        <select id="editStatus" name="status" class="form-control">
                            <option value="ACTIVE">🟢 Đang áp dụng (ACTIVE)</option>
                            <option value="INACTIVE">⚪ Tạm ngưng (INACTIVE)</option>
                        </select>
                        <span class="form-hint">Chuyển tạm ngưng thay vì xóa khi đã có tham chiếu.</span>
                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeEditModal()">Hủy</button>
                <button type="submit" class="btn-modal-submit"><i class="fa fa-save"></i> Cập nhật thay đổi</button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     Modal 3: Xác nhận Xóa Danh mục
     ========================================================================== -->
<div id="deleteModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 style="color: #dc2626;"><i class="fa fa-triangle-exclamation" style="margin-right: 8px;"></i> Xác nhận Xóa Danh mục</h3>
            <button type="button" class="modal-close" onclick="closeDeleteModal()">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/categories/update" onsubmit="return handleFormSubmit(event, this);">
            <input type="hidden" name="action" value="DELETE"/>
            <input type="hidden" id="deleteCategoryId" name="categoryId"/>
            <div class="modal-body">
                <p style="font-size: 14.5px; color: var(--crm-text-body); margin-bottom: 14px;">
                    Bạn có chắc chắn muốn xóa danh mục: <strong id="deleteCategoryName" style="color: var(--crm-text-heading);">--</strong>?
                </p>
                <div class="alert-notice" style="background: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px; padding: 12px; font-size: 13px; color: #92400e; display: flex; gap: 10px;">
                    <i class="fa fa-shield-halved" style="margin-top: 2px; font-size: 16px;"></i>
                    <div>
                        <strong>Quy tắc bảo vệ tham chiếu Backlog:</strong><br/>
                        Hệ thống chỉ cho phép xóa những danh mục <strong>chưa phát sinh tham chiếu (0 bản ghi)</strong>. Nếu danh mục đã có dữ liệu trong khách hàng, cơ hội hoặc hoạt động, thao tác xóa sẽ bị từ chối và bạn nên chuyển sang trạng thái <em>Tạm ngưng (INACTIVE)</em>.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeDeleteModal()">Hủy bỏ</button>
                <button type="submit" class="btn-modal-submit" style="background: #dc2626;"><i class="fa fa-trash-can"></i> Xác nhận Xóa</button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     Client-side Scripting & Interactive Controls
     ========================================================================== -->
<script>
    const CONTEXT_PATH = "${pageContext.request.contextPath}";
    let currentTabType = "${categoryType != null ? categoryType : ''}";

    // 1. Initialize KPI Cards and Counts on DOM Load
    document.addEventListener("DOMContentLoaded", function() {
        calculateAndRenderMetrics();
        if (currentTabType) {
            filterTableRows();
        }
    });

    function calculateAndRenderMetrics() {
        const rows = document.querySelectorAll("#categoriesTableBody tr[data-id]");
        const total = rows.length;
        let activeCount = 0;
        let refCount = 0;
        let industryCount = 0;
        let sizeCount = 0;
        let sourceCount = 0;
        let activityCount = 0;

        rows.forEach(r => {
            const status = r.getAttribute("data-status");
            const type = r.getAttribute("data-type");
            const refs = parseInt(r.getAttribute("data-refs") || "0", 10);

            if (status === "ACTIVE") activeCount++;
            if (refs > 0) refCount++;

            if (type === "INDUSTRY") industryCount++;
            else if (type === "COMPANY_SIZE") sizeCount++;
            else if (type === "LEAD_SOURCE" || type === "SOURCE") sourceCount++;
            else if (type === "ACTIVITY_TYPE") activityCount++;
        });

        // Set KPI cards
        const kpiTotal = document.getElementById("kpiTotalCategories");
        if (kpiTotal) kpiTotal.innerText = total;

        const kpiActive = document.getElementById("kpiActiveCount");
        if (kpiActive) kpiActive.innerText = activeCount;

        const kpiRef = document.getElementById("kpiReferencedCount");
        if (kpiRef) kpiRef.innerText = refCount;

        // Set Tab Counters
        const cAll = document.getElementById("countAll");
        if (cAll) cAll.innerText = total;

        const cInd = document.getElementById("countIndustry");
        if (cInd) cInd.innerText = industryCount;

        const cSize = document.getElementById("countSize");
        if (cSize) cSize.innerText = sizeCount;

        const cSrc = document.getElementById("countSource");
        if (cSrc) cSrc.innerText = sourceCount;

        const cAct = document.getElementById("countActivity");
        if (cAct) cAct.innerText = activityCount;
    }

    // 2. Tab Navigation
    function switchTab(type) {
        currentTabType = type;
        document.querySelectorAll(".tab-btn").forEach(btn => btn.classList.remove("active"));
        
        // Find matching tab button
        if (!type) {
            document.querySelectorAll(".tab-btn")[0].classList.add("active");
        } else if (type === "INDUSTRY") {
            document.querySelectorAll(".tab-btn")[1].classList.add("active");
        } else if (type === "COMPANY_SIZE") {
            document.querySelectorAll(".tab-btn")[2].classList.add("active");
        } else if (type === "LEAD_SOURCE") {
            document.querySelectorAll(".tab-btn")[3].classList.add("active");
        } else if (type === "ACTIVITY_TYPE") {
            document.querySelectorAll(".tab-btn")[4].classList.add("active");
        }

        filterTableRows();
    }

    // 3. Filtering by Search, Status, References
    function filterTableRows() {
        const query = (document.getElementById("searchInput").value || "").trim().toLowerCase();
        const statusVal = document.getElementById("statusFilter").value;
        const refVal = document.getElementById("refFilter").value;

        const rows = document.querySelectorAll("#categoriesTableBody tr[data-id]");
        let visibleCount = 0;

        rows.forEach(r => {
            const rType = r.getAttribute("data-type");
            const rName = (r.getAttribute("data-name") || "").toLowerCase();
            const rId = r.getAttribute("data-id");
            const rStatus = r.getAttribute("data-status");
            const rRefs = parseInt(r.getAttribute("data-refs") || "0", 10);

            // Tab filter
            let matchTab = true;
            if (currentTabType) {
                if (currentTabType === "LEAD_SOURCE") {
                    matchTab = (rType === "LEAD_SOURCE" || rType === "SOURCE");
                } else {
                    matchTab = (rType === currentTabType);
                }
            }

            // Search filter
            let matchSearch = true;
            if (query) {
                matchSearch = rName.includes(query) || rId.includes(query) || (rType && rType.toLowerCase().includes(query));
            }

            // Status filter
            let matchStatus = true;
            if (statusVal) {
                matchStatus = (rStatus === statusVal);
            }

            // Reference filter
            let matchRef = true;
            if (refVal === "LOCKED") {
                matchRef = (rRefs > 0);
            } else if (refVal === "SAFE") {
                matchRef = (rRefs === 0);
            }

            if (matchTab && matchSearch && matchStatus && matchRef) {
                r.style.display = "";
                visibleCount++;
            } else {
                r.style.display = "none";
            }
        });
    }

    // 4. Modal Open/Close Handlers
    function openCreateModal() {
        if (currentTabType) {
            const select = document.getElementById("createType");
            if (select) {
                select.value = (currentTabType === "SOURCE" ? "LEAD_SOURCE" : currentTabType);
            }
        }
        document.getElementById("createModal").classList.add("show");
        setTimeout(() => document.getElementById("createName").focus(), 150);
    }
    function closeCreateModal() {
        document.getElementById("createModal").classList.remove("show");
    }

    function openEditModal(trigger) {
        let id, type, name, order, status;
        if (trigger && trigger.closest) {
            const row = trigger.closest("tr");
            id = row.getAttribute("data-id");
            type = row.getAttribute("data-type");
            name = row.getAttribute("data-name");
            order = row.getAttribute("data-order");
            status = row.getAttribute("data-status");
        } else {
            id = arguments[0];
            type = arguments[1];
            name = arguments[2];
            order = arguments[3];
            status = arguments[4];
        }

        document.getElementById("editCategoryId").value = id;
        document.getElementById("editCategoryType").value = type;
        
        let typeText = type;
        if (type === 'INDUSTRY') typeText = '🏢 Ngành nghề khách hàng (INDUSTRY)';
        else if (type === 'COMPANY_SIZE') typeText = '👥 Quy mô doanh nghiệp (COMPANY_SIZE)';
        else if (type === 'LEAD_SOURCE' || type === 'SOURCE') typeText = '🎯 Nguồn Lead (LEAD_SOURCE)';
        else if (type === 'ACTIVITY_TYPE') typeText = '⚡ Loại hoạt động (ACTIVITY_TYPE)';
        document.getElementById("editTypeDisplay").innerText = typeText;

        document.getElementById("editCategoryName").value = name;
        document.getElementById("editDisplayOrder").value = order;
        document.getElementById("editStatus").value = status;

        document.getElementById("editModal").classList.add("show");
        setTimeout(() => document.getElementById("editCategoryName").focus(), 150);
    }
    function closeEditModal() {
        document.getElementById("editModal").classList.remove("show");
    }

    function confirmDelete(trigger) {
        let id, name, refs;
        if (trigger && trigger.closest) {
            const row = trigger.closest("tr");
            id = row.getAttribute("data-id");
            name = row.getAttribute("data-name");
            refs = parseInt(row.getAttribute("data-refs") || "0", 10);
        } else {
            id = arguments[0];
            name = arguments[1];
            refs = arguments[2];
        }

        if (refs > 0) {
            alert("CHÍNH SÁCH BẢO VỆ THAM CHIẾU:\n\nDanh mục '" + name + "' đang được tham chiếu bởi " + refs + " bản ghi trong hệ thống và KHÔNG THỂ XÓA.\n\nVui lòng chuyển trạng thái sang 'Tạm ngưng (INACTIVE)' nếu không còn nhu cầu nhập liệu mới.");
            return;
        }
        document.getElementById("deleteCategoryId").value = id;
        document.getElementById("deleteCategoryName").innerText = name;
        document.getElementById("deleteModal").classList.add("show");
    }
    function closeDeleteModal() {
        document.getElementById("deleteModal").classList.remove("show");
    }

    // 5. Quick Adjust Sort Order
    function quickAdjustOrder(trigger, delta) {
        let id;
        let row;
        if (trigger && trigger.closest) {
            row = trigger.closest("tr");
            id = row ? row.getAttribute("data-id") : null;
        } else {
            id = trigger;
            row = document.querySelector("#categoriesTableBody tr[data-id='" + id + "']");
        }
        if (!row) return;
        const currentOrder = parseInt(row.getAttribute("data-order") || "0", 10);
        const newOrder = Math.max(0, currentOrder + delta);
        const name = row.getAttribute("data-name");
        const type = row.getAttribute("data-type");
        const status = row.getAttribute("data-status");

        const params = new URLSearchParams();
        params.append("action", "UPDATE");
        params.append("categoryId", id);
        params.append("categoryType", type);
        params.append("categoryName", name);
        params.append("displayOrder", newOrder);
        params.append("status", status);

        fetch(CONTEXT_PATH + "/categories/update", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                "X-Requested-With": "XMLHttpRequest"
            },
            body: params.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                row.setAttribute("data-order", newOrder);
                const orderNumEl = row.querySelector(".order-number");
                if (orderNumEl) orderNumEl.innerText = newOrder;
            } else {
                alert("Lỗi: " + (data.errors ? data.errors.join("\n") : "Không thể đổi thứ tự hiển thị."));
            }
        })
        .catch(err => {
            console.error(err);
            window.location.reload();
        });
    }

    // 6. AJAX Form Submission
    function handleFormSubmit(event, form) {
        event.preventDefault();
        const formData = new FormData(form);
        const params = new URLSearchParams();
        for (const pair of formData.entries()) {
            params.append(pair[0], pair[1]);
        }

        fetch(form.action, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                "X-Requested-With": "XMLHttpRequest"
            },
            body: params.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                window.location.href = CONTEXT_PATH + "/categories?success=true";
            } else {
                alert("LỖI THỰC HIỆN:\n\n" + (data.errors ? data.errors.join("\n") : "Thao tác không thành công."));
            }
        })
        .catch(err => {
            console.error(err);
            form.submit(); // fallback to standard POST
        });
        return false;
    }

    // Close modal on click outside
    window.addEventListener("click", function(e) {
        if (e.target.classList.contains("modal-overlay")) {
            e.target.classList.remove("show");
        }
    });
</script>

</body>
</html>
