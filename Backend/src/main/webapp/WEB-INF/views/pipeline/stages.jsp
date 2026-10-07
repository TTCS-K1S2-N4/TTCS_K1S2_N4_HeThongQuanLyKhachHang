<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Giai đoạn Pipeline | CRM</title>
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
                <span class="breadcrumb-current">Giai đoạn Pipeline</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Cấu hình Giai đoạn Pipeline (S2-09)</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Thiết lập các bước bán hàng, xác suất thành công mặc định và điều kiện chuyển giai đoạn.</p>
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
                    <i class="fas fa-exclamation-triangle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
                <!-- Form tạo/sửa stage -->
                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                    <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 16px 20px;">
                        <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-sliders-h" style="color: var(--color-primary);"></i> <span id="formTitle">Thêm mới Giai đoạn</span>
                        </h2>
                    </div>
                    <div class="card-body" style="padding: 20px;">
                        <form action="${pageContext.request.contextPath}/pipeline/stages" method="POST" id="stageForm">
                            <input type="hidden" name="action" id="stageAction" value="CREATE">
                            <input type="hidden" name="pipelineStageId" id="stageId" value="">

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên giai đoạn <span style="color:red;">*</span></label>
                                <input type="text" name="stageName" id="stageName" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Thứ tự hiển thị <span style="color:red;">*</span></label>
                                <input type="number" name="displayOrder" id="displayOrder" class="form-control" min="0" value="1" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Xác suất mặc định (%) <span style="color:red;">*</span></label>
                                <input type="number" step="0.1" min="0" max="100" name="defaultProbability" id="defaultProbability" class="form-control" value="10" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Điều kiện hoàn thành / chuyển bước</label>
                                <textarea name="exitCondition" id="exitCondition" class="form-control" rows="2" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" placeholder="Ví dụ: Đã xác định người liên hệ chính, Đã gửi báo giá..."></textarea>
                            </div>

                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Trạng thái</label>
                                <select name="status" id="stageStatus" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    <option value="ACTIVE">ACTIVE (Hoạt động)</option>
                                    <option value="INACTIVE">INACTIVE (Tạm ngưng)</option>
                                </select>
                            </div>

                            <div style="display: flex; gap: 8px;">
                                <button type="submit" class="btn btn-primary" style="flex: 1; padding: 10px;"><i class="fas fa-save"></i> Lưu Giai đoạn</button>
                                <button type="button" onclick="resetForm()" class="btn btn-secondary" style="padding: 10px; background: white; border: 1px solid var(--color-border);">Hủy</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Danh sách stage -->
                <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div class="card-header" style="border-bottom: 1px solid var(--color-border); padding: 16px 20px;">
                        <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-list-ol" style="color: var(--color-primary);"></i> Danh sách Giai đoạn Pipeline
                        </h2>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <div class="table-responsive">
                            <table class="table" style="width: 100%; border-collapse: collapse;">
                                <thead style="background: #f8fafc;">
                                    <tr>
                                        <th style="padding: 12px 16px; text-align: center; width: 60px;">Thứ tự</th>
                                        <th style="padding: 12px 16px;">Tên Giai đoạn</th>
                                        <th style="padding: 12px 16px; text-align: center;">Xác suất %</th>
                                        <th style="padding: 12px 16px;">Yêu cầu hoàn thành</th>
                                        <th style="padding: 12px 16px; text-align: center;">Trạng thái</th>
                                        <th style="padding: 12px 16px; text-align: center; width: 100px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="s" items="${pipelineStages}">
                                        <tr style="border-bottom: 1px solid var(--color-border);">
                                            <td style="padding: 12px 16px; text-align: center; font-weight: 600;">${s.displayOrder}</td>
                                            <td style="padding: 12px 16px;">
                                                <strong style="color: var(--color-gray-900);"><c:out value="${s.stageName}"/></strong>
                                            </td>
                                            <td style="padding: 12px 16px; text-align: center;">
                                                <span style="font-weight: 600; color: var(--color-primary);">${s.defaultProbability}%</span>
                                            </td>
                                            <td style="padding: 12px 16px; font-size: 13px; color: var(--color-text-secondary);">
                                                <c:choose>
                                                    <c:when test="${not empty s.exitCondition}"><c:out value="${s.exitCondition}"/></c:when>
                                                    <c:otherwise><span style="color: #cbd5e1;">(Không có)</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="padding: 12px 16px; text-align: center;">
                                                <span class="badge ${s.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}" style="padding: 4px 8px; border-radius: 4px; font-size: 12px; background: ${s.status == 'ACTIVE' ? '#dcfce7' : '#f1f5f9'}; color: ${s.status == 'ACTIVE' ? '#166534' : '#475569'};">
                                                    <c:out value="${s.status}"/>
                                                </span>
                                            </td>
                                            <td style="padding: 12px 16px; text-align: center;">
                                                <button onclick="editStage(${s.pipelineStageId}, '<c:out value="${s.stageName}"/>', ${s.displayOrder}, ${s.defaultProbability}, '<c:out value="${s.exitCondition}"/>', '${s.status}')" class="btn btn-secondary" style="padding: 4px 10px; font-size: 12px; background: white; border: 1px solid var(--color-border);"><i class="fas fa-edit"></i> Sửa</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty pipelineStages}">
                                        <tr>
                                            <td colspan="6" style="padding: 32px; text-align: center; color: var(--color-text-secondary);">Chưa có giai đoạn nào được cấu hình.</td>
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
    function editStage(id, name, order, prob, condition, status) {
        document.getElementById('stageAction').value = 'UPDATE';
        document.getElementById('stageId').value = id;
        document.getElementById('stageName').value = name;
        document.getElementById('displayOrder').value = order;
        document.getElementById('defaultProbability').value = prob;
        document.getElementById('exitCondition').value = condition || '';
        document.getElementById('stageStatus').value = status;
        document.getElementById('formTitle').innerText = 'Cập nhật Giai đoạn ID #' + id;
    }

    function resetForm() {
        document.getElementById('stageForm').reset();
        document.getElementById('stageAction').value = 'CREATE';
        document.getElementById('stageId').value = '';
        document.getElementById('formTitle').innerText = 'Thêm mới Giai đoạn';
    }
</script>
</body>
</html>
