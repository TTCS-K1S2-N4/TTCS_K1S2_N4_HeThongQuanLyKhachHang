<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Preview Import Khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <h1 class="page-title">Xem trước dữ liệu Import</h1>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="row mb-3">
                <div class="col-md-4">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <h5 class="card-title">Hợp lệ</h5>
                            <p class="card-text fs-4">${validRowsCount != null ? validRowsCount : 0}</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-danger text-white">
                        <div class="card-body">
                            <h5 class="card-title">Lỗi</h5>
                            <p class="card-text fs-4">${invalidRowsCount != null ? invalidRowsCount : 0}</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-warning text-dark">
                        <div class="card-body">
                            <h5 class="card-title">Trùng lặp</h5>
                            <p class="card-text fs-4">${duplicateRowsCount != null ? duplicateRowsCount : 0}</p>
                        </div>
                    </div>
                </div>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/customers/import/execute">
                <input type="hidden" name="token" value="${importToken}">
                
                <c:if test="${duplicateRowsCount > 0}">
                    <div class="mb-3">
                        <label class="form-label">Xử lý dữ liệu trùng lặp:</label>
                        <select name="duplicateAction" class="form-control w-25">
                            <option value="SKIP">Bỏ qua bản ghi trùng</option>
                            <option value="UPDATE">Cập nhật bản ghi trùng</option>
                        </select>
                    </div>
                </c:if>

                <div class="mb-3">
                    <button type="submit" class="btn btn-primary" ${invalidRowsCount > 0 && validRowsCount == 0 ? 'disabled' : ''}>Thực hiện Import</button>
                    <a href="${pageContext.request.contextPath}/customers/import" class="btn btn-secondary">Hủy bỏ</a>
                </div>
            </form>

            <c:if test="${not empty rowErrors}">
                <h4 class="mt-4 text-danger">Chi tiết lỗi</h4>
                <table class="table table-bordered">
                    <thead>
                    <tr>
                        <th>Dòng</th>
                        <th>Nội dung lỗi</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="err" items="${rowErrors}">
                        <tr>
                            <td>${err.rowNumber}</td>
                            <td>${err.message}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>
