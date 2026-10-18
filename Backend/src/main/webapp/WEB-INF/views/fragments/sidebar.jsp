<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.service.PermissionService" %>
<%@ page import="com.crm.model.MenuItem" %>
<%@ page import="com.crm.model.Account" %>
<%@ page import="java.util.List" %>
<%
    Account currentUser = (Account) session.getAttribute("currentUser");
    String userName = (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Người dùng";
    String userRole = (currentUser != null && currentUser.getRoleName() != null) ? currentUser.getRoleName() : "Thành viên hệ thống";
    String userTeam = (currentUser != null && currentUser.getTeamName() != null) ? currentUser.getTeamName() : "Chưa thuộc nhóm";
    String userInitial = (userName.length() > 0) ? userName.substring(0, 1).toUpperCase() : "U";
    String avatarUrl = (currentUser != null) ? currentUser.getAvatarUrl() : null;
    boolean hasAvatar = (avatarUrl != null && !avatarUrl.trim().isEmpty());

    PermissionService permissionService = new PermissionService();
    List<Integer> sessionRoleIds = com.crm.util.ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds"));
    Integer sessionRoleId = (Integer) session.getAttribute("roleId");
    List<Integer> effectiveRoleIds = sessionRoleIds != null && !sessionRoleIds.isEmpty()
            ? sessionRoleIds
            : java.util.Collections.singletonList(sessionRoleId != null ? sessionRoleId : 0);

    // Permission checks according to user story AC
    boolean canViewAccounts = permissionService.hasPermissionForRoles(effectiveRoleIds, "ACCOUNT_VIEW");
    boolean canViewDeals = permissionService.hasPermissionForRoles(effectiveRoleIds, "DEAL_VIEW");
    boolean canViewActivities = permissionService.hasPermissionForRoles(effectiveRoleIds, "ACTIVITY_VIEW");
    boolean canViewQuotes = permissionService.hasPermissionForRoles(effectiveRoleIds, "QUOTE_VIEW");
    boolean canViewProducts = permissionService.hasPermissionForRoles(effectiveRoleIds, "PRODUCT_VIEW");
    boolean canViewCategories = permissionService.hasPermissionForRoles(effectiveRoleIds, "CATEGORY_VIEW");
    boolean canManageCategories = permissionService.hasPermissionForRoles(effectiveRoleIds, "CATEGORY_MANAGE");
    boolean canViewOrg = permissionService.hasPermissionForRoles(effectiveRoleIds, "ORG_VIEW");
    boolean canViewUsers = permissionService.hasPermissionForRoles(effectiveRoleIds, "USER_VIEW");
    boolean canViewAudit = permissionService.hasPermissionForRoles(effectiveRoleIds, "AUDIT_VIEW");
    boolean canCreateAccount = permissionService.hasPermissionForRoles(effectiveRoleIds, "ACCOUNT_CREATE");
    boolean canImportData = permissionService.hasPermissionForRoles(effectiveRoleIds, "IMPORT_DATA");

    // Lead module role & permission detection
    boolean isMarketing = false;
    boolean isSalesRep = false;
    boolean isTeamLead = false;
    boolean isDirector = false;
    boolean isAdmin = false;

    if (currentUser != null) {
        List<String> rCodes = currentUser.getRoleCodes();
        if (rCodes != null && !rCodes.isEmpty()) {
            for (String rc : rCodes) {
                if (rc != null) {
                    String u = rc.toUpperCase().trim();
                    if (u.equals("MARKETING")) isMarketing = true;
                    if (u.equals("SALES_REP") || u.contains("SALES")) isSalesRep = true;
                    if (u.equals("TEAM_LEAD") || u.contains("LEAD")) isTeamLead = true;
                    if (u.equals("DIRECTOR")) isDirector = true;
                    if (u.equals("ADMIN")) isAdmin = true;
                }
            }
        }
        if (userRole != null) {
            String ur = userRole.toLowerCase();
            if (ur.contains("quản trị") || ur.contains("admin")) isAdmin = true;
            if (ur.contains("marketing")) isMarketing = true;
            if (ur.contains("giám đốc") || ur.contains("director")) isDirector = true;
            if (ur.contains("trưởng") || ur.contains("leader")) isTeamLead = true;
            if (ur.contains("kinh doanh") || ur.contains("sales")) isSalesRep = true;
        }
    }

    boolean canViewLeads = canViewAccounts || isMarketing || isSalesRep || isTeamLead || isDirector || isAdmin;
    boolean canCreateLead = canCreateAccount || isMarketing || isSalesRep || isTeamLead || isDirector || isAdmin;
    boolean canImportLead = canImportData || canCreateAccount || isMarketing || isTeamLead || isDirector || isAdmin;
    boolean canManageWebForms = isMarketing || isDirector || isAdmin;
    boolean canManageDuplicates = isMarketing || isTeamLead || isDirector || isAdmin;
    boolean canConfigureScoring = isDirector || isAdmin || isTeamLead;
    boolean canViewSavedFilters = canViewLeads;

    // Route matching for active state
    String forwardUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
    if (forwardUri == null) {
        forwardUri = (String) request.getAttribute("javax.servlet.forward.request_uri");
    }
    String currentUri = (forwardUri != null) ? forwardUri : request.getRequestURI();
    String contextPath = request.getContextPath();
    String relativePath = (contextPath != null && !contextPath.isEmpty() && currentUri.startsWith(contextPath))
            ? currentUri.substring(contextPath.length())
            : currentUri;

    boolean isDashboardActive = relativePath.equals("/") || relativePath.equals("") || relativePath.equals("/dashboard") || relativePath.startsWith("/dashboard/");
    boolean isLeadActive = !isDashboardActive && (relativePath.startsWith("/leads") || relativePath.startsWith("/lead-scoring") || relativePath.startsWith("/lead-assignment") || relativePath.startsWith("/campaigns"));
%>

<!-- SIDEBAR NAVIGATION DRAWER (LIGHT ELEGANT THEME) -->
<aside class="sidebar frost-sidebar" id="app-sidebar" aria-label="Menu điều hướng hệ thống">
    
    <!-- MOBILE TOP BAR WITH BRAND & CLOSE BUTTON (VISIBLE <= 768px) -->
    <div class="sidebar-mobile-header">
        <div class="sidebar-mobile-brand">
            <div class="frost-mini-icon">
                <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M24 3L43 14V34L24 45L5 34V14L24 3Z" stroke="#2563eb" stroke-width="2.5" fill="rgba(37, 99, 235, 0.12)" />
                    <polygon points="24,13 34,24 24,35 14,24" fill="#2563eb" />
                </svg>
            </div>
            <div class="sidebar-mobile-title">
                <span>Frostline</span> <span class="badge-crm">CRM</span>
            </div>
        </div>
        <button id="sidebar-close-btn" class="sidebar-close-btn" aria-label="Đóng menu">
            <i class="fa-solid fa-xmark"></i>
        </button>
    </div>

    <!-- USER CONTEXT CARD (AC: Hiển thị tên, vai trò và nhóm kinh doanh) -->
    <div class="sidebar-user-card" title="Thông tin người dùng hiện tại">
        <div class="sidebar-user-top">
            <div class="sidebar-avatar-box">
                <% if (hasAvatar) { %>
                    <img src="<%= avatarUrl %>" alt="Avatar" class="sidebar-avatar-img">
                <% } else { %>
                    <span class="sidebar-avatar-initial"><%= userInitial %></span>
                <% } %>
                <span class="sidebar-status-dot" title="Đang trực tuyến"></span>
            </div>
            <div class="sidebar-user-details">
                <div class="sidebar-user-name" title="<%= userName %>"><%= userName %></div>
                <div class="sidebar-user-role-badge">
                    <i class="fa-solid fa-shield-halved"></i>
                    <span><%= userRole %></span>
                </div>
            </div>
        </div>
        <div class="sidebar-team-row">
            <i class="fa-solid fa-users"></i>
            <span class="sidebar-team-name" title="<%= userTeam %>"><%= userTeam %></span>
        </div>
    </div>

    <!-- NAVIGATION MENU LIST ACCORDING TO ROLES (BẢN GỐC GỌN GÀNG ĐỒNG NHẤT) -->
    <nav class="sidebar-nav-container" aria-label="Điều hướng chính">
        
        <!-- SECTION 1: TỔNG QUAN -->
        <div class="nav-section-group">
            <div class="nav-section-title">Tổng quan</div>
            <a class="nav-item <%= isDashboardActive ? "active" : "" %>" href="${pageContext.request.contextPath}/">
                <span class="nav-active-indicator"></span>
                <span class="nav-icon"><i class="fa-solid fa-house"></i></span>
                <span class="nav-label">Dashboard</span>
            </a>
        </div>

        <!-- SECTION 2: KHÁCH HÀNG & CHĂM SÓC -->
        <% if (canViewAccounts) { %>
            <div class="nav-section-group">
                <div class="nav-section-title">Khách hàng</div>
                
                <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/customers") && !relativePath.startsWith("/customers/care")) ? "active" : "" %>" 
                   href="${pageContext.request.contextPath}/customers">
                    <span class="nav-active-indicator"></span>
                    <span class="nav-icon"><i class="fa-solid fa-building-user"></i></span>
                    <span class="nav-label">Danh mục khách hàng</span>
                </a>

                <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/customers/care")) ? "active" : "" %>" 
                   href="${pageContext.request.contextPath}/customers/care">
                    <span class="nav-active-indicator"></span>
                    <span class="nav-icon"><i class="fa-solid fa-hand-holding-heart"></i></span>
                    <span class="nav-label">Chăm sóc định kỳ</span>
                </a>
            </div>
        <% } %>

        <!-- SECTION: QUẢN LÝ LEAD (TIỀM NĂNG & THU THẬP) -->
        <% if (canViewLeads) { %>
            <div class="nav-section-group">
                <div class="nav-section-title">Tiềm năng & Lead</div>

                <div class="nav-dropdown <%= isLeadActive ? "open" : "" %>" id="lead-nav-dropdown">
                    <div class="nav-item-header-group">
                        <a class="nav-item nav-item-lead-main <%= isLeadActive ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/leads" 
                           title="Quản lý Lead">
                            <span class="nav-active-indicator"></span>
                            <span class="nav-icon"><i class="fa-solid fa-bullseye"></i></span>
                            <span class="nav-label">Quản lý Lead</span>
                        </a>
                        <button type="button" class="nav-toggle-btn" id="lead-toggle-btn" 
                                aria-label="Mở rộng menu Lead" 
                                aria-expanded="<%= isLeadActive ? "true" : "false" %>"
                                title="Mở rộng/Thu gọn menu con">
                            <i class="fa-solid fa-chevron-down"></i>
                        </button>
                    </div>

                    <div class="nav-sub-menu" id="lead-sub-menu">
                        <a class="nav-sub-item <%= (!isDashboardActive && (relativePath.equals("/leads") || relativePath.equals("/leads/list") || relativePath.startsWith("/leads/detail"))) ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/leads">
                            <span class="nav-sub-dot"></span>
                            <span class="nav-sub-text">Danh sách Lead</span>
                        </a>

                        <a class="nav-sub-item <%= (!isDashboardActive && (relativePath.startsWith("/leads/assigned") || relativePath.startsWith("/leads/my-assigned"))) ? "active" : "" %>"
                           href="${pageContext.request.contextPath}/leads/assigned">
                            <span class="nav-sub-dot"></span>
                            <span class="nav-sub-text">Lead được phân cho tôi</span>
                        </a>

                        <% if (canCreateLead) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/leads/create")) ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/leads/create">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Tạo Lead</span>
                            </a>
                        <% } %>

                        <% if (canImportLead) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/leads/import")) ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/leads/import">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Nhập Lead từ Excel</span>
                            </a>
                        <% } %>

                        <% if (canManageWebForms) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/leads/web-forms")) ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/leads/web-forms">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Web Forms</span>
                            </a>
                        <% } %>

                        <% if (canManageDuplicates) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/leads/duplicates")) ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/leads/duplicates">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Phát hiện Lead trùng</span>
                            </a>
                        <% } %>

                        <% if (canConfigureScoring) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/lead-scoring")) ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/lead-scoring/rules">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Cấu hình chấm điểm</span>
                            </a>

                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/lead-assignment")) ? "active" : "" %>"
                               href="${pageContext.request.contextPath}/lead-assignment/rules">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Quy tắc phân bổ</span>
                            </a>
                        <% } %>

                        <% if (isTeamLead || isDirector || isAdmin) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && (relativePath.startsWith("/leads/assignment-queue") || relativePath.startsWith("/leads/queue"))) ? "active" : "" %>"
                               href="${pageContext.request.contextPath}/leads/assignment-queue">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Hàng chờ phân bổ</span>
                            </a>
                        <% } %>

                        <% if (canViewSavedFilters) { %>
                            <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/leads/saved-filters")) ? "active" : "" %>" 
                               href="${pageContext.request.contextPath}/leads/saved-filters">
                                <span class="nav-sub-dot"></span>
                                <span class="nav-sub-text">Bộ lọc đã lưu</span>
                            </a>
                        <% } %>

                        <a class="nav-sub-item <%= (!isDashboardActive && relativePath.startsWith("/campaigns")) ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/campaigns">
                            <span class="nav-sub-dot"></span>
                            <span class="nav-sub-text">Chiến dịch Marketing</span>
                        </a>
                    </div>
                </div>

            </div>
        <% } %>

        <!-- SECTION 3: KINH DOANH & GIAO DỊCH -->
        <% if (canViewDeals || canViewActivities || canViewQuotes) { %>
            <div class="nav-section-group">
                <div class="nav-section-title">Kinh doanh</div>

                <% if (canViewDeals) { %>
                    <a class="nav-item <%= (!isDashboardActive && (relativePath.startsWith("/deals") || relativePath.startsWith("/opportunities"))) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/deals">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-chart-line"></i></span>
                        <span class="nav-label">Cơ hội kinh doanh</span>
                    </a>
                <% } %>

                <% if (canViewActivities) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/activities")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/activities">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-calendar-check"></i></span>
                        <span class="nav-label">Hoạt động & Lịch hẹn</span>
                    </a>
                <% } %>

                <% if (canViewQuotes) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/quotes")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/quotes">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-file-invoice-dollar"></i></span>
                        <span class="nav-label">Báo giá</span>
                    </a>
                <% } %>
            </div>
        <% } %>

        <!-- SECTION 4: SẢN PHẨM & PIPELINE -->
        <% if (canViewProducts || canViewCategories || canManageCategories) { %>
            <div class="nav-section-group">
                <div class="nav-section-title">Sản phẩm & Danh mục</div>

                <% if (canViewProducts) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/products")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/products">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-box-archive"></i></span>
                        <span class="nav-label">Sản phẩm & Dịch vụ</span>
                    </a>
                <% } %>

                <% if (canViewCategories) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/categories")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/categories">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-tags"></i></span>
                        <span class="nav-label">Danh mục dùng chung</span>
                    </a>
                <% } %>

                <% if (canManageCategories) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/pipeline/stages")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/pipeline/stages">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-bars-staggered"></i></span>
                        <span class="nav-label">Giai đoạn Pipeline</span>
                    </a>

                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/pipeline/win-loss-reasons")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/pipeline/win-loss-reasons">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-award"></i></span>
                        <span class="nav-label">Lý do Thắng/Thua</span>
                    </a>

                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/pipeline/competitors")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/pipeline/competitors">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-chess-knight"></i></span>
                        <span class="nav-label">Đối thủ cạnh tranh</span>
                    </a>
                <% } %>
            </div>
        <% } %>

        <!-- SECTION 5: HỆ THỐNG & QUẢN TRỊ -->
        <% if (canViewOrg || canViewUsers || canViewAudit) { %>
            <div class="nav-section-group">
                <div class="nav-section-title">Hệ thống & Quản trị</div>

                <% if (canViewOrg) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/organization")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/organization/teams">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-sitemap"></i></span>
                        <span class="nav-label">Cấu trúc tổ chức</span>
                    </a>
                <% } %>

                <% if (canViewUsers) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/accounts")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/accounts/list">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-user-gear"></i></span>
                        <span class="nav-label">Quản lý tài khoản</span>
                    </a>
                <% } %>

                <% if (canViewAudit) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/audit")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/audit/list">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-clock-rotate-left"></i></span>
                        <span class="nav-label">Nhật ký hệ thống</span>
                    </a>
                <% } %>

                <% if (canViewUsers || canViewOrg || (currentUser != null && "Quản trị hệ thống".equals(userRole))) { %>
                    <a class="nav-item <%= (!isDashboardActive && relativePath.startsWith("/custom-fields")) ? "active" : "" %>" 
                       href="${pageContext.request.contextPath}/custom-fields">
                        <span class="nav-active-indicator"></span>
                        <span class="nav-icon"><i class="fa-solid fa-sliders"></i></span>
                        <span class="nav-label">Trường tùy chỉnh</span>
                    </a>
                <% } %>
            </div>
        <% } %>

    </nav>

    <!-- SIDEBAR FOOTER -->
    <div class="sidebar-bottom-footer">
        <div class="sidebar-security-badge">
            <i class="fa-solid fa-shield-halved"></i>
            <span>TLS 256-bit • v2.4</span>
        </div>
        <a href="${pageContext.request.contextPath}/auth/logout" class="sidebar-mobile-logout" title="Đăng xuất">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
            <span>Đăng xuất</span>
        </a>
    </div>

