<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <title>Yêu cầu hỗ trợ | CRM</title>
            <jsp:include page="/WEB-INF/views/fragments/head.jsp" />
        </head>

        <body>
            <div class="app">
                <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
                <jsp:include page="/WEB-INF/views/fragments/sidebar.jsp" />
                <main class="main-content">
                    <div class="content-container">
                        <h1 class="page-title">Yêu cầu hỗ trợ <c:if test="${not empty customer}">-
                                <c:out value="${customer.customerName}" />
                            </c:if>
                        </h1>
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

                        <c:if test="${not empty customer}">
                            <div
                                style="margin-bottom: 30px; background: #fff; padding: 20px; border: 1px solid #ddd; border-radius: 4px;">
                                <h3>Tạo yêu cầu mới</h3>
                                <form
                                    action="${pageContext.request.contextPath}/customers/${customer.customerId}/support"
                                    method="post">
                                    <input type="hidden" name="customerId" value="${customer.customerId}">

                                    <div style="margin-bottom: 15px;">
                                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Tiêu
                                            đề:</label>
                                        <input type="text" name="title" required
                                            style="width: 100%; max-width: 500px; padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
                                    </div>

                                    <div style="margin-bottom: 15px;">
                                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Mô
                                            tả:</label>
                                        <textarea name="description" required rows="3"
                                            style="width: 100%; max-width: 500px; padding: 8px; border: 1px solid #ccc; border-radius: 4px;"></textarea>
                                    </div>

                                    <div style="margin-bottom: 15px;">
                                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Mức độ ưu
                                            tiên (Priority):</label>
                                        <select name="priority"
                                            style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; min-width: 200px;">
                                            <option value="LOW">Low</option>
                                            <option value="MEDIUM">Medium</option>
                                            <option value="HIGH">High</option>
                                            <option value="URGENT">Urgent</option>
                                        </select>
                                    </div>

                                    <div style="margin-bottom: 15px;">
                                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Người phụ
                                            trách (Assignee ID):</label>
                                        <input type="number" name="assigneeId"
                                            style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; min-width: 200px;">
                                    </div>

                                    <div style="margin-bottom: 15px;">
                                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Trạng
                                            thái:</label>
                                        <select name="status"
                                            style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; min-width: 200px;">
                                            <option value="OPEN">Open</option>
                                            <option value="IN_PROGRESS">In Progress</option>
                                            <option value="RESOLVED">Resolved</option>
                                            <option value="CLOSED">Closed</option>
                                        </select>
                                    </div>

                                    <button type="submit" class="btn btn-primary">Lưu yêu cầu</button>
                                </form>
                            </div>

                            <hr style="margin: 30px 0;">

                            <h3>Danh sách yêu cầu</h3>
                            <table class="table" style="width: 100%; text-align: left; border-collapse: collapse;">
                                <thead>
                                    <tr style="background: #f4f4f4; border-bottom: 2px solid #ddd;">
                                        <th style="padding: 10px;">ID</th>
                                        <th style="padding: 10px;">Tiêu đề</th>
                                        <th style="padding: 10px;">Mức độ ưu tiên</th>
                                        <th style="padding: 10px;">Trạng thái</th>
                                        <th style="padding: 10px;">Người phụ trách</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty supportRequests}">
                                            <c:forEach var="req" items="${supportRequests}">
                                                <tr style="border-bottom: 1px solid #eee;">
                                                    <td style="padding: 10px;">${req.id}</td>
                                                    <td style="padding: 10px;">
                                                        <c:out value="${req.title}" />
                                                    </td>
                                                    <td style="padding: 10px;">
                                                        <span
                                                            style="padding: 4px 8px; border-radius: 12px; background: #eee; font-size: 0.9em;">
                                                            <c:out value="${req.priority}" />
                                                        </span>
                                                    </td>
                                                    <td style="padding: 10px;">
                                                        <span
                                                            style="padding: 4px 8px; border-radius: 12px; background: #eee; font-size: 0.9em;">
                                                            <c:out value="${req.status}" />
                                                        </span>
                                                    </td>
                                                    <td style="padding: 10px;">${req.assigneeId}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="5" class="text-center" style="padding: 20px;">Chưa có yêu
                                                    cầu hỗ trợ nào.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>

                            <div style="margin-top: 20px;">
                                <a class="btn btn-secondary"
                                    href="${pageContext.request.contextPath}/customers/detail?id=${customer.customerId}">Quay
                                    lại chi tiết</a>
                            </div>
                        </c:if>
                        <c:if test="${empty customer}">
                            <div class="alert alert-warning">Không tìm thấy thông tin khách hàng.</div>
                        </c:if>
                    </div>
                </main>
            </div>
        </body>

        </html>