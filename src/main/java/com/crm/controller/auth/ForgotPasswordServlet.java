package com.crm.controller.auth;

import com.crm.exception.AuthenticationException;
import com.crm.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet xu ly tinh nang S1-03: Quen mat khau va Dat lai mat khau.
 */
@WebServlet(urlPatterns = {"/auth/forgot-password", "/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private AuthService authService;

    public ForgotPasswordServlet() {
        this.authService = new AuthService();
    }

    public ForgotPasswordServlet(AuthService authService) {
        this.authService = authService;
    }

    @Override
    public void init() {
        if (this.authService == null) {
            this.authService = new AuthService();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        if (token != null && !token.trim().isEmpty()) {
            boolean isValid = authService.validateResetToken(token.trim());
            if (isValid) {
                request.setAttribute("token", token.trim());
                request.setAttribute("isResetStep", true);
            } else {
                request.setAttribute("errorMessage", "Mã token khôi phục mật khẩu không hợp lệ hoặc đã hết hạn.");
                request.setAttribute("isResetStep", false);
            }
        } else {
            request.setAttribute("isResetStep", false);
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String token = request.getParameter("token");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if ("reset".equalsIgnoreCase(action) || (token != null && !token.trim().isEmpty() && newPassword != null)) {
            // Bước 2: Đặt lại mật khẩu mới
            try {
                authService.resetPasswordWithToken(token, newPassword, confirmPassword);
                request.setAttribute("successMessage", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.");
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            } catch (AuthenticationException e) {
                request.setAttribute("errorMessage", e.getMessage());
                request.setAttribute("token", token);
                request.setAttribute("isResetStep", true);
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            }
        } else {
            // Bước 1: Gửi yêu cầu lấy token đặt lại mật khẩu theo email
            try {
                String generatedToken = authService.generateResetToken(email);
                String resetUrl = request.getContextPath() + "/auth/forgot-password?token=" + generatedToken;

                request.setAttribute("successMessage", "Yêu cầu khôi phục mật khẩu đã được gửi thành công!");
                request.setAttribute("resetToken", generatedToken);
                request.setAttribute("resetUrl", resetUrl);
                request.setAttribute("email", email);
                request.setAttribute("isResetStep", false);

                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            } catch (AuthenticationException e) {
                request.setAttribute("errorMessage", e.getMessage());
                request.setAttribute("email", email);
                request.setAttribute("isResetStep", false);
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            }
        }
    }
}
