<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết Sản phẩm | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h1 class="page-title">Chi tiết Sản phẩm: <c:out value="${product.productName}"/></h1>
                <div>
                    <c:if test="${canManageProducts}">
                        <a href="${pageContext.request.contextPath}/products/edit?productId=${product.productId}" class="btn btn-primary">Chỉnh sửa</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">Quay lại</a>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <table class="table" style="max-width: 600px;">
                        <tr><th>Mã sản phẩm</th><td><c:out value="${product.productCode}"/></td></tr>
                        <tr><th>Tên sản phẩm</th><td><strong><c:out value="${product.productName}"/></strong></td></tr>
                        <tr><th>Loại sản phẩm</th><td><c:out value="${product.productType}"/></td></tr>
                        <tr><th>Đơn vị tính</th><td><c:out value="${product.unit}"/></td></tr>
                        <tr><th>Giá niêm yết</th><td><fmt:formatNumber value="${product.listPrice}" type="currency" currencySymbol="VNĐ"/></td></tr>
                        <tr><th>Giá sàn</th><td><fmt:formatNumber value="${product.floorPrice}" type="currency" currencySymbol="VNĐ"/></td></tr>
                        <c:if test="${canAccessCostPrice}">
                            <tr>
                                <th>Giá vốn</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${product.costPrice != null}">
                                            <fmt:formatNumber value="${product.costPrice}" type="currency" currencySymbol="VNĐ"/>
                                        </c:when>
                                        <c:otherwise>---</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:if>
                        <tr><th>Trạng thái</th><td><c:out value="${product.status}"/></td></tr>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
