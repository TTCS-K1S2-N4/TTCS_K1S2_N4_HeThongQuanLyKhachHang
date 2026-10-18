<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Web Forms | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="content-container lead-page-container">
                
                <!-- Breadcrumb Navigation -->
                <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px;">
                    <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Quản lý Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Web Forms</span>
                </nav>

                <!-- Page Header Banner -->
                <div class="lead-header-banner">
                    <div class="lead-header-left">
                        <div class="lead-header-icon-box" style="background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); border-color: #bfdbfe; color: #2563eb;">
                            <i class="fa-solid fa-code"></i>
                        </div>
                        <div class="lead-header-titles">
                            <h1 class="lead-page-title">
                                Cấu hình Web Form (Thu thập Lead)
                                <span class="badge" style="background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; border-radius: 6px; font-size: 0.72rem; padding: 3px 8px; font-weight: 700;">
                                    Lead Capture Forms
                                </span>
                            </h1>
                            <p class="lead-page-subtitle">
                                Tạo và quản lý các biểu mẫu thu thập thông tin khách hàng tiềm năng tự động từ website nhúng vào CRM.
                            </p>
                        </div>
                    </div>

                    <div class="lead-header-actions">
                        <button type="button" class="btn-lead-primary" id="btnOpenCreatePanel" style="padding: 9px 18px;">
                            <i class="fa-solid fa-plus-circle"></i> Tạo biểu mẫu Web Form mới
                        </button>
                        <a href="${pageContext.request.contextPath}/leads" class="btn-lead-action" title="Quay lại danh sách Lead">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Alert Notifications -->
                <c:if test="${not empty error}">
                    <div class="alert" style="background: #fef2f2; border: 1px solid #fecaca; border-left: 4px solid #ef4444; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #991b1b; display: flex; align-items: center; gap: 10px; font-weight: 500;">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.1rem; color: #ef4444;"></i>
                        <span><c:out value="${error}"/></span>
                    </div>
                </c:if>

                <c:if test="${param.created == 'true'}">
                    <div class="alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; border-left: 4px solid #10b981; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #065f46; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                        <i class="fa-solid fa-circle-check" style="font-size: 1.2rem; color: #10b981;"></i>
                        <span>Tạo biểu mẫu Web Form mới thành công! Bạn có thể lấy mã nhúng bên dưới để tích hợp vào website.</span>
                    </div>
                </c:if>

                <c:if test="${param.success == 'true'}">
                    <div class="alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; border-left: 4px solid #10b981; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #065f46; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                        <i class="fa-solid fa-circle-check" style="font-size: 1.2rem; color: #10b981;"></i>
                        <span>Cập nhật cấu hình biểu mẫu thành công!</span>
                    </div>
                </c:if>

                <!-- KPI Metric Highlights -->
                <div class="lead-kpi-row" style="margin-bottom: 20px;">
                    <div class="lead-kpi-box lead-kpi-blue">
                        <div class="lead-kpi-info">
                            <span class="lead-kpi-label">Tổng biểu mẫu</span>
                            <span class="lead-kpi-val">${not empty webForms ? fn:length(webForms) : 0}</span>
                        </div>
                        <div class="lead-kpi-icon">
                            <i class="fa-solid fa-window-restore"></i>
                        </div>
                    </div>

                    <div class="lead-kpi-box lead-kpi-emerald">
                        <div class="lead-kpi-info">
                            <span class="lead-kpi-label">Bảo vệ chống Spam</span>
                            <span class="lead-kpi-val" style="color: #059669; font-size: 1.15rem; font-weight: 700;">Rate Limit IP</span>
                        </div>
                        <div class="lead-kpi-icon">
                            <i class="fa-solid fa-shield-halved"></i>
                        </div>
                    </div>

                    <div class="lead-kpi-box lead-kpi-amber">
                        <div class="lead-kpi-info">
                            <span class="lead-kpi-label">Nguồn dữ liệu</span>
                            <span class="lead-kpi-val" style="color: #d97706; font-size: 1.15rem; font-weight: 700;">Website Embed</span>
                        </div>
                        <div class="lead-kpi-icon">
                            <i class="fa-solid fa-globe"></i>
                        </div>
                    </div>
                </div>

                <!-- COLLAPSIBLE CREATE NEW WEB FORM PANEL (Hidden by default, shown upon clicking "+ Tạo biểu mẫu") -->
                <div class="webform-create-panel <c:if test="${not empty error}">show</c:if>" id="createWebFormPanel">
                    <div class="webform-panel-header">
                        <h2 class="webform-panel-title">
                            <i class="fa-solid fa-circle-plus" style="color: #2563eb;"></i> Tạo biểu mẫu Web Form mới
                        </h2>
                        <button type="button" class="webform-panel-close" id="btnCloseCreatePanel" title="Đóng bảng tạo mới">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>

                    <div class="webform-panel-body">
                        <form action="${pageContext.request.contextPath}/leads/web-forms" method="post" id="createWebForm">
                            <div class="webform-form-grid">
                                <div class="webform-input-group">
                                    <label class="webform-label" for="formName">
                                        Tên biểu mẫu <span style="color: #ef4444;">*</span>
                                    </label>
                                    <input type="text" id="formName" name="formName" class="webform-input" 
                                           value="<c:out value='${param.formName}'/>" 
                                           placeholder="VD: Form liên hệ tư vấn, Đăng ký dùng thử..." required>
                                    <span class="webform-hint">Tên định danh hiển thị trong danh sách và báo cáo nguồn Lead.</span>
                                </div>

                                <div class="webform-input-group">
                                    <label class="webform-label" for="allowedDomains">
                                        Tên miền được phép nhúng
                                    </label>
                                    <input type="text" id="allowedDomains" name="allowedDomains" class="webform-input" 
                                           value="<c:out value='${param.allowedDomains}'/>" 
                                           placeholder="VD: company.com, landingpage.vn">
                                    <span class="webform-hint">Để trống nếu cho phép mọi tên miền. Phân cách bằng dấu phẩy.</span>
                                </div>
                            </div>

                            <div class="webform-form-grid">
                                <div class="webform-input-group">
                                    <label class="webform-label" for="leadSourceId">
                                        Nguồn Lead liên kết
                                    </label>
                                    <select id="leadSourceId" name="leadSourceId" class="webform-input" style="height: 42px; background-color: #fff; cursor: pointer;">
                                        <option value="">-- Mặc định (Biểu mẫu Website) --</option>
                                        <c:forEach var="src" items="${sources}">
                                            <option value="${src.sourceId}" <c:if test="${param.leadSourceId == src.sourceId}">selected</c:if>>
                                                <c:out value="${src.sourceName}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <span class="webform-hint">Nguồn Lead gán tự động khi khách gửi dữ liệu qua form này.</span>
                                </div>

                                <div class="webform-input-group">
                                    <label class="webform-label" for="successRedirectUrl">
                                        URL chuyển hướng sau khi gửi (Tùy chọn)
                                    </label>
                                    <input type="url" id="successRedirectUrl" name="successRedirectUrl" class="webform-input" 
                                           value="<c:out value='${param.successRedirectUrl}'/>" 
                                           placeholder="VD: https://company.com/cam-on.html">
                                    <span class="webform-hint">Trang khách hàng sẽ được điều hướng đến sau khi gửi form thành công.</span>
                                </div>
                            </div>

                            <div class="webform-form-grid">
                                <div class="webform-input-group">
                                    <label class="webform-label">
                                        Cấu hình an toàn & Trạng thái
                                    </label>
                                    <div style="display: flex; gap: 20px; align-items: center; height: 42px;">
                                        <label style="display: inline-flex; align-items: center; gap: 7px; font-size: 0.84rem; cursor: pointer; color: #334155; font-weight: 500;">
                                            <input type="checkbox" name="spamProtection" value="true" checked style="width: 16px; height: 16px; accent-color: #2563eb;">
                                            <span>Chống spam & Giới hạn IP</span>
                                        </label>
                                        <label style="display: inline-flex; align-items: center; gap: 7px; font-size: 0.84rem; cursor: pointer; color: #334155; font-weight: 500;">
                                            <input type="checkbox" name="active" value="true" checked style="width: 16px; height: 16px; accent-color: #2563eb;">
                                            <span>Kích hoạt ngay</span>
                                        </label>
                                    </div>
                                    <span class="webform-hint">Tự động chặn gửi lặp từ một địa chỉ IP và kích hoạt tiếp nhận Lead.</span>
                                </div>
                            </div>

                            <div class="webform-input-group" style="margin-bottom: 20px;">
                                <label class="webform-label" for="description">
                                    Mô tả biểu mẫu
                                </label>
                                <textarea id="description" name="description" class="webform-textarea" rows="2" 
                                          placeholder="Mục đích sử dụng hoặc vị trí đặt biểu mẫu..."><c:out value="${param.description}"/></textarea>
                            </div>

                            <div style="display: flex; gap: 10px; align-items: center; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                                <button type="submit" class="btn-lead-primary" style="padding: 9px 20px;">
                                    <i class="fa-solid fa-save"></i> Tạo biểu mẫu
                                </button>
                                <button type="reset" class="btn-filter-reset">
                                    Nhập lại
                                </button>
                                <button type="button" class="btn-filter-reset" id="btnCancelCreate">
                                    Hủy bỏ
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- MAIN SECTION: THE WEB FORMS LIST TABLE -->
                <div class="webform-list-card">
                    <div class="webform-list-header">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <h2 style="font-size: 1.05rem; font-weight: 700; color: #0f172a; margin: 0; display: flex; align-items: center; gap: 8px;">
                                <i class="fa-solid fa-list-check" style="color: #2563eb;"></i> Danh sách biểu mẫu Web Form đã lưu
                            </h2>
                            <span class="badge" style="background: #f1f5f9; color: #475569; font-weight: 700; font-size: 0.78rem; padding: 3px 8px; border-radius: 6px; border: 1px solid #e2e8f0;">
                                ${not empty webForms ? fn:length(webForms) : 0} biểu mẫu
                            </span>
                        </div>

                        <!-- Real-time Quick Search Filter -->
                        <div class="webform-search-box">
                            <i class="fa-solid fa-magnifying-glass webform-search-icon"></i>
                            <input type="text" id="webFormSearchInput" placeholder="Tìm theo tên form, tên miền...">
                        </div>
                    </div>

                    <div style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty webForms}">
                                <div class="table-responsive">
                                    <table class="leads-table" id="webFormsTable" style="margin: 0; width: 100%;">
                                        <thead>
                                            <tr>
                                                <th style="width: 70px; text-align: center;">ID</th>
                                                <th>Tên biểu mẫu & Mô tả</th>
                                                <th style="width: 160px;">Nguồn Lead</th>
                                                <th>Tên miền cho phép nhúng</th>
                                                <th style="width: 140px; text-align: center;">Trạng thái</th>
                                                <th style="width: 220px; text-align: center;">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="f" items="${webForms}">
                                                <tr class="webform-row-item">
                                                    <td style="text-align: center;">
                                                        <span style="font-weight: 700; color: #64748b; font-size: 0.82rem;">#${f.formId}</span>
                                                    </td>
                                                    <td>
                                                        <div style="font-weight: 700; color: #0f172a; font-size: 0.92rem; margin-bottom: 3px;">
                                                            <c:out value="${f.formName}"/>
                                                        </div>
                                                        <c:if test="${not empty f.description}">
                                                            <div style="color: #64748b; font-size: 0.78rem; line-height: 1.35;">
                                                                <c:out value="${f.description}"/>
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty f.sourceName}">
                                                                <span class="badge" style="background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; border-radius: 6px; font-size: 0.76rem; font-weight: 600; padding: 4px 8px; display: inline-flex; align-items: center; gap: 5px;">
                                                                    <i class="fa-solid fa-bullhorn" style="font-size: 0.72rem;"></i>
                                                                    <c:out value="${f.sourceName}"/>
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color: #94a3b8; font-size: 0.78rem; font-style: italic;">
                                                                    Mặc định
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty f.allowedDomains}">
                                                                <span class="domain-pill" title="<c:out value='${f.allowedDomains}'/>">
                                                                    <i class="fa-solid fa-shield-halved" style="color: #2563eb;"></i>
                                                                    <c:out value="${f.allowedDomains}"/>
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="domain-pill" style="background: #f8fafc; color: #64748b; font-style: italic;">
                                                                    <i class="fa-solid fa-globe" style="color: #94a3b8;"></i> Tất cả tên miền (*)
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <c:choose>
                                                            <c:when test="${f.active}">
                                                                <span class="badge" style="background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; border-radius: 9999px; padding: 4px 10px; font-weight: 600; font-size: 0.76rem; display: inline-flex; align-items: center; gap: 5px;">
                                                                    <span style="width: 6px; height: 6px; border-radius: 50%; background: #10b981;"></span>
                                                                    Hoạt động
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge" style="background: #f1f5f9; color: #64748b; border: 1px solid #cbd5e1; border-radius: 9999px; padding: 4px 10px; font-weight: 600; font-size: 0.76rem; display: inline-flex; align-items: center; gap: 5px;">
                                                                    <span style="width: 6px; height: 6px; border-radius: 50%; background: #94a3b8;"></span>
                                                                    Tạm dừng
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                                            <a href="${pageContext.request.contextPath}/leads/web-forms/embed-code?formId=${f.formId}" 
                                                               class="btn-code-action" title="Lấy mã nhúng HTML & Script">
                                                                <i class="fa-solid fa-code"></i> Mã nhúng
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/leads/public-form?formId=${f.formId}" 
                                                               target="_blank" class="btn-lead-action" style="padding: 6px 10px; font-size: 0.78rem;" title="Xem biểu mẫu trực tiếp">
                                                                <i class="fa-solid fa-arrow-up-right-from-square"></i> Xem
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align: center; padding: 60px 20px;">
                                    <div style="width: 64px; height: 64px; border-radius: 20px; background: #eff6ff; color: #2563eb; display: inline-flex; align-items: center; justify-content: center; font-size: 1.8rem; margin-bottom: 16px;">
                                        <i class="fa-solid fa-window-restore"></i>
                                    </div>
                                    <h3 style="font-size: 1.1rem; font-weight: 700; color: #0f172a; margin-bottom: 6px;">
                                        Chưa có biểu mẫu Web Form nào
                                    </h3>
                                    <p style="font-size: 0.85rem; color: #64748b; max-width: 450px; margin: 0 auto 20px auto;">
                                        Tạo biểu mẫu đầu tiên để sinh mã nhúng dán vào website, landing page giúp tự động thu thập khách hàng tiềm năng vào CRM.
                                    </p>
                                    <button type="button" class="btn-lead-primary" onclick="toggleCreatePanel(true)" style="padding: 9px 20px;">
                                        <i class="fa-solid fa-plus-circle"></i> Tạo biểu mẫu đầu tiên ngay
                                    </button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Toggle & Real-time Search Script -->
    <script>
        function toggleCreatePanel(show) {
            var panel = document.getElementById('createWebFormPanel');
            var btn = document.getElementById('btnOpenCreatePanel');
            if (!panel) return;

            if (show === true) {
                panel.classList.add('show');
                panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
                var input = document.getElementById('formName');
                if (input) setTimeout(function() { input.focus(); }, 250);
            } else if (show === false) {
                panel.classList.remove('show');
            } else {
                panel.classList.toggle('show');
                if (panel.classList.contains('show')) {
                    panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    var input = document.getElementById('formName');
                    if (input) setTimeout(function() { input.focus(); }, 250);
                }
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            var btnOpen = document.getElementById('btnOpenCreatePanel');
            var btnClose = document.getElementById('btnCloseCreatePanel');
            var btnCancel = document.getElementById('btnCancelCreate');

            if (btnOpen) {
                btnOpen.addEventListener('click', function() {
                    toggleCreatePanel();
                });
            }

            if (btnClose) {
                btnClose.addEventListener('click', function() {
                    toggleCreatePanel(false);
                });
            }

            if (btnCancel) {
                btnCancel.addEventListener('click', function() {
                    toggleCreatePanel(false);
                });
            }

            // Real-time table search filter
            var searchInput = document.getElementById('webFormSearchInput');
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    var filter = this.value.toLowerCase().trim();
                    var rows = document.querySelectorAll('.webform-row-item');
                    rows.forEach(function(row) {
                        var text = row.innerText.toLowerCase();
                        if (text.indexOf(filter) > -1) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    });
                });
            }
        });
    </script>
</body>
</html>
