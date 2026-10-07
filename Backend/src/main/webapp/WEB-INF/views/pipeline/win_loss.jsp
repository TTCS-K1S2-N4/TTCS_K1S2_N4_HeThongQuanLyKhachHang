<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Lý do Thắng / Thua | CRM</title>
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
                <span class="breadcrumb-current">Lý do Thắng/Thua</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Cấu hình Lý do Thắng / Thua (S2-10)</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Danh sách lý do thắng và lý do thua được quản lý tách biệt 100% trong CSDL.</p>
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
                    <i class="fas fa-exclamation-triangle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
                <!-- Form tạo/sửa lý do -->
                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                    <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 16px 20px;">
                        <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-edit" style="color: var(--color-primary);"></i> <span id="formTitle">Thêm mới Lý do</span>
                        </h2>
                    </div>
                    <div class="card-body" style="padding: 20px;">
                        <form action="${pageContext.request.contextPath}/pipeline/win-loss-reasons" method="POST" id="reasonForm">
                            <input type="hidden" name="action" id="reasonAction" value="CREATE">
                            <input type="hidden" name="reasonId" id="reasonId" value="">

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Phân loại Danh mục <span style="color:red;">*</span></label>
                                <select name="reasonType" id="reasonType" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    <option value="WIN">WIN (Lý do Thắng cơ hội)</option>
                                    <option value="LOSS">LOSS (Lý do Thua cơ hội)</option>
                                </select>
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên Lý do <span style="color:red;">*</span></label>
                                <input type="text" name="reasonName" id="reasonName" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" placeholder="Ví dụ: Giá cả cạnh tranh, Ngân sách hẹp...">
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Thứ tự hiển thị</label>
                                <input type="number" name="displayOrder" id="displayOrder" class="form-control" min="0" value="1" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                            </div>

                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Trạng thái</label>
                                <select name="status" id="reasonStatus" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    <option value="ACTIVE">ACTIVE (Hoạt động)</option>
                                    <option value="INACTIVE">INACTIVE (Tạm ngưng)</option>
                                </select>
                            </div>

                            <div style="display: flex; gap: 8px;">
                                <button type="submit" class="btn btn-primary" style="flex: 1; padding: 10px;"><i class="fas fa-save"></i> Lưu Lý do</button>
                                <button type="button" onclick="resetForm()" class="btn btn-secondary" style="padding: 10px; background: white; border: 1px solid var(--color-border);">Hủy</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Danh sách lý do tách biệt -->
                <div>
                    <!-- Section Win Reasons -->
                    <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 24px;">
                        <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 14px 20px; background: #f0fdf4;">
                            <h2 class="card-title" style="font-size: 15px; margin: 0; color: #166534; display: flex; align-items: center; gap: 8px;">
                                <i class="fas fa-trophy"></i> Danh sách Lý do THẮNG (WIN REASONS)
                            </h2>
                        </div>
                        <div class="card-body" style="padding: 0;">
                            <table class="table" style="width: 100%; border-collapse: collapse;">
                                <thead style="background: #f8fafc;">
                                    <tr>
                                        <th style="padding: 10px 16px; width: 60px; text-align: center;">ID</th>
                                        <th style="padding: 10px 16px;">Tên Lý do</th>
                                        <th style="padding: 10px 16px; text-align: center; width: 80px;">Thứ tự</th>
                                        <th style="padding: 10px 16px; text-align: center; width: 100px;">Trạng thái</th>
                                        <th style="padding: 10px 16px; text-align: center; width: 80px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="w" items="${winReasons}">
                                        <tr style="border-bottom: 1px solid var(--color-border);">
                                            <td style="padding: 10px 16px; text-align: center;">${w.reasonId}</td>
                                            <td style="padding: 10px 16px;"><strong style="color: #15803d;"><c:out value="${w.reasonName}"/></strong></td>
                                            <td style="padding: 10px 16px; text-align: center;">${w.displayOrder}</td>
                                            <td style="padding: 10px 16px; text-align: center;">
                                                <span class="badge" style="padding: 2px 8px; border-radius: 4px; font-size: 12px; background: #dcfce7; color: #166534;"><c:out value="${w.status}"/></span>
                                            </td>
                                            <td style="padding: 10px 16px; text-align: center;">
                                                <button onclick="editReason(${w.reasonId}, 'WIN', '<c:out value="${w.reasonName}"/>', ${w.displayOrder}, '${w.status}')" class="btn btn-secondary" style="padding: 4px 8px; font-size: 12px; background: white; border: 1px solid var(--color-border);"><i class="fas fa-edit"></i> Sửa</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty winReasons}">
                                        <tr><td colspan="5" style="padding: 20px; text-align: center; color: var(--color-text-secondary);">Chưa có lý do thắng nào.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Section Loss Reasons -->
                    <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 14px 20px; background: #fef2f2;">
                            <h2 class="card-title" style="font-size: 15px; margin: 0; color: #991b1b; display: flex; align-items: center; gap: 8px;">
                                <i class="fas fa-times-circle"></i> Danh sách Lý do THUA (LOSS REASONS)
                            </h2>
                        </div>
                        <div class="card-body" style="padding: 0;">
                            <table class="table" style="width: 100%; border-collapse: collapse;">
                                <thead style="background: #f8fafc;">
                                    <tr>
                                        <th style="padding: 10px 16px; width: 60px; text-align: center;">ID</th>
                                        <th style="padding: 10px 16px;">Tên Lý do</th>
                                        <th style="padding: 10px 16px; text-align: center; width: 80px;">Thứ tự</th>
                                        <th style="padding: 10px 16px; text-align: center; width: 100px;">Trạng thái</th>
                                        <th style="padding: 10px 16px; text-align: center; width: 80px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="l" items="${lossReasons}">
                                        <tr style="border-bottom: 1px solid var(--color-border);">
                                            <td style="padding: 10px 16px; text-align: center;">${l.reasonId}</td>
                                            <td style="padding: 10px 16px;"><strong style="color: #b91c1c;"><c:out value="${l.reasonName}"/></strong></td>
                                            <td style="padding: 10px 16px; text-align: center;">${l.displayOrder}</td>
                                            <td style="padding: 10px 16px; text-align: center;">
                                                <span class="badge" style="padding: 2px 8px; border-radius: 4px; font-size: 12px; background: #fee2e2; color: #991b1b;"><c:out value="${l.status}"/></span>
                                            </td>
                                            <td style="padding: 10px 16px; text-align: center;">
                                                <button onclick="editReason(${l.reasonId}, 'LOSS', '<c:out value="${l.reasonName}"/>', ${l.displayOrder}, '${l.status}')" class="btn btn-secondary" style="padding: 4px 8px; font-size: 12px; background: white; border: 1px solid var(--color-border);"><i class="fas fa-edit"></i> Sửa</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty lossReasons}">
                                        <tr><td colspan="5" style="padding: 20px; text-align: center; color: var(--color-text-secondary);">Chưa có lý do thua nào.</td></tr>
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
    function editReason(id, type, name, order, status) {
        document.getElementById('reasonAction').value = 'UPDATE';
        document.getElementById('reasonId').value = id;
        document.getElementById('reasonType').value = type;
        document.getElementById('reasonName').value = name;
        document.getElementById('displayOrder').value = order;
        document.getElementById('reasonStatus').value = status;
        document.getElementById('formTitle').innerText = 'Cập nhật Lý do ID #' + id;
    }

    function resetForm() {
        document.getElementById('reasonForm').reset();
        document.getElementById('reasonAction').value = 'CREATE';
        document.getElementById('reasonId').value = '';
        document.getElementById('formTitle').innerText = 'Thêm mới Lý do';
    }
</script>
</body>
</html>
