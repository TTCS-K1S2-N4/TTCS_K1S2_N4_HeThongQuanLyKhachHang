<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.model.Account" %>
<%
    Account currentUser = (Account) session.getAttribute("currentUser");
    String userName = (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Tài khoản CRM";
    String userTeam = (currentUser != null && currentUser.getTeamName() != null) ? currentUser.getTeamName() : "Thành viên hệ thống";
    String userInitial = (userName.length() > 0) ? userName.substring(0, 1).toUpperCase() : "U";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Hệ thống quản lý khách hàng CRM">
    <title>Tổng quan | CRM System</title>

    <!-- FOUNDATION CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
</head>

<body>
<div class="app">

    <!-- HEADER -->
    <header class="app-header">
        <div class="header-left">
            <a class="header-brand" href="${pageContext.request.contextPath}/" aria-label="CRM System">
                <span class="brand-mark">CRM</span>
                <span>CRM System</span>
            </a>
        </div>

        <div class="header-right">
            <button class="header-action" type="button" aria-label="Thông báo" title="Thông báo">
                <span aria-hidden="true">🔔</span>
            </button>

            <div class="header-user">
                <div class="user-avatar" aria-hidden="true">
                    <%= userInitial %>
                </div>

                <div class="header-user-info">
                    <div class="user-name">
                        <%= userName %>
                    </div>
                    <div class="user-role">
                        <%= userTeam %>
                    </div>
                </div>

                <div style="margin-left: 12px;">
                    <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-secondary btn-sm" title="Đăng xuất">
                        Đăng xuất
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <nav aria-label="Điều hướng chính">
            <div class="sidebar-section">
                <div class="sidebar-title">Tổng quan</div>
                <a class="nav-item active" href="${pageContext.request.contextPath}/" aria-current="page">
                    <span class="nav-icon" aria-hidden="true">◫</span>
                    <span>Dashboard</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-title">Kinh doanh</div>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">◎</span>
                    <span>Khách hàng</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">◇</span>
                    <span>Lead</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">△</span>
                    <span>Cơ hội</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">○</span>
                    <span>Hoạt động</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">▣</span>
                    <span>Báo giá & Hợp đồng</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-title">Phân tích</div>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">◈</span>
                    <span>Chỉ tiêu & KPI</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">▤</span>
                    <span>Báo cáo & Dashboard</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-title">Hệ thống</div>
                <a class="nav-item" href="${pageContext.request.contextPath}/accounts/list">
                    <span class="nav-icon" aria-hidden="true">□</span>
                    <span>Quản lý tài khoản</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">⚙</span>
                    <span>Vai trò & phân quyền</span>
                </a>
                <a class="nav-item" href="#">
                    <span class="nav-icon" aria-hidden="true">≡</span>
                    <span>Nhật ký hệ thống</span>
                </a>
            </div>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span aria-hidden="true">/</span>
                <span class="breadcrumb-current">Tổng quan</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Tổng quan hệ thống</h1>
                    <p class="page-description">Theo dõi tình hình hoạt động của hệ thống CRM.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/accounts/list">
                        Quản lý tài khoản
                    </a>
                </div>
            </div>

            <!-- OVERVIEW STATISTIC CARDS -->
            <section class="dashboard-grid" aria-label="Thống kê tổng quan">
                <article class="card statistic-card">
                    <div class="card-body">
                        <div class="statistic-header">
                            <div>
                                <div class="statistic-label">Tổng khách hàng</div>
                                <div class="statistic-value">--</div>
                            </div>
                            <div class="statistic-icon" aria-hidden="true">◎</div>
                        </div>
                        <div class="statistic-footer">
                            <span class="badge badge-secondary">Chưa kết nối dữ liệu</span>
                        </div>
                    </div>
                </article>

                <article class="card statistic-card">
                    <div class="card-body">
                        <div class="statistic-header">
                            <div>
                                <div class="statistic-label">Lead mới</div>
                                <div class="statistic-value">--</div>
                            </div>
                            <div class="statistic-icon" aria-hidden="true">◇</div>
                        </div>
                        <div class="statistic-footer">
                            <span class="badge badge-secondary">Chưa kết nối dữ liệu</span>
                        </div>
                    </div>
                </article>

                <article class="card statistic-card">
                    <div class="card-body">
                        <div class="statistic-header">
                            <div>
                                <div class="statistic-label">Cơ hội đang mở</div>
                                <div class="statistic-value">--</div>
                            </div>
                            <div class="statistic-icon" aria-hidden="true">△</div>
                        </div>
                        <div class="statistic-footer">
                            <span class="badge badge-secondary">Chưa kết nối dữ liệu</span>
                        </div>
                    </div>
                </article>

                <article class="card statistic-card">
                    <div class="card-body">
                        <div class="statistic-header">
                            <div>
                                <div class="statistic-label">Hợp đồng</div>
                                <div class="statistic-value">--</div>
                            </div>
                            <div class="statistic-icon" aria-hidden="true">▣</div>
                        </div>
                        <div class="statistic-footer">
                            <span class="badge badge-secondary">Chưa kết nối dữ liệu</span>
                        </div>
                    </div>
                </article>
            </section>

            <!-- MAIN CONTENT GRID -->
            <section class="dashboard-content-grid" style="margin-top: 24px;">
                <article class="card">
                    <div class="card-header">
                        <div>
                            <h2 class="card-title">Trạng thái dữ liệu hệ thống</h2>
                            <p class="card-description">Thông tin kết nối CSDL và phiên đăng nhập hiện tại.</p>
                        </div>
                    </div>
                    <div class="card-body">
                        <div style="padding: 16px; background-color: var(--color-gray-50); border-radius: var(--radius-md); border: 1px solid var(--color-border);">
                            <p><strong>Người dùng đăng nhập:</strong> <%= userName %> (<%= currentUser != null ? currentUser.getEmail() : "" %>)</p>
                            <p style="margin-top: 8px;"><strong>Nhóm / Vai trò:</strong> <%= userTeam %></p>
                            <p style="margin-top: 8px;"><strong>Trạng thái kết nối CSDL:</strong> <span class="badge badge-success">Đã kết nối crm_db</span></p>
                        </div>
                    </div>
                </article>
            </section>
        </div>
    </main>
</div>
</body>
</html>
