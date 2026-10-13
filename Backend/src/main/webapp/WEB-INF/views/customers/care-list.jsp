<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chăm sóc khách hàng định kỳ | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        /* ==========================================================================
           Executive Luxury CRM - Customer Periodic Care Interface
           ========================================================================== */
        :root {
            --care-navy-900: #0f172a;
            --care-navy-800: #1e293b;
            --care-primary: #1e3a8a;
            --care-primary-hover: #172554;
            --care-accent-blue: #2563eb;
            --care-accent-blue-light: #eff6ff;
            --care-emerald: #10b981;
            --care-emerald-light: #ecfdf5;
            --care-emerald-border: #a7f3d0;
            --care-amber: #f59e0b;
            --care-amber-light: #fffbeb;
            --care-amber-border: #fde68a;
            --care-rose: #f43f5e;
            --care-rose-light: #fff1f2;
            --care-rose-border: #fecdd3;
            --care-purple: #7c3aed;
            --care-purple-light: #f5f3ff;
            --care-slate: #64748b;
            --care-slate-light: #f1f5f9;
            --care-surface: #ffffff;
            --care-bg: #f8fafc;
            --care-border: #e2e8f0;
            --care-border-subtle: #f1f5f9;
            --care-radius-sm: 8px;
            --care-radius-md: 12px;
            --care-radius-lg: 16px;
            --care-radius-xl: 20px;
            --care-shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --care-shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.07), 0 2px 4px -2px rgba(15, 23, 42, 0.04);
            --care-shadow-lg: 0 10px 25px -3px rgba(30, 58, 138, 0.09), 0 4px 6px -4px rgba(15, 23, 42, 0.03);
            --care-shadow-glow: 0 0 15px rgba(37, 99, 235, 0.25);
        }

        .care-page-container {
            max-width: 1400px;
            margin: 0 auto;
            padding-bottom: 60px;
        }

        /* Modern Breadcrumbs */
        .exec-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--care-slate);
            margin-bottom: 16px;
        }
        .exec-breadcrumb a {
            color: var(--care-slate);
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .exec-breadcrumb a:hover {
            color: var(--care-primary);
        }
        .exec-breadcrumb .sep {
            color: #cbd5e1;
            font-size: 11px;
        }
        .exec-breadcrumb .current {
            color: var(--care-accent-blue);
            font-weight: 600;
        }

        /* Hero Header Card */
        .exec-hero-header {
            background: #ffffff;
            border: 1px solid var(--care-border);
            border-radius: var(--care-radius-lg);
            padding: 24px 28px;
            box-shadow: var(--care-shadow-sm);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            overflow: hidden;
        }
        .exec-hero-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(180deg, #2563eb 0%, #7c3aed 100%);
        }
        .exec-hero-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .exec-hero-icon {
            width: 58px;
            height: 58px;
            border-radius: 16px;
            background: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 4px 14px rgba(37, 99, 235, 0.25);
            flex-shrink: 0;
        }
        .exec-hero-title h1 {
            margin: 0;
            font-size: 22px;
            font-weight: 800;
            color: var(--care-navy-900);
            letter-spacing: -0.02em;
        }
        .exec-hero-title p {
            margin: 4px 0 0 0;
            font-size: 13.5px;
            color: var(--care-slate);
            line-height: 1.45;
        }
        .exec-hero-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 6px;
            font-size: 12.5px;
            color: var(--care-slate);
        }
        .hero-pulse-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 3px 10px;
            border-radius: 20px;
            background: var(--care-emerald-light);
            color: #047857;
            font-weight: 600;
            font-size: 11.5px;
            border: 1px solid var(--care-emerald-border);
        }
        .hero-pulse-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #10b981;
            box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.25);
            animation: pulse-animation 2s infinite;
        }
        @keyframes pulse-animation {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.5); }
            70% { box-shadow: 0 0 0 6px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        /* Metric KPI Summary Cards Grid */
        .exec-metric-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .exec-metric-card {
            background: #ffffff;
            border: 1px solid var(--care-border);
            border-radius: var(--care-radius-md);
            padding: 20px;
            box-shadow: var(--care-shadow-sm);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: all 0.2s ease;
            position: relative;
        }
        .exec-metric-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--care-shadow-md);
            border-color: #cbd5e1;
        }
        .metric-icon-wrap {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }
        .metric-icon-rose { background: var(--care-rose-light); color: var(--care-rose); }
        .metric-icon-emerald { background: var(--care-emerald-light); color: var(--care-emerald); }
        .metric-icon-indigo { background: #e0e7ff; color: #4338ca; }
        .metric-icon-amber { background: var(--care-amber-light); color: var(--care-amber); }
        .metric-content {
            flex: 1;
            min-width: 0;
        }
        .metric-label {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--care-slate);
            margin-bottom: 4px;
        }
        .metric-value {
            font-size: 22px;
            font-weight: 800;
            color: var(--care-navy-900);
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .metric-sub {
            font-size: 11.5px;
            color: #94a3b8;
            margin-top: 4px;
        }

        /* Threshold Configuration & Filter Control Card */
        .exec-control-card {
            background: #ffffff;
            border: 1px solid var(--care-border);
            border-radius: var(--care-radius-lg);
            padding: 20px 24px;
            box-shadow: var(--care-shadow-sm);
            margin-bottom: 24px;
        }
        .control-top-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            padding-bottom: 18px;
            border-bottom: 1px solid var(--care-border-subtle);
        }
        .config-title-group {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .config-badge-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: #eff6ff;
            color: #2563eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }
        .config-title-text h4 {
            margin: 0;
            font-size: 15px;
            font-weight: 700;
            color: var(--care-navy-900);
        }
        .config-title-text p {
            margin: 2px 0 0 0;
            font-size: 12px;
            color: var(--care-slate);
        }

        .config-form-inline {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .config-presets-group {
            display: flex;
            align-items: center;
            gap: 6px;
            background: #f8fafc;
            padding: 4px;
            border-radius: var(--care-radius-sm);
            border: 1px solid #e2e8f0;
        }
        .preset-btn {
            background: transparent;
            border: none;
            padding: 5px 12px;
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .preset-btn:hover {
            color: var(--care-primary);
            background: #ffffff;
        }
        .preset-btn.active {
            background: #ffffff;
            color: var(--care-accent-blue);
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            border: 1px solid #cbd5e1;
        }

        .config-input-box {
            display: flex;
            align-items: center;
            border: 1.5px solid #cbd5e1;
            border-radius: var(--care-radius-sm);
            background: #ffffff;
            overflow: hidden;
            transition: border-color 0.15s ease;
        }
        .config-input-box:focus-within {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
        }
        .config-input-prefix {
            padding: 0 10px;
            font-size: 12.5px;
            font-weight: 700;
            color: #64748b;
            background: #f8fafc;
            border-right: 1px solid #e2e8f0;
            height: 38px;
            display: flex;
            align-items: center;
        }
        .config-number-input {
            width: 65px;
            border: none;
            outline: none;
            padding: 6px 8px;
            font-size: 14px;
            font-weight: 700;
            color: var(--care-navy-900);
            text-align: center;
        }
        .config-input-suffix {
            padding-right: 12px;
            font-size: 12.5px;
            font-weight: 600;
            color: #64748b;
        }

        .btn-config-save {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            border: none;
            padding: 0 18px;
            height: 38px;
            border-radius: var(--care-radius-sm);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            transition: all 0.2s ease;
            box-shadow: 0 2px 5px rgba(37, 99, 235, 0.25);
        }
        .btn-config-save:hover {
            background: linear-gradient(135deg, #172554 0%, #1d4ed8 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.35);
        }
        .btn-config-save:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        /* Search & Filter Subbar */
        .control-sub-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 16px;
        }
        .care-search-box {
            position: relative;
            flex: 1;
            min-width: 280px;
            max-width: 480px;
        }
        .care-search-input {
            width: 100%;
            height: 38px;
            padding: 8px 12px 8px 38px;
            border: 1px solid #cbd5e1;
            border-radius: var(--care-radius-sm);
            font-size: 13px;
            color: var(--care-navy-900);
            background: #ffffff;
            transition: all 0.15s ease;
        }
        .care-search-input:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }
        .care-search-icon {
            position: absolute;
            top: 50%;
            left: 12px;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 14px;
        }
        .filter-tags-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-tag-pill {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            background: #f1f5f9;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .filter-tag-pill:hover {
            color: var(--care-navy-900);
            background: #e2e8f0;
        }
        .filter-tag-pill.active {
            color: #2563eb;
            background: #eff6ff;
            border-color: #bfdbfe;
        }

        /* Modern Table Card */
        .exec-table-card {
            background: #ffffff;
            border: 1px solid var(--care-border);
            border-radius: var(--care-radius-lg);
            box-shadow: var(--care-shadow-sm);
            overflow: hidden;
            margin-bottom: 24px;
        }
        .exec-table-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--care-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #ffffff;
        }
        .exec-table-header h3 {
            margin: 0;
            font-size: 15px;
            font-weight: 700;
            color: var(--care-navy-900);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .sort-order-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 11.5px;
            font-weight: 600;
            color: #6366f1;
            background: #eef2ff;
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid #e0e7ff;
        }

        .exec-data-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 13.5px;
        }
        .exec-data-table thead th {
            background: #f8fafc;
            color: #475569;
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 14px 18px;
            border-bottom: 1px solid var(--care-border);
            text-align: left;
            white-space: nowrap;
        }
        .exec-data-table tbody tr {
            transition: all 0.2s ease;
        }
        .exec-data-table tbody tr:hover {
            background: #f8fafc;
        }
        .exec-data-table tbody td {
            padding: 16px 18px;
            border-bottom: 1px solid #f1f5f9;
            color: var(--care-navy-900);
            vertical-align: middle;
        }
        .exec-data-table tbody tr:last-child td {
            border-bottom: none;
        }

        /* Customer Cell Elements */
        .customer-meta-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .customer-squircle-avatar {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 14px;
            flex-shrink: 0;
            box-shadow: 0 2px 6px rgba(37, 99, 235, 0.2);
        }
        .customer-info-box h5 {
            margin: 0;
            font-size: 14px;
            font-weight: 700;
            color: var(--care-navy-900);
        }
        .customer-info-box a {
            color: var(--care-navy-900);
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .customer-info-box a:hover {
            color: var(--care-accent-blue);
        }
        .customer-code-sub {
            margin: 2px 0 0 0;
            font-size: 11.5px;
            color: #94a3b8;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        }

        /* ID Badge */
        .badge-id-mono {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 11.5px;
            font-weight: 700;
            color: #64748b;
            background: #f1f5f9;
            padding: 3px 8px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
        }

        /* Phone Badge */
        .phone-badge-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12.5px;
            font-weight: 600;
            color: #475569;
            text-decoration: none;
            padding: 4px 8px;
            border-radius: 6px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            transition: all 0.15s ease;
        }
        .phone-badge-link:hover {
            background: #eff6ff;
            color: #2563eb;
            border-color: #bfdbfe;
        }

        /* Owner Badge */
        .owner-chip {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 12.5px;
            font-weight: 600;
            color: #334155;
        }
        .owner-circle-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: #e0e7ff;
            color: #3730a3;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
        }

        /* Inactive Days Urgency Badge */
        .urgency-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }
        .urgency-badge.critical {
            background: var(--care-rose-light);
            color: #e11d48;
            border: 1px solid var(--care-rose-border);
        }
        .urgency-badge.warning {
            background: var(--care-amber-light);
            color: #b45309;
            border: 1px solid var(--care-amber-border);
        }

        /* Contract Value */
        .contract-value-cell {
            font-size: 14.5px;
            font-weight: 800;
            color: #0f172a;
            white-space: nowrap;
        }
        .contract-high-tag {
            display: block;
            font-size: 11px;
            font-weight: 600;
            color: #059669;
            margin-top: 2px;
        }

        /* Care Status Pill */
        .status-pill-care {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            background: #fff1f2;
            color: #e11d48;
            border: 1px solid #fecdd3;
        }
        .status-pill-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #e11d48;
        }

        /* Action Buttons */
        .action-cell-flex {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-care-contacted {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border: none;
            padding: 7px 14px;
            border-radius: var(--care-radius-sm);
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            box-shadow: 0 2px 5px rgba(16, 185, 129, 0.25);
            white-space: nowrap;
        }
        .btn-care-contacted:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(16, 185, 129, 0.35);
        }
        .btn-care-contacted:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        .btn-care-detail {
            width: 32px;
            height: 32px;
            border-radius: var(--care-radius-sm);
            background: #f1f5f9;
            color: #64748b;
            border: 1px solid #e2e8f0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-care-detail:hover {
            background: #eff6ff;
            color: #2563eb;
            border-color: #bfdbfe;
        }

        /* Empty State */
        .care-empty-state {
            text-align: center;
            padding: 60px 20px;
        }
        .empty-state-squircle {
            width: 72px;
            height: 72px;
            border-radius: 22px;
            background: var(--care-emerald-light);
            color: var(--care-emerald);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            margin: 0 auto 16px auto;
            border: 1px solid var(--care-emerald-border);
        }
        .care-empty-state h4 {
            margin: 0;
            font-size: 18px;
            font-weight: 800;
            color: var(--care-navy-900);
        }
        .care-empty-state p {
            margin: 6px auto 0 auto;
            font-size: 13.5px;
            color: var(--care-slate);
            max-width: 480px;
            line-height: 1.5;
        }

        /* Modern Pagination */
        .exec-pagination-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            border-top: 1px solid var(--care-border);
            background: #ffffff;
            flex-wrap: wrap;
            gap: 12px;
        }
        .pagination-meta {
            font-size: 13px;
            color: var(--care-slate);
        }
        .pagination-buttons {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .btn-page-step {
            padding: 6px 14px;
            border-radius: var(--care-radius-sm);
            font-size: 12.5px;
            font-weight: 600;
            color: #475569;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            text-decoration: none;
            transition: all 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-page-step:hover {
            background: #ffffff;
            color: var(--care-primary);
            border-color: var(--care-primary);
        }

        /* Interactive Modal */
        .exec-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            padding: 20px;
        }
        .exec-modal-overlay.active {
            display: flex;
        }
        .exec-modal-box {
            background: #ffffff;
            border-radius: var(--care-radius-xl);
            width: 100%;
            max-width: 500px;
            box-shadow: 0 20px 40px -10px rgba(15, 23, 42, 0.25);
            border: 1px solid var(--care-border);
            overflow: hidden;
            animation: modal-appear 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes modal-appear {
            from { opacity: 0; transform: scale(0.95) translateY(10px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }
        .modal-header-bar {
            padding: 20px 24px;
            border-bottom: 1px solid var(--care-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .modal-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .modal-icon-badge {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: var(--care-emerald-light);
            color: var(--care-emerald);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        .modal-header-left h4 {
            margin: 0;
            font-size: 16px;
            font-weight: 700;
            color: var(--care-navy-900);
        }
        .modal-close-btn {
            background: transparent;
            border: none;
            color: #94a3b8;
            font-size: 18px;
            cursor: pointer;
            padding: 4px;
            border-radius: 6px;
        }
        .modal-close-btn:hover {
            color: #334155;
            background: #f1f5f9;
        }
        .modal-body-content {
            padding: 24px;
        }
        .modal-customer-banner {
            background: #f8fafc;
            border: 1px solid var(--care-border);
            border-radius: var(--care-radius-md);
            padding: 14px 16px;
            margin-bottom: 18px;
        }
        .modal-customer-name {
            font-weight: 700;
            font-size: 15px;
            color: var(--care-navy-900);
            margin-bottom: 4px;
        }
        .modal-customer-hint {
            font-size: 12px;
            color: #64748b;
        }
        .modal-form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--care-navy-900);
            margin-bottom: 8px;
        }
        .modal-textarea {
            width: 100%;
            height: 90px;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: var(--care-radius-sm);
            font-size: 13px;
            color: var(--care-navy-900);
            resize: vertical;
            transition: all 0.15s ease;
        }
        .modal-textarea:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }
        .quick-note-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 8px;
        }
        .quick-chip {
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 4px 10px;
            font-size: 11.5px;
            color: #475569;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .quick-chip:hover {
            background: #e0e7ff;
            color: #3730a3;
            border-color: #c7d2fe;
        }
        .modal-footer-bar {
            padding: 16px 24px;
            background: #f8fafc;
            border-top: 1px solid var(--care-border);
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
        }
        .btn-modal-cancel {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            color: #475569;
            padding: 8px 16px;
            border-radius: var(--care-radius-sm);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .btn-modal-cancel:hover {
            background: #f1f5f9;
            color: #1e293b;
        }
        .btn-modal-submit {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border: none;
            color: #ffffff;
            padding: 8px 20px;
            border-radius: var(--care-radius-sm);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.15s ease;
            box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
        }
        .btn-modal-submit:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
        }

        /* Floating Modern Toast */
        .exec-toast-container {
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 10000;
            display: flex;
            flex-direction: column;
            gap: 10px;
            pointer-events: none;
        }
        .exec-toast {
            pointer-events: auto;
            background: #ffffff;
            border-radius: var(--care-radius-md);
            padding: 14px 18px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.15);
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 300px;
            max-width: 420px;
            border-left: 4px solid #10b981;
            animation: toast-slide 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            transition: all 0.25s ease;
        }
        .exec-toast.danger {
            border-left-color: #e11d48;
        }
        @keyframes toast-slide {
            from { opacity: 0; transform: translateX(30px); }
            to { opacity: 1; transform: translateX(0); }
        }
        .toast-icon {
            font-size: 20px;
            flex-shrink: 0;
        }
        .toast-icon.success { color: #10b981; }
        .toast-icon.danger { color: #e11d48; }
        .toast-message-text {
            font-size: 13px;
            color: var(--care-navy-900);
            font-weight: 500;
            line-height: 1.4;
            flex: 1;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="content-container">
            <div class="care-page-container">
                
                <!-- Breadcrumbs -->
                <nav class="exec-breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> CRM</a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                    <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="current">Chăm sóc định kỳ</span>
                </nav>

                <!-- Hero Header Card -->
                <div class="exec-hero-header">
                    <div class="exec-hero-left">
                        <div class="exec-hero-icon">
                            <i class="fa-solid fa-heart-pulse"></i>
                        </div>
                        <div class="exec-hero-title">
                            <h1>Chăm sóc khách hàng định kỳ</h1>
                            <p>
                                Giám sát và tương tác chủ động với các khách hàng đã ký hợp đồng nhưng chưa ghi nhận tương tác quá <strong>${inactiveDays}</strong> ngày, tránh để bị lãng quên tới kỳ tái tục.
                            </p>
                            <div class="exec-hero-meta">
                                <span class="hero-pulse-badge">
                                    <span class="hero-pulse-dot"></span>
                                    Chế độ tự động lọc theo chu kỳ N = ${inactiveDays} ngày
                                </span>
                                <span>•</span>
                                <span>Sắp xếp tự động theo giá trị hợp đồng giảm dần</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- JSTL Calculation for Metrics -->
                <c:set var="totalContractValue" value="0" />
                <c:set var="criticalOverdueCount" value="0" />
                <c:set var="maxDaysInactive" value="0" />
                <c:forEach var="item" items="${careList}">
                    <c:set var="totalContractValue" value="${totalContractValue + (not empty item.contractValue ? item.contractValue : 0)}" />
                    <c:if test="${item.daysInactive >= (inactiveDays * 2)}">
                        <c:set var="criticalOverdueCount" value="${criticalOverdueCount + 1}" />
                    </c:if>
                    <c:if test="${item.daysInactive > maxDaysInactive}">
                        <c:set var="maxDaysInactive" value="${item.daysInactive}" />
                    </c:if>
                </c:forEach>
                <c:set var="totalCustomersCount" value="${fn:length(careList)}" />

                <!-- Metric KPI Summary Cards Grid -->
                <div class="exec-metric-grid">
                    <!-- Metric 1: Total Attention Needed -->
                    <div class="exec-metric-card">
                        <div class="metric-icon-wrap metric-icon-rose">
                            <i class="fa-solid fa-bell"></i>
                        </div>
                        <div class="metric-content">
                            <div class="metric-label">Cần chăm sóc ngay</div>
                            <div class="metric-value" id="kpi-customer-count">${totalCustomersCount} khách hàng</div>
                            <div class="metric-sub">Chưa tương tác $\ge$ ${inactiveDays} ngày</div>
                        </div>
                    </div>

                    <!-- Metric 2: Total Contract Value at Risk -->
                    <div class="exec-metric-card">
                        <div class="metric-icon-wrap metric-icon-emerald">
                            <i class="fa-solid fa-file-invoice-dollar"></i>
                        </div>
                        <div class="metric-content">
                            <div class="metric-label">Tổng giá trị hợp đồng</div>
                            <div class="metric-value">
                                <fmt:formatNumber value="${totalContractValue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </div>
                            <div class="metric-sub">Bảo toàn doanh số gia hạn</div>
                        </div>
                    </div>

                    <!-- Metric 3: Current Configured Threshold -->
                    <div class="exec-metric-card">
                        <div class="metric-icon-wrap metric-icon-indigo">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </div>
                        <div class="metric-content">
                            <div class="metric-label">Thời hạn cấu hình (N)</div>
                            <div class="metric-value">${inactiveDays} ngày</div>
                            <div class="metric-sub">Có thể tùy chỉnh linh hoạt</div>
                        </div>
                    </div>

                    <!-- Metric 4: Critical Overdue Priority -->
                    <div class="exec-metric-card">
                        <div class="metric-icon-wrap metric-icon-amber">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>
                        <div class="metric-content">
                            <div class="metric-label">Chưa liên hệ lâu nhất</div>
                            <div class="metric-value">
                                <c:choose>
                                    <c:when test="${maxDaysInactive > 0}">${maxDaysInactive} ngày</c:when>
                                    <c:otherwise>0 ngày</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="metric-sub">Ưu tiên xử lý trước</div>
                        </div>
                    </div>
                </div>

                <!-- Threshold Configuration & Filter Control Card -->
                <div class="exec-control-card">
                    <!-- Top Row: N-Day Configuration Form -->
                    <div class="control-top-bar">
                        <div class="config-title-group">
                            <div class="config-badge-icon">
                                <i class="fa-solid fa-sliders"></i>
                            </div>
                            <div class="config-title-text">
                                <h4>Cấu hình chu kỳ chăm sóc (N ngày)</h4>
                                <p>Hệ thống tự động lọc ra khách hàng chưa có tương tác trong N ngày gần nhất</p>
                            </div>
                        </div>

                        <form action="${pageContext.request.contextPath}/customers/care/config" method="post" class="config-form-inline" id="formCareConfig" onsubmit="return handleConfigSubmit(this, event)">
                            <!-- Quick Preset Chips -->
                            <div class="config-presets-group" title="Chọn nhanh chu kỳ định kỳ">
                                <button type="button" class="preset-btn ${inactiveDays == 15 ? 'active' : ''}" onclick="applyPresetDays(15)">15 ngày</button>
                                <button type="button" class="preset-btn ${inactiveDays == 30 ? 'active' : ''}" onclick="applyPresetDays(30)">30 ngày</button>
                                <button type="button" class="preset-btn ${inactiveDays == 45 ? 'active' : ''}" onclick="applyPresetDays(45)">45 ngày</button>
                                <button type="button" class="preset-btn ${inactiveDays == 60 ? 'active' : ''}" onclick="applyPresetDays(60)">60 ngày</button>
                                <button type="button" class="preset-btn ${inactiveDays == 90 ? 'active' : ''}" onclick="applyPresetDays(90)">90 ngày</button>
                            </div>

                            <!-- Numeric Stepper Input -->
                            <div class="config-input-box">
                                <span class="config-input-prefix">N =</span>
                                <input type="number" id="inactiveDaysInput" name="inactiveDays" class="config-number-input" value="${inactiveDays}" min="1" max="365" required>
                                <span class="config-input-suffix">ngày</span>
                            </div>

                            <!-- Submit Config Button -->
                            <button type="submit" id="btnSaveConfig" class="btn-config-save">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu cấu hình
                            </button>
                        </form>
                    </div>

                    <!-- Bottom Row: Live Search & Filter Options -->
                    <div class="control-sub-bar">
                        <!-- Live Search Input -->
                        <div class="care-search-box">
                            <i class="fa-solid fa-magnifying-glass care-search-icon"></i>
                            <input type="text" id="careSearchInput" class="care-search-input" placeholder="Tìm theo tên doanh nghiệp, số điện thoại, người phụ trách..." onkeyup="filterCareTable()">
                        </div>

                        <!-- Filter Tag Buttons -->
                        <div class="filter-tags-wrap">
                            <span style="font-size: 12px; font-weight: 600; color: #94a3b8;">Lọc nhanh:</span>
                            <button type="button" class="filter-tag-pill active" onclick="setQuickFilter('ALL', this)">
                                <i class="fa-solid fa-list-check"></i> Tất cả (<span id="count-filter-all">${totalCustomersCount}</span>)
                            </button>
                            <button type="button" class="filter-tag-pill" onclick="setQuickFilter('URGENT', this)">
                                <i class="fa-solid fa-fire" style="color: #f43f5e;"></i> Quá 60 ngày
                            </button>
                            <button type="button" class="filter-tag-pill" onclick="setQuickFilter('HIGH_VALUE', this)">
                                <i class="fa-solid fa-gem" style="color: #10b981;"></i> Hợp đồng lớn (> 100M)
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Table Card Container -->
                <div class="exec-table-card">
                    <div class="exec-table-header">
                        <h3>
                            <i class="fa-solid fa-table-list" style="color: #2563eb;"></i> Danh sách khách hàng cần tương tác
                        </h3>
                        <div class="sort-order-badge">
                            <i class="fa-solid fa-arrow-down-wide-short"></i> Sắp xếp theo giá trị hợp đồng giảm dần
                        </div>
                    </div>

                    <div style="overflow-x: auto;">
                        <table class="exec-data-table" id="careDataTable">
                            <thead>
                                <tr>
                                    <th style="width: 70px; text-align: center;">ID</th>
                                    <th>Tên khách hàng</th>
                                    <th>SĐT liên hệ</th>
                                    <th>Người phụ trách</th>
                                    <th>Chưa tương tác</th>
                                    <th>Giá trị hợp đồng</th>
                                    <th style="text-align: center;">Trạng thái</th>
                                    <th style="text-align: center; width: 180px;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="care-table-body">
                                <c:choose>
                                    <c:when test="${not empty careList}">
                                        <c:forEach var="item" items="${careList}">
                                            <tr id="customer-row-${item.customerId}" 
                                                class="care-row-item"
                                                data-days="${item.daysInactive}"
                                                data-value="${not empty item.contractValue ? item.contractValue : 0}"
                                                data-search="${fn:toLowerCase(item.customerName)} ${fn:toLowerCase(item.phone)} ${fn:toLowerCase(item.ownerName)}">
                                                
                                                <!-- ID -->
                                                <td style="text-align: center;">
                                                    <span class="badge-id-mono">#${item.customerId}</span>
                                                </td>

                                                <!-- Customer Name -->
                                                <td>
                                                    <div class="customer-meta-cell">
                                                        <div class="customer-squircle-avatar">
                                                            <c:out value="${fn:toUpperCase(fn:substring(item.customerName, 0, 1))}"/>
                                                        </div>
                                                        <div class="customer-info-box">
                                                            <h5>
                                                                <a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}" title="Xem chi tiết khách hàng">
                                                                    <c:out value="${item.customerName}"/>
                                                                </a>
                                                            </h5>
                                                            <div class="customer-code-sub">Mã hồ sơ: KH-${item.customerId}</div>
                                                        </div>
                                                    </div>
                                                </td>

                                                <!-- Phone -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.phone}">
                                                            <a href="tel:${item.phone}" class="phone-badge-link" title="Bấm để gọi">
                                                                <i class="fa-solid fa-phone" style="font-size: 11px; color: #10b981;"></i>
                                                                <c:out value="${item.phone}"/>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #cbd5e1;">---</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- Owner -->
                                                <td>
                                                    <div class="owner-chip">
                                                        <div class="owner-circle-avatar">
                                                            <i class="fa-solid fa-user"></i>
                                                        </div>
                                                        <span><c:out value="${not empty item.ownerName ? item.ownerName : 'Chưa phân công'}"/></span>
                                                    </div>
                                                </td>

                                                <!-- Days Inactive -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.daysInactive >= 60}">
                                                            <span class="urgency-badge critical" title="Chưa có tương tác trong hơn 2 tháng">
                                                                <i class="fa-solid fa-triangle-exclamation"></i> ${item.daysInactive} ngày
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="urgency-badge warning" title="Cần sớm liên hệ tái kết nối">
                                                                <i class="fa-solid fa-clock"></i> ${item.daysInactive} ngày
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- Contract Value -->
                                                <td>
                                                    <div class="contract-value-cell">
                                                        <fmt:formatNumber value="${item.contractValue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                    </div>
                                                    <c:if test="${item.contractValue >= 100000000}">
                                                        <span class="contract-high-tag"><i class="fa-solid fa-circle-check"></i> Hợp đồng trọng điểm</span>
                                                    </c:if>
                                                </td>

                                                <!-- Status -->
                                                <td style="text-align: center;">
                                                    <span class="status-pill-care">
                                                        <span class="status-pill-dot"></span>
                                                        <c:out value="${item.careStatus}"/>
                                                    </span>
                                                </td>

                                                <!-- Action -->
                                                <td style="text-align: center;">
                                                    <div class="action-cell-flex">
                                                        <button type="button" 
                                                                class="btn-care-contacted" 
                                                                id="btn-care-${item.customerId}"
                                                                onclick="openContactModal(${item.customerId}, '<c:out value="${item.customerName}"/>', this)">
                                                            <i class="fa-solid fa-check-double"></i> Đã liên hệ
                                                        </button>
                                                        <a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}" 
                                                           class="btn-care-detail" 
                                                           title="Mở hồ sơ 360° khách hàng">
                                                            <i class="fa-solid fa-arrow-up-right-from-square"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8">
                                                <div class="care-empty-state">
                                                    <div class="empty-state-squircle">
                                                        <i class="fa-solid fa-circle-check"></i>
                                                    </div>
                                                    <h4>Tuyệt vời! Tất cả khách hàng đều đã được chăm sóc</h4>
                                                    <p>
                                                        Không có khách hàng nào bị gián đoạn tương tác quá <strong>${inactiveDays}</strong> ngày. Mối quan hệ và hợp đồng đang được duy trì rất tốt.
                                                    </p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Bar -->
                    <c:if test="${totalPages > 1}">
                        <div class="exec-pagination-bar">
                            <div class="pagination-meta">
                                Hiển thị trang <strong>${currentPage}</strong> trên tổng số <strong>${totalPages}</strong> trang
                            </div>
                            <div class="pagination-buttons">
                                <c:if test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/customers/care?inactiveDays=${inactiveDays}&page=${currentPage - 1}" class="btn-page-step">
                                        <i class="fa-solid fa-chevron-left"></i> Trước
                                    </a>
                                </c:if>
                                <c:if test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/customers/care?inactiveDays=${inactiveDays}&page=${currentPage + 1}" class="btn-page-step">
                                        Sau <i class="fa-solid fa-chevron-right"></i>
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </c:if>
                </div>

            </div>
        </div>
    </main>
</div>

<!-- Contact Confirmation & Note Modal -->
<div class="exec-modal-overlay" id="contactModalOverlay" onclick="closeContactModalOnOutside(event)">
    <div class="exec-modal-box">
        <div class="modal-header-bar">
            <div class="modal-header-left">
                <div class="modal-icon-badge">
                    <i class="fa-solid fa-headset"></i>
                </div>
                <h4>Ghi nhận chăm sóc khách hàng</h4>
            </div>
            <button type="button" class="modal-close-btn" onclick="closeContactModal()">&times;</button>
        </div>
        <div class="modal-body-content">
            <div class="modal-customer-banner">
                <div class="modal-customer-name" id="modalCustomerName">Tên doanh nghiệp</div>
                <div class="modal-customer-hint">
                    Hệ thống sẽ cập nhật ngày tương tác gần nhất thành hôm nay và đưa khách ra khỏi danh sách cần chăm sóc định kỳ.
                </div>
            </div>

            <div class="modal-form-group">
                <label for="contactNoteInput">Nội dung ghi chú tương tác (Tùy chọn):</label>
                <textarea id="contactNoteInput" class="modal-textarea" placeholder="Nhập tóm tắt nội dung cuộc gọi, nhu cầu gia hạn hoặc phản hồi của khách hàng..."></textarea>
                
                <div class="quick-note-chips">
                    <span class="quick-chip" onclick="appendNote('Đã gọi điện thoại hỏi thăm tình hình sử dụng dịch vụ')">+ Đã gọi điện</span>
                    <span class="quick-chip" onclick="appendNote('Đã gửi email trao đổi về kỳ hạn tái tục hợp đồng')">+ Đã gửi email</span>
                    <span class="quick-chip" onclick="appendNote('Đã hẹn gặp trực tiếp trao đổi kế hoạch nâng cấp')">+ Hẹn gặp</span>
                    <span class="quick-chip" onclick="appendNote('Khách hàng hài lòng, tiếp tục duy trì dịch vụ')">+ Khách hài lòng</span>
                </div>
            </div>
        </div>
        <div class="modal-footer-bar">
            <button type="button" class="btn-modal-cancel" onclick="closeContactModal()">Hủy</button>
            <button type="button" class="btn-modal-submit" id="btnConfirmContact" onclick="submitContactModal()">
                <i class="fa-solid fa-check"></i> Xác nhận đã liên hệ
            </button>
        </div>
    </div>
</div>

<!-- Floating Toast Container -->
<div class="exec-toast-container" id="toastContainer"></div>

<script>
let currentTargetCustomerId = null;
let currentTargetCustomerName = "";
let currentTargetBtn = null;
let currentFilterMode = 'ALL';

// Preset Threshold selection
function applyPresetDays(days) {
    const input = document.getElementById('inactiveDaysInput');
    if (input) {
        input.value = days;
    }
    document.querySelectorAll('.preset-btn').forEach(btn => btn.classList.remove('active'));
    if (event && event.target) {
        event.target.classList.add('active');
    }
}

// Config Submit Validation
function handleConfigSubmit(form, event) {
    const input = document.getElementById("inactiveDaysInput");
    const val = parseInt(input.value, 10);
    if (isNaN(val) || val <= 0 || val > 365) {
        if (event) event.preventDefault();
        showToast("Số ngày N phải là số nguyên dương từ 1 đến 365 ngày.", "danger");
        return false;
    }
    const btn = document.getElementById("btnSaveConfig");
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
    }
    return true;
}

