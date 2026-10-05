<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Gộp khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css">
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
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers/duplicates">Kiểm tra trùng lặp</a>
                <span>/</span>
                <span class="breadcrumb-current">Thực hiện Gộp</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Gộp Khách hàng (Merge)</h1>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <p class="text-danger">
                        <strong>Cảnh báo:</strong> Quá trình này sẽ bảo toàn các dữ liệu (mối quan hệ cha-con, custom fields) của khách hàng phụ (Secondary) 
                        và chuyển sang khách hàng chính (Primary). Sau đó, Khách hàng phụ sẽ bị <strong>xoá vĩnh viễn</strong>.
                    </p>
                    <form method="post" action="${pageContext.request.contextPath}/customers/merge">
                        <div class="form-row">
                            <div class="form-group col-md-5">
                                <label>ID Khách hàng CHÍNH (Được giữ lại)</label>
                                <input type="number" name="primaryId" class="form-control" value="${primaryId}" required min="0">
                            </div>
                            <div class="col-md-2 text-center" style="align-self: flex-end; padding-bottom: 15px;">
                                <span class="badge badge-primary">&larr; Gộp vào</span>
                            </div>
                            <div class="form-group col-md-5">
                                <label>ID Khách hàng PHỤ (Bị xoá)</label>
                                <input type="number" name="secondaryId" class="form-control" value="${secondaryId}" required min="0">
                            </div>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Bạn có chắc chắn muốn thực hiện gộp? Hành động này không thể hoàn tác!')">Xác nhận Gộp</button>
                            <a href="${pageContext.request.contextPath}/customers/duplicates" class="btn btn-secondary">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
