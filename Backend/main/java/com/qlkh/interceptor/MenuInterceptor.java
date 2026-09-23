package com.qlkh.interceptor;

import com.qlkh.entity.User;
import com.qlkh.service.MenuService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

/**
 * Gắn "menuItems" (đã lọc theo quyền của user đang đăng nhập) vào ModelAndView
 * của MỌI request trả về JSP, để layout menu dùng chung không phải tự query
 * lại ở từng Controller (đúng mô tả "Trang báo lỗi dùng chung giao diện ứng
 * dụng" / menu dùng chung trong đề bài).
 *
 * Đăng ký trong WebMvcConfig (xem MenuWebConfig.java).
 */
public class MenuInterceptor implements HandlerInterceptor {

    private final MenuService menuService;

    public MenuInterceptor(MenuService menuService) {
        this.menuService = menuService;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                            Object handler, ModelAndView modelAndView) {
        if (modelAndView == null || modelAndView.getViewName() == null) {
            return; // response JSON/redirect thì bỏ qua
        }
        if (modelAndView.getViewName().startsWith("redirect:")) {
            return;
        }

        // TODO: thay bằng cách lấy user thật từ Spring Security context, ví dụ:
        // User currentUser = ((MyUserDetails) SecurityContextHolder.getContext()
        //         .getAuthentication().getPrincipal()).getUser();
        User currentUser = (User) request.getSession().getAttribute("CURRENT_USER");

        if (currentUser != null) {
            modelAndView.addObject("menuItems", menuService.getMenuForUser(currentUser));
            modelAndView.addObject("currentUser", currentUser);
        }
    }
}
