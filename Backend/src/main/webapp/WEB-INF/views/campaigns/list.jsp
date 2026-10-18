<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Chiến dịch Marketing | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/campaigns.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
        <main class="main-content">
            <div class="campaign-page-container">
                <!-- Breadcrumbs -->
                <div class="exec-breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fa fa-home"></i> Trang chủ</a>
                    <span class="sep"><i class="fa fa-chevron-right"></i></span>
                    <span>Marketing & Truyền thông</span>
                    <span class="sep"><i class="fa fa-chevron-right"></i></span>
                    <span style="color: var(--crm-text-heading); font-weight: 600;">Chiến dịch Marketing</span>
                </div>

                <!-- Toast Messages -->
                <c:if test="${param.success eq 'true' or param.created eq 'true' or param.updated eq 'true'}">
                    <div class="toast-banner toast-success">
                        <div><i class="fa fa-circle-check" style="margin-right: 8px;"></i> Thao tác cập nhật chiến dịch thành công!</div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty error or not empty errorMessage}">
                    <div class="toast-banner toast-error">
                        <div>
                            <i class="fa fa-triangle-exclamation" style="margin-right: 8px;"></i>
                            <c:out value="${not empty error ? error : errorMessage}" />
                        </div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>

                <!-- Hero Header -->
                <div class="exec-hero">
                    <div class="hero-title-group">
                        <h1>
                            <i class="fa fa-bullhorn"></i> Chiến dịch Marketing & Hiệu quả Doanh thu
                        </h1>
                        <p>
                            Theo dõi tập trung các chiến dịch tiếp thị trên toàn hệ thống. Đo lường số lượng Lead sinh ra, tỷ lệ chuyển đổi sang Cơ hội bán hàng và Doanh thu thực tế chốt được (Closed Won) theo từng chiến dịch.
                        </p>
                    </div>
                    <div class="hero-actions">
                        <a href="${pageContext.request.contextPath}/campaigns" class="btn-exec-secondary">
                            <i class="fa fa-rotate"></i> Tải lại
                        </a>
                        <a href="${pageContext.request.contextPath}/campaigns/create" class="btn-exec-primary">
                            <i class="fa fa-plus-circle"></i> + Thêm chiến dịch mới
                        </a>
                    </div>
                </div>

                <!-- Policy Callout -->
                <div class="policy-callout">
                    <div class="policy-icon">
                        <i class="fa fa-chart-line"></i>
                    </div>
                    <div class="policy-content">
                        <h4>Chính sách Đo lường ROI Marketing (User Story S4-03)</h4>
                        <p>
                            Hệ thống duy trì liên kết nguồn gốc <strong>campaign_id</strong> xuyên suốt từ Lead (thủ công, Excel, Web form) đến Opportunity. Chỉ số <strong>Đã chốt (VNĐ)</strong> được tổng hợp từ các cơ hội có giai đoạn thắng thực tế, đảm bảo không trùng lặp và phản ánh chính xác hiệu quả sinh doanh thu của từng chiến dịch.
                        </p>
                        <div class="policy-badges">
                            <span class="policy-pill"><i class="fa fa-tags"></i> Phân loại đa kênh</span>
                            <span class="policy-pill shield"><i class="fa fa-shield-halved"></i> Giữ toàn vẹn liên kết Lead & Cơ hội</span>
                            <span class="policy-pill revenue"><i class="fa fa-coins"></i> Doanh thu thắng thực (Closed Won)</span>
                        </div>
                    </div>
                </div>

                <!-- 4 KPI Cards -->
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-icon-box metric-icon-blue">
                            <i class="fa fa-bullhorn"></i>
                        </div>
                        <div class="metric-meta">
                            <span class="metric-label">Tổng chiến dịch</span>
                            <span class="metric-value">${not empty totalCampaigns ? totalCampaigns : 0}</span>
                            <span class="metric-desc">Đã thiết lập trong hệ thống</span>
                        </div>
                    </div>

                    <div class="metric-card">
                        <div class="metric-icon-box metric-icon-emerald">
                            <i class="fa fa-play-circle"></i>
                        </div>
                        <div class="metric-meta">
                            <span class="metric-label">Đang triển khai</span>
                            <span class="metric-value">${not empty activeCampaigns ? activeCampaigns : 0}</span>
                            <span class="metric-desc">Chiến dịch trạng thái ACTIVE</span>
                        </div>
                    </div>

                    <div class="metric-card">
                        <div class="metric-icon-box metric-icon-indigo">
                            <i class="fa fa-users"></i>
                        </div>
                        <div class="metric-meta">
                            <span class="metric-label">Tổng Lead phát sinh</span>
                            <span class="metric-value">${not empty totalLeads ? totalLeads : 0}</span>
                            <span class="metric-desc">Gắn nguồn từ các chiến dịch</span>
                        </div>
                    </div>

                    <div class="metric-card">
                        <div class="metric-icon-box metric-icon-amber">
                            <i class="fa fa-hand-holding-dollar"></i>
                        </div>
                        <div class="metric-meta">
                            <span class="metric-label">Doanh thu đã chốt</span>
                            <span class="metric-value">
                                <fmt:formatNumber value="${not empty totalWonRevenue ? totalWonRevenue : 0}" pattern="#,##0" /> đ
                            </span>
                            <span class="metric-desc">Tổng giá trị Closed Won</span>
                        </div>
                    </div>
                </div>

                <!-- Filter Section -->
                <form id="filterForm" action="${pageContext.request.contextPath}/campaigns" method="get" class="filter-section">
                    <div class="filter-controls">
                        <div class="search-box">
                            <i class="fa fa-search"></i>
                            <input name="keyword" type="search" placeholder="Tìm kiếm theo tên chiến dịch..." value="<c:out value='${keyword}'/>">
                        </div>
                        <select name="channel" class="select-filter">
                            <option value="">-- Tất cả kênh tiếp thị --</option>
                            <option value="Email" ${channel eq 'Email' ? 'selected' : ''}>Email Marketing</option>
                            <option value="Social" ${channel eq 'Social' ? 'selected' : ''}>Social Media</option>
                            <option value="Search" ${channel eq 'Search' ? 'selected' : ''}>Search Ads (SEM/SEO)</option>
                            <option value="Event" ${channel eq 'Event' ? 'selected' : ''}>Sự kiện & Hội thảo</option>
                        </select>
                        <select name="status" class="select-filter">
                            <option value="">-- Tất cả trạng thái --</option>
                            <option value="ACTIVE" ${status eq 'ACTIVE' ? 'selected' : ''}>Đang chạy (ACTIVE)</option>
                            <option value="PLANNING" ${status eq 'PLANNING' ? 'selected' : ''}>Lên kế hoạch (PLANNING)</option>
                            <option value="COMPLETED" ${status eq 'COMPLETED' ? 'selected' : ''}>Đã hoàn thành (COMPLETED)</option>
                            <option value="CANCELLED" ${status eq 'CANCELLED' ? 'selected' : ''}>Đã hủy (CANCELLED)</option>
                        </select>
                    </div>
                    <div style="display: flex; gap: 8px;">
                        <button type="submit" class="btn-exec-primary" style="padding: 9px 18px;">
                            <i class="fa fa-filter"></i> Lọc
                        </button>
                        <c:if test="${not empty keyword or not empty channel or not empty status}">
                            <a href="${pageContext.request.contextPath}/campaigns" class="btn-exec-light">
                                <i class="fa fa-rotate-left"></i> Đặt lại
                            </a>
                        </c:if>
                    </div>
                </form>

                <!-- Table Card -->
                <div class="exec-table-card">
                    <div class="table-header-bar">
                        <h2 class="table-header-title">
                            <i class="fa fa-list-check"></i> Danh sách Chiến dịch Marketing
                        </h2>
                    </div>

                    <div class="table-responsive">
                        <table class="exec-table">
                            <thead>
                                <tr>
                                    <th style="width: 60px; text-align: center;">ID</th>
                                    <th>Tên chiến dịch</th>
                                    <th>Kênh</th>
                                    <th style="text-align: right;">Ngân sách</th>
                                    <th style="text-align: center;">Số Lead</th>
                                    <th style="text-align: center;">Số Cơ hội</th>
                                    <th style="text-align: right;">Đã chốt (VNĐ)</th>
                                    <th style="text-align: center;">Thời gian chạy</th>
                                    <th style="text-align: center;">Trạng thái</th>
                                    <th style="width: 100px; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="campaignList" value="${not empty campaigns ? campaigns : list}" />
                                <c:choose>
                                    <c:when test="${not empty campaignList}">
                                        <c:forEach var="item" items="${campaignList}">
                                            <tr>
                                                <td style="text-align: center; font-weight: 700; color: var(--crm-text-muted);">
                                                    #${item.campaignId}
                                                </td>
                                                <td>
                                                    <div style="font-weight: 600; color: var(--crm-text-heading); font-size: 14px;">
                                                        <a href="${pageContext.request.contextPath}/campaigns/detail?id=${item.campaignId}" style="color: inherit; text-decoration: none;">
                                                            <c:out value="${item.campaignName}" />
                                                        </a>
                                                    </div>
                                                    <c:if test="${not empty item.description}">
                                                        <div style="font-size: 12px; color: var(--crm-text-muted); margin-top: 2px;">
                                                            <c:out value="${item.description}" />
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.channel eq 'Email'}"><span class="channel-badge channel-email"><i class="fa fa-envelope"></i> Email</span></c:when>
                                                        <c:when test="${item.channel eq 'Social'}"><span class="channel-badge channel-social"><i class="fa fa-share-nodes"></i> Social</span></c:when>
                                                        <c:when test="${item.channel eq 'Search'}"><span class="channel-badge channel-search"><i class="fa fa-magnifying-glass"></i> Search</span></c:when>
                                                        <c:when test="${item.channel eq 'Event'}"><span class="channel-badge channel-event"><i class="fa fa-calendar-days"></i> Event</span></c:when>
                                                        <c:otherwise><span class="channel-badge channel-default"><c:out value="${item.channel}" default="Khác" /></span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: right; font-weight: 600;">
                                                    <fmt:formatNumber value="${item.budget}" pattern="#,##0" /> đ
                                                </td>
                                                <td style="text-align: center;">
                                                    <span class="count-pill count-pill-blue" title="${item.leadCount} Lead sinh ra từ chiến dịch">
                                                        ${item.leadCount}
                                                    </span>
                                                </td>
                                                <td style="text-align: center;">
                                                    <span class="count-pill count-pill-emerald" title="${item.opportunityCount} Cơ hội được tạo">
                                                        ${item.opportunityCount}
                                                    </span>
                                                </td>
                                                <td style="text-align: right;">
                                                    <span class="revenue-text">
                                                        <fmt:formatNumber value="${item.closedValue}" pattern="#,##0" /> đ
                                                    </span>
                                                </td>
                                                <td style="text-align: center; font-size: 12px; color: var(--crm-text-muted);">
                                                    <fmt:formatDate value="${item.startDate}" pattern="dd/MM/yyyy" />
                                                    <c:if test="${not empty item.endDate}">
                                                        <br/>→ <fmt:formatDate value="${item.endDate}" pattern="dd/MM/yyyy" />
                                                    </c:if>
                                                </td>
                                                <td style="text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${item.status eq 'ACTIVE'}"><span class="status-badge status-active"><i class="fa fa-circle-dot"></i> Đang chạy</span></c:when>
                                                        <c:when test="${item.status eq 'COMPLETED'}"><span class="status-badge status-completed"><i class="fa fa-circle-check"></i> Hoàn thành</span></c:when>
                                                        <c:when test="${item.status eq 'CANCELLED'}"><span class="status-badge status-cancelled"><i class="fa fa-circle-xmark"></i> Đã hủy</span></c:when>
                                                        <c:otherwise><span class="status-badge status-planning"><i class="fa fa-clock"></i> Kế hoạch</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <div class="action-btn-group">
                                                        <a href="${pageContext.request.contextPath}/campaigns/detail?id=${item.campaignId}"
                                                           class="btn-action"
                                                           title="Xem chi tiết hiệu quả">
                                                            <i class="fa fa-eye"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/campaigns/edit?id=${item.campaignId}"
                                                           class="btn-action edit"
                                                           title="Chỉnh sửa chiến dịch">
                                                            <i class="fa fa-pen-to-square"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="10">
                                                <div class="empty-state">
                                                    <div class="empty-state-icon"><i class="fa fa-bullhorn"></i></div>
                                                    <h3>Chưa tìm thấy chiến dịch nào</h3>
                                                    <p>Hãy bấm "Thêm chiến dịch mới" để bắt đầu khai báo và đo lường ROI chiến dịch.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

