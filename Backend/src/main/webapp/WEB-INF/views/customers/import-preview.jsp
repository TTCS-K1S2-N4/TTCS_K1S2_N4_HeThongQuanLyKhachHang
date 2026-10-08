<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Preview Import Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .badge-duplicate { background-color: #f59e0b; color: #fff; }
        .badge-valid { background-color: #10b981; color: #fff; }
        .badge-error { background-color: #ef4444; color: #fff; }
        .preview-table-container {
            max-height: 500px;
            overflow-y: auto;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            margin-top: 20px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h1 class="page-title" style="margin: 0;">Kết quả phân tích & Xem trước Import Khách hàng</h1>
                <a href="${pageContext.request.contextPath}/customers" class="btn btn-secondary" style="background: white; border: 1px solid #cbd5e1; padding: 8px 16px; border-radius: 6px; color: #334155; text-decoration: none; font-weight: 500; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách khách hàng
                </a>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger mb-3"><c:out value="${errorMessage}"/></div>
            </c:if>

            <c:if test="${executed}">
                <div class="card mb-4" style="border: 2px solid #10b981; background: #f0fdf4;">
                    <div class="card-header bg-success text-white">
                        <h4 style="margin: 0;"><i class="fa-solid fa-square-check"></i> BÁO CÁO KẾT QUẢ THỰC THI IMPORT</h4>
                    </div>
                    <div class="card-body">
                        <p class="fs-5"><strong><c:out value="${message}"/></strong></p>
                        <ul>
                            <li>Tổng số dòng phân tích: <strong>${total != null ? total : 0}</strong></li>
                            <li>Thành công: <strong class="text-success">${success != null ? success : 0}</strong> dòng</li>
                            <li>Bỏ qua (Trùng lặp / Lỗi): <strong class="text-warning">${skipped != null ? skipped : 0}</strong> dòng</li>
                            <li>Thất bại do lỗi DB / Validate: <strong class="text-danger">${failed != null ? failed : 0}</strong> dòng</li>
                        </ul>

                        <c:if test="${not empty errors}">
                            <h5 class="text-danger mt-3">Chi tiết thông báo / Lỗi trong quá trình ghi:</h5>
                            <div style="max-height: 200px; overflow-y: auto; background: #fff; border: 1px solid #cbd5e1; padding: 10px; border-radius: 4px;">
                                <ul style="margin: 0; padding-left: 20px;">
                                    <c:forEach var="errText" items="${errors}">
                                        <li class="text-danger"><c:out value="${errText}"/></li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:if>

                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/customers" class="btn btn-primary"><i class="fa-solid fa-list"></i> Quản lý danh sách khách hàng</a>
                            <a href="${pageContext.request.contextPath}/customers/import" class="btn btn-secondary"><i class="fa-solid fa-file-excel"></i> Tiếp tục Import tệp khác</a>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Statistics Overview -->
            <div class="row mb-3">
                <div class="col-md-4">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fa-solid fa-check-circle"></i> Hợp lệ</h5>
                            <p class="card-text fs-4" style="margin: 0;">${validRowsCount != null ? validRowsCount : 0} dòng</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-danger text-white">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fa-solid fa-circle-exclamation"></i> Cú pháp Lỗi</h5>
                            <p class="card-text fs-4" style="margin: 0;">${invalidRowsCount != null ? invalidRowsCount : 0} dòng</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-warning text-dark">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fa-solid fa-clone"></i> Trùng lặp</h5>
                            <p class="card-text fs-4" style="margin: 0;">${duplicateRowsCount != null ? duplicateRowsCount : 0} dòng</p>
                        </div>
                    </div>
                </div>
            </div>

            <c:if test="${not executed}">
                <!-- Execute Form & Controls -->
                <form method="post" action="${pageContext.request.contextPath}/customers/import/execute" style="background: #ffffff; padding: 20px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 20px;">
                    <c:if test="${duplicateRowsCount > 0}">
                        <div class="mb-3" style="max-width: 450px;">
                            <label class="form-label" style="font-weight: bold; color: #1e293b;">
                                <i class="fa-solid fa-gear"></i> Tùy chọn xử lý bản ghi trùng lặp:
                            </label>
                            <select name="duplicateAction" class="form-select" style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 4px;">
                                <option value="SKIP" selected>Bỏ qua các bản ghi trùng lặp (SKIP)</option>
                                <option value="UPDATE">Cập nhật dữ liệu cho bản ghi đã tồn tại (UPDATE)</option>
                            </select>
                            <small class="text-muted" style="display: block; margin-top: 4px;">
                                * Nếu chọn Cập nhật, hệ thống sẽ cập nhật thông tin khách hàng hiện có với các trường mới từ Excel.
                            </small>
                        </div>
                    </c:if>

                    <div class="mb-0">
                        <button type="submit" class="btn btn-primary" style="background-color: #2563eb; color: white; padding: 10px 20px; border: none; border-radius: 4px; font-weight: 500;" ${validRowsCount == 0 && duplicateRowsCount == 0 ? 'disabled' : ''}>
                            <i class="fa-solid fa-cloud-arrow-up"></i> Xác nhận Thực hiện Import
                        </button>
                        <a href="${pageContext.request.contextPath}/customers/import" class="btn btn-secondary" style="margin-left: 10px; padding: 10px 20px; text-decoration: none; border-radius: 4px;">Hủy bỏ / Chọn file khác</a>
                    </div>
                </form>
            </c:if>

            <!-- Detailed Preview Table -->
            <div class="card" style="background: #fff; padding: 20px; border: 1px solid #e2e8f0; border-radius: 6px;">
                <h4 style="margin-top: 0; margin-bottom: 15px; color: #0f172a;"><i class="fa-solid fa-table"></i> Chi tiết bảng xem trước dữ liệu</h4>

                <div class="preview-table-container">
                    <table class="table table-hover table-striped mb-0" style="width: 100%; border-collapse: collapse;">
                        <thead style="background: #f8fafc; sticky-top">
                        <tr style="border-bottom: 2px solid #e2e8f0; text-align: left;">
                            <th style="padding: 10px; width: 60px;">STT</th>
                            <th style="padding: 10px;">Tên khách hàng</th>
                            <th style="padding: 10px;">Số điện thoại</th>
                            <th style="padding: 10px;">Mã số thuế</th>
                            <th style="padding: 10px;">Ngành nghề</th>
                            <th style="padding: 10px;">Website</th>
                            <th style="padding: 10px; width: 120px;">Trạng thái</th>
                            <th style="padding: 10px;">Ghi chú / Chi tiết</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty allRows}">
                                <c:forEach var="row" items="${allRows}">
                                    <tr style="border-bottom: 1px solid #f1f5f9; ${row.duplicate ? 'background-color: #fffbeb;' : (not row.valid ? 'background-color: #fef2f2;' : '')}">
                                        <td style="padding: 10px;">${row.rowIndex}</td>
                                        <td style="padding: 10px; font-weight: 600;"><c:out value="${row.customerName}"/></td>
                                        <td style="padding: 10px;"><c:out value="${not empty row.phone ? row.phone : '---'}"/></td>
                                        <td style="padding: 10px;"><c:out value="${not empty row.taxCode ? row.taxCode : '---'}"/></td>
                                        <td style="padding: 10px;"><c:out value="${not empty row.industry ? row.industry : '---'}"/></td>
                                        <td style="padding: 10px;"><c:out value="${not empty row.website ? row.website : '---'}"/></td>
                                        <td style="padding: 10px;">
                                            <c:choose>
                                                <c:when test="${row.duplicate}">
                                                    <span class="badge badge-duplicate" style="padding: 4px 8px; border-radius: 4px;"><i class="fa-solid fa-clone"></i> Trùng lặp</span>
                                                </c:when>
                                                <c:when test="${not row.valid}">
                                                    <span class="badge badge-error" style="padding: 4px 8px; border-radius: 4px;"><i class="fa-solid fa-circle-exclamation"></i> Lỗi</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-valid" style="padding: 4px 8px; border-radius: 4px;"><i class="fa-solid fa-check"></i> Hợp lệ</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 10px;">
                                            <c:choose>
                                                <c:when test="${row.duplicate}">
                                                    <span style="color: #d97706; font-weight: 500;"><c:out value="${row.duplicateReason}"/></span>
                                                </c:when>
                                                <c:when test="${not row.valid}">
                                                    <span style="color: #dc2626; font-weight: 500;"><c:out value="${row.error}"/></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #16a34a;">Sẵn sàng nhập mới</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 20px; color: #64748b;">
                                        Chưa có dữ liệu preview. Vui lòng tải file Excel từ trang Import.
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
