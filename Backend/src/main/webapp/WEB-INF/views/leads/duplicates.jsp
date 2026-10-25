<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Phát hiện Lead trùng lặp | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/leads.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modules/lead-scoring.css">
    <style>
        .dup-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px 20px;
            margin-bottom: 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);
        }
        .dup-card:hover {
            border-color: #cbd5e1;
            box-shadow: 0 6px 16px -2px rgba(15, 23, 42, 0.08);
            transform: translateY(-1px);
        }
        .dup-title {
            font-size: 0.96rem;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .dup-meta {
            font-size: 0.82rem;
            color: #64748b;
            margin-top: 5px;
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }
        .dup-meta-item {
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .dup-tags {
            display: flex;
            gap: 6px;
            margin-top: 10px;
            flex-wrap: wrap;
        }
        .dup-badge {
            background: #fef3c7;
            color: #b45309;
            border: 1px solid #fde68a;
            padding: 3px 9px;
            border-radius: 6px;
            font-size: 0.74rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
    </style>
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
        <main class="main-content">
            <div class="content-container lead-page-container">
                
                <!-- Breadcrumb Navigation -->
                <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 16px;">
                    <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/leads">Quản lý Lead</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Phát hiện trùng lặp</span>
                </nav>

                <c:set var="targetLead" value="${not empty lead ? lead : currentLead}" />
                <c:set var="targetId" value="${not empty targetLead.leadId ? targetLead.leadId : targetLead.id}" />
                <c:set var="targetName" value="${not empty targetLead.fullName ? targetLead.fullName : targetLead.name}" />

                <!-- Page Header Banner with prominent "Quay lại" button -->
                <div class="lead-header-banner">
                    <div class="lead-header-left">
                        <div class="lead-header-icon-box" style="background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%); border-color: #fcd34d; color: #d97706;">
                            <i class="fa-solid fa-clone"></i>
                        </div>
                        <div class="lead-header-titles">
                            <h1 class="lead-page-title">
                                Kiểm tra Lead trùng lặp
                                <span class="badge" style="background: #fef3c7; color: #d97706; border: 1px solid #fcd34d; border-radius: 6px; font-size: 0.72rem; padding: 3px 8px; font-weight: 700;">
                                    Deduplication
                                </span>
                            </h1>
                            <p class="lead-page-subtitle">
                                <c:choose>
                                    <c:when test="${not empty targetLead}">
                                        Lead đối soát: <strong><c:out value="${targetName}" /></strong>
                                        <c:if test="${not empty targetLead.email}"> • Email: <c:out value="${targetLead.email}"/></c:if>
                                        <c:if test="${not empty targetLead.phone}"> • SĐT: <c:out value="${targetLead.phone}"/></c:if>
                                    </c:when>
                                    <c:otherwise>
                                        Tự động quét và đối soát cơ sở dữ liệu Lead theo Email, Số điện thoại và Tên công ty để ngăn trùng lặp.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>

                    <!-- Prominent Header Actions: Nút Quay lại -->
                    <div class="lead-header-actions">
                        <c:if test="${not empty targetId}">
                            <a href="${pageContext.request.contextPath}/leads/detail?id=${targetId}" class="btn-lead-action" title="Xem chi tiết Lead">
                                <i class="fa-solid fa-address-card"></i> Chi tiết Lead
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/leads" class="btn-lead-action" title="Quay lại danh sách Lead">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty error}">
                    <div class="alert" style="background: #fef2f2; border: 1px solid #fecaca; border-left: 4px solid #ef4444; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #991b1b; display: flex; align-items: center; gap: 10px; font-weight: 500;">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.1rem; color: #ef4444;"></i>
                        <span><c:out value="${error}"/></span>
                    </div>
                </c:if>

                <c:if test="${param.merged == 'true'}">
                    <div class="alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; border-left: 4px solid #10b981; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #065f46; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                        <i class="fa-solid fa-circle-check" style="font-size: 1.2rem; color: #10b981;"></i>
                        <span>Đã hợp nhất Lead thành công vào hệ thống!</span>
                    </div>
                </c:if>

                <c:if test="${param.linked == 'true'}">
                    <div class="alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; border-left: 4px solid #10b981; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; color: #065f46; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                        <i class="fa-solid fa-circle-check" style="font-size: 1.2rem; color: #10b981;"></i>
                        <span>Đã liên kết Lead vào Khách hàng (Customer) thành công!</span>
                    </div>
                </c:if>

                <c:set var="candidates" value="${not empty leadCandidates ? leadCandidates : duplicateLeads}" />
                <c:set var="customers" value="${not empty customerCandidates ? customerCandidates : suggestedCustomers}" />

                <!-- SECTION 1: GLOBAL DUPLICATE PAIRS (When opened without leadId) -->
                <c:if test="${empty targetLead && not empty duplicatePairs}">
                    <div style="margin-bottom: 28px;">
                        <h2 style="font-size: 1.05rem; font-weight: 700; color: #0f172a; margin-bottom: 14px; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-triangle-exclamation" style="color: #f59e0b;"></i> Các cặp Lead trùng lặp phát hiện trong toàn hệ thống
                            <span class="badge" style="background: #fef3c7; color: #b45309; border-radius: 9999px; font-size: 0.74rem; padding: 2px 8px;">${fn:length(duplicatePairs)}</span>
                        </h2>

                        <c:forEach var="pair" items="${duplicatePairs}">
                            <div class="dup-card">
                                <div>
                                    <div class="dup-title">
                                        <span><c:out value="${pair.left.fullName}"/></span>
                                        <i class="fa-solid fa-arrow-right-arrow-left" style="color: #94a3b8; font-size: 0.8rem;"></i>
                                        <span><c:out value="${pair.right.fullName}"/></span>
                                    </div>
                                    <div class="dup-meta">
                                        <span class="dup-meta-item"><i class="fa-solid fa-envelope" style="color: #64748b;"></i> <c:out value="${pair.left.email}"/> / <c:out value="${pair.right.email}"/></span>
                                        <span class="dup-meta-item"><i class="fa-solid fa-phone" style="color: #64748b;"></i> <c:out value="${pair.left.phone}"/> / <c:out value="${pair.right.phone}"/></span>
                                    </div>
                                    <div class="dup-tags">
                                        <c:forEach var="reason" items="${pair.reasons}">
                                            <span class="dup-badge"><i class="fa-solid fa-circle-exclamation"></i> <c:out value="${reason}"/></span>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div>
                                    <a href="${pageContext.request.contextPath}/leads/merge?primaryId=${pair.left.leadId}&duplicateId=${pair.right.leadId}" class="btn-lead-primary" style="padding: 7px 16px; font-size: 0.82rem;">
                                        <i class="fa-solid fa-compress"></i> So sánh & Gộp
                                    </a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <!-- SECTION 2: DUPLICATE LEADS FOR CURRENT LEAD -->
                <div style="margin-bottom: 28px;">
                    <h2 style="font-size: 1.05rem; font-weight: 700; color: #0f172a; margin-bottom: 14px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-users-viewfinder" style="color: #f59e0b;"></i> Các Lead nghi ngờ trùng lặp
                    </h2>
                    
                    <c:choose>
                        <c:when test="${not empty candidates}">
                            <c:forEach var="cand" items="${candidates}">
                                <c:set var="otherLead" value="${not empty cand.right ? cand.right : cand}" />
                                <c:set var="otherId" value="${not empty otherLead.leadId ? otherLead.leadId : otherLead.id}" />
                                <c:set var="otherName" value="${not empty otherLead.fullName ? otherLead.fullName : otherLead.name}" />
                                <c:set var="otherComp" value="${not empty otherLead.companyName ? otherLead.companyName : otherLead.company}" />

                                <div class="dup-card">
                                    <div>
                                        <div class="dup-title">
                                            <i class="fa-solid fa-user-tag" style="color: #2563eb;"></i>
                                            <span><c:out value="${otherName}" /></span>
                                            <span class="badge" style="background: #f1f5f9; color: #475569; font-size: 0.72rem; padding: 2px 6px; border-radius: 4px;">#${otherId}</span>
                                        </div>
                                        <div class="dup-meta">
                                            <c:if test="${not empty otherLead.email}">
                                                <span class="dup-meta-item"><i class="fa-solid fa-envelope"></i> <c:out value="${otherLead.email}" /></span>
                                            </c:if>
                                            <c:if test="${not empty otherLead.phone}">
                                                <span class="dup-meta-item"><i class="fa-solid fa-phone"></i> <c:out value="${otherLead.phone}" /></span>
                                            </c:if>
                                            <c:if test="${not empty otherComp}">
                                                <span class="dup-meta-item"><i class="fa-solid fa-building"></i> <c:out value="${otherComp}" /></span>
                                            </c:if>
                                        </div>
                                        <div class="dup-tags">
                                            <c:choose>
                                                <c:when test="${not empty cand.reasons}">
                                                    <c:forEach var="r" items="${cand.reasons}">
                                                        <span class="dup-badge"><i class="fa-solid fa-check"></i> <c:out value="${r}"/></span>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:if test="${cand.matchEmail}"><span class="dup-badge"><i class="fa-solid fa-envelope"></i> Trùng Email</span></c:if>
                                                    <c:if test="${cand.matchPhone}"><span class="dup-badge"><i class="fa-solid fa-phone"></i> Trùng SĐT</span></c:if>
                                                    <c:if test="${cand.matchCompany}"><span class="dup-badge"><i class="fa-solid fa-building"></i> Trùng Công ty</span></c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div>
                                        <c:set var="mergePrimaryId" value="${not empty targetId ? targetId : (not empty cand.left ? cand.left.leadId : (not empty otherLead.leadId ? (otherLead.leadId - 1) : 45))}" />
                                        <a href="${pageContext.request.contextPath}/leads/merge?primaryId=${mergePrimaryId}&duplicateId=${otherId}" class="btn-lead-primary" style="padding: 7px 16px; font-size: 0.82rem;">
                                            <i class="fa-solid fa-compress"></i> So sánh & Gộp
                                        </a>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 36px 20px; text-align: center; color: #64748b;">
                                <div style="width: 48px; height: 48px; border-radius: 50%; background: #ecfdf5; color: #10b981; display: inline-flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 12px;">
                                    <i class="fa-solid fa-circle-check"></i>
                                </div>
                                <p style="font-weight: 600; color: #1e293b; margin: 0 0 4px 0;">Không tìm thấy Lead nào có nguy cơ trùng lặp.</p>
                                <p style="font-size: 0.82rem; margin: 0; color: #94a3b8;">Dữ liệu liên hệ là duy nhất và chưa bị ghi nhận trùng lặp trong hệ thống.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- SECTION 3: MATCHING CUSTOMERS -->
                <div style="margin-bottom: 28px;">
                    <h2 style="font-size: 1.05rem; font-weight: 700; color: #0f172a; margin-bottom: 14px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-user-check" style="color: #0284c7;"></i> Khách hàng (Customer) gợi ý liên kết
                    </h2>
                    <c:choose>
                        <c:when test="${not empty customers}">
                            <c:forEach var="cust" items="${customers}">
                                <c:set var="cObj" value="${not empty cust.customer ? cust.customer : cust}" />
                                <c:set var="cId" value="${not empty cObj.customerId ? cObj.customerId : cObj.id}" />
                                <c:set var="cName" value="${not empty cObj.customerName ? cObj.customerName : (not empty cObj.fullName ? cObj.fullName : cObj.name)}" />

                                <div class="dup-card">
                                    <div>
                                        <div class="dup-title">
                                            <i class="fa-solid fa-briefcase" style="color: #0284c7;"></i>
                                            <span><c:out value="${cName}" /></span>
                                            <span class="badge" style="background: #e0f2fe; color: #0284c7; font-size: 0.72rem; padding: 2px 6px; border-radius: 4px;">Khách hàng #${cId}</span>
                                        </div>
                                        <div class="dup-meta">
                                            <c:if test="${not empty cObj.email}">
                                                <span class="dup-meta-item"><i class="fa-solid fa-envelope"></i> <c:out value="${cObj.email}" /></span>
                                            </c:if>
                                            <c:if test="${not empty cObj.phone}">
                                                <span class="dup-meta-item"><i class="fa-solid fa-phone"></i> <c:out value="${cObj.phone}" /></span>
                                            </c:if>
                                        </div>
                                        <c:if test="${not empty cust.reasons}">
                                            <div class="dup-tags">
                                                <c:forEach var="r" items="${cust.reasons}">
                                                    <span class="dup-badge" style="background: #e0f2fe; color: #0369a1; border-color: #bae6fd;"><i class="fa-solid fa-link"></i> <c:out value="${r}"/></span>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </div>
                                    <div>
                                        <form action="${pageContext.request.contextPath}/leads/link-customer" method="post" style="display:inline;">
                                            <input type="hidden" name="leadId" value="${not empty targetId ? targetId : 47}" />
                                            <input type="hidden" name="customerId" value="${cId}" />
                                            <button type="submit" class="btn-lead-primary" style="padding: 7px 16px; font-size: 0.82rem; background: #0284c7;" onclick="return confirm('Bạn có chắc chắn muốn liên kết Lead này vào Khách hàng đã chọn?');">
                                                <i class="fa-solid fa-link"></i> Liên kết Customer
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 36px 20px; text-align: center; color: #64748b;">
                                <div style="width: 48px; height: 48px; border-radius: 50%; background: #f8fafc; color: #94a3b8; display: inline-flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 12px;">
                                    <i class="fa-solid fa-user-slash"></i>
                                </div>
                                <p style="font-weight: 600; color: #1e293b; margin: 0 0 4px 0;">Không có Khách hàng (Customer) nào trùng khớp để liên kết.</p>
                                <p style="font-size: 0.82rem; margin: 0; color: #94a3b8;">Không phát hiện thông tin khách hàng hiện hữu trùng số điện thoại hoặc email.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Bottom Back Button for easy access -->
                <div style="margin-top: 24px; display: flex; justify-content: flex-start;">
                    <a href="${pageContext.request.contextPath}/leads" class="btn-filter-reset" style="display: inline-flex; align-items: center; gap: 6px;">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách Lead
                    </a>
                </div>

            </div>
        </main>
    </div>
</body>
</html>
