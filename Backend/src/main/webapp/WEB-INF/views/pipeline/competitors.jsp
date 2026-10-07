<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Đối thủ Cạnh tranh | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
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
                <span class="breadcrumb-current">Đối thủ Cạnh tranh</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Quản lý Đối thủ Cạnh tranh (S2-10)</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Khai báo danh sách đối thủ cạnh tranh trên thị trường để theo dõi khi cơ hội thất bại.</p>
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
                    <i class="fas fa-exclamation-triangle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
                <!-- Form tạo/sửa đối thủ -->
                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                    <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 16px 20px;">
                        <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-user-ninja" style="color: var(--color-primary);"></i> <span id="formTitle">Thêm mới Đối thủ</span>
                        </h2>
                    </div>
                    <div class="card-body" style="padding: 20px;">
                        <form action="${pageContext.request.contextPath}/pipeline/competitors" method="POST" id="compForm">
                            <input type="hidden" name="action" id="compAction" value="CREATE">
                            <input type="hidden" name="competitorId" id="competitorId" value="">

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên Đối thủ <span style="color:red;">*</span></label>
                                <input type="text" name="competitorName" id="competitorName" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" placeholder="Ví dụ: Công ty Phần mềm Alpha...">
                            </div>

                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Trạng thái</label>
                                <select name="status" id="compStatus" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    <option value="ACTIVE">ACTIVE (Hoạt động)</option>
                                    <option value="INACTIVE">INACTIVE (Tạm ngưng)</option>
                                </select>
                            </div>

                            <div style="display: flex; gap: 8px;">
                                <button type="submit" class="btn btn-primary" style="flex: 1; padding: 10px;"><i class="fas fa-save"></i> Lưu Đối thủ</button>
                                <button type="button" onclick="resetForm()" class="btn btn-secondary" style="padding: 10px; background: white; border: 1px solid var(--color-border);">Hủy</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Danh sách đối thủ -->
                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 16px 20px;">
                        <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-building" style="color: var(--color-primary);"></i> Danh sách Đối thủ Cạnh tranh
                        </h2>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <div class="table-responsive">
                            <table class="table" style="width: 100%; border-collapse: collapse;">
                                <thead style="background: #f8fafc;">
                                    <tr>
                                        <th style="padding: 12px 16px; width: 60px; text-align: center;">ID</th>
                                        <th style="padding: 12px 16px;">Tên Đối thủ Cạnh tranh</th>
                                        <th style="padding: 12px 16px; text-align: center; width: 120px;">Trạng thái</th>
                                        <th style="padding: 12px 16px; text-align: center; width: 100px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${competitors}">
                                        <tr style="border-bottom: 1px solid var(--color-border);">
                                            <td style="padding: 12px 16px; text-align: center; font-weight: 600;">${c.competitorId}</td>
                                            <td style="padding: 12px 16px;"><strong style="color: var(--color-gray-900);"><c:out value="${c.competitorName}"/></strong></td>
                                            <td style="padding: 12px 16px; text-align: center;">
                                                <span class="badge ${c.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}" style="padding: 4px 8px; border-radius: 4px; font-size: 12px; background: ${c.status == 'ACTIVE' ? '#dcfce7' : '#f1f5f9'}; color: ${c.status == 'ACTIVE' ? '#166534' : '#475569'};">
                                                    <c:out value="${c.status}"/>
                                                </span>
                                            </td>
                                            <td style="padding: 12px 16px; text-align: center;">
                                                <button onclick="editCompetitor(${c.competitorId}, '<c:out value="${c.competitorName}"/>', '${c.status}')" class="btn btn-secondary" style="padding: 4px 10px; font-size: 12px; background: white; border: 1px solid var(--color-border);"><i class="fas fa-edit"></i> Sửa</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty competitors}">
                                        <tr>
                                            <td colspan="4" style="padding: 32px; text-align: center; color: var(--color-text-secondary);">Chưa có đối thủ cạnh tranh nào.</td>
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
    function editCompetitor(id, name, status) {
        document.getElementById('compAction').value = 'UPDATE';
        document.getElementById('competitorId').value = id;
        document.getElementById('competitorName').value = name;
        document.getElementById('compStatus').value = status;
        document.getElementById('formTitle').innerText = 'Cập nhật Đối thủ ID #' + id;
    }

    function resetForm() {
        document.getElementById('compForm').reset();
        document.getElementById('compAction').value = 'CREATE';
        document.getElementById('competitorId').value = '';
        document.getElementById('formTitle').innerText = 'Thêm mới Đối thủ';
    }
</script>
</body>
</html>
