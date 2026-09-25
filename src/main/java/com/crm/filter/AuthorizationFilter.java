package com.crm.filter;

import com.crm.exception.AuthorizationException;
import com.crm.service.PermissionService;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Servlet Filter kiểm tra phân quyền người dùng (AuthorizationFilter).
 * Chạy sau AuthenticationFilter. Kiểm tra người dùng trong session có quyền truy cập URL request hay không.
 * Ném ngoại lệ / Forward trang 403 bằng tiếng Việt nếu từ chối truy cập.
 */
public class AuthorizationFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthorizationFilter.class.getName());

    private PermissionService permissionService;

    // Map ánh xạ các URI path với Permission Code tương ứng
    private final Map<String, String> protectedUrlMap = new HashMap<>();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.permissionService = new PermissionService();

        // Khai báo các URL pattern bảo vệ trong module BE3
        protectedUrlMap.put("/accounts", "ACCOUNT_VIEW");
        protectedUrlMap.put("/accounts/create", "ACCOUNT_CREATE");
        protectedUrlMap.put("/accounts/edit", "ACCOUNT_EDIT");
        protectedUrlMap.put("/accounts/delete", "ACCOUNT_DELETE");
        protectedUrlMap.put("/accounts/export", "ACCOUNT_EXPORT");

        protectedUrlMap.put("/deals", "DEAL_VIEW");
        protectedUrlMap.put("/deals/create", "DEAL_CREATE");
        protectedUrlMap.put("/deals/edit", "DEAL_EDIT");

        protectedUrlMap.put("/activities", "ACTIVITY_VIEW");
        protectedUrlMap.put("/quotes", "QUOTE_VIEW");

        LOGGER.info("AuthorizationFilter (BE3) khởi tạo hoàn tất.");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();

        // Tìm permission code bắt buộc cho URL hiện tại
        String requiredPermission = matchRequiredPermission(path);

        // Nếu URI không nằm trong danh sách kiểm tra bảo vệ, cho phép tiếp tục
        if (requiredPermission == null) {
            chain.doFilter(request, response);
            return;
        }

        // Lấy thông tin session người dùng (đã được thiết lập từ AuthenticationFilter)
        HttpSession session = httpRequest.getSession(false);
        Integer roleId = null;
        Integer userId = null;

        if (session != null) {
            Object roleIdObj = session.getAttribute("roleId");
            Object userIdObj = session.getAttribute("userId");
            if (roleIdObj instanceof Integer) {
                roleId = (Integer) roleIdObj;
            }
            if (userIdObj instanceof Integer) {
                userId = (Integer) userIdObj;
            }
        }

        // Nếu thiếu thông tin người dùng trong session => Chưa đăng nhập
        if (roleId == null || userId == null) {
            LOGGER.warning("Từ chối truy cập đường dẫn " + path + ": Chưa xác thực session");
            handleUnauthorized(httpRequest, httpResponse, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        // Kiểm tra permission của roleId
        boolean isAuthorized = permissionService.hasPermission(roleId, requiredPermission);

        if (!isAuthorized) {
            LOGGER.warning(String.format("Từ chối truy cập: userId=%d, roleId=%d không có quyền %s cho path %s",
                    userId, roleId, requiredPermission, path));
            handleForbidden(httpRequest, httpResponse, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        // Cho phép đi tiếp tới Servlet/JSP tiếp theo
        chain.doFilter(request, response);
    }

    private String matchRequiredPermission(String path) {
        if (path == null) return null;
        for (Map.Entry<String, String> entry : protectedUrlMap.entrySet()) {
            if (path.equalsIgnoreCase(entry.getKey()) || path.startsWith(entry.getKey() + "/")) {
                return entry.getValue();
            }
        }
        return null;
    }

    private void handleUnauthorized(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException, ServletException {
        if (isAjaxRequest(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"status\": 401, \"message\": \"" + message + "\"}");
            out.flush();
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    private void handleForbidden(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException, ServletException {
        if (isAjaxRequest(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"status\": 403, \"message\": \"" + message + "\"}");
            out.flush();
        } else {
            request.setAttribute("errorMessage", message);
            request.setAttribute("exception", new AuthorizationException(message));
            // Forward sang trang 403.jsp của BE2
            request.getRequestDispatcher("/WEB-INF/views/403.jsp").forward(request, response);
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    @Override
    public void destroy() {
        // Thu dọn tài nguyên nếu cần
    }
}