<c:if test="${not empty error}">
    <input type="hidden" id="toast-campaign-err" value="<c:out value='${error}'/>">
</c:if>
<c:if test="${not empty message}">
    <input type="hidden" id="toast-campaign-msg" value="<c:out value='${message}'/>">
</c:if>
<script>
    (function() {
        var errInput = document.getElementById('toast-campaign-err');
        var msgInput = document.getElementById('toast-campaign-msg');
        if (errInput && errInput.value && typeof window.showToast === 'function') {
            window.showToast('error', errInput.value);
        }
        if (msgInput && msgInput.value && typeof window.showToast === 'function') {
            window.showToast('success', msgInput.value);
        }

        try {
            var urlParams = new URLSearchParams(window.location.search);
            var urlErr = urlParams.get('error');
            var urlSuccess = urlParams.get('success');
            var urlMsg = urlParams.get('msg');
            var hasParamToast = false;

            if (urlErr) {
                if (typeof window.showToast === 'function') {
                    window.showToast('error', urlErr === '1' ? 'Đã xảy ra lỗi khi xử lý chiến dịch.' : urlErr);
                }
                urlParams.delete('error');
                hasParamToast = true;
            } else if (urlSuccess) {
                if (typeof window.showToast === 'function') {
                    window.showToast('success', urlSuccess === '1' || urlSuccess === 'true' ? 'Thao tác chiến dịch thành công!' : urlSuccess);
                }
                urlParams.delete('success');
                hasParamToast = true;
            } else if (urlMsg) {
                if (typeof window.showToast === 'function') {
                    window.showToast('info', urlMsg);
                }
                urlParams.delete('msg');
                hasParamToast = true;
            }

            if (hasParamToast && window.history && window.history.replaceState) {
                var remainingQuery = urlParams.toString();
                var newUrl = window.location.pathname + (remainingQuery ? ('?' + remainingQuery) : '') + window.location.hash;
                window.history.replaceState(null, document.title, newUrl);
            }
        } catch (e) {
            console.error('Error handling URL params in campaigns/list.jsp:', e);
        }
    })();
</script>
</body>
</html>
