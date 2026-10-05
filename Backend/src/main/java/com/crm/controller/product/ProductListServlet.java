package com.crm.controller.product;

import com.crm.model.Account;
import com.crm.model.Product;
import com.crm.service.ProductService;
import com.crm.service.PermissionService;
import com.crm.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/products")
public class ProductListServlet extends HttpServlet {

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
            } catch (Exception e) {
                // Ignore fallback
            }
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

        String keyword = req.getParameter("keyword");
        String productType = req.getParameter("productType");
        String status = req.getParameter("status");

        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            } catch (NumberFormatException ignored) {}
        }

        int pageSize = Constants.DEFAULT_PAGE_SIZE;
        String pageSizeParam = req.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                pageSize = Math.max(1, Integer.parseInt(pageSizeParam.trim()));
            } catch (NumberFormatException ignored) {}
        }

        PermissionService permissionService = new PermissionService();
        java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
        if (roleIds == null || roleIds.isEmpty()) {
            Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
            if (roleId == null && currentUser != null) {
                roleId = currentUser.getRoleId();
            }
            if (roleId != null) {
                roleIds = java.util.Collections.singletonList(roleId);
            }
        }
        boolean canViewCost = permissionService.canViewProductCost(roleIds);

        List<Product> products = productService.getProducts(keyword, productType, status, page, pageSize, currentUser);
        if (products != null && !canViewCost) {
            for (Product p : products) {
                p.setCostPrice(null);
            }
        }
        int totalItems = productService.getTotalCount(keyword, productType, status);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages < 1) totalPages = 1;

        req.setAttribute("products", products);
        req.setAttribute("canAccessCostPrice", canViewCost);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("keyword", keyword);
        req.setAttribute("productType", productType);
        req.setAttribute("status", status);

        if (isAjaxRequest(req)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"currentPage\":").append(page).append(",");
            json.append("\"totalPages\":").append(totalPages).append(",");
            json.append("\"totalItems\":").append(totalItems).append(",");
            json.append("\"products\":[");
            for (int i = 0; i < products.size(); i++) {
                Product p = products.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"productId\":").append(p.getProductId()).append(",");
                json.append("\"productCode\":\"").append(escapeJson(p.getProductCode())).append("\",");
                json.append("\"productName\":\"").append(escapeJson(p.getProductName())).append("\",");
                json.append("\"productType\":\"").append(escapeJson(p.getProductType())).append("\",");
                json.append("\"unit\":\"").append(escapeJson(p.getUnit())).append("\",");
                json.append("\"listPrice\":").append(p.getListPrice() != null ? p.getListPrice() : 0).append(",");
                json.append("\"floorPrice\":").append(p.getFloorPrice() != null ? p.getFloorPrice() : 0).append(",");
                if (canViewCost && p.getCostPrice() != null) {
                    json.append("\"costPrice\":").append(p.getCostPrice()).append(",");
                }
                json.append("\"status\":\"").append(escapeJson(p.getStatus())).append("\"");
                json.append("}");
            }
            json.append("]}");
            out.print(json.toString());
            out.flush();
        } else {
            req.getRequestDispatcher("/WEB-INF/views/products/list.jsp").forward(req, resp);
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
