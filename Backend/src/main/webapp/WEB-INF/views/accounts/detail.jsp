<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết tài khoản | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css?v=2">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Quản lý tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Chi tiết tài khoản</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 8px;">Thông tin hồ sơ và quyền truy cập của tài khoản.</p>
                </div>
            </div>

            <div class="card" style="margin-bottom: var(--space-6);">
                <div class="card-body">
                    <div class="account-profile" style="margin-bottom: 0; align-items: center; display: flex; justify-content: space-between; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: var(--space-5);">
                            <div class="account-profile-avatar">
                                <% 
                                    com.crm.model.Account acc = (com.crm.model.Account)request.getAttribute("account");
                                    String n = acc.getFullName();
                                    String i = "";
                                    if (n != null && !n.trim().isEmpty()) {
                                        String[] p = n.trim().split("\\s+");
                                        if (p.length == 1) {
                                            i = p[0].substring(0, Math.min(2, p[0].length())).toUpperCase();
                                        } else {
                                            i = (p[0].substring(0, 1) + p[p.length - 1].substring(0, 1)).toUpperCase();
                                        }
                                    }
                                    out.print(i);
                                %>
                            </div>
                            <div>
                                <div class="account-profile-name"><c:out value="${account.fullName}"/></div>
                                <div class="account-profile-email"><i class="fas fa-envelope" style="width:16px;text-align:center;color:var(--color-text-secondary);margin-right:4px;"></i> <c:out value="${account.email}"/></div>
                                <div class="account-profile-email" style="margin-bottom:0;"><i class="fas fa-user-friends" style="width:16px;text-align:center;color:var(--color-text-secondary);margin-right:4px;"></i> <c:out value="${account.roleName}"/></div>
                            </div>
                        </div>
                        <div style="margin-top: 10px;">
                            <c:choose>
                                <c:when test="${account.status == 'ACTIVE'}"><span class="badge badge-success"><i class="fas fa-circle" style="font-size: 8px;"></i> Đang hoạt động</span></c:when>
                                <c:when test="${account.status == 'INACTIVE'}"><span class="badge badge-secondary"><i class="fas fa-circle" style="font-size: 8px;"></i> Ngừng hoạt động</span></c:when>
                                <c:when test="${account.status == 'LOCKED'}"><span class="badge badge-danger"><i class="fas fa-lock" style="font-size: 10px;"></i> Đã khóa</span></c:when>
                                <c:otherwise><span class="badge badge-secondary"><c:out value="${account.status}"/></span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title"><i class="fas fa-address-card" style="margin-right: 8px; color: var(--color-primary);"></i> Thông tin tài khoản</h2>
                </div>
                <div class="card-body">
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-user" style="width:16px;text-align:center;"></i> Họ và tên</div>
                        <div class="detail-value"><c:out value="${account.fullName}"/></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-envelope" style="width:16px;text-align:center;"></i> Email</div>
                        <div class="detail-value"><c:out value="${account.email}"/></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-phone" style="width:16px;text-align:center;"></i> Điện thoại</div>
                        <div class="detail-value" style="display:flex; align-items:center; gap: 8px;">
                            <c:choose>
                                <c:when test="${empty account.phone}"><span style="color: var(--color-text-secondary);">—</span> <span class="badge badge-secondary" style="background:#f1f5f9; color:#64748b; font-weight:normal; font-size:12px;">Chưa cập nhật</span></c:when>
                                <c:otherwise><c:out value="${account.phone}"/></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-shield-alt" style="width:16px;text-align:center;"></i> Vai trò</div>
                        <div class="detail-value"><span class="badge badge-primary-light"><c:out value="${account.roleName}"/></span></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-users" style="width:16px;text-align:center;"></i> Nhóm</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${empty account.teamName}"><span style="color: var(--color-text-secondary);">—</span></c:when>
                                <c:otherwise><c:out value="${account.teamName}"/></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-bolt" style="width:16px;text-align:center;"></i> Trạng thái</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${account.status == 'ACTIVE'}"><span class="badge badge-success"><i class="fas fa-circle" style="font-size: 8px;"></i> Đang hoạt động</span></c:when>
                                <c:when test="${account.status == 'INACTIVE'}"><span class="badge badge-secondary"><i class="fas fa-circle" style="font-size: 8px;"></i> Ngừng hoạt động</span></c:when>
                                <c:when test="${account.status == 'LOCKED'}"><span class="badge badge-danger"><i class="fas fa-lock" style="font-size: 10px;"></i> Đã khóa</span></c:when>
                                <c:otherwise><span class="badge badge-secondary"><c:out value="${account.status}"/></span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="card-footer" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                    <div>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/list"><i class="fas fa-arrow-left" style="margin-right:6px;"></i> Quay lại</a>
                    </div>
                    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/accounts/edit?accountId=${account.accountId}"><i class="fas fa-pen" style="margin-right:6px;"></i> Chỉnh sửa</a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/accounts/assign-role?accountId=${account.accountId}" style="background: white; border: 1px solid var(--color-primary); color: var(--color-primary);"><i class="fas fa-user-tag" style="margin-right:6px;"></i> Gán vai trò</a>
                        <c:if test="${account.status == 'ACTIVE'}">
                            <a class="btn btn-danger" href="${pageContext.request.contextPath}/accounts/lock?accountId=${account.accountId}"><i class="fas fa-lock" style="margin-right:6px;"></i> Khóa và bàn giao</a>
                        </c:if>
                        <c:if test="${account.status != 'ACTIVE'}">
                            <a class="btn btn-success" href="${pageContext.request.contextPath}/accounts/unlock?accountId=${account.accountId}" onclick="return confirm('Bạn có chắc chắn muốn mở khóa tài khoản này?');"><i class="fas fa-unlock" style="margin-right:6px;"></i> Mở khóa tài khoản</a>
                        </c:if>
                    </div>
                </div>
            </div>

        </div>
    </main>
</div>
</body>
</html>
