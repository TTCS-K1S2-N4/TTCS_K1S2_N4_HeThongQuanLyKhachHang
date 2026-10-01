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

@WebServlet({ "/profile", "/profile/update" })
public class ProfileServlet extends HttpServlet {
    private ProfileService profileService;

    @Override
    public void init() throws ServletException {
        this.profileService = new ProfileService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/profile".equals(path)) {
            handleGetProfile(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/profile/update".equals(path)) {
            handleUpdateProfile(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleGetProfile(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        Integer userId = getUserIdFromSession(request);

        if (userId == null) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Vui lòng đăng nhập.");
            return;
        }

        UserProfile profile = profileService.getProfile(userId);

        if (profile == null) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy hồ sơ.");
            return;
        }

        writeProfileJson(response, profile);
    }

    private void handleUpdateProfile(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        Integer userId = getUserIdFromSession(request);

        if (userId == null) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Vui lòng đăng nhập.");
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String emailSignature = request.getParameter("emailSignature");

        ProfileUpdateRequest updateReq = new ProfileUpdateRequest(
                fullName,
                phone,
                emailSignature);

        String errorMessage = profileService.updateProfile(userId, updateReq);

        if (errorMessage != null) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    errorMessage);
            return;
        }

        writeUpdateSuccessJson(response);
    }

    private void prepareJsonResponse(HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private void writeProfileJson(
            HttpServletResponse response,
            UserProfile profile) throws IOException {

        prepareJsonResponse(response);

        StringBuilder json = new StringBuilder();

        json.append("{");
        json.append("\"profile\":{");

        json.append("\"fullName\":\"")
                .append(escapeJson(profile.getFullName()))
                .append("\",");

        json.append("\"email\":\"")
                .append(escapeJson(profile.getEmail()))
                .append("\",");

        json.append("\"phone\":\"")
                .append(escapeJson(profile.getPhone()))
                .append("\",");

        json.append("\"emailSignature\":\"")
                .append(escapeJson(profile.getEmailSignature()))
                .append("\",");

        json.append("\"team\":\"")
                .append(escapeJson(profile.getTeam()))
                .append("\",");

        json.append("\"roles\":[");

        if (profile.getRoles() != null) {
            for (int i = 0; i < profile.getRoles().size(); i++) {
                if (i > 0) {
                    json.append(",");
                }

                json.append("\"")
                        .append(escapeJson(profile.getRoles().get(i)))
                        .append("\"");
            }
        }

        json.append("]");
        json.append("}");
        json.append("}");

        response.getWriter().write(json.toString());
    }

    private void writeUpdateSuccessJson(
            HttpServletResponse response) throws IOException {

        prepareJsonResponse(response);

        response.getWriter().write(
                "{\"success\":true,\"message\":\"Cập nhật hồ sơ thành công.\"}");
    }

    private void writeErrorJson(
            HttpServletResponse response,
            int status,
            String message) throws IOException {

        prepareJsonResponse(response);
        response.setStatus(status);

        String json = "{\"success\":false,\"error\":\""
                + escapeJson(message)
                + "\"}";

        response.getWriter().write(json);
    }

    private Integer getUserIdFromSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        Object userId = session.getAttribute("userId");

        if (userId instanceof Integer) {
            return (Integer) userId;
        }

        return null;
    }
}
