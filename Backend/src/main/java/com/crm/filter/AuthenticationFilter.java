package com.crm.filter;

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
import java.util.logging.Logger;

/**
 * Servlet Filter kiểm tra trạng thái xác thực/đăng nhập của người dùng (AuthenticationFilter).
 * Bảo vệ các trang nội bộ, nếu chưa đăng nhập sẽ chuyển hướng người dùng về trang đăng nhập.
 */
public class AuthenticationFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthenticationFilter.class.getName());

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("AuthenticationFilter (S1-02) đã được khởi tạo.");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();
        if (path == null) path = "";

        // Cho phép truy cập không cần đăng nhập đối với trang đăng nhập, đăng xuất và tài nguyên công khai
        if (isPublicUri(path, httpRequest.getRequestURI())) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        String requestedSessionId = httpRequest.getRequestedSessionId();
        boolean isKicked = (requestedSessionId != null && com.crm.util.SessionListener.isKickedSession(requestedSessionId)) ||
                           (session != null && com.crm.util.SessionListener.isKickedSession(session.getId()));

        if (isKicked) {
            LOGGER.info("Từ chối truy cập do đăng nhập ở vị trí khác: " + path);
            if (session != null) {
                try { session.invalidate(); } catch (Exception ignored) {}
            }
            if (isAjaxRequest(httpRequest)) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json;charset=UTF-8");
                PrintWriter out = httpResponse.getWriter();
                out.print("{\"status\": 401, \"message\": \"Tài khoản của bạn đã được đăng nhập ở một vị trí/thiết bị khác.\"}");
                out.flush();
            } else {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/auth/login?concurrent=true");
            }
            return;
        }

        boolean isLoggedIn = (session != null && (session.getAttribute("currentUser") != null || session.getAttribute("userId") != null));

        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            LOGGER.info("Từ chối truy cập chưa xác thực tới: " + path);
            if (isAjaxRequest(httpRequest)) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json;charset=UTF-8");
                PrintWriter out = httpResponse.getWriter();
                out.print("{\"status\": 401, \"message\": \"Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.\"}");
                out.flush();
            } else {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/auth/login?expired=true");
            }
        }
    }

    private boolean isPublicUri(String path, String requestUri) {
        if (path.equals("/auth/login") || path.equals("/login") ||
            path.equals("/auth/logout") || path.equals("/logout") ||
            path.equals("/auth/forgot-password") || path.equals("/forgot-password") ||
            path.equals("/auth/activate") || path.equals("/activate")) {
            return true;
        }

        if (path.startsWith("/assets/") || path.startsWith("/css/") ||
            path.startsWith("/js/") || path.startsWith("/images/") || path.startsWith("/icons/")) {
            return true;
        }

        String lowerPath = path.toLowerCase();
        if (lowerPath.endsWith(".css") || lowerPath.endsWith(".js") ||
            lowerPath.endsWith(".png") || lowerPath.endsWith(".jpg") ||
            lowerPath.endsWith(".jpeg") || lowerPath.endsWith(".gif") ||
            lowerPath.endsWith(".ico") || lowerPath.endsWith(".svg") ||
            lowerPath.endsWith(".woff") || lowerPath.endsWith(".woff2") ||
            lowerPath.endsWith(".ttf")) {
            return true;
        }

        return false;
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    @Override
    public void destroy() {
        // Thu dọn tài nguyên Filter
    }
}
