<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <title>Gộp khách hàng | CRM</title>
                <jsp:include page="/WEB-INF/views/fragments/head.jsp" />

                <style>
                    .merge-container {
                        margin-top: 20px;
                    }

                    .merge-warning {
                        margin-bottom: 20px;
                    }

                    .merge-compare {
                        display: flex;
                        gap: 20px;
                        align-items: stretch;
                    }

                    .merge-column {
                        flex: 1;
                        min-width: 0;
                    }

                    .merge-arrow {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        min-width: 100px;
                        font-weight: 600;
                    }

                    .customer-card {
                        height: 100%;
                    }

                    .customer-card .card-body p {
                        margin-bottom: 8px;
                    }

                    .merge-actions {
                        margin-top: 20px;
                        display: flex;
                        gap: 10px;
                        flex-wrap: wrap;
                    }

                    @media (max-width: 768px) {
                        .merge-compare {
                            flex-direction: column;
                        }

                        .merge-arrow {
                            min-width: auto;
                            padding: 8px 0;
                        }
                    }
                </style>
            </head>

            <body>

                <div class="app">

                    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
                    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

                    <main class="main-content">

                        <div class="content-container merge-container">

                            <h1 class="page-title">So sánh và Gộp khách hàng</h1>

                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-danger">
                                    <c:out value="${errorMessage}" />
                                </div>
                            </c:if>

                            <c:if test="${not empty successMessage}">
                                <div class="alert alert-success">
                                    <c:out value="${successMessage}" />
                                </div>
                            </c:if>

                            <div class="alert alert-warning merge-warning">
                                <strong>Cảnh báo:</strong>
                                Hành động gộp khách hàng không thể hoàn tác.
                                Dữ liệu của khách hàng phụ sẽ được xử lý và chuyển sang
                                khách hàng chính theo nghiệp vụ của hệ thống.
                            </div>

                            <form method="post" action="${pageContext.request.contextPath}/customers/merge">

                                <div class="merge-compare">

                                    <!-- PRIMARY CUSTOMER -->
                                    <div class="merge-column">

                                        <div class="card customer-card">

                                            <div class="card-header">
                                                <strong>Khách hàng CHÍNH</strong>
                                                <span> — Được giữ lại</span>
                                            </div>

                                            <div class="card-body">

                                                <div class="form-group">

                                                    <label for="primaryId">
                                                        ID khách hàng chính
                                                    </label>

                                                    <input id="primaryId" type="number" name="primaryId"
                                                        class="form-control" value="<c:out value='${primaryId}' />"
                                                        required min="1">

                                                </div>

                                                <c:if test="${not empty primaryCustomer}">

                                                    <hr>

                                                    <p>
                                                        <strong>ID:</strong>
                                                        <c:out value="${primaryCustomer.customerId}" />
                                                    </p>

                                                    <p>
                                                        <strong>Tên:</strong>
                                                        <c:out value="${primaryCustomer.customerName}" />
                                                    </p>

                                                    <p>
                                                        <strong>Điện thoại:</strong>
                                                        <c:out value="${primaryCustomer.phone}" />
                                                    </p>

                                                    <p>
                                                        <strong>Email:</strong>
                                                        <c:out value="${primaryCustomer.email}" />
                                                    </p>

                                                    <p>
                                                        <strong>Mã số thuế:</strong>
                                                        <c:out value="${primaryCustomer.taxCode}" />
                                                    </p>

                                                    <p>
                                                        <strong>Website:</strong>
                                                        <c:out value="${primaryCustomer.website}" />
                                                    </p>

                                                    <c:if test="${not empty primaryCustomer.createdAt}">
                                                        <p>
                                                            <strong>Ngày tạo:</strong>
                                                            <fmt:formatDate value="${primaryCustomer.createdAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </p>
                                                    </c:if>

                                                </c:if>

                                            </div>

                                        </div>

                                    </div>

                                    <!-- DIRECTION -->
                                    <div class="merge-arrow">

                                        <span class="badge badge-primary">
                                            ← Gộp vào
                                        </span>

                                    </div>

                                    <!-- SECONDARY CUSTOMER -->
                                    <div class="merge-column">

                                        <div class="card customer-card">

                                            <div class="card-header">
                                                <strong>Khách hàng PHỤ</strong>
                                                <span> — Bị gộp</span>
                                            </div>

                                            <div class="card-body">

                                                <div class="form-group">

                                                    <label for="secondaryId">
                                                        ID khách hàng phụ
                                                    </label>

                                                    <input id="secondaryId" type="number" name="secondaryId"
                                                        class="form-control" value="<c:out value='${secondaryId}' />"
                                                        required min="1">

                                                </div>

                                                <c:if test="${not empty secondaryCustomer}">

                                                    <hr>

                                                    <p>
                                                        <strong>ID:</strong>
                                                        <c:out value="${secondaryCustomer.customerId}" />
                                                    </p>

                                                    <p>
                                                        <strong>Tên:</strong>
                                                        <c:out value="${secondaryCustomer.customerName}" />
                                                    </p>

                                                    <p>
                                                        <strong>Điện thoại:</strong>
                                                        <c:out value="${secondaryCustomer.phone}" />
                                                    </p>

                                                    <p>
                                                        <strong>Email:</strong>
                                                        <c:out value="${secondaryCustomer.email}" />
                                                    </p>

                                                    <p>
                                                        <strong>Mã số thuế:</strong>
                                                        <c:out value="${secondaryCustomer.taxCode}" />
                                                    </p>

                                                    <p>
                                                        <strong>Website:</strong>
                                                        <c:out value="${secondaryCustomer.website}" />
                                                    </p>

                                                    <c:if test="${not empty secondaryCustomer.createdAt}">
                                                        <p>
                                                            <strong>Ngày tạo:</strong>
                                                            <fmt:formatDate value="${secondaryCustomer.createdAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </p>
                                                    </c:if>

                                                </c:if>

                                            </div>

                                        </div>

                                    </div>

                                </div>

                                <div class="merge-actions">

                                    <button type="submit" class="btn btn-danger" onclick="return confirm(
                            'Bạn có chắc chắn muốn thực hiện gộp? Hành động này không thể hoàn tác!'
                        );">
                                        Xác nhận gộp
                                    </button>

                                    <a href="${pageContext.request.contextPath}/customers/duplicates"
                                        class="btn btn-secondary">
                                        Hủy
                                    </a>

                                </div>

                            </form>

                        </div>

                    </main>

                </div>

                <script>
                    (function () {
                        const primaryInput = document.getElementById('primaryId');
                        const secondaryInput = document.getElementById('secondaryId');

                        function reloadComparison() {
                            const primaryId = primaryInput.value.trim();
                            const secondaryId = secondaryInput.value.trim();

                            if (!primaryId || !secondaryId) {
                                return;
                            }

                            const contextPath = '${pageContext.request.contextPath}';

                            window.location.href =
                                contextPath +
                                '/customers/merge?primaryId=' +
                                encodeURIComponent(primaryId) +
                                '&secondaryId=' +
                                encodeURIComponent(secondaryId);
                        }

                        primaryInput.addEventListener('change', reloadComparison);
                        secondaryInput.addEventListener('change', reloadComparison);
                    })();
                </script>

            </body>

            </html>