<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.model.Account" %>
<%
    Account currentUser = (Account) session.getAttribute("currentUser");
    String userName = (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Người dùng";
    String userRole = (currentUser != null && currentUser.getRoleName() != null) ? currentUser.getRoleName() : "Administrator";
    String userInitial = (userName.length() > 0) ? userName.substring(0, 1).toUpperCase() : "U";
    String userTeam = (currentUser != null && currentUser.getTeamName() != null) ? currentUser.getTeamName() : "Chưa thuộc nhóm";
    String avatarUrl = (currentUser != null) ? currentUser.getAvatarUrl() : null;
    boolean hasAvatar = (avatarUrl != null && !avatarUrl.trim().isEmpty());
%>
<header class="app-header frost-app-header">
    <div class="header-left">
        <!-- MOBILE MENU HAMBURGER BUTTON (TOUCH-OPTIMIZED FOR 360px) -->
        <button id="mobile-menu-toggle" class="btn-mobile-toggle" aria-label="Mở menu điều hướng" title="Mở menu điều hướng">
            <i class="fa-solid fa-bars"></i>
        </button>
        
        <!-- FROSTLINE CRM BRAND LOCKUP -->
        <a class="header-brand frost-brand-lockup" href="${pageContext.request.contextPath}/" title="Frostline CRM - Trang chủ">
            <div class="frost-header-logo-icon">
                <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <linearGradient id="frostHeaderGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#0284c7" />
                            <stop offset="100%" stop-color="#0369a1" />
                        </linearGradient>
                        <linearGradient id="frostHeaderGrad2" x1="100%" y1="0%" x2="0%" y2="100%">
                            <stop offset="0%" stop-color="#38bdf8" />
                            <stop offset="100%" stop-color="#0284c7" />
                        </linearGradient>
                        <linearGradient id="frostHeaderFacet" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#38bdf8" stop-opacity="0.95" />
                            <stop offset="100%" stop-color="#0284c7" stop-opacity="0.3" />
                        </linearGradient>
                    </defs>
                    <path d="M24 3L43 14V34L24 45L5 34V14L24 3Z" stroke="url(#frostHeaderGrad1)" stroke-width="2.5" fill="#f0f9ff" />
                    <path d="M24 3V45" stroke="url(#frostHeaderGrad2)" stroke-width="1.5" stroke-dasharray="2 2" />
                    <path d="M5 14L43 34" stroke="url(#frostHeaderGrad1)" stroke-width="1.2" stroke-opacity="0.35" />
                    <path d="M5 34L43 14" stroke="url(#frostHeaderGrad1)" stroke-width="1.2" stroke-opacity="0.35" />
                    <polygon points="24,13 34,24 24,35 14,24" fill="url(#frostHeaderFacet)" />
                    <circle cx="24" cy="24" r="3.5" fill="#0284c7" />
                </svg>
            </div>
            <div class="frost-header-brand-text">
                <span class="frost-brand-name">Frostline</span>
                <span class="frost-brand-pill">CRM</span>
            </div>
        </a>
    </div>

    <div class="header-right">
        <div class="header-user">
            <!-- USER PROFILE INFO (DESKTOP) / AVATAR SHORTCUT (MOBILE) -->
            <a href="${pageContext.request.contextPath}/pages/profile/index.html?t=<%= System.currentTimeMillis() %>" class="header-user-link" title="Xem hồ sơ cá nhân">
                <div class="user-avatar-box">
                    <% if (hasAvatar) { %>
                        <img src="<%= avatarUrl %>" alt="Avatar" class="user-avatar-img">
                    <% } else { %>
                        <span class="user-avatar-initial"><%= userInitial %></span>
                    <% } %>
                    <span class="user-online-dot"></span>
                </div>
                <div class="header-user-info">
                    <div class="user-name-text">
                        <%= userName %>
                    </div>
                    <div class="user-role-text">
                        <%= userRole %> • <%= userTeam %>
                    </div>
                </div>
            </a>

            <!-- LOGOUT BUTTON -->
            <a href="${pageContext.request.contextPath}/auth/logout" class="btn-header-logout" title="Đăng xuất khỏi hệ thống">
                <i class="fa-solid fa-arrow-right-from-bracket"></i>
                <span class="logout-label">Đăng xuất</span>
            </a>
        </div>
    </div>
</header>
<jsp:include page="/WEB-INF/views/fragments/toast.jsp"/>

<style>
    /* TOPBAR FOUNDATION */
    .frost-app-header {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        height: 64px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border-bottom: 1px solid #e2e8f0;
        box-shadow: 0 2px 12px rgba(15, 23, 42, 0.04);
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 1.5rem;
        z-index: 998;
    }

    .header-left, .header-right {
        display: flex;
        align-items: center;
        gap: 0.85rem;
    }

    /* MOBILE HAMBURGER BUTTON */
    .btn-mobile-toggle {
        display: none;
        align-items: center;
        justify-content: center;
        width: 38px;
        height: 38px;
        border-radius: 10px;
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        color: #0f172a;
        font-size: 1.05rem;
        cursor: pointer;
        transition: all 0.2s ease;
        flex-shrink: 0;
    }
    .btn-mobile-toggle:hover {
        background: #e2e8f0;
        color: #0284c7;
    }

    /* BRAND LOCKUP */
    .frost-brand-lockup {
        display: flex;
        align-items: center;
        gap: 0.65rem;
        text-decoration: none;
        flex-shrink: 0;
    }
    .frost-header-logo-icon {
        width: 34px;
        height: 34px;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        filter: drop-shadow(0 2px 8px rgba(2, 132, 199, 0.25));
        transition: transform 0.25s ease;
    }
    .frost-brand-lockup:hover .frost-header-logo-icon {
        transform: scale(1.08) rotate(3deg);
    }
    .frost-header-logo-icon svg {
        width: 100%;
        height: 100%;
    }
    .frost-header-brand-text {
        display: flex;
        align-items: baseline;
        gap: 0.35rem;
    }
    .frost-brand-name {
        font-family: 'Space Grotesk', 'Plus Jakarta Sans', system-ui, sans-serif;
        font-size: 1.25rem;
        font-weight: 700;
        color: #0f172a;
        letter-spacing: -0.02em;
    }
    .frost-brand-pill {
        font-size: 0.65rem;
        font-weight: 800;
        color: #0284c7;
        background: rgba(2, 132, 199, 0.1);
        border: 1px solid rgba(2, 132, 199, 0.28);
        padding: 0.12rem 0.45rem;
        border-radius: 5px;
        letter-spacing: 0.05em;
        text-transform: uppercase;
    }

    /* USER AVATAR & INFO */
    .header-user {
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .header-user-link {
        display: flex;
        align-items: center;
        gap: 0.65rem;
        text-decoration: none;
        padding: 0.35rem 0.55rem;
        border-radius: 10px;
        transition: background 0.2s ease;
    }
    .header-user-link:hover {
        background: #f1f5f9;
    }
    .user-avatar-box {
        position: relative;
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: #e0f2fe;
        color: #0284c7;
        font-weight: 700;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #bae6fd;
        flex-shrink: 0;
    }
    .user-avatar-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
    }
    .user-online-dot {
        position: absolute;
        bottom: 0;
        right: 0;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #10b981;
        border: 1.5px solid #ffffff;
    }
    .header-user-info {
        display: flex;
        flex-direction: column;
    }
    .user-name-text {
        font-size: 0.865rem;
        font-weight: 600;
        color: #0f172a;
        line-height: 1.25;
    }
    .user-role-text {
        font-size: 0.72rem;
        color: #64748b;
        line-height: 1.2;
    }

    /* LOGOUT BUTTON */
    .btn-header-logout {
        display: inline-flex;
        align-items: center;
        gap: 0.4rem;
        padding: 0.45rem 0.8rem;
        border-radius: 8px;
        font-size: 0.825rem;
        font-weight: 500;
        color: #475569;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        text-decoration: none;
        transition: all 0.2s ease;
    }
    .btn-header-logout:hover {
        background: #fee2e2;
        border-color: #fca5a5;
        color: #b91c1c;
    }

    /* =========================================================
       RESPONSIVE & 360PX ADAPTATION
       ========================================================= */
    @media (max-width: 768px) {
        .frost-app-header {
            padding: 0 1rem;
        }
        .btn-mobile-toggle {
            display: inline-flex;
        }
    }

    @media (max-width: 640px) {
        .header-user-info {
            display: none; /* Hide long text on mobile to avoid overflow */
        }
        .logout-label {
            display: none; /* Keep logout icon compact */
        }
        .btn-header-logout {
            padding: 0.45rem 0.6rem;
        }
    }

    /* 360px SCREEN SPECIFIC TUNING */
    @media (max-width: 380px) {
        .frost-app-header {
            padding: 0 0.65rem;
        }
        .frost-header-logo-icon {
            width: 30px;
            height: 30px;
        }
        .frost-brand-name {
            font-size: 1.05rem;
        }
        .header-left, .header-right {
            gap: 0.45rem;
        }
        .user-avatar-box {
            width: 34px;
            height: 34px;
            font-size: 0.85rem;
        }
    }
</style>
