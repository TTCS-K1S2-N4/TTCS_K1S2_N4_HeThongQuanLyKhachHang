<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa Lead: <c:out value="${lead.fullName}"/> | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/campaigns.css">
    <style>
        .lead-edit-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 10px 20px 48px 20px;
        }

        .exec-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.85rem;
            color: #64748b;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .exec-breadcrumb a {
            color: #475569;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-weight: 500;
            transition: color 0.15s ease;
        }

        .exec-breadcrumb a:hover {
            color: #1e40af;
        }

        .exec-breadcrumb .sep {
            color: #cbd5e1;
            font-size: 0.75rem;
        }

        .lead-edit-hero {
            background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 50%, #172554 100%);
            border-radius: 16px;
            padding: 24px 28px;
            color: #ffffff;
            margin-bottom: 24px;
            box-shadow: 0 10px 25px -3px rgba(30, 58, 138, 0.12);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            position: relative;
            overflow: hidden;
        }

        .lead-edit-hero::after {
            content: '';
            position: absolute;
            top: -60px;
            right: -60px;
            width: 200px;
            height: 200px;
            background: radial-gradient(circle, rgba(217, 119, 6, 0.22) 0%, rgba(255,255,255,0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }

        .lead-edit-hero-left {
            display: flex;
            align-items: center;
            gap: 16px;
            z-index: 1;
        }

        .lead-edit-avatar {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            background: #eff6ff;
            color: #1e40af;
            font-size: 22px;
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #bfdbfe;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            flex-shrink: 0;
        }

        .lead-edit-hero-title h1 {
            font-size: 22px;
            font-weight: 800;
            margin: 0 0 4px 0;
            color: #ffffff;
            letter-spacing: -0.02em;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .lead-edit-hero-title p {
            margin: 0;
            color: #cbd5e1;
            font-size: 13px;
        }

        .lead-edit-badge {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.25);
            color: #ffffff;
            padding: 3px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }

        .lead-edit-form-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            margin-bottom: 30px;
        }

        .form-section {
            padding: 24px 28px;
            border-bottom: 1px solid #f1f5f9;
        }

        .form-section:last-of-type {
            border-bottom: none;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .section-header-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .icon-blue { background: #eff6ff; color: #2563eb; }
        .icon-purple { background: #faf5ff; color: #9333ea; }
        .icon-amber { background: #fffbeb; color: #d97706; }
        .icon-emerald { background: #ecfdf5; color: #059669; }

        .section-header-text h3 {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
            margin: 0 0 2px 0;
        }

        .section-header-text p {
            font-size: 12px;
            color: #64748b;
            margin: 0;
        }

        .form-grid-2 {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px 24px;
        }

        .form-grid-3 {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px 24px;
        }

        @media (max-width: 868px) {
            .form-grid-2, .form-grid-3 {
                grid-template-columns: 1fr;
            }
        }

        .form-col-full {
            grid-column: 1 / -1;
        }

        .form-field-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-field-group label {
            font-size: 13px;
            font-weight: 600;
            color: #334155;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .required-star {
            color: #dc2626;
            font-weight: bold;
        }

        .field-input, .field-select, .field-textarea {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #cbd5e1;
            border-radius: 9px;
            padding: 9px 13px;
            font-size: 13.5px;
            color: #0f172a;
            background-color: #ffffff;
            transition: all 0.2s ease;
            outline: none;
            font-family: inherit;
        }

        .field-input:focus, .field-select:focus, .field-textarea:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .field-hint {
            font-size: 11.5px;
            color: #64748b;
        }

        .form-footer-actions {
            background: #f8fafc;
            padding: 20px 28px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-cancel-edit {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            border-radius: 9px;
            font-size: 13.5px;
            font-weight: 600;
            color: #475569;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .btn-cancel-edit:hover {
            background: #f1f5f9;
            color: #1e293b;
        }

        .btn-save-lead {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 24px;
            border-radius: 9px;
            font-size: 13.5px;
            font-weight: 600;
            color: #ffffff;
            background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 100%);
            border: none;
            box-shadow: 0 2px 4px rgba(37, 99, 235, 0.25);
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-save-lead:hover {
            background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%);
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.35);
            transform: translateY(-1px);
        }

        .toast-banner-edit {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-left: 4px solid #ef4444;
            color: #991b1b;
            padding: 14px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 13.5px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
    </style>
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="lead-edit-container">
                <!-- Breadcrumbs -->
                <nav class="exec-breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa fa-home"></i> Trang chủ</a>
                    <span class="sep"><i class="fa fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/leads"><i class="fa fa-users"></i> Quản lý Lead</a>
                    <span class="sep"><i class="fa fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}">Hồ sơ #${lead.leadId}</a>
                    <span class="sep"><i class="fa fa-chevron-right"></i></span>
                    <span style="color: #0f172a; font-weight: 600;">Chỉnh sửa hồ sơ</span>
                </nav>

                <!-- Toast Error Notification -->
                <c:if test="${not empty error or not empty errorMessage}">
                    <div class="toast-banner-edit">
                        <div>
                            <i class="fa fa-triangle-exclamation" style="margin-right: 8px;"></i>
                            <c:out value="${not empty error ? error : errorMessage}"/>
                        </div>
                        <button type="button" style="background: none; border: none; font-size: 18px; cursor: pointer; color: #991b1b;" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>

                <!-- Hero Header Banner -->
                <div class="lead-edit-hero">
                    <div class="lead-edit-hero-left">
                        <div class="lead-edit-avatar">
                            <c:out value="${not empty lead.fullName ? lead.fullName.substring(0, 1).toUpperCase() : 'L'}"/>
                        </div>
                        <div class="lead-edit-hero-title">
                            <h1>
                                Chỉnh sửa Lead: <c:out value="${lead.fullName}"/>
                                <span class="lead-edit-badge">ID: #${lead.leadId}</span>
                            </h1>
                            <p>
                                <c:out value="${not empty lead.title ? lead.title : 'Đầu mối kinh doanh'}"/>
                                <c:if test="${not empty lead.company}"> &bull; <c:out value="${lead.company}"/></c:if>
                            </p>
                        </div>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}" class="btn-cancel-edit" style="background: rgba(255,255,255,0.15); color: #ffffff; border-color: rgba(255,255,255,0.3);">
                            <i class="fa fa-arrow-left"></i> Quay lại chi tiết
                        </a>
                    </div>
                </div>

                <!-- Main Form Card -->
                <div class="lead-edit-form-card">
                    <form action="${pageContext.request.contextPath}/leads/edit" method="post" id="leadEditForm">
                        <input type="hidden" name="id" value="${lead.leadId}">
                        <input type="hidden" name="state" value="${not empty param.state ? param.state : lead.state}">
                        <input type="hidden" name="country" value="${not empty param.country ? param.country : lead.country}">
                        <input type="hidden" name="zipCode" value="${not empty param.zipCode ? param.zipCode : lead.zipCode}">

                        <!-- SECTION 1: CONTACT & IDENTITY -->
                        <div class="form-section">
                            <div class="section-header">
                                <div class="section-header-icon icon-blue">
                                    <i class="fa fa-id-card"></i>
                                </div>
                                <div class="section-header-text">
                                    <h3>1. Thông tin cá nhân & Doanh nghiệp</h3>
                                    <p>Các trường thông tin liên lạc cốt lõi của đầu mối tiềm năng</p>
                                </div>
                            </div>

                            <div class="form-grid-2">
                                <div class="form-field-group">
                                    <label for="fullName">Họ và tên khách hàng <span class="required-star">*</span></label>
                                    <input type="text" id="fullName" name="fullName" class="field-input"
                                           value="<c:out value='${not empty param.fullName ? param.fullName : lead.fullName}'/>"
                                           placeholder="Ví dụ: Nguyễn Anh Tuấn" required>
                                </div>

                                <div class="form-field-group">
                                    <label for="title">Chức danh / Vị trí</label>
                                    <input type="text" id="title" name="title" class="field-input"
                                           value="<c:out value='${not empty param.title ? param.title : lead.title}'/>"
                                           placeholder="Ví dụ: Giám đốc kinh doanh, Trưởng phòng CNTT">
                                </div>

                                <div class="form-field-group">
                                    <label for="company">Tên công ty / Doanh nghiệp</label>
                                    <input type="text" id="company" name="company" class="field-input"
                                           value="<c:out value='${not empty param.company ? param.company : lead.company}'/>"
                                           placeholder="Ví dụ: Công ty CP Giải Pháp Phần Mềm Nova">
                                </div>

                                <div class="form-field-group">
                                    <label for="industry">Lĩnh vực hoạt động</label>
                                    <input type="text" id="industry" name="industry" class="field-input"
                                           value="<c:out value='${not empty param.industry ? param.industry : lead.industry}'/>"
                                           placeholder="Ví dụ: Công nghệ thông tin, Bán lẻ, Giáo dục...">
                                </div>

                                <div class="form-field-group">
                                    <label for="email">Địa chỉ Email</label>
                                    <input type="email" id="email" name="email" class="field-input"
                                           value="<c:out value='${not empty param.email ? param.email : lead.email}'/>"
                                           placeholder="Ví dụ: tuan.nguyen@novasoft.vn">
                                </div>

                                <div class="form-field-group">
                                    <label for="phone">Số điện thoại liên hệ</label>
                                    <input type="text" id="phone" name="phone" class="field-input"
                                           value="<c:out value='${not empty param.phone ? param.phone : lead.phone}'/>"
                                           placeholder="Ví dụ: 0912345678">
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 2: MARKETING ATTRIBUTION & CAMPAIGN -->
                        <div class="form-section">
                            <div class="section-header">
                                <div class="section-header-icon icon-purple">
                                    <i class="fa fa-bullhorn"></i>
                                </div>
                                <div class="section-header-text">
                                    <h3>2. Nguồn gốc Marketing & Chiến dịch tiếp thị</h3>
                                    <p>Xác định kênh thu hút và chiến dịch mang lại cơ hội kinh doanh này</p>
                                </div>
                            </div>

                            <div class="form-grid-2">
                                <div class="form-field-group">
                                    <label for="leadSourceId">Nguồn tiếp cận Lead <span class="required-star">*</span></label>
                                    <select id="leadSourceId" name="leadSourceId" class="field-select" required>
                                        <option value="">-- Chọn nguồn tiếp cận --</option>
                                        <c:forEach var="src" items="${sources}">
                                            <option value="${src.sourceId}" ${(not empty param.leadSourceId ? param.leadSourceId : lead.leadSourceId) == src.sourceId ? 'selected' : ''}>
                                                <c:out value="${src.sourceName}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <span class="field-hint">Kênh ban đầu tiếp cận đầu mối (Website, Hotline, Sự kiện...)</span>
                                </div>

                                <div class="form-field-group">
                                    <label for="campaignId">Chiến dịch Marketing liên kết</label>
                                    <select id="campaignId" name="campaignId" class="field-select">
                                        <option value="">-- Không gắn chiến dịch tiếp thị --</option>
                                        <c:forEach var="cp" items="${campaigns}">
                                            <option value="${cp.campaignId}" ${(not empty param.campaignId ? param.campaignId : lead.campaignId) == cp.campaignId ? 'selected' : ''}>
                                                <c:out value="${cp.campaignName}"/> (<c:out value="${cp.channel}"/>)
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <span class="field-hint">Giúp đo lường ROI chuyển đổi và hiệu quả doanh thu theo từng chiến dịch</span>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 3: QUALIFICATION & ASSIGNMENT -->
                        <div class="form-section">
                            <div class="section-header">
                                <div class="section-header-icon icon-amber">
                                    <i class="fa fa-sliders"></i>
                                </div>
                                <div class="section-header-text">
                                    <h3>3. Phân loại bán hàng & Phân bổ phụ trách</h3>
                                    <p>Trạng thái phễu kinh doanh, nhiệt độ quan tâm và chuyên viên phụ trách</p>
                                </div>
                            </div>

                            <div class="form-grid-3">
                                <div class="form-field-group">
                                    <label for="status">Trạng thái xử lý Lead</label>
                                    <select id="status" name="status" class="field-select">
                                        <c:set var="curStatus" value="${not empty param.status ? param.status : lead.status}"/>
                                        <option value="NEW" ${curStatus eq 'NEW' ? 'selected' : ''}>Mới tạo (NEW)</option>
                                        <option value="CONTACTED" ${curStatus eq 'CONTACTED' ? 'selected' : ''}>Đang liên hệ (CONTACTED)</option>
                                        <option value="QUALIFIED" ${curStatus eq 'QUALIFIED' ? 'selected' : ''}>Đã xác định nhu cầu (QUALIFIED)</option>
                                        <option value="IN_PROGRESS" ${curStatus eq 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý (IN_PROGRESS)</option>
                                        <option value="ASSIGNED" ${curStatus eq 'ASSIGNED' ? 'selected' : ''}>Đã phân bổ (ASSIGNED)</option>
                                        <option value="UNQUALIFIED" ${curStatus eq 'UNQUALIFIED' ? 'selected' : ''}>Không tiềm năng (UNQUALIFIED)</option>
                                        <option value="CONVERTED" ${curStatus eq 'CONVERTED' ? 'selected' : ''}>Đã chuyển đổi (CONVERTED)</option>
                                    </select>
                                </div>

                                <div class="form-field-group">
                                    <label for="rating">Mức độ nhiệt tình (Rating)</label>
                                    <select id="rating" name="rating" class="field-select">
                                        <c:set var="curRating" value="${not empty param.rating ? param.rating : lead.rating}"/>
                                        <option value="HOT" ${curRating eq 'HOT' ? 'selected' : ''}>🔥 NÓNG (HOT - Khả năng chốt cao)</option>
                                        <option value="WARM" ${curRating eq 'WARM' ? 'selected' : ''}>⚡ ẤM (WARM - Đang cân nhắc)</option>
                                        <option value="COLD" ${curRating eq 'COLD' ? 'selected' : ''}>❄️ LẠNH (COLD - Nuôi dưỡng lâu dài)</option>
                                    </select>
                                </div>

                                <div class="form-field-group">
                                    <label for="ownerId">Chuyên viên phụ trách</label>
                                    <select id="ownerId" name="ownerId" class="field-select">
                                        <option value="">-- Chưa phân bổ nhân sự --</option>
                                        <c:forEach var="acc" items="${accounts}">
                                            <option value="${acc.accountId}" ${(not empty param.ownerId ? param.ownerId : lead.ownerId) == acc.accountId ? 'selected' : ''}>
                                                <c:out value="${acc.fullName}"/> (<c:out value="${acc.email}"/>)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 4: LOCATION & NOTES -->
                        <div class="form-section">
                            <div class="section-header">
                                <div class="section-header-icon icon-emerald">
                                    <i class="fa fa-location-dot"></i>
                                </div>
                                <div class="section-header-text">
                                    <h3>4. Địa chỉ liên hệ & Nhu cầu tư vấn</h3>
                                    <p>Địa bàn hoạt động và thông tin nhu cầu mua hàng của khách</p>
                                </div>
                            </div>

                            <div class="form-grid-2">
                                <div class="form-field-group">
                                    <label for="address">Địa chỉ trụ sở / văn phòng</label>
                                    <input type="text" id="address" name="address" class="field-input"
                                           value="<c:out value='${not empty param.address ? param.address : lead.address}'/>"
                                           placeholder="Ví dụ: Tầng 6, Tòa nhà Nova Tower, Duy Tân">
                                </div>

                                <div class="form-field-group">
                                    <label for="city">Tỉnh / Thành phố</label>
                                    <input type="text" id="city" name="city" class="field-input"
                                           value="<c:out value='${not empty param.city ? param.city : lead.city}'/>"
                                           placeholder="Ví dụ: Hà Nội, TP. Hồ Chí Minh, Đà Nẵng">
                                </div>

                                <div class="form-field-group form-col-full">
                                    <label for="notes">Nhu cầu quan tâm & Ghi chú tư vấn</label>
                                    <textarea id="notes" name="notes" class="field-textarea" rows="4"
                                              placeholder="Mô tả cụ thể bài toán khách hàng cần giải quyết, quy mô nhân sự, ngân sách dự kiến, thời hạn triển khai..."><c:out value="${not empty param.notes ? param.notes : lead.notes}"/></textarea>
                                </div>
                            </div>
                        </div>

                        <!-- FORM ACTIONS FOOTER -->
                        <div class="form-footer-actions">
                            <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}" class="btn-cancel-edit">
                                <i class="fa fa-xmark"></i> Hủy bỏ
                            </a>
                            <button type="submit" class="btn-save-lead">
                                <i class="fa fa-floppy-disk"></i> Lưu thay đổi hồ sơ Lead
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
