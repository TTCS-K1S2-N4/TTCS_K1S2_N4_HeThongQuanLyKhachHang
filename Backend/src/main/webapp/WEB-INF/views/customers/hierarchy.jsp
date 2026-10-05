<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu trúc khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <h1 class="page-title">Cấu trúc công ty mẹ/con</h1>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success"><c:out value="${successMessage}"/></div>
            </c:if>
            
            <c:choose>
                <c:when test="${not empty customer}">
                    <div style="background: #f9f9f9; padding: 20px; border-radius: 4px; margin-bottom: 20px;">
                        <h3>Khách hàng hiện tại: <c:out value="${customer.customerName}"/> (ID: ${customer.customerId})</h3>
                        <c:if test="${not empty groupContractTotal}">
                            <p><strong>Tổng giá trị hợp đồng nhóm:</strong> <c:out value="${groupContractTotal}"/></p>
                        </c:if>
                    </div>

                    <div style="margin-top: 20px;">
                        <h4>Công ty mẹ (Parent)</h4>
                        <c:choose>
                            <c:when test="${not empty parent}">
                                <p><strong>Tên:</strong> <c:out value="${parent.customerName}"/> (ID: ${parent.customerId})</p>
                            </c:when>
                            <c:otherwise>
                                <p><em>Không có</em></p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div style="margin-top: 20px;">
                        <h4>Danh sách công ty con (Children)</h4>
                        <c:choose>
                            <c:when test="${not empty children and children.size() > 0}">
                                <ul style="list-style-type: disc; margin-left: 20px;">
                                    <c:forEach var="child" items="${children}">
                                        <li><c:out value="${child.customerName}"/> (ID: ${child.customerId})</li>
                                    </c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise>
                                <p><em>Không có</em></p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <hr style="margin: 30px 0;">
                    
                    <h4>Cập nhật quan hệ</h4>
                    <form action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="background: #fff; padding: 20px; border: 1px solid #eee; border-radius: 4px;">
                        <input type="hidden" name="customerId" value="${customer.customerId}">
                        <div style="margin-bottom: 15px;">
                            <label for="parentId" style="font-weight: bold; display: block; margin-bottom: 5px;">ID Công ty mẹ (Để trống để bỏ quan hệ):</label>
                            <input type="number" id="parentId" name="parentId" value="${not empty parent ? parent.customerId : ''}" placeholder="Nhập ID công ty mẹ" style="padding: 8px; width: 100%; max-width: 300px; border: 1px solid #ccc; border-radius: 4px;">
                        </div>
                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                    </form>
                    
                    <div style="margin-top: 20px;">
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers/detail?id=${customer.customerId}">Quay lại chi tiết</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning">Không tìm thấy thông tin khách hàng.</div>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers">Quay lại danh sách</a>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
</body>
</html>
