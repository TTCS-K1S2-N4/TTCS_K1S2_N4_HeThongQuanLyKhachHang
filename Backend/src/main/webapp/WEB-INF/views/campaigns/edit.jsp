<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cập nhật Chiến dịch Marketing | CRM</title>
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
                    <span style="color: var(--crm-text-heading); font-weight: 600;">Cập nhật chiến dịch</span>
                </div>

                <c:if test="${not empty errorMessage or not empty error}">
                    <div class="toast-banner toast-error">
                        <div>
                            <i class="fa fa-triangle-exclamation" style="margin-right: 8px;"></i>
                            <c:out value="${not empty errorMessage ? errorMessage : error}"/>
                        </div>
                        <button type="button" class="toast-close" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                </c:if>

                <div class="exec-form-card">
                    <div class="exec-form-header">
                        <h2>
                            <i class="fa fa-pen-to-square" style="color: var(--crm-accent);"></i>
                            Chỉnh sửa Chiến dịch: <c:out value="${not empty campaign.campaignName ? campaign.campaignName : campaign.name}" />
                        </h2>
                        <span class="status-badge status-planning">
                            ID: #${not empty campaign.campaignId ? campaign.campaignId : campaign.id}
                        </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/campaigns/edit" method="post">
                        <input type="hidden" name="id" value="${not empty campaign.campaignId ? campaign.campaignId : campaign.id}" />

                        <div class="exec-form-body">
                            <div class="exec-form-grid">
                                <div class="form-group form-group-full">
                                    <label>Tên chiến dịch tiếp thị <span style="color: #dc2626;">*</span></label>
                                    <input type="text" name="name" class="form-control" required
                                           placeholder="Ví dụ: Chiến dịch Q4 Khuyến mãi Mùa lễ hội 2026"
                                           value="<c:out value='${not empty campaign.campaignName ? campaign.campaignName : campaign.name}'/>">
                                    <span class="form-text">Tên đại diện phân biệt chiến dịch trong danh sách và báo cáo gộp.</span>
                                </div>

                                <div class="form-group">
                                    <label>Kênh tiếp thị <span style="color: #dc2626;">*</span></label>
                                    <select name="channel" class="form-control" required>
                                        <option value="">-- Chọn kênh tiếp thị --</option>
                                        <option value="Email" ${campaign.channel eq 'Email' ? 'selected' : ''}>Email Marketing</option>
                                        <option value="Social" ${campaign.channel eq 'Social' ? 'selected' : ''}>Social Media (Facebook/LinkedIn)</option>
                                        <option value="Search" ${campaign.channel eq 'Search' ? 'selected' : ''}>Search Ads (Google/SEO)</option>
                                        <option value="Event" ${campaign.channel eq 'Event' ? 'selected' : ''}>Sự kiện & Hội thảo (Event/Workshop)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Trạng thái chiến dịch</label>
                                    <select name="status" class="form-control">
                                        <option value="PLANNING" ${campaign.status eq 'PLANNING' ? 'selected' : ''}>Lên kế hoạch (PLANNING)</option>
                                        <option value="ACTIVE" ${campaign.status eq 'ACTIVE' ? 'selected' : ''}>Đang chạy (ACTIVE)</option>
                                        <option value="COMPLETED" ${campaign.status eq 'COMPLETED' ? 'selected' : ''}>Đã hoàn thành (COMPLETED)</option>
                                        <option value="CANCELLED" ${campaign.status eq 'CANCELLED' ? 'selected' : ''}>Đã hủy (CANCELLED)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Ngân sách dự toán (VNĐ)</label>
                                    <input type="number" step="1000" min="0" name="budget" class="form-control"
                                           placeholder="Ví dụ: 50000000"
                                           value="<c:out value='${campaign.budget}'/>">
                                </div>

                                <div class="form-group">
                                    <label>Ngày bắt đầu <span style="color: #dc2626;">*</span></label>
                                    <input type="date" name="startDate" class="form-control" required
                                           value="<fmt:formatDate value='${campaign.startDate}' pattern='yyyy-MM-dd'/>">
                                </div>

                                <div class="form-group">
                                    <label>Ngày kết thúc</label>
                                    <input type="date" name="endDate" class="form-control"
                                           value="<fmt:formatDate value='${campaign.endDate}' pattern='yyyy-MM-dd'/>">
                                </div>

                                <div class="form-group form-group-full">
                                    <label>Mô tả mục tiêu & kế hoạch triển khai</label>
                                    <textarea name="description" class="form-control" rows="4"
                                              placeholder="Chi tiết KPI kỳ vọng, thông điệp truyền thông, ngân sách phân bổ theo tuần..."><c:out value="${campaign.description}"/></textarea>
                                </div>
                            </div>
                        </div>

                        <div class="exec-form-footer">
                            <a href="${pageContext.request.contextPath}/campaigns" class="btn-exec-light">
                                <i class="fa fa-xmark"></i> Hủy bỏ
                            </a>
                            <button type="submit" class="btn-exec-primary">
                                <i class="fa fa-floppy-disk"></i> Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
