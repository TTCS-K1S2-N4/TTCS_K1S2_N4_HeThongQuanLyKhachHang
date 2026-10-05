<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Gộp khách hàng | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <style>
        .compare-container { display: flex; gap: 20px; margin-bottom: 20px; }
        .compare-col { flex: 1; border: 1px solid #ddd; padding: 15px; border-radius: 4px; background: #fff; }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp"/>
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp"/>
    <main class="main-content">
        <div class="content-container">
            <h1 class="page-title">So sánh và Gộp khách hàng</h1>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success"><c:out value="${successMessage}"/></div>
            </c:if>

            <c:choose>
                <c:when test="${not empty left and not empty right}">
                    <div class="alert alert-warning">
                        Cảnh báo: Hành động này không thể hoàn tác. Khách hàng bị gộp sẽ được chuyển sang trạng thái đã gộp và dữ liệu liên quan sẽ được chuyển sang khách hàng chính.
                    </div>
                    
                    <form action="${pageContext.request.contextPath}/customers/merge" method="post">
                        <div class="compare-container">
                            <div class="compare-col">
                                <h3>Khách hàng 1 (Left)</h3>
                                <p><strong>ID:</strong> ${left.customerId}</p>
                                <p><strong>Tên:</strong> <c:out value="${left.customerName}"/></p>
                                <p><strong>Điện thoại:</strong> <c:out value="${left.phone}"/></p>
                                <p><strong>Email:</strong> <c:out value="${left.email}"/></p>
                                <p><strong>Mã số thuế:</strong> <c:out value="${left.taxCode}"/></p>
                                <p><strong>Website:</strong> <c:out value="${left.website}"/></p>
                                <label style="display: block; margin-top: 10px; font-weight: bold;">
                                    <input type="radio" name="primaryCustomerId" value="${left.customerId}" required>
                                    Giữ làm khách hàng chính
                                </label>
                            </div>
                            <div class="compare-col">
                                <h3>Khách hàng 2 (Right)</h3>
                                <p><strong>ID:</strong> ${right.customerId}</p>
                                <p><strong>Tên:</strong> <c:out value="${right.customerName}"/></p>
                                <p><strong>Điện thoại:</strong> <c:out value="${right.phone}"/></p>
                                <p><strong>Email:</strong> <c:out value="${right.email}"/></p>
                                <p><strong>Mã số thuế:</strong> <c:out value="${right.taxCode}"/></p>
                                <p><strong>Website:</strong> <c:out value="${right.website}"/></p>
                                <label style="display: block; margin-top: 10px; font-weight: bold;">
                                    <input type="radio" name="primaryCustomerId" value="${right.customerId}" required>
                                    Giữ làm khách hàng chính
                                </label>
                            </div>
                        </div>
                        
                        <input type="hidden" name="duplicateCustomerId" id="duplicateCustomerId" value="">
                        
                        <button type="submit" class="btn btn-primary" onclick="setDuplicateId()">Xác nhận gộp</button>
                        <a class="btn btn-secondary" href="javascript:history.back()">Quay lại</a>
                    </form>
                    
                    <script>
                        function setDuplicateId() {
                            const primaryRadios = document.getElementsByName('primaryCustomerId');
                            let primaryId = null;
                            for (let i = 0; i < primaryRadios.length; i++) {
                                if (primaryRadios[i].checked) {
                                    primaryId = primaryRadios[i].value;
                                    break;
                                }
                            }
                            if (primaryId) {
                                const leftId = '${left.customerId}';
                                const rightId = '${right.customerId}';
                                document.getElementById('duplicateCustomerId').value = (primaryId === leftId) ? rightId : leftId;
                            }
                        }
                    </script>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-info">Dữ liệu so sánh không hợp lệ. Vui lòng thử lại.</div>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/customers">Quay lại danh sách</a>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
</body>
</html>
