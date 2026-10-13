<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
  S4-07: Nhận / từ chối Lead được phân và hiển thị Lead quá SLA.
  HỢP ĐỒNG VỚI SERVLET (đối chiếu LeadAcceptServlet.java, LeadRejectServlet.java, LeadSlaService.java):
  Request attribute khi mở trang
    leads  danh sách Lead được phân cho người dùng hiện tại, hoặc
    lead   một Lead (theo cách LeadDetailServlet đang đặt tên).
           Dùng getter của Lead/LeadResponse: leadId, fullName, company, email, phone, status, ownerId, ownerName, createdAt.
           Tùy chọn: overdue (boolean). Thiếu thì chỉ dựa vào status = OVERDUE do LeadSlaService gắn.
  Mã trạng thái lấy từ LeadSlaService: ASSIGNED, IN_PROGRESS (Đang chăm sóc), OVERDUE, QUEUED.
  Gửi đi: POST /leads/accept (leadId) và POST /leads/reject (leadId, rejectReason), application/x-www-form-urlencoded.
          Servlet hiện nhận diện người dùng bằng header X-User-Id; giá trị lấy từ sessionScope.userId. Session không có thì
          không gửi header và để servlet trả 401. Về lâu dài servlet nên lấy người dùng từ session phía server,
          vì header do trình duyệt gửi có thể bị giả mạo.
  Phản hồi: JSON khi thành công; lỗi là HTTP 4xx/5xx. Sau khi thành công trang tải lại để hiển thị trạng thái thật của Backend.
