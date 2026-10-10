<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên hệ với chúng tôi</title>
    <!-- Public styles can be minimal or import the project CSS if allowed -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
</head>
<body class="public-form-body">
    <div class="public-form-container">
        <h2 class="public-form-title">Đăng ký tư vấn</h2>
        
        <c:if test="${not empty param.success}">
            <div class="alert alert-success">Cảm ơn bạn đã quan tâm. Chúng tôi sẽ liên hệ trong thời gian sớm nhất!</div>
        </c:if>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/public/leads" method="post" id="publicLeadForm" class="lead-form">
            <input type="hidden" name="formId" value="${param.formId}">
            <!-- sourceKey logic backend might use -->
            <input type="hidden" name="sourceKey" value="${param.sourceKey}">

            <div class="form-group">
                <label for="fullName">Họ tên <span class="required">*</span></label>
                <input type="text" id="fullName" name="fullName" class="form-control" value="${param.fullName}" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email <span class="required">*</span></label>
                <input type="email" id="email" name="email" class="form-control" value="${param.email}" required>
            </div>

            <div class="form-group">
                <label for="phone">Số điện thoại <span class="required">*</span></label>
                <input type="text" id="phone" name="phone" class="form-control" value="${param.phone}" required>
            </div>

            <div class="form-group">
                <label for="company">Công ty</label>
                <input type="text" id="company" name="company" class="form-control" value="${param.company}">
            </div>

            <div class="form-group">
                <label for="interest">Nhu cầu quan tâm</label>
                <textarea id="interest" name="interest" class="form-control" rows="4">${param.interest}</textarea>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary btn-block">Gửi yêu cầu</button>
            </div>
        </form>
    </div>
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-web-form.js"></script>
</body>
</html>
