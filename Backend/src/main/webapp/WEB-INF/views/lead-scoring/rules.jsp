<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Chấm điểm Lead | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
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
                <a href="${pageContext.request.contextPath}/leads">Lead</a>
                <span>/</span>
                <span class="breadcrumb-current">Cấu hình Lead Scoring</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Cấu hình Chấm điểm Lead (Lead Scoring)</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                        Khai báo tiêu chí ngành nghề, quy mô, nguồn và mức độ quan tâm để tự động xếp hạng ưu tiên Lead Nóng, Ấm, Lạnh.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 8px;">
                    <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary">
                        <i class="fas fa-list"></i> Xem danh sách Lead
                    </a>
                </div>
            </div>

            <div id="leadScoringAlert" class="alert" style="display: none; margin-bottom: 16px;"></div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="margin-bottom: 16px;">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success" style="margin-bottom: 16px;">
                    <i class="fas fa-check-circle"></i> <c:out value="${successMessage}"/>
                </div>
            </c:if>

            <!-- Scoring Grid: Form khai báo tiêu chí + Cấu hình ngưỡng phân loại -->
            <div class="scoring-grid">
                <!-- Cột 1: Danh sách và Form thêm tiêu chí chấm điểm -->
                <div class="scoring-card">
                    <div class="scoring-card-header">
                        <h2 class="scoring-card-title">
                            <i class="fas fa-sliders-h" style="color: var(--color-primary);"></i>
                            Khai báo Tiêu chí & Số điểm
                        </h2>
                    </div>

                    <form id="scoringRuleForm" method="post" action="${pageContext.request.contextPath}/lead-scoring/rules" style="background: var(--color-gray-50); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--color-border); margin-bottom: 20px;">
                        <input type="hidden" name="ruleId" value="">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 12px;">
                            <div>
                                <label class="form-label" style="font-weight: 600; font-size: 13px;">Tiêu chí (Criterion) <span style="color:red">*</span></label>
                                <select id="criterionSelect" name="criterion" class="form-control" required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px; width: 100%;">
                                    <option value="INDUSTRY">Ngành nghề phù hợp (Industry)</option>
                                    <option value="COMPANY_SIZE">Quy mô doanh nghiệp (Company Size)</option>
                                    <option value="SOURCE">Nguồn Lead (Lead Source)</option>
                                    <option value="INTEREST">Mức độ quan tâm (Interest Level)</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" style="font-weight: 600; font-size: 13px;">Toán tử (Operator)</label>
                                <select name="operator" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px; width: 100%;">
                                    <option value="EQUALS">Bằng (Equals)</option>
                                    <option value="CONTAINS">Chứa (Contains)</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" style="font-weight: 600; font-size: 13px;">Giá trị điều kiện <span style="color:red">*</span></label>
                                <input type="text" id="conditionValueInput" name="conditionValue" list="criterionSuggestions" class="form-control" placeholder="VD: Công nghệ, Lớn, Website..." required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px; width: 100%;">
                                <datalist id="criterionSuggestions"></datalist>
                            </div>
                            <div>
                                <label class="form-label" style="font-weight: 600; font-size: 13px;">Số điểm cộng/trừ <span style="color:red">*</span></label>
                                <input type="number" name="score" class="form-control" placeholder="VD: 20 hoặc -10" required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px; width: 100%;">
                            </div>
                        </div>
                        <div style="text-align: right;">
                            <button type="submit" class="btn btn-primary btn-sm">
                                <i class="fas fa-plus"></i> Lưu tiêu chí
                            </button>
                        </div>
                    </form>

                    <!-- Danh sách các quy tắc đã khai báo -->
                    <h3 style="font-size: 15px; font-weight: 600; margin-bottom: 12px; color: var(--color-gray-800);">
                        Danh sách tiêu chí đang áp dụng
                    </h3>
                    <div class="table-container">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Tiêu chí</th>
                                    <th>Toán tử</th>
                                    <th>Giá trị áp dụng</th>
                                    <th>Điểm</th>
                                    <th style="width: 100px; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty rules}">
                                        <c:forEach var="rule" items="${rules}" varStatus="status">
                                            <tr>
                                                <td>${status.count}</td>
                                                <td>
                                                    <strong>
                                                        <c:choose>
                                                            <c:when test="${rule.criterion == 'INDUSTRY'}">Ngành nghề</c:when>
                                                            <c:when test="${rule.criterion == 'COMPANY_SIZE'}">Quy mô doanh nghiệp</c:when>
                                                            <c:when test="${rule.criterion == 'SOURCE'}">Nguồn Lead</c:when>
                                                            <c:when test="${rule.criterion == 'INTEREST'}">Mức độ quan tâm</c:when>
                                                            <c:otherwise><c:out value="${rule.criterion}"/></c:otherwise>
                                                        </c:choose>
                                                    </strong>
                                                </td>
                                                <td><c:out value="${rule.operator != null ? rule.operator : 'EQUALS'}"/></td>
                                                <td><span class="badge badge-neutral"><c:out value="${rule.conditionValue}"/></span></td>
                                                <td>
                                                    <span class="lead-score-pill ${rule.score > 0 ? 'score-positive' : (rule.score < 0 ? 'score-negative' : 'score-neutral')}">
                                                        ${rule.score > 0 ? '+' : ''}${rule.score} điểm
                                                    </span>
                                                </td>
                                                <td style="text-align: center;">
                                                    <button type="button" class="btn btn-secondary btn-sm" onclick="LeadScoring.deleteRule('${rule.ruleId}')" title="Xóa quy tắc">
                                                        <i class="fas fa-trash-alt" style="color: #dc2626;"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Dữ liệu hiển thị mẫu ban đầu nếu Backend chưa nạp danh sách -->
                                        <tr>
                                            <td>1</td>
                                            <td><strong>Ngành nghề</strong></td>
                                            <td>EQUALS</td>
                                            <td><span class="badge badge-neutral">Công nghệ thông tin</span></td>
                                            <td><span class="lead-score-pill score-positive">+25 điểm</span></td>
                                            <td style="text-align: center;"><span class="text-muted" style="font-size:12px;">Mặc định</span></td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td><strong>Quy mô doanh nghiệp</strong></td>
                                            <td>EQUALS</td>
                                            <td><span class="badge badge-neutral">100-500</span></td>
                                            <td><span class="lead-score-pill score-positive">+20 điểm</span></td>
                                            <td style="text-align: center;"><span class="text-muted" style="font-size:12px;">Mặc định</span></td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td><strong>Nguồn Lead</strong></td>
                                            <td>EQUALS</td>
                                            <td><span class="badge badge-neutral">Website</span></td>
                                            <td><span class="lead-score-pill score-positive">+15 điểm</span></td>
                                            <td style="text-align: center;"><span class="text-muted" style="font-size:12px;">Mặc định</span></td>
                                        </tr>
                                        <tr>
                                            <td>4</td>
                                            <td><strong>Mức độ quan tâm</strong></td>
                                            <td>EQUALS</td>
                                            <td><span class="badge badge-neutral">Rất cao</span></td>
                                            <td><span class="lead-score-pill score-positive">+30 điểm</span></td>
                                            <td style="text-align: center;"><span class="text-muted" style="font-size:12px;">Mặc định</span></td>
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
                        <h2 class="scoring-card-title">
                            <i class="fas fa-thermometer-half" style="color: #ef4444;"></i>
                            Ngưỡng Phân loại Lead
                        </h2>
                    </div>

                    <p style="font-size: 13px; color: var(--color-text-secondary); margin-bottom: 16px;">
                        Lead được tự động phân loại dựa trên tổng điểm tính từ các tiêu chí khai báo:
                    </p>

                    <div class="threshold-indicator-container">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                            <span class="badge badge-cold"><i class="fas fa-snowflake"></i> LẠNH (<span id="lblColdThreshold">&lt; ${not empty warmThreshold ? warmThreshold : 40}</span>)</span>
                            <span class="badge badge-warm"><i class="fas fa-sun"></i> ẤM (≥ <span id="lblWarmThreshold">${not empty warmThreshold ? warmThreshold : 40}</span>)</span>
                            <span class="badge badge-hot"><i class="fas fa-fire"></i> NÓNG (≥ <span id="lblHotThreshold">${not empty hotThreshold ? hotThreshold : 70}</span>)</span>
                        </div>
                        <div class="threshold-range-bar"></div>
                        <div class="threshold-labels">
                            <span>0 điểm</span>
                            <span>Ưu tiên gọi sau</span>
                            <span>100+ điểm (Gọi ngay)</span>
                        </div>
                    </div>

                    <form id="thresholdConfigForm" method="post" action="${pageContext.request.contextPath}/lead-scoring/config" style="margin-top: 12px;">
                        <div style="margin-bottom: 14px;">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">
                                Ngưỡng Lead NÓNG (Hot Threshold) <span style="color:red">*</span>
                            </label>
                            <input type="number" name="hotThreshold" class="form-control" value="${not empty hotThreshold ? hotThreshold : 70}" required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px; width: 100%;">
                            <small class="text-muted" style="display:block; margin-top: 4px; font-size: 12px;">Lead có tổng điểm từ mức này trở lên sẽ gắn nhãn Nóng (Ưu tiên gọi trước).</small>
                        </div>

                        <div style="margin-bottom: 16px;">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">
                                Ngưỡng Lead ẤM (Warm Threshold) <span style="color:red">*</span>
                            </label>
                            <input type="number" name="warmThreshold" class="form-control" value="${not empty warmThreshold ? warmThreshold : 40}" required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px; width: 100%;">
                            <small class="text-muted" style="display:block; margin-top: 4px; font-size: 12px;">Lead có điểm từ mức này đến dưới ngưỡng Nóng được phân loại Ấm.</small>
                        </div>

                        <div style="padding: 12px; background: #fefce8; border: 1px solid #fef08a; border-radius: 6px; margin-bottom: 16px; font-size: 12px; color: #854d0e;">
                            <i class="fas fa-info-circle"></i> <strong>Lưu ý nghiệp vụ (S4-05-AC-04):</strong> Điểm số và phân loại chỉ dùng để sắp xếp thứ tự ưu tiên cuộc gọi, không tự động loại bỏ Lead khỏi hệ thống.
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">
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
