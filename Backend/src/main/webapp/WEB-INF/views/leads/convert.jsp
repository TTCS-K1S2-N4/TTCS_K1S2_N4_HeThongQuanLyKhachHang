<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  HỢP ĐỒNG VỚI SERVLET: đối chiếu với LeadConvertServlet.java trước khi chạy.
  Request attribute khi mở trang
    lead          bắt buộc: id, fullName, status, company, email, phone
                  tùy chọn: interest, sourceName (thiếu getter thì hiện "—", không lỗi 500)
    errorMessage  tùy chọn
  Gửi đi: POST application/x-www-form-urlencoded với leadId và opportunityName
          Header X-User-Id lấy từ sessionScope.userId (tên attribute là giả định). Nếu session không có thì
          không gửi header và để servlet trả 401/403. Về lâu dài servlet nên lấy người dùng từ session phía server,
          vì header do trình duyệt gửi có thể bị giả mạo.
  Phản hồi: JSON. Thành công: HTTP 2xx kèm customerId, contactId, opportunityId (tùy chọn activityCount).
            Lỗi: HTTP 4xx/5xx kèm message hoặc error (chuỗi).
  Các khóa JSON và route /customers/detail, /contacts/detail là giả định, cần đối chiếu với servlet.
  Thư viện thẻ: jakarta.tags.* dành cho Tomcat 10+. Tomcat 9 dùng http://java.sun.com/jsp/jstl/core
  Form chưa có CSRF token: thêm vào nếu dự án có cơ chế này.
--%>
<c:set var="convertedStatus" value="Đã chuyển đổi" />
<c:set var="dash" value="—" />
<c:set var="hasLead" value="${not empty lead}" />
<c:set var="isConverted" value="${hasLead and fn:trim(lead.status) == convertedStatus}" />
<c:if test="${hasLead}">
    <c:set var="initial" value="${empty lead.fullName ? '?' : fn:toUpperCase(fn:substring(lead.fullName, 0, 1))}" />
    <c:catch var="optErr"><c:set var="leadInterest" value="${lead.interest}" /></c:catch>
    <c:catch var="optErr"><c:set var="leadSource" value="${lead.sourceName}" /></c:catch>
