<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cơ cấu Tổ chức | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div class="page-header" style="margin-bottom: 1rem;">
                <h1 class="page-title">Cơ cấu Tổ chức Kinh doanh</h1>
                <p class="page-description">Khai báo và quản lý các nhóm bán hàng, khu vực.</p>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <!-- Danh sách nhóm kinh doanh -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Danh sách nhóm kinh doanh</h2>
                    </div>
                    <div class="card-body table-container">
                        <table class="table" style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên nhóm</th>
                                    <th>Trưởng nhóm</th>
                                    <th>Khu vực</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${teams}">
                                    <tr>
                                        <td>${t.id}</td>
                                        <td><strong><c:out value="${t.name}"/></strong></td>
                                        <td><c:out value="${t.leaderName != null ? t.leaderName : 'Chưa có'}"/></td>
                                        <td><c:out value="${t.region}"/></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty teams}">
                                    <tr>
                                        <td colspan="4" style="text-align: center; color: var(--text-secondary);">Chưa có dữ liệu nhóm kinh doanh.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Form Cập nhật nhóm kinh doanh -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Cập nhật nhóm kinh doanh</h2>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/organization/teams/update" method="POST">
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="teamId">Mã nhóm (ID)</label>
                                <input type="number" id="teamId" name="teamId" class="form-control" style="width: 100%;" placeholder="Để trống nếu tạo mới" min="0" step="1" onkeydown="if(event.key==='-'||event.key==='e'||event.key==='E')event.preventDefault();" oninput="if(this.value < 0) this.value = Math.abs(this.value);">
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="teamName">Tên nhóm (*)</label>
                                <input type="text" id="teamName" name="teamName" class="form-control" style="width: 100%;" required>
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="parentTeamId">Nhóm cha (ID)</label>
                                <input type="number" id="parentTeamId" name="parentTeamId" class="form-control" style="width: 100%;" min="0" step="1" onkeydown="if(event.key==='-'||event.key==='e'||event.key==='E')event.preventDefault();" oninput="if(this.value < 0) this.value = Math.abs(this.value);">
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="leaderId">Trưởng nhóm (ID người dùng)</label>
                                <input type="number" id="leaderId" name="leaderId" class="form-control" style="width: 100%;" min="0" step="1" onkeydown="if(event.key==='-'||event.key==='e'||event.key==='E')event.preventDefault();" oninput="if(this.value < 0) this.value = Math.abs(this.value);">
                            </div>
                            <div class="form-group" style="margin-bottom: 1rem;">
                                <label for="region">Khu vực địa lý</label>
                                <input type="text" id="region" name="region" class="form-control" style="width: 100%;" placeholder="VD: Miền Bắc, Hà Nội...">
                            </div>
                            <button type="submit" class="btn btn-primary" style="width: 100%;">Lưu thay đổi</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
