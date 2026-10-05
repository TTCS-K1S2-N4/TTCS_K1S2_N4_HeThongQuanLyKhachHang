package com.crm.filter;

import com.crm.exception.AuthorizationException;
import com.crm.service.PermissionService;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
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
    private final Map<String, String> protectedUrlMap = new LinkedHashMap<>();

    public void setPermissionService(PermissionService permissionService) {
        if (permissionService != null) {
            this.permissionService = permissionService;
        }
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        if (this.permissionService == null) {
            this.permissionService = new PermissionService();
        }

        initProtectedUrlMap();

        LOGGER.info("AuthorizationFilter (BE3) khởi tạo hoàn tất.");
    }

    public void initProtectedUrlMap() {
        protectedUrlMap.clear();

        // Khai báo các URL pattern bảo vệ trong module Khách hàng (bao gồm Sprint 03)
        protectedUrlMap.put("/customers/create", "ACCOUNT_CREATE");
        protectedUrlMap.put("/customers/edit", "ACCOUNT_EDIT");
        protectedUrlMap.put("/customers/delete", "ACCOUNT_DELETE");
        protectedUrlMap.put("/customers/export", "ACCOUNT_EXPORT");
        protectedUrlMap.put("/customers/detail", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers/hierarchy", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers/duplicates", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers/merge", "ACCOUNT_EDIT");
        protectedUrlMap.put("/customers/support", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers/risk", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers/care/config", "ACCOUNT_EDIT");
        protectedUrlMap.put("/customers/care", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers", "ACCOUNT_VIEW");

        // Alias URL ngắn gọn nếu có
        protectedUrlMap.put("/support", "ACCOUNT_VIEW");
        protectedUrlMap.put("/risk", "ACCOUNT_VIEW");
        protectedUrlMap.put("/care", "ACCOUNT_VIEW");

        // Quản lý người liên hệ (Contacts - Sprint 03 S3-02)
        protectedUrlMap.put("/contacts/create", "ACCOUNT_CREATE");
        protectedUrlMap.put("/contacts/edit", "ACCOUNT_EDIT");
        protectedUrlMap.put("/contacts/primary", "ACCOUNT_EDIT");
        protectedUrlMap.put("/contacts/transfer", "ACCOUNT_EDIT");
        protectedUrlMap.put("/contacts/detail", "ACCOUNT_VIEW");
        protectedUrlMap.put("/contacts/list", "ACCOUNT_VIEW");
        protectedUrlMap.put("/contacts", "ACCOUNT_VIEW");
        protectedUrlMap.put("/customers/contacts", "ACCOUNT_VIEW");

        protectedUrlMap.put("/accounts/create", "USER_CREATE");
        protectedUrlMap.put("/accounts/edit", "USER_EDIT");
        protectedUrlMap.put("/accounts/assign-role", "USER_EDIT");
        protectedUrlMap.put("/accounts/resend-email", "USER_EDIT");
        protectedUrlMap.put("/accounts/lock", "USER_DELETE");
        protectedUrlMap.put("/accounts/unlock", "USER_DELETE");
        protectedUrlMap.put("/accounts/transfer-data", "USER_DELETE");
        protectedUrlMap.put("/accounts/delete", "USER_DELETE");
        protectedUrlMap.put("/accounts/detail", "USER_VIEW");
        protectedUrlMap.put("/accounts/list", "USER_VIEW");
        protectedUrlMap.put("/accounts", "USER_VIEW");

        protectedUrlMap.put("/deals/create", "DEAL_CREATE");
        protectedUrlMap.put("/deals/edit", "DEAL_EDIT");
        protectedUrlMap.put("/deals/detail", "DEAL_VIEW");
        protectedUrlMap.put("/deals", "DEAL_VIEW");

        protectedUrlMap.put("/activities/detail", "ACTIVITY_VIEW");
        protectedUrlMap.put("/activities", "ACTIVITY_VIEW");

        protectedUrlMap.put("/quotes/detail", "QUOTE_VIEW");
        protectedUrlMap.put("/quotes", "QUOTE_VIEW");

        protectedUrlMap.put("/products/create", "PRODUCT_MANAGE");
        protectedUrlMap.put("/products/edit", "PRODUCT_MANAGE");
        protectedUrlMap.put("/products/status", "PRODUCT_MANAGE");
        protectedUrlMap.put("/products/detail", "PRODUCT_VIEW");
        protectedUrlMap.put("/products", "PRODUCT_VIEW");

        protectedUrlMap.put("/organization/teams/update", "ORG_MANAGE");
        protectedUrlMap.put("/organization/teams", "ORG_VIEW");

        protectedUrlMap.put("/categories/update", "CATEGORY_MANAGE");
        protectedUrlMap.put("/categories", "CATEGORY_VIEW");

        protectedUrlMap.put("/api/custom-fields", "CATEGORY_MANAGE");
        protectedUrlMap.put("/custom-fields", "CATEGORY_MANAGE");

        protectedUrlMap.put("/pipeline/stages", "CATEGORY_MANAGE");
        protectedUrlMap.put("/pipeline/win-loss-reasons", "CATEGORY_MANAGE");
        protectedUrlMap.put("/pipeline/competitors", "CATEGORY_MANAGE");

        protectedUrlMap.put("/audit-log/detail", "AUDIT_VIEW");
        protectedUrlMap.put("/audit/detail", "AUDIT_VIEW");
        protectedUrlMap.put("/audit-log", "AUDIT_VIEW");
        protectedUrlMap.put("/audit/list", "AUDIT_VIEW");

        protectedUrlMap.put("/import/excel/execute", "IMPORT_DATA");
        protectedUrlMap.put("/import/excel/preview", "IMPORT_DATA");
        protectedUrlMap.put("/import/excel/template", "IMPORT_DATA");
        protectedUrlMap.put("/import/excel", "IMPORT_DATA");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String rawPath = httpRequest.getServletPath();
        String normalizedPath = normalizePath(rawPath);

        // Tìm permission code bắt buộc cho URL hiện tại (đã được chuẩn hóa)
        String requiredPermission = matchRequiredPermission(normalizedPath);

        // Nếu URI không nằm trong danh sách kiểm tra bảo vệ
        if (requiredPermission == null) {
            // Cho phép đi tiếp nếu là endpoint công khai hoặc trang hồ sơ
            if (isPublicOrProfilePath(normalizedPath)) {
                chain.doFilter(request, response);
                return;
            }

            // Kiểm tra session người dùng
            HttpSession session = httpRequest.getSession(false);
            Integer userId = (session != null && session.getAttribute("userId") instanceof Integer)
                    ? (Integer) session.getAttribute("userId")
                    : null;

            if (userId == null) {
                LOGGER.warning("Từ chối truy cập đường dẫn " + rawPath + ": Chưa xác thực session");
                handleUnauthorized(httpRequest, httpResponse, "Bạn cần đăng nhập để thực hiện chức năng này.");
                return;
            }

            // Đã đăng nhập nhưng truy cập URL không xác định / chưa được phân quyền trong protectedUrlMap -> Fail Closed (403)
            LOGGER.warning("Từ chối truy cập đường dẫn chưa được phân quyền: " + rawPath + " (normalized: " + normalizedPath + ")");
            handleForbidden(httpRequest, httpResponse, "Đường dẫn không hợp lệ hoặc chưa được phân quyền.");
            return;
        }

        // Lấy thông tin session người dùng (đã được thiết lập từ AuthenticationFilter)
        HttpSession session = httpRequest.getSession(false);
        Integer roleId = null;
        Integer userId = null;
        java.util.List<Integer> roleIds = null;

        if (session != null) {
            Object roleIdObj = session.getAttribute("roleId");
            Object userIdObj = session.getAttribute("userId");
            if (roleIdObj instanceof Integer) {
                roleId = (Integer) roleIdObj;
            }
            if (userIdObj instanceof Integer) {
                userId = (Integer) userIdObj;
            }
            if (userId != null) {
                try {
                    com.crm.model.Account account = new com.crm.dao.AccountDAO().getAccountById(userId);
                    if (account != null) {
                        roleIds = account.getRoleIds();
                        session.setAttribute("currentUser", account);
                        session.setAttribute("roleIds", new java.util.ArrayList<>(roleIds));
                        session.setAttribute("roleId", roleIds.isEmpty() ? null : roleIds.get(0));
                        session.setAttribute("teamId", account.getTeamId());
                        session.setAttribute("teamName", account.getTeamName());
                    }
                } catch (Exception ignored) {
                }

                if (roleIds == null || roleIds.isEmpty()) {
                    Object sessionRoleIds = session.getAttribute("roleIds");
                    if (sessionRoleIds instanceof java.util.List<?>) {
                        @SuppressWarnings("unchecked")
                        java.util.List<Integer> castedList = (java.util.List<Integer>) sessionRoleIds;
                        roleIds = castedList;
                    } else if (roleId != null) {
                        roleIds = java.util.Collections.singletonList(roleId);
                    }
                }
            }
        }

        // Nếu chưa đăng nhập (thiếu userId trong session) => Chưa đăng nhập
        if (userId == null) {
            LOGGER.warning("Từ chối truy cập đường dẫn " + rawPath + ": Chưa xác thực session");
            handleUnauthorized(httpRequest, httpResponse, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        // Nếu đã đăng nhập nhưng chưa có vai trò (roleIds is null or empty) => Từ chối truy cập (403)
        if (roleIds == null || roleIds.isEmpty()) {
            LOGGER.warning("Từ chối truy cập đường dẫn " + rawPath + ": Tài khoản chưa được phân vai trò");
            handleForbidden(httpRequest, httpResponse, "Tài khoản của bạn chưa được phân vai trò trong hệ thống.");
            return;
        }

        if (permissionService == null) {
            permissionService = new PermissionService();
        }

        // Kiểm tra permission của roleIds
        boolean isAuthorized = permissionService.hasPermissionForRoles(roleIds, requiredPermission);

        if (!isAuthorized) {
            LOGGER.warning(String.format("Từ chối truy cập: userId=%d không có quyền %s cho path %s",
                    userId, requiredPermission, rawPath));
            handleForbidden(httpRequest, httpResponse, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        httpRequest.setAttribute("effectiveRoleIds", roleIds);

        // Cho phép đi tiếp tới Servlet/JSP tiếp theo
        chain.doFilter(request, response);
    }

    public String normalizePath(String path) {
        if (path == null) {
            return "";
        }
        // Loại bỏ Query Parameters (?key=val)
        int queryIndex = path.indexOf('?');
        if (queryIndex != -1) {
            path = path.substring(0, queryIndex);
        }
        // Loại bỏ Matrix Parameters (;jsessionid=...)
        int matrixIndex = path.indexOf(';');
        if (matrixIndex != -1) {
            path = path.substring(0, matrixIndex);
        }
        // Loại bỏ dấu / ở cuối ngoại trừ dấu / gốc
        while (path.endsWith("/") && path.length() > 1) {
            path = path.substring(0, path.length() - 1);
        }
        return path;
    }

    public String matchRequiredPermission(String path) {
        if (path == null) return null;
        String normalized = normalizePath(path);
        // 1. Khớp chính xác đường dẫn
        for (Map.Entry<String, String> entry : protectedUrlMap.entrySet()) {
            if (normalized.equalsIgnoreCase(entry.getKey())) {
                return entry.getValue();
            }
        }
        // 2. Khớp tiền tố (prefix) cho các URL con (ví dụ /customers/care/config hoặc /customers/support/...)
        String bestMatch = null;
        String matchedKey = "";
        for (Map.Entry<String, String> entry : protectedUrlMap.entrySet()) {
            String key = entry.getKey();
            if (normalized.toLowerCase().startsWith(key.toLowerCase() + "/") && key.length() > matchedKey.length()) {
                matchedKey = key;
                bestMatch = entry.getValue();
            }
        }
        return bestMatch;
    }

    private boolean isPublicOrProfilePath(String normalizedPath) {
        if (normalizedPath == null || normalizedPath.isEmpty()) return true;

        String lower = normalizedPath.toLowerCase();

        // Các URL xác thực công khai
        if (lower.startsWith("/auth/") || lower.equals("/login") || lower.equals("/logout") || lower.equals("/forgot-password") || lower.equals("/activate")) {
            return true;
        }

        // Tài nguyên tĩnh & trang lỗi
        if (lower.startsWith("/assets/") || lower.startsWith("/css/") || lower.startsWith("/js/") ||
            lower.startsWith("/images/") || lower.startsWith("/icons/") || lower.startsWith("/uploads/") ||
            lower.startsWith("/error/") || lower.startsWith("/errors/") || lower.equals("/index.jsp")) {
            return true;
        }

        // Trang hồ sơ cá nhân
        if (lower.startsWith("/profile") || lower.equals("/avatar")) {
            return true;
        }

        return false;
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
            response.sendRedirect(request.getContextPath() + "/auth/login");
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
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorMessage", message);
            request.setAttribute("exception", new AuthorizationException(message));
            // Forward sang trang 403.jsp của BE2
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp");
            if (dispatcher != null) {
                dispatcher.forward(request, response);
            }
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
