<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết Lead: <c:out value="${not empty lead.fullName ? lead.fullName : 'CRM'}"/> | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
    <style>
        .lead-detail-container {
            max-width: 1320px;
            margin: 0 auto;
            padding: 10px 20px 48px 20px;
        }
        .lead-detail-hero {
            background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 50%, #172554 100%);
            border-radius: 16px;
            padding: 28px 32px;
            color: #ffffff;
            margin-bottom: 24px;
            box-shadow: 0 10px 25px -3px rgba(30, 58, 138, 0.12);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            overflow: hidden;
        }
        .lead-detail-hero::after {
            content: '';
            position: absolute;
            top: -60px;
            right: -60px;
            width: 220px;
            height: 220px;
            background: radial-gradient(circle, rgba(217, 119, 6, 0.22) 0%, rgba(255,255,255,0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }
        .hero-left-content {
            display: flex;
            align-items: center;
            gap: 20px;
            z-index: 1;
        }
        .lead-avatar-circle {
            width: 64px;
            height: 64px;
            border-radius: 16px;
            background: #eff6ff;
            color: #1e40af;
            font-size: 24px;
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #bfdbfe;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            flex-shrink: 0;
        }
        .lead-title-area h1 {
            font-size: 24px;
            font-weight: 800;
            margin: 0 0 6px 0;
            color: #ffffff;
            letter-spacing: -0.02em;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .lead-meta-sub {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #cbd5e1;
            font-size: 13px;
            flex-wrap: wrap;
        }
        .lead-hero-badges {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 10px;
            flex-wrap: wrap;
        }
        .hero-action-buttons {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            z-index: 2;
        }
        .btn-hero-primary {
            background: linear-gradient(135deg, #d97706 0%, #b45309 100%);
            color: #ffffff !important;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 2px 6px rgba(180, 83, 9, 0.35);
            transition: all 0.2s ease;
        }
        .btn-hero-primary:hover {
            background: linear-gradient(135deg, #b45309 0%, #92400e 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(180, 83, 9, 0.45);
        }
        .btn-hero-secondary {
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.25);
            padding: 10px 18px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
        }
        .btn-hero-secondary:hover {
            background: rgba(255, 255, 255, 0.22);
            border-color: rgba(255, 255, 255, 0.4);
        }
        .lead-kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .lead-kpi-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px 20px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .lead-kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.06);
        }
        .lead-kpi-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }
        .kpi-icon-blue { background: #eff6ff; color: #1d4ed8; }
        .kpi-icon-amber { background: #fffbeb; color: #b45309; }
        .kpi-icon-emerald { background: #ecfdf5; color: #047857; }
        .kpi-icon-purple { background: #f3e8ff; color: #6b21a8; }
        .lead-kpi-data {
            display: flex;
            flex-direction: column;
        }
        .lead-kpi-title {
            font-size: 11px;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 3px;
        }
        .lead-kpi-number {
            font-size: 18px;
            font-weight: 800;
            color: #0f172a;
            line-height: 1.2;
        }
        .lead-kpi-sub {
            font-size: 11px;
            color: #64748b;
            margin-top: 2px;
        }
        .lead-detail-columns {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }
        .lead-section-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }
        .lead-section-header {
            padding: 16px 22px;
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .lead-section-header h3 {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .lead-section-body {
            padding: 22px;
            flex: 1;
        }
        .lead-field-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .lead-field-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 12px;
        }
        .lead-field-item:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }
        .lead-field-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
        }
        .lead-field-val {
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .lead-field-val a {
            color: #2563eb;
            text-decoration: none;
            transition: color 0.15s;
        }
        .lead-field-val a:hover {
            color: #1d4ed8;
            text-decoration: underline;
        }
        .campaign-pill-box {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            color: #1e40af;
            padding: 8px 14px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .campaign-pill-box:hover {
            background: #dbeafe;
            border-color: #93c5fd;
            color: #1d4ed8;
        }
        .notes-content-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 16px;
            font-size: 13.5px;
            line-height: 1.6;
            color: #334155;
            white-space: pre-wrap;
        }
        .lead-footer-actions {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 16px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
        }
        @media (max-width: 992px) {
            .lead-kpi-grid { grid-template-columns: repeat(2, 1fr); }
            .lead-detail-columns { grid-template-columns: 1fr; }
        }
        @media (max-width: 576px) {
            .lead-kpi-grid { grid-template-columns: 1fr; }
            .lead-detail-hero { padding: 20px; }
            .hero-left-content { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="lead-detail-container">
                <!-- Breadcrumb Navigation -->
                <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px;">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Quản lý Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Hồ sơ chi tiết #<c:out value="${lead.leadId}"/></span>
                </nav>

                <!-- Toast Notifications -->
                <c:if test="${param.updated == 'true'}">
                    <div class="toast-banner toast-success" style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between;">
                        <div><i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> Cập nhật thông tin Lead thành công!</div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>
                <c:if test="${param.converted == 'true'}">
                    <div class="toast-banner toast-success" style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between;">
                        <div><i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> Chuyển đổi Lead thành Cơ hội thành công!</div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${empty lead or empty lead.leadId}">
                        <div class="lead-section-card" style="text-align: center; padding: 56px 20px;">
                            <div style="font-size: 48px; color: #cbd5e1; margin-bottom: 16px;">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                            <h2 style="font-size: 18px; font-weight: 700; color: #0f172a; margin-bottom: 8px;">Không tìm thấy thông tin Lead</h2>
                            <p style="color: #64748b; margin-bottom: 24px; font-size: 13.5px;">Bản ghi Lead không tồn tại hoặc đã bị xóa khỏi cơ sở dữ liệu hệ thống.</p>
                            <div>
                                <a href="${pageContext.request.contextPath}/leads" class="btn-lead-primary">
                                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách Lead
                                </a>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <!-- Hero Header Banner -->
                        <div class="lead-detail-hero">
                            <div class="hero-left-content">
                                <div class="lead-avatar-circle">
                                    <c:choose>
                                        <c:when test="${not empty lead.fullName}">
                                            ${lead.fullName.substring(0, 1).toUpperCase()}
                                        </c:when>
                                        <c:otherwise>L</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="lead-title-area">
                                    <h1>
                                        <c:out value="${lead.fullName}"/>
                                        <span style="font-size: 14px; font-weight: 600; color: #93c5fd; background: rgba(255,255,255,0.12); padding: 3px 10px; border-radius: 20px;">
                                            #${lead.leadId}
                                        </span>
                                    </h1>
                                    <div class="lead-meta-sub">
                                        <c:if test="${not empty lead.title}">
                                            <span><i class="fa-solid fa-id-badge" style="color: #fbbf24;"></i> <c:out value="${lead.title}"/></span>
                                        </c:if>
                                        <c:if test="${not empty lead.company}">
                                            <span><i class="fa-regular fa-building" style="color: #60a5fa;"></i> <c:out value="${lead.company}"/></span>
                                        </c:if>
                                        <c:if test="${not empty lead.createdAt}">
                                            <span><i class="fa-regular fa-clock" style="color: #cbd5e1;"></i> Tạo ngày: <fmt:formatDate value="${lead.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                        </c:if>
                                    </div>
                                    <div class="lead-hero-badges">
                                        <!-- Status Badge -->
                                        <c:choose>
                                            <c:when test="${lead.status == 'NEW' || lead.status == 'Mới' || lead.status == 'Mới tạo'}">
                                                <span class="lead-status-pill status-new"><span class="lead-status-dot"></span> Mới tạo</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'CONTACTED' || lead.status == 'Đang liên hệ'}">
                                                <span class="lead-status-pill status-contacted"><span class="lead-status-dot"></span> Đang liên hệ</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'QUALIFIED' || lead.status == 'Tiềm năng'}">
                                                <span class="lead-status-pill status-qualified"><span class="lead-status-dot"></span> Đã xác định NC</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'CONVERTED' || lead.status == 'Đã chuyển đổi'}">
                                                <span class="lead-status-pill status-converted"><span class="lead-status-dot"></span> Đã chuyển đổi</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'MERGED'}">
                                                <span class="lead-status-pill" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1;"><span class="lead-status-dot" style="background: #64748b;"></span> Đã gộp (MERGED)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="lead-status-pill status-unqualified"><span class="lead-status-dot"></span> <c:out value="${lead.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Lead Score Badge -->
                                        <c:set var="scoreVal" value="${not empty lead.score ? lead.score : (not empty lead.leadScore ? lead.leadScore : 0)}"/>
                                        <span class="lead-score-badge ${scoreVal >= 70 ? 'score-high' : (scoreVal >= 40 ? 'score-med' : 'score-low')}">
                                            <i class="fa-solid fa-bolt"></i> ${scoreVal} đ
                                        </span>

                                        <!-- Rating Hot/Warm/Cold -->
                                        <c:choose>
                                            <c:when test="${lead.classification == 'HOT' || lead.rating == 'HOT' || scoreVal >= 70}">
                                                <span class="lead-rating-badge rating-hot"><i class="fa-solid fa-fire"></i> NÓNG</span>
                                            </c:when>
                                            <c:when test="${lead.classification == 'WARM' || lead.rating == 'WARM' || (scoreVal >= 40 && scoreVal < 70)}">
                                                <span class="lead-rating-badge rating-warm"><i class="fa-solid fa-sun"></i> ẤM</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="lead-rating-badge rating-cold"><i class="fa-solid fa-snowflake"></i> LẠNH</span>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- SLA Badge -->
                                        <c:choose>
                                            <c:when test="${lead.slaOverdue}">
                                                <span class="lead-sla-badge lead-sla-overdue"><i class="fa-solid fa-triangle-exclamation"></i> Quá SLA</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="lead-sla-ok"><i class="fa-solid fa-circle-check"></i> SLA Trong hạn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <c:set var="isLeadOwner" value="${not empty sessionScope.userId and lead.ownerId == sessionScope.userId}"/>
                            <c:set var="isAdminOrDirector" value="${sessionScope.roleId == 1 or sessionScope.roleId == 4}"/>
                            <c:set var="canActOnLead" value="${isLeadOwner or isAdminOrDirector}"/>
                            <c:set var="canAccept" value="${canActOnLead and (lead.status == 'ASSIGNED' or lead.status == 'OVERDUE')}"/>
                            <c:set var="canReject" value="${canActOnLead and (lead.status == 'ASSIGNED' or lead.status == 'OVERDUE')}"/>
                            <c:set var="canMarkContacted" value="${canActOnLead and lead.status == 'IN_PROGRESS'}"/>

                            <div class="hero-action-buttons">
                                <c:if test="${canAccept}">
                                    <button type="button" class="btn-hero-primary" style="background: linear-gradient(135deg, #16a34a 0%, #15803d 100%); border: none; cursor: pointer;" onclick="handleAcceptLead(${lead.leadId})">
                                        <i class="fa-solid fa-check"></i> Nhận Lead
                                    </button>
                                </c:if>
                                <c:if test="${canReject}">
                                    <button type="button" class="btn-hero-secondary" style="background: rgba(239, 68, 68, 0.25); border-color: rgba(239, 68, 68, 0.5); color: #fee2e2 !important; cursor: pointer;" onclick="openRejectModal(${lead.leadId})">
                                        <i class="fa-solid fa-xmark"></i> Từ chối Lead
                                    </button>
                                </c:if>
                                <c:if test="${canMarkContacted}">
                                    <button type="button" class="btn-hero-primary" style="background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); border: none; cursor: pointer;" onclick="handleRecordContact(${lead.leadId})">
                                        <i class="fa-solid fa-phone"></i> Ghi nhận liên hệ
                                    </button>
                                </c:if>
                                <c:choose>
                                    <c:when test="${lead.status == 'CONVERTED' or lead.status == 'Đã chuyển đổi'}">
                                        <span style="background: rgba(16, 185, 129, 0.2); border: 1px solid rgba(16, 185, 129, 0.4); color: #10b981; padding: 8px 14px; border-radius: 8px; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px;">
                                            <i class="fa-solid fa-check-double"></i> Đã chuyển đổi (Khóa)
                                        </span>
                                        <c:if test="${lead.convertedCustomerId != null && lead.convertedCustomerId > 0}">
                                            <a href="${pageContext.request.contextPath}/customers/detail?id=${lead.convertedCustomerId}" class="btn-hero-primary" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%);">
                                                <i class="fa-solid fa-building"></i> Xem Khách hàng
                                            </a>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/leads/edit?id=${lead.leadId}" class="btn-hero-primary" id="btn-edit-lead">
                                            <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa Lead
                                        </a>
                                        <a href="${pageContext.request.contextPath}/leads/convert?leadId=${lead.leadId}" class="btn-hero-secondary">
                                            <i class="fa-solid fa-arrow-right-arrow-left"></i> Chuyển đổi Cơ hội
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                                <a href="${pageContext.request.contextPath}/leads" class="btn-hero-secondary">
                                    <i class="fa-solid fa-arrow-left"></i> Danh sách
                                </a>
                            </div>
                        </div>

                        <!-- Converted Status Banner Notice -->
                        <c:if test="${lead.status == 'CONVERTED' or lead.status == 'Đã chuyển đổi'}">
                            <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-left: 5px solid #16a34a; border-radius: 12px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; gap: 16px; box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);">
                                <div style="display: flex; align-items: center; gap: 12px; color: #166534;">
                                    <i class="fa-solid fa-circle-check" style="font-size: 24px; color: #16a34a;"></i>
                                    <div>
                                        <strong style="font-size: 14.5px; color: #14532d;">Bản ghi Lead này đã được CHUYỂN ĐỔI (CONVERTED)</strong>
                                        <div style="font-size: 13px; color: #15803d; margin-top: 3px;">
                                            Lead đã hoàn tất chuyển đổi thành Khách hàng, Người liên hệ và Cơ hội kinh doanh. Để đảm bảo tính toàn vẹn dữ liệu, bản ghi Lead được bảo toàn và khóa chỉnh sửa.
                                        </div>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <c:if test="${lead.convertedCustomerId != null && lead.convertedCustomerId > 0}">
                                        <a href="${pageContext.request.contextPath}/customers/detail?id=${lead.convertedCustomerId}" style="background: #16a34a; border: none; color: white; padding: 8px 14px; border-radius: 8px; font-weight: 600; font-size: 12.5px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                                            <i class="fa-solid fa-building"></i> Xem Khách hàng
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${param.error == 'converted_locked'}">
                            <div style="background: #fef2f2; border: 1px solid #fecaca; border-left: 5px solid #ef4444; border-radius: 12px; padding: 14px 18px; margin-bottom: 20px; color: #991b1b; font-weight: 600; display: flex; align-items: center; gap: 10px;">
                                <i class="fa-solid fa-lock" style="font-size: 18px;"></i>
                                <span>Lead đã được chuyển đổi (CONVERTED) nên không thể chỉnh sửa thông tin.</span>
                            </div>
                        </c:if>

                        <!-- SLA Overdue Warning Notice -->
                        <c:if test="${lead.slaOverdue}">
                            <div style="background: #fef2f2; border: 1px solid #fecaca; border-left: 5px solid #ef4444; border-radius: 12px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; gap: 16px; box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);">
                                <div style="display: flex; align-items: center; gap: 12px; color: #b91c1c;">
                                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 24px; color: #dc2626;"></i>
                                    <div>
                                        <strong style="font-size: 14.5px; color: #991b1b;">CẢNH BÁO: Lead đã quá hạn phản hồi theo SLA (Response SLA Breach)</strong>
                                        <div style="font-size: 13px; color: #7f1d1d; margin-top: 3px;">
                                            Lead này đã vượt quá thời hạn SLA quy định mà chưa có hoạt động liên hệ khách hàng thực tế. Hệ thống đã tự động gửi thông báo tới Trưởng nhóm phụ trách.
                                        </div>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <c:if test="${canAccept}">
                                        <button type="button" style="background: #16a34a; border: none; color: white; padding: 8px 14px; border-radius: 8px; font-weight: 600; font-size: 12.5px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;" onclick="handleAcceptLead(${lead.leadId})">
                                            <i class="fa-solid fa-check"></i> Nhận Lead ngay
                                        </button>
                                    </c:if>
                                    <c:if test="${canMarkContacted}">
                                        <button type="button" style="background: #0284c7; border: none; color: white; padding: 8px 14px; border-radius: 8px; font-weight: 600; font-size: 12.5px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;" onclick="handleRecordContact(${lead.leadId})">
                                            <i class="fa-solid fa-phone"></i> Ghi nhận liên hệ ngay
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>

                        <!-- Merged Audit Banner Notice -->
                        <c:if test="${lead.status == 'MERGED'}">
                            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; gap: 16px; box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);">
                                <div style="display: flex; align-items: center; gap: 12px; color: #b45309;">
                                    <i class="fa-solid fa-box-archive" style="font-size: 22px;"></i>
                                    <div>
                                        <strong style="font-size: 14px; color: #92400e;">Bản ghi Lead này đã được GỘP (MERGED)</strong>
                                        <div style="font-size: 13px; color: #78350f; margin-top: 2px;">Toàn bộ lịch sử hoạt động và ghi chú đã được chuyển sang bản ghi Lead chính. Bản ghi này được bảo toàn trong cơ sở dữ liệu để phục vụ kiểm toán.</div>
                                    </div>
                                </div>
                                <div>
                                    <a href="${pageContext.request.contextPath}/leads/duplicates" class="btn-lead-primary" style="background: #d97706; padding: 7px 16px; font-size: 13px; border-radius: 8px; text-decoration: none; color: white; display: inline-flex; align-items: center; gap: 6px;">
                                        <i class="fa-solid fa-clone"></i> Danh sách trùng lặp
                                    </a>
                                </div>
                            </div>
                        </c:if>

                        <!-- 4 Quick KPI Summary Cards -->
                        <div class="lead-kpi-grid">
                            <div class="lead-kpi-card">
                                <div class="lead-kpi-icon kpi-icon-amber">
                                    <i class="fa-solid fa-bolt"></i>
                                </div>
                                <div class="lead-kpi-data">
                                    <span class="lead-kpi-title">Điểm số ưu tiên</span>
                                    <span class="lead-kpi-number">${scoreVal} điểm</span>
                                    <span class="lead-kpi-sub">
                                        <c:choose>
                                            <c:when test="${scoreVal >= 70}">Mức độ: Rất tiềm năng</c:when>
                                            <c:when test="${scoreVal >= 40}">Mức độ: Cần chăm sóc</c:when>
                                            <c:otherwise>Mức độ: Nuôi dưỡng dài hạn</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>

                            <div class="lead-kpi-card">
                                <div class="lead-kpi-icon kpi-icon-blue">
                                    <i class="fa-solid fa-bullhorn"></i>
                                </div>
                                <div class="lead-kpi-data">
                                    <span class="lead-kpi-title">Chiến dịch tiếp thị</span>
                                    <span class="lead-kpi-number" style="font-size: 15px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 200px;">
                                        <c:choose>
                                            <c:when test="${not empty lead.campaignName}">
                                                <c:out value="${lead.campaignName}"/>
                                            </c:when>
                                            <c:otherwise>Chưa liên kết</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="lead-kpi-sub">Nguồn: <c:out value="${not empty lead.sourceName ? lead.sourceName : 'Trực tiếp'}"/></span>
                                </div>
                            </div>

                            <div class="lead-kpi-card">
                                <div class="lead-kpi-icon kpi-icon-purple">
                                    <i class="fa-solid fa-user-tie"></i>
                                </div>
                                <div class="lead-kpi-data">
                                    <span class="lead-kpi-title">Người phụ trách</span>
                                    <span class="lead-kpi-number" style="font-size: 15px;">
                                        <c:out value="${not empty lead.ownerName ? lead.ownerName : 'Chưa phân bổ'}"/>
                                    </span>
                                    <span class="lead-kpi-sub">Phụ trách tiếp cận & chốt sales</span>
                                </div>
                            </div>

                            <div class="lead-kpi-card">
                                <div class="lead-kpi-icon kpi-icon-emerald">
                                    <i class="fa-solid fa-clock-rotate-left"></i>
                                </div>
                                <div class="lead-kpi-data">
                                    <span class="lead-kpi-title">Tình trạng SLA</span>
                                    <span class="lead-kpi-number" style="font-size: 15px;">
                                        <c:choose>
                                            <c:when test="${lead.slaOverdue}"><span style="color: #dc2626;">Quá hạn SLA</span></c:when>
                                            <c:otherwise><span style="color: #047857;">Trong hạn quy định</span></c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="lead-kpi-sub">Thời hạn phản hồi khách hàng</span>
                                </div>
                            </div>
                        </div>

                        <!-- 2-Column Detail Cards Grid -->
                        <div class="lead-detail-columns">
                            <!-- Left Column: Identity & Contact Info -->
                            <div class="lead-section-card">
                                <div class="lead-section-header">
                                    <h3><i class="fa-solid fa-address-card" style="color: #2563eb;"></i> Thông tin liên hệ & Doanh nghiệp</h3>
                                    <a href="${pageContext.request.contextPath}/leads/edit?id=${lead.leadId}" style="color: #2563eb; font-size: 12.5px; font-weight: 600; text-decoration: none;">
                                        <i class="fa-solid fa-pen-to-square"></i> Sửa
                                    </a>
                                </div>
                                <div class="lead-section-body">
                                    <div class="lead-field-list">
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Họ và tên khách hàng</span>
                                            <span class="lead-field-val"><c:out value="${lead.fullName}"/></span>
                                        </div>
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Chức danh / Vị trí</span>
                                            <span class="lead-field-val"><c:out value="${not empty lead.title ? lead.title : '-'}"/></span>
                                        </div>
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Công ty / Tổ chức</span>
                                            <span class="lead-field-val">
                                                <i class="fa-regular fa-building" style="color: #64748b;"></i>
                                                <c:out value="${not empty lead.company ? lead.company : '-'}"/>
                                            </span>
                                        </div>
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Hộp thư điện tử (Email)</span>
                                            <span class="lead-field-val">
                                                <c:choose>
                                                    <c:when test="${not empty lead.email}">
                                                        <i class="fa-regular fa-envelope" style="color: #2563eb;"></i>
                                                        <a href="mailto:${lead.email}"><c:out value="${lead.email}"/></a>
                                                    </c:when>
                                                    <c:otherwise><span style="color: #94a3b8;">Chưa cập nhật</span></c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Số điện thoại liên hệ</span>
                                            <span class="lead-field-val">
                                                <c:choose>
                                                    <c:when test="${not empty lead.phone}">
                                                        <i class="fa-solid fa-phone" style="color: #059669;"></i>
                                                        <a href="tel:${lead.phone}"><c:out value="${lead.phone}"/></a>
                                                    </c:when>
                                                    <c:otherwise><span style="color: #94a3b8;">Chưa cập nhật</span></c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Địa chỉ & Khu vực</span>
                                            <span class="lead-field-val">
                                                <i class="fa-solid fa-location-dot" style="color: #64748b;"></i>
                                                <c:choose>
                                                    <c:when test="${not empty lead.address or not empty lead.city or not empty lead.country}">
                                                        <c:if test="${not empty lead.address}"><c:out value="${lead.address}"/></c:if>
                                                        <c:if test="${not empty lead.city}"><c:if test="${not empty lead.address}">, </c:if><c:out value="${lead.city}"/></c:if>
                                                        <c:if test="${not empty lead.country}"><c:if test="${not empty lead.address or not empty lead.city}">, </c:if><c:out value="${lead.country}"/></c:if>
                                                    </c:when>
                                                    <c:otherwise><span style="color: #94a3b8;">Chưa cập nhật</span></c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Column: Marketing & Attribution Info -->
                            <div class="lead-section-card">
                                <div class="lead-section-header">
                                    <h3><i class="fa-solid fa-bullhorn" style="color: #d97706;"></i> Nguồn gốc Marketing & Phân bổ Sales</h3>
                                    <span class="policy-pill" style="font-size: 11px;">
                                        <i class="fa-solid fa-shield-halved"></i> Toàn vẹn nguồn
                                    </span>
                                </div>
                                <div class="lead-section-body">
                                    <div class="lead-field-list">
                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Chiến dịch Marketing liên kết</span>
                                            <div class="lead-field-val" style="margin-top: 4px;">
                                                <c:choose>
                                                    <c:when test="${not empty lead.campaignName}">
                                                        <a href="${pageContext.request.contextPath}/campaigns/detail?id=${lead.campaignId}" class="campaign-pill-box" title="Bấm để xem phân tích ROI chiến dịch">
                                                            <i class="fa-solid fa-bullhorn"></i>
                                                            <span><c:out value="${lead.campaignName}"/></span>
                                                            <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 11px; margin-left: 4px;"></i>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #64748b; font-style: italic;">Chưa gán chiến dịch tiếp thị</span>
                                                        <a href="${pageContext.request.contextPath}/leads/edit?id=${lead.leadId}" style="margin-left: 8px; font-size: 12px; color: #2563eb;">+ Gán chiến dịch</a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Nguồn tiếp nhận đầu vào</span>
                                            <span class="lead-field-val">
                                                <span class="badge" style="background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 12px;">
                                                    <i class="fa-solid fa-share-nodes" style="margin-right: 4px;"></i>
                                                    <c:out value="${not empty lead.sourceName ? lead.sourceName : 'Không xác định'}"/>
                                                </span>
                                            </span>
                                        </div>

                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Nhân sự phụ trách chốt Deal</span>
                                            <span class="lead-field-val">
                                                <i class="fa-solid fa-circle-user" style="color: #2563eb;"></i>
                                                <c:out value="${not empty lead.ownerName ? lead.ownerName : 'Chưa phân bổ nhân sự'}"/>
                                            </span>
                                        </div>

                                        <div class="lead-field-item">
                                            <span class="lead-field-label">Lịch sử cập nhật hệ thống</span>
                                            <span class="lead-field-val" style="font-size: 13px; color: #64748b; font-weight: 500;">
                                                <i class="fa-regular fa-calendar-check"></i>
                                                Tạo lúc: <fmt:formatDate value="${lead.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                <c:if test="${not empty lead.updatedAt}">
                                                    • Cập nhật: <fmt:formatDate value="${lead.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:if>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Full Width Card: Notes & Needs Analysis -->
                        <div class="lead-section-card" style="margin-bottom: 24px;">
                            <div class="lead-section-header">
                                <h3><i class="fa-solid fa-clipboard-list" style="color: #059669;"></i> Nhu cầu khách hàng & Ghi chú tư vấn</h3>
                            </div>
                            <div class="lead-section-body">
                                <c:choose>
                                    <c:when test="${not empty lead.notes}">
                                        <div class="notes-content-box"><c:out value="${lead.notes}"/></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="notes-content-box" style="color: #94a3b8; font-style: italic;">
                                            Chưa có thông tin ghi chú nhu cầu hoặc trao đổi tư vấn ban đầu.
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Bottom Footer Actions Toolbar -->
                        <div class="lead-footer-actions">
                            <a href="${pageContext.request.contextPath}/leads" class="btn-lead-action" style="padding: 10px 18px; border-radius: 8px; border: 1px solid #cbd5e1; background: #ffffff; color: #334155; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
                                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách Lead
                            </a>

                            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                                <c:if test="${canAccept}">
                                    <button type="button" class="btn-hero-primary" style="background: #16a34a; border: none; padding: 10px 18px; font-size: 13.5px; cursor: pointer;" onclick="handleAcceptLead(${lead.leadId})">
                                        <i class="fa-solid fa-check"></i> Nhận Lead
                                    </button>
                                </c:if>
                                <c:if test="${canReject}">
                                    <button type="button" class="btn-lead-action" style="color: #dc2626; border-color: #fca5a5; background: #fff5f5; padding: 10px 18px; font-size: 13.5px; cursor: pointer;" onclick="openRejectModal(${lead.leadId})">
                                        <i class="fa-solid fa-xmark"></i> Từ chối Lead
                                    </button>
                                </c:if>
                                <c:if test="${canMarkContacted}">
                                    <button type="button" class="btn-hero-primary" style="background: #0284c7; border: none; padding: 10px 18px; font-size: 13.5px; cursor: pointer;" onclick="handleRecordContact(${lead.leadId})">
                                        <i class="fa-solid fa-phone"></i> Ghi nhận liên hệ
                                    </button>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/leads/edit?id=${lead.leadId}" class="btn-hero-primary" style="padding: 10px 20px; font-size: 13.5px;">
                                    <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa hồ sơ Lead
                                </a>
                                <a href="${pageContext.request.contextPath}/leads/convert?leadId=${lead.leadId}" class="btn-lead-primary" style="padding: 10px 20px; font-size: 13.5px;">
                                    <i class="fa-solid fa-arrow-right-arrow-left"></i> Chuyển đổi Cơ hội & Khách hàng
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <!-- Modal Từ Chối Lead (S4-07) -->
    <div id="rejectLeadModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); z-index: 9999; align-items: center; justify-content: center;" onclick="if(event.target === this) closeRejectModal();">
        <div style="background: #ffffff; border-radius: 16px; width: 100%; max-width: 520px; padding: 24px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">
                <h3 style="margin: 0; font-size: 17px; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-triangle-exclamation" style="color: #ef4444;"></i> Xác nhận từ chối Lead #<span id="rejectModalLeadIdText"></span>
                </h3>
                <button type="button" onclick="closeRejectModal()" style="border: none; background: transparent; font-size: 22px; color: #64748b; cursor: pointer;">&times;</button>
            </div>
            <form id="rejectLeadForm" onsubmit="submitRejectLead(event)">
                <input type="hidden" id="rejectModalLeadId" name="leadId">
                <div style="margin-bottom: 16px;">
                    <label for="rejectReasonInput" style="display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                        Lý do từ chối Lead <span style="color: #ef4444;">*</span>
                    </label>
                    <textarea id="rejectReasonInput" name="rejectReason" class="form-control" rows="4" required placeholder="Nhập lý do cụ thể (VD: Khách sai số điện thoại, ngoài khu vực phục vụ, không có nhu cầu...)" style="width: 100%; border-radius: 8px; border: 1px solid #cbd5e1; padding: 10px; font-size: 13.5px;"></textarea>
                    <p style="font-size: 12px; color: #64748b; margin-top: 6px; line-height: 1.4;">
                        <i class="fa-solid fa-circle-info" style="color: #0284c7;"></i> Bắt buộc nhập lý do. Lead sẽ quay lại hàng chờ phân bổ và không còn thuộc quyền của bạn.
                    </p>
                </div>
                <div style="display: flex; justify-content: flex-end; gap: 10px;">
                    <button type="button" onclick="closeRejectModal()" style="padding: 8px 16px; border-radius: 8px; border: 1px solid #cbd5e1; background: #ffffff; color: #475569; font-weight: 600; cursor: pointer;">Hủy</button>
                    <button type="submit" id="btnSubmitReject" style="padding: 8px 18px; border-radius: 8px; border: none; background: #dc2626; color: #ffffff; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="fa-solid fa-xmark"></i> Xác nhận từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function handleAcceptLead(leadId) {
            if (!confirm('Bạn có chắc chắn muốn tiếp nhận Lead #' + leadId + ' để bắt đầu chăm sóc?')) return;
            fetch('${pageContext.request.contextPath}/leads/accept', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: 'leadId=' + encodeURIComponent(leadId)
            })
            .then(res => res.json().then(data => ({ status: res.status, ok: res.ok, data })))
            .then(result => {
                if (result.ok) {
                    alert(result.data.message || 'Đã tiếp nhận Lead thành công!');
                    window.location.reload();
                } else {
                    alert(result.data.message || ('Tiếp nhận Lead thất bại (Mã lỗi ' + result.status + ').'));
                }
            })
            .catch(err => {
                alert('Lỗi kết nối máy chủ: ' + err.message);
            });
        }

        function openRejectModal(leadId) {
            document.getElementById('rejectModalLeadId').value = leadId;
            document.getElementById('rejectModalLeadIdText').textContent = leadId;
            document.getElementById('rejectReasonInput').value = '';
            document.getElementById('rejectLeadModal').style.display = 'flex';
            setTimeout(() => document.getElementById('rejectReasonInput').focus(), 100);
        }

        function closeRejectModal() {
            document.getElementById('rejectLeadModal').style.display = 'none';
        }

        function submitRejectLead(e) {
            e.preventDefault();
            const leadId = document.getElementById('rejectModalLeadId').value;
            const reason = document.getElementById('rejectReasonInput').value.trim();
            if (!reason) {
                alert('Vui lòng nhập lý do từ chối Lead.');
                return;
            }
            const btn = document.getElementById('btnSubmitReject');
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';

            fetch('${pageContext.request.contextPath}/leads/reject', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: 'leadId=' + encodeURIComponent(leadId) + '&rejectReason=' + encodeURIComponent(reason)
            })
            .then(res => res.json().then(data => ({ status: res.status, ok: res.ok, data })))
            .then(result => {
                if (result.ok) {
                    alert(result.data.message || 'Đã từ chối Lead. Lead quay lại hàng chờ phân bổ.');
                    closeRejectModal();
                    window.location.reload();
                } else {
                    alert(result.data.message || ('Từ chối Lead thất bại (Mã lỗi ' + result.status + ').'));
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fa-solid fa-xmark"></i> Xác nhận từ chối';
                }
            })
            .catch(err => {
                alert('Lỗi kết nối máy chủ: ' + err.message);
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-xmark"></i> Xác nhận từ chối';
            });
        }

        function handleRecordContact(leadId) {
            const note = prompt('Nhập ghi chú liên hệ khách hàng:', 'Đã gọi điện tư vấn nhu cầu khách hàng');
            if (note === null) return;
            fetch('${pageContext.request.contextPath}/leads/contact', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: 'leadId=' + encodeURIComponent(leadId) + '&note=' + encodeURIComponent(note)
            })
            .then(res => res.json().then(data => ({ status: res.status, ok: res.ok, data })))
            .then(result => {
                if (result.ok) {
                    alert(result.data.message || 'Đã ghi nhận liên hệ khách hàng thành công!');
                    window.location.reload();
                } else {
                    alert(result.data.message || 'Ghi nhận liên hệ thất bại.');
                }
            })
            .catch(err => {
                alert('Lỗi kết nối máy chủ: ' + err.message);
            });
        }
    </script>
</body>
</html>