</c:if>
<c:url var="listUrl" value="/leads" />
<c:url var="convertUrl" value="/leads/convert" />
<c:url var="customerBase" value="/customers/detail" />
<c:url var="contactBase" value="/contacts/detail" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chuyển đổi Lead - CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <style>
        .cv-page {
            --cv-primary: var(--primary-color, #2563eb);
            --cv-primary-dark: #1d4ed8;
            --cv-text: var(--text-main, #0f172a);
            --cv-muted: #64748b;
            --cv-border: var(--border-color, #e2e8f0);
            --cv-surface: #ffffff;
            --cv-soft: #f8fafc;
            --cv-ok: #047857;
            --cv-ok-bg: #ecfdf5;
            --cv-err: #b91c1c;
            --cv-err-bg: #fef2f2;
            --cv-info-bg: #eff6ff;
            max-width: 980px;
            margin: 0 auto;
            padding: 20px 16px 40px;
            color: var(--cv-text);
            font-family: inherit;
        }
        .cv-page, .cv-page *, .cv-page *::before, .cv-page *::after { box-sizing: border-box; }
        .cv-page [hidden] { display: none !important; }
        .cv-icon { width: 20px; height: 20px; flex: none; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }

        .cv-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 20px; }
        .cv-title { margin: 0; font-size: 1.6rem; line-height: 1.25; font-weight: 700; }
        .cv-sub { margin: 4px 0 0; color: var(--cv-muted); font-size: .95rem; max-width: 62ch; }
        .cv-back { display: inline-flex; align-items: center; gap: 6px; color: var(--cv-muted); text-decoration: none; font-size: .9rem; }
        .cv-back:hover { color: var(--cv-primary); }

        .cv-badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 999px; font-size: .8rem; font-weight: 600; background: var(--cv-info-bg); color: var(--cv-primary-dark); }
        .cv-badge-ok { background: var(--cv-ok-bg); color: var(--cv-ok); }

        .cv-alert { display: flex; gap: 10px; align-items: flex-start; padding: 12px 14px; margin-bottom: 16px; border-radius: 10px; border: 1px solid; font-size: .92rem; line-height: 1.45; }
        .cv-alert .cv-icon { margin-top: 1px; }
        .cv-alert-error { background: var(--cv-err-bg); border-color: #fecaca; color: var(--cv-err); }
        .cv-alert-info { background: var(--cv-info-bg); border-color: #bfdbfe; color: var(--cv-primary-dark); }
        .cv-alert-ok { background: var(--cv-ok-bg); border-color: #a7f3d0; color: var(--cv-ok); }

        .cv-card { background: var(--cv-surface); border: 1px solid var(--cv-border); border-radius: 12px; padding: 18px; }
        .cv-lead { display: flex; align-items: center; gap: 14px; margin-bottom: 20px; }
        .cv-avatar { width: 48px; height: 48px; flex: none; display: grid; place-items: center; border-radius: 50%; background: var(--cv-info-bg); color: var(--cv-primary-dark); font-size: 1.15rem; font-weight: 700; }
        .cv-lead-main { min-width: 0; flex: 1; }
        .cv-lead-name { margin: 0; font-size: 1.1rem; font-weight: 600; overflow-wrap: anywhere; }
        .cv-lead-meta { display: flex; flex-wrap: wrap; gap: 2px 16px; margin: 2px 0 0; color: var(--cv-muted); font-size: .88rem; overflow-wrap: anywhere; }

        .cv-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; margin: 0 0 20px; padding: 0; list-style: none; }
        .cv-target { display: flex; flex-direction: column; gap: 12px; }
        .cv-target-head { display: flex; align-items: center; gap: 10px; }
        .cv-target-icon { width: 36px; height: 36px; flex: none; display: grid; place-items: center; border-radius: 10px; background: var(--cv-info-bg); color: var(--cv-primary-dark); }
        .cv-target-title { margin: 0; font-size: 1rem; font-weight: 600; }
        .cv-target-tag { margin: 0; font-size: .8rem; color: var(--cv-muted); }
        .cv-fields { margin: 0; display: grid; gap: 10px; }
        .cv-fields dt, .cv-label { font-size: .8rem; color: var(--cv-muted); margin: 0 0 2px; }
        .cv-fields dd { margin: 0; font-size: .95rem; overflow-wrap: anywhere; }
        .cv-label { display: block; }
        .cv-input { width: 100%; min-height: 40px; padding: 8px 10px; border: 1px solid var(--cv-border); border-radius: 8px; background: var(--cv-surface); color: var(--cv-text); font: inherit; font-size: .95rem; }
        .cv-input:focus-visible { outline: 3px solid rgba(37, 99, 235, .35); outline-offset: 1px; border-color: var(--cv-primary); }

        .cv-effects { margin: 0 0 20px; padding: 16px 18px; background: var(--cv-soft); border: 1px solid var(--cv-border); border-radius: 12px; }
        .cv-effects h2 { margin: 0 0 10px; font-size: .95rem; font-weight: 600; }
        .cv-effects ul { margin: 0; padding: 0; list-style: none; display: grid; gap: 8px; }
        .cv-effects li { display: flex; gap: 8px; align-items: flex-start; font-size: .9rem; color: #334155; }
        .cv-effects .cv-icon { color: var(--cv-ok); width: 18px; height: 18px; margin-top: 2px; }

        .cv-actions { display: flex; flex-wrap: wrap; justify-content: flex-end; gap: 12px; }
        .cv-btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; min-height: 44px; padding: 10px 18px; border-radius: 10px; border: 1px solid var(--cv-border); background: var(--cv-surface); color: #334155; font: inherit; font-size: .95rem; font-weight: 600; text-decoration: none; cursor: pointer; transition: background-color .15s, border-color .15s; }
        .cv-btn:hover { background: var(--cv-soft); border-color: #cbd5e1; }
        .cv-btn-primary { background: var(--cv-primary); border-color: var(--cv-primary); color: #fff; }
        .cv-btn-primary:hover { background: var(--cv-primary-dark); border-color: var(--cv-primary-dark); }
        .cv-btn:focus-visible, .cv-back:focus-visible, .cv-link:focus-visible { outline: 3px solid rgba(37, 99, 235, .35); outline-offset: 2px; }
        .cv-btn:disabled { opacity: .65; cursor: not-allowed; }
        .cv-spin { width: 16px; height: 16px; border: 2px solid rgba(255, 255, 255, .4); border-top-color: #fff; border-radius: 50%; animation: cv-rotate .7s linear infinite; }
        @keyframes cv-rotate { to { transform: rotate(360deg); } }

        .cv-done { display: flex; align-items: center; gap: 14px; margin-bottom: 20px; }
        .cv-done-icon { width: 52px; height: 52px; flex: none; display: grid; place-items: center; border-radius: 50%; background: var(--cv-ok-bg); color: var(--cv-ok); }
        .cv-done-icon .cv-icon { width: 28px; height: 28px; }
        .cv-done h2:focus { outline: none; }
        .cv-result-id { margin: 0; font-size: 1.35rem; font-weight: 700; }
        .cv-link { align-self: flex-start; color: var(--cv-primary); font-weight: 600; font-size: .9rem; text-decoration: none; }
        .cv-link:hover { text-decoration: underline; }

        .cv-dialog { width: min(440px, calc(100vw - 32px)); padding: 22px; border: 0; border-radius: 14px; color: var(--cv-text); box-shadow: 0 20px 50px rgba(15, 23, 42, .3); }
        .cv-dialog::backdrop { background: rgba(15, 23, 42, .5); }
        .cv-dialog h2 { margin: 0 0 8px; font-size: 1.15rem; }
        .cv-dialog p { margin: 0 0 18px; color: #475569; font-size: .92rem; line-height: 1.5; }

        @media (max-width: 760px) {
            .cv-grid { grid-template-columns: 1fr; }
            .cv-title { font-size: 1.35rem; }
            .cv-actions .cv-btn { flex: 1 1 100%; }
        }
        @media (prefers-reduced-motion: reduce) {
            .cv-btn { transition: none; }
            .cv-spin { animation-duration: 1.6s; }
        }
    </style>
</head>
<body>
<svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
    <symbol id="cv-i-building" viewBox="0 0 24 24"><path d="M4 21V5a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v16M14 9h5a1 1 0 0 1 1 1v11M3 21h18M8 8h2M8 12h2M8 16h2"/></symbol>
    <symbol id="cv-i-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></symbol>
    <symbol id="cv-i-brief" viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M3 13h18"/></symbol>
    <symbol id="cv-i-check" viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"/></symbol>
    <symbol id="cv-i-alert" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5h.01"/></symbol>
    <symbol id="cv-i-info" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 7.5h.01"/></symbol>
    <symbol id="cv-i-back" viewBox="0 0 24 24"><path d="M19 12H5M11 6l-6 6 6 6"/></symbol>
    <symbol id="cv-i-swap" viewBox="0 0 24 24"><path d="M7 7h12l-3-3M17 17H5l3 3"/></symbol>
</svg>

<jsp:include page="/WEB-INF/views/fragments/header.jsp" />
<jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

<main class="cv-page" aria-labelledby="cvTitle">
    <div class="cv-head">
        <div>
            <h1 class="cv-title" id="cvTitle">Chuyển đổi Lead</h1>
            <p class="cv-sub">Tạo Khách hàng doanh nghiệp, Người liên hệ và Cơ hội bán hàng từ Lead trong một thao tác.</p>
        </div>
        <a class="cv-back" href="${listUrl}">
            <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-back"/></svg>Danh sách Lead
        </a>
    </div>

    <div class="cv-alert cv-alert-error" id="cvError" role="alert" <c:if test="${empty errorMessage}">hidden</c:if>>
        <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-alert"/></svg>
        <span id="cvErrorText"><c:out value="${errorMessage}" /></span>
    </div>

    <c:choose>
        <%-- 1. Không có dữ liệu Lead --%>
        <c:when test="${not hasLead}">
            <div class="cv-alert cv-alert-info" role="status">
                <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-info"/></svg>
                <span>Không tìm thấy Lead cần chuyển đổi. Hãy quay lại danh sách và chọn một Lead khác.</span>
            </div>
            <div class="cv-actions">
                <a class="cv-btn cv-btn-primary" href="${listUrl}">Quay lại danh sách Lead</a>
            </div>
        </c:when>

        <%-- 2. Lead đã được chuyển đổi trước đó: chỉ xem --%>
        <c:when test="${isConverted}">
            <div class="cv-alert cv-alert-info" role="status">
                <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-info"/></svg>
                <span>Lead này đã được chuyển đổi nên không thể chuyển đổi lại hoặc chỉnh sửa.</span>
            </div>
            <section class="cv-card cv-lead" aria-label="Thông tin Lead">
                <span class="cv-avatar" aria-hidden="true"><c:out value="${initial}" /></span>
                <div class="cv-lead-main">
                    <p class="cv-lead-name"><c:out value="${lead.fullName}" /></p>
                    <p class="cv-lead-meta">
                        <c:if test="${not empty lead.company}"><span><c:out value="${lead.company}" /></span></c:if>
                        <c:if test="${not empty lead.email}"><span><c:out value="${lead.email}" /></span></c:if>
                        <c:if test="${not empty lead.phone}"><span><c:out value="${lead.phone}" /></span></c:if>
                    </p>
                </div>
                <span class="cv-badge cv-badge-ok"><c:out value="${convertedStatus}" /></span>
            </section>
            <div class="cv-actions">
                <a class="cv-btn cv-btn-primary" href="${listUrl}">Quay lại danh sách Lead</a>
            </div>
        </c:when>

        <%-- 3. Xem trước, nhập tên cơ hội và xác nhận --%>
        <c:otherwise>
            <noscript>
                <div class="cv-alert cv-alert-info">
                    <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-info"/></svg>
                    <span>Cần bật JavaScript để chuyển đổi Lead.</span>
                </div>
            </noscript>

            <section class="cv-card cv-lead" aria-label="Lead nguồn">
                <span class="cv-avatar" aria-hidden="true"><c:out value="${initial}" /></span>
                <div class="cv-lead-main">
                    <p class="cv-lead-name"><c:out value="${lead.fullName}" /></p>
                    <p class="cv-lead-meta">
                        <c:if test="${not empty lead.company}"><span><c:out value="${lead.company}" /></span></c:if>
                        <c:if test="${not empty lead.email}"><span><c:out value="${lead.email}" /></span></c:if>
                    </p>
                </div>
                <span class="cv-badge" id="cvLeadBadge"><c:out value="${empty lead.status ? 'Lead' : lead.status}" /></span>
            </section>

            <div id="cvFormWrap">
                <c:set var="defaultOppName" value="Cơ hội - ${empty lead.company ? lead.fullName : lead.company}" />
                <form id="convertForm" method="post" action="${convertUrl}" data-user-id="<c:out value='${sessionScope.userId}'/>">
                    <input type="hidden" name="leadId" value="<c:out value='${lead.id}'/>">

                    <p class="cv-sub" style="margin-bottom:14px">Lead này sẽ được chuyển thành ba bản ghi sau.</p>

                    <ul class="cv-grid">
                        <li class="cv-card cv-target">
                            <div class="cv-target-head">
                                <span class="cv-target-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-building"/></svg></span>
                                <div>
                                    <h2 class="cv-target-title">Khách hàng</h2>
                                    <p class="cv-target-tag">Doanh nghiệp, sẽ được tạo</p>
                                </div>
                            </div>
                            <dl class="cv-fields">
                                <div><dt>Tên doanh nghiệp</dt><dd><c:out value="${empty lead.company ? dash : lead.company}" /></dd></div>
                            </dl>
                        </li>
                        <li class="cv-card cv-target">
                            <div class="cv-target-head">
                                <span class="cv-target-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-user"/></svg></span>
                                <div>
                                    <h2 class="cv-target-title">Người liên hệ</h2>
                                    <p class="cv-target-tag">Sẽ được tạo</p>
                                </div>
                            </div>
                            <dl class="cv-fields">
                                <div><dt>Họ và tên</dt><dd><c:out value="${empty lead.fullName ? dash : lead.fullName}" /></dd></div>
                                <div><dt>Email</dt><dd><c:out value="${empty lead.email ? dash : lead.email}" /></dd></div>
                                <div><dt>Số điện thoại</dt><dd><c:out value="${empty lead.phone ? dash : lead.phone}" /></dd></div>
                            </dl>
                        </li>
                        <li class="cv-card cv-target">
                            <div class="cv-target-head">
                                <span class="cv-target-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-brief"/></svg></span>
                                <div>
                                    <h2 class="cv-target-title">Cơ hội bán hàng</h2>
                                    <p class="cv-target-tag">Sẽ được tạo</p>
                                </div>
                            </div>
                            <div>
                                <label class="cv-label" for="cvOppName">Tên cơ hội</label>
                                <input type="text" class="cv-input" id="cvOppName" name="opportunityName" required autocomplete="off" value="<c:out value='${defaultOppName}'/>">
                            </div>
                            <dl class="cv-fields">
                                <div><dt>Nhu cầu quan tâm</dt><dd><c:out value="${empty leadInterest ? dash : leadInterest}" /></dd></div>
                                <div><dt>Nguồn</dt><dd><c:out value="${empty leadSource ? dash : leadSource}" /></dd></div>
                            </dl>
                        </li>
                    </ul>

                    <section class="cv-effects" aria-labelledby="cvEffects">
                        <h2 id="cvEffects">Điều gì sẽ xảy ra khi chuyển đổi</h2>
                        <ul>
                            <li><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>Ba bản ghi được tạo trong cùng một thao tác. Nếu có lỗi, không bản ghi nào được lưu.</li>
                            <li><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>Hoạt động đã ghi trên Lead được giữ lại trên khách hàng mới.</li>
                            <li><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>Lead chuyển sang <strong><c:out value="${convertedStatus}" /></strong> và không thể chỉnh sửa nữa.</li>
                        </ul>
                    </section>

                    <div class="cv-actions">
                        <a class="cv-btn" href="${listUrl}">Hủy</a>
                        <button type="submit" id="cvSubmit" class="cv-btn cv-btn-primary">
                            <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-swap"/></svg>Chuyển đổi Lead
                        </button>
                    </div>
                </form>
            </div>

            <%-- Kết quả: được điền bằng JavaScript sau khi servlet trả JSON thành công --%>
            <div id="cvSuccess" hidden data-status="<c:out value='${convertedStatus}'/>" data-customer-url="${customerBase}" data-contact-url="${contactBase}">
                <div class="cv-card cv-done" role="status">
                    <span class="cv-done-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg></span>
                    <div>
                        <h2 class="cv-lead-name" id="cvDoneTitle" tabindex="-1">Chuyển đổi thành công</h2>
                        <p class="cv-lead-meta">
                            <span>Lead <strong><c:out value="${lead.fullName}" /></strong> đã chuyển sang trạng thái
                            <span class="cv-badge cv-badge-ok"><c:out value="${convertedStatus}" /></span>
                            và không thể chỉnh sửa.</span>
                        </p>
                    </div>
                </div>

                <ul class="cv-grid">
                    <li class="cv-card cv-target" id="cvResCustomer" hidden>
                        <span class="cv-target-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-building"/></svg></span>
                        <p class="cv-target-tag">Khách hàng doanh nghiệp</p>
                        <p class="cv-result-id">#<span id="cvResCustomerId"></span></p>
                        <a class="cv-link" id="cvResCustomerLink" href="#">Xem khách hàng</a>
                    </li>
                    <li class="cv-card cv-target" id="cvResContact" hidden>
                        <span class="cv-target-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-user"/></svg></span>
                        <p class="cv-target-tag">Người liên hệ</p>
                        <p class="cv-result-id">#<span id="cvResContactId"></span></p>
                        <a class="cv-link" id="cvResContactLink" href="#">Xem người liên hệ</a>
                    </li>
                    <li class="cv-card cv-target" id="cvResOpportunity" hidden>
                        <span class="cv-target-icon"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-brief"/></svg></span>
                        <p class="cv-target-tag">Cơ hội bán hàng</p>
                        <p class="cv-result-id">#<span id="cvResOpportunityId"></span></p>
                    </li>
                </ul>

                <div class="cv-alert cv-alert-ok" id="cvResActivities" role="status" hidden>
                    <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>
                    <span>Đã giữ lại <strong id="cvResActivityCount"></strong> hoạt động của Lead trên khách hàng mới.</span>
                </div>

                <div class="cv-actions">
                    <a class="cv-btn cv-btn-primary" href="${listUrl}">Quay lại danh sách Lead</a>
                </div>
            </div>

            <dialog id="cvDialog" class="cv-dialog" aria-labelledby="cvDialogTitle">
                <h2 id="cvDialogTitle">Chuyển đổi Lead này?</h2>
                <p>Lead <strong><c:out value="${lead.fullName}" /></strong> sẽ được chuyển thành Khách hàng, Người liên hệ và Cơ hội bán hàng. Sau đó Lead không thể chỉnh sửa.</p>
                <div class="cv-actions">
                    <button type="button" id="cvDialogCancel" class="cv-btn">Xem lại</button>
                    <button type="button" id="cvDialogOk" class="cv-btn cv-btn-primary">Chuyển đổi</button>
                </div>
            </dialog>

            <script>
                (function () {
                    var form = document.getElementById('convertForm');
                    if (!form) { return; }
                    var submit = document.getElementById('cvSubmit');
                    var nameInput = document.getElementById('cvOppName');
                    var dialog = document.getElementById('cvDialog');
                    var ok = document.getElementById('cvDialogOk');
                    var cancel = document.getElementById('cvDialogCancel');
                    var wrap = document.getElementById('cvFormWrap');
                    var success = document.getElementById('cvSuccess');
                    var errBox = document.getElementById('cvError');
                    var errText = document.getElementById('cvErrorText');
                    var badge = document.getElementById('cvLeadBadge');
                    var original = submit.innerHTML;
                    var sending = false;

                    function toast(type, message) {
                        if (typeof window.showToast === 'function') { window.showToast(type, message); }
                    }

                    function setBusy() {
                        sending = true;
                        submit.disabled = true;
                        submit.setAttribute('aria-busy', 'true');
                        submit.textContent = '';
                        var spinner = document.createElement('span');
                        spinner.className = 'cv-spin';
                        spinner.setAttribute('aria-hidden', 'true');
                        submit.appendChild(spinner);
                        submit.appendChild(document.createTextNode('Đang xử lý...'));
                    }

                    function reset() {
                        sending = false;
                        submit.disabled = false;
                        submit.removeAttribute('aria-busy');
                        submit.innerHTML = original;
                    }

                    function fail(message) {
                        reset();
                        errText.textContent = message;
                        errBox.hidden = false;
                        errBox.scrollIntoView({ block: 'nearest' });
                        toast('error', message);
                    }

                    function failMessage(status, data) {
                        if (data && typeof data.message === 'string' && data.message) { return data.message; }
                        if (data && typeof data.error === 'string' && data.error) { return data.error; }
                        if (status === 401 || status === 403) { return 'Phiên đăng nhập đã hết hạn hoặc bạn không có quyền chuyển đổi Lead này.'; }
                        if (!data) { return 'Máy chủ trả về dữ liệu không hợp lệ. Hãy tải lại trang rồi thử lại.'; }
                        return 'Chuyển đổi không thành công. Vui lòng thử lại.';
                    }

                    function fill(key, id, base) {
                        var box = document.getElementById('cvRes' + key);
                        if (!box) { return; }
                        if (id === undefined || id === null || id === '') { box.hidden = true; return; }
                        box.hidden = false;
                        document.getElementById('cvRes' + key + 'Id').textContent = id;
                        var link = document.getElementById('cvRes' + key + 'Link');
                        if (link && base) {
                            link.href = base + (base.indexOf('?') < 0 ? '?' : '&') + 'id=' + encodeURIComponent(id);
                        }
                    }

                    function done(payload) {
                        fill('Customer', payload.customerId, success.getAttribute('data-customer-url'));
                        fill('Contact', payload.contactId, success.getAttribute('data-contact-url'));
                        fill('Opportunity', payload.opportunityId, null);
                        var count = Number(payload.activityCount);
                        if (count > 0) {
                            document.getElementById('cvResActivityCount').textContent = count;
                            document.getElementById('cvResActivities').hidden = false;
                        }
                        if (badge) {
                            badge.textContent = success.getAttribute('data-status');
                            badge.className = 'cv-badge cv-badge-ok';
                        }
                        errBox.hidden = true;
                        wrap.hidden = true;
                        success.hidden = false;
                        document.getElementById('cvDoneTitle').focus();
                        toast('success', 'Chuyển đổi thành công.');
                    }

                    function send() {
                        if (sending) { return; }
                        errBox.hidden = true;
                        setBusy();
                        var headers = {
                            'Accept': 'application/json',
                            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                        };
                        // Chỉ gửi khi session có userId. Không đoán giá trị mặc định để tránh ghi nhầm người thực hiện.
                        var userId = (form.getAttribute('data-user-id') || '').trim();
                        if (/^[\w-]+$/.test(userId)) { headers['X-User-Id'] = userId; }
                        fetch(form.action, {
                            method: 'POST',
                            credentials: 'same-origin',
                            headers: headers,
                            body: new URLSearchParams(new FormData(form)).toString()
                        }).then(function (res) {
                            return res.text().then(function (text) {
                                var data = null;
                                try { data = text ? JSON.parse(text) : null; } catch (e) { data = null; }
                                if (data !== null && typeof data !== 'object') { data = null; }
                                return { ok: res.ok, status: res.status, data: data };
                            });
                        }).then(function (r) {
                            var d = r.data;
                            if (!r.ok || !d || d.success === false || d.error) {
                                fail(failMessage(r.status, d));
                                return;
                            }
                            done(d.data && typeof d.data === 'object' ? d.data : d);
                        }).catch(function () {
                            fail('Không kết nối được máy chủ. Hãy kiểm tra mạng và thử lại.');
                        });
                    }

                    form.addEventListener('submit', function (event) {
                        event.preventDefault();
                        if (sending) { return; }
                        nameInput.value = nameInput.value.trim();
                        if (!nameInput.value) {
                            nameInput.setCustomValidity('Nhập tên cơ hội.');
                            nameInput.reportValidity();
                            return;
                        }
                        if (dialog && typeof dialog.showModal === 'function') {
                            dialog.showModal();
                            cancel.focus();
                        } else if (window.confirm('Chuyển đổi Lead này? Sau đó Lead không thể chỉnh sửa.')) {
                            send();
                        }
                    });
                    nameInput.addEventListener('input', function () { nameInput.setCustomValidity(''); });
                    if (ok) { ok.addEventListener('click', function () { dialog.close(); send(); }); }
                    if (cancel) { cancel.addEventListener('click', function () { dialog.close(); submit.focus(); }); }
                })();
            </script>
        </c:otherwise>
    </c:choose>
</main>

<jsp:include page="/WEB-INF/views/fragments/toast.jsp" />
<script>
    document.addEventListener('DOMContentLoaded', function () {
        var error = document.getElementById('cvError');
        if (error && !error.hidden && typeof window.showToast === 'function') {
            window.showToast('error', error.textContent.trim());
        }
    });
</script>
</body>
</html>