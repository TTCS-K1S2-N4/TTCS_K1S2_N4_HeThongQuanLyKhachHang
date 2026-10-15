<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Chấm điểm Lead | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
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
                <span class="breadcrumb-current">Cấu hình Lead Scoring</span>
            </nav>

            <!-- Page Header -->
            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <h1 class="page-title" style="margin: 0;">Cấu hình Chấm điểm Lead (Lead Scoring)</h1>
                        <span class="badge badge-info" style="font-size: 11px;"><i class="fas fa-cog"></i> Sprint 04</span>
                    </div>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin: 0; line-height: 1.5;">
                        Khai báo tiêu chí ngành nghề, quy mô, nguồn và mức độ quan tâm để tự động xếp hạng ưu tiên Lead Nóng, Ấm, Lạnh.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Danh sách Lead
                    </a>
                </div>
            </div>

            <!-- Global Feedback Notifications -->
            <div id="leadScoringAlert" class="alert" style="display: none; margin-bottom: 16px;"></div>
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

            <!-- Scoring Grid: Form khai báo tiêu chí + Cấu hình ngưỡng phân loại -->
            <div class="scoring-grid">
                <!-- Cột 1: Danh sách và Form thêm tiêu chí chấm điểm -->
                <div class="scoring-card">
                    <div class="scoring-card-header">
                        <div>
                            <h2 class="scoring-card-title">
                                <i class="fas fa-sliders-h" style="color: var(--color-primary);"></i>
                                Khai báo Tiêu chí & Số điểm
                            </h2>
                            <div class="scoring-card-subtitle">
                                Định nghĩa các điều kiện cộng hoặc trừ điểm cho mỗi đầu mối kinh doanh mới thu thập.
                            </div>
                        </div>
                    </div>

                    <!-- Form nhập quy tắc chấm điểm -->
                    <div class="rule-form-container">
                        <div class="rule-form-header">
                            <span class="rule-form-header-title">
                                <i class="fas fa-plus-circle" style="color: var(--color-primary);"></i>
                                Thêm mới hoặc chỉnh sửa tiêu chí
                            </span>
                            <span style="font-size: 12px; color: var(--color-text-secondary);">
                                Dấu (<span style="color: red;">*</span>) là bắt buộc
                            </span>
                        </div>

                        <form id="scoringRuleForm" method="post" action="${pageContext.request.contextPath}/lead-scoring/rules">
                            <input type="hidden" name="ruleId" value="">
                            <div class="rule-form-grid">
                                <div class="rule-form-field">
                                    <label class="form-label" for="criterionSelect">
                                        <i class="fas fa-tag" style="color: var(--color-primary); font-size: 11px;"></i>
                                        Tiêu chí <span style="color:red">*</span>
                                    </label>
                                    <select id="criterionSelect" name="criterion" class="form-control" required>
                                        <option value="INDUSTRY">Ngành nghề phù hợp (Industry)</option>
                                        <option value="COMPANY_SIZE">Quy mô doanh nghiệp (Company Size)</option>
                                        <option value="SOURCE">Nguồn Lead (Lead Source)</option>
                                        <option value="INTEREST">Mức độ quan tâm (Interest Level)</option>
                                    </select>
                                </div>

                                <div class="rule-form-field">
                                    <label class="form-label">
                                        <i class="fas fa-code-branch" style="color: var(--color-text-secondary); font-size: 11px;"></i>
                                        Toán tử so khớp
                                    </label>
                                    <select name="operator" class="form-control">
                                        <option value="EQUALS">Bằng chính xác (Equals)</option>
                                        <option value="CONTAINS">Chứa từ khóa (Contains)</option>
                                    </select>
                                </div>

                                <div class="rule-form-field">
                                    <label class="form-label" for="conditionValueInput">
                                        <i class="fas fa-font" style="color: var(--color-text-secondary); font-size: 11px;"></i>
                                        Giá trị điều kiện <span style="color:red">*</span>
                                    </label>
                                    <input type="text" id="conditionValueInput" name="conditionValue" list="criterionSuggestions" class="form-control" placeholder="VD: Công nghệ thông tin, Bất động sản..." required>
                                    <datalist id="criterionSuggestions"></datalist>
                                </div>

                                <div class="rule-form-field">
                                    <label class="form-label">
                                        <i class="fas fa-calculator" style="color: var(--color-text-secondary); font-size: 11px;"></i>
                                        Số điểm (+ / -) <span style="color:red">*</span>
                                    </label>
                                    <input type="number" name="score" class="form-control" placeholder="VD: 25 hoặc -10" required>
                                </div>
                            </div>

                            <div class="rule-form-actions">
                                <button type="reset" class="btn btn-secondary btn-sm" onclick="document.querySelector('#scoringRuleForm [name=ruleId]').value=''">
                                    <i class="fas fa-redo"></i> Nhập lại
                                </button>
                                <button type="submit" class="btn btn-primary btn-sm">
                                    <i class="fas fa-save"></i> Lưu tiêu chí chấm điểm
                                </button>
                            </div>
                        </form>
                    </div>

                    <!-- Danh sách các quy tắc đã khai báo -->
                    <div class="rule-table-section-title">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span>Danh sách tiêu chí đang áp dụng</span>
                            <span class="rule-table-count">
                                ${not empty rules ? rules.size() : 4} tiêu chí
                            </span>
                        </div>
                    </div>

                    <div class="table-container">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align: center;">#</th>
                                    <th>Tiêu chí</th>
                                    <th>Toán tử</th>
                                    <th>Giá trị áp dụng</th>
                                    <th>Điểm số</th>
                                    <th style="width: 100px; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty rules}">
                                        <c:forEach var="rule" items="${rules}" varStatus="status">
                                            <tr>
                                                <td style="text-align: center; color: var(--color-text-secondary); font-weight: 500;">
                                                    ${status.count}
                                                </td>
                                                <td>
                                                    <div class="criterion-tag">
                                                        <c:choose>
                                                            <c:when test="${rule.criterion == 'INDUSTRY'}">
                                                                <i class="fas fa-building" title="Ngành nghề"></i>
                                                                <span>Ngành nghề</span>
                                                            </c:when>
                                                            <c:when test="${rule.criterion == 'COMPANY_SIZE'}">
                                                                <i class="fas fa-users" title="Quy mô"></i>
                                                                <span>Quy mô doanh nghiệp</span>
                                                            </c:when>
                                                            <c:when test="${rule.criterion == 'SOURCE'}">
                                                                <i class="fas fa-share-alt" title="Nguồn"></i>
                                                                <span>Nguồn Lead</span>
                                                            </c:when>
                                                            <c:when test="${rule.criterion == 'INTEREST'}">
                                                                <i class="fas fa-heart" title="Quan tâm"></i>
                                                                <span>Mức độ quan tâm</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fas fa-check"></i>
                                                                <span><c:out value="${rule.criterion}"/></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="operator-badge">
                                                        <c:out value="${rule.operator != null ? rule.operator : 'EQUALS'}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge badge-neutral" style="font-weight: 600;">
                                                        <c:out value="${rule.conditionValue}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="lead-score-pill ${rule.score > 0 ? 'score-positive' : (rule.score < 0 ? 'score-negative' : 'score-neutral')}">
                                                        <i class="fas ${rule.score > 0 ? 'fa-arrow-up' : (rule.score < 0 ? 'fa-arrow-down' : 'fa-minus')}"></i>
                                                        ${rule.score > 0 ? '+' : ''}${rule.score} điểm
                                                    </span>
                                                </td>
                                                <td style="text-align: center;">
                                                    <button type="button" class="btn btn-secondary btn-sm" onclick="LeadScoring.deleteRule('${rule.ruleId}')" title="Xóa quy tắc này" style="padding: 4px 8px;">
                                                        <i class="fas fa-trash-alt" style="color: #dc2626;"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Dữ liệu hiển thị mẫu ban đầu nếu Backend chưa nạp danh sách -->
                                        <tr>
                                            <td style="text-align: center; color: var(--color-text-secondary);">1</td>
                                            <td>
                                                <div class="criterion-tag">
                                                    <i class="fas fa-building"></i>
                                                    <span>Ngành nghề</span>
                                                </div>
                                            </td>
                                            <td><span class="operator-badge">EQUALS</span></td>
                                            <td><span class="badge badge-neutral" style="font-weight: 600;">Công nghệ thông tin</span></td>
                                            <td><span class="lead-score-pill score-positive"><i class="fas fa-arrow-up"></i> +25 điểm</span></td>
                                            <td style="text-align: center;"><span class="badge badge-neutral" style="font-size: 11px;">Mặc định</span></td>
                                        </tr>
                                        <tr>
                                            <td style="text-align: center; color: var(--color-text-secondary);">2</td>
                                            <td>
                                                <div class="criterion-tag">
                                                    <i class="fas fa-users"></i>
                                                    <span>Quy mô doanh nghiệp</span>
                                                </div>
                                            </td>
                                            <td><span class="operator-badge">EQUALS</span></td>
                                            <td><span class="badge badge-neutral" style="font-weight: 600;">100-500</span></td>
                                            <td><span class="lead-score-pill score-positive"><i class="fas fa-arrow-up"></i> +20 điểm</span></td>
                                            <td style="text-align: center;"><span class="badge badge-neutral" style="font-size: 11px;">Mặc định</span></td>
                                        </tr>
                                        <tr>
                                            <td style="text-align: center; color: var(--color-text-secondary);">3</td>
                                            <td>
                                                <div class="criterion-tag">
                                                    <i class="fas fa-share-alt"></i>
                                                    <span>Nguồn Lead</span>
                                                </div>
                                            </td>
                                            <td><span class="operator-badge">EQUALS</span></td>
                                            <td><span class="badge badge-neutral" style="font-weight: 600;">Website</span></td>
                                            <td><span class="lead-score-pill score-positive"><i class="fas fa-arrow-up"></i> +15 điểm</span></td>
                                            <td style="text-align: center;"><span class="badge badge-neutral" style="font-size: 11px;">Mặc định</span></td>
                                        </tr>
                                        <tr>
                                            <td style="text-align: center; color: var(--color-text-secondary);">4</td>
                                            <td>
                                                <div class="criterion-tag">
                                                    <i class="fas fa-heart"></i>
                                                    <span>Mức độ quan tâm</span>
                                                </div>
                                            </td>
                                            <td><span class="operator-badge">EQUALS</span></td>
                                            <td><span class="badge badge-neutral" style="font-weight: 600;">Rất cao</span></td>
                                            <td><span class="lead-score-pill score-positive"><i class="fas fa-arrow-up"></i> +30 điểm</span></td>
                                            <td style="text-align: center;"><span class="badge badge-neutral" style="font-size: 11px;">Mặc định</span></td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Cột 2: Cấu hình ngưỡng phân loại Nóng / Ấm / Lạnh (S4-05-AC-03) -->
                <div class="scoring-card">
                    <div class="scoring-card-header">
                        <div>
                            <h2 class="scoring-card-title">
                                <i class="fas fa-thermometer-half" style="color: #ef4444;"></i>
                                Ngưỡng Phân loại Lead
                            </h2>
                            <div class="scoring-card-subtitle">
                                Tự động gán nhãn Nóng, Ấm hoặc Lạnh theo tổng điểm tiêu chí để tối ưu hóa thứ tự gọi của Sales.
                            </div>
                        </div>
                    </div>

                    <!-- Visual Classification Cards -->
                    <div class="classification-cards-stack">
                        <!-- Card NÓNG -->
                        <div class="classification-card-item hot">
                            <div class="classification-card-icon">
                                <i class="fas fa-fire"></i>
                            </div>
                            <div class="classification-card-content">
                                <div class="classification-card-title">
                                    <span>LEAD NÓNG (HOT)</span>
                                    <span class="badge badge-hot">≥ <span id="lblHotThreshold">${not empty hotThreshold ? hotThreshold : 70}</span> điểm</span>
                                </div>
                                <div class="classification-card-desc">
                                    Nhu cầu cấp thiết, khả năng chuyển đổi cao.
                                </div>
                                <div class="classification-card-action">
                                    <i class="fas fa-phone-volume"></i> Ưu tiên gọi điện tư vấn ngay lập tức!
                                </div>
                            </div>
                        </div>

                        <!-- Card ẤM -->
                        <div class="classification-card-item warm">
                            <div class="classification-card-icon">
                                <i class="fas fa-sun"></i>
                            </div>
                            <div class="classification-card-content">
                                <div class="classification-card-title">
                                    <span>LEAD ẤM (WARM)</span>
                                    <span class="badge badge-warm">≥ <span id="lblWarmThreshold">${not empty warmThreshold ? warmThreshold : 40}</span> điểm</span>
                                </div>
                                <div class="classification-card-desc">
                                    Quan tâm dịch vụ, đang tìm hiểu giải pháp.
                                </div>
                                <div class="classification-card-action">
                                    <i class="fas fa-envelope-open-text"></i> Gửi email tài liệu hoặc liên hệ trong ngày.
                                </div>
                            </div>
                        </div>

                        <!-- Card LẠNH -->
                        <div class="classification-card-item cold">
                            <div class="classification-card-icon">
                                <i class="fas fa-snowflake"></i>
                            </div>
                            <div class="classification-card-content">
                                <div class="classification-card-title">
                                    <span>LEAD LẠNH (COLD)</span>
                                    <span class="badge badge-cold"><span id="lblColdThreshold">&lt; ${not empty warmThreshold ? warmThreshold : 40}</span> điểm</span>
                                </div>
                                <div class="classification-card-desc">
                                    Chưa có nhu cầu rõ ràng hoặc chưa phù hợp.
                                </div>
                                <div class="classification-card-action">
                                    <i class="fas fa-seedling"></i> Đưa vào chuỗi chiến dịch nuôi dưỡng tự động.
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Visual Indicator Bar -->
                    <div class="threshold-indicator-container">
                        <div style="font-size: 12px; font-weight: 600; color: var(--color-gray-700); margin-bottom: 6px; display: flex; justify-content: space-between;">
                            <span><i class="fas fa-chart-line" style="color: var(--color-primary);"></i> Thước đo dải điểm</span>
                            <span style="font-size: 11px; color: var(--color-text-secondary);">Thang điểm 0 - 100+</span>
                        </div>
                        <div class="threshold-range-bar-wrapper">
                            <div class="threshold-range-bar"></div>
                        </div>
                        <div class="threshold-labels">
                            <span>0 điểm (Lạnh)</span>
                            <span>Ngưỡng Ấm</span>
                            <span>Ngưỡng Nóng (Gọi ngay)</span>
                        </div>
                    </div>

                    <!-- Form điều chỉnh ngưỡng -->
                    <form id="thresholdConfigForm" method="post" action="${pageContext.request.contextPath}/lead-scoring/config">
                        <div id="thresholdWarning" class="alert alert-danger" style="display: none; padding: 10px 12px; font-size: 12px; margin-bottom: 12px;"></div>

                        <div style="margin-bottom: 14px;">
                            <label class="form-label" style="font-weight: 600; font-size: 13px; display: flex; align-items: center; justify-content: space-between;">
                                <span><i class="fas fa-fire" style="color: #ef4444;"></i> Ngưỡng Lead NÓNG (Hot Threshold) <span style="color:red">*</span></span>
                                <span style="font-size: 11px; color: var(--color-text-secondary); font-weight: normal;">Khuyến nghị: 70 - 80</span>
                            </label>
                            <input type="number" name="hotThreshold" class="form-control" value="${not empty hotThreshold ? hotThreshold : 70}" required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 9px 12px; width: 100%; font-size: 14px;">
                            <small class="text-muted" style="display:block; margin-top: 4px; font-size: 12px;">Lead có tổng điểm từ mức này trở lên sẽ gắn nhãn Nóng.</small>
                        </div>

                        <div style="margin-bottom: 16px;">
                            <label class="form-label" style="font-weight: 600; font-size: 13px; display: flex; align-items: center; justify-content: space-between;">
                                <span><i class="fas fa-sun" style="color: #f59e0b;"></i> Ngưỡng Lead ẤM (Warm Threshold) <span style="color:red">*</span></span>
                                <span style="font-size: 11px; color: var(--color-text-secondary); font-weight: normal;">Khuyến nghị: 40 - 50</span>
                            </label>
                            <input type="number" name="warmThreshold" class="form-control" value="${not empty warmThreshold ? warmThreshold : 40}" required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 9px 12px; width: 100%; font-size: 14px;">
                            <small class="text-muted" style="display:block; margin-top: 4px; font-size: 12px;">Lead có điểm từ mức này đến dưới ngưỡng Nóng được phân loại Ấm.</small>
                        </div>

                        <div style="padding: 12px 14px; background: #fefce8; border: 1px solid #fef08a; border-radius: 6px; margin-bottom: 18px; font-size: 12px; color: #854d0e; line-height: 1.45;">
                            <i class="fas fa-info-circle"></i> <strong>Quy định nghiệp vụ (S4-05-AC-04):</strong> Điểm số và phân loại chỉ dùng để sắp xếp thứ tự ưu tiên cuộc gọi, hệ thống cam kết không tự ý loại bỏ Lead khỏi danh sách.
                        </div>

                        <button type="submit" class="btn btn-primary btn-block" style="padding: 10px 16px; font-weight: 600;">
                            <i class="fas fa-save"></i> Cập nhật ngưỡng phân loại
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/modules/lead-scoring.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        LeadScoring.init({
            contextPath: '${pageContext.request.contextPath}'
        });
    });
</script>
</body>
</html>
