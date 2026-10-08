<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cơ hội kinh doanh | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/opportunities.css">
    <style>
        .deals-toolbar {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
        }
        .search-group-inline {
            display: flex;
            align-items: center;
            gap: 8px;
            background: white;
            padding: 4px 8px 4px 16px;
            border-radius: 8px;
            border: 1px solid var(--color-border);
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            flex: 1;
            min-width: 320px;
            max-width: 480px;
        }
        .search-group-inline .form-control {
            border: none;
            box-shadow: none;
            padding: 8px 0;
            width: 100%;
            outline: none;
        }
        .search-group-inline .search-icon {
            color: var(--color-text-secondary);
        }
        .filter-actions {
            display: flex;
            gap: 8px;
        }
        .card-header-flex {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .empty-state {
            padding: 48px 0;
            text-align: center;
            color: var(--color-text-secondary);
        }
        .empty-state-icon {
            font-size: 32px;
            margin-bottom: 16px;
            color: var(--color-gray-400);
        }
        @media (max-width: 768px) {
            .search-group-inline {
                max-width: 100%;
            }
            .filter-actions {
                width: 100%;
            }
            .filter-actions .btn {
                flex: 1;
            }
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
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                <span>/</span>
                <span class="breadcrumb-current">Cơ hội kinh doanh</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Cơ hội kinh doanh</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Quản lý danh sách các cơ hội bán hàng.</p>
                </div>
                <div class="page-actions" style="display: flex; gap: 8px;">
                    <button class="btn btn-primary" onclick="openOppModal()"><i class="fas fa-plus"></i> Thêm cơ hội</button>
                    <a href="${pageContext.request.contextPath}/deals/export?keyword=<c:out value='${keyword}'/>&filterFieldId=${filterFieldId}&filterFieldValue=<c:out value='${filterFieldValue}'/>" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">
                        <i class="fas fa-file-export"></i> Xuất CSV
                    </a>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/deals" method="get" class="deals-toolbar">
                <div class="search-group-inline">
                    <i class="fas fa-search search-icon"></i>
                    <input class="form-control" name="keyword" type="search" placeholder="Tìm theo tiêu đề..." value="<c:out value='${keyword}'/>">
                </div>
                <c:if test="${not empty customFieldDefinitions}">
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <select name="filterFieldId" class="form-control" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 6px 12px;">
                            <option value="">-- Lọc theo trường tùy chỉnh --</option>
                            <c:forEach var="def" items="${customFieldDefinitions}">
                                <option value="${def.fieldId}" ${filterFieldId == def.fieldId ? 'selected' : ''}><c:out value="${def.fieldLabel}"/></option>
                            </c:forEach>
                        </select>
                        <input type="text" name="filterFieldValue" class="form-control" placeholder="Giá trị..." value="<c:out value='${filterFieldValue}'/>" style="background: white; border: 1px solid var(--color-border); border-radius: 8px; padding: 6px 12px; max-width: 160px;">
                    </div>
                </c:if>
                <div class="filter-actions">
                    <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i> Lọc</button>
                    <c:if test="${not empty keyword or not empty filterFieldId}">
                        <a href="${pageContext.request.contextPath}/deals" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border);">Đặt lại</a>
                    </c:if>
                </div>
            </form>

            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <div class="card-header card-header-flex">
                    <h2 class="card-title" style="font-size: 16px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-list-ul" style="color: var(--color-primary);"></i> Danh sách cơ hội kinh doanh</h2>
                </div>
                
                <div class="table-container table-responsive">
                    <table class="table">
                        <thead style="background: #f8fafc;">
                            <tr>
                                <th style="width: 70px; color: var(--color-text-secondary); font-weight: 600; text-transform: none;">ID</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Tiêu đề cơ hội</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Giá trị</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Giai đoạn Pipeline</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none; text-align: center;">Xác suất %</th>
                                <th style="color: var(--color-text-secondary); font-weight: 600; text-transform: none;">Ngày tạo</th>
                                <th style="width: 100px; color: var(--color-text-secondary); font-weight: 600; text-transform: none; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty list}">
                                    <c:forEach var="item" items="${list}">
                                        <tr style="height: 64px;">
                                            <td style="color: var(--color-text-secondary);">${item.opportunityId}</td>
                                            <td>
                                                <div style="font-weight: 500; color: var(--color-gray-900);"><c:out value="${item.title}"/></div>
                                                <c:if test="${not empty item.reasonName}">
                                                    <span style="font-size: 12px; color: var(--color-text-secondary);"><i class="fas fa-tag"></i> <c:out value="${item.reasonName}"/></span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <strong style="color: var(--color-gray-900);"><fmt:formatNumber value="${item.amount}" type="currency" currencySymbol="₫"/></strong>
                                            </td>
                                            <td>
                                                <span class="badge" style="padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 500; background: ${item.probability >= 100 ? '#dcfce7' : item.probability <= 0 ? '#fee2e2' : '#e0f2fe'}; color: ${item.probability >= 100 ? '#166534' : item.probability <= 0 ? '#991b1b' : '#0369a1'};">
                                                    <c:choose>
                                                        <c:when test="${not empty item.stageName}"><c:out value="${item.stageName}"/></c:when>
                                                        <c:otherwise>Chưa chọn stage</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td style="text-align: center;">
                                                <strong style="color: var(--color-primary);">${item.probability}%</strong>
                                            </td>
                                            <td><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/deals/detail?id=${item.opportunityId}" class="btn btn-secondary" style="background: white; border: 1px solid var(--color-border); padding: 4px 12px; font-size: 13px;" title="Xem chi tiết"><i class="fas fa-eye"></i> Xem</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <div class="empty-state-icon"><i class="fas fa-folder-open"></i></div>
                                                <c:choose>
                                                    <c:when test="${not empty keyword}">
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Không tìm thấy cơ hội</h3>
                                                        <p>Không có kết quả phù hợp với từ khóa "<c:out value='${keyword}'/>"</p>
                                                        <a href="${pageContext.request.contextPath}/deals" class="btn btn-secondary" style="margin-top: 16px;">Đặt lại tìm kiếm</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <h3 style="font-size: 16px; margin-bottom: 8px; color: var(--color-gray-900);">Chưa có cơ hội kinh doanh</h3>
                                                        <p>Danh sách hiện chưa có dữ liệu cơ hội bán hàng.</p>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalPages > 1}">
                    <div class="card-footer" style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--color-border); padding: 12px 24px;">
                        <span style="color: var(--color-text-secondary); font-size: 13px;">Trang ${currentPage} / ${totalPages}</span>
                        <ul class="pagination" style="margin: 0; display: flex; gap: 4px; list-style: none; padding: 0;">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}" style="opacity: ${currentPage == 1 ? '0.5' : '1'}; pointer-events: ${currentPage == 1 ? 'none' : 'auto'};">
                                <a class="page-link btn btn-secondary" style="padding: 4px 12px; background: white; border: 1px solid var(--color-border);" href="?page=${currentPage - 1}&keyword=<c:out value='${keyword}'/>">‹ Trước</a>
                            </li>
                            <c:forEach begin="${currentPage - 2 > 1 ? currentPage - 2 : 1}" end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link btn ${currentPage == i ? 'btn-primary' : 'btn-secondary'}" style="padding: 4px 12px; ${currentPage != i ? 'background: white; border: 1px solid var(--color-border);' : ''}" href="?page=${i}&keyword=<c:out value='${keyword}'/>">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}" style="opacity: ${currentPage == totalPages ? '0.5' : '1'}; pointer-events: ${currentPage == totalPages ? 'none' : 'auto'};">
                                <a class="page-link btn btn-secondary" style="padding: 4px 12px; background: white; border: 1px solid var(--color-border);" href="?page=${currentPage + 1}&keyword=<c:out value='${keyword}'/>">Sau ›</a>
                            </li>
                        </ul>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<!-- Modal Create Opportunity -->
