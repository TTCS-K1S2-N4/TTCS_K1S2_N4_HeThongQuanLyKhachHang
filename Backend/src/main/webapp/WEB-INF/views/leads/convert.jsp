<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  convert.jsp - S4-08 Chuyển đổi Lead (FE04).
  Đã khớp và đồng bộ với:
    - LeadConvertServlet (POST /leads/convert: leadId, opportunityName, Header X-User-Id)
    - OpportunityDetailServlet (/deals/detail?id=)
    - CustomerDetailServlet (/customers/detail?id=)
    - ContactDetailServlet (/contacts/detail?id=)
    - Khung app, header cố định và sidebar của CRM
--%>
<c:set var="convertedStatus" value="Đã chuyển đổi" />
<c:set var="dash" value="—" />
<c:set var="hasLead" value="${not empty lead}" />
<c:if test="${hasLead}">
    <c:set var="leadActualId" value="${not empty lead.id ? lead.id : lead.leadId}" />
    <c:set var="statusTrim" value="${fn:trim(lead.status)}" />
    <c:set var="isConverted" value="${statusTrim == convertedStatus or fn:toUpperCase(statusTrim) == 'CONVERTED'}" />
    <c:set var="displayName" value="${empty lead.fullName ? 'Lead chưa có tên' : lead.fullName}" />
    <c:set var="initial" value="${empty lead.fullName ? '?' : fn:toUpperCase(fn:substring(lead.fullName, 0, 1))}" />
    <c:catch var="optErr"><c:set var="leadInterest" value="${not empty lead.interest ? lead.interest : lead.notes}" /></c:catch>
    <c:catch var="optErr"><c:set var="leadSource" value="${not empty lead.sourceName ? lead.sourceName : lead.source}" /></c:catch>
</c:if>

