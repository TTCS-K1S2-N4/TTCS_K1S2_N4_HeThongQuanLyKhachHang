package com.crm.controller.product;

import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Account;
import com.crm.service.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/products/delete")
public class ProductDeleteServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    public void setProductService(ProductService productService) {
        if (productService != null) {
            this.productService = productService;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account currentUser = getCurrentUser(req);

        if (currentUser == null) {
            handleUnauthorized(req, resp, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        if (!productService.canManageProducts(currentUser)) {
            handleForbidden(req, resp, "Bạn không có quyền xóa thông tin sản phẩm/dịch vụ.");
            return;
        }

        String productIdStr = req.getParameter("productId");
        int productId = -1;
        if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            try {
                productId = Integer.parseInt(productIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        if (productId <= 0) {
            handleBadRequest(req, resp, "ID sản phẩm không hợp lệ.");
            return;
        }

        try {
            boolean deleted = productService.deleteProduct(productId, currentUser);
            if (deleted) {
                if (isAjaxRequest(req)) {
                    resp.setContentType("application/json;charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print("{\"success\": true, \"message\": \"Xóa sản phẩm thành công.\"}");
                    out.flush();
                } else {
                    resp.sendRedirect(req.getContextPath() + "/products?success=delete");
                }
            } else {
                handleBadRequest(req, resp, "Không thể xóa sản phẩm khỏi CSDL.");
            }
        } catch (ValidationException e) {
            handleBadRequest(req, resp, e.getMessage());
        } catch (AuthorizationException e) {
            handleForbidden(req, resp, e.getMessage());
        } catch (Exception e) {
            handleBadRequest(req, resp, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    private Account getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Account user = (Account) session.getAttribute("currentUser");
        if (user == null && session.getAttribute("userId") != null) {
            try {
                user = new com.crm.dao.AccountDAO().getAccountById((Integer) session.getAttribute("userId"));
            } catch (Exception ignored) {}
        }
        return user;
    }

    private void handleBadRequest(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
        if (isAjaxRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"success\": false, \"message\": \"" + escapeJson(message) + "\"}");
            out.flush();
        } else {
            resp.sendRedirect(req.getContextPath() + "/products?error=" + java.net.URLEncoder.encode(message, "UTF-8"));
        }
    }

    private void handleUnauthorized(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
        if (isAjaxRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"status\": 401, \"message\": \"" + escapeJson(message) + "\"}");
            out.flush();
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    private void handleForbidden(HttpServletRequest req, HttpServletResponse resp, String message) throws ServletException, IOException {
        if (isAjaxRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"status\": 403, \"message\": \"" + escapeJson(message) + "\"}");
            out.flush();
        } else {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.setAttribute("errorMessage", message);
            req.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(req, resp);
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
                    .replace("\n", "\\n")
                    .replace("\r", "\\r");
    }
}
