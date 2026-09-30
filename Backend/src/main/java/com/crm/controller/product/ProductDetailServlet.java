package com.crm.controller.product;

import com.crm.model.Account;
import com.crm.model.Product;
import com.crm.service.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/products/detail")
public class ProductDetailServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    public void setProductService(ProductService productService) {
        if (productService != null) {
            this.productService = productService;
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

        String productIdStr = req.getParameter("productId");
        int productId = -1;
        if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            try {
                productId = Integer.parseInt(productIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        if (productId <= 0) {
            handleNotFound(req, resp, "ID sản phẩm không hợp lệ.");
            return;
        }

        Product product = productService.getProductById(productId, currentUser);
        if (product == null) {
            handleNotFound(req, resp, "Không tìm thấy sản phẩm với ID: " + productId);
            return;
        }

        req.setAttribute("product", product);
        req.setAttribute("canAccessCostPrice", productService.isCostPriceAllowed(currentUser));
        req.setAttribute("canManageProducts", productService.canManageProducts(currentUser));

        if (isAjaxRequest(req)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"product\":{");
            json.append("\"productId\":").append(product.getProductId()).append(",");
            json.append("\"productCode\":\"").append(escapeJson(product.getProductCode())).append("\",");
            json.append("\"productName\":\"").append(escapeJson(product.getProductName())).append("\",");
            json.append("\"productType\":\"").append(escapeJson(product.getProductType())).append("\",");
            json.append("\"unit\":\"").append(escapeJson(product.getUnit())).append("\",");
            json.append("\"listPrice\":").append(product.getListPrice() != null ? product.getListPrice() : 0).append(",");
            json.append("\"floorPrice\":").append(product.getFloorPrice() != null ? product.getFloorPrice() : 0).append(",");
            if (product.getCostPrice() != null) {
                json.append("\"costPrice\":").append(product.getCostPrice()).append(",");
            }
            json.append("\"status\":\"").append(escapeJson(product.getStatus())).append("\"");
            json.append("}}");
            out.print(json.toString());
            out.flush();
        } else {
            req.getRequestDispatcher("/WEB-INF/views/products/detail.jsp").forward(req, resp);
        }
    }

    private void handleNotFound(HttpServletRequest req, HttpServletResponse resp, String message) throws ServletException, IOException {
        if (isAjaxRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"status\": 404, \"message\": \"" + escapeJson(message) + "\"}");
            out.flush();
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.setAttribute("errorMessage", message);
            req.getRequestDispatcher("/WEB-INF/views/errors/404.jsp").forward(req, resp);
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
