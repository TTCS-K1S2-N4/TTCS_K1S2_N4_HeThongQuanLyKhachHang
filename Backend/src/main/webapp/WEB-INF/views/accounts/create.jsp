<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.Role" %>
<%@ page import="com.crm.model.Team" %>

<%
    String fullNameVal = request.getAttribute("fullName") != null ? (String) request.getAttribute("fullName") : "";
    String emailVal = request.getAttribute("email") != null ? (String) request.getAttribute("email") : "";
    String phoneVal = request.getAttribute("phone") != null ? (String) request.getAttribute("phone") : "";
    String teamIdVal = request.getAttribute("teamIdStr") != null ? (String) request.getAttribute("teamIdStr") : "";
    String[] roleIdsVal = (String[]) request.getAttribute("roleIdsParam");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tạo mới tài khoản người dùng | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/accounts/list">Quản lý tài khoản</a>
                <span>/</span>
                <span class="breadcrumb-current">Tạo mới tài khoản</span>
            </nav>

            <!-- Page Title -->
            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title" style="display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-user-plus" style="color: var(--frost-blue-600); font-size: 24px;"></i>
                        Tạo tài khoản người dùng
                    </h1>
                    <p class="page-description" style="color: var(--frost-slate-600); margin-top: 4px;">
                        Cấp quyền cho nhân viên kinh doanh mới ngay ngày đầu nhận địa bàn phụ trách.
                    </p>
                </div>
                <div class="page-actions">
                    <a href="${pageContext.request.contextPath}/accounts/list" class="btn-secondary-frost">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>

            <!-- Form Card -->
            <div class="account-form-card">
                <div class="account-form-header">
                    <h2>
                        <i class="fa-solid fa-address-card" style="color: var(--frost-blue-600);"></i>
                        Thông tin tài khoản &amp; Phân quyền
                    </h2>
                    <p>Nhập thông tin nhân sự và thiết lập vai trò để kích hoạt tài khoản trên hệ thống.</p>
                </div>

                <div class="account-form-body">
                    <!-- Duplicate Email or Validation Error Alert -->
                    <% if (error != null && !error.trim().isEmpty()) { %>
                        <div class="frost-alert frost-alert-danger" role="alert">
                            <i class="fas fa-triangle-exclamation frost-alert-icon"></i>
                            <div>
                                <strong style="display: block; margin-bottom: 2px;">Không thể tạo tài khoản!</strong>
                                <span><%= error %></span>
                            </div>
                        </div>
                    <% } %>

                    <!-- Automatic Activation & Temporary Password Notice Callout -->
                    <div class="account-notice-callout">
                        <div class="notice-icon-circle">
                            <i class="fas fa-envelope-open-text"></i>
                        </div>
                        <div class="notice-content">
                            <h4>Quy trình gửi email kích hoạt kèm mật khẩu tạm</h4>
                            <p>
                                Sau khi hoàn tất tạo tài khoản, hệ thống sẽ tự động khởi tạo mật khẩu tạm thời ngẫu nhiên có độ bảo mật cao và gửi email kích hoạt tới địa chỉ email công ty của nhân viên. Nhân viên sẽ đăng nhập bằng mật khẩu tạm và được yêu cầu đổi mật khẩu mới trong lần truy cập đầu tiên.
                            </p>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/accounts/create" method="post">
                        <!-- Full Name & Email Grid -->
                        <div class="form-grid-2">
                            <div class="form-group-custom">
                                <label class="form-label-custom" for="editFullName">
                                    Họ và tên <span class="required-star">*</span>
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-regular fa-user input-icon"></i>
                                    <input id="editFullName" name="fullName" class="form-input-custom" type="text" 
                                           placeholder="Ví dụ: Nguyễn Văn An" value="<%= fullNameVal %>" required>
                                </div>
                                <span class="form-hint">Họ tên đầy đủ theo hồ sơ nhân sự của nhân viên.</span>
                            </div>

                            <div class="form-group-custom">
                                <label class="form-label-custom" for="editEmail">
                                    Email công ty <span class="required-star">*</span>
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-regular fa-envelope input-icon"></i>
                                    <input id="editEmail" name="email" class="form-input-custom" type="email" 
                                           placeholder="Ví dụ: nhanvien@congty.com" value="<%= emailVal %>" required>
                                </div>
                                <span class="form-hint">Email duy nhất dùng làm tên đăng nhập và nhận thư kích hoạt.</span>
                            </div>
                        </div>

                        <!-- Phone & Role Grid -->
                        <div class="form-grid-2">
                            <div class="form-group-custom">
                                <label class="form-label-custom" for="editPhone">
                                    Số điện thoại
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-solid fa-phone input-icon"></i>
                                    <input id="editPhone" name="phone" class="form-input-custom" type="tel" 
                                           placeholder="Ví dụ: 0912 345 678" value="<%= phoneVal %>">
                                </div>
                                <span class="form-hint">Số điện thoại liên hệ nội bộ hoặc di động.</span>
                            </div>

                            <div class="form-group-custom">
                                <label class="form-label-custom" for="roleIds">
                                    Vai trò hệ thống <span class="required-star">*</span>
                                </label>
                                <div class="input-with-icon">
                                    <i class="fa-solid fa-shield-halved input-icon"></i>
                                    <select id="roleIds" name="roleIds" class="form-select-custom" required>
                                        <option value="">-- Chọn vai trò người dùng --</option>
                                        <% 
                                        List<Role> roles = (List<Role>) request.getAttribute("roles");
                                        if (roles != null) {
                                            for (Role r : roles) {
                                                boolean selected = roleIdsVal != null && roleIdsVal.length > 0 && String.valueOf(r.getId()).equals(roleIdsVal[0]);
                                        %>
                                        <option value="<%= r.getId() %>" <%= selected ? "selected" : "" %>><%= r.getName() %></option>
                                        <% 
                                            }
                                        } 
                                        %>
                                    </select>
                                </div>
                                <span class="form-hint">Quyết định quyền hạn và các chức năng nhân viên được truy cập.</span>
                            </div>
                        </div>

                        <!-- Team Selection -->
                        <div class="form-group-custom">
                            <label class="form-label-custom" for="teamId">
                                Nhóm kinh doanh phụ trách
                            </label>
                            <div class="input-with-icon">
                                <i class="fa-solid fa-user-group input-icon"></i>
                                <select id="teamId" name="teamId" class="form-select-custom">
                                    <option value="">-- Chọn nhóm kinh doanh (Không bắt buộc nếu là Quản trị) --</option>
                                    <% 
                                    List<Team> teams = (List<Team>) request.getAttribute("teams");
                                    if (teams != null) {
                                        for (Team t : teams) {
                                            boolean selected = teamIdVal.equals(String.valueOf(t.getId()));
                                    %>
                                    <option value="<%= t.getId() %>" <%= selected ? "selected" : "" %>><%= t.getName() %> (<%= t.getRegion() != null ? t.getRegion() : "Toàn quốc" %>)</option>
                                    <% 
                                        }
                                    } 
                                    %>
                                </select>
                            </div>
                            <span class="form-hint">Gán địa bàn hoạt động ngay ngày đầu để nhân viên phụ trách khách hàng theo nhóm.</span>
                        </div>

                        <!-- Form Actions Bar -->
                        <div class="form-actions-bar">
                            <a class="btn-secondary-frost" href="${pageContext.request.contextPath}/accounts/list">
                                <i class="fas fa-times"></i> Hủy bỏ
                            </a>
                            <button class="btn-primary-frost" type="submit">
                                <i class="fas fa-paper-plane"></i> Tạo tài khoản &amp; Gửi email kích hoạt
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
