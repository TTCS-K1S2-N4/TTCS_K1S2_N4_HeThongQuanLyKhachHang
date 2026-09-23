package com.qlkh.interceptor;

import com.qlkh.entity.User;
import com.qlkh.service.MenuService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Map;
import java.util.Set;

/**
 * Kiểm tra user hiện tại có quyền truy cập URL đang gọi hay không, dựa trên
 * menu được phép của Role (S1-06 mô tả: "truy cập nhầm chỗ hoặc không đủ
 * quyền" -> cần thông báo rõ ràng thay vì trang trắng - liên quan S1-07,
 * BE3 chỉ cần đảm bảo dữ liệu quyền đúng để phần đó xử lý điều hướng).
 *
 * urlToMenuCode: ánh xạ tiền tố URL -> mã menu tương ứng, để biết cần
 * menu code nào mới được vào URL đó. Khai báo ở WebMvcConfig.
 */
public class PermissionInterceptor implements HandlerInterceptor {

    private final MenuService menuService;
    private final Map<String, String> urlPrefixToMenuCode;

    public PermissionInterceptor(MenuService menuService, Map<String, String> urlPrefixToMenuCode) {
        this.menuService = menuService;
        this.urlPrefixToMenuCode = urlPrefixToMenuCode;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        User currentUser = (User) request.getSession().getAttribute("CURRENT_USER");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        String uri = request.getRequestURI().substring(request.getContextPath().length());
        String requiredMenuCode = matchMenuCode(uri);

        if (requiredMenuCode == null) {
            return true; // URL không nằm trong danh sách cần kiểm soát (vd: /dashboard, /assets/**)
        }

        Set<String> allowed = menuService.getAllowedMenuCodes(currentUser);
        if (!allowed.contains(requiredMenuCode)) {
            // Không đủ quyền -> điều hướng sang trang báo lỗi dùng chung (S1-07)
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return false;
        }

        return true;
    }

    private String matchMenuCode(String uri) {
        for (Map.Entry<String, String> entry : urlPrefixToMenuCode.entrySet()) {
            if (uri.startsWith(entry.getKey())) {
                return entry.getValue();
            }
        }
        return null;
    }
}
