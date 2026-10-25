<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết tài khoản | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Quản lý tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Hồ sơ người dùng</span>
            </nav>

            <!-- Page Title -->
            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title" style="display: flex; align-items: center; gap: 10px;">
                        <i class="fa-solid fa-address-card" style="color: var(--frost-blue-600); font-size: 24px;"></i>
                        Hồ sơ tài khoản người dùng
                    </h1>
                    <p class="page-description" style="color: var(--frost-slate-600); margin-top: 4px;">
                        Chi tiết lý lịch nhân sự, vai trò hệ thống và địa bàn kinh doanh được phân bổ.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 10px; align-items: center;">
                    <a href="${pageContext.request.contextPath}/accounts/list" class="btn-secondary-frost">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                    <a href="${pageContext.request.contextPath}/accounts/edit?accountId=${account.accountId}" class="btn-primary-frost">
                        <i class="fas fa-user-pen"></i> Chỉnh sửa tài khoản
                    </a>
                </div>
            </div>

            <!-- Update Success Alert -->
            <% if ("updated".equals(msg)) { %>
                <div class="frost-alert frost-alert-success">
                    <i class="fas fa-circle-check frost-alert-icon"></i>
                    <div>
                        <strong>Cập nhật thành công!</strong> Thông tin hồ sơ và phân quyền tài khoản đã được ghi nhận vào nhật ký hệ thống.
                    </div>
                </div>
            <% } %>

            <!-- Profile Hero Card -->
            <div class="profile-hero-card">
                <div class="profile-hero-left">
                    <div class="profile-hero-avatar">
                        <% 
                            com.crm.model.Account acc = (com.crm.model.Account)request.getAttribute("account");
                            String n = acc != null ? acc.getFullName() : "";
                            String i = "";
                            if (n != null && !n.trim().isEmpty()) {
                                String[] p = n.trim().split("\\s+");
                                if (p.length == 1) {
                                    i = p[0].substring(0, Math.min(2, p[0].length())).toUpperCase();
                                } else {
                                    i = (p[0].substring(0, 1) + p[p.length - 1].substring(0, 1)).toUpperCase();
                                }
                            }
                            out.print(i.isEmpty() ? "U" : i);
                        %>
                    </div>
                    <div>
                        <div class="profile-hero-name"><c:out value="${account.fullName}"/></div>
                        <div class="profile-hero-meta">
                            <span><i class="fa-regular fa-envelope" style="color: var(--frost-blue-600);"></i> <c:out value="${account.email}"/></span>
                            <span><i class="fa-solid fa-phone" style="color: var(--frost-emerald-600);"></i> <c:out value="${empty account.phone ? 'Chưa cập nhật SĐT' : account.phone}"/></span>
                            <span><i class="fa-solid fa-user-group" style="color: var(--frost-amber-600);"></i> <c:out value="${empty account.teamName ? 'Chưa thuộc nhóm' : account.teamName}"/></span>
                        </div>
                    </div>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${account.status == 'ACTIVE'}">
                            <span class="status-badge status-active" style="padding: 6px 14px; font-size: 13px;">
                                <span class="status-dot-active"></span> Đang hoạt động
                            </span>
                        </c:when>
                        <c:when test="${account.status == 'LOCKED'}">
                            <span class="status-badge status-locked" style="padding: 6px 14px; font-size: 13px;">
                                <i class="fas fa-lock" style="font-size: 11px;"></i> Đã bị khóa
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge" style="background:#f1f5f9; color:#475569; padding: 6px 14px;"><c:out value="${account.status}"/></span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Detail Information Card -->
            <div class="accounts-list-card">
                <div class="accounts-toolbar-container" style="background: var(--frost-slate-50); border-bottom: 1px solid var(--frost-slate-200);">
                    <h3 style="font-size: 16px; font-weight: 700; color: var(--frost-slate-900); margin: 0; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-id-card-clip" style="color: var(--frost-blue-600);"></i>
                        Thông tin chi tiết hồ sơ
                    </h3>
                </div>

                <div style="padding: 24px 30px;">
                    <div class="detail-row">
                        <div class="detail-label"><i class="fa-regular fa-user" style="width:18px;"></i> Họ và tên</div>
                        <div class="detail-value"><c:out value="${account.fullName}"/></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fa-regular fa-envelope" style="width:18px;"></i> Email công ty</div>
                        <div class="detail-value"><c:out value="${account.email}"/></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fa-solid fa-phone" style="width:18px;"></i> Số điện thoại</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${empty account.phone}">
                                    <span style="color: var(--frost-slate-400); font-style: italic;">Chưa cập nhật số điện thoại</span>
                                </c:when>
                                <c:otherwise><c:out value="${account.phone}"/></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fa-solid fa-shield-halved" style="width:18px;"></i> Vai trò hệ thống</div>
                        <div class="detail-value">
                            <span class="badge-role">
                                <i class="fa-solid fa-shield-halved" style="font-size: 11px;"></i>
                                <c:out value="${account.roleName}"/>
                            </span>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fa-solid fa-users" style="width:18px;"></i> Nhóm kinh doanh</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${empty account.teamName}">
                                    <span style="color: var(--frost-slate-400); font-style: italic;">Chưa được phân nhóm địa bàn</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-team">
                                        <i class="fa-solid fa-user-group" style="font-size: 11px;"></i>
                                        <c:out value="${account.teamName}"/>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fa-solid fa-circle-check" style="width:18px;"></i> Trạng thái hoạt động</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${account.status == 'ACTIVE'}">
                                    <span class="status-badge status-active"><span class="status-dot-active"></span> Đang hoạt động bình thường</span>
                                </c:when>
                                <c:when test="${account.status == 'LOCKED'}">
                                    <span class="status-badge status-locked"><i class="fas fa-lock" style="font-size: 10px;"></i> Đang bị khóa truy cập</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge"><c:out value="${account.status}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Footer Quick Actions -->
                <div class="accounts-pagination-footer" style="background: var(--frost-slate-50);">
                    <div>
                        <a class="btn-secondary-frost" href="${pageContext.request.contextPath}/accounts/list">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a class="btn-primary-frost" href="${pageContext.request.contextPath}/accounts/edit?accountId=${account.accountId}">
                            <i class="fas fa-pen-to-square"></i> Chỉnh sửa
                        </a>
                        <a class="btn-secondary-frost" href="${pageContext.request.contextPath}/accounts/assign-role?accountId=${account.accountId}">
                            <i class="fas fa-user-tag"></i> Gán vai trò
                        </a>
                        <c:if test="${account.status == 'ACTIVE'}">
                            <a class="btn-secondary-frost" style="color: var(--frost-rose-600); border-color: var(--frost-rose-200); background: var(--frost-rose-50);" 
                               href="${pageContext.request.contextPath}/accounts/lock?accountId=${account.accountId}">
                                <i class="fas fa-lock"></i> Khóa và bàn giao
                            </a>
                        </c:if>
                        <c:if test="${account.status != 'ACTIVE'}">
                            <a class="btn-secondary-frost" style="color: var(--frost-emerald-600); border-color: var(--frost-emerald-200); background: var(--frost-emerald-50);" 
                               href="${pageContext.request.contextPath}/accounts/unlock?accountId=${account.accountId}" 
                               onclick="return confirm('Bạn có chắc chắn muốn mở khóa tài khoản này?');">
                                <i class="fas fa-unlock"></i> Mở khóa tài khoản
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
