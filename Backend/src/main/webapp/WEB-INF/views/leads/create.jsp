<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tạo Lead Mới | CRM</title>
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
                    <span class="breadcrumb-current">Tạo mới</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h1 class="page-title">Tạo Lead Mới</h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                            Nhập thông tin chi tiết để thêm đầu mối kinh doanh mới vào hệ thống.
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

                <div class="card form-card">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/leads/create" method="post" class="lead-form">
                            <div class="form-group">
                                <label for="fullName">Họ tên <span class="required">*</span></label>
                                <input type="text" id="fullName" name="fullName" class="form-control" value="<c:out value='${param.fullName}'/>" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" class="form-control" value="<c:out value='${param.email}'/>">
                            </div>

                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="text" id="phone" name="phone" class="form-control" value="<c:out value='${param.phone}'/>">
                            </div>

                            <div class="form-group">
                                <label for="company">Công ty</label>
                                <input type="text" id="company" name="company" class="form-control" value="<c:out value='${param.company}'/>">
                            </div>

                            <div class="form-group">
                                <label for="notes">Nhu cầu quan tâm</label>
                                <textarea id="notes" name="notes" class="form-control" rows="3"><c:out value="${param.notes}"/></textarea>
                            </div>

                            <div class="form-group">
                                <label for="leadSourceId">Nguồn Lead <span class="required">*</span></label>
                                <select id="leadSourceId" name="leadSourceId" class="form-control" required>
                                    <option value="">-- Chọn nguồn --</option>
                                    <c:forEach var="src" items="${sources}">
                                        <option value="${src.sourceId}" ${param.leadSourceId == src.sourceId ? 'selected' : ''}><c:out value="${src.sourceName}"/></option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-actions" style="display: flex; gap: 8px; margin-top: 20px;">
                                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Lưu Lead</button>
                                <button type="reset" class="btn btn-secondary">Nhập lại</button>
                                <a href="${pageContext.request.contextPath}/leads" class="btn btn-outline">Hủy</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
