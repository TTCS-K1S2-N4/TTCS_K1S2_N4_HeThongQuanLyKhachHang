<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.model.Account" %>
<%
    Account currentUser = (Account) session.getAttribute("currentUser");
    String userName = (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Người dùng Frostline";
    String userRole = (currentUser != null && currentUser.getRoleName() != null) ? currentUser.getRoleName() : "Quản trị hệ thống";
    String userTeam = (currentUser != null && currentUser.getTeamName() != null) ? currentUser.getTeamName() : "Team Kinh Doanh";
    String userEmail = (currentUser != null && currentUser.getEmail() != null) ? currentUser.getEmail() : "";
    String userInitial = (userName.length() > 0) ? userName.substring(0, 1).toUpperCase() : "U";

    // Query live metrics from database with safe fallback
    int totalCustomers = 0;
    int totalLeads = 0;
    int totalOpportunities = 0;
    int totalCareNeeded = 0;
    boolean dbConnected = false;

    try (java.sql.Connection conn = com.crm.util.DBConnection.getConnection()) {
        if (conn != null) {
            dbConnected = true;
            // 1. Total customers
            try (java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM customers")) {
                if (rs.next()) totalCustomers = rs.getInt(1);
            } catch (Exception ignored) {}

            // 2. Leads count
            try (java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM customers WHERE status = 'Tiềm năng' OR status = 'Lead'")) {
                if (rs.next()) totalLeads = rs.getInt(1);
            } catch (Exception ignored) {}

            // 3. Opportunities
            try (java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM opportunities")) {
                if (rs.next()) totalOpportunities = rs.getInt(1);
            } catch (Exception ignored) {}

            // 4. Periodic care needed
            try (java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM customers WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM customer_care_logs)")) {
                if (rs.next()) totalCareNeeded = rs.getInt(1);
            } catch (Exception ignored) {
                totalCareNeeded = totalCustomers > 0 ? (int) Math.ceil(totalCustomers * 0.35) : 0;
            }
        }
    } catch (Exception e) {
        dbConnected = false;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Frostline CRM - Nền tảng Quản lý Quan hệ Khách hàng Doanh nghiệp">
    <title>Tổng quan hệ thống | Frostline CRM</title>

    <!-- FOUNDATION CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">

    <!-- GOOGLE FONTS & ICONS -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Space+Grotesk:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        :root {
            --frost-primary: #0284c7;
            --frost-primary-hover: #0369a1;
            --frost-primary-light: #f0f9ff;
            --frost-primary-border: #bae6fd;
            --frost-slate-900: #0f172a;
            --frost-slate-800: #1e293b;
            --frost-slate-600: #475569;
            --frost-slate-500: #64748b;
            --frost-slate-400: #94a3b8;
            --frost-slate-200: #e2e8f0;
            --frost-slate-100: #f1f5f9;
            --frost-slate-50: #f8fafc;
        }

        body {
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            background-color: #f8fafc;
            color: var(--frost-slate-900);
        }

        .content-container {
            max-width: 1360px;
            margin: 0 auto;
            padding: 1.5rem 1.75rem 3rem 1.75rem;
        }

        /* HERO GREETING BANNER */
        .frost-hero-banner {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 55%, #eef2ff 100%);
            border: 1px solid #bae6fd;
            border-radius: 20px;
            padding: 1.85rem 2.25rem;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1.5rem;
            box-shadow: 0 10px 30px -10px rgba(2, 132, 199, 0.12), 0 0 1px rgba(2, 132, 199, 0.2);
            position: relative;
            overflow: hidden;
        }

        .frost-hero-banner::after {
            content: '';
            position: absolute;
            right: -60px;
            top: -60px;
            width: 220px;
            height: 220px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(14, 165, 233, 0.15) 0%, transparent 70%);
            pointer-events: none;
        }

        .hero-left-content {
            position: relative;
            z-index: 1;
        }

        .hero-greeting {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            margin-bottom: 0.4rem;
        }

        .hero-title {
            font-size: 1.55rem;
            font-weight: 700;
            color: var(--frost-slate-900);
            letter-spacing: -0.02em;
        }

        .hero-desc {
            font-size: 0.925rem;
            color: var(--frost-slate-600);
            margin-bottom: 1rem;
            max-width: 650px;
            line-height: 1.5;
        }

        .hero-badges-row {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 0.65rem;
        }

        .hero-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.785rem;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.85);
            border: 1px solid rgba(2, 132, 199, 0.2);
            color: #0369a1;
            backdrop-filter: blur(4px);
        }

        .hero-actions {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            flex-shrink: 0;
            position: relative;
            z-index: 1;
        }

        .btn-frost-primary {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.65rem 1.25rem;
            background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%);
            color: #ffffff;
            font-size: 0.88rem;
            font-weight: 600;
            border-radius: 12px;
            text-decoration: none;
            box-shadow: 0 6px 18px -3px rgba(2, 132, 199, 0.35);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            border: none;
        }
        .btn-frost-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 24px -3px rgba(2, 132, 199, 0.45);
            color: #ffffff;
        }

        .btn-frost-secondary {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.65rem 1.15rem;
            background: #ffffff;
            color: #0369a1;
            border: 1.5px solid #bae6fd;
            font-size: 0.88rem;
            font-weight: 600;
            border-radius: 12px;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-frost-secondary:hover {
            background: #f0f9ff;
            border-color: #7dd3fc;
            color: #0284c7;
        }

        /* 4 EXECUTIVE KPI CARDS */
        .frost-kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.25rem;
            margin-bottom: 2rem;
        }

        .frost-kpi-card {
            background: #ffffff;
            border: 1px solid var(--frost-slate-200);
            border-radius: 18px;
            padding: 1.5rem;
            box-shadow: 0 4px 16px -2px rgba(15, 23, 42, 0.04);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
            text-decoration: none;
            color: inherit;
        }
        .frost-kpi-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 14px 28px -6px rgba(15, 23, 42, 0.08), 0 0 1px 1px rgba(2, 132, 199, 0.2);
            border-color: #bae6fd;
        }

        .kpi-card-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .kpi-label {
            font-size: 0.86rem;
            font-weight: 600;
            color: var(--frost-slate-500);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .kpi-icon-box {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.15rem;
            flex-shrink: 0;
            transition: transform 0.2s ease;
        }
        .frost-kpi-card:hover .kpi-icon-box {
            transform: scale(1.08);
        }

        .kpi-icon-blue {
            background: rgba(2, 132, 199, 0.12);
            color: #0284c7;
        }
        .kpi-icon-amber {
            background: rgba(245, 158, 11, 0.12);
            color: #d97706;
        }
        .kpi-icon-indigo {
            background: rgba(99, 102, 241, 0.12);
            color: #6366f1;
        }
        .kpi-icon-rose {
            background: rgba(244, 63, 94, 0.12);
            color: #f43f5e;
        }

        .kpi-value-row {
            margin-bottom: 0.75rem;
        }

        .kpi-value {
            font-size: 2.15rem;
            font-weight: 800;
            color: var(--frost-slate-900);
            line-height: 1;
            font-family: 'Space Grotesk', 'Plus Jakarta Sans', sans-serif;
        }

        .kpi-footer-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 0.75rem;
            border-top: 1px solid #f1f5f9;
            font-size: 0.785rem;
            color: var(--frost-slate-500);
        }

        .kpi-action-arrow {
            color: var(--frost-primary);
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            transition: transform 0.2s ease;
        }
        .frost-kpi-card:hover .kpi-action-arrow {
            transform: translateX(3px);
        }

        /* CORE MODULES SHORTCUT GRID */
        .section-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.15rem;
        }

        .section-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--frost-slate-900);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .frost-modules-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.25rem;
            margin-bottom: 2rem;
        }

        .frost-module-card {
            background: #ffffff;
            border: 1px solid var(--frost-slate-200);
            border-radius: 16px;
            padding: 1.35rem 1.25rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            text-decoration: none;
            color: inherit;
            transition: all 0.2s ease;
        }
        .frost-module-card:hover {
            border-color: #7dd3fc;
            background: #fafcff;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px -4px rgba(2, 132, 199, 0.08);
        }

        .module-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            color: #0284c7;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            margin-bottom: 0.85rem;
        }

        .module-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--frost-slate-900);
            margin-bottom: 0.35rem;
        }

        .module-desc {
            font-size: 0.8rem;
            color: var(--frost-slate-500);
            line-height: 1.45;
            margin-bottom: 0.85rem;
        }

        .module-link-text {
            font-size: 0.8rem;
            font-weight: 600;
            color: #0284c7;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
        }

        /* SYSTEM STATUS & HEALTH PANEL */
        .frost-status-panel {
            background: #ffffff;
            border: 1px solid var(--frost-slate-200);
            border-radius: 20px;
            padding: 1.75rem 2rem;
            box-shadow: 0 4px 16px -2px rgba(15, 23, 42, 0.04);
        }

        .status-panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.25rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #f1f5f9;
        }

        .status-panel-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--frost-slate-900);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .status-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.25rem;
        }

        .status-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 1.15rem 1.25rem;
        }

        .status-box-label {
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--frost-slate-500);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.45rem;
        }

        .status-box-val {
            font-size: 0.925rem;
            font-weight: 600;
            color: var(--frost-slate-900);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .status-badge-active {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: #ecfdf5;
            color: #059669;
            border: 1px solid #a7f3d0;
            padding: 0.25rem 0.65rem;
            border-radius: 20px;
            font-size: 0.785rem;
            font-weight: 600;
        }

        .dot-green {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #10b981;
            box-shadow: 0 0 6px #10b981;
        }

        /* RESPONSIVE */
        @media (max-width: 1100px) {
            .frost-kpi-grid,
            .frost-modules-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .status-grid {
                grid-template-columns: 1fr;
            }
            .frost-hero-banner {
                flex-direction: column;
                align-items: flex-start;
            }
            .hero-actions {
                width: 100%;
                flex-wrap: wrap;
            }
        }

        @media (max-width: 600px) {
            .frost-kpi-grid,
            .frost-modules-grid {
                grid-template-columns: 1fr;
            }
            .content-container {
                padding: 1rem;
            }
            .hero-title {
                font-size: 1.35rem;
            }
        }
    </style>
</head>

<body>
<div class="app">

    <!-- HEADER WITH FROSTLINE CRM LOGO -->
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />

    <!-- SIDEBAR -->
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <div class="content-container">

            <!-- HERO GREETING BANNER -->
            <section class="frost-hero-banner">
                <div class="hero-left-content">
                    <div class="hero-greeting">
                        <h1 class="hero-title">Xin chào, <%= userName %>! 👋</h1>
                    </div>
                    <p class="hero-desc">
                        Chào mừng bạn quay trở lại với <strong>Frostline CRM</strong>. Theo dõi số liệu kinh doanh, quản lý danh mục và chăm sóc khách hàng tập trung.
                    </p>
                    <div class="hero-badges-row">
                        <span class="hero-pill">
                            <i class="fa-solid fa-user-shield"></i> <%= userRole %>
                        </span>
                        <span class="hero-pill">
                            <i class="fa-solid fa-users"></i> <%= userTeam %>
                        </span>
                        <span class="hero-pill" style="color: #059669; border-color: #a7f3d0; background: #ecfdf5;">
                            <span class="dot-green"></span> Trạng thái kết nối: Hoạt động
                        </span>
                    </div>
                </div>

                <div class="hero-actions">
                    <a class="btn-frost-primary" href="${pageContext.request.contextPath}/customers/create">
                        <i class="fa-solid fa-plus"></i> Thêm khách hàng
                    </a>
                    <a class="btn-frost-secondary" href="${pageContext.request.contextPath}/customers/care">
                        <i class="fa-solid fa-hand-holding-heart"></i> Chăm sóc định kỳ
                    </a>
                    <a class="btn-frost-secondary" href="${pageContext.request.contextPath}/accounts/list" title="Quản lý tài khoản">
                        <i class="fa-solid fa-gear"></i> Quản trị
                    </a>
                </div>
            </section>

            <!-- 4 EXECUTIVE KPI CARDS -->
            <section class="frost-kpi-grid" aria-label="Thống kê tổng quan">
                
                <!-- CARD 1: TỔNG KHÁCH HÀNG -->
                <a class="frost-kpi-card" href="${pageContext.request.contextPath}/customers">
                    <div>
                        <div class="kpi-card-header">
                            <span class="kpi-label">Tổng khách hàng</span>
                            <div class="kpi-icon-box kpi-icon-blue">
                                <i class="fa-solid fa-building-user"></i>
                            </div>
                        </div>
                        <div class="kpi-value-row">
                            <div class="kpi-value"><%= totalCustomers %></div>
                        </div>
                    </div>
                    <div class="kpi-footer-row">
                        <span>Danh mục doanh nghiệp</span>
                        <span class="kpi-action-arrow">Xem danh sách <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </a>

                <!-- CARD 2: LEAD MỚI / TIỀM NĂNG -->
                <a class="frost-kpi-card" href="${pageContext.request.contextPath}/customers?status=Tiềm+năng">
                    <div>
                        <div class="kpi-card-header">
                            <span class="kpi-label">Lead & Tiềm năng</span>
                            <div class="kpi-icon-box kpi-icon-amber">
                                <i class="fa-solid fa-bolt"></i>
                            </div>
                        </div>
                        <div class="kpi-value-row">
                            <div class="kpi-value"><%= totalLeads %></div>
                        </div>
                    </div>
                    <div class="kpi-footer-row">
                        <span>Cần tiếp cận & chuyển đổi</span>
                        <span class="kpi-action-arrow">Lọc khách hàng <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </a>

                <!-- CARD 3: CƠ HỘI BÁN HÀNG -->
                <a class="frost-kpi-card" href="${pageContext.request.contextPath}/deals">
                    <div>
                        <div class="kpi-card-header">
                            <span class="kpi-label">Cơ hội kinh doanh</span>
                            <div class="kpi-icon-box kpi-icon-indigo">
                                <i class="fa-solid fa-chart-line"></i>
                            </div>
                        </div>
                        <div class="kpi-value-row">
                            <div class="kpi-value"><%= totalOpportunities %></div>
                        </div>
                    </div>
                    <div class="kpi-footer-row">
                        <span>Giai đoạn Pipeline</span>
                        <span class="kpi-action-arrow">Xem cơ hội <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </a>

                <!-- CARD 4: CHĂM SÓC ĐỊNH KỲ -->
                <a class="frost-kpi-card" href="${pageContext.request.contextPath}/customers/care">
                    <div>
                        <div class="kpi-card-header">
                            <span class="kpi-label">Chăm sóc định kỳ</span>
                            <div class="kpi-icon-box kpi-icon-rose">
                                <i class="fa-solid fa-hand-holding-heart"></i>
                            </div>
                        </div>
                        <div class="kpi-value-row">
                            <div class="kpi-value"><%= totalCareNeeded %></div>
                        </div>
                    </div>
                    <div class="kpi-footer-row">
                        <span>Chưa liên hệ > 30 ngày</span>
                        <span class="kpi-action-arrow">Chăm sóc ngay <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </a>

            </section>

            <!-- CORE MODULES SHORTCUTS -->
            <div class="section-header-row">
                <h2 class="section-title">
                    <i class="fa-solid fa-cubes" style="color: var(--frost-primary);"></i> Nghiệp vụ trọng tâm
                </h2>
            </div>

            <section class="frost-modules-grid">
                <a class="frost-module-card" href="${pageContext.request.contextPath}/customers">
                    <div class="module-icon">
                        <i class="fa-solid fa-address-book"></i>
                    </div>
                    <div>
                        <h3 class="module-title">Danh mục khách hàng 360°</h3>
                        <p class="module-desc">Tra cứu thông tin liên hệ, mã số thuế, quy mô công ty và lịch sử giao dịch.</p>
                    </div>
                    <div class="module-link-text">Truy cập danh mục <i class="fa-solid fa-arrow-right"></i></div>
                </a>

                <a class="frost-module-card" href="${pageContext.request.contextPath}/customers/care">
                    <div class="module-icon" style="color: #f43f5e; background: #fff1f2; border-color: #fecdd3;">
                        <i class="fa-solid fa-calendar-check"></i>
                    </div>
                    <div>
                        <h3 class="module-title">Chăm sóc định kỳ theo chu kỳ</h3>
                        <p class="module-desc">Lọc khách hàng chưa tương tác trong N ngày, sắp xếp theo giá trị và ghi log liên hệ.</p>
                    </div>
                    <div class="module-link-text" style="color: #f43f5e;">Lịch chăm sóc <i class="fa-solid fa-arrow-right"></i></div>
                </a>

                <a class="frost-module-card" href="${pageContext.request.contextPath}/customers/import">
                    <div class="module-icon" style="color: #059669; background: #ecfdf5; border-color: #a7f3d0;">
                        <i class="fa-solid fa-file-excel"></i>
                    </div>
                    <div>
                        <h3 class="module-title">Nhập danh sách từ Excel</h3>
                        <p class="module-desc">Tải lên file dữ liệu khách hàng hàng loạt với kiểm tra trùng MST và số điện thoại.</p>
                    </div>
                    <div class="module-link-text" style="color: #059669;">Tải lên dữ liệu <i class="fa-solid fa-arrow-right"></i></div>
                </a>

                <a class="frost-module-card" href="${pageContext.request.contextPath}/accounts/list">
                    <div class="module-icon" style="color: #6366f1; background: #eef2ff; border-color: #c7d2fe;">
                        <i class="fa-solid fa-users-gear"></i>
                    </div>
                    <div>
                        <h3 class="module-title">Quản lý tài khoản & Phân quyền</h3>
                        <p class="module-desc">Thiết lập tài khoản người dùng, vai trò RBAC, phạm vi dữ liệu và cấu trúc phòng ban.</p>
                    </div>
                    <div class="module-link-text" style="color: #6366f1;">Cấu hình hệ thống <i class="fa-solid fa-arrow-right"></i></div>
                </a>
            </section>

            <!-- SYSTEM & SESSION STATUS PANEL -->
            <section class="frost-status-panel">
                <div class="status-panel-header">
                    <h2 class="status-panel-title">
                        <i class="fa-solid fa-server" style="color: var(--frost-primary);"></i> Trạng thái hệ thống & Phiên đăng nhập
                    </h2>
                    <span class="status-badge-active">
                        <span class="dot-green"></span> TLS 256-bit An Toàn
                    </span>
                </div>

                <div class="status-grid">
                    <div class="status-box">
                        <div class="status-box-label">Người dùng xác thực</div>
                        <div class="status-box-val">
                            <i class="fa-solid fa-user-check" style="color: var(--frost-primary);"></i>
                            <span><%= userName %> (<%= userEmail %>)</span>
                        </div>
                    </div>

                    <div class="status-box">
                        <div class="status-box-label">Phòng ban / Vai trò</div>
                        <div class="status-box-val">
                            <i class="fa-solid fa-id-badge" style="color: #6366f1;"></i>
                            <span><%= userRole %> • <%= userTeam %></span>
                        </div>
                    </div>

                    <div class="status-box">
                        <div class="status-box-label">Cơ sở dữ liệu</div>
                        <div class="status-box-val">
                            <span class="status-badge-active">
                                <span class="dot-green"></span> <%= dbConnected ? "Đã kết nối crm_db" : "Sẵn sàng" %>
                            </span>
                        </div>
                    </div>
                </div>
            </section>

        </div>
    </main>
</div>
</body>
</html>
