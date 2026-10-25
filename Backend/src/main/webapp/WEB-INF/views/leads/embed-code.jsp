<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Mã nhúng Biểu mẫu | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
        <main class="main-content">
            <div class="content-container">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Lead</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads/web-forms">Web Forms</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Mã nhúng</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h1 class="page-title">Mã Nhúng Biểu Mẫu</h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                            <c:if test="${not empty webForm}">
                                Biểu mẫu: <strong><c:out value="${webForm.formName}"/></strong> (ID: #${webForm.formId})
                            </c:if>
                        </p>
                    </div>
                    <div style="display: flex; gap: 8px;">
                        <c:if test="${not empty webForm}">
                            <a href="${pageContext.request.contextPath}/leads/public-form?formId=${webForm.formId}" target="_blank" class="btn btn-outline" title="Xem biểu mẫu công khai">
                                <i class="fas fa-external-link-alt"></i> Xem form công khai
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/leads/web-forms" class="btn btn-outline">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px;">
                        <i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/>
                    </div>
                </c:if>

                <div class="card form-card">
                    <div class="card-header" style="padding: 16px 20px; border-bottom: 1px solid var(--color-border); background: #f8fafc;">
                        <h2 style="font-size: 16px; margin: 0; font-weight: 600;">
                            <i class="fas fa-code" style="color: var(--color-primary);"></i> Đoạn mã tích hợp vào Website
                        </h2>
                    </div>
                    <div class="card-body">
                        <p class="form-description" style="color: var(--color-text-secondary); margin-bottom: 16px;">
                            Sao chép đoạn mã dưới đây và dán vào bất kỳ vị trí nào trên website của bạn (HTML/CMS) để hiển thị form thu thập Lead.
                        </p>
                        
                        <div class="embed-code-container">
                            <textarea id="embedSnippet" class="form-control" rows="8" readonly style="font-family: monospace; font-size: 13px; background: #f8fafc; resize: vertical;"><c:out value="${embedCode}" /></textarea>
                        </div>

                        <div class="form-actions" style="margin-top: 16px; display: flex; align-items: center; gap: 12px;">
                            <button type="button" id="btnCopyEmbed" class="btn btn-primary">
                                <i class="fas fa-copy"></i> Sao chép mã nhúng
                            </button>
                            <span id="copyFeedback" class="text-success" style="display: none; color: #16a34a; font-weight: 500;">
                                <i class="fas fa-check-circle"></i> Đã sao chép vào bộ nhớ tạm!
                            </span>
                        </div>
                    </div>
                </div>

                <div class="card" style="margin-top: 24px; background: #eff6ff; border-color: #bfdbfe;">
                    <div class="card-body" style="color: #1e40af; font-size: 14px;">
                        <h3 style="font-size: 15px; font-weight: 600; margin-bottom: 8px;">
                            <i class="fas fa-info-circle"></i> Hướng dẫn tích hợp
                        </h3>
                        <ul style="margin-left: 20px; line-height: 1.6;">
                            <li>Dán mã nhúng vào vị trí mong muốn trong mã nguồn trang web (thẻ <code>&lt;body&gt;</code>).</li>
                            <li>Đảm bảo tên miền của website nằm trong danh sách <strong>Tên miền được phép nhúng</strong> của biểu mẫu để dữ liệu được bảo vệ.</li>
                            <li>Dữ liệu khách hàng điền vào biểu mẫu sẽ tự động được gửi và lưu trữ trong hệ thống Lead của CRM.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-web-form.js"></script>
</body>
</html>
