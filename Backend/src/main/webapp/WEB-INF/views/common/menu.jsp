<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  S1-06: menu dùng chung, chỉ hiển thị các mục có trong "menuItems"
  (đã được MenuInterceptor lọc theo Role của currentUser trước khi vào JSP).
  Không có mục nào bị disable/xám đi — mục không có quyền sẽ KHÔNG xuất hiện.
  Tiêu chí "dùng được thuận tiện trên màn hình 360px" -> CSS responsive bên dưới,
  chuyển sang menu dạng hamburger/bottom khi width nhỏ.
--%>
<style>
    .app-sidebar { width: 260px; box-sizing: border-box; }
    .app-sidebar__user { padding: 12px; display: flex; flex-direction: column; gap: 2px; }
    .app-sidebar__user-name { font-weight: 600; }
    .app-sidebar__user-role, .app-sidebar__user-team { font-size: 12px; opacity: .75; }
    .app-sidebar__menu { list-style: none; margin: 0; padding: 0; }
    .app-sidebar__menu-item a {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 12px; text-decoration: none;
    }

    /* Màn hình nhỏ (tối thiểu 360px theo tiêu chí S1-06) -> sidebar thu gọn
       thành thanh ngang cuộn ngang, không che nội dung chính */
    @media (max-width: 480px) {
        .app-sidebar {
            width: 100%;
            position: static;
        }
        .app-sidebar__user {
            flex-direction: row;
            flex-wrap: wrap;
            align-items: baseline;
            gap: 6px;
            padding: 8px 12px;
        }
        .app-sidebar__menu {
            display: flex;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            white-space: nowrap;
        }
        .app-sidebar__menu-item a {
            padding: 8px 10px;
            font-size: 13px;
        }
    }
</style>
<div class="app-sidebar">
    <div class="app-sidebar__user">
        <span class="app-sidebar__user-name"><c:out value="${currentUser.fullName}" /></span>
        <span class="app-sidebar__user-role"><c:out value="${currentUser.role.name}" /></span>
        <c:if test="${not empty currentUser.team}">
            <span class="app-sidebar__user-team"><c:out value="${currentUser.team.name}" /></span>
        </c:if>
    </div>

    <ul class="app-sidebar__menu">
        <c:forEach var="item" items="${menuItems}">
            <li class="app-sidebar__menu-item">
                <a href="${pageContext.request.contextPath}${item.url}">
                    <c:if test="${not empty item.icon}">
                        <i class="icon icon-${item.icon}"></i>
                    </c:if>
                    <c:out value="${item.name}" />
                </a>
            </li>
        </c:forEach>
    </ul>
</div>