</aside>

<!-- BACKDROP OVERLAY FOR MOBILE (TOUCH-TO-CLOSE) -->
<div id="sidebar-overlay" class="frost-sidebar-overlay"></div>

<!-- STYLES FOR ELEGANT LIGHT THEME FROSTLINE SIDEBAR -->
<style>
    /* DESKTOP SIDEBAR - LIGHT THEME (KHÔNG CÒN NỀN ĐEN U TỐI) */
    .frost-sidebar {
        background: #ffffff !important;
        border-right: 1px solid #e2e8f0 !important;
        box-shadow: 2px 0 16px rgba(15, 23, 42, 0.04) !important;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        padding: 1.15rem 0.85rem 1rem 0.85rem !important;
        scrollbar-width: thin;
        scrollbar-color: #cbd5e1 transparent;
        z-index: 1000;
        width: 268px !important;
    }

    .frost-sidebar::-webkit-scrollbar {
        width: 5px;
    }
    .frost-sidebar::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 4px;
    }
    .frost-sidebar::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }

    /* MOBILE HEADER (HIDDEN ON DESKTOP) */
    .sidebar-mobile-header {
        display: none;
        align-items: center;
        justify-content: space-between;
        padding-bottom: 1rem;
        margin-bottom: 0.85rem;
        border-bottom: 1px solid #e2e8f0;
    }
    .sidebar-mobile-brand {
        display: flex;
        align-items: center;
        gap: 0.65rem;
    }
    .frost-mini-icon {
        width: 28px;
        height: 28px;
    }
    .frost-mini-icon svg {
        width: 100%;
        height: 100%;
    }
    .sidebar-mobile-title {
        font-family: 'Space Grotesk', 'Plus Jakarta Sans', sans-serif;
        font-size: 1.15rem;
        font-weight: 700;
        color: #0f172a;
        display: flex;
        align-items: center;
        gap: 0.35rem;
    }
    .badge-crm {
        font-size: 0.65rem;
        font-weight: 800;
        color: #2563eb;
        background: #eff6ff;
        border: 1px solid #bfdbfe;
        padding: 0.1rem 0.4rem;
        border-radius: 4px;
    }
    .sidebar-close-btn {
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        color: #64748b;
        width: 34px;
        height: 34px;
        border-radius: 8px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        transition: all 0.2s ease;
    }
    .sidebar-close-btn:hover {
        background: #e2e8f0;
        color: #0f172a;
    }

    /* USER CONTEXT CARD */
    .sidebar-user-card {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 0.85rem 0.9rem;
        margin-bottom: 1.15rem;
        transition: all 0.25s ease;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
    }
    .sidebar-user-card:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
        box-shadow: 0 3px 8px rgba(15, 23, 42, 0.06);
    }
    .sidebar-user-top {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        margin-bottom: 0.55rem;
    }
    .sidebar-avatar-box {
        position: relative;
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 0.95rem;
        border: 2px solid #93c5fd;
        box-shadow: 0 2px 6px rgba(37, 99, 235, 0.25);
        flex-shrink: 0;
    }
    .sidebar-avatar-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
    }
    .sidebar-status-dot {
        position: absolute;
        bottom: 0;
        right: 0;
        width: 9px;
        height: 9px;
        border-radius: 50%;
        background: #10b981;
        border: 2px solid #ffffff;
        box-shadow: 0 0 4px rgba(16, 185, 129, 0.5);
    }
    .sidebar-user-details {
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    .sidebar-user-name {
        font-size: 0.92rem;
        font-weight: 700;
        color: #0f172a;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        line-height: 1.25;
        margin-bottom: 0.25rem;
    }
    .sidebar-user-role-badge {
        display: inline-flex;
        align-items: center;
        gap: 0.35rem;
        font-size: 0.72rem;
        font-weight: 600;
        color: #2563eb;
        background: #eff6ff;
        border: 1px solid #bfdbfe;
        padding: 0.12rem 0.5rem;
        border-radius: 6px;
        width: fit-content;
        line-height: 1.3;
    }
    .sidebar-team-row {
        display: flex;
        align-items: center;
        gap: 0.45rem;
        font-size: 0.78rem;
        color: #64748b;
        padding-top: 0.45rem;
        border-top: 1px solid #e2e8f0;
        overflow: hidden;
        font-weight: 500;
    }
    .sidebar-team-name {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* NAVIGATION CONTAINER & GROUPS */
    .sidebar-nav-container {
        flex: 1;
        overflow-y: auto;
        padding-right: 0.15rem;
    }
    .nav-section-group {
        margin-bottom: 1.15rem;
    }

    /* SECTION TITLES */
    .nav-section-title {
        font-size: 0.72rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: #64748b !important;
        padding: 0.35rem 0.65rem;
        margin-bottom: 0.25rem;
    }

    /* =========================================================
       MENU ITEMS - BẢN GỐC THANH LỊCH TRÊN NỀN SÁNG
       ========================================================= */
    .frost-sidebar .nav-item {
        position: relative;
        min-height: 42px;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        margin-bottom: 3px;
        padding: 0.55rem 0.75rem;
        border-radius: 9px;
        color: #334155 !important;
        text-decoration: none;
        font-size: 0.88rem;
        font-weight: 500;
        background: transparent;
        border: 1px solid transparent;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }

    /* HOVER STATE */
    .frost-sidebar .nav-item:hover {
        color: #0f172a !important;
        background: #f1f5f9 !important;
        border-color: #e2e8f0 !important;
        transform: translateX(3px);
    }
    .frost-sidebar .nav-item:hover .nav-icon {
        background: #e0f2fe;
        color: #0284c7;
    }

    /* ACTIVE STATE */
    .frost-sidebar .nav-item.active {
        color: #1d4ed8 !important;
        font-weight: 600;
        background: #eff6ff !important;
        border: 1px solid #bfdbfe !important;
        box-shadow: 0 2px 8px rgba(37, 99, 235, 0.08);
    }
    .frost-sidebar .nav-item.active .nav-icon {
        background: #2563eb;
        color: #ffffff;
        box-shadow: 0 2px 6px rgba(37, 99, 235, 0.3);
    }

    /* ACTIVE INDICATOR BAR */
    .nav-active-indicator {
        display: none;
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 3.5px;
        height: 20px;
        border-radius: 4px;
        background: #2563eb;
    }
    .frost-sidebar .nav-item.active .nav-active-indicator {
        display: block;
    }

    /* ICON CAPSULES (BẢN GỐC ĐỒNG NHẤT) */
    .frost-sidebar .nav-icon {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.95rem;
        flex-shrink: 0;
        background: #f1f5f9;
        color: #64748b;
        transition: all 0.2s ease;
    }

    .frost-sidebar .nav-label {
        flex: 1;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        letter-spacing: 0.01em;
    }

    /* =========================================================
       DROPDOWN & SUBMENU STYLES FOR MODULE LEAD
       ========================================================= */
    .nav-dropdown {
        display: flex;
        flex-direction: column;
        margin-bottom: 3px;
    }
    .nav-item-header-group {
        display: flex;
        align-items: center;
        gap: 3px;
        position: relative;
    }
    .nav-item-header-group .nav-item-lead-main {
        flex: 1;
        margin-bottom: 0;
    }
    .nav-toggle-btn {
        width: 32px;
        height: 38px;
        border: 1px solid transparent;
        background: transparent;
        border-radius: 8px;
        color: #64748b;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.78rem;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        padding: 0;
        flex-shrink: 0;
    }
    .nav-toggle-btn:hover {
        background: #f1f5f9;
        color: #0f172a;
        border-color: #e2e8f0;
    }
    .nav-toggle-btn i {
        transition: transform 0.25s ease;
    }
    .nav-dropdown.open .nav-toggle-btn i {
        transform: rotate(180deg);
    }
    .nav-sub-menu {
        display: none;
        flex-direction: column;
        gap: 2px;
        padding: 0.35rem 0 0.25rem 0.5rem;
        margin-left: 1.25rem;
        border-left: 2px solid #e2e8f0;
    }
    .nav-dropdown.open .nav-sub-menu {
        display: flex;
    }
    .nav-sub-item {
        position: relative;
        min-height: 34px;
        display: flex;
        align-items: center;
        gap: 0.65rem;
        padding: 0.4rem 0.65rem;
        border-radius: 7px;
        color: #475569 !important;
        text-decoration: none;
        font-size: 0.82rem;
        font-weight: 500;
        transition: all 0.18s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .nav-sub-item:hover {
        color: #0f172a !important;
        background: #f1f5f9 !important;
        transform: translateX(2px);
    }
    .nav-sub-item.active {
        color: #1d4ed8 !important;
        font-weight: 600;
        background: #eff6ff !important;
    }
    .nav-sub-dot {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: #94a3b8;
        flex-shrink: 0;
        transition: all 0.2s ease;
    }
    .nav-sub-item:hover .nav-sub-dot {
        background: #2563eb;
    }
    .nav-sub-item.active .nav-sub-dot {
        background: #2563eb;
        transform: scale(1.3);
        box-shadow: 0 0 6px rgba(37, 99, 235, 0.4);
    }
    .nav-sub-text {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* BOTTOM FOOTER */
    .sidebar-bottom-footer {
        padding-top: 1rem;
        margin-top: 0.5rem;
        border-top: 1px solid #e2e8f0;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 0.75rem;
        color: #64748b;
    }
    .sidebar-security-badge {
        display: inline-flex;
        align-items: center;
        gap: 0.35rem;
        color: #64748b;
    }
    .sidebar-security-badge i {
        color: #2563eb;
    }
    .sidebar-mobile-logout {
        display: none;
        align-items: center;
        gap: 0.35rem;
        color: #dc2626;
        text-decoration: none;
        font-weight: 600;
        padding: 0.3rem 0.6rem;
        border-radius: 6px;
        background: #fee2e2;
        border: 1px solid #fecaca;
    }

    /* =========================================================
       RESPONSIVE DRAWER & 360PX OPTIMIZATIONS
       ========================================================= */
    .frost-sidebar-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.45);
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
        z-index: 999;
        opacity: 0;
        transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .frost-sidebar-overlay.open {
        display: block;
        opacity: 1;
    }

    @media (max-width: 768px) {
        .frost-sidebar {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            bottom: 0 !important;
            height: 100vh !important;
            width: 290px !important;
            max-width: calc(100vw - 45px) !important;
            transform: translateX(-100%);
            transition: transform 0.32s cubic-bezier(0.16, 1, 0.3, 1) !important;
            z-index: 1000 !important;
            box-shadow: 10px 0 35px rgba(0, 0, 0, 0.15) !important;
        }

        .frost-sidebar.open {
            transform: translateX(0) !important;
        }

        .sidebar-mobile-header {
            display: flex;
        }

        .sidebar-mobile-logout {
            display: inline-flex;
        }
    }

    /* SPECIFIC 360px SCREEN TUNING */
    @media (max-width: 380px) {
        .frost-sidebar {
            width: 280px !important;
            padding: 1rem 0.75rem !important;
        }
        .sidebar-user-card {
            padding: 0.75rem 0.8rem;
        }
        .sidebar-user-name {
            font-size: 0.86rem;
        }
        .sidebar-user-role-badge {
            font-size: 0.68rem;
        }
        .frost-sidebar .nav-item {
            min-height: 44px;
            font-size: 0.84rem;
            padding: 0.55rem 0.65rem;
        }
        .nav-sub-item {
            font-size: 0.78rem;
            min-height: 32px;
            padding: 0.35rem 0.5rem;
        }
    }
</style>

<!-- JAVASCRIPT FOR SIDEBAR DRAWER & TOUCH INTERACTION -->
<script>
    (function() {
        document.addEventListener("DOMContentLoaded", function() {
            var toggle = document.getElementById("mobile-menu-toggle");
            var sidebar = document.getElementById("app-sidebar");
            var overlay = document.getElementById("sidebar-overlay");
            var closeBtn = document.getElementById("sidebar-close-btn");

            function openSidebar() {
                if (!sidebar) return;
                sidebar.classList.add("open");
                if (overlay) overlay.classList.add("open");
                document.body.style.overflow = "hidden"; // Prevent background scroll
            }

            function closeSidebar() {
                if (!sidebar) return;
                sidebar.classList.remove("open");
                if (overlay) overlay.classList.remove("open");
                document.body.style.overflow = "";
            }

            if (toggle) {
                toggle.style.display = window.innerWidth <= 768 ? "inline-flex" : "none";
                toggle.addEventListener("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (sidebar && sidebar.classList.contains("open")) {
                        closeSidebar();
                    } else {
                        openSidebar();
                    }
                });
            }

            if (closeBtn) {
                closeBtn.addEventListener("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    closeSidebar();
                });
            }

            if (overlay) {
                overlay.addEventListener("click", closeSidebar);
            }

            // Close on ESC
            document.addEventListener("keydown", function(e) {
                if (e.key === "Escape" && sidebar && sidebar.classList.contains("open")) {
                    closeSidebar();
                }
            });

            // Lead submenu dropdown toggle handling
            var leadToggleBtn = document.getElementById("lead-toggle-btn");
            var leadDropdown = document.getElementById("lead-nav-dropdown");
            if (leadToggleBtn && leadDropdown) {
                leadToggleBtn.addEventListener("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    leadDropdown.classList.toggle("open");
                    var isOpen = leadDropdown.classList.contains("open");
                    leadToggleBtn.setAttribute("aria-expanded", isOpen ? "true" : "false");
                });
            }

            // Close when clicking nav items on mobile
            if (sidebar) {
                var navLinks = sidebar.querySelectorAll(".nav-item, .nav-sub-item");
                navLinks.forEach(function(link) {
                    link.addEventListener("click", function() {
                        if (window.innerWidth <= 768) {
                            closeSidebar();
                        }
                    });
                });
            }

            // Window resize adjustment
            window.addEventListener("resize", function() {
                if (toggle) {
                    toggle.style.display = window.innerWidth <= 768 ? "inline-flex" : "none";
                }
                if (window.innerWidth > 768) {
                    closeSidebar();
                }
            });
        });
    })();
</script>