// Modal open/close logic
function openContactModal(customerId, customerName, btn) {
    currentTargetCustomerId = customerId;
    currentTargetCustomerName = customerName;
    currentTargetBtn = btn;
    
    document.getElementById('modalCustomerName').textContent = customerName;
    document.getElementById('contactNoteInput').value = "Đã liên hệ chăm sóc định kỳ từ danh sách";
    document.getElementById('contactModalOverlay').classList.add('active');
    setTimeout(() => {
        document.getElementById('contactNoteInput').focus();
    }, 150);
}

function closeContactModal() {
    document.getElementById('contactModalOverlay').classList.remove('active');
    currentTargetCustomerId = null;
    currentTargetCustomerName = "";
    currentTargetBtn = null;
}

function closeContactModalOnOutside(e) {
    if (e.target.id === 'contactModalOverlay') {
        closeContactModal();
    }
}

function appendNote(text) {
    const el = document.getElementById('contactNoteInput');
    if (el) {
        if (!el.value || el.value === "Đã liên hệ chăm sóc định kỳ từ danh sách") {
            el.value = text;
        } else {
            el.value += "; " + text;
        }
        el.focus();
    }
}

// Submit Contacted via AJAX
function submitContactModal() {
    if (!currentTargetCustomerId) return;
    
    const customerId = currentTargetCustomerId;
    const customerName = currentTargetCustomerName;
    const note = document.getElementById('contactNoteInput').value.trim() || "Đã liên hệ chăm sóc định kỳ từ danh sách";
    const btnConfirm = document.getElementById('btnConfirmContact');
    const sourceBtn = currentTargetBtn;

    btnConfirm.disabled = true;
    btnConfirm.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang ghi nhận...';

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "${pageContext.request.contextPath}/customers/care/mark-contacted", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    xhr.setRequestHeader("Accept", "application/json");

    xhr.onload = function() {
        btnConfirm.disabled = false;
        btnConfirm.innerHTML = '<i class="fa-solid fa-check"></i> Xác nhận đã liên hệ';
        closeContactModal();

        if (xhr.status >= 200 && xhr.status < 300) {
            showToast("Đã ghi nhận chăm sóc khách hàng \"" + customerName + "\" thành công!", "success");
            
            const row = document.getElementById("customer-row-" + customerId);
            if (row) {
                row.style.transition = "all 0.4s cubic-bezier(0.16, 1, 0.3, 1)";
                row.style.opacity = "0";
                row.style.transform = "translateX(30px)";
                setTimeout(function() {
                    row.remove();
                    
                    // Update remaining rows count
                    const remainingRows = document.querySelectorAll("#care-table-body tr.care-row-item");
                    const countEl = document.getElementById('kpi-customer-count');
                    const filterAllEl = document.getElementById('count-filter-all');
                    if (countEl) countEl.textContent = remainingRows.length + " khách hàng";
                    if (filterAllEl) filterAllEl.textContent = remainingRows.length;

                    if (remainingRows.length === 0) {
                        window.location.reload();
                    }
                }, 400);
            }
        } else {
            let errorMsg = "Lỗi máy chủ (" + xhr.status + ")";
            try {
                const json = JSON.parse(xhr.responseText);
                if (json && json.message) errorMsg = json.message;
            } catch (e) {
                if (xhr.responseText) errorMsg = xhr.responseText;
            }
            showToast("Không thể ghi nhận: " + errorMsg, "danger");
        }
    };

    xhr.onerror = function() {
        btnConfirm.disabled = false;
        btnConfirm.innerHTML = '<i class="fa-solid fa-check"></i> Xác nhận đã liên hệ';
        closeContactModal();
        showToast("Lỗi kết nối mạng đến máy chủ!", "danger");
    };

    xhr.send("customerId=" + encodeURIComponent(customerId) + "&note=" + encodeURIComponent(note));
}

