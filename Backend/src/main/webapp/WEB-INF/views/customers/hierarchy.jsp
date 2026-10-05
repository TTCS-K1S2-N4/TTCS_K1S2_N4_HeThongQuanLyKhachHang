<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cây quan hệ khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/accounts.css">
    <style>
        .hierarchy-section { margin-top: 20px; }
        .hierarchy-list { margin-top: 10px; }
        .hierarchy-item { display: flex; justify-content: space-between; align-items: center; padding: 10px; border: 1px solid #ddd; margin-bottom: 5px; border-radius: 4px; }
        .add-form { margin-top: 10px; padding: 10px; background: #f9f9f9; border-radius: 4px; }
    </style>
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
                <a href="${pageContext.request.contextPath}/customers/detail?id=${customerId}">Chi tiết</a>
                <span>/</span>
                <span class="breadcrumb-current">Cây quan hệ</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Cây quan hệ: <c:out value="${customer.customerName}"/></h1>
                </div>
                <div class="page-actions">
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers/detail?id=${customerId}">Quay lại chi tiết</a>
                </div>
            </div>

            <c:if test="${not empty customer}">
                <div class="card hierarchy-section">
                    <div class="card-header">
                        <h2>Công ty mẹ (Parent Companies)</h2>
                    </div>
                    <div class="card-body">
                        <div class="hierarchy-list">
                            <c:if test="${empty parents}">
                                <p>Không có dữ liệu.</p>
                            </c:if>
                            <c:forEach var="rel" items="${parents}">
                                <div class="hierarchy-item">
                                    <div>
                                        <strong><a href="${pageContext.request.contextPath}/customers/hierarchy?id=${rel.parentCustomer.customerId}">
                                            <c:out value="${rel.parentCustomer.customerName}"/>
                                        </a></strong> 
                                        - Loại quan hệ: <span class="badge"><c:out value="${rel.relationshipType}"/></span>
                                    </div>
                                    <form method="post" action="${pageContext.request.contextPath}/customers/hierarchy" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="customerId" value="${customerId}">
                                        <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Xóa quan hệ này?');">Xóa</button>
                                    </form>
                                </div>
                            </c:forEach>
                        </div>
                        
                        <div class="add-form">
                            <h4>Thêm Công ty mẹ</h4>
                            <form method="post" action="${pageContext.request.contextPath}/customers/hierarchy">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="customerId" value="${customerId}">
                                <input type="hidden" name="childId" value="${customerId}">
                                <div class="form-row">
                                    <div class="form-group col-md-4">
                                        <label>ID Công ty mẹ</label>
                                        <input type="number" name="parentId" class="form-control" min="0" required>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label>Loại quan hệ</label>
                                        <select name="relationshipType" class="form-control">
                                            <option value="SUBSIDIARY">Công ty con (Subsidiary)</option>
                                            <option value="BRANCH">Chi nhánh (Branch)</option>
                                            <option value="AFFILIATE">Công ty liên kết (Affiliate)</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-4 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary" style="margin-top: 24px;">Thêm</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="card hierarchy-section">
                    <div class="card-header">
                        <h2>Công ty con (Child Companies)</h2>
                    </div>
                    <div class="card-body">
                        <div class="hierarchy-list">
                            <c:if test="${empty children}">
                                <p>Không có dữ liệu.</p>
                            </c:if>
                            <c:forEach var="rel" items="${children}">
                                <div class="hierarchy-item">
                                    <div>
                                        <strong><a href="${pageContext.request.contextPath}/customers/hierarchy?id=${rel.childCustomer.customerId}">
                                            <c:out value="${rel.childCustomer.customerName}"/>
                                        </a></strong> 
                                        - Loại quan hệ: <span class="badge"><c:out value="${rel.relationshipType}"/></span>
                                    </div>
                                    <form method="post" action="${pageContext.request.contextPath}/customers/hierarchy" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="customerId" value="${customerId}">
                                        <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Xóa quan hệ này?');">Xóa</button>
                                    </form>
                                </div>
                            </c:forEach>
                        </div>
                        
                        <div class="add-form">
                            <h4>Thêm Công ty con</h4>
                            <form method="post" action="${pageContext.request.contextPath}/customers/hierarchy">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="customerId" value="${customerId}">
                                <input type="hidden" name="parentId" value="${customerId}">
                                <div class="form-row">
                                    <div class="form-group col-md-4">
                                        <label>ID Công ty con</label>
                                        <input type="number" name="childId" class="form-control" min="0" required>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label>Loại quan hệ</label>
                                        <select name="relationshipType" class="form-control">
                                            <option value="SUBSIDIARY">Công ty con (Subsidiary)</option>
                                            <option value="BRANCH">Chi nhánh (Branch)</option>
                                            <option value="AFFILIATE">Công ty liên kết (Affiliate)</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-4 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary" style="margin-top: 24px;">Thêm</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>
