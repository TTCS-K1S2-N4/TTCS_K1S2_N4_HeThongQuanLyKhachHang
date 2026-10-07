<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý trường tùy chỉnh | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .custom-fields-container {
            margin-top: 20px;
        }
        .entity-selector {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
        }
        .entity-btn {
            padding: 8px 16px;
            border-radius: 6px;
            border: 1px solid var(--color-border);
            background: white;
            cursor: pointer;
            font-weight: 500;
        }
        .entity-btn.active {
            background: var(--color-primary);
            color: white;
            border-color: var(--color-primary);
        }
        .badge-req {
            background: #fee2e2;
            color: #dc2626;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-opt {
            background: #f3f4f6;
            color: #4b5563;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
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
                <span class="breadcrumb-current">Trường tùy chỉnh</span>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <div>
                    <h1 class="page-title">Cấu hình trường tùy chỉnh (Custom Fields)</h1>
                    <p class="page-subtitle" style="color: var(--color-text-secondary); margin-top: 4px;">Tạo và cấu hình các trường tùy chỉnh cho Khách hàng và Cơ hội kinh doanh.</p>
                </div>
                <div class="page-actions">
                    <button class="btn btn-primary" onclick="openCreateModal()"><i class="fas fa-plus"></i> Tạo trường mới</button>
                </div>
            </div>

            <div class="entity-selector">
                <button class="entity-btn active" id="btn-customer" onclick="switchEntity('CUSTOMER')"><i class="fas fa-user-tag"></i> Khách hàng (Customer)</button>
                <button class="entity-btn" id="btn-opportunity" onclick="switchEntity('OPPORTUNITY')"><i class="fas fa-handshake"></i> Cơ hội (Opportunity)</button>
            </div>

            <div class="card" style="box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <div class="card-header">
                    <h2 class="card-title" style="font-size: 16px;" id="table-title"><i class="fas fa-list-check"></i> Danh sách trường tùy chỉnh - Khách hàng</h2>
                </div>
                <div class="table-container table-responsive">
                    <table class="table" id="fields-table">
                        <thead style="background: #f8fafc;">
                            <tr>
                                <th style="width: 60px;">ID</th>
                                <th>Key</th>
                                <th>Tên hiển thị (Label)</th>
                                <th>Loại dữ liệu (Type)</th>
                                <th>Bắt buộc (Required)</th>
                                <th>Tùy chọn (Options)</th>
                                <th style="width: 90px; text-align: center;">Thứ tự</th>
                                <th style="width: 100px; text-align: center;">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody id="fields-list">
                            <tr><td colspan="8" style="text-align: center; padding: 24px;">Đang tải dữ liệu...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Modal Create Custom Field -->
<div id="createModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 2000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background: white; border-radius: 8px; width: 100%; max-width: 540px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="margin: 0; font-size: 18px;" id="modalTitle">Thêm trường tùy chỉnh mới</h3>
            <button onclick="closeModal()" style="border: none; background: none; font-size: 20px; cursor: pointer;">&times;</button>
        </div>
        <form id="fieldForm" onsubmit="saveCustomField(event)">
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Dành cho đối tượng</label>
                <select id="formEntityType" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                    <option value="CUSTOMER">Khách hàng (Customer)</option>
                    <option value="OPPORTUNITY">Cơ hội (Opportunity)</option>
                </select>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Mã trường (Field Key)</label>
                <input type="text" id="formFieldKey" class="form-control" placeholder="vd: interest_level" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên hiển thị (Label)</label>
                <input type="text" id="formFieldLabel" class="form-control" placeholder="vd: Mức độ quan tâm" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Loại dữ liệu (Field Type)</label>
                <select id="formFieldType" class="form-control" onchange="toggleOptionsVisibility()" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                    <option value="TEXT">Văn bản (Text)</option>
                    <option value="NUMBER">Số (Number)</option>
                    <option value="DATE">Ngày tháng (Date)</option>
                    <option value="SELECT">Danh sách lựa chọn (Select)</option>
                </select>
            </div>
            <div class="form-group" id="optionsGroup" style="margin-bottom: 16px; display: none;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Các tùy chọn (Options, phân cách bởi dấu phẩy)</label>
                <input type="text" id="formOptions" class="form-control" placeholder="Thấp, Trung bình, Cao" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                    <input type="checkbox" id="formIsRequired" value="true"> Bắt buộc nhập (Required)
                </label>
            </div>
            <div class="form-group" style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Thứ tự hiển thị (Display Order)</label>
                <input type="number" id="formDisplayOrder" class="form-control" value="0" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
            </div>
            <div style="display: flex; justify-content: flex-end; gap: 12px;">
                <button type="button" onclick="closeModal()" class="btn btn-secondary" style="padding: 8px 16px;">Hủy</button>
                <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Lưu trường</button>
            </div>
        </form>
    </div>
</div>

<script>
    let currentEntity = 'CUSTOMER';

    document.addEventListener("DOMContentLoaded", function() {
        loadFields('CUSTOMER');
    });

    function switchEntity(entity) {
        currentEntity = entity;
        document.getElementById('btn-customer').classList.toggle('active', entity === 'CUSTOMER');
        document.getElementById('btn-opportunity').classList.toggle('active', entity === 'OPPORTUNITY');
        document.getElementById('table-title').innerHTML = '<i class="fas fa-list-check"></i> Danh sách trường tùy chỉnh - ' + (entity === 'CUSTOMER' ? 'Khách hàng' : 'Cơ hội');
        loadFields(entity);
    }

    function loadFields(entity) {
        const tbody = document.getElementById('fields-list');
        tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 24px;">Đang tải dữ liệu...</td></tr>';
        
        fetch('${pageContext.request.contextPath}/api/custom-fields?entityType=' + entity)
            .then(res => res.json())
            .then(data => {
                if (!Array.isArray(data) || data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 24px; color: #6b7280;">Chưa có trường tùy chỉnh nào cho ' + (entity === 'CUSTOMER' ? 'Khách hàng' : 'Cơ hội') + '.</td></tr>';
                    return;
                }
                let html = '';
                data.forEach(item => {
                    html += `<tr>
                        <td>\${item.fieldId}</td>
                        <td><code>\${item.fieldKey}</code></td>
                        <td><strong>\${item.fieldLabel}</strong></td>
                        <td><span class="badge badge-opt">\${item.fieldType}</span></td>
                        <td>\${item.isRequired ? '<span class="badge-req">Bắt buộc</span>' : '<span class="badge-opt">Không</span>'}</td>
                        <td>\${item.options ? item.options : '-'}</td>
                        <td style="text-align: center;">\${item.displayOrder}</td>
                        <td style="text-align: center;">\${item.status === 'ACTIVE' ? '<span style="color: green; font-weight: 600;">ACTIVE</span>' : '<span style="color: gray;">INACTIVE</span>'}</td>
                    </tr>`;
                });
                tbody.innerHTML = html;
            })
            .catch(err => {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 24px; color: red;">Lỗi tải dữ liệu trường tùy chỉnh.</td></tr>';
            });
    }

    function toggleOptionsVisibility() {
        const type = document.getElementById('formFieldType').value;
        document.getElementById('optionsGroup').style.display = (type === 'SELECT') ? 'block' : 'none';
    }

    function openCreateModal() {
        document.getElementById('formEntityType').value = currentEntity;
        document.getElementById('formFieldKey').value = '';
        document.getElementById('formFieldLabel').value = '';
        document.getElementById('formFieldType').value = 'TEXT';
        document.getElementById('formOptions').value = '';
        document.getElementById('formIsRequired').checked = false;
        document.getElementById('formDisplayOrder').value = '0';
        toggleOptionsVisibility();
        document.getElementById('createModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('createModal').style.display = 'none';
    }

    function saveCustomField(e) {
        e.preventDefault();
        const entityType = document.getElementById('formEntityType').value;
        const fieldKey = document.getElementById('formFieldKey').value.trim();
        const fieldLabel = document.getElementById('formFieldLabel').value.trim();
        const fieldType = document.getElementById('formFieldType').value;
        const options = document.getElementById('formOptions').value.trim();
        const isRequired = document.getElementById('formIsRequired').checked;
        const displayOrder = document.getElementById('formDisplayOrder').value;

        const bodyParams = new URLSearchParams();
        bodyParams.append('entityType', entityType);
        bodyParams.append('fieldKey', fieldKey);
        bodyParams.append('fieldLabel', fieldLabel);
        bodyParams.append('fieldType', fieldType);
        bodyParams.append('options', options);
        bodyParams.append('isRequired', isRequired ? 'true' : 'false');
        bodyParams.append('displayOrder', displayOrder);

        fetch('${pageContext.request.contextPath}/api/custom-fields', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: bodyParams
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Lỗi: ' + data.error);
            } else {
                closeModal();
                loadFields(currentEntity);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ.'));
    }
</script>
</body>
</html>
