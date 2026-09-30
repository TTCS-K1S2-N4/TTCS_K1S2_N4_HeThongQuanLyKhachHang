<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.model.Account" %>
<%
    Account currentUser = (Account) session.getAttribute("currentUser");
    String userName = (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Người dùng";
    String userRole = (currentUser != null && currentUser.getRoleName() != null) ? currentUser.getRoleName() : "Administrator";
    String userInitial = (userName.length() > 0) ? userName.substring(0, 1).toUpperCase() : "U";
    String userTeam = (currentUser != null && currentUser.getTeamName() != null) ? currentUser.getTeamName() : "Chưa thuộc nhóm";
%>
<header class="app-header">
    <div class="header-left">
        <button id="mobile-menu-toggle" class="btn btn-secondary btn-sm" aria-label="Toggle Menu" style="display: none; margin-right: 1rem;">
            <i class="fa-solid fa-bars"></i>
        </button>
        <a class="header-brand" href="${pageContext.request.contextPath}/">
            <span class="brand-mark">CRM</span>
            <span>CRM System</span>
        </a>
        <div class="header-divider"></div>
    </div>

    <div class="header-right">
        <div class="header-user">
            <div class="user-avatar">
                <%= userInitial %>
            </div>
            <div class="header-user-info">
                <div class="user-name">
                    <%= userName %>
                </div>
                <div class="user-role">
                    <%= userRole %> - <%= userTeam %>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-secondary btn-sm" style="margin-left: 1rem;" title="Đăng xuất">
                <i class="fa-solid fa-sign-out-alt"></i> <span class="logout-text">Đăng xuất</span>
            </a>
        </div>
    </div>
</header>
