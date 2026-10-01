package com.crm.controller.profile;

import com.crm.dao.AccountDAO;
import com.crm.model.Account;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(urlPatterns = { "/profile", "/profile/update" })
public class ProfileServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null
                || (session.getAttribute("currentUser") == null && session.getAttribute("userId") == null)) {
            sendJsonError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Account account = null;
        if (userId != null) {
            try {
                account = accountDAO.getAccountById(userId);
            } catch (Exception ignored) {
            }
        }

        if (account == null && session.getAttribute("currentUser") instanceof Account) {
            account = (Account) session.getAttribute("currentUser");
        }

        if (account == null) {
            sendJsonError(response, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy thông tin tài khoản.");
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"profile\":{");
        json.append("\"fullName\":").append(toJsonString(account.getFullName())).append(",");
        json.append("\"phone\":").append(toJsonString(account.getPhone())).append(",");
        json.append("\"email\":").append(toJsonString(account.getEmail())).append(",");
        json.append("\"department\":").append(toJsonString(account.getTeamName() != null ? account.getTeamName() : ""))
                .append(",");
        json.append("\"role\":").append(toJsonString(account.getRoleName() != null ? account.getRoleName() : ""))
                .append(",");
        json.append("\"avatarUrl\":").append(toJsonString(account.getAvatarUrl()));
        json.append("}");
        json.append("}");
        out.print(json.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null
                || (session.getAttribute("currentUser") == null && session.getAttribute("userId") == null)) {
            sendJsonError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null && session.getAttribute("currentUser") instanceof Account) {
            userId = ((Account) session.getAttribute("currentUser")).getAccountId();
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");

        if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Họ tên và số điện thoại không được để trống.");
            return;
        }

        try {
            Account account = accountDAO.getAccountById(userId);
            if (account != null) {
                account.setFullName(fullName.trim());
                account.setPhone(phone.trim());
                accountDAO.updateAccountInfo(userId, fullName.trim(), phone.trim());
                session.setAttribute("currentUser", account);
            }

            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"message\": \"Cập nhật hồ sơ thành công.\"}");
            out.flush();

        } catch (Exception e) {
            sendJsonError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi cập nhật hồ sơ.");
        }
    }

    private void sendJsonError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"status\":" + statusCode + ",\"message\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private String toJsonString(String val) {
        if (val == null)
            return "null";
        return "\"" + escapeJson(val) + "\"";
    }

    private String escapeJson(String text) {
        if (text == null)
            return "";
        return text.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
