<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.model.AuditLog" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết nhật ký | CRM System</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/audit-log.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content audit-log-page">
        <%
            AuditLog auditLog = (AuditLog) request.getAttribute("auditLog");
            String errorMessage = (String) request.getAttribute("errorMessage");

            String performer = "";
            String timeStr = "";
            String oldValueStr = "-";
            String newValueStr = "-";

            if (auditLog != null) {
                performer = auditLog.getPerformedByName() != null ? auditLog.getPerformedByName() : (auditLog.getUserId() > 0 ? "Mã " + auditLog.getUserId() : "-");
                timeStr = auditLog.getFormattedCreatedAt();

                if (auditLog.getOldValue() != null && !auditLog.getOldValue().trim().isEmpty() && !"null".equalsIgnoreCase(auditLog.getOldValue().trim())) {
                    oldValueStr = auditLog.getOldValue();
                }
                if (auditLog.getNewValue() != null && !auditLog.getNewValue().trim().isEmpty() && !"null".equalsIgnoreCase(auditLog.getNewValue().trim())) {
                    newValueStr = auditLog.getNewValue();
                }
            }
        %>

        <div class="content-container">
            <!-- BREADCRUMB -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/audit/list">Nhật ký hệ thống</a>
                <span>/</span>
                <span class="breadcrumb-current">Chi tiết</span>
            </nav>

            <!-- PAGE HEADER -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Chi tiết nhật ký thay đổi</h1>
                    <p class="page-description">
                        <% if (auditLog != null) { %>
                            Bản ghi nhật ký #<%= auditLog.getLogId() %> – người thực hiện, thời điểm và giá trị trước/sau thay đổi.
                        <% } else { %>
                            Thông tin người thực hiện, thời điểm và giá trị trước/sau thay đổi.
                        <% } %>
                    </p>
                </div>
                <div class="page-actions">
                    <a id="audit-log-back" class="btn btn-secondary" href="${pageContext.request.contextPath}/audit/list">‹ Quay lại danh sách</a>
                </div>
            </div>

            <!-- GLOBAL MESSAGES HAVE BEEN MOVED TO TOAST -->

            <% if (auditLog == null) { %>
                <section class="card">
                    <div class="card-body">
                        <div class="empty-state">
                            <h2 class="empty-state-title">Không tìm thấy bản ghi nhật ký</h2>
                            <p class="empty-state-description">Bản ghi không tồn tại hoặc bạn không có quyền xem bản ghi này.</p>
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/audit/list">Về danh sách nhật ký</a>
                        </div>
                    </div>
                </section>
            <% } else { %>
                <section class="card" data-loaded="true">
                    <div class="card-header">
                        <div>
                            <h2 class="card-title">Thông tin thay đổi</h2>
                            <p class="card-description">Thời điểm hiển thị theo giờ Việt Nam (Asia/Ho_Chi_Minh).</p>
                        </div>
                    </div>

                    <div class="card-body">
                        <dl class="audit-log-meta">
                            <div class="audit-log-meta-item">
                                <dt class="audit-log-meta-label">Người thực hiện</dt>
                                <dd class="audit-log-meta-value"><%= performer %></dd>
                            </div>
                            <div class="audit-log-meta-item">
                                <dt class="audit-log-meta-label">Thời điểm</dt>
                                <dd class="audit-log-meta-value audit-log-time"><%= timeStr %></dd>
                            </div>
                            <div class="audit-log-meta-item">
                                <dt class="audit-log-meta-label">Loại đối tượng</dt>
                                <dd class="audit-log-meta-value"><%= auditLog.getTargetEntityName() != null ? auditLog.getTargetEntityName() : (auditLog.getEntityTypeDisplay() != null ? auditLog.getEntityTypeDisplay() : "-") %></dd>
                            </div>
                            <div class="audit-log-meta-item">
                                <dt class="audit-log-meta-label">Mã đối tượng</dt>
                                <dd class="audit-log-meta-value"><%= auditLog.getEntityId() %></dd>
                            </div>
                            <div class="audit-log-meta-item">
                                <dt class="audit-log-meta-label">Hành động</dt>
                                <dd class="audit-log-meta-value audit-log-action"><%= auditLog.getActionDisplay() != null ? auditLog.getActionDisplay() : "-" %></dd>
                            </div>
                        </dl>

                        <!-- COMPARE OLD/NEW -->
                        <div class="audit-log-compare">
                            <section class="audit-log-change audit-log-change-old">
                                <h3 class="audit-log-change-header">Giá trị trước thay đổi</h3>
                                <pre class="audit-log-value"><%= oldValueStr %></pre>
                            </section>

                            <section class="audit-log-change audit-log-change-new">
                                <h3 class="audit-log-change-header">Giá trị sau thay đổi</h3>
                                <pre class="audit-log-value"><%= newValueStr %></pre>
                            </section>
                        </div>
                    </div>
                </section>
            <% } %>
        </div>
    </main>
</div>
</body>
</html>
