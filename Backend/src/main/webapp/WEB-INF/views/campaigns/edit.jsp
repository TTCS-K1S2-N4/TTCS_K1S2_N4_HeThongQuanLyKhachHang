<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cập nhật Chiến dịch | CRM</title>
    <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
</head>
<body>
    <div class="app">
        <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
        <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
        <main class="main-content">
            <div class="content-container">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/campaigns">Chiến dịch</a>
                    <span>/</span>
                    <span class="breadcrumb-current">Cập nhật</span>
                </nav>

                <div class="page-header" style="margin-bottom: 24px;">
                    <h1 class="page-title">Cập nhật Chiến dịch: <c:out value="${campaign.name}" /></h1>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" style="margin-bottom: 16px; padding: 12px; background: #fee2e2; color: #dc2626; border-radius: 6px;">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <div class="card" style="max-width: 600px;">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/campaigns/edit" method="post">
                            <input type="hidden" name="id" value="${campaign.id}" />
                            
                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Tên chiến dịch <span style="color:red;">*</span></label>
                                <input type="text" name="name" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" value="<c:out value='${campaign.name}'/>">
                            </div>
                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Ngân sách</label>
                                <input type="number" step="1000" name="budget" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" value="<c:out value='${campaign.budget}'/>">
                            </div>
                            <div class="form-group" style="margin-bottom: 16px;">
                                <label style="display: block; margin-bottom: 6px; font-weight: 500;">Kênh <span style="color:red;">*</span></label>
                                <select name="channel" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;">
                                    <option value="">-- Chọn kênh --</option>
                                    <option value="Email" ${campaign.channel == 'Email' ? 'selected' : ''}>Email</option>
                                    <option value="Social" ${campaign.channel == 'Social' ? 'selected' : ''}>Social</option>
                                    <option value="Search" ${campaign.channel == 'Search' ? 'selected' : ''}>Search</option>
                                    <option value="Event" ${campaign.channel == 'Event' ? 'selected' : ''}>Event</option>
                                </select>
                            </div>
                            <div style="display: flex; gap: 16px; margin-bottom: 16px;">
                                <div class="form-group" style="flex: 1;">
                                    <label style="display: block; margin-bottom: 6px; font-weight: 500;">Ngày bắt đầu <span style="color:red;">*</span></label>
                                    <input type="date" name="startDate" class="form-control" required style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" value="<c:out value='${campaign.startDate}'/>">
                                </div>
                                <div class="form-group" style="flex: 1;">
                                    <label style="display: block; margin-bottom: 6px; font-weight: 500;">Ngày kết thúc</label>
                                    <input type="date" name="endDate" class="form-control" style="width: 100%; padding: 8px; border: 1px solid var(--color-border); border-radius: 6px;" value="<c:out value='${campaign.endDate}'/>">
                                </div>
                            </div>
                            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px;">
                                <a href="${pageContext.request.contextPath}/campaigns" class="btn btn-secondary" style="padding: 8px 16px; background: white; border: 1px solid var(--color-border);">Hủy</a>
                                <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Lưu thay đổi</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
