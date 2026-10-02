<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.CustomFieldDefinition" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
    private static String nz(String s) { return s == null ? "" : s; }
    private static String typeLabel(String t) {
        if ("TEXT".equals(t)) return "Văn bản";
        if ("NUMBER".equals(t)) return "Số";
        if ("DATE".equals(t)) return "Ngày";
        if ("SELECT".equals(t)) return "Danh sách chọn";
        return nz(t);
    }
    private static String typeIcon(String t) {
        if ("NUMBER".equals(t)) return "fa-hashtag";
        if ("DATE".equals(t)) return "fa-calendar-days";
        if ("SELECT".equals(t)) return "fa-list-ul";
        return "fa-font";
    }
%>
<%
    List<CustomFieldDefinition> customFields =
            (List<CustomFieldDefinition>) request.getAttribute("customFields");
    Object errorsAttr = request.getAttribute("errors");

    String successParam = request.getParameter("success");
    String successMsg = null;
    if ("created".equals(successParam)) successMsg = "Đã thêm trường tùy chỉnh.";
    else if ("updated".equals(successParam)) successMsg = "Đã cập nhật trường tùy chỉnh.";
    else if ("deactivated".equals(successParam)) successMsg = "Đã vô hiệu hóa trường tùy chỉnh.";
    else if (successParam != null && !successParam.isEmpty()) successMsg = "Thao tác thành công.";

    boolean hasErrors = false;
    if (errorsAttr instanceof List) hasErrors = !((List<?>) errorsAttr).isEmpty();
    else if (errorsAttr != null) hasErrors = !errorsAttr.toString().isEmpty();

    String formAction = "CREATE", formId = "", formName = "", formType = "TEXT", formOptions = "";
    boolean formRequired = false;
    if (hasErrors) {
        if ("UPDATE".equals(request.getParameter("action"))) formAction = "UPDATE";
        formId = nz(request.getParameter("customFieldId"));
        formName = nz(request.getParameter("fieldName"));
        if (request.getParameter("fieldType") != null) formType = request.getParameter("fieldType");
        formOptions = nz(request.getParameter("options"));
        formRequired = "true".equals(request.getParameter("required"));
    }
    boolean editing = "UPDATE".equals(formAction);

    int total = 0, activeCount = 0, requiredCount = 0;
    if (customFields != null) {
        for (CustomFieldDefinition f : customFields) {
            total++;
            if (!"INACTIVE".equals(f.getStatus())) activeCount++;
            if (f.isRequired()) requiredCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Trường tùy chỉnh khách hàng | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="content-container">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span><span>Khách hàng</span><span>/</span>
                <span class="breadcrumb-current">Trường tùy chỉnh</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Trường tùy chỉnh khách hàng</h1>
                    <p class="page-description">Thêm các cột riêng mà nhân viên đang tự ghi trong Excel vào hồ sơ khách hàng.</p>
                </div>
            </div>

            <% if (successMsg != null) { %>
                <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> <%= esc(successMsg) %></div>
            <% } %>
            <% if (hasErrors) { %>
                <div class="alert alert-danger">
                    <% if (errorsAttr instanceof List) {
                           for (Object err : (List<?>) errorsAttr) { %>
                        <div><i class="fa-solid fa-circle-exclamation"></i> <%= esc(String.valueOf(err)) %></div>
                    <%     }
                       } else { %>
                        <div><i class="fa-solid fa-circle-exclamation"></i> <%= esc(errorsAttr.toString()) %></div>
                    <% } %>
                </div>
            <% } %>

            <div class="cf-stats">
                <div class="cf-stat"><span class="cf-stat-icon"><i class="fa-solid fa-layer-group"></i></span>
                    <div><div class="cf-stat-num"><%= total %></div><div class="cf-stat-label">Tổng số trường</div></div></div>
                <div class="cf-stat cf-stat-ok"><span class="cf-stat-icon"><i class="fa-solid fa-circle-check"></i></span>
                    <div><div class="cf-stat-num"><%= activeCount %></div><div class="cf-stat-label">Đang dùng</div></div></div>
                <div class="cf-stat cf-stat-off"><span class="cf-stat-icon"><i class="fa-solid fa-ban"></i></span>
                    <div><div class="cf-stat-num"><%= total - activeCount %></div><div class="cf-stat-label">Đã vô hiệu</div></div></div>
                <div class="cf-stat cf-stat-req"><span class="cf-stat-icon"><i class="fa-solid fa-asterisk"></i></span>
                    <div><div class="cf-stat-num"><%= requiredCount %></div><div class="cf-stat-label">Bắt buộc nhập</div></div></div>
            </div>

            <div class="cf-layout">
                <!-- Danh sách -->
                <section class="card">
                    <div class="card-body">
                        <div class="cf-toolbar">
                            <div class="cf-search">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="search" id="cfSearch" class="form-control" placeholder="Tìm theo tên trường..." aria-label="Tìm trường">
                            </div>
                            <select id="cfStatusFilter" class="form-control cf-filter" aria-label="Lọc trạng thái">
                                <option value="">Tất cả trạng thái</option>
                                <option value="ACTIVE">Đang dùng</option>
                                <option value="INACTIVE">Đã vô hiệu</option>
                            </select>
                        </div>

                        <div class="table-container">
                            <table class="table">
                                <thead>
                                    <tr><th>Tên trường</th><th>Kiểu dữ liệu</th><th>Trạng thái</th><th>Thao tác</th></tr>
                                </thead>
                                <tbody id="cfBody">
                                <% if (customFields == null || customFields.isEmpty()) { %>
                                    <tr><td colspan="4">
                                        <div class="cf-empty">
                                            <i class="fa-regular fa-folder-open"></i>
                                            <strong>Chưa có trường tùy chỉnh nào</strong>
                                            <span>Hãy thêm trường đầu tiên ở khung bên cạnh.</span>
                                        </div>
                                    </td></tr>
                                <% } else {
                                       for (CustomFieldDefinition f : customFields) {
                                           boolean active = !"INACTIVE".equals(f.getStatus());
                                           String opts = nz(f.getOptions()); %>
                                    <tr class="cf-row" data-name="<%= esc(nz(f.getFieldLabel()).toLowerCase()) %>"
                                        data-status="<%= active ? "ACTIVE" : "INACTIVE" %>">
                                        <td>
                                            <div class="cf-name"><%= esc(f.getFieldLabel()) %>
                                                <% if (f.isRequired()) { %><span class="cf-req" title="Bắt buộc nhập">*</span><% } %>
                                            </div>
                                            <% if ("SELECT".equals(f.getFieldType()) && !opts.trim().isEmpty()) { %>
                                            <div class="cf-chips">
                                                <% for (String o : opts.split(",")) { if (!o.trim().isEmpty()) { %>
                                                <span class="cf-chip"><%= esc(o.trim()) %></span>
                                                <% } } %>
                                            </div>
                                            <% } %>
                                        </td>
                                        <td><span class="cf-type"><i class="fa-solid <%= typeIcon(f.getFieldType()) %>"></i> <%= esc(typeLabel(f.getFieldType())) %></span></td>
                                        <td><span class="badge <%= active ? "badge-success" : "badge-neutral" %>"><%= active ? "Đang dùng" : "Đã vô hiệu" %></span></td>
                                        <td>
                                            <div class="cf-row-actions">
                                                <button type="button" class="btn btn-secondary btn-sm cf-edit"
                                                        data-id="<%= f.getFieldId() %>" data-label="<%= esc(f.getFieldLabel()) %>"
                                                        data-type="<%= esc(f.getFieldType()) %>" data-required="<%= f.isRequired() %>"
                                                        data-options="<%= esc(f.getOptions()) %>"><i class="fa-solid fa-pen"></i> Sửa</button>
                                                <% if (active) { %>
                                                <form method="POST" action="${pageContext.request.contextPath}/custom-fields" class="cf-deactivate-form">
                                                    <input type="hidden" name="action" value="DEACTIVATE">
                                                    <input type="hidden" name="customFieldId" value="<%= f.getFieldId() %>">
                                                    <input type="hidden" name="entityType" value="CUSTOMER">
                                                    <button type="submit" class="btn btn-secondary btn-sm"><i class="fa-solid fa-ban"></i> Vô hiệu hóa</button>
                                                </form>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                <%     }
                                   } %>
                                    <tr id="cfNoResult" style="display: none;"><td colspan="4">
                                        <div class="cf-empty"><i class="fa-solid fa-magnifying-glass"></i><strong>Không tìm thấy trường phù hợp</strong></div>
                                    </td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- Form -->
                <aside class="card cf-form-card">
                    <div class="card-body">
                        <h2 id="cfFormTitle" class="cf-form-title">
                            <i class="fa-solid <%= editing ? "fa-pen-to-square" : "fa-plus" %>"></i>
                            <span><%= editing ? "Sửa trường tùy chỉnh" : "Thêm trường mới" %></span>
                        </h2>
                        <form id="cfForm" method="POST" action="${pageContext.request.contextPath}/custom-fields">
                            <input type="hidden" name="action" id="cfAction" value="<%= formAction %>">
                            <input type="hidden" name="customFieldId" id="cfId" value="<%= esc(formId) %>">
                            <input type="hidden" name="entityType" value="CUSTOMER">

                            <div class="form-group">
                                <label for="cfName">Tên trường (*)</label>
                                <input type="text" id="cfName" name="fieldName" class="form-control" required maxlength="100"
                                       placeholder="Ví dụ: Nguồn khách hàng" value="<%= esc(formName) %>">
                            </div>
                            <div class="form-group">
                                <label for="cfFieldType">Kiểu dữ liệu (*)</label>
                                <select id="cfFieldType" name="fieldType" class="form-control" required>
                                    <option value="TEXT" <%= "TEXT".equals(formType) ? "selected" : "" %>>Văn bản</option>
                                    <option value="NUMBER" <%= "NUMBER".equals(formType) ? "selected" : "" %>>Số</option>
                                    <option value="DATE" <%= "DATE".equals(formType) ? "selected" : "" %>>Ngày</option>
                                    <option value="SELECT" <%= "SELECT".equals(formType) ? "selected" : "" %>>Danh sách chọn</option>
                                </select>
                            </div>
                            <div class="form-group" id="cfOptionsGroup" style="display: none;">
                                <label for="cfOptions">Các lựa chọn (*)</label>
                                <input type="text" id="cfOptions" name="options" class="form-control"
                                       placeholder="Nhỏ, Vừa, Lớn" value="<%= esc(formOptions) %>">
                                <small class="cf-hint">Ngăn cách các lựa chọn bằng dấu phẩy.</small>
                                <div id="cfPreview" class="cf-chips"></div>
                            </div>
                            <label class="cf-switch">
                                <input type="checkbox" id="cfRequired" name="required" value="true" <%= formRequired ? "checked" : "" %>>
                                <span class="cf-switch-track"></span>
                                <span class="cf-switch-text">Bắt buộc nhập</span>
                            </label>

                            <div class="cf-form-actions">
                                <button type="submit" id="cfSubmit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu trường</button>
                                <button type="button" id="cfCancel" class="btn btn-secondary<%= editing ? "" : " cf-hidden" %>">Hủy sửa</button>
                            </div>
                        </form>
                    </div>
                </aside>
            </div>
        </div>
    </main>
</div>

<script>
    (function () {
        var typeSel = document.getElementById('cfFieldType');
        var optGroup = document.getElementById('cfOptionsGroup');
        var optInput = document.getElementById('cfOptions');
        var preview = document.getElementById('cfPreview');
        var cancelBtn = document.getElementById('cfCancel');
        var form = document.getElementById('cfForm');

        function renderPreview() {
            preview.textContent = '';
            optInput.value.split(',').forEach(function (o) {
                o = o.trim();
                if (!o) return;
                var chip = document.createElement('span');
                chip.className = 'cf-chip';
                chip.textContent = o;
                preview.appendChild(chip);
            });
        }
        function toggleOptions() {
            var isSelect = typeSel.value === 'SELECT';
            optGroup.style.display = isSelect ? 'block' : 'none';
            optInput.required = isSelect;
            if (!isSelect) optInput.value = '';
            renderPreview();
        }
        typeSel.addEventListener('change', toggleOptions);
        optInput.addEventListener('input', renderPreview);

        function setForm(action, id, label, type, required, options, title, icon) {
            document.getElementById('cfAction').value = action;
            document.getElementById('cfId').value = id;
            document.getElementById('cfName').value = label;
            typeSel.value = type;
            document.getElementById('cfRequired').checked = required;
            toggleOptions();
            optInput.value = (type === 'SELECT') ? options : '';
            renderPreview();
            document.querySelector('#cfFormTitle span').textContent = title;
            document.querySelector('#cfFormTitle i').className = 'fa-solid ' + icon;
            cancelBtn.style.display = (action === 'UPDATE') ? 'inline-flex' : 'none';
        }

        document.querySelectorAll('.cf-edit').forEach(function (btn) {
            btn.addEventListener('click', function () {
                setForm('UPDATE', btn.dataset.id, btn.dataset.label, btn.dataset.type,
                        btn.dataset.required === 'true', btn.dataset.options, 'Sửa trường tùy chỉnh', 'fa-pen-to-square');
                form.scrollIntoView({ behavior: 'smooth', block: 'center' });
                document.getElementById('cfName').focus();
            });
        });
        cancelBtn.addEventListener('click', function () {
            setForm('CREATE', '', '', 'TEXT', false, '', 'Thêm trường mới', 'fa-plus');
        });

        document.querySelectorAll('.cf-deactivate-form').forEach(function (f) {
            f.addEventListener('submit', function (e) {
                if (!confirm('Vô hiệu hóa trường này? Dữ liệu đã nhập vẫn được giữ lại.')) e.preventDefault();
            });
        });

        // Tìm kiếm và lọc ngay trên trình duyệt
        var search = document.getElementById('cfSearch');
        var statusSel = document.getElementById('cfStatusFilter');
        var rows = document.querySelectorAll('#cfBody .cf-row');
        var noResult = document.getElementById('cfNoResult');
        function applyFilter() {
            var q = search.value.trim().toLowerCase();
            var st = statusSel.value;
            var shown = 0;
            rows.forEach(function (r) {
                var ok = (!q || r.dataset.name.indexOf(q) !== -1) && (!st || r.dataset.status === st);
                r.style.display = ok ? '' : 'none';
                if (ok) shown++;
            });
            noResult.style.display = (rows.length > 0 && shown === 0) ? '' : 'none';
        }
        search.addEventListener('input', applyFilter);
        statusSel.addEventListener('change', applyFilter);

        form.addEventListener('submit', function () {
            var b = document.getElementById('cfSubmit');
            b.disabled = true;
            b.textContent = 'Đang lưu...';
        });

        toggleOptions();
    })();
</script>
</body>
</html>