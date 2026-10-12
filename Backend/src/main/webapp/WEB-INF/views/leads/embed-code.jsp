<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lấy mã nhúng Form | CRM System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
</head>
<body>
    <div class="app">
        <header class="app-header">
            <div class="header-left">
                <a class="header-brand" href="${pageContext.request.contextPath}/">CRM System</a>
                <div class="header-divider"></div>
                <nav class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a> / <a href="${pageContext.request.contextPath}/lead-forms">Web Forms</a> / <span class="breadcrumb-current">Mã nhúng</span>
                </nav>
            </div>
        </header>
        <aside class="sidebar">
            <nav aria-label="Điều hướng chính">
                <div class="sidebar-section">
                    <a class="nav-item active" href="${pageContext.request.contextPath}/leads">Lead</a>
                </div>
            </nav>
        </aside>
        <main class="main-content">
            <div class="content-container">
                <div class="page-header">
                    <h1 class="page-title">Mã Nhúng Biểu Mẫu</h1>
                    <a href="${pageContext.request.contextPath}/lead-forms" class="btn btn-outline">Quay lại</a>
                </div>

                <div class="card form-card">
                    <div class="card-body">
                        <p class="form-description">Sao chép đoạn mã dưới đây và dán vào bất kỳ vị trí nào trên website của bạn (HTML/CMS) để hiển thị form thu thập Lead.</p>
                        
                        <div class="embed-code-container">
                            <textarea id="embedSnippet" class="form-control" rows="8" readonly><c:out value="${embedSnippet}" /></textarea>
                        </div>

                        <div class="form-actions" style="margin-top: 15px;">
                            <button type="button" id="btnCopyEmbed" class="btn btn-primary">Sao chép mã nhúng</button>
                            <span id="copyFeedback" class="text-success" style="display: none; margin-left: 10px;">Đã sao chép!</span>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <script src="${pageContext.request.contextPath}/assets/js/modules/lead-web-form.js"></script>
</body>
</html>