// Live Search & Quick Filter
function filterCareTable() {
    const query = (document.getElementById('careSearchInput').value || '').trim().toLowerCase();
    const rows = document.querySelectorAll('#care-table-body tr.care-row-item');

    rows.forEach(row => {
        const searchData = row.getAttribute('data-search') || '';
        const days = parseInt(row.getAttribute('data-days') || '0', 10);
        const val = parseFloat(row.getAttribute('data-value') || '0');

        let matchesSearch = !query || searchData.includes(query);
        let matchesFilter = true;

        if (currentFilterMode === 'URGENT') {
            matchesFilter = days >= 60;
        } else if (currentFilterMode === 'HIGH_VALUE') {
            matchesFilter = val >= 100000000;
        }

        if (matchesSearch && matchesFilter) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

function setQuickFilter(mode, btn) {
    currentFilterMode = mode;
    document.querySelectorAll('.filter-tag-pill').forEach(b => b.classList.remove('active'));
    if (btn) btn.classList.add('active');
    filterCareTable();
}

// Modern Toast Alert
function showToast(message, type = 'success') {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = 'exec-toast ' + (type === 'danger' ? 'danger' : 'success');
    
    const iconClass = type === 'danger' ? 'fa-triangle-exclamation toast-icon danger' : 'fa-circle-check toast-icon success';
    toast.innerHTML = '<i class="fa-solid ' + iconClass + '"></i><div class="toast-message-text">' + message + '</div>';

    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(-10px)';
        setTimeout(() => toast.remove(), 250);
    }, 4500);
}

// Handle URL success query param
<c:if test="${not empty param.success}">
window.addEventListener('DOMContentLoaded', () => {
    showToast("Đã cập nhật cấu hình thời hạn chăm sóc định kỳ thành công!", "success");
});
</c:if>
</script>
</body>
</html>
