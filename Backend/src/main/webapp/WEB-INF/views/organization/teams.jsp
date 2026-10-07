<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cơ cấu Tổ chức Kinh doanh | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .org-container {
            display: grid;
            grid-template-columns: minmax(320px, 1fr) minmax(400px, 1.25fr);
            gap: 1.5rem;
            align-items: start;
        }
        @media (max-width: 1024px) {
            .org-container {
                grid-template-columns: 1fr;
            }
        }
        .org-col {
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .tree-card-body {
            padding: 1rem;
            max-height: 540px;
            overflow-y: auto;
        }

        .tree-node-level-0 {
            margin-bottom: 0.85rem;
        }
        .tree-node-level-1 {
            margin-left: 1.5rem;
            border-left: 2px solid #e2e8f0;
            padding-left: 1rem;
            margin-top: 0.5rem;
            margin-bottom: 0.5rem;
        }
        .tree-node-level-2 {
            margin-left: 1.5rem;
            border-left: 2px dashed #cbd5e1;
            padding-left: 1rem;
            margin-top: 0.5rem;
            margin-bottom: 0.5rem;
        }

        .team-card-item {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            padding: 0.85rem 1rem;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
            transition: all 0.15s ease-in-out;
        }

        .team-card-item:hover {
            border-color: #3b82f6;
            box-shadow: 0 2px 6px rgba(59, 130, 246, 0.1);
        }

        .team-card-info {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
            min-width: 0;
            flex: 1;
        }

        .team-title-row {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .team-name {
            font-weight: 600;
            font-size: 0.95rem;
            color: #1e293b;
        }

        .badge-id {
            font-size: 0.75rem;
            padding: 0.15rem 0.5rem;
            background-color: #f1f5f9;
            color: #475569;
            border-radius: 4px;
            font-weight: 500;
        }

        .badge-region {
            font-size: 0.75rem;
            padding: 0.15rem 0.5rem;
            background-color: #eff6ff;
            color: #1d4ed8;
            border-radius: 4px;
            font-weight: 500;
        }

        .team-sub-info {
            font-size: 0.825rem;
            color: #475569;
            line-height: 1.4;
        }

        .btn-edit-team {
            padding: 0.35rem 0.65rem;
            font-size: 0.8rem;
            font-weight: 500;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #334155;
            cursor: pointer;
            white-space: nowrap;
        }
        .btn-edit-team:hover {
            border-color: #3b82f6;
            color: #2563eb;
            background-color: #f8fafc;
        }

        .alert-success {
            padding: 0.75rem 1rem;
            background-color: #dcfce7;
            border: 1px solid #86efac;
            color: #166534;
            border-radius: 6px;
            margin-bottom: 1rem;
        }
        .alert-danger {
            padding: 0.75rem 1rem;
            background-color: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
            border-radius: 6px;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <div class="page-header" style="margin-bottom: 1.25rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h1 class="page-title">Cơ cấu Tổ chức Kinh doanh</h1>
                    <p class="page-description">Khai báo danh sách nhóm, quản lý cây phân cấp tổ chức và đồng bộ tài khoản người dùng.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-outline" onclick="resetForm()">+ Tạo nhóm mới</button>
                </div>
            </div>

            <c:if test="${param.success == 'update'}">
                <div class="alert-success">Cập nhật thông tin nhóm kinh doanh thành công! Tài khoản Trưởng nhóm đã được đồng bộ.</div>
            </c:if>
            <c:if test="${param.success == 'transfer'}">
                <div class="alert-success">Chuyển nhân viên sang nhóm mới thành công! Thuộc tính users.team_id và Data Scoping đã cập nhật.</div>
            </c:if>
            <c:if test="${not empty errors}">
                <div class="alert-danger">
                    <strong>Đã xảy ra lỗi:</strong>
                    <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.25rem;">
                        <c:forEach var="err" items="${errors}">
                            <li><c:out value="${err}"/></li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>

            <div class="org-container">
                <!-- Cột trái: Cây tổ chức & Chuyển nhân viên theo nhóm nguồn -->
                <div class="org-col">
                    <!-- Cây tổ chức kinh doanh -->
                    <div class="card">
                        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                            <h2 class="card-title">Cây tổ chức kinh doanh</h2>
                            <span style="font-size: 0.85rem; color: #64748b;">Cấu trúc Cha - Con</span>
                        </div>
                        <div class="card-body tree-card-body">
                            <div id="treeContainer">
                                <c:forEach var="t" items="${teams}">
                                    <c:if test="${empty t.parentTeamId || t.parentTeamId == 0}">
                                        <!-- Root level -->
                                        <div class="tree-node-level-0">
                                            <div class="team-card-item">
                                                <div class="team-card-info">
                                                    <div class="team-title-row">
                                                        <span class="team-name"><c:out value="${t.name}"/></span>
                                                        <span class="badge-id">ID: ${t.id}</span>
                                                        <c:if test="${not empty t.region}">
                                                            <span class="badge-region">Khu vực: <c:out value="${t.region}"/></span>
                                                        </c:if>
                                                    </div>
                                                    <div class="team-sub-info">
                                                        Trưởng nhóm: <strong><c:out value="${t.leaderName != null ? t.leaderName : 'Chưa phân công'}"/></strong>
                                                    </div>
                                                </div>
                                                <div style="display: flex; flex-direction: column; gap: 0.35rem; align-items: flex-end;">
                                                    <button type="button" class="btn-edit-team" onclick="editTeam(${t.id}, '<c:out value="${t.name}"/>', '${t.parentTeamId}', '${t.leaderId}', '<c:out value="${t.region}"/>', '<c:out value="${t.description}"/>')">Hiệu chỉnh</button>
                                                    <button type="button" class="btn-edit-team" style="font-size: 0.75rem;" onclick="selectTeamForTransfer(${t.id})">Chuyển NV</button>
                                                </div>
                                            </div>

                                            <!-- Sub teams level 1 -->
                                            <c:forEach var="sub" items="${teams}">
                                                <c:if test="${sub.parentTeamId == t.id}">
                                                    <div class="tree-node-level-1">
                                                        <div class="team-card-item">
                                                            <div class="team-card-info">
                                                                <div class="team-title-row">
                                                                    <span class="team-name"><c:out value="${sub.name}"/></span>
                                                                    <span class="badge-id">ID: ${sub.id}</span>
                                                                    <c:if test="${not empty sub.region}">
                                                                        <span class="badge-region">Khu vực: <c:out value="${sub.region}"/></span>
                                                                    </c:if>
                                                                </div>
                                                                <div class="team-sub-info">
                                                                    Trưởng nhóm: <strong><c:out value="${sub.leaderName != null ? sub.leaderName : 'Chưa phân công'}"/></strong>
                                                                </div>
                                                            </div>
                                                            <div style="display: flex; flex-direction: column; gap: 0.35rem; align-items: flex-end;">
                                                                <button type="button" class="btn-edit-team" onclick="editTeam(${sub.id}, '<c:out value="${sub.name}"/>', '${sub.parentTeamId}', '${sub.leaderId}', '<c:out value="${sub.region}"/>', '<c:out value="${sub.description}"/>')">Hiệu chỉnh</button>
                                                                <button type="button" class="btn-edit-team" style="font-size: 0.75rem;" onclick="selectTeamForTransfer(${sub.id})">Chuyển NV</button>
                                                            </div>
                                                        </div>

                                                        <!-- Sub teams level 2 -->
                                                        <c:forEach var="sub2" items="${teams}">
                                                            <c:if test="${sub2.parentTeamId == sub.id}">
                                                                <div class="tree-node-level-2">
                                                                    <div class="team-card-item">
                                                                        <div class="team-card-info">
                                                                            <div class="team-title-row">
                                                                                <span class="team-name"><c:out value="${sub2.name}"/></span>
                                                                                <span class="badge-id">ID: ${sub2.id}</span>
                                                                                <c:if test="${not empty sub2.region}">
                                                                                    <span class="badge-region">Khu vực: <c:out value="${sub2.region}"/></span>
                                                                                </c:if>
                                                                            </div>
                                                                            <div class="team-sub-info">
                                                                                Trưởng nhóm: <strong><c:out value="${sub2.leaderName != null ? sub2.leaderName : 'Chưa phân công'}"/></strong>
                                                                            </div>
                                                                        </div>
                                                                        <div style="display: flex; flex-direction: column; gap: 0.35rem; align-items: flex-end;">
                                                                            <button type="button" class="btn-edit-team" onclick="editTeam(${sub2.id}, '<c:out value="${sub2.name}"/>', '${sub2.parentTeamId}', '${sub2.leaderId}', '<c:out value="${sub2.region}"/>', '<c:out value="${sub2.description}"/>')">Hiệu chỉnh</button>
                                                                            <button type="button" class="btn-edit-team" style="font-size: 0.75rem;" onclick="selectTeamForTransfer(${sub2.id})">Chuyển NV</button>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:if>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${empty teams}">
                                    <div style="text-align: center; color: #64748b; padding: 2rem 0;">Chưa có dữ liệu nhóm kinh doanh.</div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- Chuyển nhân viên sang nhóm khác -->
                    <div class="card" id="transferCard">
                        <div class="card-header">
                            <h2 class="card-title">Chuyển nhân viên sang nhóm khác</h2>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/organization/teams/update" method="POST" id="transferForm">
                                <input type="hidden" name="action" value="transferUser">
                                
                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="sourceTeamId">Bước 1: Chọn nhóm hiện tại (Nhóm nguồn) (*)</label>
                                    <select id="sourceTeamId" name="sourceTeamId" class="form-control" style="width: 100%;" onchange="onSourceTeamChange(this.value)" required>
                                        <option value="">-- Chọn nhóm hiện tại --</option>
                                        <c:forEach var="t" items="${teams}">
                                            <option value="${t.id}">[ID: ${t.id}] <c:out value="${t.name}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="transferUserId">Bước 2 & 3: Chọn nhân viên thuộc nhóm nguồn (*)</label>
                                    <select id="transferUserId" name="transferUserId" class="form-control" style="width: 100%;" required>
                                        <option value="">-- Vui lòng chọn Nhóm hiện tại trước --</option>
                                    </select>
                                </div>

                                <div class="form-group" style="margin-bottom: 1.25rem;">
                                    <label for="targetTeamId">Bước 4: Chọn nhóm chuyển đến (Nhóm đích) (*)</label>
                                    <select id="targetTeamId" name="targetTeamId" class="form-control" style="width: 100%;" required>
                                        <option value="">-- Chọn nhóm đích --</option>
                                        <c:forEach var="t" items="${teams}">
                                            <option value="${t.id}">[ID: ${t.id}] <c:out value="${t.name}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <button type="submit" class="btn btn-primary" style="width: 100%;">Bước 5: Xác nhận chuyển nhóm</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Cột phải: Form Cập nhật nhóm & Danh sách nhân viên -->
                <div class="org-col">
                    <!-- Form Khai báo / Cập nhật Nhóm -->
                    <div class="card">
                        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                            <h2 class="card-title" id="formCardTitle">Khai báo / Cập nhật Nhóm kinh doanh</h2>
                            <button type="button" class="btn btn-sm btn-outline" onclick="resetForm()">Tạo mới</button>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/organization/teams/update" method="POST" id="teamForm">
                                <input type="hidden" id="teamId" name="teamId" value="">
                                
                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="displayTeamId">Mã nhóm (ID)</label>
                                    <input type="text" id="displayTeamId" class="form-control" style="width: 100%; background-color: #f8fafc;" readonly placeholder="Tự động sinh khi tạo mới">
                                </div>

                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="teamName">Tên nhóm kinh doanh (*)</label>
                                    <input type="text" id="teamName" name="teamName" class="form-control" style="width: 100%;" placeholder="VD: Nhóm Hà Nội 1, Nhóm Miền Nam..." required>
                                </div>

                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="parentTeamId">Nhóm cha (Parent Team)</label>
                                    <select id="parentTeamId" name="parentTeamId" class="form-control" style="width: 100%;">
                                        <option value="">(Không có - Nhóm cấp gốc)</option>
                                        <c:forEach var="pt" items="${teams}">
                                            <option value="${pt.id}">[ID: ${pt.id}] <c:out value="${pt.name}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="leaderId">Trưởng nhóm (Team Leader)</label>
                                    <select id="leaderId" name="leaderId" class="form-control" style="width: 100%;">
                                        <option value="">(Chưa phân công)</option>
                                        <c:forEach var="u" items="${not empty leaderCandidates ? leaderCandidates : users}">
                                            <option value="${u.accountId}">
                                                <c:out value="${u.fullName}"/> (<c:out value="${u.email}"/>)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group" style="margin-bottom: 1rem;">
                                    <label for="region">Khu vực địa lý (Region)</label>
                                    <input type="text" id="region" name="region" class="form-control" style="width: 100%;" placeholder="VD: Miền Bắc, Hà Nội, Miền Nam...">
                                </div>

                                <div class="form-group" style="margin-bottom: 1.25rem;">
                                    <label for="description">Mô tả nhóm</label>
                                    <textarea id="description" name="description" class="form-control" style="width: 100%; height: 75px;" placeholder="Nhập ghi chú hoặc mô tả nhóm..."></textarea>
                                </div>

                                <div style="display: flex; gap: 0.75rem;">
                                    <button type="submit" class="btn btn-primary" style="flex: 1;">Lưu thay đổi</button>
                                    <button type="button" class="btn btn-outline" onclick="resetForm()">Làm mới</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Bảng Danh sách Thành viên Quản lý tài khoản (Lọc duy nhất theo nhóm đó) -->
                    <div class="card">
                        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem;">
                            <h2 class="card-title">Thành viên Quản lý tài khoản</h2>
                            <div style="display: flex; align-items: center; gap: 0.5rem;">
                                <label for="memberFilterTeamId" style="font-size: 0.825rem; color: #64748b; margin: 0; white-space: nowrap;">Lọc theo nhóm:</label>
                                <select id="memberFilterTeamId" class="form-control" style="font-size: 0.85rem; padding: 0.25rem 0.5rem; max-width: 220px;" onchange="filterMemberTable(this.value)">
                                    <option value="">-- Chọn nhóm để xem --</option>
                                    <c:forEach var="t" items="${teams}">
                                        <option value="${t.id}">[ID: ${t.id}] <c:out value="${t.name}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="card-body table-container">
                            <table class="table" style="width: 100%;">
                                <thead>
                                    <tr>
                                        <th style="width: 70px;">Mã NV</th>
                                        <th>Họ và tên</th>
                                        <th>Nhóm hiện tại</th>
                                        <th>Email</th>
                                    </tr>
                                </thead>
                                <tbody id="memberTableBody">
                                    <c:forEach var="u" items="${users}">
                                        <tr class="member-row" data-team-id="${u.teamId}">
                                            <td>#${u.accountId}</td>
                                            <td><strong><c:out value="${u.fullName}"/></strong></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty u.teamName}">
                                                        <span class="badge-region"><c:out value="${u.teamName}"/> (ID: ${u.teamId})</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #94a3b8; font-size: 0.85rem;">Chưa thuộc nhóm</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size: 0.85rem; color: #64748b;"><c:out value="${u.email}"/></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty users}">
                                        <tr>
                                            <td colspan="4" style="text-align: center; color: #64748b; padding: 1.5rem 0;">Chưa có dữ liệu nhân viên.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    var allUsers = [
        <c:forEach var="u" items="${users}" varStatus="loop">
            {
                userId: ${u.accountId},
                fullName: '<c:out value="${u.fullName}"/>',
                email: '<c:out value="${u.email}"/>',
                teamId: ${u.teamId != null ? u.teamId : 'null'},
                teamName: '<c:out value="${u.teamName}"/>'
            }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];

    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/&/g, "&amp;")
                   .replace(/</g, "&lt;")
                   .replace(/>/g, "&gt;")
                   .replace(/"/g, "&quot;")
                   .replace(/'/g, "&#039;");
    }

    function filterMemberTable(selectedTeamId) {
        var tbody = document.getElementById('memberTableBody');
        if (!tbody) return;
        tbody.innerHTML = '';

        if (!selectedTeamId || selectedTeamId === '') {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #64748b; padding: 1.5rem 0;">Vui lòng chọn một nhóm từ bộ lọc trên để xem danh sách thành viên thuộc nhóm đó.</td></tr>';
            return;
        }

        var teamIdNum = parseInt(selectedTeamId);
        var filteredMembers = allUsers.filter(function(u) {
            return u.teamId === teamIdNum;
        });

        if (filteredMembers.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #64748b; padding: 1.5rem 0;">Nhóm này hiện chưa có thành viên nào.</td></tr>';
            return;
        }

        filteredMembers.forEach(function(u) {
            var tr = document.createElement('tr');
            var teamBadge = u.teamName ? '<span class="badge-region">' + escapeHtml(u.teamName) + ' (ID: ' + u.teamId + ')</span>'
                                       : '<span style="color: #94a3b8; font-size: 0.85rem;">Chưa thuộc nhóm</span>';

            tr.innerHTML = '<td>#' + u.userId + '</td>' +
                           '<td><strong>' + escapeHtml(u.fullName) + '</strong></td>' +
                           '<td>' + teamBadge + '</td>' +
                           '<td style="font-size: 0.85rem; color: #64748b;">' + escapeHtml(u.email) + '</td>';
            tbody.appendChild(tr);
        });
    }

    function onSourceTeamChange(selectedTeamId) {
        var userSelect = document.getElementById('transferUserId');
        userSelect.innerHTML = '<option value="">-- Chọn nhân viên --</option>';
        if (!selectedTeamId) {
            userSelect.innerHTML = '<option value="">-- Vui lòng chọn Nhóm hiện tại trước --</option>';
            return;
        }

        var teamIdNum = parseInt(selectedTeamId);
        var filteredMembers = allUsers.filter(function(u) {
            return u.teamId === teamIdNum;
        });

        if (filteredMembers.length === 0) {
            var opt = document.createElement('option');
            opt.value = '';
            opt.textContent = '(Nhóm này hiện chưa có nhân viên nào)';
            userSelect.appendChild(opt);
        } else {
            filteredMembers.forEach(function(u) {
                var opt = document.createElement('option');
                opt.value = u.userId;
                opt.textContent = u.fullName + ' (' + u.email + ')';
                userSelect.appendChild(opt);
            });
        }
    }

    function selectTeamForTransfer(teamId) {
        var sourceSelect = document.getElementById('sourceTeamId');
        sourceSelect.value = teamId;
        onSourceTeamChange(teamId);
        
        var filterSelect = document.getElementById('memberFilterTeamId');
        if (filterSelect) {
            filterSelect.value = teamId;
            filterMemberTable(teamId);
        }

        document.getElementById('transferCard').scrollIntoView({ behavior: 'smooth' });
    }

    function editTeam(id, name, parentId, leaderId, region, description) {
        document.getElementById('formCardTitle').innerText = 'Hiệu chỉnh Nhóm: ' + name;
        document.getElementById('teamId').value = id;
        document.getElementById('displayTeamId').value = id;
        document.getElementById('teamName').value = name;
        document.getElementById('parentTeamId').value = parentId && parentId !== 'null' ? parentId : '';
        document.getElementById('leaderId').value = leaderId && leaderId !== 'null' ? leaderId : '';
        document.getElementById('region').value = region && region !== 'null' ? region : '';
        document.getElementById('description').value = description && description !== 'null' ? description : '';
        
        var filterSelect = document.getElementById('memberFilterTeamId');
        if (filterSelect) {
            filterSelect.value = id;
            filterMemberTable(id);
        }

        document.getElementById('teamForm').scrollIntoView({ behavior: 'smooth' });
    }

    function resetForm() {
        document.getElementById('formCardTitle').innerText = 'Khai báo Nhóm kinh doanh mới';
        document.getElementById('teamId').value = '';
        document.getElementById('displayTeamId').value = 'Tự động';
        document.getElementById('teamName').value = '';
        document.getElementById('parentTeamId').value = '';
        document.getElementById('leaderId').value = '';
        document.getElementById('region').value = '';
        document.getElementById('description').value = '';
    }

    // Mặc định chọn nhóm đầu tiên (nếu có) để hiển thị danh sách thành viên thuộc nhóm đó
    document.addEventListener('DOMContentLoaded', function() {
        var filterSelect = document.getElementById('memberFilterTeamId');
        if (filterSelect && filterSelect.options.length > 1) {
            filterSelect.selectedIndex = 1; // Chọn nhóm đầu tiên
            filterMemberTable(filterSelect.value);
        }
    });
</script>
</body>
</html>
