<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi Mật Khẩu | CRM System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/auth.css">
</head>
<body class="auth-page">
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1 class="auth-title">Đổi mật khẩu</h1>
                <p class="auth-description">Vui lòng nhập mật khẩu hiện tại và mật khẩu mới của bạn.</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="auth-message auth-message-error" role="alert">
                    ${errorMessage}
                </div>
            </c:if>

            <c:if test="${not empty successMessage}">
                <div class="auth-message auth-message-success" role="status">
                    ${successMessage}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/change-password" method="post">
                <div class="form-group" style="margin-bottom: 1rem;">
                    <label class="form-label" for="oldPassword">Mật khẩu hiện tại</label>
                    <input id="oldPassword" name="oldPassword" class="form-control" type="password" required autocomplete="current-password">
                </div>

                <div class="form-group" style="margin-bottom: 1rem;">
                    <label class="form-label" for="newPassword">Mật khẩu mới</label>
                    <input id="newPassword" name="newPassword" class="form-control" type="password" required autocomplete="new-password">
                    <small style="color: #6b7280; font-size: 0.8rem; display: block; margin-top: 0.25rem;">
                        Tối thiểu 8 ký tự, bao gồm cả chữ cái và chữ số.
                    </small>
                </div>

                <div class="form-group" style="margin-bottom: 1.5rem;">
                    <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <input id="confirmPassword" name="confirmPassword" class="form-control" type="password" required autocomplete="new-password">
                </div>

                <button class="btn btn-primary" type="submit" style="width: 100%;">
                    Lưu mật khẩu mới
                </button>
            </form>

            <div class="auth-footer" style="margin-top: 1.5rem;">
                <a href="${pageContext.request.contextPath}/" class="auth-link">Quay lại trang chủ</a>
            </div>
        </div>
    </div>
</body>
</html>
