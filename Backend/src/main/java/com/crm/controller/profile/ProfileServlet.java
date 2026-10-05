package com.crm.controller.profile;

import com.crm.dao.AccountDAO;
import com.crm.dto.ProfileUpdateRequest;
import com.crm.model.Account;
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
    private AccountDAO accountDAO;

    @Override
    public void init() throws ServletException {
        this.profileService = new ProfileService();
        this.accountDAO = new AccountDAO();
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
                    "Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.");
            return;
        }

        UserProfile profile = profileService.getProfile(userId);

        if (profile == null) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy thông tin tài khoản.");
            return;
        }

        String avatarUrl = null;
        Account account = accountDAO.getAccountById(userId);
        if (account != null) {
            avatarUrl = account.getAvatarUrl();
        }
        if (avatarUrl == null) {
            avatarUrl = profile.getAvatar();
        }

        writeProfileJson(response, profile, avatarUrl);
    }

    private void handleUpdateProfile(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        Integer userId = getUserIdFromSession(request);

        if (userId == null) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.");
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

        Account account = accountDAO.getAccountById(userId);
        if (account != null) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.setAttribute("currentUser", account);
            }
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

    private String toJsonString(String val) {
        if (val == null) {
            return "null";
        }
        return "\"" + escapeJson(val) + "\"";
    }

    private void writeProfileJson(
            HttpServletResponse response,
            UserProfile profile,
            String avatarUrl) throws IOException {

        prepareJsonResponse(response);

        StringBuilder json = new StringBuilder();

        json.append("{");
        json.append("\"profile\":{");

        json.append("\"fullName\":").append(toJsonString(profile.getFullName())).append(",");
        json.append("\"email\":").append(toJsonString(profile.getEmail())).append(",");
        json.append("\"phone\":").append(toJsonString(profile.getPhone())).append(",");
        json.append("\"emailSignature\":").append(toJsonString(profile.getEmailSignature())).append(",");
        json.append("\"department\":").append(toJsonString(profile.getTeam())).append(",");
        json.append("\"team\":").append(toJsonString(profile.getTeam())).append(",");
        json.append("\"avatarUrl\":").append(toJsonString(avatarUrl)).append(",");

        json.append("\"roles\":[");
        if (profile.getRoles() != null) {
            for (int i = 0; i < profile.getRoles().size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append(toJsonString(profile.getRoles().get(i)));
            }
        }
        json.append("],");

        String mainRole = (profile.getRoles() != null && !profile.getRoles().isEmpty())
                ? profile.getRoles().get(0)
                : "";
        json.append("\"role\":").append(toJsonString(mainRole));

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

        String json = "{\"success\":false,\"message\":\""
                + escapeJson(message)
                + "\",\"error\":\""
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

        Object currentUser = session.getAttribute("currentUser");

        if (currentUser instanceof Account) {
            return ((Account) currentUser).getAccountId();
        }

        return null;
    }
}
