<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Khách hàng cần chăm sóc định kỳ | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/customers.css">
    <style>
        .care-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #fff;
            padding: 16px 20px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }
        .config-box {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .config-box label {
            font-weight: 600;
            color: #334155;
            font-size: 0.95rem;
        }
        .config-box input {
            width: 80px;
            padding: 6px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 0.95rem;
            text-align: center;
        }
        .btn-contacted {
            background-color: #10b981;
            color: white;
            border: none;
            padding: 6px 14px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .btn-contacted:hover {
            background-color: #059669;
            box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
        }
        .badge-care {
            background-color: #fee2e2;
            color: #dc2626;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .contract-value {
            font-weight: 700;
            color: #1e293b;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <!-- Breadcrumbs -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/customers">Khách hàng</a>
                <span>/</span>
                <span class="breadcrumb-current">Chăm sóc định kỳ</span>
            </nav>

            <!-- Page Header -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Khách hàng cần chăm sóc định kỳ</h1>
                    <p class="page-subtitle" style="color: #64748b; font-size: 0.9rem; margin-top: 4px;">
                        Danh sách các khách hàng chưa có tương tác trong quá <strong>${inactiveDays}</strong> ngày (xắp xếp theo giá trị hợp đồng giảm dần).
                    </p>
                </div>
            </div>

            <!-- Toast / Alert message -->
            <div id="alert-toast" class="alert" style="display: none; margin-bottom: 15px;"></div>
            <c:if test="${not empty param.success}">
                <div class="alert alert-success" style="background: #dcfce7; color: #15803d; padding: 12px; border-radius: 6px; margin-bottom: 15px;">
                    Cập nhật cấu hình ngày định kỳ thành công!
                </div>
            </c:if>

            <!-- Care Config Toolbar -->
            <div class="care-toolbar">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-clock-rotate-left" style="color: #4f46e5; font-size: 1.2rem;"></i>
                    <span style="font-weight: 600; color: #1e293b;">Cấu hình thời hạn chăm sóc (N ngày):</span>
                </div>
                <form action="${pageContext.request.contextPath}/customers/care/config" method="post" class="config-box">
                    <label for="inactiveDaysInput">N =</label>
                    <input type="number" id="inactiveDaysInput" name="inactiveDays" value="${inactiveDays}" min="1" max="365" required>
                    <label for="inactiveDaysInput">ngày</label>
                    <button type="submit" class="btn btn-primary" style="padding: 6px 16px; font-size: 0.875rem;">Lưu cấu hình</button>
                </form>
            </div>

            <!-- Table Card -->
            <div class="card">
                <div class="card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="table" style="width: 100%; border-collapse: collapse;">
                            <thead>
                                <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; text-align: left;">
                                    <th style="padding: 12px 16px;">ID</th>
                                    <th style="padding: 12px 16px;">Tên khách hàng</th>
                                    <th style="padding: 12px 16px;">SĐT liên hệ</th>
                                    <th style="padding: 12px 16px;">Người sở hữu</th>
                                    <th style="padding: 12px 16px;">Chưa tương tác</th>
                                    <th style="padding: 12px 16px;">Giá trị hợp đồng</th>
                                    <th style="padding: 12px 16px;">Trạng thái</th>
                                    <th style="padding: 12px 16px; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="care-table-body">
                                <c:choose>
                                    <c:when test="${not empty careList}">
                                        <c:forEach var="item" items="${careList}">
                                            <tr id="customer-row-${item.customerId}" style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="padding: 12px 16px;">${item.customerId}</td>
                                                <td style="padding: 12px 16px;">
                                                    <a href="${pageContext.request.contextPath}/customers/360?id=${item.customerId}" style="font-weight: 600; color: #2563eb; text-decoration: none;">
                                                        <c:out value="${item.customerName}"/>
                                                    </a>
                                                </td>
                                                <td style="padding: 12px 16px;"><c:out value="${not empty item.phone ? item.phone : '---'}"/></td>
                                                <td style="padding: 12px 16px;"><c:out value="${not empty item.ownerName ? item.ownerName : '---'}"/></td>
                                                <td style="padding: 12px 16px; color: #dc2626; font-weight: 600;">
                                                    ${item.daysInactive} ngày
                                                </td>
                                                <td style="padding: 12px 16px;" class="contract-value">
                                                    <fmt:formatNumber value="${item.contractValue}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                </td>
                                                <td style="padding: 12px 16px;">
                                                    <span class="badge-care"><c:out value="${item.careStatus}"/></span>
                                                </td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <button type="button" class="btn-contacted" onclick="markContacted(${item.customerId}, '${item.customerName}')">
                                                        <i class="fa-solid fa-check-double"></i> Đã liên hệ
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8" style="text-align: center; padding: 40px; color: #64748b;">
                                                <i class="fa-solid fa-square-check" style="font-size: 2rem; color: #10b981; margin-bottom: 10px; display: block;"></i>
                                                Tất cả khách hàng đều đã được chăm sóc trong vòng ${inactiveDays} ngày qua!
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 16px 20px; border-top: 1px solid #e2e8f0;">
                            <span style="font-size: 0.875rem; color: #64748b;">Trang ${currentPage} / ${totalPages}</span>
                            <div style="display: flex; gap: 8px;">
                                <c:if test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/customers/care?inactiveDays=${inactiveDays}&page=${currentPage - 1}" class="btn btn-secondary" style="padding: 4px 12px; font-size: 0.85rem;">Trước</a>
                                </c:if>
                                <c:if test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/customers/care?inactiveDays=${inactiveDays}&page=${currentPage + 1}" class="btn btn-secondary" style="padding: 4px 12px; font-size: 0.85rem;">Sau</a>
                                </c:if>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
function markContacted(customerId, customerName) {
    if (!confirm("Xác nhận đánh dấu đã chăm sóc/liên hệ với " + customerName + "?")) {
        return;
    }
    
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "${pageContext.request.contextPath}/customers/" + customerId + "/care/mark-contacted", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    xhr.setRequestHeader("Accept", "application/json");

    xhr.onload = function() {
        if (xhr.status >= 200 && xhr.status < 300) {
            showToast("Đã ghi nhận chăm sóc khách hàng " + customerName + " thành công!", "success");
            var row = document.getElementById("customer-row-" + customerId);
            if (row) {
                row.style.transition = "all 0.4s ease";
                row.style.opacity = "0";
                row.style.transform = "translateX(20px)";
                setTimeout(function() {
                    row.remove();
                    var remainingRows = document.querySelectorAll("#care-table-body tr");
                    if (remainingRows.length === 0) {
                        window.location.reload();
                    }
                }, 400);
            }
        } else {
            showToast("Không thể ghi nhận: " + (xhr.responseText || "Lỗi máy chủ"), "danger");
        }
    };
    xhr.onerror = function() {
        showToast("Lỗi kết nối mạng!", "danger");
    };
    xhr.send("customerId=" + customerId + "&note=" + encodeURIComponent("Đã liên hệ chăm sóc định kỳ từ danh sách"));
}

function showToast(message, type) {
    var toast = document.getElementById("alert-toast");
    toast.className = "alert alert-" + type;
    toast.style.background = type === "success" ? "#dcfce7" : "#fee2e2";
    toast.style.color = type === "success" ? "#15803d" : "#dc2626";
    toast.style.padding = "12px";
    toast.style.borderRadius = "6px";
    toast.style.display = "block";
    toast.innerText = message;
    setTimeout(function() {
        toast.style.display = "none";
    }, 4000);
}
</script>
</body>
</html>
