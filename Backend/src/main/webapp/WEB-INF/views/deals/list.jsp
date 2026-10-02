<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cơ hội | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .page-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0f172a;
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
            color: #94a3b8;
        }
        .search-wrapper input {
            padding-left: 40px;
            border-radius: 8px;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        }
        .deal-title {
            font-weight: 600;
            color: #1e293b;
        }
        .table-container {
            border: none;
            border-radius: 0;
            box-shadow: none;
        }
        .table thead th {
            background-color: #f8fafc;
            color: #475569;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
            padding: 1rem;
        }
        .table tbody td {
            padding: 1rem;
            vertical-align: middle;
        }
        .btn-icon {
            width: 32px;
            height: 32px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
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
            <div class="toolbar" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title mb-0">Cơ hội kinh doanh</h1>
                    <p class="text-secondary mt-1" style="font-size: 0.875rem;">Tra cứu và quản lý các cơ hội kinh doanh (Deals)</p>
                </div>
                <div class="toolbar-group">
                    <!-- Nút Thêm mới (nếu bạn có trang create thì dùng href này) -->
                    <a href="${pageContext.request.contextPath}/deals/create" class="btn btn-primary" style="box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);">
                        <i class="fa-solid fa-plus"></i> Thêm Cơ hội
                    </a>
                </div>
            </div>

            <!-- Card -->
            <div class="card" style="border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
                <!-- Card Header (Search) -->
                <div class="card-header" style="background: #ffffff; padding: 20px;">
                    <form method="get" action="${pageContext.request.contextPath}/deals" style="display: flex; gap: 12px; width: 100%; align-items: center;">
                        <div style="display: flex; gap: 12px; width: 100%; max-width: 500px;">
                            <div class="search-wrapper">
                                <i class="fa-solid fa-search"></i>
                                <input name="keyword" class="form-control" value="<c:out value='${keyword}'/>" placeholder="Tìm kiếm cơ hội kinh doanh...">
                            </div>
                            <button class="btn btn-primary" style="padding: 0 20px;">Tìm kiếm</button> 
                        </div>
                    </form>
                </div>
                
                <!-- Table -->
                <div class="table-container">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th>Tiêu đề</th>
                                <th>Giá trị</th>
                                <th class="text-center" style="width: 120px;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty list}">
                                    <tr>
                                        <td colspan="4">
                                            <div class="empty-state">
                                                <div style="font-size: 3rem; color: #cbd5e1; margin-bottom: 15px;"><i class="fa-solid fa-folder-open"></i></div>
                                                <h3 class="empty-state-title">Không tìm thấy cơ hội nào</h3>
                                                <p class="empty-state-description">Vui lòng thử tìm từ khóa khác.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="item" items="${list}">
                                        <tr>
                                            <td><span class="badge badge-neutral">#${item.opportunityId}</span></td>
                                            <td>
                                                <div class="deal-title"><c:out value="${item.title}"/></div>
                                            </td>
                                            <td>
                                                <i class="fa-solid fa-dollar-sign" style="color: #10b981; margin-right: 4px; font-size: 0.875rem;"></i>
                                                <span style="font-weight: 500; color: #334155;"><c:out value="${item.amount}"/></span>
                                            </td>
                                            <td>
                                                <div class="table-actions" style="justify-content: center;">
                                                    <a href="${pageContext.request.contextPath}/deals/detail?id=${item.opportunityId}" class="btn btn-secondary btn-icon" title="Xem chi tiết">
                                                        <i class="fa-solid fa-eye" style="color: #3b82f6;"></i>
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
                    <div class="card-footer" style="background: #ffffff; border-top: 1px solid #e2e8f0; display: flex; justify-content: center; padding: 15px;">
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
