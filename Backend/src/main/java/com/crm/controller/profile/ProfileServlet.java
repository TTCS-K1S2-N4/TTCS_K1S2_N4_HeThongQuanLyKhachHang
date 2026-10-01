package com.crm.controller.profile;

import com.crm.dto.ProfileUpdateRequest;
import com.crm.model.UserProfile;
import com.crm.service.ProfileService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet({"/profile", "/profile/update"})
public class ProfileServlet extends HttpServlet {
    private ProfileService profileService;

    @Override
    public void init() throws ServletException {
        this.profileService = new ProfileService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/profile".equals(path)) {
            handleGetProfile(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/profile/update".equals(path)) {
            handleUpdateProfile(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleGetProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = getUserIdFromSession(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        UserProfile profile = profileService.getProfile(userId);
        if (profile == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ.");
            return;
        }

        // Return JSON response or forward to JSP based on request type
        // Assuming the contract expects JSON response for the data based on typical patterns, 
        // but if it's a frontend render, we put it in attribute. The instructions state:
        // Output: profile {...} and Frontend file: pages/profile/index.html
        
        request.setAttribute("profile", profile);
        request.getRequestDispatcher("/pages/profile/index.html").forward(request, response);
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = getUserIdFromSession(request);
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập.");
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String emailSignature = request.getParameter("emailSignature");

        ProfileUpdateRequest updateReq = new ProfileUpdateRequest(fullName, phone, emailSignature);
        String errorMessage = profileService.updateProfile(userId, updateReq);

        if (errorMessage != null) {
            request.setAttribute("errors", errorMessage);
        } else {
            request.setAttribute("successMessage", "Cập nhật hồ sơ thành công.");
        }
        
        UserProfile profile = profileService.getProfile(userId);
        request.setAttribute("profile", profile);
        request.getRequestDispatcher("/pages/profile/index.html").forward(request, response);
    }

    private Integer getUserIdFromSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj instanceof Integer) {
                return (Integer) userIdObj;
            }
            // Some systems store the whole Account object in currentUser
            Object currentUser = session.getAttribute("currentUser");
            if (currentUser != null) {
                try {
                    // Using reflection or assuming it's an Account model
                    java.lang.reflect.Method getIdMethod = currentUser.getClass().getMethod("getAccountId");
                    return (Integer) getIdMethod.invoke(currentUser);
                } catch (Exception e) {
                    try {
                        java.lang.reflect.Method getUserIdMethod = currentUser.getClass().getMethod("getUserId");
                        return (Integer) getUserIdMethod.invoke(currentUser);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
        }
        return null;
    }
}
