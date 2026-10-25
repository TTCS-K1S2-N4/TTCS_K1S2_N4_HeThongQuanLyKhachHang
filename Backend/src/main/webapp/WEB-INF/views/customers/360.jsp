<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <title>Customer 360 | CRM System</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer-360.css">
    <style>
        /* Modern Royal Navy & Amber Customer 360 Dashboard Design */
        :root {
            --crm-primary: #1e3a8a;
            --crm-primary-hover: #172554;
            --crm-primary-light: #eff6ff;
            --crm-primary-border: #bfdbfe;
            --crm-accent: #d97706;
            --crm-accent-light: #fffbeb;
            --crm-surface: #ffffff;
            --crm-bg: #f8fafc;
            --crm-border: #e2e8f0;
            --crm-text-main: #0f172a;
            --crm-text-muted: #64748b;
            --crm-radius: 14px;
            --crm-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --crm-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.07);
        }

        .c360-page-container {
            max-width: 1440px;
            margin: 0 auto;
            padding: 24px 32px;
        }

        /* Top Hero Header Card */
        .c360-hero-card {
            background: #ffffff;
            border-radius: var(--crm-radius);
            border: 1px solid var(--crm-border);
            padding: 24px 28px;
            box-shadow: var(--crm-shadow-sm);
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .c360-hero-info {
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .c360-hero-avatar {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(30, 58, 138, 0.25);
            flex-shrink: 0;
        }

        .c360-hero-title-group h1 {
            font-size: 22px;
            font-weight: 700;
            color: var(--crm-text-main);
            margin: 0 0 6px 0;
            line-height: 1.3;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .c360-hero-tags {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            font-size: 13px;
            color: var(--crm-text-muted);
        }

        .c360-hero-tag-item {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-c360-back {
            background: #ffffff;
            color: #334155 !important;
            border: 1px solid var(--crm-border);
            padding: 8px 16px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 13.5px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-c360-back:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            transform: translateY(-1px);
        }

        /* Modern Dashboard Navigation Tabs Bar */
        .c360-dashboard-nav-bar {
            background: #ffffff;
            border-radius: var(--crm-radius);
            border: 1px solid var(--crm-border);
            padding: 6px;
            margin-bottom: 24px;
            display: flex;
            gap: 6px;
            overflow-x: auto;
            box-shadow: var(--crm-shadow-sm);
        }

        .c360-nav-tab {
            background: transparent;
            border: none;
            padding: 11px 18px;
            border-radius: 10px;
            font-size: 13.5px;
            font-weight: 600;
            color: #64748b;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            outline: none;
        }

        .c360-nav-tab i {
            font-size: 15px;
        }

        .c360-nav-tab:hover {
            color: var(--crm-primary);
            background: #f8fafc;
        }

        .c360-nav-tab.active {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(30, 58, 138, 0.25);
        }

        .c360-nav-tab.active .c360-tab-badge {
            background: rgba(255, 255, 255, 0.25);
            color: #ffffff;
        }

        .c360-tab-badge {
            background: #f1f5f9;
            color: #475569;
            font-size: 11px;
            padding: 2px 7px;
            border-radius: 12px;
            font-weight: 700;
        }

        /* Tab Content Panes */
        .c360-dashboard-pane {
            display: none;
            animation: paneFadeIn 0.2s ease-out;
        }
        .c360-dashboard-pane.active {
            display: block;
        }

        @keyframes paneFadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Content Cards & Grids */
        .c360-grid-2col {
            display: grid;
            grid-template-columns: 1.8fr 1.2fr;
            gap: 24px;
        }
        @media (max-width: 1024px) {
            .c360-grid-2col {
                grid-template-columns: 1fr;
            }
        }

        .c360-card {
            background: #ffffff;
            border-radius: var(--crm-radius);
            border: 1px solid var(--crm-border);
            box-shadow: var(--crm-shadow-sm);
            overflow: hidden;
            margin-bottom: 24px;
        }

        .c360-card-header {
            padding: 16px 22px;
            border-bottom: 1px solid var(--crm-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
        }

        .c360-card-title {
            font-size: 15.5px;
            font-weight: 700;
            color: var(--crm-text-main);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 9px;
        }

        .c360-card-body {
            padding: 22px;
        }

        /* KPI Value Cards */
        .kpi-card {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px 18px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .kpi-card:last-child {
            margin-bottom: 0;
        }
        .kpi-card.highlight {
            background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
            border: 1px solid #bfdbfe;
        }

        .kpi-label {
            font-size: 13px;
            font-weight: 600;
            color: #64748b;
        }
        .kpi-card.highlight .kpi-label {
            color: #1e3a8a;
        }

        .kpi-amount {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
        }

        /* Table custom */
        .c360-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }
        .c360-table th {
            background: #f8fafc;
            color: #475569;
            font-size: 12.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            padding: 12px 16px;
            border-bottom: 1px solid var(--crm-border);
            text-align: left;
        }
        .c360-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13.5px;
            color: #334155;
            vertical-align: middle;
        }
        .c360-table tbody tr:hover td {
            background-color: #f8fafc;
        }

        /* Sub-tabs for Opportunities */
        .c360-subtabs {
            display: inline-flex;
            background: #f1f5f9;
            padding: 4px;
            border-radius: 10px;
            margin-bottom: 16px;
        }
        .c360-subtab-btn {
            background: transparent;
            border: none;
            padding: 6px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #64748b;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .c360-subtab-btn.active {
            background: #ffffff;
            color: var(--crm-primary);
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="c360-page-container">
            <!-- Data sets initialization -->
            <c:set var="contactList" value="${not empty contacts ? contacts : customer360.contacts}"/>
            <c:set var="openOppList" value="${not empty openOpportunities ? openOpportunities : customer360.openOpportunities}"/>
            <c:set var="closedOppList" value="${not empty closedOpportunities ? closedOpportunities : customer360.closedOpportunities}"/>
            <c:set var="signedVal" value="${signedValue != null ? signedValue : customer360.signedValue}"/>
            <c:set var="openVal" value="${openOpportunityValue != null ? openOpportunityValue : (totalOpenOpportunityValue != null ? totalOpenOpportunityValue : customer360.totalOpenOpportunityValue)}"/>
            <c:set var="attachmentList" value="${not empty attachments ? attachments : customer360.attachments}"/>
            <c:set var="subsidiaryList" value="${not empty subsidiaries ? subsidiaries : customer360.subsidiaries}"/>
            <c:set var="groupTotal" value="${groupContractTotal != null ? groupContractTotal : customer360.groupContractTotal}"/>
            <c:set var="riskObj" value="${customerRisk != null ? customerRisk : customer360.customerRisk}"/>
            <c:set var="srList" value="${not empty supportRequests ? supportRequests : customer360.supportRequests}"/>
            <c:set var="custName" value="${customer != null ? (not empty customer.customerName ? customer.customerName : customer.customername) : 'Khách hàng'}"/>
            <c:set var="custId" value="${customer != null ? (customer.customerId > 0 ? customer.customerId : customer.customerid) : customer360.customer.customerId}"/>

            <!-- Churn Risk Alert Banner -->
            <c:if test="${riskObj != null && riskObj.riskFlag}">
                <div class="alert alert-danger" style="background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b; padding: 14px 18px; border-radius: 12px; margin-bottom: 20px; display: flex; align-items: center; gap: 14px; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.08);">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 24px; color: #dc2626;"></i>
                    <div style="flex: 1;">
                        <h4 style="margin: 0 0 2px 0; font-size: 15px; font-weight: 700; color: #991b1b;">CẢNH BÁO: KHÁCH HÀNG CÓ NGUY CƠ RỜI BỎ</h4>
                        <p style="margin: 0; font-size: 13.5px;"><c:out value="${riskObj.riskReason}"/></p>
                    </div>
                </div>
            </c:if>

            <!-- Customer Hero Banner -->
            <div class="c360-hero-card">
                <div class="c360-hero-info">
                    <div class="c360-hero-avatar">
                        <c:choose>
                            <c:when test="${not empty custName}">
                                ${custName.substring(0, 1).toUpperCase()}
                            </c:when>
                            <c:otherwise>K</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="c360-hero-title-group">
                        <h1>
                            <c:out value="${custName}"/>
                            <span class="badge" style="background: #eff6ff; color: #1e3a8a; border: 1px solid #bfdbfe; font-size: 12px; padding: 4px 10px; border-radius: 14px; font-weight: 600;">
                                <c:out value="${customer != null && not empty customer.status ? customer.status : 'Mới'}"/>
                            </span>
                        </h1>
                        <div class="c360-hero-tags">
                            <span class="c360-hero-tag-item"><i class="fa-solid fa-hashtag" style="color: #94a3b8;"></i> Mã: <strong>#${custId}</strong></span>
                            <span style="color: #cbd5e1;">•</span>
                            <span class="c360-hero-tag-item"><i class="fa-solid fa-receipt" style="color: #94a3b8;"></i> MST: <strong><c:out value="${customer != null && not empty customer.taxCode ? customer.taxCode : '---'}"/></strong></span>
                            <span style="color: #cbd5e1;">•</span>
                            <span class="c360-hero-tag-item"><i class="fa-solid fa-industry" style="color: #94a3b8;"></i> <c:out value="${customer != null && not empty customer.industry ? customer.industry : '---'}"/></span>
                        </div>
                    </div>
                </div>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <a href="${pageContext.request.contextPath}/customers" class="btn-c360-back">
                        <i class="fa-solid fa-arrow-left"></i> Danh sách khách hàng
                    </a>
                </div>
            </div>

            <!-- Dashboard Navigation Bar -->
            <div class="c360-dashboard-nav-bar">
                <button type="button" class="c360-nav-tab active" data-tab="tab-overview" onclick="switchDashboardTab('tab-overview')">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>Tổng quan & Tài chính</span>
                </button>
                <button type="button" class="c360-nav-tab" data-tab="tab-contacts" onclick="switchDashboardTab('tab-contacts')">
                    <i class="fa-solid fa-users"></i>
                    <span>Người liên hệ</span>
                    <span class="c360-tab-badge">${not empty contactList ? contactList.size() : 0}</span>
                </button>
                <button type="button" class="c360-nav-tab" data-tab="tab-opportunities" onclick="switchDashboardTab('tab-opportunities')">
                    <i class="fa-solid fa-briefcase"></i>
                    <span>Cơ hội & Hợp đồng</span>
                    <span class="c360-tab-badge">${(not empty openOppList ? openOppList.size() : 0) + (not empty closedOppList ? closedOppList.size() : 0)}</span>
                </button>
                <button type="button" class="c360-nav-tab" data-tab="tab-support" onclick="switchDashboardTab('tab-support')">
                    <i class="fa-solid fa-headset"></i>
                    <span>Hỗ trợ sau bán</span>
                    <span class="c360-tab-badge">${not empty srList ? srList.size() : 0}</span>
                </button>
                <button type="button" class="c360-nav-tab" data-tab="tab-subsidiaries" onclick="switchDashboardTab('tab-subsidiaries')">
                    <i class="fa-solid fa-sitemap"></i>
                    <span>Công ty con</span>
                    <span class="c360-tab-badge">${not empty subsidiaryList ? subsidiaryList.size() : 0}</span>
                </button>
                <button type="button" class="c360-nav-tab" data-tab="tab-timeline" onclick="switchDashboardTab('tab-timeline')">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <span>Lịch sử & Tài liệu</span>
                    <span class="c360-tab-badge">${not empty attachmentList ? attachmentList.size() : 0}</span>
                </button>
            </div>

            <!-- ================= TAB 1: TỔNG QUAN & TÀI CHÍNH ================= -->
            <div id="tab-overview" class="c360-dashboard-pane active">
                <div class="c360-grid-2col">
                    <!-- Thông tin chi tiết khách hàng -->
                    <div class="c360-card">
                        <div class="c360-card-header">
                            <h2 class="c360-card-title">
                                <i class="fa-solid fa-building" style="color: var(--crm-primary);"></i>
                                Hồ sơ thông tin doanh nghiệp
                            </h2>
                        </div>
                        <div class="c360-card-body">
                            <div class="c360-overview-grid" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 18px;">
                                <div class="c360-field">
                                    <span class="c360-label">Tên công ty / Khách hàng</span>
                                    <span class="c360-value" style="font-size: 15px; font-weight: 600; color: #0f172a;">
                                        <c:out value="${custName}"/>
                                    </span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Mã khách hàng</span>
                                    <span class="c360-value font-mono">#${custId}</span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Mã số thuế</span>
                                    <span class="c360-value"><c:out value="${customer != null && not empty customer.taxCode ? customer.taxCode : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Ngành nghề</span>
                                    <span class="c360-value"><c:out value="${customer != null && not empty customer.industry ? customer.industry : '---'}"/></span>
                                </div>
                                <div class="c360-field" style="grid-column: span 2;">
                                    <span class="c360-label">Địa chỉ trụ sở</span>
                                    <span class="c360-value"><c:out value="${customer != null && not empty customer.address ? customer.address : 'Chưa cập nhật địa chỉ'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Trạng thái quan hệ</span>
                                    <span class="c360-value">
                                        <span class="badge" style="background: #eff6ff; color: #1e3a8a; border: 1px solid #bfdbfe; padding: 4px 10px; border-radius: 12px; font-weight: 600;">
                                            <c:out value="${customer != null && not empty customer.status ? customer.status : 'Mới'}"/>
                                        </span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Thẻ giá trị khách hàng -->
                    <div class="c360-card">
                        <div class="c360-card-header">
                            <h2 class="c360-card-title">
                                <i class="fa-solid fa-coins" style="color: var(--crm-accent);"></i>
                                Giá trị & Tài chính khách hàng
                            </h2>
                        </div>
                        <div class="c360-card-body">
                            <div class="kpi-card">
                                <div>
                                    <div class="kpi-label">Giá trị đã ký (Doanh thu thực)</div>
                                    <div class="kpi-amount" style="color: #15803d; margin-top: 4px;">
                                        <fmt:formatNumber value="${signedVal != null ? signedVal : 0}" type="currency" currencySymbol="VND"/>
                                    </div>
                                </div>
                                <i class="fa-solid fa-file-invoice-dollar" style="font-size: 28px; color: #86efac;"></i>
                            </div>

                            <div class="kpi-card">
                                <div>
                                    <div class="kpi-label">Giá trị cơ hội tiềm năng (Open)</div>
                                    <div class="kpi-amount" style="color: #b45309; margin-top: 4px;">
                                        <fmt:formatNumber value="${openVal != null ? openVal : 0}" type="currency" currencySymbol="VND"/>
                                    </div>
                                </div>
                                <i class="fa-solid fa-chart-line" style="font-size: 28px; color: #fde68a;"></i>
                            </div>

                            <div class="kpi-card highlight">
                                <div>
                                    <div class="kpi-label">Tổng giá trị hợp đồng tập đoàn</div>
                                    <div class="kpi-amount" style="color: #1e3a8a; font-size: 20px; margin-top: 4px;">
                                        <fmt:formatNumber value="${groupTotal != null ? groupTotal : (signedVal != null ? signedVal : 0)}" type="currency" currencySymbol="VND"/>
                                    </div>
                                </div>
                                <i class="fa-solid fa-network-wired" style="font-size: 28px; color: #93c5fd;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ================= TAB 2: NGƯỜI LIÊN HỆ ================= -->
            <div id="tab-contacts" class="c360-dashboard-pane">
                <div class="c360-card">
                    <div class="c360-card-header">
                        <h2 class="c360-card-title">
                            <i class="fa-solid fa-users" style="color: var(--crm-primary);"></i>
                            Danh sách người liên hệ (${not empty contactList ? contactList.size() : 0})
                        </h2>
                        <div style="display: flex; gap: 8px;">
                            <a href="${pageContext.request.contextPath}/contacts?customerId=${custId}" class="btn btn-secondary btn-sm" style="padding: 7px 14px; border-radius: 8px; font-weight: 500;">
                                <i class="fa-solid fa-list"></i> Quản lý liên hệ
                            </a>
                            <a href="${pageContext.request.contextPath}/contacts/create?customerId=${custId}" class="btn btn-primary btn-sm" style="padding: 7px 14px; border-radius: 8px; font-weight: 600; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none;">
                                <i class="fa-solid fa-plus"></i> Thêm người liên hệ
                            </a>
                        </div>
                    </div>
                    <div class="c360-card-body" style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty contactList}">
                                <div class="table-responsive">
                                    <table class="c360-table">
                                        <thead>
                                            <tr>
                                                <th>Họ và tên</th>
                                                <th>Chức vụ</th>
                                                <th>Vai trò quyết định</th>
                                                <th>Đầu mối</th>
                                                <th>Email</th>
                                                <th>Số điện thoại</th>
                                                <th style="width: 100px; text-align: center;">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="contact" items="${contactList}">
                                                <c:set var="cId" value="${not empty contact.contactId ? contact.contactId : (not empty contact.id ? contact.id : contact['contactId'])}"/>
                                                <tr>
                                                    <td>
                                                        <div style="display: flex; align-items: center; gap: 10px;">
                                                            <div style="width: 34px; height: 34px; border-radius: 50%; background: #eff6ff; color: #1e3a8a; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 13px; border: 1px solid #bfdbfe;">
                                                                <c:out value="${not empty contact.fullName ? contact.fullName.substring(0, 1).toUpperCase() : 'C'}"/>
                                                            </div>
                                                            <div>
                                                                <strong style="color: #0f172a;">
                                                                    <c:choose>
                                                                        <c:when test="${not empty cId}">
                                                                            <a href="${pageContext.request.contextPath}/contacts/detail?id=${cId}" style="color: #1e3a8a; text-decoration: none;">
                                                                                <c:out value="${not empty contact.fullName ? contact.fullName : (not empty contact.contactName ? contact.contactName : contact.name)}"/>
                                                                            </a>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <c:out value="${not empty contact.fullName ? contact.fullName : (not empty contact.contactName ? contact.contactName : contact.name)}"/>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </strong>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span style="color: #475569;">
                                                            <c:out value="${not empty contact.title ? contact.title : (not empty contact.position ? contact.position : (not empty contact.role ? contact.role : '---'))}"/>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${contact.buyingRole == 'DECIDER' or contact.buyingRole == 'DECISION_MAKER'}">
                                                                <span class="badge" style="background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                                                                    <i class="fa-solid fa-crown" style="font-size: 10px;"></i> Người quyết định
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${contact.buyingRole == 'INFLUENCER'}">
                                                                <span class="badge" style="background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                                                                    <i class="fa-solid fa-wand-magic-sparkles" style="font-size: 10px;"></i> Người ảnh hưởng
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${contact.buyingRole == 'END_USER'}">
                                                                <span class="badge" style="background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                                                                    <i class="fa-solid fa-user-check" style="font-size: 10px;"></i> Người dùng cuối
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${contact.buyingRole == 'BLOCKER'}">
                                                                <span class="badge" style="background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                                                                    <i class="fa-solid fa-shield-halved" style="font-size: 10px;"></i> Người cản trở
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color: #94a3b8; font-size: 13px;">—</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${contact.primary}">
                                                                <span class="badge" style="background: #fefce8; color: #a16207; border: 1px solid #fef08a; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                                                                    <i class="fa-solid fa-star" style="font-size: 11px; color: #eab308;"></i> Chính
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color: #94a3b8; font-size: 13px;">Phụ</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty contact.email}">
                                                                <a href="mailto:${contact.email}" style="color: #2563eb; text-decoration: none;"><i class="fa-solid fa-envelope" style="margin-right: 4px; color: #94a3b8;"></i><c:out value="${contact.email}"/></a>
                                                            </c:when>
                                                            <c:otherwise><span style="color: #94a3b8;">—</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty contact.phone}">
                                                                <a href="tel:${contact.phone}" style="color: #0f172a; text-decoration: none; font-weight: 500;"><i class="fa-solid fa-phone" style="margin-right: 4px; color: #94a3b8;"></i><c:out value="${contact.phone}"/></a>
                                                            </c:when>
                                                            <c:otherwise><span style="color: #94a3b8;">—</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <c:if test="${not empty cId}">
                                                            <a href="${pageContext.request.contextPath}/contacts/detail?id=${cId}" class="btn btn-sm btn-secondary" style="padding: 5px 10px; border-radius: 6px; font-size: 12px;" title="Xem chi tiết & chuyển công ty">
                                                                <i class="fa-solid fa-eye"></i>
                                                            </a>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="c360-empty-state" style="padding: 48px 20px;">
                                    <i class="fa-regular fa-address-book" style="font-size: 40px; color: #cbd5e1; margin-bottom: 12px;"></i>
                                    <p style="font-size: 14px; color: #64748b; margin-bottom: 14px;">Chưa có người liên hệ nào được gắn với khách hàng này.</p>
                                    <a href="${pageContext.request.contextPath}/contacts/create?customerId=${custId}" class="btn btn-primary btn-sm" style="padding: 8px 16px; border-radius: 8px; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none;">
                                        <i class="fa-solid fa-plus"></i> Thêm người liên hệ đầu tiên
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- ================= TAB 3: CƠ HỘI & HỢP ĐỒNG ================= -->
            <div id="tab-opportunities" class="c360-dashboard-pane">
                <div class="c360-card">
                    <div class="c360-card-header">
                        <h2 class="c360-card-title">
                            <i class="fa-solid fa-briefcase" style="color: var(--crm-primary);"></i>
                            Quản lý Cơ hội & Hợp đồng
                        </h2>
                    </div>
                    <div class="c360-card-body">
                        <!-- Subtabs: Open vs Closed -->
                        <div class="c360-subtabs">
                            <button class="c360-subtab-btn active" onclick="switchOppTab('open')">
                                Đang mở (${not empty openOppList ? openOppList.size() : 0})
                            </button>
                            <button class="c360-subtab-btn" onclick="switchOppTab('closed')">
                                Đã đóng (${not empty closedOppList ? closedOppList.size() : 0})
                            </button>
                        </div>
                        
                        <!-- Open Opportunities -->
                        <div id="tab-opp-open" class="c360-tab-content active">
                            <c:choose>
                                <c:when test="${not empty openOppList}">
                                    <div class="table-responsive">
                                        <table class="c360-table">
                                            <thead>
                                                <tr>
                                                    <th>Tên cơ hội</th>
                                                    <th>Giá trị dự kiến</th>
                                                    <th>Giai đoạn Pipeline</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="opp" items="${openOppList}">
                                                    <tr>
                                                        <td style="font-weight: 600; color: #0f172a;"><c:out value="${not empty opp.title ? opp.title : opp.name}"/></td>
                                                        <td style="font-weight: 600; color: #b45309;"><fmt:formatNumber value="${opp.amount != null ? opp.amount : opp.value}" type="currency" currencySymbol="VND"/></td>
                                                        <td><span class="badge" style="background: #fffbeb; color: #b45309; border: 1px solid #fde68a; padding: 4px 10px; border-radius: 12px; font-weight: 600;"><c:out value="${not empty opp.stageName ? opp.stageName : opp.stage}"/></span></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state" style="padding: 40px 20px;">
                                        <i class="fa-solid fa-seedling" style="font-size: 36px; color: #cbd5e1; margin-bottom: 10px;"></i>
                                        <p style="color: #64748b;">Khách hàng hiện chưa có cơ hội nào đang mở.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Closed Opportunities -->
                        <div id="tab-opp-closed" class="c360-tab-content" style="display: none;">
                            <c:choose>
                                <c:when test="${not empty closedOppList}">
                                    <div class="table-responsive">
                                        <table class="c360-table">
                                            <thead>
                                                <tr>
                                                    <th>Tên cơ hội</th>
                                                    <th>Giá trị hợp đồng</th>
                                                    <th>Kết quả</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="opp" items="${closedOppList}">
                                                    <tr>
                                                        <td style="font-weight: 600; color: #0f172a;"><c:out value="${not empty opp.title ? opp.title : opp.name}"/></td>
                                                        <td style="font-weight: 600; color: #15803d;"><fmt:formatNumber value="${opp.amount != null ? opp.amount : opp.value}" type="currency" currencySymbol="VND"/></td>
                                                        <td><span class="badge" style="background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 4px 10px; border-radius: 12px; font-weight: 600;"><c:out value="${not empty opp.stageName ? opp.stageName : opp.stage}"/></span></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state" style="padding: 40px 20px;">
                                        <i class="fa-solid fa-box-archive" style="font-size: 36px; color: #cbd5e1; margin-bottom: 10px;"></i>
                                        <p style="color: #64748b;">Khách hàng chưa có cơ hội nào đã đóng.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ================= TAB 4: HỖ TRỢ SAU BÁN ================= -->
            <div id="tab-support" class="c360-dashboard-pane">
                <div class="c360-card">
                    <div class="c360-card-header">
                        <h2 class="c360-card-title">
                            <i class="fa-solid fa-headset" style="color: var(--crm-primary);"></i>
                            Yêu cầu hỗ trợ & CSKH (${not empty srList ? srList.size() : 0})
                        </h2>
                        <a href="${pageContext.request.contextPath}/customers/support?customerId=${custId}" class="btn btn-primary btn-sm" style="padding: 7px 14px; border-radius: 8px; font-weight: 600; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none;">
                            <i class="fa-solid fa-plus"></i> Tạo yêu cầu mới
                        </a>
                    </div>
                    <div class="c360-card-body" style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty srList}">
                                <div class="table-responsive">
                                    <table class="c360-table">
                                        <thead>
                                            <tr>
                                                <th style="width: 70px;">ID</th>
                                                <th>Tiêu đề yêu cầu</th>
                                                <th>Mức ưu tiên</th>
                                                <th>Trạng thái</th>
                                                <th>Người xử lý</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="sr" items="${srList}">
                                                <tr>
                                                    <td style="font-weight: 600; color: #64748b;">#${sr.requestId}</td>
                                                    <td style="font-weight: 600; color: #0f172a;"><c:out value="${sr.title}"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.priority == 'URGENT'}"><span class="badge" style="background:#fee2e2; color:#dc2626; border: 1px solid #fca5a5; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 600;">Khẩn cấp</span></c:when>
                                                            <c:when test="${sr.priority == 'HIGH'}"><span class="badge" style="background:#fef3c7; color:#d97706; border: 1px solid #fde68a; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 600;">Cao</span></c:when>
                                                            <c:when test="${sr.priority == 'MEDIUM'}"><span class="badge" style="background:#eff6ff; color:#2563eb; border: 1px solid #bfdbfe; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 600;">Trung bình</span></c:when>
                                                            <c:otherwise><span class="badge" style="background:#f1f5f9; color:#475569; padding: 3px 10px; border-radius: 12px; font-size: 11.5px;"><c:out value="${sr.priority}"/></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.status == 'OPEN'}"><span class="badge" style="background:#eff6ff; color:#1e40af; border: 1px solid #bfdbfe; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 600;">Mới tạo</span></c:when>
                                                            <c:when test="${sr.status == 'IN_PROGRESS'}"><span class="badge" style="background:#fef08a; color:#ca8a04; border: 1px solid #fde047; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 600;">Đang xử lý</span></c:when>
                                                            <c:when test="${sr.status == 'RESOLVED'}"><span class="badge" style="background:#dcfce7; color:#16a34a; border: 1px solid #bbf7d0; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 600;">Đã giải quyết</span></c:when>
                                                            <c:otherwise><span class="badge" style="background:#f3f4f6; color:#4b5563; padding: 3px 10px; border-radius: 12px; font-size: 11.5px;"><c:out value="${sr.status}"/></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <span style="color: #475569; font-weight: 500;">
                                                            <i class="fa-solid fa-user-circle" style="color: #94a3b8; margin-right: 4px;"></i>
                                                            <c:out value="${not empty sr.assigneeName ? sr.assigneeName : (sr.assigneeId != null ? sr.assigneeId : 'Chưa phân công')}"/>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="c360-empty-state" style="padding: 48px 20px;">
                                    <i class="fa-solid fa-headset" style="font-size: 40px; color: #cbd5e1; margin-bottom: 12px;"></i>
                                    <p style="color: #64748b; margin-bottom: 14px;">Chưa có yêu cầu hỗ trợ nào cho khách hàng này.</p>
                                    <a href="${pageContext.request.contextPath}/customers/support?customerId=${custId}" class="btn btn-primary btn-sm" style="padding: 8px 16px; border-radius: 8px; background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); border: none;">
                                        <i class="fa-solid fa-plus"></i> Tạo yêu cầu hỗ trợ
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- ================= TAB 5: CÔNG TY CON ================= -->
            <div id="tab-subsidiaries" class="c360-dashboard-pane">
                <div class="c360-card">
                    <div class="c360-card-header">
                        <h2 class="c360-card-title">
                            <i class="fa-solid fa-sitemap" style="color: var(--crm-primary);"></i>
                            Mạng lưới công ty con & Chi nhánh (${not empty subsidiaryList ? subsidiaryList.size() : 0})
                        </h2>
                        <a href="${pageContext.request.contextPath}/customers/hierarchy?id=${custId}" class="btn btn-secondary btn-sm" style="padding: 7px 14px; border-radius: 8px; font-weight: 500;">
                            <i class="fa-solid fa-network-wired"></i> Khai báo quan hệ tập đoàn
                        </a>
                    </div>
                    <div class="c360-card-body" style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty subsidiaryList}">
                                <div class="table-responsive">
                                    <table class="c360-table">
                                        <thead>
                                            <tr>
                                                <th style="width: 80px;">ID</th>
                                                <th>Tên công ty con</th>
                                                <th>Mã số thuế</th>
                                                <th style="width: 140px; text-align: center;">Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="sub" items="${subsidiaryList}">
                                                <tr>
                                                    <td style="font-weight: 600; color: #64748b;">#${sub.customerId}</td>
                                                    <td>
                                                        <strong style="color: #0f172a;">
                                                            <a href="${pageContext.request.contextPath}/customers/360?id=${sub.customerId}" style="color: #1e3a8a; text-decoration: none;">
                                                                <i class="fa-regular fa-building" style="margin-right: 6px; color: #94a3b8;"></i>
                                                                <c:out value="${sub.customerName}"/>
                                                            </a>
                                                        </strong>
                                                    </td>
                                                    <td><span class="font-mono"><c:out value="${not empty sub.taxCode ? sub.taxCode : '---'}"/></span></td>
                                                    <td style="text-align: center;">
                                                        <a href="${pageContext.request.contextPath}/customers/360?id=${sub.customerId}" class="btn btn-sm btn-secondary" style="padding: 4px 10px; border-radius: 6px; font-size: 12.5px;">
                                                            Xem 360 <i class="fa-solid fa-arrow-right" style="font-size: 10px; margin-left: 2px;"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="c360-empty-state" style="padding: 48px 20px;">
                                    <i class="fa-solid fa-building-user" style="font-size: 40px; color: #cbd5e1; margin-bottom: 12px;"></i>
                                    <p style="color: #64748b; margin-bottom: 14px;">Chưa có công ty con hoặc chi nhánh nào được liên kết.</p>
                                    <a href="${pageContext.request.contextPath}/customers/hierarchy?id=${custId}" class="btn btn-secondary btn-sm" style="padding: 8px 16px; border-radius: 8px;">
                                        <i class="fa-solid fa-plus"></i> Khai báo quan hệ liên kết
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- ================= TAB 6: LỊCH SỬ & TÀI LIỆU ================= -->
            <div id="tab-timeline" class="c360-dashboard-pane">
                <div class="c360-grid-2col">
                    <!-- Dòng thời gian hoạt động -->
                    <div class="c360-card">
                        <div class="c360-card-header">
                            <h2 class="c360-card-title">
                                <i class="fa-solid fa-clock-rotate-left" style="color: var(--crm-primary);"></i>
                                Dòng thời gian tương tác (Activity Timeline)
                            </h2>
                        </div>
                        <div class="c360-card-body">
                            <div id="c360-timeline-container">
                                <div class="c360-loading-state" style="padding: 30px; text-align: center; color: #64748b;">
                                    <i class="fa-solid fa-circle-notch fa-spin" style="font-size: 24px; color: var(--crm-primary); margin-bottom: 8px;"></i>
                                    <p>Đang tải dòng thời gian...</p>
                                </div>
                            </div>
                            <div class="c360-timeline-actions" id="c360-timeline-actions" style="display: none; text-align: center; margin-top: 16px;">
                                <button class="btn btn-sm btn-secondary" onclick="loadMoreTimeline()" style="padding: 6px 16px; border-radius: 8px;">Tải thêm hoạt động</button>
                            </div>
                        </div>
                    </div>

                    <!-- Tài liệu đính kèm -->
                    <div class="c360-card">
                        <div class="c360-card-header">
                            <h2 class="c360-card-title">
                                <i class="fa-solid fa-paperclip" style="color: var(--crm-accent);"></i>
                                Tài liệu đính kèm (${not empty attachmentList ? attachmentList.size() : 0})
                            </h2>
                        </div>
                        <div class="c360-card-body">
                            <c:choose>
                                <c:when test="${not empty attachmentList}">
                                    <ul class="c360-attachment-list" style="list-style: none; padding: 0; margin: 0;">
                                        <c:forEach var="att" items="${attachmentList}">
                                            <li style="padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 8px; display: flex; align-items: center; gap: 10px; background: #f8fafc;">
                                                <i class="fa-solid fa-file-pdf" style="color: #ef4444; font-size: 18px;"></i>
                                                <a href="${pageContext.request.contextPath}${not empty att.filePath ? att.filePath : att.url}" target="_blank" style="color: #1e3a8a; text-decoration: none; font-weight: 500; flex: 1; word-break: break-all;">
                                                    <c:out value="${not empty att.fileName ? att.fileName : att.name}"/>
                                                </a>
                                                <i class="fa-solid fa-download" style="color: #94a3b8; font-size: 13px;"></i>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state" style="padding: 36px 16px;">
                                        <i class="fa-regular fa-file" style="font-size: 36px; color: #cbd5e1; margin-bottom: 10px;"></i>
                                        <p style="color: #64748b;">Chưa có tài liệu đính kèm nào.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Hidden Inputs for JS Engine -->
            <input type="hidden" id="c360-customer-id" value="${custId}">
            <input type="hidden" id="c360-context-path" value="${pageContext.request.contextPath}">
        </div>
    </main>
