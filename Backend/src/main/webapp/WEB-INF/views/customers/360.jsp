<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                                    <span class="c360-value"><c:out value="${customer != null ? customer.name : 'Chưa có dữ liệu'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Mã khách hàng</span>
                                    <span class="c360-value"><c:out value="${customer != null ? customer.code : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Mã số thuế</span>
                                    <span class="c360-value"><c:out value="${customer != null ? customer.taxCode : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Ngành nghề</span>
                                    <span class="c360-value"><c:out value="${customer != null ? customer.industry : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Địa chỉ</span>
                                    <span class="c360-value"><c:out value="${customer != null ? customer.address : '---'}"/></span>
                                </div>
                                <div class="c360-field">
                                    <span class="c360-label">Trạng thái</span>
                                    <span class="c360-value badge badge-primary"><c:out value="${customer != null ? customer.status : 'Mới'}"/></span>
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
                                <c:when test="${not empty contacts}">
                                    <ul class="c360-list">
                                        <c:forEach var="contact" items="${contacts}">
                                            <li class="c360-list-item">
                                                <div class="c360-contact-info">
                                                    <strong><c:out value="${contact.name}"/></strong>
                                                    <span class="text-sm text-gray"><c:out value="${contact.role}"/></span>
                                                </div>
                                                <div class="c360-contact-contact">
                                                    <span><i class="fa-solid fa-envelope"></i> <c:out value="${contact.email}"/></span>
                                                    <span><i class="fa-solid fa-phone"></i> <c:out value="${contact.phone}"/></span>
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
                                    <c:when test="${not empty openOpportunities}">
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Tên cơ hội</th>
                                                    <th>Giá trị</th>
                                                    <th>Giai đoạn</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="opp" items="${openOpportunities}">
                                                    <tr>
                                                        <td><c:out value="${opp.name}"/></td>
                                                        <td><fmt:formatNumber value="${opp.value}" type="currency" currencySymbol="VND"/></td>
                                                        <td><span class="badge badge-warning"><c:out value="${opp.stage}"/></span></td>
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
                                    <c:when test="${not empty closedOpportunities}">
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Tên cơ hội</th>
                                                    <th>Giá trị</th>
                                                    <th>Giai đoạn</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="opp" items="${closedOpportunities}">
                                                    <tr>
                                                        <td><c:out value="${opp.name}"/></td>
                                                        <td><fmt:formatNumber value="${opp.value}" type="currency" currencySymbol="VND"/></td>
                                                        <td><span class="badge badge-success"><c:out value="${opp.stage}"/></span></td>
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
                                        <c:choose>
                                            <c:when test="${signedValue != null}">
                                                <fmt:formatNumber value="${signedValue}" type="currency" currencySymbol="VND"/>
                                            </c:when>
                                            <c:otherwise>0 VND</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="c360-value-item">
                                    <span class="c360-value-label">Giá trị cơ hội (Open)</span>
                                    <span class="c360-value-amount text-warning">
                                        <c:choose>
                                            <c:when test="${openOpportunityValue != null}">
                                                <fmt:formatNumber value="${openOpportunityValue}" type="currency" currencySymbol="VND"/>
                                            </c:when>
                                            <c:otherwise>0 VND</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </section>
                    
                    <!-- Attachments Section -->
                    <section class="card c360-section" id="customer-attachments">
                        <div class="card-header">
                            <h2 class="card-title">Tài liệu đính kèm</h2>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty attachments}">
                                    <ul class="c360-attachment-list">
                                        <c:forEach var="att" items="${attachments}">
                                            <li>
                                                <i class="fa-solid fa-paperclip"></i>
                                                <a href="${pageContext.request.contextPath}${att.url}" target="_blank"><c:out value="${att.name}"/></a>
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
            
            <input type="hidden" id="c360-customer-id" value="${customer != null ? customer.id : ''}">
            <input type="hidden" id="c360-context-path" value="${pageContext.request.contextPath}">
        </div>
    </main>
</div>

<!-- Customer 360 JS -->
<script src="${pageContext.request.contextPath}/assets/js/customer-360.js"></script>
</body>
</html>
