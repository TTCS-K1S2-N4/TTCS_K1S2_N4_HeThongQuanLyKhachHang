<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa Sản phẩm & Bảng giá | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/products.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Edit Product & Pricing Architecture
           ========================================================================== */
        :root {
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-accent: #d97706;
            --crm-surface: #ffffff;
            --crm-border: #e2e8f0;
            --crm-border-focus: #2563eb;
            --crm-text-heading: #0f172a;
            --crm-text-body: #334155;
            --crm-text-muted: #64748b;
            --crm-radius-sm: 8px;
            --crm-radius-md: 12px;
            --crm-radius-lg: 16px;
            --crm-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --crm-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.06);
        }

        .product-form-container {
            max-width: 1200px;
            margin: 0 auto;
            padding-bottom: 50px;
        }

        /* Breadcrumbs */
        .exec-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--crm-text-muted);
            margin-bottom: 16px;
        }
        .exec-breadcrumb a {
            color: var(--crm-text-muted);
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .exec-breadcrumb a:hover {
            color: var(--crm-primary);
        }
        .exec-breadcrumb .sep {
            color: #cbd5e1;
            font-size: 11px;
        }
        .exec-breadcrumb .current {
            color: var(--crm-primary);
            font-weight: 600;
        }

        /* Header */
        .exec-form-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 24px;
        }
        .exec-form-title h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 4px 0;
            letter-spacing: -0.02em;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .exec-form-title p {
            font-size: 14px;
            color: var(--crm-text-muted);
            margin: 0;
        }

        /* Grid Layout */
        .exec-form-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }
        @media (max-width: 992px) {
            .exec-form-layout {
                grid-template-columns: 1fr;
            }
        }

        /* Cards */
        .exec-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--crm-shadow-sm);
        }
        .exec-card-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 18px 0;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .exec-card-title i {
            color: var(--crm-primary);
            font-size: 18px;
        }

        /* Form Controls */
        .form-row-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        @media (max-width: 600px) {
            .form-row-2col {
                grid-template-columns: 1fr;
            }
        }

        .exec-field-group {
            margin-bottom: 18px;
        }
        .exec-field-group label {
            display: block;
            font-size: 13.5px;
            font-weight: 600;
            color: var(--crm-text-heading);
            margin-bottom: 6px;
        }
        .exec-field-group label .req {
            color: #dc2626;
            margin-left: 2px;
        }

        .exec-input-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            font-size: 14px;
            color: var(--crm-text-heading);
            background: #ffffff;
            transition: all 0.15s ease;
            box-sizing: border-box;
        }
        .exec-input-control:focus {
            border-color: var(--crm-border-focus);
            outline: none;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .exec-field-hint {
            font-size: 12px;
            color: var(--crm-text-muted);
            margin-top: 5px;
            line-height: 1.4;
        }

        /* Live Price Preview Pill */
        .live-preview-box {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: var(--crm-radius-sm);
            padding: 8px 12px;
            font-size: 12.5px;
            color: var(--crm-text-body);
            margin-top: 6px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .live-preview-val {
            font-weight: 700;
            color: var(--crm-primary);
        }

        /* Director Financial Card */
        .director-card {
            background: linear-gradient(135deg, #f8fafc 0%, #faf5ff 100%);
            border: 1px solid #e9d5ff;
        }
        .director-card .exec-card-title i {
            color: #7c3aed;
        }
        .director-badge-inline {
            background: #7c3aed;
            color: #ffffff;
            font-size: 11px;
            font-weight: 600;
            padding: 2px 8px;
            border-radius: 12px;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        /* Policy & Guidance Sidebar */
        .policy-card {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
        }
        .policy-item {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            margin-bottom: 14px;
            font-size: 13px;
            line-height: 1.5;
            color: #1e3a8a;
        }
        .policy-item i {
            font-size: 16px;
            color: #2563eb;
            margin-top: 2px;
            flex-shrink: 0;
        }

        /* Metric preview widget */
        .margin-calc-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: var(--crm-radius-md);
            padding: 16px;
            margin-top: 14px;
        }
        .margin-calc-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 0;
            font-size: 13px;
            border-bottom: 1px solid #f1f5f9;
        }
        .margin-calc-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        /* Error Banner */
        .exec-error-box {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: var(--crm-radius-md);
            padding: 16px 20px;
            margin-bottom: 24px;
            color: #991b1b;
        }
        .exec-error-box ul {
            margin: 8px 0 0 18px;
            padding: 0;
            font-size: 13px;
        }

        /* Buttons */
        .btn-exec-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            padding: 11px 24px;
            font-weight: 600;
            font-size: 14px;
            border-radius: var(--crm-radius-md);
            border: none;
            box-shadow: 0 4px 14px rgba(30, 58, 138, 0.28);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-exec-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(30, 58, 138, 0.38);
        }

        .btn-exec-secondary {
            background: #ffffff;
            color: var(--crm-text-body) !important;
            padding: 10px 20px;
            font-weight: 600;
            font-size: 14px;
            border-radius: var(--crm-radius-md);
            border: 1px solid var(--crm-border);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-exec-secondary:hover {
            background: #f1f5f9;
        }

        .btn-danger-outline {
            background: #ffffff;
            color: #dc2626 !important;
            padding: 10px 18px;
            font-weight: 600;
            font-size: 13.5px;
            border-radius: var(--crm-radius-md);
            border: 1px solid #fecaca;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
        }
        .btn-danger-outline:hover {
            background: #fef2f2;
            border-color: #f87171;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container product-form-container">
            
            <!-- Breadcrumbs -->
            <nav class="exec-breadcrumb">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> CRM</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <a href="${pageContext.request.contextPath}/products">Bảng giá & Sản phẩm</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current">Chỉnh sửa: <c:out value="${product.productName}"/></span>
            </nav>

            <!-- Header -->
            <div class="exec-form-header">
                <div class="exec-form-title">
                    <h1>
                        <i class="fa-solid fa-pen-to-square"></i>
                        Cập nhật Bảng giá: <span style="color: var(--crm-primary);"><c:out value="${product.productName}"/></span>
                    </h1>
                    <p>Điều chỉnh thông tin sản phẩm, giá niêm yết chuẩn và ngưỡng giá sàn phê duyệt chiết khấu.</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/products/detail?productId=${product.productId}" class="btn-exec-secondary">
                        <i class="fa-solid fa-eye"></i> Xem chi tiết
                    </a>
                    <a href="${pageContext.request.contextPath}/products" class="btn-exec-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Danh sách
                    </a>
                </div>
            </div>

            <!-- Server Errors Notification -->
            <c:if test="${not empty errors}">
                <div class="exec-error-box">
                    <div style="font-weight: 700; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Không thể lưu thay đổi, vui lòng kiểm tra:
                    </div>
                    <ul>
                        <c:forEach var="err" items="${errors}">
                            <li><c:out value="${err}"/></li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>

            <!-- Form -->
            <form method="post" action="${pageContext.request.contextPath}/products/edit" id="productEditForm">
                <input type="hidden" name="productId" value="${product.productId}">

                <div class="exec-form-layout">
                    
                    <!-- LEFT COLUMN: Main Information -->
                    <div class="exec-form-main">
                        
                        <!-- CARD 1: Identity & Classification -->
                        <div class="exec-card">
                            <h2 class="exec-card-title">
                                <i class="fa-solid fa-tag"></i>
                                1. Định danh & Phân loại sản phẩm
                            </h2>

                            <div class="form-row-2col">
                                <div class="exec-field-group">
                                    <label for="productCode">Mã sản phẩm <span class="req">*</span></label>
                                    <input type="text" id="productCode" name="productCode" 
                                           class="exec-input-control" required
                                           value="<c:out value='${product.productCode}'/>">
                                    <div class="exec-field-hint">Mã duy nhất trong toàn hệ thống bảng giá CRM.</div>
                                </div>

                                <div class="exec-field-group">
                                    <label for="productType">Loại hình sản phẩm <span class="req">*</span></label>
                                    <select id="productType" name="productType" class="exec-input-control" required>
                                        <option value="ONE_TIME" ${product.productType == 'ONE_TIME' ? 'selected' : ''}>
                                            Sản phẩm một lần (One-time Sale)
                                        </option>
                                        <option value="SUBSCRIPTION" ${product.productType == 'SUBSCRIPTION' ? 'selected' : ''}>
                                            Dịch vụ thuê bao định kỳ (Subscription)
                                        </option>
                                    </select>
                                    <div class="exec-field-hint">Xác định hình thức bán một lần hay tính phí chu kỳ.</div>
                                </div>
                            </div>

                            <div class="exec-field-group">
                                <label for="productName">Tên sản phẩm / Dịch vụ <span class="req">*</span></label>
                                <input type="text" id="productName" name="productName" 
                                       class="exec-input-control" required
                                       value="<c:out value='${product.productName}'/>">
                                <div class="exec-field-hint">Tên hiển thị trên báo giá gửi cho đối tác/khách hàng.</div>
                            </div>

                            <div class="exec-field-group">
                                <label for="unit">Đơn vị tính (ĐVT) <span class="req">*</span></label>
                                <input type="text" id="unit" name="unit" 
                                       class="exec-input-control" required list="unitSuggestions"
                                       value="<c:out value='${product.unit}'/>">
                                <datalist id="unitSuggestions">
                                    <option value="Cái">
                                    <option value="Bộ">
                                    <option value="Gói">
                                    <option value="User/Tháng">
                                    <option value="User/Năm">
                                    <option value="Dự án">
                                    <option value="License">
                                </datalist>
                                <div class="exec-field-hint">Đơn vị đo lường khi lên số lượng.</div>
                            </div>
                        </div>

                        <!-- CARD 2: Standard Pricing & Discount Floor -->
                        <div class="exec-card">
                            <h2 class="exec-card-title">
                                <i class="fa-solid fa-money-bill-wave"></i>
                                2. Bảng giá niêm yết chuẩn & Ngưỡng duyệt chiết khấu
                            </h2>

                            <div class="form-row-2col">
                                <div class="exec-field-group">
                                    <label for="listPrice">Giá niêm yết (List Price) <span class="req">*</span></label>
                                    <input type="number" step="0.01" min="0" id="listPrice" name="listPrice" 
                                           class="exec-input-control" required
                                           value="${product.listPrice}">
                                    <div class="live-preview-box">
                                        <span>Quy đổi:</span>
                                        <span class="live-preview-val" id="listPricePreview">0 ₫</span>
                                    </div>
                                    <div class="exec-field-hint">Mọi báo giá gửi khách hàng đều bắt đầu từ mức giá này.</div>
                                </div>

                                <div class="exec-field-group">
                                    <label for="floorPrice">Giá sàn (Floor Price) <span class="req">*</span></label>
                                    <input type="number" step="0.01" min="0" id="floorPrice" name="floorPrice" 
                                           class="exec-input-control" required
                                           value="${product.floorPrice}">
                                    <div class="live-preview-box">
                                        <span>Quy đổi:</span>
                                        <span class="live-preview-val" id="floorPricePreview" style="color: #d97706;">0 ₫</span>
                                    </div>
                                    <div class="exec-field-hint">
                                        <strong>Ngưỡng chiết khấu:</strong> Giá báo dưới mức này bắt buộc phải qua Giám đốc kinh doanh duyệt.
                                    </div>
                                </div>
                            </div>

                            <!-- Real-time calculation margin box -->
                            <div class="margin-calc-card" id="pricingAnalysisCard">
                                <div class="margin-calc-row">
                                    <span style="color: var(--crm-text-muted);">Biên độ giảm giá Sales được phép tự quyết:</span>
                                    <span style="font-weight: 700; color: #166534;" id="maxDiscountAmount">0 ₫</span>
                                </div>
                                <div class="margin-calc-row">
                                    <span style="color: var(--crm-text-muted);">Tỷ lệ chiết khấu tối đa không cần duyệt:</span>
                                    <span style="font-weight: 700; color: #166534;" id="maxDiscountPercent">0%</span>
                                </div>
                                <div id="priceValidationError" style="display: none; color: #dc2626; font-size: 12.5px; margin-top: 8px; font-weight: 600;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Giá sàn không được lớn hơn giá niêm yết!
                                </div>
                            </div>
                        </div>

                        <!-- CARD 3: Director Only Cost Price (AC3) -->
                        <c:if test="${canAccessCostPrice}">
                            <div class="exec-card director-card">
                                <h2 class="exec-card-title">
                                    <i class="fa-solid fa-shield-halved"></i>
                                    3. Dữ liệu Tài chính Bảo mật
                                    <span class="director-badge-inline"><i class="fa-solid fa-lock"></i> Dành riêng cho Giám đốc kinh doanh</span>
                                </h2>

                                <div class="exec-field-group">
                                    <label for="costPrice">Giá vốn sản phẩm / Dịch vụ</label>
                                    <input type="number" step="0.01" min="0" id="costPrice" name="costPrice" 
                                           class="exec-input-control"
                                           value="${product.costPrice}">
                                    <div class="live-preview-box">
                                        <span>Quy đổi giá vốn:</span>
                                        <span class="live-preview-val" id="costPricePreview" style="color: #7c3aed;">0 ₫</span>
                                    </div>
                                    <div class="exec-field-hint" style="color: #6b21a8;">
                                        🔒 <strong>Phân quyền bảo mật:</strong> Chỉ Giám đốc kinh doanh và Quản trị viên hệ thống có quyền xem và sửa giá vốn. Nhân viên kinh doanh hoàn toàn không nhìn thấy số liệu này.
                                    </div>
                                </div>

                                <div class="margin-calc-card" id="profitAnalysisCard" style="background: rgba(255,255,255,0.8);">
                                    <div class="margin-calc-row">
                                        <span style="color: #475569;">Lợi nhuận gộp danh nghĩa (Giá niêm yết - Giá vốn):</span>
                                        <span style="font-weight: 700; color: #1e3a8a;" id="grossProfitVal">0 ₫</span>
                                    </div>
                                    <div class="margin-calc-row">
                                        <span style="color: #475569;">Biên lợi nhuận gộp danh nghĩa:</span>
                                        <span style="font-weight: 700; color: #1e3a8a;" id="grossMarginPercent">0%</span>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                    </div>

                    <!-- RIGHT COLUMN: Status & Policies -->
                    <div class="exec-form-sidebar">
                        
                        <!-- CARD 4: Business Status -->
                        <div class="exec-card">
                            <h2 class="exec-card-title">
                                <i class="fa-solid fa-toggle-on"></i>
                                Trạng thái kinh doanh
                            </h2>

                            <div class="exec-field-group">
                                <label for="status">Tình trạng mở bán</label>
                                <select id="status" name="status" class="exec-input-control">
                                    <option value="ACTIVE" ${product.status == 'ACTIVE' ? 'selected' : ''}>
                                        Đang kinh doanh (Kích hoạt cho Sales)
                                    </option>
                                    <option value="INACTIVE" ${product.status == 'INACTIVE' ? 'selected' : ''}>
                                        Ngừng kinh doanh (Tạm dừng)
                                    </option>
                                </select>
                                <div class="exec-field-hint">
                                    Khi chuyển sang <em>Ngừng kinh doanh</em>, sản phẩm vẫn được giữ trong lịch sử báo giá cũ nhưng không thể tạo báo giá mới.
                                </div>
                            </div>

                            <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 24px;">
                                <button type="submit" class="btn-exec-primary" style="justify-content: center;" id="btnSubmitProduct">
                                    <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi Bảng giá
                                </button>
                                <a href="${pageContext.request.contextPath}/products" class="btn-exec-secondary" style="justify-content: center;">
                                    <i class="fa-solid fa-xmark"></i> Hủy bỏ
                                </a>
                            </div>
                        </div>

                        <!-- CARD 5: Danger Zone & Backlog Constraint -->
                        <div class="exec-card" style="border-color: #fecaca; background: #fffafb;">
                            <h2 class="exec-card-title" style="color: #991b1b; border-bottom-color: #fee2e2;">
                                <i class="fa-solid fa-triangle-exclamation" style="color: #dc2626;"></i>
                                Thao tác rủi ro & Dữ liệu
                            </h2>
                            <p style="font-size: 13px; color: #7f1d1d; line-height: 1.5; margin-bottom: 16px;">
                                Theo quy tắc CRM, sản phẩm đã xuất hiện trong báo giá thì <strong>không xóa được</strong> để tránh mất mát dữ liệu kế toán; thay vào đó bạn hãy chọn <strong>Ngừng kinh doanh</strong>.
                            </p>
                            <button type="button" onclick="confirmDeleteCurrentProduct()" class="btn-danger-outline" style="width: 100%; justify-content: center;">
                                <i class="fa-solid fa-trash-can"></i> Xóa sản phẩm này
                            </button>
                        </div>

                    </div>

                </div>
            </form>

        </div>
    </main>
</div>

<!-- Interactive Financial Logic Script -->
<script>
    function formatVND(value) {
        if (!value || isNaN(value)) return '0 ₫';
        return Number(value).toLocaleString('vi-VN') + ' ₫';
    }

    function recalculatePricing() {
        var listPriceInput = document.getElementById('listPrice');
        var floorPriceInput = document.getElementById('floorPrice');
        var costPriceInput = document.getElementById('costPrice');

        var listPrice = parseFloat(listPriceInput ? listPriceInput.value : 0) || 0;
        var floorPrice = parseFloat(floorPriceInput ? floorPriceInput.value : 0) || 0;
        var costPrice = parseFloat(costPriceInput ? costPriceInput.value : 0) || 0;

        // Update previews
        document.getElementById('listPricePreview').textContent = formatVND(listPrice);
        document.getElementById('floorPricePreview').textContent = formatVND(floorPrice);
        if (document.getElementById('costPricePreview')) {
            document.getElementById('costPricePreview').textContent = formatVND(costPrice);
        }

        // Validate floor <= list
        var validationErr = document.getElementById('priceValidationError');
        var submitBtn = document.getElementById('btnSubmitProduct');

        if (floorPrice > listPrice && listPrice > 0) {
            validationErr.style.display = 'block';
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.6';
        } else {
            validationErr.style.display = 'none';
            submitBtn.disabled = false;
            submitBtn.style.opacity = '1';
        }

        // Calculate max allowed discount
        if (listPrice > 0 && floorPrice <= listPrice) {
            var maxDiscountAmount = listPrice - floorPrice;
            var maxDiscountPercent = ((maxDiscountAmount / listPrice) * 100).toFixed(1);
            document.getElementById('maxDiscountAmount').textContent = formatVND(maxDiscountAmount);
            document.getElementById('maxDiscountPercent').textContent = maxDiscountPercent + '%';
        } else {
            document.getElementById('maxDiscountAmount').textContent = '0 ₫';
            document.getElementById('maxDiscountPercent').textContent = '0%';
        }

        // Calculate gross profit if director
        if (costPriceInput && document.getElementById('grossProfitVal')) {
            if (listPrice > 0 && costPrice > 0) {
                var profit = listPrice - costPrice;
                var margin = ((profit / listPrice) * 100).toFixed(1);
                document.getElementById('grossProfitVal').textContent = formatVND(profit);
                document.getElementById('grossMarginPercent').textContent = margin + '%';
            } else {
                document.getElementById('grossProfitVal').textContent = '0 ₫';
                document.getElementById('grossMarginPercent').textContent = '0%';
            }
        }
    }

    document.getElementById('listPrice').addEventListener('input', recalculatePricing);
    document.getElementById('floorPrice').addEventListener('input', recalculatePricing);
    var costInput = document.getElementById('costPrice');
    if (costInput) {
        costInput.addEventListener('input', recalculatePricing);
    }

    // Initialize on page load
    recalculatePricing();

    function confirmDeleteCurrentProduct() {
        var productName = document.getElementById('productName').value;
        var warningMsg = 'XÁC NHẬN XÓA SẢN PHẨM: "' + productName + '"\n\n' +
            '⚠️ QUY ĐỊNH BẢO VỆ DỮ LIỆU BÁO GIÁ CRM:\n' +
            '• Nếu sản phẩm này ĐÃ TỪNG XUẤT HIỆN trong bất kỳ báo giá hoặc cơ hội nào, hệ thống sẽ NGĂN CHẶN XÓA để bảo toàn lịch sử số liệu.\n' +
            '• Khi đó bạn chỉ có thể chọn "Ngừng kinh doanh".\n\n' +
            'Bạn có chắc chắn muốn gửi yêu cầu xóa không?';

        if (!confirm(warningMsg)) {
            return;
        }

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/products/delete';

        var inputId = document.createElement('input');
        inputId.type = 'hidden';
        inputId.name = 'productId';
        inputId.value = '${product.productId}';
        form.appendChild(inputId);

        document.body.appendChild(form);
        form.submit();
    }
</script>
</body>
</html>
