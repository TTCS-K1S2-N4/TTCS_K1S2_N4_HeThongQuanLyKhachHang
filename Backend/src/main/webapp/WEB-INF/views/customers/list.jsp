<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .customer-toolbar {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: var(--space-4);
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
            min-width: 250px;
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
                <span class="breadcrumb-current">Khách hàng</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Khách hàng</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Quản lý và tra cứu danh sách khách hàng.</p>
                </div>
                <div class="page-actions">
                    <a href="${pageContext.request.contextPath}/customers/export?keyword=<c:out value='${keyword}'/>" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">
                        <i class="fas fa-file-export"></i> Xuất CSV
                    </a>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/customers" method="get" class="customer-toolbar">
                <div class="search-group-inline">
                    <i class="fas fa-search search-icon"></i>
                    <input class="form-control" name="keyword" type="search" placeholder="Tìm khách hàng theo tên..." value="<c:out value='${keyword}'/>">
                </div>
                <select name="status" class="form-control" style="width: auto; min-width: 140px;">
                    <option value="">- Trạng thái -</option>
                    <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                    <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                </select>
                <select name="industry" class="form-control" style="width: auto; min-width: 140px;">
                    <option value="">- Ngành -</option>
                    <option value="IT" ${param.industry == 'IT' ? 'selected' : ''}>IT</option>
                    <option value="FINANCE" ${param.industry == 'FINANCE' ? 'selected' : ''}>Tài chính</option>
                </select>
                <select name="size" class="form-control" style="width: auto; min-width: 120px;">
                    <option value="">- Quy mô -</option>
                    <option value="SMALL" ${param.size == 'SMALL' ? 'selected' : ''}>Nhỏ</option>
                    <option value="MEDIUM" ${param.size == 'MEDIUM' ? 'selected' : ''}>Vừa</option>
                    <option value="LARGE" ${param.size == 'LARGE' ? 'selected' : ''}>Lớn</option>
                </select>
                <select name="region" class="form-control" style="width: auto; min-width: 120px;">
                    <option value="">- Khu vực -</option>
                    <option value="NORTH" ${param.region == 'NORTH' ? 'selected' : ''}>Miền Bắc</option>
                    <option value="SOUTH" ${param.region == 'SOUTH' ? 'selected' : ''}>Miền Nam</option>
                </select>
                <input type="text" name="ownerId" class="form-control" value="<c:out value='${param.ownerId}'/>" placeholder="Owner ID" style="width: 100px;">
                <div class="filter-actions">
                    <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i> Lọc / Tìm</button>
                    <c:if test="${not empty keyword or not empty param.status or not empty param.industry or not empty param.size or not empty param.region or not empty param.ownerId}">
                        <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">Đặt lại</a>
                    </c:if>
                </div>
            </form>

            <div class="saved-filters-section mb-4 d-flex align-items-center" style="gap: 12px;">
                <h4 style="font-size: 14px; margin: 0; color: var(--color-text-secondary);"><i class="fas fa-bookmark" style="margin-right: 4px;"></i> Bộ lọc đã lưu:</h4>
                <a href="${pageContext.request.contextPath}/customers/filters" class="btn btn-info btn-sm" style="padding: 4px 12px; font-size: 13px;">Quản lý bộ lọc</a>
                <form method="post" action="${pageContext.request.contextPath}/customers/filters" class="d-inline" style="margin: 0;">
                    <input type="hidden" name="name" value="Current Filter">
                    <input type="hidden" name="criteria" value="">
                    <button type="submit" class="btn btn-success btn-sm" style="padding: 4px 12px; font-size: 13px;" disabled>Lưu bộ lọc hiện tại</button>
                </form>
            </div>

            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <div class="card-header card-header-flex">
                    <h2 class="card-title" style="font-size: 16px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-users" style="color: var(--color-primary);"></i> Danh sách khách hàng</h2>
                </div>
                
                <div class="table-container table-responsive">
                    <table class="table">
                        <thead style="background: #f8fafc;">
                            <tr>
                                <th style="width: 80px; color: var(--color-text-secondary); font-weight: 600; text-transform: none;">ID</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Khách hàng</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Điện thoại</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Ngày tạo</th>
                                <th style="width: 120px; color: var(--color-text-secondary); font-weight: 600; text-transform: none; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty list}">
                                    <c:forEach var="item" items="${list}">
                                        <tr style="height: 64px;">
                                            <td style="color: var(--color-text-secondary);">${item.customerId}</td>
                                            <td>
                                                <div style="font-weight: 500; color: var(--color-gray-900);"><c:out value="${item.customerName}"/></div>
                                            </td>
                                            <td><c:out value="${item.phone}"/></td>
                                            <td><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border); padding: 4px 12px; font-size: 13px;" title="Xem chi tiết"><i class="fas fa-eye"></i> Xem</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5">
                                            <div class="empty-state">
                                                <div class="empty-state-icon"><i class="fas fa-users-slash"></i></div>
                                                <c:choose>
                                                    <c:when test="${not empty keyword or not empty param.status or not empty param.industry or not empty param.size or not empty param.region or not empty param.ownerId}">
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Không tìm thấy khách hàng</h3>
                                                        <p>Không có kết quả phù hợp với tiêu chí tìm kiếm và lọc</p>
                                                        <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary" style="margin-top: 16px;">Đặt lại tìm kiếm</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa có khách hàng</h3>
                                                        <p>Danh sách hiện chưa có dữ liệu khách hàng.</p>
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
                    <div class="card-footer" style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--color-border); padding: 12px 24px;">
                        <span style="color: var(--color-text-secondary); font-size: 13px;">Trang ${currentPage} / ${totalPages}</span>
                        <ul class="pagination" style="margin: 0; display: flex; gap: 4px; list-style: none; padding: 0;">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}" style="opacity: ${currentPage == 1 ? '0.5' : '1'}; pointer-events: ${currentPage == 1 ? 'none' : 'auto'};">
                                <a class="page-link btn btn-secondary" style="padding: 4px 12px; background: white; border: 1px solid var(--color-border);" href="?page=${currentPage - 1}&keyword=<c:out value='${keyword}'/>">‹ Trước</a>
                            </li>
                            <c:forEach begin="${Math.max(1, currentPage - 2)}" end="${Math.min(totalPages, currentPage + 2)}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link btn ${currentPage == i ? 'btn-primary' : 'btn-secondary'}" style="padding: 4px 12px; ${currentPage != i ? 'background: white; border: 1px solid var(--color-border);' : ''}" href="?page=${i}&keyword=<c:out value='${keyword}'/>">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}" style="opacity: ${currentPage == totalPages ? '0.5' : '1'}; pointer-events: ${currentPage == totalPages ? 'none' : 'auto'};">
                                <a class="page-link btn btn-secondary" style="padding: 4px 12px; background: white; border: 1px solid var(--color-border);" href="?page=${currentPage + 1}&keyword=<c:out value='${keyword}'/>">Sau ›</a>
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
