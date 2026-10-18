<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
  S4-06: Hàng chờ phân bổ Lead và phân bổ thủ công.
  HỢP ĐỒNG VỚI SERVLET (đối chiếu LeadAssignServlet.java):
  Request attribute khi mở trang
    queue      danh sách Lead chờ phân bổ; dùng getter của Lead/LeadResponse: leadId, fullName, company,
               email, phone, industry, status, ownerName, createdAt. Tùy chọn: matchedRule (thiếu thì hiện "—").
    assignees  tùy chọn: danh sách Account (accountId, fullName) được phép nhận Lead theo Data Scope.
               Không có thì nhập mã nhân viên.
  Gửi đi: POST /leads/assign, application/x-www-form-urlencoded, leadId + assigneeId (servlet đang đọc) + userId (tên theo API Contract).
          Servlet hiện phân quyền bằng header X-User-Role = TEAM_LEADER. Header chỉ được gửi khi tài khoản trong session
          có mã vai trò TEAM_LEAD. Về lâu dài servlet nên tự lấy vai trò từ session, vì header do trình duyệt gửi có thể bị giả mạo.
  Phản hồi: JSON khi thành công; lỗi là HTTP 4xx/5xx. Sau khi thành công trang tải lại để hiển thị dữ liệu thật của Backend.
--%>
<c:set var="dash" value="—"/>
<c:if test="${empty canAssign}">
    <c:set var="canAssign" value="false"/>
    <c:forEach var="rc" items="${sessionScope.currentUser.roleCodes}">
        <c:if test="${rc == 'TEAM_LEAD' or rc == 'ADMIN' or rc == 'DIRECTOR'}"><c:set var="canAssign" value="true"/></c:if>
    </c:forEach>
    <c:if test="${sessionScope.roleId == 1 or sessionScope.roleId == 4 or sessionScope.roleId == 3}">
        <c:set var="canAssign" value="true"/>
    </c:if>
