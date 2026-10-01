package com.crm.controller.organization;

import com.crm.model.Account;
import com.crm.model.Category;
import com.crm.service.CategoryService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/categories")
public class CategoryListServlet extends HttpServlet {

    private CategoryService categoryService = new CategoryService();

    public void setCategoryService(CategoryService categoryService) {
        if (categoryService != null) {
            this.categoryService = categoryService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account currentUser = session != null ? (Account) session.getAttribute("currentUser") : null;
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (currentUser == null && userId != null) {
            try {
                currentUser = new com.crm.dao.AccountDAO().getAccountById(userId);
            } catch (Exception ignored) {}
        }

        if (currentUser == null && userId == null) {
            if (isAjaxRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\": 401, \"message\": \"Bạn cần đăng nhập để thực hiện chức năng này.\"}");
                out.flush();
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }
        }

        String categoryType = req.getParameter("categoryType");
        List<Category> categories = categoryService.getCategories(categoryType);

        if (isAjaxRequest(req)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"success\": true,");
            json.append("\"categoryType\":").append(categoryType != null ? "\"" + escapeJson(categoryType) + "\"" : "null").append(",");
            json.append("\"categories\":[");
            for (int i = 0; i < categories.size(); i++) {
                Category c = categories.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"categoryId\":").append(c.getCategoryId()).append(",");
                json.append("\"categoryType\":\"").append(escapeJson(c.getCategoryType())).append("\",");
                json.append("\"categoryName\":\"").append(escapeJson(c.getCategoryName())).append("\",");
                json.append("\"displayOrder\":").append(c.getDisplayOrder()).append(",");
                json.append("\"status\":\"").append(escapeJson(c.getStatus())).append("\",");
                json.append("\"createdAt\":").append(c.getCreatedAt() != null ? "\"" + c.getCreatedAt().toString() + "\"" : "null").append(",");
                json.append("\"updatedAt\":").append(c.getUpdatedAt() != null ? "\"" + c.getUpdatedAt().toString() + "\"" : "null");
                json.append("}");
            }
            json.append("]}");
            out.print(json.toString());
            out.flush();
        } else {
            req.setAttribute("categories", categories);
            req.setAttribute("categoryType", categoryType);
            req.getRequestDispatcher("/WEB-INF/views/categories/list.jsp").forward(req, resp);
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
