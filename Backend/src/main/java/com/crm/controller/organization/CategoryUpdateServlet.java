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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/categories/update")
public class CategoryUpdateServlet extends HttpServlet {

    private CategoryService categoryService = new CategoryService();

    public void setCategoryService(CategoryService categoryService) {
        if (categoryService != null) {
            this.categoryService = categoryService;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        List<String> errors = new ArrayList<>();

        String actionStr = req.getParameter("action");
        Category.Action action = Category.Action.fromString(actionStr);
        if (action == null) {
            errors.add("Tham số 'action' không hợp lệ. Giá trị hợp lệ: CREATE, UPDATE, DEACTIVATE.");
        }

        String categoryIdStr = req.getParameter("categoryId");
        int categoryId = 0;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr.trim());
            } catch (NumberFormatException e) {
                errors.add("ID danh mục (categoryId) không đúng định dạng số.");
            }
        }

        String categoryType = req.getParameter("categoryType");
        String categoryName = req.getParameter("categoryName");

        String displayOrderStr = req.getParameter("displayOrder");
        int displayOrder = 0;
        if (displayOrderStr != null && !displayOrderStr.trim().isEmpty()) {
            try {
                displayOrder = Integer.parseInt(displayOrderStr.trim());
            } catch (NumberFormatException e) {
                errors.add("Thứ tự hiển thị (displayOrder) không đúng định dạng số.");
            }
        }

        String status = req.getParameter("status");

        Category category = new Category();
        category.setCategoryId(categoryId);
        category.setCategoryType(categoryType);
        category.setCategoryName(categoryName);
        category.setDisplayOrder(displayOrder);
        category.setStatus(status);

        if (!errors.isEmpty()) {
            handleErrorResponse(req, resp, errors, category);
            return;
        }

        boolean updated = categoryService.processCategoryUpdate(action, category, errors);

        if (updated) {
            if (isAjaxRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"success\": true, \"message\": \"Thao tác danh mục thành công.\", \"categoryId\": " + category.getCategoryId() + "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/categories?success=true");
            }
        } else {
            handleErrorResponse(req, resp, errors, category);
        }
    }

    private void handleErrorResponse(HttpServletRequest req, HttpServletResponse resp, List<String> errors, Category category)
            throws ServletException, IOException {
        if (isAjaxRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": false, \"errors\": [");
            for (int i = 0; i < errors.size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(errors.get(i))).append("\"");
            }
            json.append("]}");
            out.print(json.toString());
            out.flush();
        } else {
            req.setAttribute("errors", errors);
            req.setAttribute("category", category);
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
