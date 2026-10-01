package com.crm.controller.avatar;

import com.crm.service.AvatarService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

@WebServlet(urlPatterns = {"/profile/avatar", "/avatar"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 2 * 1024 * 1024,   // 2MB max file size
    maxRequestSize = 5 * 1024 * 1024 // 5MB max request size
)
public class AvatarServlet extends HttpServlet {

    private AvatarService avatarService;

    @Override
    public void init() {
        this.avatarService = new AvatarService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("currentUser") == null && session.getAttribute("userId") == null)) {
            sendJsonError(response, HttpServletResponse.SC_UNAUTHORIZED, "Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null && session.getAttribute("currentUser") != null) {
            com.crm.model.Account acc = (com.crm.model.Account) session.getAttribute("currentUser");
            userId = acc.getAccountId();
        }

        try {
            Part part = null;
            try {
                part = request.getPart("avatar");
            } catch (Exception e) {
                sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "File không hợp lệ hoặc kích thước vượt quá 2MB.");
                return;
            }

            if (part == null || part.getSize() == 0) {
                sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn file avatar.");
                return;
            }

            if (part.getSize() > 2 * 1024 * 1024) {
                sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Dung lượng file vượt quá 2MB.");
                return;
            }

            String contentType = part.getContentType();
            String fileName = getSubmittedFileName(part);

            boolean isJpgOrPng = (contentType != null && (contentType.equalsIgnoreCase("image/jpeg") || contentType.equalsIgnoreCase("image/png") || contentType.equalsIgnoreCase("image/jpg")))
                    || (fileName != null && (fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg") || fileName.toLowerCase().endsWith(".png")));

            if (!isJpgOrPng) {
                sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Chỉ chấp nhận định dạng ảnh JPG hoặc PNG.");
                return;
            }

            String uploadRealPath = getServletContext().getRealPath("/uploads/avatars");
            String contextPath = request.getContextPath();

            Map<String, String> result = avatarService.uploadAvatar(userId != null ? userId : 0, part.getInputStream(), fileName, uploadRealPath, contextPath);

            String avatarUrl = result.get("avatarUrl");
            if (avatarUrl != null && userId != null && userId > 0) {
                new com.crm.dao.AccountDAO().updateAvatarUrl(userId, avatarUrl);
                if (session.getAttribute("currentUser") instanceof com.crm.model.Account) {
                    ((com.crm.model.Account) session.getAttribute("currentUser")).setAvatarUrl(avatarUrl);
                }
            }

            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"avatarUrl\":\"" + escapeJson(result.get("avatarUrl")) + "\",\"thumbnailUrl\":\"" + escapeJson(result.get("thumbnailUrl")) + "\"}");
            out.flush();

        } catch (IllegalArgumentException e) {
            sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            sendJsonError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi xử lý avatar.");
        }
    }

    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                return cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    private void sendJsonError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"status\":" + statusCode + ",\"message\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}