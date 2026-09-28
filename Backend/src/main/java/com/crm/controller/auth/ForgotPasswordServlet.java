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
                if (generatedToken != null) {
                    String scheme = request.getScheme();
                    String serverName = request.getServerName();
                    int serverPort = request.getServerPort();
                    String contextPath = request.getContextPath();
                    String resetUrl = scheme + "://" + serverName;
                    if (("http".equals(scheme) && serverPort != 80) || ("https".equals(scheme) && serverPort != 443)) {
                        resetUrl += ":" + serverPort;
                    }
                    resetUrl += contextPath + "/auth/forgot-password?token=" + generatedToken;

                    try {
                        authService.sendResetEmail(email, resetUrl);
                    } catch (Exception e) {
                        System.err.println("Failed to send reset email to " + email + ": " + e.getMessage());
                    }
                }

                request.setAttribute("successMessage", "Nếu email tồn tại trong hệ thống, liên kết đặt lại mật khẩu đã được gửi.");
                request.setAttribute("email", email);
                request.setAttribute("isResetStep", false);

                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            } catch (AuthenticationException e) {
                if (e.getMessage().contains("Vui lòng")) {
                    request.setAttribute("errorMessage", e.getMessage());
                } else {
                    request.setAttribute("successMessage", "Nếu email tồn tại trong hệ thống, liên kết đặt lại mật khẩu đã được gửi.");
                }
                request.setAttribute("email", email);
                request.setAttribute("isResetStep", false);
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            }
        }
    }
}
