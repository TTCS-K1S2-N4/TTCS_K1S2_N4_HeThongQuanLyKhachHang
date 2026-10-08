<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
            <h1 class="page-title">Cấu trúc công ty mẹ / con</h1>
            
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="padding: 12px; margin-bottom: 20px; background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 4px;">
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success" style="padding: 12px; margin-bottom: 20px; background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 4px;">
                    <c:out value="${successMessage}"/>
                </div>
            </c:if>
            
            <c:choose>
                <c:when test="${not empty customer}">
                    <div style="background: #ffffff; padding: 20px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 25px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <h3 style="margin-top: 0; color: #1e293b;">
                            Khách hàng: <c:out value="${customer.customerName}"/> <span style="font-weight: normal; color: #64748b;">(ID: ${customer.customerId})</span>
                        </h3>
                        <c:if test="${not empty groupContractTotal}">
                            <p style="font-size: 1.1rem; margin-bottom: 0; color: #047857;">
                                <strong>Tổng giá trị hợp đồng tập đoàn:</strong> 
                                <fmt:formatNumber value="${groupContractTotal}" type="currency" currencySymbol="VND"/>
                            </p>
                        </c:if>
                    </div>

                    <!-- Company Parent List -->
                    <div style="margin-bottom: 25px; background: #fff; padding: 20px; border-radius: 6px; border: 1px solid #e2e8f0;">
                        <h4 style="margin-top: 0; border-bottom: 2px solid #3b82f6; padding-bottom: 8px; color: #1e293b;">
                            <i class="fa-solid fa-building"></i> Công ty mẹ (Parent Companies)
                        </h4>
                        <c:choose>
                            <c:when test="${not empty parents and parents.size() > 0}">
                                <ul style="list-style-type: none; padding-left: 0; margin-bottom: 0;">
                                    <c:forEach var="rel" items="${parents}">
                                        <li style="padding: 10px 0; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center;">
                                            <div>
                                                <strong>
                                                    <a href="${pageContext.request.contextPath}/customers/360?id=${rel.parentCustomer.customerId}">
                                                        <c:out value="${rel.parentCustomer.customerName}"/>
                                                    </a>
                                                </strong>
                                                <span style="color: #64748b; font-size: 0.9rem;">
                                                    (ID: ${rel.parentCustomer.customerId}) - Loại: ${rel.relationshipType}
                                                </span>
                                            </div>
                                            <form action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="margin: 0;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                                <input type="hidden" name="customerId" value="${customer.customerId}">
                                                <button type="submit" class="btn btn-sm btn-danger" style="background-color: #ef4444; color: white; border: none; padding: 4px 10px; border-radius: 4px; cursor: pointer;" onclick="return confirm('Bạn có chắc chắn muốn xóa quan hệ này?')">Hủy quan hệ</button>
                                            </form>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise>
                                <p style="color: #64748b; font-style: italic; margin-bottom: 0;">Chưa có công ty mẹ nào.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Subsidiaries List -->
                    <div style="margin-bottom: 25px; background: #fff; padding: 20px; border-radius: 6px; border: 1px solid #e2e8f0;">
                        <h4 style="margin-top: 0; border-bottom: 2px solid #10b981; padding-bottom: 8px; color: #1e293b;">
                            <i class="fa-solid fa-sitemap"></i> Danh sách công ty con (Subsidiary Companies)
                        </h4>
                        <c:choose>
                            <c:when test="${not empty children and children.size() > 0}">
                                <ul style="list-style-type: none; padding-left: 0; margin-bottom: 0;">
                                    <c:forEach var="rel" items="${children}">
                                        <li style="padding: 10px 0; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center;">
                                            <div>
                                                <strong>
                                                    <a href="${pageContext.request.contextPath}/customers/360?id=${rel.childCustomer.customerId}">
                                                        <c:out value="${rel.childCustomer.customerName}"/>
                                                    </a>
                                                </strong>
                                                <span style="color: #64748b; font-size: 0.9rem;">
                                                    (ID: ${rel.childCustomer.customerId}) - Loại: ${rel.relationshipType}
                                                </span>
                                            </div>
                                            <form action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="margin: 0;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                                <input type="hidden" name="customerId" value="${customer.customerId}">
                                                <button type="submit" class="btn btn-sm btn-danger" style="background-color: #ef4444; color: white; border: none; padding: 4px 10px; border-radius: 4px; cursor: pointer;" onclick="return confirm('Bạn có chắc chắn muốn xóa quan hệ này?')">Hủy quan hệ</button>
                                            </form>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise>
                                <p style="color: #64748b; font-style: italic; margin-bottom: 0;">Chưa có công ty con nào.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Add Relationship Form -->
                    <div style="background: #fff; padding: 20px; border: 1px solid #e2e8f0; border-radius: 6px;">
                        <h4 style="margin-top: 0; border-bottom: 2px solid #6366f1; padding-bottom: 8px; color: #1e293b;">
                            <i class="fa-solid fa-plus-circle"></i> Khai báo quan hệ mới
                        </h4>
                        <form id="addRelForm" action="${pageContext.request.contextPath}/customers/hierarchy" method="post" style="margin-top: 15px;">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="customerId" value="${customer.customerId}">
                            
                            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                                <div>
                                    <label for="parentId" style="font-weight: bold; display: block; margin-bottom: 5px;">Công ty mẹ (Parent):</label>
                                    <select id="parentId" name="parentId" style="padding: 8px 12px; width: 100%; border: 1px solid #cbd5e1; border-radius: 4px;">
                                        <c:forEach var="cItem" items="${allCustomers}">
                                            <option value="${cItem.customerId}" ${cItem.customerId == customer.customerId ? 'selected' : ''}>
                                                <c:out value="${cItem.customerName}"/> (ID: ${cItem.customerId})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label for="childId" style="font-weight: bold; display: block; margin-bottom: 5px;">Công ty con (Child):</label>
                                    <select id="childId" name="childId" style="padding: 8px 12px; width: 100%; border: 1px solid #cbd5e1; border-radius: 4px;" required>
                                        <option value="">-- Chọn công ty con --</option>
                                        <c:forEach var="cItem" items="${allCustomers}">
                                            <c:if test="${cItem.customerId != customer.customerId}">
                                                <option value="${cItem.customerId}">
                                                    <c:out value="${cItem.customerName}"/> (ID: ${cItem.customerId})
                                                </option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label for="relationshipType" style="font-weight: bold; display: block; margin-bottom: 5px;">Loại quan hệ:</label>
                                    <select id="relationshipType" name="relationshipType" style="padding: 8px 12px; width: 100%; border: 1px solid #cbd5e1; border-radius: 4px;">
                                        <option value="SUBSIDIARY">Công ty con (SUBSIDIARY)</option>
                                        <option value="MEMBER">Công ty thành viên (MEMBER)</option>
                                        <option value="BRANCH">Chi nhánh (BRANCH)</option>
                                    </select>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-primary" style="background-color: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 4px; font-weight: 500; cursor: pointer;">
                                <i class="fa-solid fa-save"></i> Lưu quan hệ
                            </button>
                        </form>
                    </div>
                    
                    <div style="margin-top: 25px;">
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers/360?id=${customer.customerId}" style="background-color: #64748b; color: white; padding: 8px 16px; border-radius: 4px; text-decoration: none; margin-right: 10px;">Xem Customer 360</a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers/detail?id=${customer.customerId}" style="background-color: #94a3b8; color: white; padding: 8px 16px; border-radius: 4px; text-decoration: none;">Quay lại Chi tiết</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning" style="padding: 15px; background-color: #fef3c7; color: #92400e; border-radius: 4px; margin-bottom: 20px;">
                        Không tìm thấy thông tin khách hàng hoặc chưa chọn khách hàng.
                    </div>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers" style="background-color: #2563eb; color: white; padding: 8px 16px; border-radius: 4px; text-decoration: none;">Quay lại danh sách khách hàng</a>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('addRelForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            var parentId = document.getElementById('parentId').value;
            var childId = document.getElementById('childId').value;
            if (!childId) {
                alert('Vui lòng chọn công ty con.');
                e.preventDefault();
                return false;
            }
            if (parentId === childId) {
                alert('Công ty mẹ và công ty con không được là cùng một khách hàng!');
                e.preventDefault();
                return false;
            }
        });
    }
});
</script>
</body>
</html>
