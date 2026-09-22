package com.crm.controller;

import com.crm.dao.UserDAO;
import com.crm.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users")
public class UserServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        if ("list".equals(action)) {
            String keyword = req.getParameter("keyword");
            String teamStr = req.getParameter("teamId");
            String statusStr = req.getParameter("status");
            String pageStr = req.getParameter("page");

            Integer teamId = (teamStr != null && !teamStr.isEmpty()) ? Integer.parseInt(teamStr) : null;
            Integer status = (statusStr != null && !statusStr.isEmpty()) ? Integer.parseInt(statusStr) : null;
            int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;

            List list = userDAO.getUsers(keyword, teamId, status, page);
            int totalRecords = userDAO.countUsers(keyword, teamId, status);
            int totalPages = (int) Math.ceil((double) totalRecords / UserDAO.PAGE_SIZE);

            req.setAttribute("userList", list);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.getRequestDispatcher("/views/user-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("create".equals(action)) {
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String fullName = req.getParameter("fullName");
            String phone = req.getParameter("phone");
            String teamStr = req.getParameter("teamId");
            Integer teamId = (teamStr != null && !teamStr.isEmpty()) ? Integer.parseInt(teamStr) : null;

            // Validate trùng Email
            if (userDAO.isEmailExists(email, 0)) {
                req.setAttribute("error", "Email '" + email + "' đã tồn tại trên hệ thống!");
                req.getRequestDispatcher("/views/user-create.jsp").forward(req, resp);
                return;
            }

            boolean ok = userDAO.createUser(email, password, fullName, phone, teamId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=create_success");
            } else {
                req.setAttribute("error", "Tạo tài khoản thất bại!");
                req.getRequestDispatcher("/views/user-create.jsp").forward(req, resp);
            }
        }
    }
}