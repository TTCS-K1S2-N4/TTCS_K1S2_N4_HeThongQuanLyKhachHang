package com.crm.controller.auth;

import com.crm.exception.AuthenticationException;
import com.crm.model.Account;
import com.crm.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/auth/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("currentUser") == null && session.getAttribute("userId") == null)) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer userId = null;

        if (session != null) {
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj instanceof Integer) {
                userId = (Integer) userIdObj;
            } else {
                Object currentUserObj = session.getAttribute("currentUser");
                if (currentUserObj instanceof Account) {
                    userId = ((Account) currentUserObj).getAccountId();
                }
            }
        }

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            authService.changePassword(userId, oldPassword, newPassword, confirmPassword);

            // Đổi mật khẩu thành công -> Hủy session hiện tại và bắt buộc người dùng đăng nhập lại bằng mật khẩu mới
            if (session != null) {
                try {
                    session.invalidate();
                } catch (IllegalStateException ignored) {}
            }

            response.sendRedirect(request.getContextPath() + "/auth/login?passwordChanged=true");

        } catch (AuthenticationException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Không thể xử lý yêu cầu đổi mật khẩu. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
        }
    }
}