</c:if>
<c:url var="assignUrl" value="/leads/assign"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Hàng chờ phân bổ Lead | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <style>
        .aq-lead-name { font-weight: 600; }
        .aq-sub { display: block; font-size: 0.85rem; color: #64748b; word-break: break-word; }
        .aq-assign { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; min-width: 200px; }
        .aq-assign .form-control { flex: 1 1 130px; min-width: 0; }
        .aq-note { padding: 12px 16px; margin-bottom: 16px; background: #f8fafc; border-left: 4px solid #94a3b8; border-radius: 6px; font-size: 0.9rem; }
        @media (max-width: 480px) {
            .aq-assign { min-width: 160px; }
            .aq-assign .btn { width: 100%; }
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/leads">Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Hàng chờ phân bổ</span>
            </nav>

            <div class="page-header" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Hàng chờ phân bổ Lead</h1>
                    <p class="page-description">Lead không khớp quy tắc phân bổ nào hoặc bị từ chối, chờ trưởng nhóm phân tay.</p>
                </div>
                <div class="page-actions" style="display: flex; gap: 10px; align-items: center;">
                    <a href="${pageContext.request.contextPath}/lead-assignment/rules" class="btn btn-secondary" title="Cấu hình quy tắc phân bổ">
                        <i class="fas fa-sliders-h"></i> Quy tắc phân bổ
                    </a>
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary" title="Quay lại" onclick="if (window.history.length > 1) { window.history.back(); return false; }">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <c:if test="${not canAssign}">
                <p class="aq-note">Bạn đang xem ở chế độ chỉ đọc. Chỉ trưởng nhóm kinh doanh được phân bổ Lead thủ công.</p>
            </c:if>

            <section class="card">
                <div class="table-container table-responsive">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Lead</th>
                            <th>Liên hệ</th>
                            <th>Ngành</th>
                            <th>Trạng thái</th>
                            <th>Người được phân</th>
                            <th>Quy tắc đã khớp</th>
                            <th>Vào hệ thống</th>
                            <c:if test="${canAssign}"><th>Phân bổ thủ công</th></c:if>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty queue}">
                                <c:forEach var="ld" items="${queue}">
                                    <c:remove var="matchedRule"/>
                                    <c:catch var="optErr"><c:set var="matchedRule" value="${ld.matchedRule}"/></c:catch>
                                    <c:url var="detailUrl" value="/leads/detail">
                                        <c:param name="id" value="${ld.leadId}"/>
                                    </c:url>
                                    <tr>
                                        <td>
                                            <a class="aq-lead-name" href="${detailUrl}"><c:out value="${ld.fullName}"/></a>
                                            <c:if test="${not empty ld.company}">
                                                <span class="aq-sub"><c:out value="${ld.company}"/></span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:out value="${empty ld.phone ? dash : ld.phone}"/>
                                            <c:if test="${not empty ld.email}">
                                                <span class="aq-sub"><c:out value="${ld.email}"/></span>
                                            </c:if>
                                        </td>
                                        <td><c:out value="${empty ld.industry ? dash : ld.industry}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ld.status == 'QUEUED'}"><span class="badge badge-warning">Chờ phân bổ</span></c:when>
                                                <c:when test="${ld.status == 'NEW'}"><span class="badge badge-info">Mới</span></c:when>
                                                <c:when test="${ld.status == 'ASSIGNED'}"><span class="badge badge-neutral">Đã phân, chờ phản hồi</span></c:when>
                                                <c:when test="${ld.status == 'IN_PROGRESS'}"><span class="badge badge-success">Đang chăm sóc</span></c:when>
                                                <c:when test="${ld.status == 'OVERDUE'}"><span class="badge badge-danger">Quá SLA</span></c:when>
                                                <c:otherwise><span class="badge badge-neutral"><c:out value="${empty ld.status ? dash : ld.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${empty ld.ownerName ? 'Chưa có' : ld.ownerName}"/></td>
                                        <td><c:out value="${empty matchedRule ? dash : matchedRule}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty ld.createdAt}">
                                                    <fmt:formatDate value="${ld.createdAt}" pattern="dd/MM/yyyy HH:mm" timeZone="Asia/Ho_Chi_Minh"/>
                                                </c:when>
                                                <c:otherwise>${dash}</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <c:if test="${canAssign}">
                                            <td>
                                                <form class="aq-assign js-assign-form" method="post" action="${assignUrl}">
                                                    <input type="hidden" name="leadId" value="<c:out value='${ld.leadId}'/>">
                                                    <c:choose>
                                                        <c:when test="${not empty assignees}">
                                                            <select name="assigneeId" class="form-control" required
                                                                    aria-label="Người nhận Lead ${ld.leadId}">
                                                                <option value="">-- Chọn người nhận --</option>
                                                                <c:forEach var="u" items="${assignees}">
                                                                    <option value="<c:out value='${u.accountId}'/>"><c:out value="${u.fullName}"/></option>
                                                                </c:forEach>
                                                            </select>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <input name="assigneeId" class="form-control" type="number" min="1" step="1" required
                                                                   placeholder="Mã nhân viên" aria-label="Mã nhân viên nhận Lead ${ld.leadId}">
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <button type="submit" class="btn btn-primary btn-sm">Phân bổ</button>
                                                </form>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="${canAssign ? 8 : 7}">
                                        <div class="empty-state">
                                            <p class="empty-state-title">Hàng chờ đang trống.</p>
                                            <p class="empty-state-description">Không có Lead nào đang chờ phân bổ thủ công.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>
</div>

<c:if test="${canAssign}">
    <script>
        (function () {
            var MESSAGES = {
                400: 'Dữ liệu phân bổ không hợp lệ. Hãy kiểm tra Lead và người nhận.',
                401: 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.',
                403: 'Bạn không có quyền phân bổ Lead này.',
                404: 'Lead không còn tồn tại.',
                409: 'Lead đã được phân cho người khác. Trang sẽ được tải lại.'
            };

            function notify(type, message) {
                if (typeof window.showToast === 'function') { window.showToast(type, message); } else { window.alert(message); }
            }

            document.querySelectorAll('.js-assign-form').forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    event.preventDefault();
                    var button = form.querySelector('button[type="submit"]');
                    if (button.disabled) { return; }
                    var body = new URLSearchParams(new FormData(form));
                    // API Contract đặt tên tham số là userId, servlet hiện đọc assigneeId: gửi cả hai với cùng giá trị.
                    body.set('userId', body.get('assigneeId'));
                    button.disabled = true;
                    fetch(form.action, {
                        method: 'POST',
                        credentials: 'same-origin',
                        headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                            'X-User-Role': 'TEAM_LEADER'
                        },
                        body: body.toString()
                    }).then(function (res) {
                        if (res.ok) {
                            notify('success', 'Đã gửi phân bổ Lead. Đang tải lại hàng chờ...');
                            window.setTimeout(function () { window.location.reload(); }, 1200);
                            return;
                        }
                        notify('error', MESSAGES[res.status] || 'Hệ thống gặp lỗi khi phân bổ Lead. Hãy thử lại sau.');
                        if (res.status === 409) {
                            window.setTimeout(function () { window.location.reload(); }, 1500);
                        } else {
                            button.disabled = false;
                        }
                    }).catch(function () {
                        notify('error', 'Không kết nối được máy chủ. Hãy kiểm tra mạng và thử lại.');
                        button.disabled = false;
                    });
                });
            });
        })();
    </script>
</c:if>
</body>
</html>
