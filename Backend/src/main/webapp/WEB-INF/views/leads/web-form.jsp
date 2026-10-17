<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Web Forms | CRM</title>
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
                    <span class="breadcrumb-current">Web Forms</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h1 class="page-title">Cấu hình Web Form (Thu thập Lead)</h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                            Tạo và quản lý các biểu mẫu thu thập thông tin khách hàng tiềm năng tự động từ website.
                        </p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px;">
                        <i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/>
                    </div>
                </c:if>

                <c:if test="${param.created == 'true'}">
                    <div class="alert alert-success" style="margin-bottom: 16px;">
                        <i class="fas fa-check-circle"></i> Tạo biểu mẫu Web Form mới thành công!
                    </div>
                </c:if>

                <c:if test="${param.success == 'true'}">
                    <div class="alert alert-success" style="margin-bottom: 16px;">
                        <i class="fas fa-check-circle"></i> Cập nhật cấu hình biểu mẫu thành công!
                    </div>
                </c:if>

                <div class="card form-card">
                    <div class="card-header" style="padding: 16px 20px; border-bottom: 1px solid var(--color-border); background: #f8fafc;">
                        <h2 style="font-size: 16px; margin: 0; font-weight: 600;">
                            <i class="fas fa-plus-circle" style="color: var(--color-primary);"></i> Tạo biểu mẫu Web Form mới
                        </h2>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/leads/web-forms" method="post" class="lead-form">
                            <div class="form-group">
                                <label for="formName">Tên biểu mẫu <span class="required">*</span></label>
                                <input type="text" id="formName" name="formName" class="form-control" value="<c:out value='${param.formName}'/>" placeholder="VD: Form liên hệ tư vấn, Đăng ký dùng thử..." required>
                            </div>

                            <div class="form-group">
                                <label for="description">Mô tả biểu mẫu</label>
                                <textarea id="description" name="description" class="form-control" rows="2" placeholder="Mục đích sử dụng hoặc vị trí đặt biểu mẫu..."><c:out value="${param.description}"/></textarea>
                            </div>

                            <div class="form-group">
                                <label for="allowedDomains">Tên miền được phép nhúng</label>
                                <input type="text" id="allowedDomains" name="allowedDomains" class="form-control" value="<c:out value='${param.allowedDomains}'/>" placeholder="VD: company.com, landingpage.vn (để trống nếu cho phép tất cả)">
                                <small style="color: var(--color-text-secondary); display: block; margin-top: 4px;">Ngăn chặn các website giả mạo gửi dữ liệu rác vào hệ thống CRM.</small>
                            </div>

                            <div class="form-group">
                                <label for="successRedirectUrl">URL chuyển hướng sau khi gửi (Tùy chọn)</label>
                                <input type="url" id="successRedirectUrl" name="successRedirectUrl" class="form-control" value="<c:out value='${param.successRedirectUrl}'/>" placeholder="VD: https://company.com/cam-on.html">
                            </div>

                            <div class="form-actions" style="display: flex; gap: 8px; margin-top: 20px;">
                                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Tạo biểu mẫu</button>
                                <button type="reset" class="btn btn-secondary">Nhập lại</button>
                                <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">Hủy</a>
                            </div>
                        </form>
                    </div>
                </div>

                <h2 class="section-title" style="margin-top: 32px; margin-bottom: 16px; font-size: 18px; font-weight: 600;">
                    <i class="fas fa-list"></i> Danh sách biểu mẫu Web Form đã lưu
                </h2>
                <div class="card">
                    <div class="card-body" style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty webForms}">
                                <div class="table-responsive">
                                    <table class="table leads-table" style="margin: 0;">
                                        <thead>
                                            <tr>
                                                <th style="width: 50px;">ID</th>
                                                <th>Tên biểu mẫu</th>
                                                <th>Mô tả</th>
                                                <th>Tên miền cho phép</th>
                                                <th>Trạng thái</th>
                                                <th style="text-align: center; width: 220px;">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="f" items="${webForms}">
                                                <tr>
                                                    <td>${f.formId}</td>
                                                    <td>
                                                        <strong><c:out value="${f.formName}"/></strong>
                                                    </td>
                                                    <td><c:out value="${not empty f.description ? f.description : '-'}"/></td>
                                                    <td><c:out value="${not empty f.allowedDomains ? f.allowedDomains : 'Tất cả (*)'}"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${f.active}">
                                                                <span class="badge" style="background: #dcfce7; color: #16a34a;"><i class="fas fa-check-circle"></i> Hoạt động</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge" style="background: #f1f5f9; color: #64748b;"><i class="fas fa-pause-circle"></i> Tạm dừng</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <div style="display: flex; gap: 6px; justify-content: center; flex-wrap: wrap;">
                                                            <a href="${pageContext.request.contextPath}/leads/web-forms/embed-code?formId=${f.formId}" class="btn btn-sm btn-primary" title="Lấy mã nhúng">
                                                                <i class="fas fa-code"></i> Mã nhúng
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/leads/public-form?formId=${f.formId}" target="_blank" class="btn btn-sm btn-outline" title="Xem biểu mẫu công khai">
                                                                <i class="fas fa-external-link-alt"></i> Xem
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
                                <div style="text-align: center; padding: 36px 16px; color: var(--color-text-secondary);">
                                    <i class="fas fa-inbox" style="font-size: 36px; margin-bottom: 8px; color: #cbd5e1; display: block;"></i>
                                    Chưa có biểu mẫu Web Form nào được tạo trong hệ thống.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
