<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.crm.model.AuditLog" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết nhật ký kiểm toán #<c:out value="${auditLog != null ? auditLog.logId : ''}"/> | Frostline CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/audit-log.css">
    <style>
        :root {
            --audit-navy-900: #0f172a;
            --audit-primary: #1e3a8a;
            --audit-accent-blue: #2563eb;
            --audit-emerald: #10b981;
            --audit-rose: #f43f5e;
            --audit-border: #e2e8f0;
            --audit-radius-md: 12px;
            --audit-radius-lg: 16px;
        }

        .audit-detail-container {
            max-width: 1200px;
            margin: 0 auto;
            padding-bottom: 60px;
        }

        .audit-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 16px;
        }
        .audit-breadcrumb a {
            color: #64748b;
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .audit-breadcrumb a:hover {
            color: var(--audit-primary);
        }
        .audit-breadcrumb .sep {
            color: #cbd5e1;
            font-size: 11px;
        }
        .audit-breadcrumb .current {
            color: var(--audit-accent-blue);
            font-weight: 600;
        }

        .audit-hero-header {
            background: #ffffff;
            border: 1px solid var(--audit-border);
            border-radius: var(--audit-radius-lg);
            padding: 24px 28px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            overflow: hidden;
        }
        .audit-hero-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(180deg, #1e3a8a 0%, #2563eb 100%);
        }

        .audit-avatar-squircle {
            width: 58px;
            height: 58px;
            border-radius: 16px;
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 8px 18px rgba(30, 58, 138, 0.25);
            flex-shrink: 0;
        }

        .btn-audit-outline {
            background: #ffffff;
            color: #334155 !important;
            border: 1px solid var(--audit-border);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
            cursor: pointer;
        }
        .btn-audit-outline:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: var(--audit-primary) !important;
        }

        .audit-grid {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 24px;
        }
        @media (max-width: 900px) {
            .audit-grid { grid-template-columns: 1fr; }
        }

        .exec-card {
            background: #ffffff;
            border: 1px solid var(--audit-border);
            border-radius: var(--audit-radius-lg);
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
            margin-bottom: 24px;
            overflow: hidden;
        }
        .exec-card-header {
            padding: 18px 24px;
            background: #ffffff;
            border-bottom: 1px solid var(--audit-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .exec-card-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 15.5px;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }
        .exec-card-title i {
            color: var(--audit-accent-blue);
        }
        .exec-card-body {
            padding: 24px;
        }

        /* Metadata items grid */
        .meta-list-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
            margin-bottom: 24px;
        }
        @media (max-width: 600px) {
            .meta-list-grid { grid-template-columns: 1fr; }
        }

        .meta-box {
            background: #f8fafc;
            border: 1px solid var(--audit-border);
            border-radius: 10px;
            padding: 14px 16px;
        }
        .meta-box label {
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            display: block;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        .meta-box .val {
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
        }

        /* Diff Side-by-Side */
        .diff-compare-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        @media (max-width: 640px) {
            .diff-compare-container { grid-template-columns: 1fr; }
        }

        .diff-panel {
            border-radius: var(--audit-radius-md);
            overflow: hidden;
            border: 1.5px solid var(--audit-border);
        }
        .diff-panel.old {
            border-color: #fecdd3;
            background: #fff1f2;
        }
        .diff-panel.new {
            border-color: #a7f3d0;
            background: #ecfdf5;
        }

        .diff-header {
            padding: 10px 16px;
            font-size: 12.5px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .diff-panel.old .diff-header {
            background: #ffe4e6;
            color: #9f1239;
            border-bottom: 1px solid #fecdd3;
        }
        .diff-panel.new .diff-header {
            background: #d1fae5;
            color: #065f46;
            border-bottom: 1px solid #a7f3d0;
        }

        .diff-content {
            padding: 16px;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 13px;
            white-space: pre-wrap;
            word-break: break-all;
            line-height: 1.6;
            margin: 0;
            color: #1e293b;
        }

        .audit-stamp {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 12px;
            padding: 18px;
            font-size: 12.5px;
            color: #475569;
            line-height: 1.5;
        }
    </style>
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <%
            AuditLog auditLog = (AuditLog) request.getAttribute("auditLog");
            String performer = "";
            String timeStr = "";
            String oldValueStr = "-";
            String newValueStr = "-";

            if (auditLog != null) {
                performer = auditLog.getPerformedByName() != null ? auditLog.getPerformedByName() : (auditLog.getUserId() > 0 ? "Mã #" + auditLog.getUserId() : "Hệ thống");
                timeStr = auditLog.getFormattedCreatedAt();
                if (auditLog.getOldValue() != null && !auditLog.getOldValue().trim().isEmpty() && !"null".equalsIgnoreCase(auditLog.getOldValue().trim())) {
                    oldValueStr = auditLog.getOldValue();
                }
                if (auditLog.getNewValue() != null && !auditLog.getNewValue().trim().isEmpty() && !"null".equalsIgnoreCase(auditLog.getNewValue().trim())) {
                    newValueStr = auditLog.getNewValue();
                }
            }
        %>

        <div class="content-container audit-detail-container">
            
            <!-- Breadcrumbs -->
            <nav class="audit-breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <a href="${pageContext.request.contextPath}/audit/list">Nhật ký kiểm toán</a>
                <span class="sep"><i class="fa-solid fa-chevron-right"></i></span>
                <span class="current">Chi tiết #<%= auditLog != null ? auditLog.getLogId() : "" %></span>
            </nav>

            <!-- Hero Header -->
            <div class="audit-hero-header">
                <div style="display: flex; align-items: center; gap: 18px;">
                    <div class="audit-avatar-squircle">
                        <i class="fa-solid fa-fingerprint"></i>
                    </div>
                    <div>
                        <h1 style="font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 6px 0;">
                            Chi tiết bản ghi kiểm toán #<%= auditLog != null ? auditLog.getLogId() : "" %>
                        </h1>
                        <div style="font-size: 13px; color: #64748b;">
                            Thời điểm ghi nhận: <strong><%= timeStr %></strong> (Múi giờ Asia/Ho_Chi_Minh)
                        </div>
                    </div>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/audit/list" class="btn-audit-outline">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>

            <% if (auditLog == null) { %>
                <div class="exec-card">
                    <div class="exec-card-body" style="text-align: center; padding: 48px;">
                        <h3 style="color: #e11d48; margin-bottom: 8px;">Không tìm thấy bản ghi kiểm toán</h3>
                        <p style="color: #64748b;">Bản ghi không tồn tại hoặc đã bị xóa khỏi hệ thống.</p>
                        <a href="${pageContext.request.contextPath}/audit/list" class="btn-audit-outline" style="margin-top: 14px;">Quay lại danh sách</a>
                    </div>
                </div>
            <% } else { %>
                <div class="audit-grid">
                    
                    <!-- Left: Metadata and Side-by-Side Diff -->
                    <div>
                        <div class="exec-card">
                            <div class="exec-card-header">
                                <h3 class="exec-card-title">
                                    <i class="fa-solid fa-circle-info"></i> Thông tin sự kiện thay đổi
                                </h3>
                                <span style="font-size: 12px; font-weight: 600; color: #1e40af; background: #dbeafe; padding: 3px 8px; border-radius: 4px;">
                                    <%= auditLog.getAction() %>
                                </span>
                            </div>
                            <div class="exec-card-body">
                                
                                <div class="meta-list-grid">
                                    <div class="meta-box">
                                        <label>Người thực hiện</label>
                                        <div class="val" style="display: flex; align-items: center; gap: 8px;">
                                            <i class="fa-solid fa-user-check" style="color: #2563eb;"></i>
                                            <%= performer %> (ID: <%= auditLog.getUserId() %>)
                                        </div>
                                    </div>
                                    <div class="meta-box">
                                        <label>Thời điểm thực hiện</label>
                                        <div class="val">
                                            <i class="fa-regular fa-clock" style="color: #2563eb;"></i>
                                            <%= timeStr %>
                                        </div>
                                    </div>
                                    <div class="meta-box">
                                        <label>Loại đối tượng</label>
                                        <div class="val">
                                            <%= auditLog.getEntityTypeDisplay() %>
                                        </div>
                                    </div>
                                    <div class="meta-box">
                                        <label>Đối tượng tác động</label>
                                        <div class="val">
                                            <%= auditLog.getTargetEntityName() != null ? auditLog.getTargetEntityName() : ("Mã #" + auditLog.getEntityId()) %>
                                        </div>
                                    </div>
                                </div>

                                <% if (auditLog.getDetails() != null && !auditLog.getDetails().trim().isEmpty()) { %>
                                    <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 16px; margin-bottom: 24px;">
                                        <div style="font-size: 12px; font-weight: 600; color: #64748b; margin-bottom: 4px;">MÔ TẢ CHI TIẾT:</div>
                                        <div style="font-size: 13.5px; color: #1e293b; font-weight: 500;"><%= auditLog.getDetails() %></div>
                                    </div>
                                <% } %>

                                <!-- Side-by-Side Diff Section -->
                                <h4 style="font-size: 14.5px; font-weight: 700; color: #0f172a; margin: 0 0 12px 0;">
                                    So sánh đối soát giá trị trước &amp; sau
                                </h4>
                                <div class="diff-compare-container">
                                    <div class="diff-panel old">
                                        <div class="diff-header">
                                            <i class="fa-solid fa-circle-minus"></i> Giá trị trước khi thay đổi (Old Value)
                                        </div>
                                        <pre class="diff-content"><%= oldValueStr %></pre>
                                    </div>
                                    <div class="diff-panel new">
                                        <div class="diff-header">
                                            <i class="fa-solid fa-circle-plus"></i> Giá trị sau khi thay đổi (New Value)
                                        </div>
                                        <pre class="diff-content"><%= newValueStr %></pre>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>

                    <!-- Right Sidebar: Integrity Stamp & Quick Links -->
                    <div>
                        <div class="exec-card">
                            <div class="exec-card-header">
                                <h3 class="exec-card-title">
                                    <i class="fa-solid fa-shield-check"></i> Tính toàn vẹn dữ liệu
                                </h3>
                            </div>
                            <div class="exec-card-body">
                                <div class="audit-stamp">
                                    <div style="font-weight: 700; color: #0f172a; margin-bottom: 6px; display: flex; align-items: center; gap: 6px;">
                                        <i class="fa-solid fa-lock" style="color: #10b981;"></i> Bản ghi bất biến (Immutable)
                                    </div>
                                    Bản ghi này được hệ thống bảo vệ tự động bằng cơ chế <strong>ON DELETE RESTRICT</strong>. Không một tài khoản nào có quyền sửa đổi hay xóa nhật ký kiểm toán.
                                </div>

                                <div style="margin-top: 20px;">
                                    <a href="${pageContext.request.contextPath}/audit/list?userId=<%= auditLog.getUserId() %>" 
                                       class="btn-audit-outline" style="width: 100%; justify-content: center; box-sizing: border-box; margin-bottom: 10px;">
                                        <i class="fa-solid fa-filter"></i> Lọc tất cả hoạt động của nhân viên này
                                    </a>
                                    <a href="${pageContext.request.contextPath}/audit/list?entityType=<%= auditLog.getEntityType() %>" 
                                       class="btn-audit-outline" style="width: 100%; justify-content: center; box-sizing: border-box;">
                                        <i class="fa-solid fa-tags"></i> Lọc tất cả biến động cùng nhóm này
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            <% } %>

        </div>
    </main>
</div>
</body>
</html>
