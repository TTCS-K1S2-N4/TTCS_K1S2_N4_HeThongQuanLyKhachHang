<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chiến dịch | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <style>
        .campaign-toolbar {
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
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
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
    </style>
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
        <main class="main-content">
            <div class="content-container">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Chiến dịch Marketing</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px;">
                    <div>
                        <h1 class="page-title">Chiến dịch Marketing</h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Theo dõi và quản lý các chiến dịch Marketing.</p>
                    </div>
                    <div class="page-actions" style="display: flex; gap: 8px;">
                        <a href="${pageContext.request.contextPath}/campaigns/create" class="btn btn-primary"><i class="fas fa-plus"></i> Thêm chiến dịch</a>
                    </div>
                </div>

                <form id="filterForm" action="${pageContext.request.contextPath}/campaigns" method="get" class="campaign-toolbar" style="background: white; padding: 16px; border-radius: 8px; border: 1px solid var(--color-border); margin-bottom: 20px;">
                    <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; width: 100%;">
                        <div class="search-group-inline" style="flex: 2; min-width: 240px;">
                            <i class="fas fa-search search-icon"></i>
                            <input class="form-control" name="keyword" type="search" placeholder="Tìm tên chiến dịch..." value="<c:out value='${keyword}'/>">
                        </div>
                        <div style="flex: 1; min-width: 140px;">
                            <select name="channel" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; width: 100%;">
                                <option value="">-- Kênh --</option>
                                <option value="Email" ${channel == 'Email' ? 'selected' : ''}>Email</option>
                                <option value="Social" ${channel == 'Social' ? 'selected' : ''}>Social</option>
                                <option value="Search" ${channel == 'Search' ? 'selected' : ''}>Search</option>
                                <option value="Event" ${channel == 'Event' ? 'selected' : ''}>Event</option>
                            </select>
                        </div>
                        <div class="filter-actions" style="display: flex; gap: 8px; margin-left: auto;">
                            <button class="btn btn-primary" type="submit"><i class="fas fa-filter"></i> Lọc</button>
                            <c:if test="${not empty keyword or not empty channel}">
                                <a href="${pageContext.request.contextPath}/campaigns" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">Đặt lại</a>
                            </c:if>
                        </div>
                    </div>
                </form>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px; padding: 12px; background: #fee2e2; color: #dc2626; border-radius: 6px;">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                <c:if test="${not empty message}">
                    <div class="alert alert-success" style="margin-bottom: 16px; padding: 12px; background: #dcfce7; color: #16a34a; border-radius: 6px;">
                        <c:out value="${message}"/>
                    </div>
                </c:if>

                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div class="card-header">
                        <h2 class="card-title" style="font-size: 16px; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-bullhorn" style="color: var(--color-primary);"></i> Danh sách chiến dịch
                        </h2>
                    </div>

                    <div class="table-container table-responsive">
                        <table class="table">
                            <thead style="background: #f8fafc;">
                                <tr>
                                    <th style="width: 60px; color: var(--color-text-secondary); font-weight: 600;">ID</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600;">Tên chiến dịch</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600;">Kênh</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600;">Ngân sách</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600;">Ngày bắt đầu</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600;">Ngày kết thúc</th>
                                    <th style="width: 120px; color: var(--color-text-secondary); font-weight: 600; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty list}">
                                        <c:forEach var="item" items="${list}">
                                            <tr style="height: 64px;">
                                                <td style="color: var(--color-text-secondary);">${item.id}</td>
                                                <td><div style="font-weight: 500; color: var(--color-gray-900);"><c:out value="${item.name}" /></div></td>
                                                <td><c:out value="${item.channel}" /></td>
                                                <td><fmt:formatNumber value="${item.budget}" pattern="#,##0" /></td>
                                                <td><fmt:formatDate value="${item.startDate}" pattern="dd/MM/yyyy" /></td>
                                                <td><fmt:formatDate value="${item.endDate}" pattern="dd/MM/yyyy" /></td>
                                                <td style="text-align: center;">
                                                    <a href="${pageContext.request.contextPath}/campaigns/detail?id=${item.id}"
                                                        class="btn btn-secondary"
                                                        style="background: white; border: 1px solid var(--color-border); padding: 4px 8px; font-size: 13px;"
                                                        title="Xem chi tiết"><i class="fas fa-eye"></i></a>
                                                    <a href="${pageContext.request.contextPath}/campaigns/edit?id=${item.id}"
                                                        class="btn btn-secondary"
                                                        style="background: white; border: 1px solid var(--color-border); padding: 4px 8px; font-size: 13px;"
                                                        title="Sửa"><i class="fas fa-edit"></i></a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-state">
                                                    <div class="empty-state-icon"><i class="fas fa-bullhorn"></i></div>
                                                    <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa có chiến dịch</h3>
                                                    <p>Danh sách hiện chưa có dữ liệu chiến dịch.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
