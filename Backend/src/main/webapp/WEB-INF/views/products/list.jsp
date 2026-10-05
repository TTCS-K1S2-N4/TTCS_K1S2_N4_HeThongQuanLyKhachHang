<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách Sản phẩm | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h1 class="page-title">Danh mục Sản phẩm & Dịch vụ</h1>
                <a href="${pageContext.request.contextPath}/products/create" class="btn btn-primary">+ Tạo mới</a>
            </div>

            <div class="card" style="margin-bottom: 1rem;">
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/products" style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                        <input type="text" name="keyword" value="<c:out value='${keyword}'/>" class="form-control" placeholder="Tìm kiếm theo mã, tên..." style="flex: 1; min-width: 200px;">
                        <select name="productType" class="form-control" style="width: auto;">
                            <option value="">-- Tất cả loại --</option>
                            <option value="ONE_TIME" ${productType == 'ONE_TIME' ? 'selected' : ''}>Sản phẩm (One-time)</option>
                            <option value="SUBSCRIPTION" ${productType == 'SUBSCRIPTION' ? 'selected' : ''}>Dịch vụ (Subscription)</option>
                        </select>
                        <select name="status" class="form-control" style="width: auto;">
                            <option value="">-- Tất cả trạng thái --</option>
                            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Hoạt động</option>
                            <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                        </select>
                        <button type="submit" class="btn btn-secondary">Lọc</button>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-body table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã SP</th>
                                <th>Tên sản phẩm</th>
                                <th>Loại</th>
                                <th>ĐVT</th>
                                <th>Giá niêm yết</th>
                                <c:if test="${canAccessCostPrice}">
                                    <th>Giá vốn</th>
                                </c:if>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td><c:out value="${p.productCode}"/></td>
                                    <td><strong><c:out value="${p.productName}"/></strong></td>
                                    <td><c:out value="${p.productType}"/></td>
                                    <td><c:out value="${p.unit}"/></td>
                                    <td><fmt:formatNumber value="${p.listPrice}" type="currency" currencySymbol="VNĐ"/></td>
                                    <c:if test="${canAccessCostPrice}">
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.costPrice != null}">
                                                    <fmt:formatNumber value="${p.costPrice}" type="currency" currencySymbol="VNĐ"/>
                                                </c:when>
                                                <c:otherwise>---</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </c:if>
                                    <td>
                                        <span class="badge ${p.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}">
                                            <c:out value="${p.status}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/products/detail?productId=${p.productId}" class="btn btn-sm btn-secondary">Chi tiết</a>
                                        <a href="${pageContext.request.contextPath}/products/edit?productId=${p.productId}" class="btn btn-sm btn-primary">Sửa</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty products}">
                                <tr>
                                    <td colspan="8" style="text-align: center; color: var(--text-secondary);">Chưa có sản phẩm nào.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                    <c:if test="${totalPages > 1}">
                        <div class="pagination" style="margin-top: 1rem; display: flex; gap: 0.25rem;">
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <a href="?page=${i}&keyword=<c:out value='${keyword}'/>&productType=<c:out value='${productType}'/>&status=<c:out value='${status}'/>" class="btn btn-sm ${i == currentPage ? 'btn-primary' : 'btn-secondary'}">${i}</a>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
