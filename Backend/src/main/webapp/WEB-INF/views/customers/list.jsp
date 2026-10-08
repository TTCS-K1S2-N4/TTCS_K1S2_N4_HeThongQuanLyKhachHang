<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <title>Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .customer-toolbar {
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

        /* Pagination custom styles */
        .pagination .page-item.disabled {
            opacity: 0.5;
            pointer-events: none;
        }
        .pagination .page-link.inactive-link {
            background: white;
            border: 1px solid var(--color-border);
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
                    <span class="breadcrumb-current">Khách hàng</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px;">
                    <div>
                        <h1 class="page-title">Khách hàng</h1>
                        <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Quản lý và tra cứu danh sách khách hàng.</p>
                    </div>
                    <div class="page-actions" style="display: flex; gap: 8px;">
                        <button class="btn btn-primary" onclick="openCustomerModal()"><i class="fas fa-plus"></i> Thêm khách hàng</button>
                        <a href="${pageContext.request.contextPath}/customers/import" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);" title="Nhập danh sách khách hàng từ Excel">
                            <i class="fas fa-file-import"></i> Import Excel
                        </a>
                        <a href="${pageContext.request.contextPath}/customers/duplicates" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);" title="Danh sách khách hàng trùng lặp">
                            <i class="fas fa-copy"></i> Khách trùng
                        </a>
                        <a href="${pageContext.request.contextPath}/customers/merge" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);" title="Gộp khách hàng">
                            <i class="fas fa-compress-alt"></i> Gộp KH
                        </a>
                        <a href="${pageContext.request.contextPath}/customers/export?keyword=<c:out value='${keyword}'/>&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">
                            <i class="fas fa-file-export"></i> Xuất CSV
                        </a>
                    </div>
                </div>

                <form id="filterForm" action="${pageContext.request.contextPath}/customers" method="get" class="customer-toolbar" style="background: white; padding: 16px; border-radius: 8px; border: 1px solid var(--color-border); margin-bottom: 20px;">
                    <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; width: 100%;">
                        <!-- Keyword Search -->
                        <div class="search-group-inline" style="flex: 2; min-width: 240px;">
                            <i class="fas fa-search search-icon"></i>
                            <input class="form-control" name="keyword" type="search" placeholder="Tìm tên KH, MST, SĐT liên hệ..." value="<c:out value='${keyword}'/>">
                        </div>

                        <!-- Status Filter -->
                        <div style="flex: 1; min-width: 140px;">
                            <select name="status" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; width: 100%;">
                                <option value="">-- Trạng thái --</option>
                                <option value="POTENTIAL" ${status == 'POTENTIAL' ? 'selected' : ''}>Tiềm năng</option>
                                <option value="DEALING" ${status == 'DEALING' ? 'selected' : ''}>Đang giao dịch</option>
                                <option value="CUSTOMER" ${status == 'CUSTOMER' || status == 'Khách hàng' ? 'selected' : ''}>Khách hàng</option>
                                <option value="ACTIVE" ${status == 'ACTIVE' || status == 'Hoạt động' ? 'selected' : ''}>Hoạt động</option>
                                <option value="STOPPED" ${status == 'STOPPED' || status == 'Ngừng hợp tác' ? 'selected' : ''}>Ngừng hợp tác</option>
                            </select>
                        </div>

                        <!-- Industry Filter -->
                        <div style="flex: 1; min-width: 150px;">
                            <select name="industry" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; width: 100%;">
                                <option value="">-- Ngành nghề --</option>
                                <option value="Công nghệ thông tin" ${industry == 'Công nghệ thông tin' ? 'selected' : ''}>Công nghệ thông tin</option>
                                <option value="Bất động sản" ${industry == 'Bất động sản' ? 'selected' : ''}>Bất động sản</option>
                                <option value="Tài chính / Ngân hàng" ${industry == 'Tài chính / Ngân hàng' ? 'selected' : ''}>Tài chính / Ngân hàng</option>
                                <option value="Sản xuất" ${industry == 'Sản xuất' ? 'selected' : ''}>Sản xuất</option>
                                <option value="Thương mại / Bán lẻ" ${industry == 'Thương mại / Bán lẻ' ? 'selected' : ''}>Thương mại / Bán lẻ</option>
                                <option value="Y tế / Dược phẩm" ${industry == 'Y tế / Dược phẩm' ? 'selected' : ''}>Y tế / Dược phẩm</option>
                                <option value="Giáo dục" ${industry == 'Giáo dục' ? 'selected' : ''}>Giáo dục</option>
                                <option value="Khác" ${industry == 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>

                        <!-- Size / CompanySize Filter -->
                        <div style="flex: 1; min-width: 130px;">
                            <select name="companySize" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; width: 100%;">
                                <option value="">-- Quy mô --</option>
                                <option value="Dưới 10" ${companySize == 'Dưới 10' || size == 'Dưới 10' ? 'selected' : ''}>Dưới 10</option>
                                <option value="10-50" ${companySize == '10-50' || size == '10-50' ? 'selected' : ''}>10-50</option>
                                <option value="50-100" ${companySize == '50-100' || size == '50-100' ? 'selected' : ''}>50-100</option>
                                <option value="100-500" ${companySize == '100-500' || size == '100-500' ? 'selected' : ''}>100-500</option>
                                <option value="Trên 500" ${companySize == 'Trên 500' || size == 'Trên 500' ? 'selected' : ''}>Trên 500</option>
                            </select>
                        </div>

                        <!-- Region Filter -->
                        <div style="flex: 1; min-width: 140px;">
                            <select name="region" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; width: 100%;">
                                <option value="">-- Khu vực --</option>
                                <option value="Miền Bắc" ${region == 'Miền Bắc' ? 'selected' : ''}>Miền Bắc</option>
                                <option value="Miền Trung" ${region == 'Miền Trung' ? 'selected' : ''}>Miền Trung</option>
                                <option value="Miền Nam" ${region == 'Miền Nam' ? 'selected' : ''}>Miền Nam</option>
                                <option value="Toàn quốc" ${region == 'Toàn quốc' ? 'selected' : ''}>Toàn quốc</option>
                                <option value="Nước ngoài" ${region == 'Nước ngoài' ? 'selected' : ''}>Nước ngoài</option>
                            </select>
                        </div>

                        <!-- Owner Filter -->
                        <div style="flex: 1; min-width: 160px;">
                            <select name="ownerId" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; width: 100%;">
                                <option value="">-- Người sở hữu --</option>
                                <c:forEach var="acc" items="${owners}">
                                    <option value="${acc.accountId}" ${ownerId == acc.accountId ? 'selected' : ''}>
                                        <c:out value="${acc.fullName}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <!-- Row 2: Custom fields, Actions, and Save Filter -->
                    <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; width: 100%; margin-top: 12px;">
                        <c:if test="${not empty customFieldDefinitions}">
                            <div style="display: flex; gap: 8px; align-items: center; flex: 2; min-width: 260px;">
                                <select name="filterFieldId" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px;">
                                    <option value="">-- Lọc theo trường tùy chỉnh --</option>
                                    <c:forEach var="def" items="${customFieldDefinitions}">
                                        <option value="${def.fieldId}" ${filterFieldId == def.fieldId ? 'selected' : ''}><c:out value="${def.fieldLabel}"/></option>
                                    </c:forEach>
                                </select>
                                <input type="text" name="filterFieldValue" class="form-control" placeholder="Giá trị..." value="<c:out value='${filterFieldValue}'/>" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 8px 12px; max-width: 160px;">
                            </div>
                        </c:if>

                        <div class="filter-actions" style="display: flex; gap: 8px; margin-left: auto;">
                            <button class="btn btn-primary" type="submit"><i class="fas fa-filter"></i> Lọc</button>
                            <c:if test="${not empty keyword or not empty status or not empty industry or not empty companySize or not empty size or not empty region or not empty ownerId or not empty filterFieldId}">
                                <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">Đặt lại</a>
                            </c:if>
                            <button type="button" class="btn btn-secondary" onclick="openSaveFilterModal()" style="background: #f1f5f9; border: 1px solid #cbd5e1; color: #334155;">
                                <i class="fas fa-bookmark" style="color: #0284c7;"></i> Lưu bộ lọc
                            </button>
                        </div>
                    </div>

                    <!-- Row 3: Saved Filters Pills -->
                    <c:if test="${not empty savedFilters}">
                        <div style="width: 100%; border-top: 1px dashed var(--color-border); margin-top: 12px; padding-top: 10px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                            <span style="font-size: 13px; font-weight: 600; color: var(--color-text-secondary);"><i class="fas fa-star" style="color: #f59e0b;"></i> Bộ lọc đã lưu:</span>
                            <c:forEach var="sf" items="${savedFilters}">
                                <div class="saved-filter-pill" style="display: inline-flex; align-items: center; gap: 6px; background: #e0f2fe; color: #0369a1; padding: 4px 10px; border-radius: 16px; font-size: 13px; border: 1px solid #bae6fd;">
                                    <span style="cursor: pointer; font-weight: 500;" onclick="applySavedFilter('<c:out value="${sf.keyword}"/>', '<c:out value="${sf.status}"/>', '<c:out value="${sf.industry}"/>', '<c:out value="${sf.companySize}"/>', '<c:out value="${sf.region}"/>', '<c:out value="${sf.ownerId}"/>')">
                                        <c:out value="${sf.filterName}"/>
                                    </span>
                                    <button type="button" onclick="deleteSavedFilter(event, ${sf.filterId})" style="border: none; background: none; color: #0284c7; cursor: pointer; font-weight: bold; padding: 0 2px; font-size: 14px;" title="Xóa bộ lọc">&times;</button>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>
                </form>

                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div class="card-header card-header-flex">
                        <h2 class="card-title"
                            style="font-size: 16px; display: flex; align-items: center; gap: 8px;"><i
                                class="fas fa-users" style="color: var(--color-primary);"></i> Danh sách
                            khách hàng</h2>
                    </div>

                    <div class="table-container table-responsive">
                        <table class="table">
                            <thead style="background: #f8fafc;">
                                <tr>
                                    <th style="width: 60px; color: var(--color-text-secondary); font-weight: 600; text-transform: none;">ID</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Tên công ty</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Mã số thuế</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Ngành nghề</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Quy mô</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Người sở hữu</th>
                                    <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Trạng thái</th>
                                    <th style="width: 170px; color: var(--color-text-secondary); font-weight: 600; text-transform: none; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty list}">
                                        <c:forEach var="item" items="${list}">
                                            <tr style="height: 64px;">
                                                <td style="color: var(--color-text-secondary);">${item.customerId}</td>
                                                <td>
                                                    <div style="font-weight: 500; color: var(--color-gray-900); display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
                                                        <c:out value="${item.customerName}" />
                                                        <c:if test="${item.riskFlag}">
                                                            <span class="badge" style="background:#fee2e2; color:#dc2626; border:1px solid #fca5a5; padding:2px 6px; border-radius:12px; font-size:11px; font-weight:600;" title="<c:out value='${item.riskReason}'/>">
                                                                <i class="fas fa-exclamation-triangle"></i> Rủi ro rời bỏ
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                </td>
                                                <td><c:out value="${item.taxCode}" /></td>
                                                <td><c:out value="${item.industry}" /></td>
                                                <td><c:out value="${item.size}" /></td>
                                                <td><c:out value="${not empty item.ownerName ? item.ownerName : item.ownerId}" /></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.status == 'POTENTIAL' || item.status == 'Tiềm năng' || item.status == 'Ti?m n?ng'}"><span class="badge badge-info" style="color:#0284c7; background:#e0f2fe; padding:2px 8px; border-radius:12px; font-size:12px;">Tiềm năng</span></c:when>
                                                        <c:when test="${item.status == 'DEALING' || item.status == 'Đang giao dịch'}"><span class="badge badge-warning" style="color:#ca8a04; background:#fef08a; padding:2px 8px; border-radius:12px; font-size:12px;">Đang giao dịch</span></c:when>
                                                        <c:when test="${item.status == 'CUSTOMER' || item.status == 'Khách hàng'}"><span class="badge badge-success" style="color:#16a34a; background:#dcfce7; padding:2px 8px; border-radius:12px; font-size:12px;">Khách hàng</span></c:when>
                                                         <c:when test="${item.status == 'ACTIVE' || item.status == 'Hoạt động'}"><span class="badge badge-success" style="color:#059669; background:#d1fae5; padding:2px 8px; border-radius:12px; font-size:12px;">Hoạt động</span></c:when>
                                                        <c:when test="${item.status == 'STOPPED' || item.status == 'Ngừng hợp tác'}"><span class="badge badge-secondary" style="color:#4b5563; background:#f3f4f6; padding:2px 8px; border-radius:12px; font-size:12px;">Ngừng hợp tác</span></c:when>
                                                        <c:otherwise><span class="badge"><c:out value="${item.status}" /></span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <a href="${pageContext.request.contextPath}/customers/360?id=${item.customerId}"
                                                        class="btn btn-secondary"
                                                        style="background: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; padding: 4px 8px; font-size: 13px;"
                                                        title="Xem trang Customer 360"><i class="fas fa-user-check"></i> 360°</a>
                                                    <a href="${pageContext.request.contextPath}/customers/detail?id=${item.customerId}"
                                                        class="btn btn-secondary"
                                                        style="background: white; border: 1px solid var(--color-border); padding: 4px 8px; font-size: 13px;"
                                                        title="Xem chi tiết"><i class="fas fa-eye"></i></a>
                                                    <a href="${pageContext.request.contextPath}/customers/merge?primaryId=${item.customerId}"
                                                        class="btn btn-secondary"
                                                        style="background: white; border: 1px solid var(--color-border); padding: 4px 8px; font-size: 13px;"
                                                        title="Gộp khách hàng"><i class="fas fa-compress-alt"></i></a>
                                                    <a href="${pageContext.request.contextPath}/customers/edit?id=${item.customerId}"
                                                        class="btn btn-secondary"
                                                        style="background: white; border: 1px solid var(--color-border); padding: 4px 8px; font-size: 13px;"
                                                        title="Sửa"><i class="fas fa-edit"></i></a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8">
                                                <div class="empty-state">
                                                    <div class="empty-state-icon"><i class="fas fa-users-slash"></i></div>
                                                    <c:choose>
                                                        <c:when test="${not empty keyword or not empty status or not empty industry or not empty companySize or not empty region or not empty ownerId}">
                                                            <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Không tìm thấy khách hàng</h3>
                                                            <p>Không có kết quả phù hợp với bộ điều kiện tìm kiếm và lọc hiện tại.</p>
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
                        <div class="card-footer"
                            style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--color-border); padding: 12px 24px;">
                            <span style="color: var(--color-text-secondary); font-size: 13px;">Trang ${currentPage} / ${totalPages}</span>
                            <ul class="pagination"
                                style="margin: 0; display: flex; gap: 4px; list-style: none; padding: 0;">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link btn btn-secondary inactive-link"
                                        style="padding: 4px 12px;"
                                        href="?page=${currentPage - 1}&keyword=<c:out value='${keyword}'/>&status=<c:out value='${status}'/>&industry=<c:out value='${industry}'/>&companySize=<c:out value='${companySize}'/>&region=<c:out value='${region}'/>&ownerId=${ownerId}&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>">‹ Trước</a>
                                </li>
                                <c:forEach begin="${currentPage - 2 > 1 ? currentPage - 2 : 1}"
                                    end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link btn ${currentPage == i ? 'btn-primary' : 'btn-secondary inactive-link'}"
                                            style="padding: 4px 12px;"
                                            href="?page=${i}&keyword=<c:out value='${keyword}'/>&status=<c:out value='${status}'/>&industry=<c:out value='${industry}'/>&companySize=<c:out value='${companySize}'/>&region=<c:out value='${region}'/>&ownerId=${ownerId}&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link btn btn-secondary inactive-link"
                                        style="padding: 4px 12px;"
                                        href="?page=${currentPage + 1}&keyword=<c:out value='${keyword}'/>&status=<c:out value='${status}'/>&industry=<c:out value='${industry}'/>&companySize=<c:out value='${companySize}'/>&region=<c:out value='${region}'/>&ownerId=${ownerId}&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>">Sau ›</a>
                                </li>
                            </ul>
                        </div>
                    </c:if>
                </div>
            </div>
        </main>
    </div>

    <!-- Modal Save Filter -->
    <div id="saveFilterModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 2000; align-items: center; justify-content: center;">
        <div class="modal-content" style="background: white; border-radius: 8px; width: 100%; max-width: 440px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0; font-size: 17px; color: var(--color-gray-900);"><i class="fas fa-bookmark" style="color: var(--color-primary);"></i> Lưu bộ lọc hiện tại</h3>
                <button type="button" onclick="closeSaveFilterModal()" style="border: none; background: none; font-size: 20px; cursor: pointer;">&times;</button>
            </div>
            <form id="saveFilterForm" onsubmit="saveCurrentFilter(event)">
                <div class="form-group" style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên bộ lọc <span style="color:red;">*</span></label>
                    <input type="text" id="filterNameInput" name="filterName" class="form-control" required placeholder="Ví dụ: Khách CNTT Miền Bắc" style="width: 100%; padding: 8px 12px; border: 1px solid var(--color-border); border-radius: 6px;">
                </div>
                <div style="background: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 20px; font-size: 13px;">
                    <strong style="color: #334155;">Các điều kiện sẽ lưu:</strong>
                    <ul style="margin: 6px 0 0 16px; padding: 0; color: #64748b;">
                        <li>Từ khóa: <span id="summaryKeyword">--</span></li>
                        <li>Trạng thái: <span id="summaryStatus">--</span></li>
                        <li>Ngành nghề: <span id="summaryIndustry">--</span></li>
                        <li>Quy mô: <span id="summarySize">--</span></li>
                        <li>Khu vực: <span id="summaryRegion">--</span></li>
                        <li>Người sở hữu: <span id="summaryOwner">--</span></li>
                    </ul>
                </div>
                <div style="display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" onclick="closeSaveFilterModal()" class="btn btn-secondary" style="padding: 8px 16px;">Hủy</button>
                    <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Lưu bộ lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Create Customer -->
    <div id="customerModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 2000; align-items: center; justify-content: center;">
        <div class="modal-content" style="background: white; border-radius: 8px; width: 100%; max-width: 520px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="margin: 0; font-size: 18px;">Thêm mới khách hàng</h3>
                <button onclick="closeCustomerModal()" style="border: none; background: none; font-size: 20px; cursor: pointer;">&times;</button>
            </div>
            <form id="customerForm" onsubmit="saveCustomer(event)">
                <div class="form-group" style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên khách hàng <span style="color:red;">*</span></label>
                    <input type="text" id="custName" name="customerName" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                </div>
                <div class="form-group" style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 6px; font-weight: 500;">Số điện thoại</label>
                    <input type="text" id="custPhone" name="phone" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                </div>

                <!-- Dynamic Custom Fields -->
                <c:if test="${not empty customFieldDefinitions}">
                    <div style="border-top: 1px solid var(--color-border); padding-top: 12px; margin-top: 12px;">
                        <h4 style="font-size: 14px; margin-bottom: 12px; color: var(--color-primary);">Trường tùy chỉnh (Custom Fields)</h4>
                        <c:forEach var="def" items="${customFieldDefinitions}">
                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">
                                    <c:out value="${def.fieldLabel}"/>
                                    <c:if test="${def.required}"><span style="color:red;"> *</span></c:if>
                                </label>
                                <c:choose>
                                    <c:when test="${def.fieldType == 'SELECT'}">
                                        <select name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                            <option value="">-- Chọn --</option>
                                            <c:forEach var="opt" items="${def.options.split('[,;\\\\n]+')}">
                                                <option value="${opt.trim()}"><c:out value="${opt.trim()}"/></option>
                                            </c:forEach>
                                        </select>
                                    </c:when>
                                    <c:when test="${def.fieldType == 'DATE'}">
                                        <input type="date" name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    </c:when>
                                    <c:when test="${def.fieldType == 'NUMBER'}">
                                        <input type="number" step="any" name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    </c:when>
                                    <c:otherwise>
                                        <input type="text" name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 20px;">
                    <button type="button" onclick="closeCustomerModal()" class="btn btn-secondary" style="padding: 8px 16px;">Hủy</button>
                    <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Lưu khách hàng</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function applySavedFilter(kw, status, industry, companySize, region, ownerId) {
            const form = document.getElementById('filterForm');
            form.querySelector('[name="keyword"]').value = kw || '';
            form.querySelector('[name="status"]').value = status || '';
            form.querySelector('[name="industry"]').value = industry || '';
            form.querySelector('[name="companySize"]').value = companySize || '';
            form.querySelector('[name="region"]').value = region || '';
            form.querySelector('[name="ownerId"]').value = (ownerId && ownerId !== 'null') ? ownerId : '';
            form.submit();
        }

        function deleteSavedFilter(e, filterId) {
            e.stopPropagation();
            if (!confirm('Bạn có chắc chắn muốn xóa bộ lọc này?')) return;

            const params = new URLSearchParams();
            params.append('action', 'delete');
            params.append('filterId', filterId);

            fetch('${pageContext.request.contextPath}/customers/filters', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    window.location.reload();
                } else {
                    alert('Lỗi: ' + (data.message || 'Không thể xóa bộ lọc.'));
                }
            })
            .catch(() => alert('Lỗi kết nối máy chủ.'));
        }

        function openSaveFilterModal() {
            const form = document.getElementById('filterForm');
            const kw = form.querySelector('[name="keyword"]').value.trim();
            const status = form.querySelector('[name="status"]').value;
            const industry = form.querySelector('[name="industry"]').value;
            const size = form.querySelector('[name="companySize"]').value;
            const region = form.querySelector('[name="region"]').value;
            const ownerSelect = form.querySelector('[name="ownerId"]');
            const ownerText = ownerSelect.options[ownerSelect.selectedIndex] ? ownerSelect.options[ownerSelect.selectedIndex].text : '';

            document.getElementById('summaryKeyword').innerText = kw || '(Tất cả)';
            document.getElementById('summaryStatus').innerText = status || '(Tất cả)';
            document.getElementById('summaryIndustry').innerText = industry || '(Tất cả)';
            document.getElementById('summarySize').innerText = size || '(Tất cả)';
            document.getElementById('summaryRegion').innerText = region || '(Tất cả)';
            document.getElementById('summaryOwner').innerText = (ownerSelect.value ? ownerText : '(Tất cả)');

            document.getElementById('filterNameInput').value = '';
            document.getElementById('saveFilterModal').style.display = 'flex';
        }

        function closeSaveFilterModal() {
            document.getElementById('saveFilterModal').style.display = 'none';
        }

        function saveCurrentFilter(e) {
            e.preventDefault();
            const filterName = document.getElementById('filterNameInput').value.trim();
            if (!filterName) {
                alert('Vui lòng nhập tên bộ lọc.');
                return;
            }

            const filterForm = document.getElementById('filterForm');
            const params = new URLSearchParams();
            params.append('filterName', filterName);
            params.append('keyword', filterForm.querySelector('[name="keyword"]').value);
            params.append('status', filterForm.querySelector('[name="status"]').value);
            params.append('industry', filterForm.querySelector('[name="industry"]').value);
            params.append('companySize', filterForm.querySelector('[name="companySize"]').value);
            params.append('region', filterForm.querySelector('[name="region"]').value);
            params.append('ownerId', filterForm.querySelector('[name="ownerId"]').value);

            fetch('${pageContext.request.contextPath}/customers/filters', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    closeSaveFilterModal();
                    filterForm.submit();
                } else {
                    alert('Lỗi: ' + (data.message || 'Không thể lưu bộ lọc.'));
                }
            })
            .catch(() => alert('Lỗi kết nối máy chủ.'));
        }

        function openCustomerModal() {
            document.getElementById('customerForm').reset();
            document.getElementById('customerModal').style.display = 'flex';
        }

        function closeCustomerModal() {
            document.getElementById('customerModal').style.display = 'none';
        }

        function saveCustomer(e) {
            e.preventDefault();
            const form = document.getElementById('customerForm');
            const formData = new FormData(form);
            const params = new URLSearchParams(formData);

            fetch('${pageContext.request.contextPath}/customers/create', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: params
            })
            .then(async res => {
                const data = await res.json();
                if (!res.ok) {
                    alert('Lỗi: ' + (data.error || 'Thao tác không hợp lệ') + (data.details ? '\n- ' + data.details.join('\n- ') : ''));
                } else {
                    closeCustomerModal();
                    window.location.reload();
                }
            })
            .catch(err => alert('Lỗi kết nối máy chủ.'));
        }
    </script>
</body>
</html>