<c:set var="authUserId" value="${not empty sessionScope.userId ? sessionScope.userId : (not empty sessionScope.currentUser ? sessionScope.currentUser.accountId : '')}" />
<c:url var="listUrl" value="/leads" />
<c:url var="convertUrl" value="/leads/convert" />
<c:url var="customerBase" value="/customers/detail" />
<c:url var="contactBase" value="/contacts/detail" />
<c:url var="dealBase" value="/deals/detail" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chuyển đổi Lead - CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <style>
        .cv-page {
            --cv-primary: var(--color-primary, #2563eb);
            --cv-primary-dark: var(--color-primary-hover, #1d4ed8);
            --cv-primary-soft: var(--color-primary-light, #eff6ff);
            --cv-text: var(--color-text-primary, #0f172a);
            --cv-muted: var(--color-text-secondary, #64748b);
            --cv-line: var(--color-border, #e2e8f0);
            --cv-line-strong: var(--color-gray-300, #cbd5e1);
            --cv-surface: var(--color-surface, #ffffff);
            --cv-wash: var(--color-page-bg, #f8fafc);
            --cv-ok: var(--color-success, #16a34a);
            --cv-ok-bg: var(--color-success-bg, #f0fdf4);
            --cv-err: var(--color-danger, #dc2626);
            --cv-err-bg: var(--color-danger-bg, #fef2f2);
            max-width: 1060px;
            margin: 0 auto;
            color: var(--cv-text);
            font-family: inherit;
            line-height: 1.5;
        }
        .cv-page, .cv-page *, .cv-page *::before, .cv-page *::after { box-sizing: border-box; }
        .cv-page [hidden] { display: none !important; }
        .cv-icon { width: 20px; height: 20px; flex: none; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }

        /* Tiêu đề & Điều hướng */
        .cv-head { display: flex; flex-wrap: wrap; align-items: flex-start; justify-content: space-between; gap: 12px 24px; margin-bottom: 20px; }
        .cv-title { margin: 0; font-size: 1.65rem; line-height: 1.25; font-weight: 700; letter-spacing: -.02em; }
        .cv-sub { margin: 6px 0 0; color: var(--cv-muted); font-size: .95rem; max-width: 65ch; }
        .cv-back { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; color: var(--cv-muted); text-decoration: none; font-size: .9rem; font-weight: 500; border-radius: 6px; border: 1px solid var(--cv-line); background: var(--cv-surface); transition: all .15s; }
        .cv-back:hover { color: var(--cv-primary); border-color: var(--cv-primary); }

        /* Các bước (Stepper) */
        .cv-steps { display: flex; align-items: center; margin: 0 0 24px; padding: 0; list-style: none; font-size: .88rem; color: var(--cv-muted); }
        .cv-step { display: flex; align-items: center; gap: 8px; flex: 1; min-width: 0; }
        .cv-step:last-child { flex: none; }
        .cv-step:not(:last-child)::after { content: ""; flex: 1; height: 1px; margin: 0 12px; background: var(--cv-line-strong); }
        .cv-dot { width: 28px; height: 28px; flex: none; display: grid; place-items: center; border-radius: 50%; border: 1.5px solid var(--cv-line-strong); background: var(--cv-surface); font-size: .78rem; font-weight: 700; }
        .cv-tick { display: none; width: 14px; height: 14px; stroke-width: 2.8; }
        .cv-step.is-current { color: var(--cv-text); font-weight: 600; }
        .cv-step.is-current .cv-dot { border-color: var(--cv-primary); background: var(--cv-primary); color: #fff; box-shadow: 0 0 0 4px var(--cv-primary-soft); }
        .cv-step.is-done .cv-dot { border-color: var(--cv-ok); background: var(--cv-ok); color: #fff; }
        .cv-step.is-done .cv-num { display: none; }
        .cv-step.is-done .cv-tick { display: block; }
        .cv-step.is-done:not(:last-child)::after { background: var(--cv-ok); }

        /* Thông báo */
        .cv-alert { display: flex; gap: 10px; align-items: flex-start; padding: 12px 14px; margin-bottom: 16px; border-radius: 8px; border: 1px solid; font-size: .92rem; }
        .cv-alert .cv-icon { margin-top: 2px; }
        .cv-alert-error { background: var(--cv-err-bg); border-color: #fecaca; color: var(--cv-err); }
        .cv-alert-info { background: var(--cv-primary-soft); border-color: #bfdbfe; color: var(--cv-primary-dark); }
        .cv-alert-ok { background: var(--cv-ok-bg); border-color: #a7f3d0; color: var(--cv-ok); }

        .cv-badge { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 999px; font-size: .8rem; font-weight: 600; background: var(--cv-primary-soft); color: var(--cv-primary-dark); white-space: nowrap; }
        .cv-badge-ok { background: var(--cv-ok-bg); color: var(--cv-ok); }

        /* Bố cục: Lead bên trái, ba bản ghi sẽ được tạo bên phải */
        .cv-layout { display: grid; grid-template-columns: 280px minmax(0, 1fr); gap: 20px; align-items: start; margin-bottom: 20px; }
        .cv-panel { background: var(--cv-surface); border: 1px solid var(--cv-line); border-radius: 12px; box-shadow: 0 1px 3px rgba(15,23,42,0.04); }

        .cv-source { position: sticky; top: calc(var(--header-height, 64px) + 20px); display: flex; flex-direction: column; align-items: flex-start; gap: 12px; padding: 22px; }
        .cv-avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--cv-primary-soft); color: var(--cv-primary); font-size: 1.4rem; font-weight: 700; border: 2px solid #bfdbfe; }
        .cv-lead-name { margin: 0; font-size: 1.15rem; line-height: 1.3; font-weight: 700; overflow-wrap: anywhere; }
        .cv-lead-company { margin: 2px 0 0; color: var(--cv-muted); font-size: .9rem; overflow-wrap: anywhere; }
        .cv-lead-id { margin: 0; padding-top: 12px; width: 100%; border-top: 1px solid var(--cv-line); color: var(--cv-muted); font-size: .85rem; }

        .cv-targets-title { margin: 0 0 4px; font-size: 1.05rem; font-weight: 600; }
        .cv-targets-head { padding: 18px 22px 14px; }
        .cv-targets-head p { margin: 0; color: var(--cv-muted); font-size: .9rem; }
        .cv-targets { margin: 0; padding: 0; list-style: none; }
        .cv-target { display: grid; grid-template-columns: 42px minmax(0, 1fr); gap: 16px; padding: 18px 22px; border-top: 1px solid var(--cv-line); }
        .cv-node { width: 42px; height: 42px; display: grid; place-items: center; border-radius: 10px; background: var(--cv-primary-soft); color: var(--cv-primary); }
        .cv-target-title { margin: 0; font-size: 1rem; font-weight: 600; }
        .cv-target-note { margin: 0 0 10px; color: var(--cv-muted); font-size: .85rem; }
        .cv-fields { margin: 0; display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 10px 16px; }
        .cv-fields dt, .cv-label { margin: 0 0 2px; font-size: .82rem; color: var(--cv-muted); font-weight: 500; }
        .cv-fields dd { margin: 0; font-size: .95rem; overflow-wrap: anywhere; }
        .cv-label { display: block; font-weight: 500; color: #334155; }
        .cv-field-group { margin-bottom: 12px; }
        .cv-input { width: 100%; min-height: 42px; padding: 8px 12px; border: 1px solid var(--cv-line-strong); border-radius: 8px; background: var(--cv-surface); color: var(--cv-text); font: inherit; font-size: .95rem; }
        .cv-input:hover { border-color: #94a3b8; }
        .cv-input:focus-visible { outline: 3px solid rgba(37, 99, 235, .25); outline-offset: 0; border-color: var(--cv-primary); }

        /* Điều gì xảy ra */
        .cv-effects { margin: 0 0 20px; padding: 16px 20px; background: var(--cv-wash); border: 1px solid var(--cv-line); border-left: 4px solid var(--cv-primary); border-radius: 8px; }
        .cv-effects h2 { margin: 0 0 8px; font-size: .95rem; font-weight: 600; }
        .cv-effects ul { margin: 0; padding: 0; list-style: none; display: grid; gap: 8px; }
        .cv-effects li { display: flex; gap: 8px; align-items: flex-start; font-size: .9rem; color: #334155; }
        .cv-effects .cv-icon { width: 18px; height: 18px; margin-top: 2px; color: var(--cv-ok); stroke-width: 2.4; }

        /* Nút */
        .cv-actions { display: flex; flex-wrap: wrap; justify-content: flex-end; gap: 12px; }
        .cv-btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; min-height: 42px; padding: 10px 22px; border-radius: 8px; border: 1px solid var(--cv-line-strong); background: var(--cv-surface); color: #334155; font: inherit; font-size: .95rem; font-weight: 600; text-decoration: none; cursor: pointer; transition: background-color .15s, border-color .15s; }
        .cv-btn:hover { background: var(--cv-wash); border-color: #94a3b8; }
        .cv-btn-primary { background: var(--cv-primary); border-color: var(--cv-primary); color: #fff; }
        .cv-btn-primary:hover { background: var(--cv-primary-dark); border-color: var(--cv-primary-dark); }
        .cv-btn:focus-visible, .cv-back:focus-visible, .cv-link:focus-visible { outline: 3px solid rgba(37, 99, 235, .35); outline-offset: 2px; }
        .cv-btn:disabled { opacity: .7; cursor: not-allowed; }
        .cv-spin { width: 16px; height: 16px; border: 2px solid rgba(255, 255, 255, .4); border-top-color: #fff; border-radius: 50%; animation: cv-rotate .7s linear infinite; }
        @keyframes cv-rotate { to { transform: rotate(360deg); } }

        /* Kết quả thành công */
        .cv-done { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; padding: 22px; }
        .cv-ring { width: 56px; height: 56px; flex: none; fill: none; stroke: var(--cv-ok); stroke-width: 2.4; stroke-linecap: round; stroke-linejoin: round; }
        .cv-ring-c { stroke-dasharray: 151; stroke-dashoffset: 151; animation: cv-draw .6s ease-out forwards; }
        .cv-ring-p { stroke-dasharray: 40; stroke-dashoffset: 40; animation: cv-draw .35s ease-out .5s forwards; }
        @keyframes cv-draw { to { stroke-dashoffset: 0; } }
        .cv-done h2 { margin: 0; font-size: 1.3rem; font-weight: 700; }
        .cv-done h2:focus { outline: none; }
        .cv-done p { margin: 4px 0 0; color: var(--cv-muted); font-size: .92rem; }
        .cv-result { display: grid; grid-template-columns: 42px minmax(0, 1fr) auto; align-items: center; gap: 14px; padding: 16px 22px; border-top: 1px solid var(--cv-line); }
        .cv-result:first-child { border-top: 0; }
        .cv-result-label { margin: 0; color: var(--cv-muted); font-size: .85rem; }
        .cv-result-id { margin: 0; font-size: 1.25rem; font-weight: 700; color: var(--cv-text); }
        .cv-link { color: var(--cv-primary); font-weight: 600; font-size: .9rem; text-decoration: none; white-space: nowrap; }
        .cv-link:hover { text-decoration: underline; }

        /* Hộp thoại xác nhận */
        .cv-dialog { width: min(460px, calc(100vw - 32px)); padding: 24px; border: 0; border-radius: 12px; color: var(--cv-text); box-shadow: 0 24px 60px rgba(15, 23, 42, .32); }
        .cv-dialog::backdrop { background: rgba(15, 23, 42, .5); }
        .cv-dialog h2 { margin: 0 0 8px; font-size: 1.15rem; font-weight: 700; }
        .cv-dialog p { margin: 0 0 12px; color: #475569; font-size: .92rem; }
        .cv-dialog ul { margin: 0 0 20px; padding-left: 20px; color: #334155; font-size: .9rem; display: grid; gap: 4px; }

        @media (max-width: 880px) {
            .cv-layout { grid-template-columns: 1fr; }
            .cv-source { position: static; flex-direction: row; flex-wrap: wrap; align-items: center; }
            .cv-lead-id { border-top: 0; padding-top: 0; width: auto; margin-left: auto; }
        }
        @media (max-width: 560px) {
            .cv-title { font-size: 1.35rem; }
            .cv-step-text { display: none; }
            .cv-step.is-current .cv-step-text { display: inline; }
            .cv-target { grid-template-columns: 1fr; gap: 10px; padding: 16px; }
            .cv-result { grid-template-columns: 40px minmax(0, 1fr); padding: 14px 16px; }
            .cv-result .cv-link { grid-column: 2; }
            .cv-done { flex-direction: column; align-items: flex-start; }
            .cv-actions { flex-direction: column-reverse; }
            .cv-actions .cv-btn { width: 100%; }
        }
        @media (prefers-reduced-motion: reduce) {
            .cv-btn { transition: none; }
            .cv-spin { animation-duration: 1.6s; }
            .cv-ring-c, .cv-ring-p { animation: none; stroke-dashoffset: 0; }
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

<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <span>/</span>
                <a href="${listUrl}">Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Chuyển đổi</span>
            </nav>

            <section class="cv-page" aria-labelledby="cvTitle">
                <div class="cv-head">
                    <div>
                        <h1 class="cv-title" id="cvTitle">Chuyển đổi Lead</h1>
                        <p class="cv-sub">Tạo Khách hàng, Người liên hệ và Cơ hội bán hàng từ Lead trong một thao tác.</p>
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
                            <span>Không tìm thấy Lead cần chuyển đổi. Quay lại danh sách và chọn một Lead khác.</span>
                        </div>
                        <div class="cv-actions">
                            <a class="cv-btn cv-btn-primary" href="${listUrl}">Quay lại danh sách Lead</a>
                        </div>
                    </c:when>

                    <%-- 2. Lead đã được chuyển đổi: chỉ xem --%>
                    <c:when test="${isConverted}">
                        <div class="cv-alert cv-alert-info" role="status">
                            <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-info"/></svg>
                            <span>Lead này đã được chuyển đổi. Bạn không thể chuyển đổi lại hoặc chỉnh sửa.</span>
                        </div>
                        <section class="cv-panel cv-source" style="position:static;margin-bottom:20px" aria-label="Thông tin Lead">
                            <span class="cv-avatar" aria-hidden="true"><c:out value="${initial}" /></span>
                            <div>
                                <p class="cv-lead-name"><c:out value="${displayName}" /></p>
                                <p class="cv-lead-company">
                                    <c:out value="${empty lead.company ? dash : lead.company}" />
                                    <c:if test="${not empty lead.email}">, <c:out value="${lead.email}" /></c:if>
                                    <c:if test="${not empty lead.phone}">, <c:out value="${lead.phone}" /></c:if>
                                </p>
                            </div>
                            <span class="cv-badge cv-badge-ok"><c:out value="${convertedStatus}" /></span>
                        </section>
                        <div class="cv-actions">
                            <a class="cv-btn cv-btn-primary" href="${listUrl}">Quay lại danh sách Lead</a>
                        </div>
                    </c:when>

                    <%-- 3. Xem lại, đặt tên cơ hội và xác nhận --%>
                    <c:otherwise>
                        <noscript>
                            <div class="cv-alert cv-alert-info">
                                <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-info"/></svg>
                                <span>Bật JavaScript để chuyển đổi Lead.</span>
                            </div>
                        </noscript>

                        <ol class="cv-steps" id="cvSteps" aria-label="Các bước chuyển đổi">
                            <li class="cv-step is-current" aria-current="step"><span class="cv-dot"><span class="cv-num">1</span><svg class="cv-icon cv-tick" aria-hidden="true"><use href="#cv-i-check"/></svg></span><span class="cv-step-text">Xem lại thông tin</span></li>
                            <li class="cv-step"><span class="cv-dot"><span class="cv-num">2</span><svg class="cv-icon cv-tick" aria-hidden="true"><use href="#cv-i-check"/></svg></span><span class="cv-step-text">Xác nhận</span></li>
                            <li class="cv-step"><span class="cv-dot"><span class="cv-num">3</span><svg class="cv-icon cv-tick" aria-hidden="true"><use href="#cv-i-check"/></svg></span><span class="cv-step-text">Hoàn tất</span></li>
                        </ol>

                        <div id="cvFormWrap">
                            <c:set var="defaultOppName" value="Cơ hội - ${empty lead.company ? displayName : lead.company}" />
                            <form id="convertForm" method="post" action="${convertUrl}" data-user-id="<c:out value='${authUserId}'/>">
                                <input type="hidden" name="leadId" value="<c:out value='${leadActualId}'/>">

                                <div class="cv-layout">
                                    <section class="cv-panel cv-source" aria-label="Lead nguồn">
                                        <span class="cv-avatar" aria-hidden="true"><c:out value="${initial}" /></span>
                                        <div>
                                            <p class="cv-lead-name"><c:out value="${displayName}" /></p>
                                            <p class="cv-lead-company"><c:out value="${empty lead.company ? 'Chưa có tên doanh nghiệp' : lead.company}" /></p>
                                        </div>
                                        <span class="cv-badge" id="cvLeadBadge"><c:out value="${empty lead.status ? 'Lead' : lead.status}" /></span>
                                        <p class="cv-lead-id">Lead #<c:out value="${leadActualId}" /></p>
                                    </section>

                                    <section class="cv-panel" aria-labelledby="cvTargetsTitle">
                                        <div class="cv-targets-head">
                                            <h2 class="cv-targets-title" id="cvTargetsTitle">Lead này sẽ trở thành ba bản ghi</h2>
                                            <p>Kiểm tra thông tin bên dưới. Bạn chỉ cần đặt tên cho cơ hội.</p>
                                        </div>
                                        <ul class="cv-targets">
                                            <li class="cv-target">
                                                <span class="cv-node"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-building"/></svg></span>
                                                <div>
                                                    <h3 class="cv-target-title">Khách hàng</h3>
                                                    <p class="cv-target-note">Khách hàng doanh nghiệp mới</p>
                                                    <dl class="cv-fields">
                                                        <div><dt>Tên doanh nghiệp</dt><dd><c:out value="${empty lead.company ? dash : lead.company}" /></dd></div>
                                                    </dl>
                                                </div>
                                            </li>
                                            <li class="cv-target">
                                                <span class="cv-node"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-user"/></svg></span>
                                                <div>
                                                    <h3 class="cv-target-title">Người liên hệ</h3>
                                                    <p class="cv-target-note">Người liên hệ mới của khách hàng</p>
                                                    <dl class="cv-fields">
                                                        <div><dt>Họ và tên</dt><dd><c:out value="${empty lead.fullName ? dash : lead.fullName}" /></dd></div>
                                                        <div><dt>Email</dt><dd><c:out value="${empty lead.email ? dash : lead.email}" /></dd></div>
                                                        <div><dt>Số điện thoại</dt><dd><c:out value="${empty lead.phone ? dash : lead.phone}" /></dd></div>
                                                    </dl>
                                                </div>
                                            </li>
                                            <li class="cv-target">
                                                <span class="cv-node"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-brief"/></svg></span>
                                                <div>
                                                    <h3 class="cv-target-title">Cơ hội bán hàng</h3>
                                                    <p class="cv-target-note">Cơ hội mới gắn với khách hàng</p>
                                                    <div class="cv-field-group">
                                                        <label class="cv-label" for="cvOppName">Tên cơ hội <span style="color:var(--cv-err)">*</span></label>
                                                        <input type="text" class="cv-input" id="cvOppName" name="opportunityName" required autocomplete="off" value="<c:out value='${defaultOppName}'/>">
                                                    </div>
                                                    <dl class="cv-fields">
                                                        <div><dt>Nhu cầu quan tâm</dt><dd><c:out value="${empty leadInterest ? dash : leadInterest}" /></dd></div>
                                                        <div><dt>Nguồn Lead</dt><dd><c:out value="${empty leadSource ? dash : leadSource}" /></dd></div>
                                                    </dl>
                                                </div>
                                            </li>
                                        </ul>
                                    </section>
                                </div>

                                <section class="cv-effects" aria-labelledby="cvEffects">
                                    <h2 id="cvEffects">Điều gì sẽ xảy ra khi chuyển đổi</h2>
                                    <ul>
                                        <li><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>Ba bản ghi được tạo trong một thao tác. Nếu có lỗi, hệ thống không lưu bản ghi nào.</li>
                                        <li><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>Hoạt động đã ghi trên Lead được chuyển sang khách hàng mới.</li>
                                        <li><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>Lead chuyển sang trạng thái <strong><c:out value="${convertedStatus}" /></strong> và không thể chỉnh sửa nữa.</li>
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

                        <%-- Kết quả: JavaScript điền dữ liệu sau khi servlet trả về thành công --%>
                        <div id="cvSuccess" hidden data-status="<c:out value='${convertedStatus}'/>" data-customer-url="<c:out value='${customerBase}'/>" data-contact-url="<c:out value='${contactBase}'/>" data-deal-url="<c:out value='${dealBase}'/>">
                            <div class="cv-panel cv-done" role="status">
                                <svg class="cv-ring" viewBox="0 0 52 52" aria-hidden="true"><circle class="cv-ring-c" cx="26" cy="26" r="24"/><path class="cv-ring-p" d="M15 27l8 8 14-16"/></svg>
                                <div>
                                    <h2 id="cvDoneTitle" tabindex="-1">Đã chuyển đổi Lead</h2>
                                    <p>Lead <strong><c:out value="${displayName}" /></strong> có trạng thái <span class="cv-badge cv-badge-ok"><c:out value="${convertedStatus}" /></span> và không thể chỉnh sửa nữa.</p>
                                </div>
                            </div>

                            <section class="cv-panel" style="margin-bottom:20px" aria-label="Bản ghi vừa tạo">
                                <div class="cv-result" id="cvResCustomer" hidden>
                                    <span class="cv-node"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-building"/></svg></span>
                                    <div><p class="cv-result-label">Khách hàng</p><p class="cv-result-id">#<span id="cvResCustomerId"></span></p></div>
                                    <a class="cv-link" id="cvResCustomerLink" href="#">Xem khách hàng</a>
                                </div>
                                <div class="cv-result" id="cvResContact" hidden>
                                    <span class="cv-node"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-user"/></svg></span>
                                    <div><p class="cv-result-label">Người liên hệ</p><p class="cv-result-id">#<span id="cvResContactId"></span></p></div>
                                    <a class="cv-link" id="cvResContactLink" href="#">Xem người liên hệ</a>
                                </div>
                                <div class="cv-result" id="cvResOpportunity" hidden>
                                    <span class="cv-node"><svg class="cv-icon" aria-hidden="true"><use href="#cv-i-brief"/></svg></span>
                                    <div><p class="cv-result-label">Cơ hội bán hàng</p><p class="cv-result-id">#<span id="cvResOpportunityId"></span></p></div>
                                    <a class="cv-link" id="cvResOpportunityLink" href="#">Xem cơ hội</a>
                                </div>
                            </section>

                            <div class="cv-alert cv-alert-ok" id="cvResActivities" role="status" hidden>
                                <svg class="cv-icon" aria-hidden="true"><use href="#cv-i-check"/></svg>
                                <span>Đã chuyển <strong id="cvResActivityCount"></strong> hoạt động của Lead sang khách hàng mới.</span>
                            </div>

                            <div class="cv-actions">
                                <a class="cv-btn cv-btn-primary" href="${listUrl}">Quay lại danh sách Lead</a>
                            </div>
                        </div>

                        <dialog id="cvDialog" class="cv-dialog" aria-labelledby="cvDialogTitle">
                            <h2 id="cvDialogTitle">Chuyển đổi Lead này?</h2>
                            <p>Hệ thống sẽ chuyển Lead <strong><c:out value="${displayName}" /></strong> thành:</p>
                            <ul>
                                <li>một Khách hàng doanh nghiệp</li>
                                <li>một Người liên hệ</li>
                                <li>một Cơ hội bán hàng tên <strong id="cvDialogOpp"></strong></li>
                            </ul>
                            <p>Sau khi chuyển đổi, bạn không thể chỉnh sửa Lead.</p>
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
                                var dialogOpp = document.getElementById('cvDialogOpp');
                                var ok = document.getElementById('cvDialogOk');
                                var cancel = document.getElementById('cvDialogCancel');
                                var wrap = document.getElementById('cvFormWrap');
                                var success = document.getElementById('cvSuccess');
                                var errBox = document.getElementById('cvError');
                                var errText = document.getElementById('cvErrorText');
                                var badge = document.getElementById('cvLeadBadge');
                                var steps = document.querySelectorAll('#cvSteps .cv-step');
                                var original = submit.innerHTML;
                                var sending = false;
                                var finished = false;

                                function toast(type, message) {
                                    if (typeof window.showToast === 'function') { window.showToast(type, message); }
                                }

                                function setStep(n) {
                                    for (var i = 0; i < steps.length; i++) {
                                        var li = steps[i];
                                        li.classList.toggle('is-done', i + 1 < n);
                                        li.classList.toggle('is-current', i + 1 === n);
                                        if (i + 1 === n) { li.setAttribute('aria-current', 'step'); } else { li.removeAttribute('aria-current'); }
                                    }
                                }

                                function setBusy() {
                                    sending = true;
                                    submit.disabled = true;
                                    ok.disabled = true;
                                    submit.setAttribute('aria-busy', 'true');
                                    submit.textContent = '';
                                    var spinner = document.createElement('span');
                                    spinner.className = 'cv-spin';
                                    spinner.setAttribute('aria-hidden', 'true');
                                    submit.appendChild(spinner);
                                    submit.appendChild(document.createTextNode('Đang chuyển đổi...'));
                                }

                                function reset() {
                                    sending = false;
                                    submit.disabled = false;
                                    ok.disabled = false;
                                    submit.removeAttribute('aria-busy');
                                    submit.innerHTML = original;
                                }

                                function fail(message) {
                                    reset();
                                    setStep(1);
                                    errText.textContent = message;
                                    errBox.hidden = false;
                                    errBox.scrollIntoView({ block: 'nearest' });
                                    toast('error', message);
                                }

                                function htmlMessage(text) {
                                    if (!text || text.indexOf('<') < 0 || typeof DOMParser !== 'function') { return ''; }
                                    try {
                                        var doc = new DOMParser().parseFromString(text, 'text/html');
                                        var paragraphs = doc.querySelectorAll('p');
                                        for (var i = 0; i < paragraphs.length; i++) {
                                            var label = paragraphs[i].querySelector('b');
                                            if (label && /^message$/i.test(label.textContent.trim())) {
                                                return paragraphs[i].textContent.replace(label.textContent, '').trim();
                                            }
                                        }
                                    } catch (e) { }
                                    return '';
                                }

                                function failMessage(status, data, text) {
                                    var detail = '';
                                    if (data && typeof data.message === 'string') { detail = data.message; }
                                    else if (data && typeof data.error === 'string') { detail = data.error; }
                                    else { detail = htmlMessage(text); }
                                    if (status === 401) { return 'Bạn chưa đăng nhập hoặc phiên đã hết hạn. Hãy đăng nhập lại rồi thử lại.'; }
                                    if (status === 403) { return 'Bạn không có quyền chuyển đổi Lead này.'; }
                                    if (status >= 500) { return 'Hệ thống gặp lỗi khi chuyển đổi. Tải lại trang để kiểm tra trạng thái Lead trước khi thử lại.'; }
                                    if (detail) { return 'Không thể chuyển đổi: ' + detail; }
                                    return 'Không thể chuyển đổi Lead. Kiểm tra thông tin rồi thử lại.';
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
                                    finished = true;
                                    sending = false;
                                    fill('Customer', payload.customerId, success.getAttribute('data-customer-url'));
                                    fill('Contact', payload.contactId, success.getAttribute('data-contact-url'));
                                    fill('Opportunity', payload.opportunityId, success.getAttribute('data-deal-url'));
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
                                    setStep(4);
                                    document.getElementById('cvDoneTitle').focus();
                                    toast('success', 'Đã chuyển đổi Lead.');
                                }

                                function send() {
                                    if (sending || finished) { return; }
                                    errBox.hidden = true;
                                    setBusy();
                                    var headers = {
                                        'Accept': 'application/json',
                                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                                    };
                                    var userId = (form.getAttribute('data-user-id') || '').trim();
                                    if (/^[\w-]+$/.test(userId)) { headers['X-User-Id'] = userId; }
                                    var controller = typeof AbortController === 'function' ? new AbortController() : null;
                                    var timer = controller ? setTimeout(function () { controller.abort(); }, 30000) : null;
                                    fetch(form.action, {
                                        method: 'POST',
                                        credentials: 'same-origin',
                                        headers: headers,
                                        body: new URLSearchParams(new FormData(form)).toString(),
                                        signal: controller ? controller.signal : undefined
                                    }).then(function (res) {
                                        return res.text().then(function (text) {
                                            var data = null;
                                            try { data = text ? JSON.parse(text) : null; } catch (e) { data = null; }
                                            if (data !== null && typeof data !== 'object') { data = null; }
                                            return { ok: res.ok, status: res.status, data: data, text: text };
                                        });
                                    }).then(function (r) {
                                        if (timer) { clearTimeout(timer); }
                                        var d = r.data;
                                        if (r.ok && !d) {
                                            fail('Máy chủ phản hồi không đúng định dạng. Tải lại trang để kiểm tra trạng thái Lead trước khi thử lại.');
                                            return;
                                        }
                                        if (!r.ok || d.success === false || d.error) {
                                            fail(failMessage(r.status, d, r.text));
                                            return;
                                        }
                                        done(d.data && typeof d.data === 'object' ? d.data : d);
                                    }).catch(function (err) {
                                        if (timer) { clearTimeout(timer); }
                                        if (err && err.name === 'AbortError') {
                                            fail('Máy chủ phản hồi quá lâu. Tải lại trang để kiểm tra trạng thái Lead trước khi thử lại.');
                                        } else {
                                            fail('Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.');
                                        }
                                    });
                                }

                                form.addEventListener('submit', function (event) {
                                    event.preventDefault();
                                    if (sending || finished) { return; }
                                    nameInput.value = nameInput.value.trim();
                                    if (!nameInput.value) {
                                        nameInput.setCustomValidity('Nhập tên cơ hội.');
                                        nameInput.reportValidity();
                                        return;
                                    }
                                    if (dialog && typeof dialog.showModal === 'function') {
                                        dialogOpp.textContent = nameInput.value;
                                        setStep(2);
                                        dialog.showModal();
                                        cancel.focus();
                                    } else if (window.confirm('Chuyển đổi Lead này? Sau đó Lead không thể chỉnh sửa.')) {
                                        setStep(2);
                                        send();
                                    }
                                });

                                nameInput.addEventListener('input', function () { nameInput.setCustomValidity(''); });
                                if (ok) { ok.addEventListener('click', function () { dialog.close(); send(); }); }
                                if (cancel) { cancel.addEventListener('click', function () { dialog.close(); submit.focus(); }); }
                                if (dialog) {
                                    dialog.addEventListener('close', function () { if (!sending && !finished) { setStep(1); } });
                                    dialog.addEventListener('click', function (e) {
                                        if (e.target !== dialog) { return; }
                                        var box = dialog.getBoundingClientRect();
                                        if (e.clientX < box.left || e.clientX > box.right || e.clientY < box.top || e.clientY > box.bottom) { dialog.close(); }
                                    });
                                }
                                window.addEventListener('beforeunload', function (e) {
                                    if (sending) { e.preventDefault(); e.returnValue = ''; }
                                });
                            })();
                        </script>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </main>
</div>

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