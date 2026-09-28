<%@ page contentType=""text/html;charset=UTF-8"" language=""java"" %>
<%@ taglib prefix=""c"" uri=""jakarta.tags.core"" %>
<!DOCTYPE html>
<html lang=""vi"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>Danh sách Customers | CRM System</title>
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
                <div><h1 class=""page-title"">Danh sách Customers</h1></div>
            </div>
            <section class=""card"">
                <div class=""card-body"">
                    <form method=""get"" action=""${pageContext.request.contextPath}/customers"" class=""toolbar"">
                        <div class=""toolbar-group"">
                            <input type=""text"" name=""keyword"" class=""form-control"" value=""${c:out(keyword)}"" placeholder=""Tìm kiếm..."" />
                            <button type=""submit"" class=""btn btn-primary""><i class=""fa-solid fa-search""></i> Tìm kiếm</button>
                        </div>
                    </form>
                    <div class=""table-container"">
                        <table class=""table"">
                            <thead><tr><th>ID</th><th>Tên/Tiêu đề</th><th>Thao tác</th></tr></thead>
                            <tbody>
                            <c:forEach var=""item"" items=""${list}"">
                                <tr>
                                    <td>${item.id != null ? item.id : (item.customerId != null ? item.customerId : (item.opportunityId != null ? item.opportunityId : (item.activityId != null ? item.activityId : item.quoteId))))}</td>
                                    <td>${c:out(item.title != null ? item.title : (item.customerName != null ? item.customerName : item.quoteNumber))}</td>
                                    <td><a href=""${pageContext.request.contextPath}/customers/detail?id=${item.id != null ? item.id : (item.customerId != null ? item.customerId : (item.opportunityId != null ? item.opportunityId : (item.activityId != null ? item.activityId : item.quoteId))))}"" class=""btn btn-secondary btn-sm"">Chi tiết</a></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <c:if test=""${totalPages > 1}"">
                        <nav class=""pagination"">
                            <c:forEach begin=""1"" end=""${totalPages}"" var=""i"">
                                <a href=""?page=${i}&keyword=${c:out(keyword)}"" class=""pagination-item ${i == page ? 'active' : ''}"">${i}</a>
                            </c:forEach>
                        </nav>
                    </c:if>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
