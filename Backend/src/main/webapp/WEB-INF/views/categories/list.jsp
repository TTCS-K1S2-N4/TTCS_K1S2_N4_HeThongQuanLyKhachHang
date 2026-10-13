<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh mục dùng chung | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div class="page-header" style="margin-bottom: 1rem;">
                <h1 class="page-title">Danh mục dùng chung</h1>
                <p class="page-description">Quản lý các danh mục phân loại trong hệ thống.</p>
            </div>

            <c:if test="${not empty errors}">
                <div class="alert alert-danger" style="background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 1rem;">
                    <strong>Đã xảy ra lỗi:</strong>
                    <ul style="margin: 0.5rem 0 0; padding-left: 1.25rem;">
                        <c:forEach var="err" items="${errors}">
                            <li><c:out value="${err}"/></li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>

            <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1rem;">
                <!-- Form cập nhật danh mục -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Cập nhật danh mục</h2>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/categories/update" method="POST">
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="action">Thao tác (*)</label>
                                <select id="action" name="action" class="form-control" style="width: 100%;" required>
                                    <option value="CREATE">Tạo mới (CREATE)</option>
                                    <option value="UPDATE">Cập nhật (UPDATE)</option>
                                    <option value="DEACTIVATE">Vô hiệu hoá (DEACTIVATE)</option>
                                </select>
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="categoryType">Loại danh mục (*)</label>
                                <input type="text" id="categoryType" name="categoryType" value="<c:out value='${categoryType}'/>" class="form-control" style="width: 100%;" required placeholder="VD: INDUSTRY, SOURCE, LEAD_STATUS...">
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="categoryId">Mã danh mục (ID)</label>
                                <input type="number" id="categoryId" name="categoryId" class="form-control" style="width: 100%;" placeholder="Bắt buộc khi Cập nhật / Vô hiệu hóa" min="0" step="1" onkeydown="if(event.key==='-'||event.key==='e'||event.key==='E')event.preventDefault();" oninput="if(this.value < 0) this.value = Math.abs(this.value);">
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="categoryName">Tên danh mục (*)</label>
                                <input type="text" id="categoryName" name="categoryName" class="form-control" style="width: 100%;" required>
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="displayOrder">Thứ tự hiển thị</label>
                                <input type="number" id="displayOrder" name="displayOrder" class="form-control" style="width: 100%;" min="0" step="1" onkeydown="if(event.key==='-'||event.key==='e'||event.key==='E')event.preventDefault();" oninput="if(this.value < 0) this.value = Math.abs(this.value);">
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="status">Trạng thái (status)</label>
                                <select id="status" name="status" class="form-control" style="width: 100%;">
                                    <option value="ACTIVE">ACTIVE</option>
                                    <option value="INACTIVE">INACTIVE</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary" style="width: 100%;">Thực hiện</button>
                        </form>
                    </div>
                </div>

                <!-- Danh sách danh mục -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Danh sách (Filter)</h2>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/categories" method="GET" style="margin-bottom: 1rem; display: flex; gap: 0.5rem;">
                            <input type="text" name="categoryType" value="<c:out value='${categoryType}'/>" class="form-control" placeholder="Lọc theo loại danh mục..." style="flex: 1;">
                            <button type="submit" class="btn btn-secondary">Lọc</button>
                        </form>
                        <div class="table-container">
                            <table class="table" style="width: 100%;">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Loại</th>
                                        <th>Tên danh mục</th>
                                        <th>Thứ tự</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${categories}">
                                        <tr>
                                            <td>${c.categoryId}</td>
                                            <td><c:out value="${c.categoryType}"/></td>
                                            <td><strong><c:out value="${c.categoryName}"/></strong></td>
                                            <td>${c.displayOrder}</td>
                                            <td>
                                                <span class="badge ${c.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}">
                                                    <c:out value="${c.status}"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty categories}">
                                        <tr>
                                            <td colspan="5" style="text-align: center; color: var(--text-secondary);">Chưa có dữ liệu danh mục.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
<script>
    (function() {
        var params = new URLSearchParams(window.location.search);
        var success = params.get('success');
        var handled = false;

        if (success === 'true') {
            if (typeof window.showToast === 'function') {
                window.showToast('success', 'Thao tác danh mục thành công!');
            }
            handled = true;
        }

        <c:if test="${not empty errors}">
            if (typeof window.showToast === 'function') {
                window.showToast('error', 'Vui lòng kiểm tra lại thông tin danh mục.');
            }
        </c:if>

        if (handled && window.history && window.history.replaceState) {
            params.delete('success');
            var remaining = params.toString();
            var newUrl = window.location.pathname + (remaining ? ('?' + remaining) : '') + window.location.hash;
            window.history.replaceState(null, document.title, newUrl);
        }
    })();
</script>
</body>
</html>
