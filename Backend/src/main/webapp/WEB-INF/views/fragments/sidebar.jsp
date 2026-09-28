<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.crm.service.PermissionService" %>
<%@ page import="com.crm.model.MenuItem" %>
<%@ page import="java.util.List" %>
<%
    PermissionService permissionService = new PermissionService();
    java.util.List<Integer> sessionRoleIds = new com.crm.dao.AccountDAO().getAccountById((Integer) session.getAttribute("userId")).getRoleIds();
    Integer sessionRoleId = (Integer) session.getAttribute("roleId");
    List<MenuItem> menuItems = permissionService.getMenuByRoles(sessionRoleIds != null ? sessionRoleIds : java.util.Collections.singletonList(sessionRoleId != null ? sessionRoleId : 0));
    String currentUri = request.getRequestURI();
%>
<aside class="sidebar" id="app-sidebar">
    <nav aria-label="Äiá»u hÆ°á»›ng chÃ­nh">
        <div class="sidebar-section">
            <% for (MenuItem item : menuItems) { 
                boolean isActive = currentUri.startsWith(request.getContextPath() + item.getUrl());
            %>
                <a class="nav-item <%= isActive ? "active" : "" %>" href="${pageContext.request.contextPath}<%= item.getUrl() %>">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid <%= item.getIcon() %>"></i></span>
                    <span><%= item.getTitle() %></span>
                </a>
            <% } %>
            
            <%-- Static fallback for Account management if it has no menu item in DB --%>
            <% 
               boolean isAccountManager = permissionService.hasPermissionForRoles(sessionRoleIds != null ? sessionRoleIds : java.util.Collections.singletonList(sessionRoleId != null ? sessionRoleId : 0), "USER_VIEW") || 
                                          permissionService.hasPermissionForRoles(sessionRoleIds != null ? sessionRoleIds : java.util.Collections.singletonList(sessionRoleId != null ? sessionRoleId : 0), "ACCOUNT_VIEW");
               if (isAccountManager && menuItems.stream().noneMatch(m -> m.getUrl().contains("/accounts"))) { 
                   boolean isAccActive = currentUri.startsWith(request.getContextPath() + "/accounts");
            %>
                <a class="nav-item <%= isAccActive ? "active" : "" %>" href="${pageContext.request.contextPath}/accounts/list">
                    <span class="nav-icon" aria-hidden="true"><i class="fa-solid fa-user-cog"></i></span>
                    <span>Quản lý tài khoản</span>
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


