<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .page-title {
            font-size: 1.75rem;
            font-family: var(--font-heading, 'Georgia', serif);
            font-weight: 600;
            color: var(--color-gray-900);
            letter-spacing: -0.02em;
        }
        .search-wrapper {
            position: relative;
            flex-grow: 1;
        }
        .search-wrapper i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--color-gray-400);
        }
        .search-wrapper input {
            padding-left: 40px;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--color-border);
            background: var(--color-gray-50);
            transition: all 0.3s ease;
        }
        .search-wrapper input:focus {
            background: var(--color-white);
            box-shadow: 0 0 0 3px var(--color-primary-light);
            border-color: var(--color-primary);
        }
        .customer-name {
            font-weight: 600;
            color: var(--color-gray-900);
        }
        .card {
            border: 1px solid var(--color-border); 
            box-shadow: var(--shadow-md);
            border-radius: var(--radius-lg);
            overflow: hidden;
            background: var(--color-surface);
        }
        .card-header {
            background: var(--color-surface);
            padding: 24px;
            border-bottom: 1px solid var(--color-border);
        }
        .table-container {
            border: none;
            border-radius: 0;
            box-shadow: none;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        .table thead th {
            background-color: var(--color-gray-50);
            color: var(--color-gray-600);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--color-border);
        }
        .table tbody tr {
            transition: background-color 0.2s ease;
            border-bottom: 1px solid var(--color-border);
        }
        .table tbody tr:hover {
            background-color: var(--color-primary-light);
        }
        .table tbody td {
            padding: 1rem 1.5rem;
            vertical-align: middle;
        }
        .btn-icon {
            width: 36px;
            height: 36px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: var(--radius-md);
            background: var(--color-gray-50);
            border: 1px solid var(--color-border);
            color: var(--color-gray-600);
            transition: all 0.2s ease;
        }
        .btn-icon:hover {
            background: var(--color-white);
            color: var(--color-primary);
            border-color: var(--color-primary);
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    
    <main class="main-content">
        <div class="content-container">
            
            <!-- Toolbar -->
            <div class="toolbar" style="margin-bottom: 32px;">
                <div>
                    <h1 class="page-title mb-0">Quản lý Khách hàng</h1>
                    <p class="text-secondary mt-1" style="font-size: 0.95rem; font-weight: 400;">Tra cứu, thêm mới và quản lý thông tin khách hàng</p>
                </div>
                <div class="toolbar-group">
                    <a href="${pageContext.request.contextPath}/customers/create" class="btn btn-primary" style="box-shadow: var(--shadow-md); border-radius: var(--radius-md);">
                        <i class="fa-solid fa-plus"></i> Thêm Khách hàng
                    </a>
                </div>
            </div>

            <!-- Card Layout -->
            <div class="card">
                <!-- Card Header (Search & Export) -->
                <div class="card-header">
                    <form method="get" action="${pageContext.request.contextPath}/customers" style="display: flex; gap: 16px; width: 100%; align-items: center; justify-content: space-between;">
                        <div style="display: flex; gap: 12px; width: 100%; max-width: 500px;">
                            <div class="search-wrapper">
                                <i class="fa-solid fa-search"></i>
                                <input name="keyword" class="form-control" value="<c:out value='${keyword}'/>" placeholder="Tìm kiếm theo tên, SĐT...">
                            </div>
                            <button class="btn btn-primary" style="padding: 0 24px; border-radius: var(--radius-md);">Tìm kiếm</button> 
                        </div>
                        <a href="${pageContext.request.contextPath}/customers/export?keyword=<c:out value='${keyword}'/>" class="btn btn-secondary" style="border-radius: var(--radius-md);">
                            <i class="fa-solid fa-file-export" style="color: var(--color-success);"></i> Xuất CSV
                        </a>
                    </form>
                </div>
                
                <!-- Table -->
                <div class="table-container">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th style="width: 100px;">ID</th>
                                <th>Tên khách hàng</th>
                                <th>Điện thoại</th>
                                <th class="text-center" style="width: 120px;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty list}">
                                    <tr>
                                        <td colspan="4" style="border-bottom: none;">
                                            <div class="empty-state" style="padding: 60px 20px;">
                                                <div style="font-size: 3.5rem; color: var(--color-gray-300); margin-bottom: 20px;"><i class="fa-solid fa-users-slash"></i></div>
                                                <h3 class="empty-state-title" style="color: var(--color-gray-800); font-family: var(--font-heading, 'Georgia', serif);">Không tìm thấy khách hàng nào</h3>
                                                <p class="empty-state-description" style="color: var(--color-gray-500);">Vui lòng thử từ khóa khác hoặc thêm mới khách hàng.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="item" items="${list}">
                                        <tr>
                                            <td><span class="badge badge-neutral" style="font-family: monospace; font-size: 0.85rem;">#${item.customerId}</span></td>
                                            <td>
                                                <div class="customer-name"><c:out value="${item.customerName}"/></div>
                                            </td>
                                            <td>
                                                <i class="fa-solid fa-phone" style="color: var(--color-text-muted); margin-right: 6px; font-size: 0.875rem;"></i>
                                                <c:out value="${item.phone}"/>
                                            </td>
                                            <td>
                                                <div class="table-actions" style="justify-content: center;">
                                                    <a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}" class="btn-icon" title="Xem chi tiết">
                                                        <i class="fa-solid fa-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customers/edit?id=${item.customerId}" class="btn-icon" title="Sửa">
                                                        <i class="fa-solid fa-pen"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="card-footer" style="background: var(--color-surface); border-top: 1px solid var(--color-border); display: flex; justify-content: center; padding: 20px;">
                        <div class="pagination mt-0">
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <a href="?page=${i}&keyword=${keyword}" class="pagination-item <c:if test='${param.page == i || (empty param.page && i == 1)}'>active</c:if>">${i}</a>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>
</body>
</html>
