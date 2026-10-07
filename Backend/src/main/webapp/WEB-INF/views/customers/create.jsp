<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thêm khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
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
                <span class="breadcrumb-current">Thêm mới</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Thêm khách hàng</h1>
                </div>
                <div class="page-actions">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers">Hủy</a>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/customers/create" method="post">
                        <!-- Thông báo lỗi chung -->
                        <c:if test="${not empty message}">
                            <div class="alert alert-danger" style="color: red; margin-bottom: 15px;">
                                <c:out value="${message}"/>
                            </div>
                        </c:if>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="customerName">Tên công ty <span style="color:red;">*</span></label>
                            <input type="text" id="customerName" name="customerName" class="form-control" 
                                   value="<c:out value='${param.customerName}'/>" required maxlength="200">
                            <c:if test="${not empty errors['customerName']}">
                                <div class="text-danger" style="color: red; font-size: 12px; margin-top: 4px;">
                                    <c:out value="${errors['customerName']}"/>
                                </div>
                            </c:if>
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="taxCode">Mã số thuế</label>
                            <input type="text" id="taxCode" name="taxCode" class="form-control" 
                                   value="<c:out value='${param.taxCode}'/>" maxlength="50">
                            <c:if test="${not empty errors['taxCode']}">
                                <div class="text-danger" style="color: red; font-size: 12px; margin-top: 4px;">
                                    <c:out value="${errors['taxCode']}"/>
                                </div>
                            </c:if>
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="industry">Ngành nghề</label>
                            <input type="text" id="industry" name="industry" class="form-control" 
                                   value="<c:out value='${param.industry}'/>">
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="size">Quy mô</label>
                            <input type="text" id="size" name="size" class="form-control" 
                                   value="<c:out value='${param.size}'/>">
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="website">Website</label>
                            <input type="url" id="website" name="website" class="form-control" 
                                   value="<c:out value='${param.website}'/>" placeholder="https://...">
                            <c:if test="${not empty errors['website']}">
                                <div class="text-danger" style="color: red; font-size: 12px; margin-top: 4px;">
                                    <c:out value="${errors['website']}"/>
                                </div>
                            </c:if>
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="address">Địa chỉ</label>
                            <input type="text" id="address" name="address" class="form-control" 
                                   value="<c:out value='${param.address}'/>">
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="ownerId">Người sở hữu <span style="color:red;">*</span></label>
                            <!-- TODO: Phụ thuộc vào Backend truyền danh sách ownerList -->
                            <input type="number" id="ownerId" name="ownerId" class="form-control" 
                                   value="<c:out value='${param.ownerId}'/>" required>
                            <small style="color: #666;">(Tạm thời nhập ID người sở hữu, do chưa chốt với Backend về attribute list user)</small>
                            <c:if test="${not empty errors['ownerId']}">
                                <div class="text-danger" style="color: red; font-size: 12px; margin-top: 4px;">
                                    <c:out value="${errors['ownerId']}"/>
                                </div>
                            </c:if>
                        </div>

                        <div class="form-group" style="margin-bottom: 15px;">
                            <label for="status">Trạng thái <span style="color:red;">*</span></label>
                            <select id="status" name="status" class="form-control" required>
                                <option value="">-- Chọn trạng thái --</option>
                                <option value="POTENTIAL" ${param.status == 'POTENTIAL' ? 'selected' : ''}>Tiềm năng</option>
                                <option value="DEALING" ${param.status == 'DEALING' ? 'selected' : ''}>Đang giao dịch</option>
                                <option value="CUSTOMER" ${param.status == 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
                                <option value="STOPPED" ${param.status == 'STOPPED' ? 'selected' : ''}>Ngừng hợp tác</option>
                            </select>
                            <c:if test="${not empty errors['status']}">
                                <div class="text-danger" style="color: red; font-size: 12px; margin-top: 4px;">
                                    <c:out value="${errors['status']}"/>
                                </div>
                            </c:if>
                        </div>

                        <div style="margin-top: 20px;">
                            <button type="submit" class="btn btn-primary">Lưu khách hàng</button>
                            <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
