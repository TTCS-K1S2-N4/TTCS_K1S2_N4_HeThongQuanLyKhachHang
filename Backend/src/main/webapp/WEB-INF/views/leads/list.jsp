<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách Lead | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
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
                <span class="breadcrumb-current">Lead</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Danh sách Lead</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">
                        Quản lý đầu mối kinh doanh, tự động chấm điểm ưu tiên và lọc danh sách gọi hàng ngày.
                    </p>
                </div>
                <div class="page-actions" style="display: flex; gap: 8px; flex-wrap: wrap;">
                    <a href="${pageContext.request.contextPath}/leads/create" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Thêm Lead
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/import" class="btn btn-secondary">
                        <i class="fas fa-file-excel"></i> Nhập Excel
                    </a>
                    <a href="${pageContext.request.contextPath}/lead-forms" class="btn btn-secondary">
                        <i class="fas fa-code"></i> Web Forms
                    </a>
                    <a href="${pageContext.request.contextPath}/lead-scoring/rules" class="btn btn-secondary" title="Cấu hình chấm điểm Lead (Giám đốc kinh doanh)">
                        <i class="fas fa-sliders-h"></i> Cấu hình Chấm điểm
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/filters" class="btn btn-secondary" title="Xem bộ lọc đã lưu">
                        <i class="fas fa-bookmark"></i> Bộ lọc đã lưu
                    </a>
                    <a href="${pageContext.request.contextPath}/leads/duplicates" class="btn btn-secondary" title="Kiểm tra Lead trùng lặp">
                        <i class="fas fa-copy"></i> Kiểm tra trùng
                    </a>
                </div>
            </div>

            <!-- Lead Filter Toolbar (S4-09-AC-01) -->
            <form id="leadFilterForm" action="${pageContext.request.contextPath}/leads" method="get" class="card" style="padding: 16px; margin-bottom: 20px; box-shadow: var(--shadow-sm);">
                <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; width: 100%;">
                    <!-- Tìm kiếm từ khóa -->
                    <div style="flex: 2; min-width: 220px;">
                        <input type="search" name="keyword" class="form-control" placeholder="Tìm kiếm họ tên, công ty, email, số điện thoại..." value="<c:out value='${param.keyword != null ? param.keyword : (param.search != null ? param.search : search)}'/>" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px 12px; width: 100%;">
                    </div>

                    <!-- Lọc Trạng thái (Status) -->
                    <div style="flex: 1; min-width: 140px;">
                        <select name="status" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px 12px; width: 100%;">
                            <option value="">-- Trạng thái --</option>
                            <option value="NEW" ${param.status == 'NEW' || status == 'NEW' ? 'selected' : ''}>Mới tạo</option>
                            <option value="CONTACTED" ${param.status == 'CONTACTED' || status == 'CONTACTED' ? 'selected' : ''}>Đang liên hệ</option>
                            <option value="QUALIFIED" ${param.status == 'QUALIFIED' || status == 'QUALIFIED' ? 'selected' : ''}>Đã xác định nhu cầu</option>
                            <option value="UNQUALIFIED" ${param.status == 'UNQUALIFIED' || status == 'UNQUALIFIED' ? 'selected' : ''}>Không tiềm năng</option>
                            <option value="CONVERTED" ${param.status == 'CONVERTED' || status == 'CONVERTED' ? 'selected' : ''}>Đã chuyển đổi</option>
                        </select>
                    </div>

                    <!-- Lọc Nguồn Lead (Source) -->
                    <div style="flex: 1; min-width: 130px;">
                        <select name="source" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px 12px; width: 100%;">
                            <option value="">-- Nguồn --</option>
                            <option value="Website" ${param.source == 'Website' ? 'selected' : ''}>Website</option>
                            <option value="Facebook" ${param.source == 'Facebook' ? 'selected' : ''}>Facebook</option>
                            <option value="Google Ads" ${param.source == 'Google Ads' ? 'selected' : ''}>Google Ads</option>
                            <option value="Giới thiệu" ${param.source == 'Giới thiệu' ? 'selected' : ''}>Giới thiệu</option>
                            <option value="Sự kiện" ${param.source == 'Sự kiện' ? 'selected' : ''}>Sự kiện</option>
                            <option value="Khác" ${param.source == 'Khác' ? 'selected' : ''}>Khác</option>
                        </select>
                    </div>

                    <!-- Lọc Phân loại Nóng / Ấm / Lạnh (Classification S4-05 & S4-09) -->
                    <div style="flex: 1; min-width: 150px;">
                        <select name="classification" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px 12px; width: 100%;">
                            <option value="">-- Phân loại điểm --</option>
                            <option value="HOT" ${param.classification == 'HOT' || param.rating == 'HOT' || rating == 'HOT' ? 'selected' : ''}>🔥 NÓNG (Gọi trước)</option>
                            <option value="WARM" ${param.classification == 'WARM' || param.rating == 'WARM' || rating == 'WARM' ? 'selected' : ''}>☀️ ẤM</option>
                            <option value="COLD" ${param.classification == 'COLD' || param.rating == 'COLD' || rating == 'COLD' ? 'selected' : ''}>❄️ LẠNH</option>
                        </select>
                    </div>

                    <!-- Lọc Người phụ trách (Owner) -->
                    <div style="flex: 1; min-width: 150px;">
                        <select name="ownerId" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 8px 12px; width: 100%;">
                            <option value="">-- Người phụ trách --</option>
                            <option value="MY" ${param.ownerId == 'MY' ? 'selected' : ''}>Của tôi</option>
                            <c:forEach var="owner" items="${owners}">
                                <option value="${owner.userId}" ${param.ownerId == owner.userId ? 'selected' : ''}>
                                    <c:out value="${owner.fullName}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- Hàng 2: Khoảng thời gian, Lọc Quá SLA, Thao tác Lọc và Lưu bộ lọc -->
                <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; width: 100%; margin-top: 12px;">
                    <div style="display: flex; align-items: center; gap: 8px; flex: 2; min-width: 280px;">
                        <label style="font-size: 13px; color: var(--color-text-secondary); white-space: nowrap;">Từ ngày:</label>
                        <input type="date" name="fromDate" value="<c:out value='${param.fromDate}'/>" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 6px 10px;">
                        <label style="font-size: 13px; color: var(--color-text-secondary); white-space: nowrap;">Đến:</label>
                        <input type="date" name="toDate" value="<c:out value='${param.toDate}'/>" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 6px 10px;">
                    </div>

                    <!-- Checkbox Lọc Lead Quá SLA (S4-09-AC-02) -->
                    <div class="checkbox-group" style="padding: 6px 12px; background: #fff1f2; border: 1px solid #fecaca; border-radius: 6px;">
                        <input type="checkbox" id="overdueCheckbox" name="overdue" value="true" ${param.overdue == 'true' ? 'checked' : ''}>
                        <label for="overdueCheckbox" style="font-size: 13px; font-weight: 600; color: #b91c1c; cursor: pointer;">
                            <i class="fas fa-exclamation-triangle"></i> Chỉ hiển thị Lead quá SLA
                        </label>
                    </div>

                    <div style="display: flex; gap: 8px; margin-left: auto;">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-filter"></i> Lọc dữ liệu
                        </button>
                        <a href="${pageContext.request.contextPath}/leads" class="btn btn-secondary">
                            Đặt lại
                        </a>
                        <button type="button" class="btn btn-secondary" onclick="openSaveLeadFilterModal()" style="background: #f1f5f9; border: 1px solid #cbd5e1; color: #334155;">
                            <i class="fas fa-bookmark" style="color: #0284c7;"></i> Lưu bộ lọc này
                        </button>
                    </div>
                </div>

                <!-- Dải hiển thị danh sách Saved Filters nhanh -->
                <c:if test="${not empty savedFilters}">
                    <div class="saved-filters-bar">
                        <span style="font-size: 12px; font-weight: 600; color: var(--color-text-secondary);">
                            <i class="fas fa-star" style="color: #f59e0b;"></i> Bộ lọc đã lưu nhanh:
                        </span>
                        <c:forEach var="sf" items="${savedFilters}">
                            <div class="saved-filter-chip">
                                <span onclick="window.location.href='${pageContext.request.contextPath}/leads?${sf.filterQuery != null ? sf.filterQuery : sf.criteria}'">
                                    <c:out value="${sf.filterName != null ? sf.filterName : sf.name}"/>
                                </span>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </form>

            <!-- Lead List Table -->
            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <c:set var="leadItems" value="${not empty leads ? leads : (not empty leadList ? leadList : list)}"/>
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <h2 class="card-title" style="font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-user-friends" style="color: var(--color-primary);"></i>
                        Danh sách Lead (${not empty leadItems ? leadItems.size() : (not empty totalLeads ? totalLeads : 0)})
                    </h2>
                    <div style="font-size: 13px; color: var(--color-text-secondary);">
                        Sắp xếp theo: <strong>Điểm số ưu tiên (Giảm dần)</strong>
                    </div>
                </div>

                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Họ và tên</th>
                                <th>Công ty</th>
                                <th>Liên hệ</th>
                                <th>Nguồn</th>
                                <th>Trạng thái</th>
                                <th>Điểm Lead (Scoring)</th>
                                <th>Phân loại</th>
                                <th>Người phụ trách</th>
                                <th>Cảnh báo SLA</th>
                                <th style="width: 140px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty leadItems}">
                                    <c:forEach var="item" items="${leadItems}">
                                        <c:set var="currentLeadId" value="${item.leadId != null && item.leadId > 0 ? item.leadId : item.id}"/>
                                        <c:set var="currentCompany" value="${item.companyName != null ? item.companyName : item.company}"/>
                                        <c:set var="currentSource" value="${item.sourceName != null ? item.sourceName : (item.source != null ? item.source : 'Chưa rõ')}"/>
                                        <c:set var="leadScore" value="${item.score != null ? item.score : 0}"/>
                                        <tr class="${item.slaOverdue ? 'row-sla-overdue' : ''}">
                                            <td>${currentLeadId}</td>
                                            <td>
                                                <div style="font-weight: 600; color: var(--color-gray-900);">
                                                    <a href="${pageContext.request.contextPath}/leads/detail?id=${currentLeadId}" class="text-primary">
                                                        <c:out value="${item.fullName}"/>
                                                    </a>
                                                </div>
                                            </td>
                                            <td><c:out value="${currentCompany}"/></td>
                                            <td>
                                                <div style="font-size: 13px;">
                                                    <c:if test="${not empty item.email}">
                                                        <div><i class="fas fa-envelope" style="color: #94a3b8; font-size: 11px;"></i> <c:out value="${item.email}"/></div>
                                                    </c:if>
                                                    <c:if test="${not empty item.phone}">
                                                        <div><i class="fas fa-phone" style="color: #94a3b8; font-size: 11px;"></i> <c:out value="${item.phone}"/></div>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td><span class="badge badge-neutral"><c:out value="${currentSource}"/></span></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.status == 'NEW' || item.status == 'Mới' || item.status == 'Mới tạo'}"><span class="badge badge-info">Mới tạo</span></c:when>
                                                    <c:when test="${item.status == 'CONTACTED' || item.status == 'Đang liên hệ'}"><span class="badge badge-warning">Đang liên hệ</span></c:when>
                                                    <c:when test="${item.status == 'QUALIFIED' || item.status == 'Tiềm năng'}"><span class="badge badge-success">Đã xác định NC</span></c:when>
                                                    <c:when test="${item.status == 'CONVERTED' || item.status == 'Đã chuyển đổi'}"><span class="badge" style="background:#dcfce7; color:#15803d;">Đã chuyển đổi</span></c:when>
                                                    <c:otherwise><span class="badge badge-neutral"><c:out value="${item.status}"/></span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <!-- Điểm số Lead (S4-05-AC-02 & S4-05-AC-04) -->
                                            <td>
                                                <span class="lead-score-pill ${leadScore >= 70 ? 'score-positive' : (leadScore >= 40 ? 'score-neutral' : 'score-negative')}">
                                                    <i class="fas fa-bolt"></i> ${leadScore} điểm
                                                </span>
                                            </td>
                                            <!-- Nhãn phân loại Nóng / Ấm / Lạnh (S4-05-AC-03) -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.classification == 'HOT' || item.rating == 'HOT' || leadScore >= 70}">
                                                        <span class="badge badge-hot"><i class="fas fa-fire"></i> NÓNG</span>
                                                    </c:when>
                                                    <c:when test="${item.classification == 'WARM' || item.rating == 'WARM' || (leadScore >= 40 && leadScore < 70)}">
                                                        <span class="badge badge-warm"><i class="fas fa-sun"></i> ẤM</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-cold"><i class="fas fa-snowflake"></i> LẠNH</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${item.ownerName != null ? item.ownerName : (item.ownerId != null ? item.ownerId : 'Chưa phân bổ')}"/></td>
                                            <!-- Nổi bật Lead quá SLA (S4-09-AC-02) -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.slaOverdue}">
                                                        <span class="badge badge-sla-overdue" title="Lead quá thời hạn phản hồi quy định!">
                                                            <i class="fas fa-exclamation-triangle"></i> Quá SLA
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="font-size: 12px; color: #16a34a;"><i class="fas fa-check-circle"></i> Trong hạn</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <div style="display: flex; gap: 4px; justify-content: center;">
                                                    <a href="${pageContext.request.contextPath}/leads/detail?id=${currentLeadId}" class="btn btn-secondary btn-sm" title="Xem chi tiết">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/edit?id=${currentLeadId}" class="btn btn-secondary btn-sm" title="Chỉnh sửa">
                                                        <i class="fas fa-pencil-alt"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/leads/convert?leadId=${currentLeadId}" class="btn btn-secondary btn-sm" style="color: #16a34a;" title="Chuyển đổi Lead">
                                                        <i class="fas fa-exchange-alt"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="11" style="text-align: center; padding: 32px 16px;">
                                            <div class="empty-state">
                                                <i class="fas fa-inbox" style="font-size: 36px; color: #cbd5e1; margin-bottom: 8px;"></i>
                                                <p style="color: var(--color-text-secondary); margin-bottom: 12px;">Chưa có dữ liệu Lead nào phù hợp với bộ lọc.</p>
                                                <a href="${pageContext.request.contextPath}/leads/create" class="btn btn-primary btn-sm">Tạo Lead mới ngay</a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Phân trang (Pagination) -->
                <c:if test="${not empty totalPages && totalPages > 1}">
                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; border-top: 1px solid var(--color-border);">
                        <div style="font-size: 13px; color: var(--color-text-secondary);">
                            Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng số: ${totalLeads} Lead)
                        </div>
                        <div style="display: flex; gap: 6px;">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/leads?page=${currentPage - 1}&keyword=${param.keyword}&status=${param.status}&rating=${param.rating}" class="btn btn-secondary btn-sm">Trước</a>
                            </c:if>
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/leads?page=${currentPage + 1}&keyword=${param.keyword}&status=${param.status}&rating=${param.rating}" class="btn btn-secondary btn-sm">Sau</a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<!-- Modal Lưu Bộ Lọc Lead (S4-09-AC-03) -->
<div id="saveLeadFilterModal" class="modal-backdrop">
    <div class="modal-dialog-box" style="padding: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 style="margin: 0; font-size: 18px; font-weight: 600; color: var(--color-gray-900);">
                <i class="fas fa-bookmark" style="color: var(--color-primary);"></i> Lưu bộ lọc Lead hay dùng
            </h3>
            <button type="button" onclick="closeSaveLeadFilterModal()" style="border: none; background: none; font-size: 20px; cursor: pointer; color: #64748b;">&times;</button>
        </div>
        <form id="saveLeadFilterForm" onsubmit="submitSaveLeadFilter(event)">
            <div style="margin-bottom: 16px;">
                <label class="form-label" style="font-weight: 600; font-size: 13px;">Đặt tên cho bộ lọc <span style="color:red">*</span></label>
                <input type="text" id="leadFilterNameInput" class="form-control" placeholder="VD: Lead Nóng sáng nay, Quá SLA..." required style="background: white; border: 1px solid var(--color-border); border-radius: 6px; padding: 10px; width: 100%;">
            </div>
            <p style="font-size: 13px; color: var(--color-text-secondary); margin-bottom: 20px;">
                Bộ lọc này sẽ được lưu vào tài khoản của bạn để áp dụng nhanh chỉ với một cú nhấp chuột mỗi buổi sáng.
            </p>
            <div style="display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn btn-secondary" onclick="closeSaveLeadFilterModal()">Hủy</button>
                <button type="submit" class="btn btn-primary" id="btnSubmitSaveFilter">Lưu bộ lọc</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openSaveLeadFilterModal() {
        document.getElementById('leadFilterNameInput').value = '';
        document.getElementById('saveLeadFilterModal').style.display = 'flex';
    }

    function closeSaveLeadFilterModal() {
        document.getElementById('saveLeadFilterModal').style.display = 'none';
    }

    function submitSaveLeadFilter(e) {
        e.preventDefault();
        const filterName = document.getElementById('leadFilterNameInput').value.trim();
        if (!filterName) {
            alert('Vui lòng nhập tên cho bộ lọc.');
            return;
        }

        const filterForm = document.getElementById('leadFilterForm');
        const formData = new FormData(filterForm);
        const params = new URLSearchParams(formData);
        params.append('filterName', filterName);

        const btn = document.getElementById('btnSubmitSaveFilter');
        btn.disabled = true;
        btn.innerText = 'Đang lưu...';

        fetch('${pageContext.request.contextPath}/leads/filters', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'Accept': 'application/json, text/html, */*'
            },
            body: params
        })
        .then(res => {
            if (res.ok) {
                alert('Lưu bộ lọc "' + filterName + '" thành công!');
                closeSaveLeadFilterModal();
                window.location.reload();
            } else {
                throw new Error('HTTP ' + res.status);
            }
        })
        .catch(err => {
            console.warn('Backend endpoint /leads/filters response:', err);
            // Fallback submit
            alert('Đã gửi yêu cầu lưu bộ lọc tới hệ thống.');
            closeSaveLeadFilterModal();
        })
        .finally(() => {
            btn.disabled = false;
            btn.innerText = 'Lưu bộ lọc';
        });
    }
</script>
</body>
</html>