</div>

<!-- Tab Navigation Engine Script -->
<script>
    function switchDashboardTab(tabId) {
        // Ẩn tất cả các tab panes
        document.querySelectorAll('.c360-dashboard-pane').forEach(pane => {
            pane.style.display = 'none';
            pane.classList.remove('active');
        });
        // Bỏ active trên các buttons
        document.querySelectorAll('.c360-nav-tab').forEach(btn => {
            btn.classList.remove('active');
        });

        // Bật tab được chọn
        const targetPane = document.getElementById(tabId);
        const targetBtn = document.querySelector('[data-tab="' + tabId + '"]');
        if (targetPane) {
            targetPane.style.display = 'block';
            targetPane.classList.add('active');
        }
        if (targetBtn) {
            targetBtn.classList.add('active');
        }

        // Lưu trạng thái vào hash URL
        try {
            history.replaceState(null, null, '#' + tabId);
        } catch (e) {}
    }

    // Tự động khôi phục tab từ URL Hash khi tải trang
    window.addEventListener('DOMContentLoaded', function() {
        const hash = window.location.hash ? window.location.hash.substring(1) : '';
        if (hash && document.getElementById(hash)) {
            switchDashboardTab(hash);
        }
    });
</script>

<!-- Customer 360 Core JS -->
<script src="${pageContext.request.contextPath}/assets/js/customer-360.js"></script>
</body>
</html>
