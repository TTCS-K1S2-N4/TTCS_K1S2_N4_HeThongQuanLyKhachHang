<%@ page contentType=""text/html;charset=UTF-8"" language=""java"" %>
<%@ taglib prefix=""c"" uri=""jakarta.tags.core"" %>
<!DOCTYPE html>
<html lang=""vi"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>Chi tiết Quotes | CRM System</title>
    <link rel=""stylesheet"" href=""${pageContext.request.contextPath}/assets/css/variables.css"">
    <link rel=""stylesheet"" href=""${pageContext.request.contextPath}/assets/css/reset.css"">
    <link rel=""stylesheet"" href=""${pageContext.request.contextPath}/assets/css/common.css"">
    <link rel=""stylesheet"" href=""${pageContext.request.contextPath}/assets/css/layout.css"">
    <link rel=""stylesheet"" href=""${pageContext.request.contextPath}/assets/css/responsive.css"">
    <link rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"">
</head>
<body>
<div class=""app"">
    <jsp:include page=""/WEB-INF/views/fragments/header.jsp"" />
    <jsp:include page=""/WEB-INF/views/fragments/sidebar.jsp"" />
    <main class=""main-content"">
        <div class=""content-container"">
            <div class=""page-header"">
                <div><h1 class=""page-title"">Chi tiết Quotes</h1></div>
            </div>
            <section class=""card"">
                <div class=""card-body"">
                    <c:if test=""${not empty errorMessage}"">
                        <div style=""color:red; margin-bottom: 1rem;"">${c:out(errorMessage)}</div>
                    </c:if>
                    <c:if test=""${not empty obj}"">
                        <p>ID: ${obj.id != null ? obj.id : (obj.customerId != null ? obj.customerId : (obj.opportunityId != null ? obj.opportunityId : (obj.activityId != null ? obj.activityId : obj.quoteId)))}</p>
                        <p>Tên/Tiêu đề: ${c:out(obj.title != null ? obj.title : (obj.customerName != null ? obj.customerName : obj.quoteNumber))}</p>
                    </c:if>
                    <a href=""${pageContext.request.contextPath}/quotes"" class=""btn btn-secondary"">Quay lại</a>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
