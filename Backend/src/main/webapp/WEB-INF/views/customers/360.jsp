<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <title>Customer 360 | CRM System</title>
    
    <!-- Customer 360 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer-360.css">
</head>
<body>
<div class="app">
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />

    <main class="main-content">
        <div class="content-container">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Customer 360</h1>
                    <p class="page-description">Toàn cảnh thông tin và lịch sử tương tác khách hàng.</p>
                </div>
                <div class="page-actions">
                    <button class="btn btn-secondary" onclick="window.history.back()">Quay lại</button>
                </div>
            </div>

            <c:set var="contactList" value="${not empty contacts ? contacts : customer360.contacts}"/>
            <c:set var="openOppList" value="${not empty openOpportunities ? openOpportunities : customer360.openOpportunities}"/>
            <c:set var="closedOppList" value="${not empty closedOpportunities ? closedOpportunities : customer360.closedOpportunities}"/>
            <c:set var="signedVal" value="${signedValue != null ? signedValue : customer360.signedValue}"/>
            <c:set var="openVal" value="${openOpportunityValue != null ? openOpportunityValue : (totalOpenOpportunityValue != null ? totalOpenOpportunityValue : customer360.totalOpenOpportunityValue)}"/>
            <c:set var="attachmentList" value="${not empty attachments ? attachments : customer360.attachments}"/>
            <c:set var="subsidiaryList" value="${not empty subsidiaries ? subsidiaries : customer360.subsidiaries}"/>
            <c:set var="groupTotal" value="${groupContractTotal != null ? groupContractTotal : customer360.groupContractTotal}"/>
            <c:set var="riskObj" value="${customerRisk != null ? customerRisk : customer360.customerRisk}"/>
            <c:set var="srList" value="${not empty supportRequests ? supportRequests : customer360.supportRequests}"/>

            <c:if test="${riskObj != null && riskObj.riskFlag}">
                <div class="alert alert-danger" style="background: #fef2f2; border: 2px solid #ef4444; color: #991b1b; padding: 16px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; gap: 14px; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.1);">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 28px; color: #dc2626;"></i>
                    <div>
                        <h4 style="margin: 0 0 4px 0; font-size: 16px; font-weight: bold; color: #991b1b;">CẢNH BÁO: KHÁCH HÀNG CÓ NGUY CƠ RỜI BỎ (CHURN RISK DETECTED)</h4>
                        <p style="margin: 0; font-size: 14px;"><c:out value="${riskObj.riskReason}"/></p>
                    </div>
                </div>
            </c:if>

            <!-- Customer 360 Grid -->
            <div class="customer-360-container" id="customer360App">
                <div class="customer-360-main">
                    <!-- Customer Overview Section -->
                    <section class="card c360-section" id="customer-overview">
                        <div class="card-header">
                            <h2 class="card-title">Thông tin tổng quan</h2>
                        </div>
                        <div class="card-body">
                            <div class="c360-overview-grid">
                                <div class="c360-field">
                                    <span class="c360-label">Tên công ty / Khách hàng</span>
                                    <span class="c360-value">
                                        <c:out value="${customer != null ? (not empty customer.customerName ? customer.customerName : customer.customername) : 'Chưa có dữ liệu'}"/>
                                    </span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Mã khách hàng</span>
                                    <span class="c360-value">
                                        <c:out value="${customer != null ? (customer.customerId > 0 ? customer.customerId : customer.customerid) : '---'}"/>
                                    </span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Mã số thuế</span>
                                    <span class="c360-value"><c:out value="${customer != null && not empty customer.taxCode ? customer.taxCode : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Ngành nghề</span>
                                    <span class="c360-value"><c:out value="${customer != null && not empty customer.industry ? customer.industry : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Địa chỉ</span>
                                    <span class="c360-value"><c:out value="${customer != null && not empty customer.address ? customer.address : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Trạng thái</span>
                                    <span class="c360-value badge badge-primary"><c:out value="${customer != null && not empty customer.status ? customer.status : 'Mới'}"/></span>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Contacts Section -->
                    <section class="card c360-section" id="customer-contacts">
                        <div class="card-header">
                            <h2 class="card-title">Người liên hệ</h2>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty contactList}">
                                    <ul class="c360-list">
                                        <c:forEach var="contact" items="${contactList}">
                                            <li class="c360-list-item">
                                                <div class="c360-contact-info">
                                                    <strong>
                                                        <c:out value="${not empty contact.fullName ? contact.fullName : (not empty contact.contactName ? contact.contactName : contact.name)}"/>
                                                    </strong>
                                                    <span class="text-sm text-gray">
                                                        <c:out value="${not empty contact.title ? contact.title : (not empty contact.position ? contact.position : contact.role)}"/>
                                                    </span>
                                                </div>
                                                <div class="c360-contact-contact">
                                                    <span><i class="fa-solid fa-envelope"></i> <c:out value="${empty contact.email ? '—' : contact.email}"/></span>
                                                    <span><i class="fa-solid fa-phone"></i> <c:out value="${empty contact.phone ? '—' : contact.phone}"/></span>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state">
                                        <i class="fa-regular fa-address-book"></i>
                                        <p>Chưa có người liên hệ.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>

                    <!-- Opportunities Section -->
                    <section class="card c360-section" id="customer-opportunities">
                        <div class="card-header">
                            <h2 class="card-title">Cơ hội & Hợp đồng</h2>
                        </div>
                        <div class="card-body">
                            <div class="c360-tabs">
                                <button class="c360-tab-btn active" onclick="switchOppTab('open')">Đang mở</button>
                                <button class="c360-tab-btn" onclick="switchOppTab('closed')">Đã đóng</button>
                            </div>
                            
                            <div id="tab-opp-open" class="c360-tab-content active">
                                <c:choose>
                                    <c:when test="${not empty openOppList}">
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Tên cơ hội</th>
                                                    <th>Giá trị</th>
                                                    <th>Giai đoạn</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="opp" items="${openOppList}">
                                                    <tr>
                                                        <td><c:out value="${not empty opp.title ? opp.title : opp.name}"/></td>
                                                        <td><fmt:formatNumber value="${opp.amount != null ? opp.amount : opp.value}" type="currency" currencySymbol="VND"/></td>
                                                        <td><span class="badge badge-warning"><c:out value="${not empty opp.stageName ? opp.stageName : opp.stage}"/></span></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="c360-empty-state">
                                            <i class="fa-solid fa-seedling"></i>
                                            <p>Khách hàng chưa có cơ hội nào đang mở.</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div id="tab-opp-closed" class="c360-tab-content" style="display: none;">
                                <c:choose>
                                    <c:when test="${not empty closedOppList}">
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Tên cơ hội</th>
                                                    <th>Giá trị</th>
                                                    <th>Giai đoạn</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="opp" items="${closedOppList}">
                                                    <tr>
                                                        <td><c:out value="${not empty opp.title ? opp.title : opp.name}"/></td>
                                                        <td><fmt:formatNumber value="${opp.amount != null ? opp.amount : opp.value}" type="currency" currencySymbol="VND"/></td>
                                                        <td><span class="badge badge-success"><c:out value="${not empty opp.stageName ? opp.stageName : opp.stage}"/></span></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="c360-empty-state">
                                            <i class="fa-solid fa-box-archive"></i>
                                            <p>Khách hàng chưa có cơ hội nào đã đóng.</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </section>

                    <!-- Support Requests Section -->
                    <section class="card c360-section" id="customer-support-requests">
                        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                            <h2 class="card-title"><i class="fa-solid fa-headset" style="color: #0284c7; margin-right: 6px;"></i> Yêu cầu hỗ trợ sau bán</h2>
                            <a href="${pageContext.request.contextPath}/customers/support?customerId=${customer != null ? (customer.customerId > 0 ? customer.customerId : customer.customerid) : ''}" class="btn btn-sm btn-outline-primary" style="font-size: 0.8rem; padding: 4px 10px; border-radius: 4px; text-decoration: none;">Tạo yêu cầu mới</a>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty srList}">
                                    <table class="table" style="width: 100%;">
                                        <thead>
                                            <tr>
                                                <th style="width: 50px;">ID</th>
                                                <th>Tiêu đề</th>
                                                <th>Ưu tiên</th>
                                                <th>Trạng thái</th>
                                                <th>Người xử lý</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="sr" items="${srList}">
                                                <tr>
                                                    <td>#${sr.requestId}</td>
                                                    <td style="font-weight: 500;"><c:out value="${sr.title}"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.priority == 'URGENT'}"><span class="badge" style="background:#fee2e2; color:#dc2626; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Urgent</span></c:when>
                                                            <c:when test="${sr.priority == 'HIGH'}"><span class="badge" style="background:#fef3c7; color:#d97706; padding: 2px 8px; border-radius: 12px; font-size: 11px;">High</span></c:when>
                                                            <c:when test="${sr.priority == 'MEDIUM'}"><span class="badge" style="background:#e0f2fe; color:#0284c7; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Medium</span></c:when>
                                                            <c:otherwise><span class="badge" style="background:#f1f5f9; color:#475569; padding: 2px 8px; border-radius: 12px; font-size: 11px;"><c:out value="${sr.priority}"/></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.status == 'OPEN'}"><span class="badge" style="background:#e0f2fe; color:#0284c7; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Open</span></c:when>
                                                            <c:when test="${sr.status == 'IN_PROGRESS'}"><span class="badge" style="background:#fef08a; color:#ca8a04; padding: 2px 8px; border-radius: 12px; font-size: 11px;">In Progress</span></c:when>
                                                            <c:when test="${sr.status == 'RESOLVED'}"><span class="badge" style="background:#dcfce7; color:#16a34a; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Resolved</span></c:when>
                                                            <c:otherwise><span class="badge" style="background:#f3f4f6; color:#4b5563; padding: 2px 8px; border-radius: 12px; font-size: 11px;"><c:out value="${sr.status}"/></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><c:out value="${not empty sr.assigneeName ? sr.assigneeName : (sr.assigneeId != null ? sr.assigneeId : 'Chưa phân công')}"/></td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state">
                                        <i class="fa-solid fa-headset"></i>
                                        <p>Chưa có yêu cầu hỗ trợ nào cho khách hàng này.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </div>

                <div class="customer-360-sidebar">
                    <!-- Value Summary -->
                    <section class="card c360-section" id="customer-values">
                        <div class="card-header">
                            <h2 class="card-title">Giá trị khách hàng</h2>
                        </div>
                        <div class="card-body">
                            <div class="c360-value-summary">
                                <div class="c360-value-item">
                                    <span class="c360-value-label">Giá trị đã ký</span>
                                    <span class="c360-value-amount text-success">
                                        <fmt:formatNumber value="${signedVal != null ? signedVal : 0}" type="currency" currencySymbol="VND"/>
                                    </span>
                                </div>
                                <div class="c360-value-item">
                                    <span class="c360-value-label">Giá trị cơ hội (Open)</span>
                                    <span class="c360-value-amount text-warning">
                                        <fmt:formatNumber value="${openVal != null ? openVal : 0}" type="currency" currencySymbol="VND"/>
                                    </span>
                                </div>
                                <div class="c360-value-item" style="border-top: 2px dashed #4f46e5; margin-top: 10px; padding-top: 10px;">
                                    <span class="c360-value-label" style="font-weight: bold; color: #4f46e5;">Tổng giá trị hợp đồng tập đoàn</span>
                                    <span class="c360-value-amount" style="color: #4f46e5; font-weight: bold; font-size: 1.2rem;">
                                        <fmt:formatNumber value="${groupTotal != null ? groupTotal : (signedVal != null ? signedVal : 0)}" type="currency" currencySymbol="VND"/>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Subsidiaries Section -->
                    <section class="card c360-section" id="customer-subsidiaries">
                        <div class="card-header d-flex justify-content-between align-items-center" style="display: flex; justify-content: space-between; align-items: center;">
                            <h2 class="card-title"><i class="fa-solid fa-sitemap"></i> Công ty con (Subsidiaries)</h2>
                            <a href="${pageContext.request.contextPath}/customers/hierarchy?id=${customer != null ? (customer.customerId > 0 ? customer.customerId : customer.customerid) : ''}" class="btn btn-sm btn-outline-primary" style="font-size: 0.8rem; padding: 4px 8px;">Khai báo quan hệ</a>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty subsidiaryList}">
                                    <ul class="c360-list" style="list-style: none; padding-left: 0;">
                                        <c:forEach var="sub" items="${subsidiaryList}">
                                            <li class="c360-list-item" style="padding: 8px 0; border-bottom: 1px solid #f0f0f0;">
                                                <div class="c360-contact-info">
                                                    <strong>
                                                        <a href="${pageContext.request.contextPath}/customers/360?id=${sub.customerId}" style="color: #2563eb; text-decoration: none;">
                                                            <c:out value="${sub.customerName}"/>
                                                        </a>
                                                    </strong>
                                                    <div class="text-sm text-gray" style="font-size: 0.85rem; color: #666;">
                                                        ID: <c:out value="${sub.customerId}"/> | MST: <c:out value="${not empty sub.taxCode ? sub.taxCode : '---'}"/>
                                                    </div>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state">
                                        <i class="fa-solid fa-building-user"></i>
                                        <p>Chưa có công ty con nào được khai báo.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                    
                    <!-- Attachments Section -->
                    <section class="card c360-section" id="customer-attachments">
                        <div class="card-header">
                            <h2 class="card-title">Tài liệu đính kèm</h2>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty attachmentList}">
                                    <ul class="c360-attachment-list">
                                        <c:forEach var="att" items="${attachmentList}">
                                            <li>
                                                <i class="fa-solid fa-paperclip"></i>
                                                <a href="${pageContext.request.contextPath}${not empty att.filePath ? att.filePath : att.url}" target="_blank">
                                                    <c:out value="${not empty att.fileName ? att.fileName : att.name}"/>
                                                </a>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="c360-empty-state">
                                        <i class="fa-regular fa-file"></i>
                                        <p>Chưa có tệp đính kèm.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>

                    <!-- Timeline Section -->
                    <section class="card c360-section" id="customer-timeline">
                        <div class="card-header">
                            <h2 class="card-title">Dòng thời gian hoạt động</h2>
                        </div>
                        <div class="card-body">
                            <div id="c360-timeline-container">
                                <!-- JS will load timeline here -->
                                <div class="c360-loading-state">
                                    <i class="fa-solid fa-circle-notch fa-spin"></i>
                                    <p>Đang tải dòng thời gian...</p>
                                </div>
                            </div>
                            <div class="c360-timeline-actions" id="c360-timeline-actions" style="display: none;">
                                <button class="btn btn-sm btn-secondary" onclick="loadMoreTimeline()">Tải thêm</button>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
            
            <input type="hidden" id="c360-customer-id" value="${customer != null ? (customer.customerId > 0 ? customer.customerId : customer.customerid) : ''}">
            <input type="hidden" id="c360-context-path" value="${pageContext.request.contextPath}">
        </div>
    </main>
</div>

<!-- Customer 360 JS -->
<script src="${pageContext.request.contextPath}/assets/js/customer-360.js"></script>
</body>
</html>
