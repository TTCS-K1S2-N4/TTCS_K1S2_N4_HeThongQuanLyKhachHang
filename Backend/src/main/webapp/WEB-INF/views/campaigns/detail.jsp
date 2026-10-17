<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết Chiến dịch Marketing | CRM</title>
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
                    <a href="${pageContext.request.contextPath}/campaigns">Chiến dịch Marketing</a>
                    <span class="sep"><i class="fa fa-chevron-right"></i></span>
                    <span style="color: var(--crm-text-heading); font-weight: 600;">Chi tiết chiến dịch</span>
                </div>

                <!-- Toast Messages -->
                <c:if test="${param.created eq 'true'}">
                    <div class="toast-banner toast-success">
                        <div><i class="fa fa-circle-check" style="margin-right: 8px;"></i> Khai báo chiến dịch mới thành công!</div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>
                <c:if test="${param.updated eq 'true'}">
                    <div class="toast-banner toast-success">
                        <div><i class="fa fa-circle-check" style="margin-right: 8px;"></i> Cập nhật thông tin chiến dịch thành công!</div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>

                <!-- Hero Section -->
                <div class="exec-hero">
                    <div class="hero-title-group">
                        <h1>
                            <i class="fa fa-bullhorn"></i> <c:out value="${not empty campaign.campaignName ? campaign.campaignName : campaign.name}" />
                        </h1>
                        <p>
                            <c:out value="${not empty campaign.description ? campaign.description : 'Theo dõi hiệu quả sinh Lead, chuyển đổi Cơ hội và Doanh thu thực tế chốt được.'}" />
                        </p>
                    </div>
                    <div class="hero-actions">
                        <a href="${pageContext.request.contextPath}/campaigns" class="btn-exec-secondary">
                            <i class="fa fa-arrow-left"></i> Quay lại danh sách
                        </a>
                        <a href="${pageContext.request.contextPath}/campaigns/edit?id=${not empty campaign.campaignId ? campaign.campaignId : campaign.id}" class="btn-exec-primary">
                            <i class="fa fa-pen-to-square"></i> Chỉnh sửa chiến dịch
                        </a>
                    </div>
                </div>

                <!-- 3 Performance Metric KPI Cards (S4-03-AC-03 Drill-down) -->
                <div class="metrics-grid" style="grid-template-columns: repeat(3, 1fr); margin-bottom: 24px;">
                    <div class="metric-card metric-card-interactive theme-blue active" id="card-metric-leads"
                         tabindex="0" role="button" aria-label="Xem danh sách Lead"
                         onclick="switchDrilldownTab('leads')" onkeydown="handleKeyDrilldown(event, 'leads')">
                        <div class="metric-card-body">
                            <div class="metric-icon-box metric-icon-blue">
                                <i class="fa fa-users"></i>
                            </div>
                            <div class="metric-meta">
                                <span class="metric-label">Tổng Lead sinh ra</span>
                                <span class="metric-value">
                                    ${not empty campaign.leadCount ? campaign.leadCount : (not empty leadCount ? leadCount : 0)}
                                </span>
                                <span class="metric-desc">Lead được gắn nguồn từ chiến dịch</span>
                            </div>
                        </div>
                        <div class="metric-card-footer">
                            <span>Xem danh sách Lead</span>
                            <i class="fa fa-arrow-right"></i>
                        </div>
                    </div>

                    <div class="metric-card metric-card-interactive theme-indigo" id="card-metric-opps"
                         tabindex="0" role="button" aria-label="Xem danh sách Cơ hội"
                         onclick="switchDrilldownTab('opps')" onkeydown="handleKeyDrilldown(event, 'opps')">
                        <div class="metric-card-body">
                            <div class="metric-icon-box metric-icon-indigo">
                                <i class="fa fa-briefcase"></i>
                            </div>
                            <div class="metric-meta">
                                <span class="metric-label">Số Cơ hội (Opportunity)</span>
                                <span class="metric-value">
                                    ${not empty campaign.opportunityCount ? campaign.opportunityCount : (not empty opportunityCount ? opportunityCount : 0)}
                                </span>
                                <span class="metric-desc">Cơ hội chuyển đổi thành công</span>
                            </div>
                        </div>
                        <div class="metric-card-footer">
                            <span>Xem danh sách Cơ hội</span>
                            <i class="fa fa-arrow-right"></i>
                        </div>
                    </div>

                    <div class="metric-card metric-card-interactive theme-emerald" id="card-metric-won"
                         tabindex="0" role="button" aria-label="Xem giao dịch đã chốt"
                         onclick="switchDrilldownTab('won')" onkeydown="handleKeyDrilldown(event, 'won')">
                        <div class="metric-card-body">
                            <div class="metric-icon-box metric-icon-emerald">
                                <i class="fa fa-hand-holding-dollar"></i>
                            </div>
                            <div class="metric-meta">
                                <span class="metric-label">Doanh thu đã chốt (Closed Won)</span>
                                <span class="metric-value" style="color: #047857;">
                                    <fmt:formatNumber value="${not empty campaign.closedValue ? campaign.closedValue : (not empty closedValue ? closedValue : 0)}" pattern="#,##0" /> đ
                                </span>
                                <span class="metric-desc">Giá trị hợp đồng thực tế mang lại</span>
                            </div>
                        </div>
                        <div class="metric-card-footer">
                            <span>Xem giao dịch đã chốt</span>
                            <i class="fa fa-arrow-right"></i>
                        </div>
                    </div>
                </div>

                <!-- Executive Drilldown Section: Leads, Opportunities, Closed Won Deals -->
                <div class="drilldown-section" id="drilldown-section" style="margin-bottom: 28px;">
                    <div class="drilldown-header">
                        <div class="drilldown-title-bar">
                            <div>
                                <h3><i class="fa fa-chart-pie"></i> Dữ liệu chuyển đổi chi tiết của Chiến dịch</h3>
                                <p>Xem chi tiết danh sách Lead, Cơ hội kinh doanh và Doanh thu đã chốt thực tế từ Database</p>
                            </div>
                            <div class="drilldown-search">
                                <i class="fa fa-magnifying-glass"></i>
                                <input type="text" id="drilldownSearchInput" placeholder="Tìm kiếm nhanh trong bảng..." onkeyup="filterDrilldownTable()">
                            </div>
                        </div>

                        <!-- Tab Headers -->
                        <div class="drilldown-nav-tabs" role="tablist">
                            <button type="button" class="drilldown-tab-btn active" id="tab-btn-leads" role="tab"
                                    aria-selected="true" aria-controls="panel-leads" onclick="switchDrilldownTab('leads')">
                                <i class="fa fa-users"></i>
                                <span>Danh sách Lead sinh ra</span>
                                <span class="tab-badge">${not empty campaignLeads ? campaignLeads.size() : (not empty campaign.leadCount ? campaign.leadCount : 0)}</span>
                            </button>

                            <button type="button" class="drilldown-tab-btn" id="tab-btn-opps" role="tab"
                                    aria-selected="false" aria-controls="panel-opps" onclick="switchDrilldownTab('opps')">
                                <i class="fa fa-briefcase"></i>
                                <span>Cơ hội bán hàng (Opportunity)</span>
                                <span class="tab-badge">${not empty campaignOpportunities ? campaignOpportunities.size() : (not empty campaign.opportunityCount ? campaign.opportunityCount : 0)}</span>
                            </button>

                            <button type="button" class="drilldown-tab-btn" id="tab-btn-won" role="tab"
                                    aria-selected="false" aria-controls="panel-won" onclick="switchDrilldownTab('won')">
                                <i class="fa fa-trophy" style="color: #059669;"></i>
                                <span>Doanh thu đã chốt (Closed Won)</span>
                                <span class="tab-badge badge-success">${not empty campaignClosedWonOpps ? campaignClosedWonOpps.size() : 0}</span>
                            </button>
                        </div>
                    </div>

                    <!-- TAB 1: LEADS TABLE -->
                    <div class="drilldown-tab-panel active" id="panel-leads" role="tabpanel" aria-labelledby="tab-btn-leads">
                        <div class="table-responsive">
                            <table class="exec-table" id="table-leads">
                                <thead>
                                    <tr>
                                        <th style="width: 100px;">Mã Lead</th>
                                        <th>Họ tên Lead</th>
                                        <th>Liên hệ (Email & SĐT)</th>
                                        <th>Công ty / Tổ chức</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày tạo</th>
                                        <th>Nhân viên phụ trách</th>
                                        <th style="text-align: right; width: 120px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty campaignLeads}">
                                            <c:forEach items="${campaignLeads}" var="lead">
                                                <tr class="drilldown-row">
                                                    <td><span class="code-badge">#L-${lead.leadId}</span></td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}" class="link-lead-detail">
                                                            <c:out value="${lead.fullName}" default="(Chưa có tên)" />
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <div style="font-size: 13px; color: var(--crm-text-heading);"><c:out value="${lead.email}" default="—" /></div>
                                                        <c:if test="${not empty lead.phone}">
                                                            <div style="font-size: 11px; color: var(--crm-text-muted);"><i class="fa fa-phone" style="font-size: 10px;"></i> <c:out value="${lead.phone}" /></div>
                                                        </c:if>
                                                    </td>
                                                    <td><c:out value="${lead.company}" default="—" /></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${lead.status eq 'NEW'}"><span class="status-badge status-planning"><i class="fa fa-bolt"></i> Mới (NEW)</span></c:when>
                                                            <c:when test="${lead.status eq 'CONTACTED'}"><span class="status-badge status-active"><i class="fa fa-phone"></i> Đã liên hệ</span></c:when>
                                                            <c:when test="${lead.status eq 'QUALIFIED'}"><span class="status-badge status-completed"><i class="fa fa-check"></i> Đủ điều kiện</span></c:when>
                                                            <c:when test="${lead.status eq 'CONVERTED'}"><span class="status-badge status-completed"><i class="fa fa-rotate"></i> Đã chuyển đổi</span></c:when>
                                                            <c:when test="${lead.status eq 'UNQUALIFIED'}"><span class="status-badge status-cancelled"><i class="fa fa-ban"></i> Không đạt</span></c:when>
                                                            <c:otherwise><span class="status-badge status-planning"><c:out value="${lead.status}" default="NEW" /></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${lead.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                    <td>
                                                        <i class="fa fa-user" style="color: var(--crm-text-muted); margin-right: 4px;"></i>
                                                        <c:out value="${not empty lead.ownerName ? lead.ownerName : 'Chưa phân công'}" />
                                                    </td>
                                                    <td style="text-align: right;">
                                                        <a href="${pageContext.request.contextPath}/leads/detail?id=${lead.leadId}" class="btn-table-action" title="Xem hồ sơ chi tiết Lead">
                                                            <i class="fa fa-eye"></i> Chi tiết
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr class="empty-state-row">
                                                <td colspan="8">
                                                    <div class="empty-state">
                                                        <div class="empty-state-icon"><i class="fa fa-user-slash"></i></div>
                                                        <h3>Chưa có Lead nào gắn với chiến dịch này</h3>
                                                        <p>Các khách hàng tiềm năng sinh ra từ chiến dịch sẽ tự động xuất hiện tại đây.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- TAB 2: OPPORTUNITIES TABLE -->
                    <div class="drilldown-tab-panel" id="panel-opps" role="tabpanel" aria-labelledby="tab-btn-opps">
                        <div class="table-responsive">
                            <table class="exec-table" id="table-opps">
                                <thead>
                                    <tr>
                                        <th style="width: 110px;">Mã Cơ hội</th>
                                        <th>Tên Cơ hội</th>
                                        <th>Khách hàng / Doanh nghiệp</th>
                                        <th>Giá trị cơ hội</th>
                                        <th>Giai đoạn pipeline</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày tạo / Dự kiến</th>
                                        <th>Nhân viên phụ trách</th>
                                        <th style="text-align: right; width: 120px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty campaignOpportunities}">
                                            <c:forEach items="${campaignOpportunities}" var="opp">
                                                <tr class="drilldown-row">
                                                    <td><span class="code-badge">#OPP-${opp.opportunityId}</span></td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/deals/detail?id=${opp.opportunityId}" class="link-deal-detail">
                                                            <c:out value="${opp.title}" default="(Chưa đặt tên)" />
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <i class="fa fa-building" style="color: var(--crm-text-muted); margin-right: 4px;"></i>
                                                        <c:out value="${not empty opp.customerName ? opp.customerName : '—'}" />
                                                    </td>
                                                    <td style="font-weight: 700; color: var(--crm-primary);">
                                                        <fmt:formatNumber value="${opp.amount}" pattern="#,##0" /> VNĐ
                                                    </td>
                                                    <td>
                                                        <span class="policy-pill" style="font-size: 11px;">
                                                            <c:out value="${not empty opp.stageName ? opp.stageName : (not empty opp.stage ? opp.stage : 'Mới')}" />
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${opp.stage eq 'WON' or opp.status eq 'WON'}">
                                                                <span class="status-badge status-completed"><i class="fa fa-trophy"></i> Thắng (WON)</span>
                                                            </c:when>
                                                            <c:when test="${opp.stage eq 'LOST' or opp.status eq 'LOST'}">
                                                                <span class="status-badge status-cancelled"><i class="fa fa-circle-xmark"></i> Thua (LOST)</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge status-active"><i class="fa fa-spinner"></i> Đang xử lý</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty opp.closeDate}">
                                                                <fmt:formatDate value="${opp.closeDate}" pattern="dd/MM/yyyy" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatDate value="${opp.createdAt}" pattern="dd/MM/yyyy" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <i class="fa fa-user" style="color: var(--crm-text-muted); margin-right: 4px;"></i>
                                                        <c:out value="${not empty opp.ownerName ? opp.ownerName : 'Chưa phân công'}" />
                                                    </td>
                                                    <td style="text-align: right;">
                                                        <a href="${pageContext.request.contextPath}/deals/detail?id=${opp.opportunityId}" class="btn-table-action" title="Xem hồ sơ chi tiết Cơ hội">
                                                            <i class="fa fa-eye"></i> Chi tiết
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr class="empty-state-row">
                                                <td colspan="9">
                                                    <div class="empty-state">
                                                        <div class="empty-state-icon"><i class="fa fa-briefcase"></i></div>
                                                        <h3>Chưa có Cơ hội kinh doanh nào gắn với chiến dịch này</h3>
                                                        <p>Các cơ hội bán hàng được chuyển đổi từ Lead chiến dịch sẽ hiển thị tại đây.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- TAB 3: CLOSED WON REVENUE DEALS TABLE -->
                    <div class="drilldown-tab-panel" id="panel-won" role="tabpanel" aria-labelledby="tab-btn-won">
                        <!-- Revenue Match Verification Banner -->
                        <div class="won-revenue-banner">
                            <div class="won-revenue-info">
                                <div class="won-revenue-icon">
                                    <i class="fa fa-hand-holding-dollar"></i>
                                </div>
                                <div class="won-revenue-text">
                                    <h4>Tổng hợp Doanh thu Thực tế đã Chốt (Closed Won)</h4>
                                    <p>Chỉ tính các giao dịch thực sự thành công theo trạng thái WON đã xác nhận trong hệ thống</p>
                                </div>
                            </div>
                            <div>
                                <div class="won-revenue-number">
                                    <fmt:formatNumber value="${not empty campaign.closedValue ? campaign.closedValue : (not empty closedValue ? closedValue : 0)}" pattern="#,##0" /> VNĐ
                                </div>
                                <div class="won-revenue-match-tag">
                                    <i class="fa fa-circle-check"></i> Khớp 100% với thẻ chỉ số Doanh thu
                                </div>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="exec-table" id="table-won">
                                <thead>
                                    <tr>
                                        <th style="width: 110px;">Mã Giao dịch</th>
                                        <th>Tên Cơ hội & Hợp đồng</th>
                                        <th>Khách hàng / Doanh nghiệp</th>
                                        <th style="color: #047857;">Doanh thu thực tế (VNĐ)</th>
                                        <th>Trạng thái chốt</th>
                                        <th>Ngày chốt thành công</th>
                                        <th>Nhân viên phụ trách</th>
                                        <th style="text-align: right; width: 120px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty campaignClosedWonOpps}">
                                            <c:forEach items="${campaignClosedWonOpps}" var="opp">
                                                <tr class="drilldown-row">
                                                    <td><span class="code-badge" style="background: #ecfdf5; border-color: #a7f3d0; color: #047857;">#OPP-${opp.opportunityId}</span></td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/deals/detail?id=${opp.opportunityId}" class="link-deal-detail" style="font-weight: 700;">
                                                            <c:out value="${opp.title}" default="(Chưa đặt tên)" />
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <i class="fa fa-building" style="color: var(--crm-text-muted); margin-right: 4px;"></i>
                                                        <c:out value="${not empty opp.customerName ? opp.customerName : '—'}" />
                                                    </td>
                                                    <td style="font-size: 15px; font-weight: 800; color: #047857;">
                                                        + <fmt:formatNumber value="${opp.amount}" pattern="#,##0" /> VNĐ
                                                    </td>
                                                    <td>
                                                        <span class="status-badge status-completed">
                                                            <i class="fa fa-trophy"></i> CHỐT THẮNG (WON)
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <i class="fa fa-calendar-check" style="color: #059669; margin-right: 4px;"></i>
                                                        <c:choose>
                                                            <c:when test="${not empty opp.closeDate}">
                                                                <fmt:formatDate value="${opp.closeDate}" pattern="dd/MM/yyyy" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatDate value="${opp.createdAt}" pattern="dd/MM/yyyy" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <i class="fa fa-user-tie" style="color: var(--crm-text-muted); margin-right: 4px;"></i>
                                                        <c:out value="${not empty opp.ownerName ? opp.ownerName : 'Chưa phân công'}" />
                                                    </td>
                                                    <td style="text-align: right;">
                                                        <a href="${pageContext.request.contextPath}/deals/detail?id=${opp.opportunityId}" class="btn-table-action" title="Xem chi tiết giao dịch chốt">
                                                            <i class="fa fa-eye"></i> Chi tiết
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr class="empty-state-row">
                                                <td colspan="8">
                                                    <div class="empty-state">
                                                        <div class="empty-state-icon"><i class="fa fa-hand-holding-dollar"></i></div>
                                                        <h3>Chưa có giao dịch chốt thắng (Closed Won) từ chiến dịch này</h3>
                                                        <p>Khi các cơ hội bán hàng được chốt thành công với trạng thái WON, doanh thu sẽ hiển thị và tự động tổng hợp tại đây.</p>
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

                <!-- Detail Info Card -->
                <div class="exec-detail-card">
                    <div class="exec-detail-header">
                        <h2>
                            <i class="fa fa-circle-info" style="color: var(--crm-primary);"></i>
                            Thông tin cấu hình & Kế hoạch chiến dịch
                        </h2>
                        <div>
                            <c:choose>
                                <c:when test="${campaign.status eq 'ACTIVE'}"><span class="status-badge status-active"><i class="fa fa-circle-dot"></i> Đang chạy (ACTIVE)</span></c:when>
                                <c:when test="${campaign.status eq 'COMPLETED'}"><span class="status-badge status-completed"><i class="fa fa-circle-check"></i> Đã hoàn thành (COMPLETED)</span></c:when>
                                <c:when test="${campaign.status eq 'CANCELLED'}"><span class="status-badge status-cancelled"><i class="fa fa-circle-xmark"></i> Đã hủy (CANCELLED)</span></c:when>
                                <c:otherwise><span class="status-badge status-planning"><i class="fa fa-clock"></i> Lên kế hoạch (PLANNING)</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="exec-detail-body">
                        <div class="detail-grid">
                            <div class="detail-item">
                                <span class="detail-label">Kênh tiếp thị</span>
                                <div class="detail-value">
                                    <c:choose>
                                        <c:when test="${campaign.channel eq 'Email'}"><span class="channel-badge channel-email"><i class="fa fa-envelope"></i> Email Marketing</span></c:when>
                                        <c:when test="${campaign.channel eq 'Social'}"><span class="channel-badge channel-social"><i class="fa fa-share-nodes"></i> Social Media</span></c:when>
                                        <c:when test="${campaign.channel eq 'Search'}"><span class="channel-badge channel-search"><i class="fa fa-magnifying-glass"></i> Search Ads (SEM/SEO)</span></c:when>
                                        <c:when test="${campaign.channel eq 'Event'}"><span class="channel-badge channel-event"><i class="fa fa-calendar-days"></i> Sự kiện & Hội thảo</span></c:when>
                                        <c:otherwise><span class="channel-badge channel-default"><c:out value="${campaign.channel}" default="Chưa xác định" /></span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Ngân sách dự toán</span>
                                <span class="detail-value" style="font-size: 16px; color: var(--crm-primary);">
                                    <fmt:formatNumber value="${campaign.budget}" pattern="#,##0" /> VNĐ
                                </span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Ngày bắt đầu</span>
                                <span class="detail-value">
                                    <i class="fa fa-calendar-day" style="color: var(--crm-text-muted); margin-right: 6px;"></i>
                                    <fmt:formatDate value="${campaign.startDate}" pattern="dd/MM/yyyy" />
                                </span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Ngày kết thúc</span>
                                <span class="detail-value">
                                    <i class="fa fa-calendar-check" style="color: var(--crm-text-muted); margin-right: 6px;"></i>
                                    <c:choose>
                                        <c:when test="${not empty campaign.endDate}">
                                            <fmt:formatDate value="${campaign.endDate}" pattern="dd/MM/yyyy" />
                                        </c:when>
                                        <c:otherwise><span style="color: var(--crm-text-muted);">Không giới hạn</span></c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Người khởi tạo</span>
                                <span class="detail-value">
                                    <i class="fa fa-user" style="color: var(--crm-text-muted); margin-right: 6px;"></i>
                                    <c:out value="${not empty campaign.creatorName ? campaign.creatorName : 'Hệ thống'}" />
                                </span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Thời điểm tạo</span>
                                <span class="detail-value">
                                    <fmt:formatDate value="${campaign.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>

                            <div class="detail-item" style="grid-column: 1 / -1;">
                                <span class="detail-label">Mô tả & Kế hoạch chi tiết</span>
                                <div style="background: #f8fafc; border: 1px solid var(--crm-border); border-radius: var(--crm-radius-sm); padding: 14px; margin-top: 6px; font-size: 13px; color: var(--crm-text-body); line-height: 1.6;">
                                    <c:out value="${campaign.description}" default="Chưa có thông tin mô tả chi tiết cho chiến dịch này." />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        function switchDrilldownTab(tabName) {
            const tabBtns = {
                'leads': document.getElementById('tab-btn-leads'),
                'opps': document.getElementById('tab-btn-opps'),
                'won': document.getElementById('tab-btn-won')
            };
            const panels = {
                'leads': document.getElementById('panel-leads'),
                'opps': document.getElementById('panel-opps'),
                'won': document.getElementById('panel-won')
            };
            const cards = {
                'leads': document.getElementById('card-metric-leads'),
                'opps': document.getElementById('card-metric-opps'),
                'won': document.getElementById('card-metric-won')
            };

            Object.keys(tabBtns).forEach(function(k) {
                if (tabBtns[k]) {
                    tabBtns[k].classList.remove('active');
                    tabBtns[k].setAttribute('aria-selected', 'false');
                }
                if (panels[k]) {
                    panels[k].classList.remove('active');
                }
                if (cards[k]) {
                    cards[k].classList.remove('active');
                }
            });

            if (tabBtns[tabName]) {
                tabBtns[tabName].classList.add('active');
                tabBtns[tabName].setAttribute('aria-selected', 'true');
            }
            if (panels[tabName]) {
                panels[tabName].classList.add('active');
            }
            if (cards[tabName]) {
                cards[tabName].classList.add('active');
            }

            const searchInput = document.getElementById('drilldownSearchInput');
            if (searchInput) {
                searchInput.value = '';
                filterDrilldownTable();
            }

            const section = document.getElementById('drilldown-section');
            if (section) {
                section.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }

        function handleKeyDrilldown(event, tabName) {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                switchDrilldownTab(tabName);
            }
        }

        function filterDrilldownTable() {
            const input = document.getElementById('drilldownSearchInput');
            const filter = input ? input.value.trim().toLowerCase() : '';
            const activePanel = document.querySelector('.drilldown-tab-panel.active');
            if (!activePanel) return;

            const table = activePanel.querySelector('.exec-table');
            if (!table) return;

            const rows = table.querySelectorAll('tbody tr.drilldown-row');
            let visibleCount = 0;

            rows.forEach(function(row) {
                const text = row.innerText.toLowerCase();
                if (!filter || text.indexOf(filter) !== -1) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            let noMatchRow = table.querySelector('.no-match-row');
            if (visibleCount === 0 && rows.length > 0) {
                if (!noMatchRow) {
                    noMatchRow = document.createElement('tr');
                    noMatchRow.className = 'no-match-row';
                    const colCount = table.querySelectorAll('thead th').length || 8;
                    noMatchRow.innerHTML = '<td colspan="' + colCount + '" style="text-align: center; padding: 32px 16px; color: var(--crm-text-muted);"><i class="fa fa-magnifying-glass" style="margin-right: 8px;"></i> Không tìm thấy kết quả phù hợp với từ khóa "' + escapeHtml(filter) + '".</td>';
                    table.querySelector('tbody').appendChild(noMatchRow);
                } else {
                    noMatchRow.style.display = '';
                    noMatchRow.querySelector('td').innerHTML = '<i class="fa fa-magnifying-glass" style="margin-right: 8px;"></i> Không tìm thấy kết quả phù hợp với từ khóa "' + escapeHtml(filter) + '".';
                }
            } else if (noMatchRow) {
                noMatchRow.style.display = 'none';
            }
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }
    </script>
</body>
</html>
