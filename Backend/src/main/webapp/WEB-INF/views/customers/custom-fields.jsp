<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.crm.model.CustomFieldDefinition" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
    private static String nz(String s) {
        return s == null ? "" : s;
    }
    private static String typeLabel(String t) {
        if ("TEXT".equals(t)) return "Văn bản";
        if ("NUMBER".equals(t)) return "Số";
        if ("DATE".equals(t)) return "Ngày";
        if ("SELECT".equals(t)) return "Danh sách chọn";
        return nz(t);
    }
%>
<%
    // Dữ liệu do CustomFieldServlet đặt vào request
    List<CustomFieldDefinition> customFields =
            (List<CustomFieldDefinition>) request.getAttribute("customFields");
    Object errorsAttr = request.getAttribute("errors");

    // Thông báo thành công: servlet redirect về GET kèm ?success=created|updated|deactivated
    String successParam = request.getParameter("success");
    String successMsg = null;
    if ("created".equals(successParam)) successMsg = "Đã thêm trường tùy chỉnh.";
    else if ("updated".equals(successParam)) successMsg = "Đã cập nhật trường tùy chỉnh.";
    else if ("deactivated".equals(successParam)) successMsg = "Đã vô hiệu hóa trường tùy chỉnh.";
    else if (successParam != null && !successParam.isEmpty()) successMsg = "Thao tác thành công.";

    // Khi POST lỗi, servlet forward lại JSP: giữ nguyên dữ liệu người dùng vừa nhập
    boolean hasErrors = false;
    if (errorsAttr instanceof List) hasErrors = !((List<?>) errorsAttr).isEmpty();
    else if (errorsAttr != null) hasErrors = !errorsAttr.toString().isEmpty();

    String formAction = "CREATE";
    String formId = "";
    String formName = "";
    String formType = "TEXT";
    String formOptions = "";
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
                <span>/</span>
                <span>Khách hàng</span>
                <span>/</span>
                <span class="breadcrumb-current">Trường tùy chỉnh</span>
            </nav>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Trường tùy chỉnh khách hàng</h1>
                    <p class="page-description">Khai báo các trường bổ sung cho hồ sơ khách hàng.</p>
                </div>
            </div>

            <% if (successMsg != null) { %>
                <div class="alert alert-success"><%= esc(successMsg) %></div>
            <% } %>
            <% if (hasErrors) { %>
                <div class="alert alert-danger">
                    <% if (errorsAttr instanceof List) {
                           for (Object err : (List<?>) errorsAttr) { %>
                        <div><%= esc(String.valueOf(err)) %></div>
                    <%     }
                       } else { %>
                        <div><%= esc(errorsAttr.toString()) %></div>
                    <% } %>
                </div>
            <% } %>

            <!-- Danh sách trường -->
            <div class="card">
                <div class="card-body">
                    <div class="table-container">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Tên trường</th>
                                    <th>Kiểu dữ liệu</th>
                                    <th>Bắt buộc</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (customFields == null || customFields.isEmpty()) { %>
                                <tr>
                                    <td colspan="5" class="cf-empty">Chưa có trường tùy chỉnh nào. Hãy thêm trường đầu tiên ở form bên dưới.</td>
                                </tr>
                            <% } else {
                                   for (CustomFieldDefinition f : customFields) {
                                       boolean active = !"INACTIVE".equals(f.getStatus()); %>
                                <tr>
                                    <td><%= esc(f.getFieldLabel()) %></td>
                                    <td><%= esc(typeLabel(f.getFieldType())) %></td>
                                    <td><%= f.isRequired() ? "Có" : "Không" %></td>
                                    <td>
                                        <span class="badge <%= active ? "badge-success" : "badge-neutral" %>">
                                            <%= active ? "Đang dùng" : "Đã vô hiệu" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="cf-row-actions">
                                            <button type="button" class="btn btn-secondary btn-sm cf-edit"
                                                    data-id="<%= f.getFieldId() %>"
                                                    data-label="<%= esc(f.getFieldLabel()) %>"
                                                    data-type="<%= esc(f.getFieldType()) %>"
                                                    data-required="<%= f.isRequired() %>"
                                                    data-options="<%= esc(f.getOptions()) %>">Sửa</button>
                                            <% if (active) { %>
                                            <form method="POST" action="${pageContext.request.contextPath}/custom-fields" class="cf-deactivate-form">
                                                <input type="hidden" name="action" value="DEACTIVATE">
                                                <input type="hidden" name="customFieldId" value="<%= f.getFieldId() %>">
                                                <input type="hidden" name="entityType" value="CUSTOMER">
                                                <button type="submit" class="btn btn-secondary btn-sm">Vô hiệu hóa</button>
                                            </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <%     }
                               } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Form thêm / sửa -->
            <div class="card cf-section">
                <div class="card-body">
                    <h2 id="cfFormTitle" class="cf-form-title"><%= editing ? "Sửa trường tùy chỉnh" : "Thêm trường mới" %></h2>
                    <form id="cfForm" method="POST" action="${pageContext.request.contextPath}/custom-fields">
                        <input type="hidden" name="action" id="cfAction" value="<%= formAction %>">
                        <input type="hidden" name="customFieldId" id="cfId" value="<%= esc(formId) %>">
                        <input type="hidden" name="entityType" value="CUSTOMER">

                        <div class="form-group">
                            <label for="cfName">Tên trường (*)</label>
                            <input type="text" id="cfName" name="fieldName" class="form-control"
                                   required maxlength="100" value="<%= esc(formName) %>">
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
                                   placeholder="Ví dụ: Nhỏ, Vừa, Lớn" value="<%= esc(formOptions) %>">
                            <small class="cf-hint">Ngăn cách các lựa chọn bằng dấu phẩy.</small>
                        </div>
                        <div class="form-group">
                            <label class="cf-check">
                                <input type="checkbox" id="cfRequired" name="required" value="true" <%= formRequired ? "checked" : "" %>>
                                Bắt buộc nhập
                            </label>
                        </div>

                        <div class="cf-form-actions">
                            <button type="submit" class="btn btn-primary">Lưu trường</button>
                            <button type="button" id="cfCancel" class="btn btn-secondary"
                                    style="<%= editing ? "" : "display: none;" %>">Hủy sửa</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    (function () {
        var typeSel = document.getElementById('cfFieldType');
        var optGroup = document.getElementById('cfOptionsGroup');
        var optInput = document.getElementById('cfOptions');
        var cancelBtn = document.getElementById('cfCancel');

        function toggleOptions() {
            var isSelect = typeSel.value === 'SELECT';
            optGroup.style.display = isSelect ? 'block' : 'none';
            optInput.required = isSelect;
            if (!isSelect) optInput.value = '';
        }
        typeSel.addEventListener('change', toggleOptions);

        function setForm(action, id, label, type, required, options, title) {
            document.getElementById('cfAction').value = action;
            document.getElementById('cfId').value = id;
            document.getElementById('cfName').value = label;
            typeSel.value = type;
            document.getElementById('cfRequired').checked = required;
            toggleOptions();
            optInput.value = (type === 'SELECT') ? options : '';
            document.getElementById('cfFormTitle').textContent = title;
            cancelBtn.style.display = (action === 'UPDATE') ? 'inline-block' : 'none';
        }

        document.querySelectorAll('.cf-edit').forEach(function (btn) {
            btn.addEventListener('click', function () {
                setForm('UPDATE', btn.dataset.id, btn.dataset.label, btn.dataset.type,
                        btn.dataset.required === 'true', btn.dataset.options, 'Sửa trường tùy chỉnh');
                document.getElementById('cfForm').scrollIntoView({ behavior: 'smooth' });
            });
        });

        cancelBtn.addEventListener('click', function () {
            setForm('CREATE', '', '', 'TEXT', false, '', 'Thêm trường mới');
        });

        document.querySelectorAll('.cf-deactivate-form').forEach(function (f) {
            f.addEventListener('submit', function (e) {
                if (!confirm('Vô hiệu hóa trường này? Dữ liệu đã nhập vẫn được giữ lại.')) {
                    e.preventDefault();
                }
            });
        });

        toggleOptions();
    })();
</script>
</body>
</html>