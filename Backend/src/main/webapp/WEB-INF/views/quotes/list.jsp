<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo giá | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/quotes.css">
    <style>
        .quotes-toolbar {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
        }
        .search-group-inline {
            display: flex;
            align-items: center;
            gap: 8px;
            background: white;
            padding: 4px 8px 4px 16px;
            border-radius: 8px;
            border: 1px solid var(--color-border);
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            flex: 1;
            min-width: 320px;
            max-width: 480px;
        }
        .search-group-inline .form-control {
            border: none;
            box-shadow: none;
            padding: 8px 0;
            width: 100%;
            outline: none;
        }
        .search-group-inline .search-icon {
            color: var(--color-text-secondary);
        }
        .filter-actions {
            display: flex;
            gap: 8px;
        }
        .card-header-flex {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .empty-state {
            padding: 48px 0;
            text-align: center;
            color: var(--color-text-secondary);
        }
        .empty-state-icon {
            font-size: 32px;
            margin-bottom: 16px;
            color: var(--color-gray-400);
        }
        @media (max-width: 768px) {
            .search-group-inline {
                max-width: 100%;
            }
            .filter-actions {
                width: 100%;
            }
            .filter-actions .btn {
                flex: 1;
            }
        }
        .page-item-disabled {
            opacity: 0.5;
            pointer-events: none;
        }
        .page-link-inactive {
            background: white;
            border: 1px solid var(--color-border);
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Báo giá</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Báo giá</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Quản lý danh sách các báo giá.</p>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/quotes" method="get" class="quotes-toolbar">
                <div class="search-group-inline">
                    <i class="fas fa-search search-icon"></i>
                    <input class="form-control" name="keyword" type="search" placeholder="Tìm theo số báo giá..." value="<c:out value='${keyword}'/>">
                </div>
                <div class="filter-actions">
                    <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i> Tìm kiếm</button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/quotes" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">Đặt lại</a>
                    </c:if>
                </div>
            </form>

            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <div class="card-header card-header-flex">
                    <h2 class="card-title" style="font-size: 16px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-file-invoice-dollar" style="color: var(--color-primary);"></i> Danh sách báo giá</h2>
                </div>
                
                <div class="table-container table-responsive">
                    <table class="table">
                        <thead style="background: #f8fafc;">
                            <tr>
                                <th style="width: 80px; color: var(--color-text-secondary); font-weight: 600; text-transform: none;">ID</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Số báo giá</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Ngày tạo</th>
                                <th style="width: 120px; color: var(--color-text-secondary); font-weight: 600; text-transform: none; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty list}">
                                    <c:forEach var="item" items="${list}">
                                        <tr style="height: 64px;">
                                            <td style="color: var(--color-text-secondary);">${item.quoteId}</td>
                                            <td>
                                                <div style="font-weight: 500; color: var(--color-gray-900);"><c:out value="${item.quoteNumber}"/></div>
                                            </td>
                                            <td><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/quotes/detail?id=${item.quoteId}" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border); padding: 4px 12px; font-size: 13px;" title="Xem chi tiết"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4">
                                            <div class="empty-state">
                                                <div class="empty-state-icon"><i class="fas fa-file-invoice"></i></div>
                                                <c:choose>
                                                    <c:when test="${not empty keyword}">
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Không tìm thấy báo giá</h3>
                                                        <p>Không có kết quả phù hợp với từ khóa "<c:out value='${keyword}'/>"</p>
                                                        <a href="${pageContext.request.contextPath}/quotes" class="btn btn-secondary" style="margin-top: 16px;">Đặt lại tìm kiếm</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa có báo giá</h3>
                                                        <p>Hiện chưa có dữ liệu báo giá để hiển thị.</p>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalPages > 1}">
                    <div class="card-footer" style="display: flex; justify-content: flex-end; align-items: center; border-top: 1px solid var(--color-border); padding: 12px 24px;">
                        <ul class="pagination" style="margin: 0; display: flex; gap: 4px; list-style: none; padding: 0;">
                            <li class="page-item ${currentPage == 1 ? 'disabled page-item-disabled' : ''}">
                                <a class="page-link btn btn-secondary page-link-inactive" style="padding: 4px 12px;" href="?page=${currentPage - 1}&keyword=<c:out value='${keyword}'/>">‹ Trước</a>
                            </li>
                            <c:forEach begin="${Math.max(1, currentPage - 2)}" end="${Math.min(totalPages, currentPage + 2)}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link btn ${currentPage == i ? 'btn-primary' : 'btn-secondary page-link-inactive'}" style="padding: 4px 12px;" href="?page=${i}&keyword=<c:out value='${keyword}'/>">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled page-item-disabled' : ''}">
                                <a class="page-link btn btn-secondary page-link-inactive" style="padding: 4px 12px;" href="?page=${currentPage + 1}&keyword=<c:out value='${keyword}'/>">Sau ›</a>
                            </li>
                        </ul>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>
</body>
</html>