<div id="oppModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 2000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background: white; border-radius: 8px; width: 100%; max-width: 580px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="margin: 0; font-size: 18px;">Thêm mới cơ hội kinh doanh</h3>
            <button onclick="closeOppModal()" style="border: none; background: none; font-size: 20px; cursor: pointer;">&times;</button>
        </div>
        <form id="oppForm" onsubmit="saveOpportunity(event)">
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tiêu đề cơ hội <span style="color:red;">*</span></label>
                <input type="text" id="oppTitle" name="title" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Giá trị dự kiến (VNĐ)</label>
                <input type="number" step="any" id="oppAmount" name="amount" class="form-control" value="0" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
            </div>

            <!-- Pipeline Stage (S2-09) -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Giai đoạn Pipeline</label>
                <select id="oppStageSelect" name="pipelineStageId" class="form-control" onchange="onStageChange(this)" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                    <option value="" data-prob="0" data-condition="">-- Chọn giai đoạn --</option>
                    <c:forEach var="st" items="${pipelineStages}">
                        <option value="${st.pipelineStageId}" data-prob="${st.defaultProbability}" data-condition="<c:out value='${st.exitCondition}'/>" data-name="<c:out value='${st.stageName}'/>">
                            <c:out value="${st.stageName}"/> (${st.defaultProbability}%)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <!-- Win Probability Realtime (S2-09) -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Xác suất thành công (%) (Realtime)</label>
                <input type="number" step="0.1" min="0" max="100" id="oppProbability" name="probability" class="form-control" value="0" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px; background: #f8fafc;">
            </div>

            <!-- Exit Condition Notice Banner -->
            <div id="stageExitNotice" style="display: none; background: #eff6ff; border: 1px solid #93c5fd; color: #1e40af; padding: 10px 14px; border-radius: 6px; margin-bottom: 16px; font-size: 13px;">
                <i class="fas fa-info-circle"></i> <strong>Yêu cầu chuyển giai đoạn:</strong> <span id="stageExitText"></span>
            </div>

            <!-- Win Reason Dropdown (S2-10 - WIN) -->
            <div id="winReasonGroup" class="form-group" style="display: none; margin-bottom: 16px; background: #f0fdf4; padding: 12px; border-radius: 6px; border: 1px solid #bbf7d0;">
                <label style="display: block; margin-bottom: 6px; font-weight: 600; color: #166534;">Lý do THẮNG (Win Reason) <span style="color:red;">*</span></label>
                <select id="winReasonSelect" name="winLossReasonId" class="form-control" style="width: 100%; padding: 8px; border: 1px solid #86efac; border-radius: 6px;">
                    <option value="">-- Chọn lý do thắng từ CSDL --</option>
                    <c:forEach var="w" items="${winReasons}">
                        <option value="${w.reasonId}"><c:out value="${w.reasonName}"/></option>
                    </c:forEach>
                </select>
            </div>

            <!-- Loss Reason & Competitor Group (S2-10 - LOSS) -->
            <div id="lossReasonGroup" class="form-group" style="display: none; margin-bottom: 16px; background: #fef2f2; padding: 12px; border-radius: 6px; border: 1px solid #fecaca;">
                <label style="display: block; margin-bottom: 6px; font-weight: 600; color: #991b1b;">Lý do THUA (Loss Reason) <span style="color:red;">*</span></label>
                <select id="lossReasonSelect" name="winLossReasonId" class="form-control" style="width: 100%; padding: 8px; border: 1px solid #fca5a5; border-radius: 6px; margin-bottom: 12px;">
                    <option value="">-- Chọn lý do thua từ CSDL --</option>
                    <c:forEach var="l" items="${lossReasons}">
                        <option value="${l.reasonId}"><c:out value="${l.reasonName}"/></option>
                    </c:forEach>
                </select>

                <label style="display: block; margin-bottom: 6px; font-weight: 600; color: #991b1b;">Đối thủ cạnh tranh</label>
                <select id="competitorSelect" name="competitorId" class="form-control" style="width: 100%; padding: 8px; border: 1px solid #fca5a5; border-radius: 6px;">
                    <option value="">-- Chọn đối thủ cạnh tranh --</option>
                    <c:forEach var="c" items="${competitors}">
                        <option value="${c.competitorId}"><c:out value="${c.competitorName}"/></option>
                    </c:forEach>
                </select>
            </div>

            <!-- Dynamic Custom Fields -->
            <c:if test="${not empty customFieldDefinitions}">
                <div style="border-top: 1px solid var(--color-border); padding-top: 12px; margin-top: 12px;">
                    <h4 style="font-size: 14px; margin-bottom: 12px; color: var(--color-primary);">Trường tùy chỉnh (Custom Fields)</h4>
                    <c:forEach var="def" items="${customFieldDefinitions}">
                        <div class="form-group" style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 6px; font-weight: 500;">
                                <c:out value="${def.fieldLabel}"/>
                                <c:if test="${def.required}"><span style="color:red;"> *</span></c:if>
                            </label>
                            <c:choose>
                                <c:when test="${def.fieldType == 'SELECT'}">
                                    <select name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                        <option value="">-- Chọn --</option>
                                        <c:forEach var="opt" items="${def.options.split('[,;\\\\n]+')}">
                                            <option value="${opt.trim()}"><c:out value="${opt.trim()}"/></option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:when test="${def.fieldType == 'DATE'}">
                                    <input type="date" name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                </c:when>
                                <c:when test="${def.fieldType == 'NUMBER'}">
                                    <input type="number" step="any" name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                </c:when>
                                <c:otherwise>
                                    <input type="text" name="customField_${def.fieldId}" class="form-control" ${def.required ? 'required' : ''} style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 20px;">
                <button type="button" onclick="closeOppModal()" class="btn btn-secondary" style="padding: 8px 16px;">Hủy</button>
                <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Lưu cơ hội</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openOppModal() {
        document.getElementById('oppForm').reset();
        document.getElementById('winReasonGroup').style.display = 'none';
        document.getElementById('lossReasonGroup').style.display = 'none';
        document.getElementById('stageExitNotice').style.display = 'none';
        document.getElementById('oppModal').style.display = 'flex';
    }

    function closeOppModal() {
        document.getElementById('oppModal').style.display = 'none';
    }

    function onStageChange(selectElem) {
        const selectedOption = selectElem.options[selectElem.selectedIndex];
        if (!selectedOption || !selectedOption.value) {
            document.getElementById('oppProbability').value = 0;
            document.getElementById('stageExitNotice').style.display = 'none';
            document.getElementById('winReasonGroup').style.display = 'none';
            document.getElementById('lossReasonGroup').style.display = 'none';
            return;
        }

        const prob = parseFloat(selectedOption.getAttribute('data-prob') || '0');
        const condition = selectedOption.getAttribute('data-condition') || '';
        const stageName = (selectedOption.getAttribute('data-name') || '').toLowerCase();

        // Realtime probability update (S2-09)
        document.getElementById('oppProbability').value = prob;

        // Show Exit Condition Notice if present (S2-09)
        if (condition && condition.trim() !== '') {
            document.getElementById('stageExitText').innerText = condition;
            document.getElementById('stageExitNotice').style.display = 'block';
        } else {
            document.getElementById('stageExitNotice').style.display = 'none';
        }

        // Show Won / Lost reasons (S2-10)
        const winSelect = document.getElementById('winReasonSelect');
        const lossSelect = document.getElementById('lossReasonSelect');

        if (prob >= 100 || stageName.includes('won') || stageName.includes('thành công')) {
            document.getElementById('winReasonGroup').style.display = 'block';
            document.getElementById('lossReasonGroup').style.display = 'none';
            winSelect.name = 'winLossReasonId';
            lossSelect.removeAttribute('name');
        } else if (prob <= 0 || stageName.includes('lost') || stageName.includes('thất bại')) {
            document.getElementById('winReasonGroup').style.display = 'none';
            document.getElementById('lossReasonGroup').style.display = 'block';
            lossSelect.name = 'winLossReasonId';
            winSelect.removeAttribute('name');
        } else {
            document.getElementById('winReasonGroup').style.display = 'none';
            document.getElementById('lossReasonGroup').style.display = 'none';
            winSelect.removeAttribute('name');
            lossSelect.removeAttribute('name');
        }
    }

    function saveOpportunity(e) {
        e.preventDefault();
        const form = document.getElementById('oppForm');
        const formData = new FormData(form);
        const params = new URLSearchParams(formData);

        fetch('${pageContext.request.contextPath}/deals/create', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: params
        })
        .then(async res => {
            const data = await res.json();
            if (!res.ok) {
                alert('Lỗi: ' + (data.error || 'Thao tác không hợp lệ') + (data.details ? '\n- ' + data.details.join('\n- ') : ''));
            } else {
                closeOppModal();
                window.location.reload();
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ.'));
    }
</script>

</body>
</html>

