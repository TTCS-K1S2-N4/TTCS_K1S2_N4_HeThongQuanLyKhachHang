<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty webForm.formName ? webForm.formName : 'Liên hệ với chúng tôi'}"/> | CRM</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
</head>
<body class="public-form-body">
    <c:choose>
        <c:when test="${empty webForm}">
            <div class="public-form-container" style="text-align: center;">
                <h2 class="public-form-title" style="color: #ef4444; font-size: 20px;">Không tìm thấy biểu mẫu</h2>
                <div class="alert alert-danger" style="margin-top: 16px;">
                    Biểu mẫu không tồn tại hoặc đã ngừng hoạt động.
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="public-form-container">
                <h2 class="public-form-title"><c:out value="${not empty webForm.formName ? webForm.formName : 'Đăng ký tư vấn'}"/></h2>
                
                <c:if test="${not empty webForm.description}">
                    <p class="public-form-desc" style="color: var(--color-text-secondary, #64748b); text-align: center; margin-top: -12px; margin-bottom: 20px; font-size: 14px; line-height: 1.5;">
                        <c:out value="${webForm.description}"/>
                    </p>
                </c:if>

                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success" style="margin-bottom: 16px;">
                        <c:out value="${successMessage}"/>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/leads/public-form" method="post" id="publicLeadForm" class="lead-form">
                    <input type="hidden" name="formId" value="${webForm.formId}">
                    <!-- Honeypot chống spam: bot tự động điền, người dùng không thấy -->
                    <input type="text" name="website_hp" id="website_hp" style="display:none;" tabindex="-1" autocomplete="off" aria-hidden="true">

                    <div class="form-group">
                        <label for="fullName">Họ tên <span class="required">*</span></label>
                        <input type="text" id="fullName" name="fullName" class="form-control" value="<c:out value='${param.fullName}'/>" placeholder="Nhập họ và tên..." required>
                    </div>

                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" id="email" name="email" class="form-control" value="<c:out value='${param.email}'/>" placeholder="name@example.com" required>
                    </div>

                    <div class="form-group">
                        <label for="phone">Số điện thoại <span class="required">*</span></label>
                        <input type="tel" id="phone" name="phone" class="form-control" value="<c:out value='${param.phone}'/>" placeholder="VD: 0912345678" required>
                    </div>

                    <div class="form-group">
                        <label for="company">Công ty</label>
                        <input type="text" id="company" name="company" class="form-control" value="<c:out value='${param.company}'/>" placeholder="Tên công ty hoặc tổ chức...">
                    </div>

                    <div class="form-group">
                        <label for="notes">Nhu cầu quan tâm</label>
                        <textarea id="notes" name="notes" class="form-control" rows="4" placeholder="Nội dung cần tư vấn hoặc ghi chú thêm..."><c:out value="${param.notes}"/></textarea>
                    </div>

                    <div class="form-actions" style="margin-top: 20px;">
                        <button type="submit" class="btn btn-primary btn-block">Gửi yêu cầu</button>
                    </div>
                </form>
            </div>
        </c:otherwise>
    </c:choose>
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-web-form.js"></script>
</body>
</html>
