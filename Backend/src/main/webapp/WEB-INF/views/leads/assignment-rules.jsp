<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Quy tắc Phân bổ Lead | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
    <style>
        .rule-badge-priority {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #eff6ff;
            color: #2563eb;
            font-weight: 700;
            font-size: 13px;
            border: 1px solid #bfdbfe;
        }
        .rule-badge-criterion {
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .crit-region { background: #e0f2fe; color: #0369a1; }
        .crit-industry { background: #fef3c7; color: #b45309; }
        .crit-roundrobin { background: #f3e8ff; color: #7e22ce; }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/leads"><i class="fas fa-user-friends"></i> Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Cấu hình Quy tắc Phân bổ</span>
            </nav>

            <!-- Page Header -->
            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <h1 class="page-title" style="margin: 0;">Quy tắc Phân bổ Lead Tự động</h1>
                        <span class="badge badge-info" style="font-size: 11px;"><i class="fas fa-robot"></i> Tự động hóa</span>
                    </div>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin: 0; line-height: 1.5;">
                        Thiết lập quy tắc phân bổ Lead tới nhân viên phụ trách theo Khu vực, Ngành nghề hoặc Xoay vòng đều (Round-Robin).
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/leads/assignment-queue" class="btn btn-secondary">
                        <i class="fas fa-inbox"></i> Hàng chờ phân bổ
                    </a>
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Danh sách Lead
                    </a>
                </div>
            </div>

            <!-- Global Feedback Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger scoring-notification-banner" style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><c:out value="${errorMessage}"/></span>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success scoring-notification-banner" style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-check-circle"></i>
                        <span><c:out value="${successMessage}"/></span>
                    </div>
                </div>
            </c:if>

            <div class="scoring-grid" style="grid-template-columns: 1fr;">
                <!-- Card Danh sách và Form thêm quy tắc -->
                <div class="scoring-card">
                    <div class="scoring-card-header">
                        <div>
                            <h2 class="scoring-card-title">
                                <i class="fas fa-network-wired" style="color: var(--color-primary);"></i>
                                Khai báo Quy tắc Phân bổ (Priority Engine)
                            </h2>
                            <div class="scoring-card-subtitle">
                                Quy tắc có Thứ tự ưu tiên (Priority) nhỏ hơn sẽ được khớp trước. Lead không khớp quy tắc nào sẽ đưa vào Hàng chờ (QUEUED).
                            </div>
                        </div>
                    </div>

                    <!-- Form nhập quy tắc phân bổ -->
                    <div class="rule-form-container">
                        <div class="rule-form-header">
                            <span class="rule-form-header-title">
                                <i class="fas fa-plus-circle" style="color: var(--color-primary);"></i>
                                Thêm mới quy tắc phân bổ
                            </span>
                        </div>

                        <form id="assignmentRuleForm" method="post" action="${pageContext.request.contextPath}/lead-assignment/rules" accept-charset="UTF-8">
                            <input type="hidden" name="ruleId" value="">
                            <div class="rule-form-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
                                <div class="rule-form-field">
                                    <label class="form-label">
                                        Tên quy tắc <span style="color:red">*</span>
                                    </label>
                                    <input type="text" name="ruleName" class="form-control" placeholder="VD: Phân bổ Lead miền Nam" required>
                                </div>

                                <div class="rule-form-field">
                                    <label class="form-label">
                                        Thứ tự ưu tiên <span style="color:red">*</span>
                                    </label>
                                    <input type="number" name="priority" class="form-control" value="1" min="1" max="999" required title="Số nhỏ hơn được ưu tiên trước (1 là cao nhất)">
                                </div>

                                <div class="rule-form-field">
                                    <label class="form-label" for="assignCriterionSelect">
                                        Tiêu chí phân bổ <span style="color:red">*</span>
                                    </label>
                                    <select id="assignCriterionSelect" name="criterion" class="form-control" required onchange="onCriterionChanged()">
                                        <option value="REGION">Theo Khu vực (REGION)</option>
                                        <option value="INDUSTRY">Theo Ngành nghề (INDUSTRY)</option>
                                        <option value="ROUND_ROBIN">Xoay vòng đều (ROUND_ROBIN)</option>
                                    </select>
                                </div>

                                <div class="rule-form-field" id="conditionValueWrapper">
                                    <label class="form-label" id="lblConditionVal">
                                        Giá trị so khớp <span style="color:red">*</span>
                                    </label>
                                    <input type="text" id="assignConditionVal" name="criterionValue" class="form-control" placeholder="VD: Miền Nam, Miền Bắc...">
                                </div>

                                <div class="rule-form-field" id="teamSelectWrapper">
                                    <label class="form-label">
                                        Nhóm kinh doanh (Team)
                                    </label>
                                    <select name="teamId" class="form-control">
                                        <option value="">-- Không chọn --</option>
                                        <c:forEach var="t" items="${teams}">
                                            <option value="${t.teamId}"><c:out value="${t.teamName}"/> (${t.region})</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="rule-form-field" id="assigneeSelectWrapper">
                                    <label class="form-label">
                                        Nhân viên tiếp nhận
                                    </label>
                                    <select name="assigneeId" class="form-control">
                                        <option value="">-- Tự động theo nhóm --</option>
                                        <c:forEach var="u" items="${salesUsers}">
                                            <option value="${u.accountId}"><c:out value="${u.fullName}"/> (${u.roleName})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <div class="rule-form-actions">
                                <button type="reset" class="btn btn-secondary btn-sm" onclick="document.querySelector('#assignmentRuleForm [name=ruleId]').value=''">
                                    <i class="fas fa-redo"></i> Nhập lại
                                </button>
                                <button type="submit" class="btn btn-primary btn-sm">
                                    <i class="fas fa-save"></i> Lưu quy tắc phân bổ
                                </button>
                            </div>
                        </form>
                    </div>

                    <!-- Bảng danh sách quy tắc đang có -->
                    <div class="rule-table-section-title">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span>Danh sách quy tắc phân bổ đang hoạt động</span>
                            <span class="rule-table-count">${not empty rules ? rules.size() : 0} quy tắc</span>
                        </div>
                    </div>

                    <div class="table-container">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 70px; text-align: center;">Ưu tiên</th>
                                    <th>Tên quy tắc</th>
                                    <th>Loại tiêu chí</th>
                                    <th>Điều kiện so khớp</th>
                                    <th>Người nhận / Nhóm</th>
                                    <th style="width: 100px; text-align: center;">Trạng thái</th>
                                    <th style="width: 90px; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty rules}">
                                        <c:forEach var="r" items="${rules}">
                                            <tr>
                                                <td style="text-align: center;">
                                                    <span class="rule-badge-priority" title="Thứ tự ưu tiên #${r.priority}">${r.priority}</span>
                                                </td>
                                                <td>
                                                    <strong><c:out value="${r.ruleName}"/></strong>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.criterion == 'REGION'}">
                                                            <span class="rule-badge-criterion crit-region"><i class="fas fa-map-marker-alt"></i> Khu vực</span>
                                                        </c:when>
                                                        <c:when test="${r.criterion == 'INDUSTRY'}">
                                                            <span class="rule-badge-criterion crit-industry"><i class="fas fa-building"></i> Ngành nghề</span>
                                                        </c:when>
                                                        <c:when test="${r.criterion == 'ROUND_ROBIN'}">
                                                            <span class="rule-badge-criterion crit-roundrobin"><i class="fas fa-rotate"></i> Xoay vòng đều</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-neutral">${r.criterion}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty r.criterionValue}">
                                                            <span class="badge badge-neutral" style="font-weight: 600;"><c:out value="${r.criterionValue}"/></span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #94a3b8; font-style: italic;">Áp dụng toàn bộ trong nhóm</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty r.assigneeName}">
                                                            <div style="font-weight: 500;"><i class="fas fa-user" style="color: #6366f1;"></i> <c:out value="${r.assigneeName}"/></div>
                                                        </c:when>
                                                        <c:when test="${not empty r.assigneeId}">
                                                            <div><i class="fas fa-user" style="color: #6366f1;"></i> Mã NV #${r.assigneeId}</div>
                                                        </c:when>
                                                    </c:choose>
                                                    <c:choose>
                                                        <c:when test="${not empty r.teamName}">
                                                            <div style="font-size: 12px; color: #64748b;"><i class="fas fa-users"></i> <c:out value="${r.teamName}"/></div>
                                                        </c:when>
                                                        <c:when test="${not empty r.teamId}">
                                                            <div style="font-size: 12px; color: #64748b;"><i class="fas fa-users"></i> Nhóm #${r.teamId}</div>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${r.active}">
                                                            <span class="badge badge-success"><i class="fas fa-check"></i> Hoạt động</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-neutral">Tạm ngưng</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <form method="post" action="${pageContext.request.contextPath}/lead-assignment/rules/delete" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa quy tắc phân bổ này?');">
                                                        <input type="hidden" name="ruleId" value="${r.ruleId}">
                                                        <button type="submit" class="btn btn-secondary btn-sm" title="Xóa quy tắc này" style="padding: 4px 8px;">
                                                            <i class="fas fa-trash-alt" style="color: #dc2626;"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" style="text-align: center; padding: 24px; color: #64748b;">
                                                Chưa có quy tắc phân bổ nào. Hãy thêm quy tắc đầu tiên ở trên!
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    function onCriterionChanged() {
        const sel = document.getElementById('assignCriterionSelect').value;
        const valWrapper = document.getElementById('conditionValueWrapper');
        const assigneeWrapper = document.getElementById('assigneeSelectWrapper');
        const teamWrapper = document.getElementById('teamSelectWrapper');
        const valInput = document.getElementById('assignConditionVal');

        if (sel === 'ROUND_ROBIN') {
            valWrapper.style.display = 'none';
            valInput.removeAttribute('required');
            assigneeWrapper.style.display = 'none';
            teamWrapper.style.display = 'block';
            teamWrapper.querySelector('select').setAttribute('required', 'required');
        } else if (sel === 'REGION') {
            valWrapper.style.display = 'block';
            valInput.setAttribute('required', 'required');
            valInput.placeholder = 'VD: Miền Bắc, Miền Nam, Miền Trung...';
            assigneeWrapper.style.display = 'block';
            teamWrapper.style.display = 'block';
            teamWrapper.querySelector('select').removeAttribute('required');
        } else if (sel === 'INDUSTRY') {
            valWrapper.style.display = 'block';
            valInput.setAttribute('required', 'required');
            valInput.placeholder = 'VD: Công nghệ thông tin, Bất động sản...';
            assigneeWrapper.style.display = 'block';
            teamWrapper.style.display = 'block';
            teamWrapper.querySelector('select').removeAttribute('required');
        }
    }
    document.addEventListener('DOMContentLoaded', onCriterionChanged);
</script>
</body>
</html>
