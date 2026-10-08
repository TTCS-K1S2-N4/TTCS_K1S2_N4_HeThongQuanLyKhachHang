<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.service.PermissionService" %>
<%@ page import="com.crm.model.MenuItem" %>
<%@ page import="java.util.List" %>
<%
    PermissionService permissionService = new PermissionService();
    java.util.List<Integer> sessionRoleIds = com.crm.util.ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds"));
    Integer sessionRoleId = (Integer) session.getAttribute("roleId");
    java.util.List<Integer> effectiveRoleIds = sessionRoleIds != null && !sessionRoleIds.isEmpty()
            ? sessionRoleIds
            : java.util.Collections.singletonList(sessionRoleId != null ? sessionRoleId : 0);
    List<MenuItem> menuItems = permissionService.getMenuByRoles(effectiveRoleIds);
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
%>
<aside class="sidebar" id="app-sidebar">
    <nav aria-label="Điều hướng chính">
        <div class="sidebar-section">
            <a class="nav-item <%= isDashboardActive ? "active" : "" %>" href="${pageContext.request.contextPath}/">
                <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-house"></i></span>
                <span>Dashboard</span>
            </a>
            <% 
               java.util.Set<String> seenUrls = new java.util.HashSet<>();
               for (MenuItem item : menuItems) { 
                String itemUrl = item.getUrl();
                if (itemUrl != null && !seenUrls.add(itemUrl)) {
                    continue;
                }
                boolean isActive = false;
                if (!isDashboardActive && itemUrl != null) {
                    if (itemUrl.equals("/customers") && relativePath.startsWith("/customers") && !relativePath.startsWith("/customers/care")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/customers/care") && relativePath.startsWith("/customers/care")) {
                        isActive = true;
                    } else if ((itemUrl.startsWith("/deals") || itemUrl.startsWith("/opportunities")) && (relativePath.startsWith("/deals") || relativePath.startsWith("/opportunities"))) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/activities") && relativePath.startsWith("/activities")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/quotes") && relativePath.startsWith("/quotes")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/accounts") && relativePath.startsWith("/accounts")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/audit") && relativePath.startsWith("/audit")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/products") && relativePath.startsWith("/products")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/categories") && relativePath.startsWith("/categories")) {
                        isActive = true;
                    } else if (itemUrl.startsWith("/organization") && relativePath.startsWith("/organization")) {
                        isActive = true;
                    } else if (itemUrl.length() > 1 && relativePath.startsWith(itemUrl)) {
                        isActive = true;
                    }
                }
            %>
                <a class="nav-item <%= isActive ? "active" : "" %>" href="${pageContext.request.contextPath}<%= item.getUrl() %>">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid <%= item.getIcon() %>"></i></span>
                    <span><%= item.getTitle() %></span>
                </a>
            <% } %>

            <%-- Static fallback for Customer Care if it has no menu item in DB --%>
            <% 
               if (menuItems.stream().noneMatch(m -> m.getUrl().contains("/customers/care"))) { 
                   boolean isCareActive = !isDashboardActive && relativePath.startsWith("/customers/care");
            %>
                <a class="nav-item <%= isCareActive ? "active" : "" %>" href="${pageContext.request.contextPath}/customers/care">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-calendar-check"></i></span>
                    <span>Chăm sóc định kỳ</span>
                </a>
            <% } %>
            
            <%-- Static fallback for Account management if it has no menu item in DB --%>
            <% 
               boolean isAccountManager = permissionService.hasPermissionForRoles(effectiveRoleIds, "USER_VIEW");
               if (isAccountManager && menuItems.stream().noneMatch(m -> m.getUrl().contains("/accounts"))) { 
                   boolean isAccActive = !isDashboardActive && relativePath.startsWith("/accounts");
            %>
                <a class="nav-item <%= isAccActive ? "active" : "" %>" href="${pageContext.request.contextPath}/accounts/list">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-user-cog"></i></span>
                    <span>Quản lý tài khoản</span>
                </a>
            <% } %>

            <%-- Static fallbacks for Pipeline Configuration (S2-09 & S2-10) --%>
            <% 
               boolean isCategoryManager = permissionService.hasPermissionForRoles(effectiveRoleIds, "CATEGORY_MANAGE");
               if (isCategoryManager) {
            %>
                <a class="nav-item <%= relativePath.startsWith("/pipeline/stages") ? "active" : "" %>" href="${pageContext.request.contextPath}/pipeline/stages">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-stream"></i></span>
                    <span>Giai đoạn Pipeline</span>
                </a>
                <a class="nav-item <%= relativePath.startsWith("/pipeline/win-loss-reasons") ? "active" : "" %>" href="${pageContext.request.contextPath}/pipeline/win-loss-reasons">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-trophy"></i></span>
                    <span>Lý do Thắng/Thua</span>
                </a>
                <a class="nav-item <%= relativePath.startsWith("/pipeline/competitors") ? "active" : "" %>" href="${pageContext.request.contextPath}/pipeline/competitors">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-user-ninja"></i></span>
                    <span>Đối thủ cạnh tranh</span>
                </a>
            <% } %>

        </div>
    </nav>
</aside>
<div id="sidebar-overlay" class="sidebar-overlay"></div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        var toggle = document.getElementById("mobile-menu-toggle");
        var sidebar = document.getElementById("app-sidebar");
        var overlay = document.getElementById("sidebar-overlay");
        
        function updateToggle() {
            if (toggle) {
                toggle.style.display = window.innerWidth <= 768 ? "inline-block" : "none";
            }
            if (window.innerWidth > 768 && sidebar) {
                sidebar.classList.remove("open");
                if (overlay) overlay.classList.remove("open");
            }
        }
        
        updateToggle();
        window.addEventListener("resize", updateToggle);
        
        if (toggle && sidebar && overlay) {
            toggle.addEventListener("click", function() {
                sidebar.classList.toggle("open");
                overlay.classList.toggle("open");
            });
            overlay.addEventListener("click", function() {
                sidebar.classList.remove("open");
                overlay.classList.remove("open");
            });
        }
    });
</script>
<style>
    @media (max-width: 768px) {
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            z-index: 1000;
            transition: transform 0.3s ease;
            transform: translateX(-100%);
            background: var(--bg-surface);
        }
        .sidebar.open {
            transform: translateX(0);
        }
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0,0,0,0.5);
            z-index: 999;
        }
        .sidebar-overlay.open {
            display: block;
        }
        .header-brand {
            display: none !important;
        }
    }
</style>


