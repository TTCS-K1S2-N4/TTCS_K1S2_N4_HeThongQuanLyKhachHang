<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <title>Cấu trúc Tập đoàn & Công ty mẹ - con | CRM Pro</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --crm-font: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --crm-navy-900: #0f172a;
            --crm-navy-800: #1e293b;
            --crm-navy-700: #334155;
            --crm-blue-600: #2563eb;
            --crm-blue-700: #1d4ed8;
            --crm-blue-50: #eff6ff;
            --crm-blue-100: #dbeafe;
            --crm-indigo-600: #4f46e5;
            --crm-emerald-600: #059669;
            --crm-emerald-50: #ecfdf5;
            --crm-amber-500: #f59e0b;
            --crm-amber-50: #fffbeb;
            --crm-rose-500: #f43f5e;
            --crm-rose-50: #fff1f2;
            --crm-slate-50: #f8fafc;
            --crm-slate-100: #f1f5f9;
            --crm-slate-200: #e2e8f0;
            --crm-slate-400: #94a3b8;
            --crm-slate-500: #64748b;
            --crm-card-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.04), 0 8px 10px -6px rgba(15, 23, 42, 0.03);
            --crm-elevate-shadow: 0 20px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.04);
            --crm-radius-lg: 18px;
            --crm-radius-md: 12px;
            --crm-radius-sm: 8px;
        }

        body {
            font-family: var(--crm-font) !important;
            background-color: #f4f6fa !important;
            color: var(--crm-navy-800);
        }

        .hier-wrapper {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px 28px 48px;
        }

        /* Hero Header */
        .hier-header-card {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            padding: 28px 32px;
            box-shadow: var(--crm-card-shadow);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
            position: relative;
            overflow: hidden;
        }

        .hier-header-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 6px;
            height: 100%;
            background: linear-gradient(180deg, var(--crm-blue-600) 0%, var(--crm-indigo-600) 100%);
        }

        .hier-header-profile {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .hier-avatar-logo {
            width: 64px;
            height: 64px;
            border-radius: 16px;
            background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 800;
            box-shadow: 0 8px 16px -2px rgba(37, 99, 235, 0.3);
            flex-shrink: 0;
        }

        .hier-title-group h1 {
            font-size: 24px;
            font-weight: 800;
            color: var(--crm-navy-900);
            margin: 0 0 8px 0;
            display: flex;
            align-items: center;
            gap: 12px;
            letter-spacing: -0.3px;
        }

        .hier-id-pill {
            background: var(--crm-blue-50);
            color: var(--crm-blue-600);
            border: 1px solid var(--crm-blue-100);
            font-size: 13px;
            font-weight: 700;
            padding: 3px 12px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .hier-meta-badges {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
            font-size: 13.5px;
            color: var(--crm-slate-500);
        }

        .hier-meta-item {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .hier-meta-item strong {
            color: var(--crm-navy-700);
        }

        .hier-header-actions {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }

        /* Top Action Buttons */
        .btn-crm-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: var(--crm-radius-md);
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid transparent;
        }

        .btn-crm-primary {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
        }

        .btn-crm-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(37, 99, 235, 0.35);
        }

        .btn-crm-outline {
            background: #ffffff;
            color: var(--crm-navy-700) !important;
            border-color: var(--crm-slate-200);
        }

        .btn-crm-outline:hover {
            background: var(--crm-slate-50);
            border-color: var(--crm-slate-400);
            transform: translateY(-1px);
        }

        /* Executive KPI Metrics Grid */
        .hier-metrics-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr;
            gap: 20px;
            margin-bottom: 28px;
        }

        @media (max-width: 992px) {
            .hier-metrics-grid {
                grid-template-columns: 1fr;
            }
        }

        .hier-metric-card {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            padding: 24px;
            box-shadow: var(--crm-card-shadow);
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .hier-metric-card.highlight {
            background: linear-gradient(135deg, #091e42 0%, #1e3a8a 60%, #1d4ed8 100%);
            color: #ffffff;
            border: none;
            box-shadow: 0 12px 28px -4px rgba(30, 58, 138, 0.35);
        }

        .hier-metric-card.highlight::after {
            content: '';
            position: absolute;
            right: -25px;
            top: -25px;
            width: 180px;
            height: 180px;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }

        .hier-metric-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        .hier-metric-title {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--crm-slate-500);
        }

        .hier-metric-card.highlight .hier-metric-title {
            color: #bfdbfe;
        }

        .hier-metric-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: var(--crm-radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .hier-metric-card.highlight .hier-metric-icon-wrap {
            background: rgba(255, 255, 255, 0.15);
            color: #ffffff;
        }

        .hier-metric-val {
            font-size: 32px;
            font-weight: 800;
            line-height: 1.1;
            color: var(--crm-navy-900);
            letter-spacing: -0.5px;
        }

        .hier-metric-card.highlight .hier-metric-val {
            color: #ffffff;
        }

        .hier-metric-sub {
            font-size: 13px;
            margin-top: 8px;
            color: var(--crm-slate-400);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .hier-metric-card.highlight .hier-metric-sub {
            color: #cbd5e1;
        }

        /* Section Container */
        .hier-section-box {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            box-shadow: var(--crm-card-shadow);
            margin-bottom: 28px;
            overflow: hidden;
        }

        .hier-section-header {
            padding: 20px 28px;
            border-bottom: 1px solid var(--crm-slate-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #ffffff;
        }

        .hier-section-title {
            margin: 0;
            font-size: 17px;
            font-weight: 800;
            color: var(--crm-navy-900);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .hier-section-title i {
            color: var(--crm-blue-600);
        }

        /* Visual Org Chart Flow Tree */
        .hier-tree-canvas {
            padding: 36px 24px;
            background: radial-gradient(#e2e8f0 1.2px, transparent 1.2px);
            background-size: 20px 20px;
            background-color: #fafbfc;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }

        .tree-level {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 24px;
            width: 100%;
            flex-wrap: wrap;
        }

        .tree-connector {
            display: flex;
            flex-direction: column;
            align-items: center;
            color: #94a3b8;
            font-size: 18px;
            position: relative;
            padding: 4px 0;
        }

        .tree-connector-line {
            width: 2px;
            height: 24px;
            background: #cbd5e1;
        }

        /* Node Cards */
        .tree-node {
            background: #ffffff;
            border-radius: var(--crm-radius-md);
            border: 1px solid var(--crm-slate-200);
            padding: 18px 24px;
            min-width: 280px;
            max-width: 360px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            transition: all 0.25s ease;
            position: relative;
        }

        .tree-node:hover {
            transform: translateY(-3px);
            box-shadow: var(--crm-elevate-shadow);
            border-color: var(--crm-blue-600);
        }

        .tree-node.node-parent {
            border-top: 4px solid #3b82f6;
            background: #ffffff;
        }

        .tree-node.node-current {
            border: 2px solid var(--crm-blue-600);
            background: linear-gradient(180deg, #ffffff 0%, #f0f7ff 100%);
            box-shadow: 0 10px 20px -3px rgba(37, 99, 235, 0.15);
        }

        .tree-node.node-child {
            border-top: 4px solid var(--crm-emerald-600);
        }

        .node-badge-tag {
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            padding: 3px 8px;
            border-radius: 6px;
            display: inline-block;
            margin-bottom: 8px;
        }

        .node-tag-parent {
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }

        .node-tag-current {
            background: #1e3a8a;
            color: #ffffff;
        }

        .node-tag-child {
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }

        .node-tag-branch {
            background: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
        }

        .node-tag-member {
            background: #faf5ff;
            color: #7e22ce;
            border: 1px solid #e9d5ff;
        }

        .node-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--crm-navy-900);
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .node-title a {
            color: var(--crm-navy-900);
            text-decoration: none;
        }

        .node-title a:hover {
            color: var(--crm-blue-600);
            text-decoration: underline;
        }

        .node-details {
            font-size: 12.5px;
            color: var(--crm-slate-500);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .node-actions {
            margin-top: 14px;
            padding-top: 10px;
            border-top: 1px dashed var(--crm-slate-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* 2 Columns Cards Grid */
        .hier-grid-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 28px;
        }

        @media (max-width: 900px) {
            .hier-grid-2col {
                grid-template-columns: 1fr;
            }
        }

        .hier-entity-list {
            list-style: none;
            padding: 20px;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .hier-entity-item {
            background: #ffffff;
            border: 1px solid var(--crm-slate-200);
            border-radius: var(--crm-radius-md);
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            transition: all 0.2s ease;
        }

        .hier-entity-item:hover {
            border-color: #cbd5e1;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
            transform: translateX(4px);
        }

        .hier-entity-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .hier-entity-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }

        .icon-parent-blue {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #bfdbfe;
        }

        .icon-child-green {
            background: #ecfdf5;
            color: #059669;
            border: 1px solid #a7f3d0;
        }

        .hier-entity-info h4 {
            margin: 0 0 4px 0;
            font-size: 14.5px;
            font-weight: 700;
        }

        .hier-entity-info h4 a {
            color: var(--crm-navy-900);
            text-decoration: none;
        }

        .hier-entity-info h4 a:hover {
            color: var(--crm-blue-600);
            text-decoration: underline;
        }

        .hier-entity-meta {
            font-size: 12.5px;
            color: var(--crm-slate-500);
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .hier-item-btns {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-action-icon {
            padding: 6px 12px;
            border-radius: var(--crm-radius-sm);
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            transition: all 0.2s ease;
            border: 1px solid transparent;
        }

        .btn-action-view {
            background: #eff6ff;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .btn-action-view:hover {
            background: #dbeafe;
            color: #1e40af;
        }

        .btn-action-delete {
            background: #fff1f2;
            color: #e11d48;
            border-color: #fecdd3;
        }

        .btn-action-delete:hover {
            background: #ffe4e6;
            color: #be123c;
        }

        /* Modern Linking Form */
        .hier-form-card {
            background: #ffffff;
            border-radius: var(--crm-radius-lg);
            border: 1px solid var(--crm-slate-200);
            box-shadow: var(--crm-card-shadow);
            padding: 28px;
            margin-bottom: 28px;
        }

        .hier-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
        }

        @media (max-width: 900px) {
            .hier-form-grid {
                grid-template-columns: 1fr;
            }
        }

        .form-field {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-field label {
            font-size: 13.5px;
            font-weight: 700;
            color: var(--crm-navy-700);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .crm-input-select {
            padding: 12px 16px;
            border: 1px solid var(--crm-slate-200);
            border-radius: var(--crm-radius-md);
            font-family: inherit;
            font-size: 14px;
            color: var(--crm-navy-900);
            background-color: #ffffff;
            transition: all 0.2s ease;
            outline: none;
        }

        .crm-input-select:focus {
            border-color: var(--crm-blue-600);
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.12);
        }

        .btn-submit-save {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            border: none;
            padding: 12px 28px;
            border-radius: var(--crm-radius-md);
            font-size: 14.5px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 14px rgba(37, 99, 235, 0.28);
            transition: all 0.2s ease;
        }

        .btn-submit-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(37, 99, 235, 0.38);
        }

        /* Empty States */
        .hier-empty-box {
            padding: 36px 20px;
            text-align: center;
            color: var(--crm-slate-400);
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            font-size: 14px;
        }

        .hier-empty-box i {
            font-size: 36px;
            color: #cbd5e1;
        }

        /* Flash Alerts */
        .crm-alert {
            padding: 14px 20px;
            border-radius: var(--crm-radius-md);
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
            font-size: 14px;
            font-weight: 600;
        }

        .crm-alert-danger {
            background: #fff1f2;
            color: #e11d48;
            border: 1px solid #fecdd3;
        }

        .crm-alert-success {
            background: #ecfdf5;
            color: #059669;
            border: 1px solid #a7f3d0;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="hier-wrapper">

            <!-- System Flash Messages -->
            <c:if test="${not empty errorMessage}">
                <div class="crm-alert crm-alert-danger">
                    <i class="fa-solid fa-circle-exclamation" style="font-size: 18px;"></i>
                    <span><c:out value="${errorMessage}"/></span>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="crm-alert crm-alert-success">
                    <i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
                    <span><c:out value="${successMessage}"/></span>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${not empty customer}">

                    <!-- 1. Top Executive Profile Card -->
                    <div class="hier-header-card">
                        <div class="hier-header-profile">
                            <div class="hier-avatar-logo">
                                <c:choose>
                                    <c:when test="${not empty customer.customerName}">
                                        ${customer.customerName.substring(0, 1).toUpperCase()}
                                    </c:when>
                                    <c:otherwise>C</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="hier-title-group">
                                <h1>
                                    <c:out value="${customer.customerName}"/>
                                    <span class="hier-id-pill">
                                        <i class="fa-solid fa-hashtag" style="font-size: 11px;"></i> Mã: #${customer.customerId}
                                    </span>
                                </h1>
                                <div class="hier-meta-badges">
                                    <span class="hier-meta-item">
                                        <i class="fa-solid fa-id-card" style="color: var(--crm-slate-400);"></i>
                                        MST: <strong><c:out value="${not empty customer.taxCode ? customer.taxCode : 'Chưa cập nhật'}"/></strong>
                                    </span>
                                    <span>•</span>
                                    <span class="hier-meta-item">
                                        <i class="fa-solid fa-industry" style="color: var(--crm-slate-400);"></i>
                                        Ngành: <strong><c:out value="${not empty customer.industry ? customer.industry : 'Doanh nghiệp'}"/></strong>
                                    </span>
                                    <span>•</span>
                                    <span class="hier-meta-item">
                                        <i class="fa-solid fa-globe" style="color: var(--crm-slate-400);"></i>
                                        Website: <strong><c:out value="${not empty customer.website ? customer.website : '---'}"/></strong>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="hier-header-actions">
                            <a href="${pageContext.request.contextPath}/customers/360?id=${customer.customerId}" class="btn-crm-pill btn-crm-primary">
                                <i class="fa-solid fa-chart-pie"></i> Xem Customer 360
                            </a>
                            <a href="${pageContext.request.contextPath}/customers" class="btn-crm-pill btn-crm-outline">
                                <i class="fa-solid fa-arrow-left"></i> DS Khách hàng
                            </a>
                        </div>
                    </div>

                    <!-- 2. Executive KPI Metrics Grid -->
                    <div class="hier-metrics-grid">
                        <!-- Primary KPI: Group Contract Total -->
                        <div class="hier-metric-card highlight">
                            <div>
                                <div class="hier-metric-top">
                                    <span class="hier-metric-title">
                                        <i class="fa-solid fa-network-wired" style="margin-right: 6px;"></i> Tổng giá trị hợp đồng tập đoàn
                                    </span>
                                    <div class="hier-metric-icon-wrap">
                                        <i class="fa-solid fa-sack-dollar"></i>
                                    </div>
                                </div>
                                <div class="hier-metric-val">
                                    <fmt:formatNumber value="${groupContractTotal != null ? groupContractTotal : 0}" type="currency" currencySymbol="VND"/>
                                </div>
                            </div>
                            <div class="hier-metric-sub">
                                <i class="fa-solid fa-shield-halved"></i>
                                Bao gồm doanh số đã ký của công ty hiện tại và toàn bộ công ty con / chi nhánh thành viên
                            </div>
                        </div>

                        <!-- KPI 2: Subsidiaries Count -->
                        <div class="hier-metric-card">
                            <div>
                                <div class="hier-metric-top">
                                    <span class="hier-metric-title">Công ty con & Chi nhánh</span>
                                    <div class="hier-metric-icon-wrap" style="background: var(--crm-emerald-50); color: var(--crm-emerald-600);">
                                        <i class="fa-solid fa-sitemap"></i>
                                    </div>
                                </div>
                                <div class="hier-metric-val" style="color: var(--crm-emerald-600);">
                                    ${not empty children ? children.size() : 0}
                                </div>
                            </div>
                            <div class="hier-metric-sub">
                                <i class="fa-regular fa-building"></i>
                                Thành viên trực thuộc tập đoàn
                            </div>
                        </div>

                        <!-- KPI 3: Parent Status -->
                        <div class="hier-metric-card">
                            <div>
                                <div class="hier-metric-top">
                                    <span class="hier-metric-title">Vị thế phân cấp</span>
                                    <div class="hier-metric-icon-wrap" style="background: var(--crm-blue-50); color: var(--crm-blue-600);">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                </div>
                                <div class="hier-metric-val" style="font-size: 20px; font-weight: 700; color: var(--crm-navy-800); margin-top: 6px;">
                                    <c:choose>
                                        <c:when test="${not empty parents and parents.size() > 0}">
                                            Đơn vị thành viên
                                        </c:when>
                                        <c:when test="${not empty children and children.size() > 0}">
                                            Công ty Mẹ (Holding)
                                        </c:when>
                                        <c:otherwise>
                                            Doanh nghiệp độc lập
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="hier-metric-sub">
                                <c:choose>
                                    <c:when test="${not empty parents and parents.size() > 0}">
                                        Thuộc ${parents.size()} công ty mẹ
                                    </c:when>
                                    <c:otherwise>
                                        Cấp cao nhất trong chuỗi
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- 3. Visual Interactive Org Chart Tree View -->
                    <div class="hier-section-box">
                        <div class="hier-section-header">
                            <h3 class="hier-section-title">
                                <i class="fa-solid fa-diagram-project"></i>
                                Sơ đồ cây phân cấp cấu trúc Tập đoàn (Visual Hierarchy Map)
                            </h3>
                            <span style="font-size: 13px; color: var(--crm-slate-500); font-weight: 600;">
                                <i class="fa-solid fa-circle-nodes" style="color: var(--crm-blue-600); margin-right: 4px;"></i>
                                Cấu trúc liên kết trực quan
                            </span>
                        </div>
                        <div class="hier-tree-canvas">
                            
                            <!-- Level 1: Parent Companies (if any) -->
                            <c:if test="${not empty parents and parents.size() > 0}">
                                <div class="tree-level">
                                    <c:forEach var="rel" items="${parents}">
                                        <div class="tree-node node-parent">
                                            <span class="node-badge-tag node-tag-parent">
                                                <i class="fa-solid fa-crown"></i> Công ty mẹ
                                            </span>
                                            <div class="node-title">
                                                <a href="${pageContext.request.contextPath}/customers/hierarchy?id=${rel.parentCustomer.customerId}">
                                                    <c:out value="${rel.parentCustomer.customerName}"/>
                                                </a>
                                            </div>
                                            <div class="node-details">
                                                <span>ID: #${rel.parentCustomer.customerId}</span>
                                                <span>•</span>
                                                <span>${rel.relationshipType}</span>
                                            </div>
                                            <div class="node-actions">
                                                <a href="${pageContext.request.contextPath}/customers/360?id=${rel.parentCustomer.customerId}" class="btn-action-icon btn-action-view">
                                                    <i class="fa-solid fa-eye"></i> Customer 360
                                                </a>
                                                <a href="${pageContext.request.contextPath}/customers/hierarchy?id=${rel.parentCustomer.customerId}" class="btn-action-icon btn-action-view" style="background: #f1f5f9; color: #334155;">
                                                    <i class="fa-solid fa-sitemap"></i> Cây phân cấp
                                                </a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                                <div class="tree-connector">
                                    <div class="tree-connector-line"></div>
                                    <i class="fa-solid fa-angle-down"></i>
                                </div>
                            </c:if>

                            <!-- Level 2: Current Selected Customer (Focus Node) -->
                            <div class="tree-level">
                                <div class="tree-node node-current">
                                    <span class="node-badge-tag node-tag-current">
                                        <i class="fa-solid fa-location-dot"></i> Đang xem trọng tâm
                                    </span>
                                    <div class="node-title" style="font-size: 16px; color: var(--crm-blue-700);">
                                        <c:out value="${customer.customerName}"/>
                                    </div>
                                    <div class="node-details">
                                        <span>ID: #${customer.customerId}</span>
                                        <span>•</span>
                                        <span>MST: <c:out value="${not empty customer.taxCode ? customer.taxCode : '---'}"/></span>
                                    </div>
                                    <div class="node-actions">
                                        <span style="font-size: 12.5px; font-weight: 700; color: var(--crm-blue-600);">
                                            <i class="fa-solid fa-chart-line"></i> Trụ sở chính / Điểm gốc
                                        </span>
                                        <a href="${pageContext.request.contextPath}/customers/360?id=${customer.customerId}" class="btn-action-icon btn-action-view">
                                            <i class="fa-solid fa-arrow-up-right-from-square"></i> Mở hồ sơ 360
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- Level 3: Subsidiaries & Branches (if any) -->
                            <c:if test="${not empty children and children.size() > 0}">
                                <div class="tree-connector">
                                    <i class="fa-solid fa-angle-down"></i>
                                    <div class="tree-connector-line"></div>
                                </div>

                                <div class="tree-level">
                                    <c:forEach var="rel" items="${children}">
                                        <div class="tree-node node-child">
                                            <c:choose>
                                                <c:when test="${rel.relationshipType == 'BRANCH'}">
                                                    <span class="node-badge-tag node-tag-branch">
                                                        <i class="fa-solid fa-code-branch"></i> Chi nhánh
                                                    </span>
                                                </c:when>
                                                <c:when test="${rel.relationshipType == 'MEMBER'}">
                                                    <span class="node-badge-tag node-tag-member">
                                                        <i class="fa-solid fa-handshake"></i> Thành viên
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="node-badge-tag node-tag-child">
                                                        <i class="fa-solid fa-building-circle-check"></i> Công ty con
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <div class="node-title">
                                                <a href="${pageContext.request.contextPath}/customers/360?id=${rel.childCustomer.customerId}">
                                                    <c:out value="${rel.childCustomer.customerName}"/>
                                                </a>
                                            </div>
                                            <div class="node-details">
                                                <span>ID: #${rel.childCustomer.customerId}</span>
                                                <span>•</span>
                                                <span>MST: <c:out value="${not empty rel.childCustomer.taxCode ? rel.childCustomer.taxCode : '---'}"/></span>
                                            </div>
                                            <div class="node-actions">
                                                <a href="${pageContext.request.contextPath}/customers/360?id=${rel.childCustomer.customerId}" class="btn-action-icon btn-action-view">
                                                    <i class="fa-solid fa-eye"></i> Xem 360
                                                </a>
                                                <form action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="margin: 0;">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                                    <input type="hidden" name="customerId" value="${customer.customerId}">
                                                    <button type="submit" class="btn-action-icon btn-action-delete" title="Gỡ bỏ liên kết này" onclick="return confirm('Bạn có chắc chắn muốn xóa quan hệ công ty con này?')">
                                                        <i class="fa-solid fa-trash-can"></i> Gỡ bỏ
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <c:if test="${empty parents && empty children}">
                                <div class="hier-empty-box" style="margin-top: 10px;">
                                    <i class="fa-solid fa-network-wired" style="font-size: 32px; color: #cbd5e1;"></i>
                                    <span>Doanh nghiệp này chưa có liên kết công ty mẹ hoặc công ty con nào trong hệ thống.</span>
                                </div>
                            </c:if>

                        </div>
                    </div>

                    <!-- 4. Detailed 2-Column Management Tables -->
                    <div class="hier-grid-2col">

                        <!-- Parent Companies Column -->
                        <div class="hier-section-box">
                            <div class="hier-section-header">
                                <h3 class="hier-section-title">
                                    <i class="fa-solid fa-building-flag" style="color: #2563eb;"></i>
                                    Công ty mẹ trực tiếp
                                </h3>
                                <span class="hier-id-pill" style="background: #eff6ff; color: #1e3a8a;">
                                    ${not empty parents ? parents.size() : 0} công ty
                                </span>
                            </div>
                            <c:choose>
                                <c:when test="${not empty parents and parents.size() > 0}">
                                    <ul class="hier-entity-list">
                                        <c:forEach var="rel" items="${parents}">
                                            <li class="hier-entity-item">
                                                <div class="hier-entity-left">
                                                    <div class="hier-entity-icon icon-parent-blue">
                                                        <i class="fa-solid fa-crown"></i>
                                                    </div>
                                                    <div class="hier-entity-info">
                                                        <h4>
                                                            <a href="${pageContext.request.contextPath}/customers/360?id=${rel.parentCustomer.customerId}">
                                                                <c:out value="${rel.parentCustomer.customerName}"/>
                                                            </a>
                                                        </h4>
                                                        <div class="hier-entity-meta">
                                                            <span>Mã: #${rel.parentCustomer.customerId}</span>
                                                            <span>•</span>
                                                            <span class="node-badge-tag node-tag-parent" style="margin: 0;">${rel.relationshipType}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="hier-item-btns">
                                                    <a href="${pageContext.request.contextPath}/customers/hierarchy?id=${rel.parentCustomer.customerId}" class="btn-action-icon btn-action-view" title="Xem cây tập đoàn của công ty này">
                                                        <i class="fa-solid fa-sitemap"></i> Cây
                                                    </a>
                                                    <form action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="margin: 0;">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                                        <input type="hidden" name="customerId" value="${customer.customerId}">
                                                        <button type="submit" class="btn-action-icon btn-action-delete" title="Hủy liên kết công ty mẹ" onclick="return confirm('Bạn có chắc chắn muốn hủy liên kết công ty mẹ này?')">
                                                            <i class="fa-solid fa-trash-can"></i> Hủy
                                                        </button>
                                                    </form>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="hier-empty-box">
                                        <i class="fa-regular fa-building"></i>
                                        <span>Không có công ty mẹ trực tiếp</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Subsidiaries Column -->
                        <div class="hier-section-box">
                            <div class="hier-section-header">
                                <h3 class="hier-section-title">
                                    <i class="fa-solid fa-sitemap" style="color: var(--crm-emerald-600);"></i>
                                    Công ty con & Chi nhánh thành viên
                                </h3>
                                <span class="hier-id-pill" style="background: #ecfdf5; color: #047857; border-color: #a7f3d0;">
                                    ${not empty children ? children.size() : 0} đơn vị
                                </span>
                            </div>
                            <c:choose>
                                <c:when test="${not empty children and children.size() > 0}">
                                    <ul class="hier-entity-list">
                                        <c:forEach var="rel" items="${children}">
                                            <li class="hier-entity-item">
                                                <div class="hier-entity-left">
                                                    <div class="hier-entity-icon icon-child-green">
                                                        <i class="fa-solid fa-network-wired"></i>
                                                    </div>
                                                    <div class="hier-entity-info">
                                                        <h4>
                                                            <a href="${pageContext.request.contextPath}/customers/360?id=${rel.childCustomer.customerId}">
                                                                <c:out value="${rel.childCustomer.customerName}"/>
                                                            </a>
                                                        </h4>
                                                        <div class="hier-entity-meta">
                                                            <span>Mã: #${rel.childCustomer.customerId}</span>
                                                            <span>•</span>
                                                            <c:choose>
                                                                <c:when test="${rel.relationshipType == 'BRANCH'}">
                                                                    <span class="node-badge-tag node-tag-branch" style="margin: 0;">Chi nhánh</span>
                                                                </c:when>
                                                                <c:when test="${rel.relationshipType == 'MEMBER'}">
                                                                    <span class="node-badge-tag node-tag-member" style="margin: 0;">Thành viên</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="node-badge-tag node-tag-child" style="margin: 0;">Công ty con</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="hier-item-btns">
                                                    <a href="${pageContext.request.contextPath}/customers/360?id=${rel.childCustomer.customerId}" class="btn-action-icon btn-action-view" title="Xem Customer 360">
                                                        <i class="fa-solid fa-chart-pie"></i> 360
                                                    </a>
                                                    <form action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="margin: 0;">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                                        <input type="hidden" name="customerId" value="${customer.customerId}">
                                                        <button type="submit" class="btn-action-icon btn-action-delete" title="Xóa quan hệ công ty con" onclick="return confirm('Bạn có chắc chắn muốn hủy liên kết công ty con này?')">
                                                            <i class="fa-solid fa-trash-can"></i> Xóa
                                                        </button>
                                                    </form>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="hier-empty-box">
                                        <i class="fa-solid fa-network-wired"></i>
                                        <span>Chưa có công ty con hoặc chi nhánh nào</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </div>

                    <!-- 5. Add / Link Relationship Form Card -->
                    <div class="hier-form-card">
                        <div style="margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between;">
                            <div>
                                <h3 style="margin: 0 0 6px 0; font-size: 18px; font-weight: 800; color: var(--crm-navy-900); display: flex; align-items: center; gap: 10px;">
                                    <i class="fa-solid fa-link" style="color: var(--crm-blue-600);"></i>
                                    Thiết lập & Khai báo quan hệ Tập đoàn mới
                                </h3>
                                <p style="margin: 0; font-size: 13.5px; color: var(--crm-slate-500);">
                                    Gắn kết quan hệ công ty mẹ - con để theo dõi doanh số tổng hợp và phân cấp hệ thống khách hàng
                                </p>
                            </div>
                        </div>

                        <form id="addRelForm" action="${pageContext.request.contextPath}/customers/hierarchy" method="post">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="customerId" value="${customer.customerId}">

                            <div class="hier-form-grid">
                                <div class="form-field">
                                    <label for="parentId">
                                        <i class="fa-solid fa-crown" style="color: #2563eb;"></i> Công ty mẹ (Parent Entity):
                                    </label>
                                    <select id="parentId" name="parentId" class="crm-input-select">
                                        <c:forEach var="cItem" items="${allCustomers}">
                                            <option value="${cItem.customerId}" ${cItem.customerId == customer.customerId ? 'selected' : ''}>
                                                <c:out value="${cItem.customerName}"/> (ID: #${cItem.customerId})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-field">
                                    <label for="childId">
                                        <i class="fa-solid fa-sitemap" style="color: var(--crm-emerald-600);"></i> Công ty con / Chi nhánh (Child Entity):
                                    </label>
                                    <select id="childId" name="childId" class="crm-input-select" required>
                                        <option value="">-- Chọn khách hàng liên kết --</option>
                                        <c:forEach var="cItem" items="${allCustomers}">
                                            <c:if test="${cItem.customerId != customer.customerId}">
                                                <option value="${cItem.customerId}">
                                                    <c:out value="${cItem.customerName}"/> (ID: #${cItem.customerId})
                                                </option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-field">
                                    <label for="relationshipType">
                                        <i class="fa-solid fa-tags" style="color: #d97706;"></i> Loại hình quan hệ:
                                    </label>
                                    <select id="relationshipType" name="relationshipType" class="crm-input-select">
                                        <option value="SUBSIDIARY">Công ty con (SUBSIDIARY)</option>
                                        <option value="BRANCH">Chi nhánh trực thuộc (BRANCH)</option>
                                        <option value="MEMBER">Công ty thành viên liên kết (MEMBER)</option>
                                    </select>
                                </div>
                            </div>

                            <div style="display: flex; justify-content: flex-end; align-items: center; gap: 12px;">
                                <button type="submit" class="btn-submit-save">
                                    <i class="fa-solid fa-circle-check"></i> Lưu & Thiết lập quan hệ
                                </button>
                            </div>
                        </form>
                    </div>

                </c:when>
                <c:otherwise>
                    <!-- No Customer Selected State -->
                    <div class="hier-header-card" style="padding: 60px 40px; text-align: center; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                        <div style="width: 72px; height: 72px; border-radius: 50%; background: #fffbeb; color: #f59e0b; display: flex; align-items: center; justify-content: center; font-size: 32px; margin-bottom: 20px;">
                            <i class="fa-solid fa-building-circle-exclamation"></i>
                        </div>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--crm-navy-900); margin: 0 0 10px 0;">Chưa chọn khách hàng</h2>
                        <p style="font-size: 14.5px; color: var(--crm-slate-500); max-width: 500px; margin: 0 0 24px 0;">
                            Vui lòng chọn một khách hàng từ danh sách để xem sơ đồ phân cấp và tổng giá trị hợp đồng tập đoàn.
                        </p>
                        <a href="${pageContext.request.contextPath}/customers" class="btn-crm-pill btn-crm-primary">
                            <i class="fa-solid fa-arrow-left"></i> Về danh sách khách hàng
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('addRelForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            var parentId = document.getElementById('parentId').value;
            var childId = document.getElementById('childId').value;
            if (!childId) {
                (typeof window.showToast === 'function' ? window.showToast('warning', 'Vui lòng chọn công ty con.') : window.alert('Vui lòng chọn công ty con.'));
                e.preventDefault();
                return false;
            }
            if (parentId === childId) {
                (typeof window.showToast === 'function' ? window.showToast('warning', 'Công ty mẹ và công ty con không được là cùng một khách hàng!') : window.alert('Công ty mẹ và công ty con không được là cùng một khách hàng!'));
                e.preventDefault();
                return false;
            }
        });
    }
});
</script>
</body>
</html>
