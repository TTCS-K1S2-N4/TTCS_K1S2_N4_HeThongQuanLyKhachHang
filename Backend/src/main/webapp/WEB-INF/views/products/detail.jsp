<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${product.productName}"/> | Bảng giá CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/products.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Product Detail & Pricing Sheet
           ========================================================================== */
        :root {
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-accent: #d97706;
            --crm-surface: #ffffff;
            --crm-border: #e2e8f0;
            --crm-text-heading: #0f172a;
            --crm-text-body: #334155;
            --crm-text-muted: #64748b;
            --crm-radius-sm: 8px;
            --crm-radius-md: 12px;
            --crm-radius-lg: 16px;
            --crm-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --crm-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.06);
        }

        .product-detail-container {
            max-width: 1240px;
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

        /* Hero Header Card */
        .product-hero-card {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-lg);
            padding: 24px 28px;
            margin-bottom: 24px;
            box-shadow: var(--crm-shadow-sm);
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 20px;
        }

        .product-hero-left {
            display: flex;
            gap: 18px;
            align-items: flex-start;
        }

        .product-avatar-icon {
            width: 58px;
            height: 58px;
            border-radius: 14px;
            background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
            color: #1e3a8a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            flex-shrink: 0;
            border: 1px solid #bfdbfe;
        }

        .product-hero-info h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--crm-text-heading);
            margin: 0 0 8px 0;
            letter-spacing: -0.02em;
        }

        .product-hero-tags {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .code-pill {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 12.5px;
            font-weight: 600;
            background: #f1f5f9;
            color: #334155;
            padding: 3px 10px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
        }

        .type-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 11.5px;
            font-weight: 600;
            padding: 3px 9px;
            border-radius: 20px;
            text-transform: uppercase;
        }
        .type-pill.one-time {
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }
        .type-pill.subscription {
            background: #faf5ff;
            color: #6b21a8;
            border: 1px solid #e9d5ff;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12.5px;
            font-weight: 600;
        }
        .status-badge.active {
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }
        .status-badge.inactive {
            background: #f8fafc;
            color: #64748b;
            border: 1px solid #e2e8f0;
        }

        .hero-actions-group {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }

        /* Executive Financial KPI Cards */
        .pricing-kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .pricing-kpi-card {
            background: #ffffff;
            border: 1px solid var(--crm-border);
            border-radius: var(--crm-radius-md);
            padding: 20px;
            box-shadow: var(--crm-shadow-sm);
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .pricing-kpi-card.highlight {
            border-color: #bfdbfe;
            background: linear-gradient(135deg, #ffffff 0%, #eff6ff 100%);
        }
        .pricing-kpi-card.director {
            border-color: #e9d5ff;
            background: linear-gradient(135deg, #ffffff 0%, #faf5ff 100%);
        }

        .pricing-kpi-title {
            font-size: 12.5px;
            font-weight: 700;
            color: var(--crm-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .pricing-kpi-amount {
            font-size: 26px;
            font-weight: 800;
            color: var(--crm-text-heading);
            letter-spacing: -0.02em;
        }
        .pricing-kpi-sub {
            font-size: 12.5px;
            color: var(--crm-text-muted);
        }

        /* 2 Column Details Layout */
        .detail-grid-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }
        @media (max-width: 992px) {
            .detail-grid-layout {
                grid-template-columns: 1fr;
            }
        }

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

        /* Specs Table */
        .specs-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }
        .specs-table tr {
            border-bottom: 1px solid #f1f5f9;
        }
        .specs-table th {
            width: 38%;
            padding: 12px 14px;
            text-align: left;
            font-size: 13px;
            color: var(--crm-text-muted);
            font-weight: 600;
            background: #f8fafc;
            border-bottom: 1px solid #f1f5f9;
        }
        .specs-table td {
            padding: 12px 14px;
            font-size: 13.5px;
            color: var(--crm-text-heading);
            border-bottom: 1px solid #f1f5f9;
        }

        /* Buttons */
        .btn-exec-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            padding: 9px 18px;
            font-weight: 600;
            font-size: 13.5px;
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
        }

        .btn-exec-secondary {
            background: #ffffff;
            color: var(--crm-text-body) !important;
            padding: 9px 18px;
            font-weight: 600;
            font-size: 13.5px;
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

        .btn-exec-danger {
            background: #ffffff;
            color: #dc2626 !important;
            padding: 9px 16px;
            font-weight: 600;
            font-size: 13.5px;
            border-radius: var(--crm-radius-md);
            border: 1px solid #fecaca;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .btn-exec-danger:hover {
            background: #fef2f2;
            border-color: #f87171;
        }

        /* Policy sidebar item */
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
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container product-detail-container">
            
            <!-- Breadcrumbs -->
            <nav class="exec-breadcrumb">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> CRM</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <a href="${pageContext.request.contextPath}/products">Bảng giá & Sản phẩm</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current"><c:out value="${product.productName}"/></span>
            </nav>

            <!-- Hero Header Card -->
            <div class="product-hero-card">
                <div class="product-hero-left">
                    <div class="product-avatar-icon">
                        <c:choose>
                            <c:when test="${product.productType == 'SUBSCRIPTION'}">
                                <i class="fa-solid fa-repeat"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-cube"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="product-hero-info">
                        <h1><c:out value="${product.productName}"/></h1>
                        <div class="product-hero-tags">
                            <span class="code-pill">Mã: <c:out value="${product.productCode}"/></span>
                            <c:choose>
                                <c:when test="${product.productType == 'SUBSCRIPTION'}">
                                    <span class="type-pill subscription"><i class="fa-solid fa-repeat"></i> Dịch vụ thuê bao</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="type-pill one-time"><i class="fa-solid fa-cube"></i> Sản phẩm bán một lần</span>
                                </c:otherwise>
                            </c:choose>
                            <c:choose>
                                <c:when test="${product.status == 'ACTIVE'}">
                                    <span class="status-badge active"><i class="fa-solid fa-circle-check"></i> Đang kinh doanh</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge inactive"><i class="fa-solid fa-ban"></i> Ngừng kinh doanh</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="hero-actions-group">
                    <c:if test="${canManageProducts}">
                        <a href="${pageContext.request.contextPath}/products/edit?productId=${product.productId}" class="btn-exec-primary">
                            <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa bảng giá
                        </a>
                        <button type="button" onclick="toggleCurrentStatus()" class="btn-exec-secondary">
                            <i class="fa-solid ${product.status == 'ACTIVE' ? 'fa-pause' : 'fa-play'}"></i>
                            ${product.status == 'ACTIVE' ? 'Ngừng kinh doanh' : 'Kích hoạt lại'}
                        </button>
                        <button type="button" onclick="deleteCurrentProduct()" class="btn-exec-danger" title="Xóa sản phẩm">
                            <i class="fa-solid fa-trash-can"></i> Xóa
                        </button>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/products" class="btn-exec-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Danh sách
                    </a>
                </div>
            </div>

            <!-- Financial Pricing Overview KPIs -->
            <div class="pricing-kpi-grid">
                
                <!-- KPI 1: List Price -->
                <div class="pricing-kpi-card highlight">
                    <div class="pricing-kpi-title">
                        <span>Giá niêm yết chuẩn</span>
                        <i class="fa-solid fa-money-bill-wave" style="color: #2563eb;"></i>
                    </div>
                    <div class="pricing-kpi-amount" style="color: var(--crm-primary);">
                        <fmt:formatNumber value="${product.listPrice}" type="currency" currencySymbol="₫"/>
                    </div>
                    <div class="pricing-kpi-sub">
                        Giá xuất phát điểm mặc định khi lập Báo giá
                    </div>
                </div>

                <!-- KPI 2: Floor Price (Backlog AC2) -->
                <div class="pricing-kpi-card">
                    <div class="pricing-kpi-title">
                        <span>Giá sàn (Ngưỡng duyệt CK)</span>
                        <i class="fa-solid fa-shield-halved" style="color: #d97706;"></i>
                    </div>
                    <div class="pricing-kpi-amount" style="color: #d97706;">
                        <fmt:formatNumber value="${product.floorPrice}" type="currency" currencySymbol="₫"/>
                    </div>
                    <div class="pricing-kpi-sub">
                        <span style="color: #b45309; font-weight: 600;">
                            <i class="fa-solid fa-lock"></i> Giá dưới ngưỡng này cần GĐKD phê duyệt
                        </span>
                    </div>
                </div>

                <!-- KPI 3: Allowed Discount Margin -->
                <div class="pricing-kpi-card">
                    <div class="pricing-kpi-title">
                        <span>Biên độ Sales tự quyết</span>
                        <i class="fa-solid fa-chart-pie" style="color: #059669;"></i>
                    </div>
                    <div class="pricing-kpi-amount" style="color: #059669;">
                        <c:choose>
                            <c:when test="${product.listPrice != null and product.floorPrice != null and product.listPrice > 0}">
                                <c:set var="maxDiscount" value="${product.listPrice - product.floorPrice}"/>
                                <fmt:formatNumber value="${maxDiscount}" type="currency" currencySymbol="₫"/>
                            </c:when>
                            <c:otherwise>0 ₫</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="pricing-kpi-sub">
                        <c:if test="${product.listPrice != null and product.floorPrice != null and product.listPrice > 0}">
                            Tối đa <fmt:formatNumber value="${((product.listPrice - product.floorPrice) / product.listPrice) * 100}" maxFractionDigits="1"/>% chiết khấu không cần trình duyệt
                        </c:if>
                    </div>
                </div>

                <!-- KPI 4: Cost Price (AC3) -->
                <c:if test="${canAccessCostPrice}">
                    <div class="pricing-kpi-card director">
                        <div class="pricing-kpi-title">
                            <span>Giá vốn (Chỉ GĐKD)</span>
                            <i class="fa-solid fa-user-tie" style="color: #7c3aed;"></i>
                        </div>
                        <div class="pricing-kpi-amount" style="color: #7c3aed;">
                            <c:choose>
                                <c:when test="${product.costPrice != null}">
                                    <fmt:formatNumber value="${product.costPrice}" type="currency" currencySymbol="₫"/>
                                </c:when>
                                <c:otherwise>---</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="pricing-kpi-sub">
                            <c:choose>
                                <c:when test="${product.costPrice != null and product.listPrice != null and product.listPrice > 0}">
                                    LN gộp: <fmt:formatNumber value="${product.listPrice - product.costPrice}" type="currency" currencySymbol="₫"/>
                                </c:when>
                                <c:otherwise>Bảo mật riêng Giám đốc kinh doanh</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>

            </div>

            <!-- Detail Grid Layout -->
            <div class="detail-grid-layout">
                
                <!-- Left: Full Specifications Table -->
                <div class="detail-main-col">
                    <div class="exec-card">
                        <h2 class="exec-card-title">
                            <i class="fa-solid fa-circle-info"></i>
                            Thông tin Chi tiết Sản phẩm & Danh mục
                        </h2>

                        <table class="specs-table">
                            <tr>
                                <th>Mã sản phẩm</th>
                                <td>
                                    <span class="code-pill"><c:out value="${product.productCode}"/></span>
                                </td>
                            </tr>
                            <tr>
                                <th>Tên sản phẩm</th>
                                <td>
                                    <strong><c:out value="${product.productName}"/></strong>
                                </td>
                            </tr>
                            <tr>
                                <th>Hình thức kinh doanh</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${product.productType == 'SUBSCRIPTION'}">
                                            Dịch vụ thuê bao định kỳ (Subscription)
                                        </c:when>
                                        <c:otherwise>
                                            Sản phẩm một lần (One-time Sale)
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <tr>
                                <th>Đơn vị tính (ĐVT)</th>
                                <td><c:out value="${product.unit}"/></td>
                            </tr>
                            <tr>
                                <th>Bảng giá niêm yết chuẩn</th>
                                <td>
                                    <span style="font-weight: 700; color: var(--crm-primary); font-size: 15px;">
                                        <fmt:formatNumber value="${product.listPrice}" type="currency" currencySymbol="VNĐ"/>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Giá sàn (Ngưỡng chiết khấu)</th>
                                <td>
                                    <span style="font-weight: 700; color: #d97706; font-size: 15px;">
                                        <fmt:formatNumber value="${product.floorPrice}" type="currency" currencySymbol="VNĐ"/>
                                    </span>
                                    <span style="font-size: 12px; color: var(--crm-text-muted); margin-left: 8px;">
                                        (Ngưỡng xác định báo giá có cần duyệt chiết khấu)
                                    </span>
                                </td>
                            </tr>
                            <c:if test="${canAccessCostPrice}">
                                <tr>
                                    <th>Giá vốn (Cost Price)</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${product.costPrice != null}">
                                                <span style="font-weight: 700; color: #7c3aed; font-size: 15px;">
                                                    <fmt:formatNumber value="${product.costPrice}" type="currency" currencySymbol="VNĐ"/>
                                                </span>
                                                <span style="font-size: 11.5px; background: #faf5ff; color: #7c3aed; padding: 2px 8px; border-radius: 4px; margin-left: 8px; border: 1px solid #e9d5ff;">
                                                    <i class="fa-solid fa-lock"></i> Chỉ Giám đốc kinh doanh xem và sửa
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--crm-text-muted);">Chưa khai báo</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:if>
                            <tr>
                                <th>Trạng thái hoạt động</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${product.status == 'ACTIVE'}">
                                            <span class="status-badge active"><i class="fa-solid fa-circle-check"></i> Đang kinh doanh (ACTIVE)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge inactive"><i class="fa-solid fa-ban"></i> Ngừng kinh doanh (INACTIVE)</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <c:if test="${not empty product.createdAt}">
                                <tr>
                                    <th>Thời điểm khởi tạo</th>
                                    <td><fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                </tr>
                            </c:if>
                            <c:if test="${not empty product.updatedAt}">
                                <tr>
                                    <th>Cập nhật lần cuối</th>
                                    <td><fmt:formatDate value="${product.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                </tr>
                            </c:if>
                        </table>
                    </div>
                </div>

                <!-- Right: Rules & Business Guardrails -->
                <div class="detail-sidebar-col">
                    <div class="exec-card" style="background: #eff6ff; border-color: #bfdbfe;">
                        <h2 class="exec-card-title" style="color: #1e3a8a; border-bottom-color: #bfdbfe;">
                            <i class="fa-solid fa-shield-halved"></i>
                            Quy chế Quản lý Bảng giá CRM
                        </h2>

                        <div class="policy-item">
                            <i class="fa-solid fa-file-invoice-dollar"></i>
                            <div>
                                <strong>Giá niêm yết chuẩn:</strong>
                                Khi lập báo giá, đơn giá của sản phẩm này tự động tải từ bảng giá niêm yết chuẩn, loại bỏ hoàn toàn việc nhân viên tự nghĩ ra giá.
                            </div>
                        </div>

                        <div class="policy-item">
                            <i class="fa-solid fa-hand-holding-dollar"></i>
                            <div>
                                <strong>Ngưỡng Giá sàn duyệt chiết khấu:</strong>
                                Bất kỳ mức chiết khấu nào khiến đơn giá thấp hơn <strong><fmt:formatNumber value="${product.floorPrice}" type="currency" currencySymbol="₫"/></strong> đều tự động bị chặn và chuyển sang luồng trình Giám đốc kinh doanh phê duyệt.
                            </div>
                        </div>

                        <div class="policy-item">
                            <i class="fa-solid fa-database"></i>
                            <div>
                                <strong>Quy định bảo toàn dữ liệu:</strong>
                                Sản phẩm đã từng xuất hiện trong bất kỳ báo giá hoặc cơ hội nào sẽ được khóa vĩnh viễn không thể xóa. Để tạm dừng phân phối, Giám đốc chuyển sang <strong>Ngừng kinh doanh</strong>.
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </div>
    </main>
</div>

<!-- Action Scripts -->
<script>
    function toggleCurrentStatus() {
        var currentStatus = '${product.status}';
        var isCurrentlyActive = (currentStatus === 'ACTIVE');
        var newStatus = isCurrentlyActive ? 'INACTIVE' : 'ACTIVE';
        var actionText = isCurrentlyActive ? 'NGỪNG KINH DOANH' : 'KÍCH HOẠT LẠI';
        var confirmMsg = 'Bạn có chắc chắn muốn ' + actionText + ' sản phẩm:\n"<c:out value="${product.productName}"/>"?\n\n' +
            (isCurrentlyActive 
                ? '• Khi ngừng kinh doanh, nhân viên kinh doanh sẽ không thể chọn sản phẩm này trong các báo giá mới.' 
                : '• Sản phẩm sẽ mở bán lại bình thường trong bảng giá.');

        if (!confirm(confirmMsg)) return;

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/products/status';

        var inputId = document.createElement('input');
        inputId.type = 'hidden';
        inputId.name = 'productId';
        inputId.value = '${product.productId}';
        form.appendChild(inputId);

        var inputStatus = document.createElement('input');
        inputStatus.type = 'hidden';
        inputStatus.name = 'status';
        inputStatus.value = newStatus;
        form.appendChild(inputStatus);

        document.body.appendChild(form);
        form.submit();
    }

    function deleteCurrentProduct() {
        var warningMsg = 'XÁC NHẬN XÓA SẢN PHẨM: "<c:out value="${product.productName}"/>"\n\n' +
            '⚠️ QUY ĐỊNH BẢO VỆ DỮ LIỆU BÁO GIÁ CRM:\n' +
            '• Nếu sản phẩm này ĐÃ TỪNG XUẤT HIỆN trong bất kỳ báo giá hoặc cơ hội nào, hệ thống sẽ NGĂN CHẶN XÓA để bảo toàn lịch sử số liệu.\n' +
            '• Khi đó bạn chỉ có thể chọn "Ngừng kinh doanh".\n\n' +
            'Bạn có chắc chắn muốn tiến hành xóa không?';

        if (!confirm(warningMsg)) return;

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