--%>
<c:set var="dash" value="—"/>
<c:set var="rows" value="${not empty leads ? leads : (not empty lead ? [lead] : null)}"/>
<c:url var="acceptUrl" value="/leads/accept"/>
<c:url var="rejectUrl" value="/leads/reject"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Lead được phân cho tôi | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <style>
        .ar-list { display: grid; gap: 16px; }
        .ar-card { border-left: 4px solid transparent; }
        .ar-card.ar-overdue { border-left-color: #ef4444; background: #fef2f2; }
        .ar-head { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; justify-content: space-between; }
        .ar-name { font-size: 1.05rem; font-weight: 600; word-break: break-word; }
        .ar-badges { display: flex; flex-wrap: wrap; gap: 6px; }
        .ar-info { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin: 12px 0; }
        .ar-info dt { font-size: 0.8rem; color: #64748b; }
        .ar-info dd { margin: 0; word-break: break-word; }
        .ar-overdue-note { margin: 0 0 12px; color: #b91c1c; font-weight: 500; }
        .ar-actions { display: flex; flex-wrap: wrap; gap: 8px; }
        .ar-actions form { margin: 0; }
        .ar-reject { margin-top: 12px; padding-top: 12px; border-top: 1px solid #e2e8f0; }
        .ar-reject-actions { display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-end; margin-top: 8px; }
        @media (max-width: 480px) {
            .ar-actions .btn, .ar-actions form, .ar-reject-actions .btn { width: 100%; }
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
                <a href="${pageContext.request.contextPath}/leads/list">Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Lead được phân</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Lead được phân cho tôi</h1>
                    <p class="page-description">Nhận Lead để bắt đầu chăm sóc, hoặc từ chối kèm lý do để Lead quay lại hàng chờ phân bổ.</p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty rows}">
                    <section class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <p class="empty-state-title">Chưa có Lead nào được phân cho bạn.</p>
                                <p class="empty-state-description">Lead mới được phân sẽ xuất hiện tại đây để bạn nhận hoặc từ chối.</p>
                            </div>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <div class="ar-list" data-user-id="<c:out value='${sessionScope.userId}'/>" id="arList">
                        <c:forEach var="ld" items="${rows}">
                            <c:remove var="overdueFlag"/>
                            <c:catch var="optErr"><c:set var="overdueFlag" value="${ld.overdue}"/></c:catch>
                            <c:set var="isOverdue" value="${overdueFlag == true or ld.status == 'OVERDUE'}"/>
                            <c:set var="isMine" value="${not empty sessionScope.userId and ld.ownerId == sessionScope.userId}"/>
                            <c:set var="canAccept" value="${isMine and ld.status == 'ASSIGNED'}"/>
                            <c:set var="canReject" value="${isMine and (ld.status == 'ASSIGNED' or ld.status == 'OVERDUE')}"/>
                            <c:url var="detailUrl" value="/leads/detail">
                                <c:param name="id" value="${ld.leadId}"/>
                            </c:url>
                            <section class="card ar-card ${isOverdue ? 'ar-overdue' : ''}">
                                <div class="card-body">
                                    <div class="ar-head">
                                        <a class="ar-name" href="${detailUrl}"><c:out value="${ld.fullName}"/></a>
                                        <div class="ar-badges">
                                            <c:if test="${isOverdue}">
                                                <span class="badge badge-danger"><i class="fas fa-flag"></i> Quá SLA phản hồi</span>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${ld.status == 'ASSIGNED'}"><span class="badge badge-warning">Chờ bạn phản hồi</span></c:when>
                                                <c:when test="${ld.status == 'IN_PROGRESS'}"><span class="badge badge-success">Đang chăm sóc</span></c:when>
                                                <c:when test="${ld.status == 'QUEUED'}"><span class="badge badge-neutral">Chờ phân bổ</span></c:when>
                                                <c:when test="${ld.status == 'OVERDUE'}"></c:when>
                                                <c:otherwise><span class="badge badge-neutral"><c:out value="${empty ld.status ? dash : ld.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <dl class="ar-info">
                                        <div>
                                            <dt>Công ty</dt>
                                            <dd><c:out value="${empty ld.company ? dash : ld.company}"/></dd>
                                        </div>
                                        <div>
                                            <dt>Số điện thoại</dt>
                                            <dd><c:out value="${empty ld.phone ? dash : ld.phone}"/></dd>
                                        </div>
                                        <div>
                                            <dt>Email</dt>
                                            <dd><c:out value="${empty ld.email ? dash : ld.email}"/></dd>
                                        </div>
                                        <div>
                                            <dt>Người phụ trách</dt>
                                            <dd><c:out value="${empty ld.ownerName ? dash : ld.ownerName}"/></dd>
                                        </div>
                                        <div>
                                            <dt>Vào hệ thống</dt>
                                            <dd>
                                                <c:choose>
                                                    <c:when test="${not empty ld.createdAt}">
                                                        <fmt:formatDate value="${ld.createdAt}" pattern="dd/MM/yyyy HH:mm" timeZone="Asia/Ho_Chi_Minh"/>
                                                    </c:when>
                                                    <c:otherwise>${dash}</c:otherwise>
                                                </c:choose>
                                            </dd>
                                        </div>
                                    </dl>

                                    <c:if test="${isOverdue}">
                                        <p class="ar-overdue-note">Lead này đã quá thời hạn phản hồi. Hãy liên hệ khách hàng ngay.</p>
                                    </c:if>

                                    <c:if test="${canAccept or canReject}">
                                        <div class="ar-actions">
                                            <c:if test="${canAccept}">
                                                <form class="js-accept-form" method="post" action="${acceptUrl}">
                                                    <input type="hidden" name="leadId" value="<c:out value='${ld.leadId}'/>">
                                                    <button type="submit" class="btn btn-primary"><i class="fas fa-check"></i> Nhận Lead</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${canReject}">
                                                <button type="button" class="btn btn-secondary js-reject-toggle"
                                                        aria-expanded="false" aria-controls="rejectBox-${ld.leadId}">
                                                    <i class="fas fa-xmark"></i> Từ chối
                                                </button>
                                            </c:if>
                                        </div>

                                        <c:if test="${canReject}">
                                            <form class="ar-reject js-reject-form" id="rejectBox-${ld.leadId}" method="post" action="${rejectUrl}" hidden>
                                                <input type="hidden" name="leadId" value="<c:out value='${ld.leadId}'/>">
                                                <div class="form-group">
                                                    <label class="form-label" for="rejectReason-${ld.leadId}">Lý do từ chối <span class="form-required">*</span></label>
                                                    <textarea id="rejectReason-${ld.leadId}" name="rejectReason" class="form-control" rows="3" required></textarea>
                                                    <p class="form-help">Bắt buộc. Lead sẽ quay lại hàng chờ phân bổ sau khi bạn từ chối.</p>
                                                </div>
                                                <div class="ar-reject-actions">
                                                    <button type="button" class="btn btn-secondary js-reject-cancel">Hủy</button>
                                                    <button type="submit" class="btn btn-danger">Xác nhận từ chối</button>
                                                </div>
                                            </form>
                                        </c:if>
                                    </c:if>
                                </div>
                            </section>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<c:if test="${not empty rows}">
    <script>
        (function () {
            var list = document.getElementById('arList');
            var userId = (list.getAttribute('data-user-id') || '').trim();

            var ERRORS = {
                accept: {
                    400: 'Không thể nhận Lead. Lead không tồn tại, đã được nhận hoặc không còn được phân cho bạn.',
                    403: 'Bạn không phải người được phân Lead này.',
                    404: 'Lead không còn tồn tại.',
                    409: 'Lead đã được xử lý trước đó. Trang sẽ được tải lại.'
                },
                reject: {
                    400: 'Không thể từ chối Lead. Hãy nhập lý do, và kiểm tra Lead còn được phân cho bạn.',
                    403: 'Bạn không phải người được phân Lead này.',
                    404: 'Lead không còn tồn tại.',
                    409: 'Lead đã được xử lý trước đó. Trang sẽ được tải lại.'
                }
            };

            function notify(type, message) {
                if (typeof window.showToast === 'function') { window.showToast(type, message); } else { window.alert(message); }
            }

            function send(form, kind, successMessage) {
                var button = form.querySelector('button[type="submit"]');
                if (button.disabled) { return; }
                var headers = {
                    'Accept': 'application/json',
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                };
                // Chỉ gửi khi session có userId. Không đoán giá trị mặc định để tránh thao tác nhầm người.
                if (/^\d+$/.test(userId)) { headers['X-User-Id'] = userId; }
                button.disabled = true;
                fetch(form.action, {
                    method: 'POST',
                    credentials: 'same-origin',
                    headers: headers,
                    body: new URLSearchParams(new FormData(form)).toString()
                }).then(function (res) {
                    if (res.ok) {
                        notify('success', successMessage);
                        window.setTimeout(function () { window.location.reload(); }, 1200);
                        return;
                    }
                    var message = res.status === 401
                        ? 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.'
                        : (ERRORS[kind][res.status] || 'Hệ thống gặp lỗi. Hãy thử lại sau.');
                    notify('error', message);
                    if (res.status === 409) {
                        window.setTimeout(function () { window.location.reload(); }, 1500);
                    } else {
                        button.disabled = false;
                    }
                }).catch(function () {
                    notify('error', 'Không kết nối được máy chủ. Hãy kiểm tra mạng và thử lại.');
                    button.disabled = false;
                });
            }

            document.querySelectorAll('.js-accept-form').forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    event.preventDefault();
                    send(form, 'accept', 'Đã nhận Lead. Đang tải lại trạng thái...');
                });
            });

            document.querySelectorAll('.js-reject-toggle').forEach(function (toggle) {
                var box = document.getElementById(toggle.getAttribute('aria-controls'));
                var reason = box.querySelector('textarea');
                function setOpen(open) {
                    box.hidden = !open;
                    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
                    if (open) { reason.focus(); }
                }
                toggle.addEventListener('click', function () { setOpen(box.hidden); });
                box.querySelector('.js-reject-cancel').addEventListener('click', function () {
                    setOpen(false);
                    toggle.focus();
                });
                reason.addEventListener('input', function () { reason.setCustomValidity(''); });
                box.addEventListener('submit', function (event) {
                    event.preventDefault();
                    reason.value = reason.value.trim();
                    if (!reason.value) {
                        reason.setCustomValidity('Nhập lý do từ chối.');
                        reason.reportValidity();
                        return;
                    }
                    send(box, 'reject', 'Đã từ chối Lead. Lead quay lại hàng chờ phân bổ.');
                });
            });
        })();
    </script>
</c:if>
</body>
</html>
