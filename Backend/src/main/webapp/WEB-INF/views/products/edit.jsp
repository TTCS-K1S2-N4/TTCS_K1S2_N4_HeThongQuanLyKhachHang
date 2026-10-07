<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa Sản phẩm | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div class="page-header" style="margin-bottom: 1rem;">
                <h1 class="page-title">Chỉnh sửa Sản phẩm: <c:out value="${product.productName}"/></h1>
            </div>

            <div class="card" style="max-width: 650px;">
                <div class="card-body">
                    <form method="post" action="${pageContext.request.contextPath}/products/edit">
                        <input type="hidden" name="productId" value="${product.productId}">
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Mã sản phẩm (*)</label>
                            <input type="text" name="productCode" value="<c:out value='${product.productCode}'/>" class="form-control" required style="width: 100%;">
                        </div>
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Tên sản phẩm (*)</label>
                            <input type="text" name="productName" value="<c:out value='${product.productName}'/>" class="form-control" required style="width: 100%;">
                        </div>
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Loại sản phẩm (*)</label>
                            <select name="productType" class="form-control" required style="width: 100%;">
                                <option value="ONE_TIME" ${product.productType == 'ONE_TIME' ? 'selected' : ''}>Sản phẩm (One-time)</option>
                                <option value="SUBSCRIPTION" ${product.productType == 'SUBSCRIPTION' ? 'selected' : ''}>Dịch vụ (Subscription)</option>
                            </select>
                        </div>
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Đơn vị tính (*)</label>
                            <input type="text" name="unit" value="<c:out value='${product.unit}'/>" class="form-control" required style="width: 100%;">
                        </div>
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Giá niêm yết (*)</label>
                            <input type="number" step="0.01" name="listPrice" value="${product.listPrice}" class="form-control" required style="width: 100%;">
                        </div>
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Giá sàn</label>
                            <input type="number" step="0.01" name="floorPrice" value="${product.floorPrice}" class="form-control" style="width: 100%;">
                        </div>
                        <c:if test="${canAccessCostPrice}">
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label>Giá vốn</label>
                                <input type="number" step="0.01" name="costPrice" value="${product.costPrice}" class="form-control" style="width: 100%;">
                            </div>
                        </c:if>
                        <div class="form-group" style="margin-bottom: 1rem;">
                            <label>Trạng thái</label>
                            <select name="status" class="form-control" style="width: 100%;">
                                <option value="ACTIVE" ${product.status == 'ACTIVE' ? 'selected' : ''}>Hoạt động</option>
                                <option value="INACTIVE" ${product.status == 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                            </select>
                        </div>
                        <div style="display: flex; gap: 0.5rem;">
                            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
