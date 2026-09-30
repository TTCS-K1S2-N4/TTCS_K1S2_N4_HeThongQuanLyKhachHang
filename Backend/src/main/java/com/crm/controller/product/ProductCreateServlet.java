package com.crm.controller.product;

import com.crm.dto.ProductRequest;
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
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/products/create")
public class ProductCreateServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    public void setProductService(ProductService productService) {
        if (productService != null) {
            this.productService = productService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account currentUser = getCurrentUser(req);
        if (currentUser == null) {
            handleUnauthorized(req, resp, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        if (!productService.canManageProducts(currentUser)) {
            handleForbidden(req, resp, "Bạn không có quyền khai báo sản phẩm/dịch vụ mới.");
            return;
        }

        req.setAttribute("canAccessCostPrice", productService.isCostPriceAllowed(currentUser));
        req.getRequestDispatcher("/WEB-INF/views/products/create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account currentUser = getCurrentUser(req);
        if (currentUser == null) {
            handleUnauthorized(req, resp, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        if (!productService.canManageProducts(currentUser)) {
            handleForbidden(req, resp, "Bạn không có quyền khai báo sản phẩm/dịch vụ mới.");
            return;
        }

        String productCode = req.getParameter("productCode");
        String productName = req.getParameter("productName");
        String productType = req.getParameter("productType");
        String unit = req.getParameter("unit");
        String listPriceStr = req.getParameter("listPrice");
        String floorPriceStr = req.getParameter("floorPrice");
        String costPriceStr = req.getParameter("costPrice");
        String status = req.getParameter("status");

        List<String> errors = new ArrayList<>();
        BigDecimal listPrice = null;
        BigDecimal floorPrice = null;
        BigDecimal costPrice = null;

        if (listPriceStr != null && !listPriceStr.trim().isEmpty()) {
            try {
                listPrice = new BigDecimal(listPriceStr.trim());
            } catch (NumberFormatException e) {
                errors.add("Giá niêm yết không đúng định dạng số.");
            }
        }

        if (floorPriceStr != null && !floorPriceStr.trim().isEmpty()) {
            try {
                floorPrice = new BigDecimal(floorPriceStr.trim());
            } catch (NumberFormatException e) {
                errors.add("Giá sàn không đúng định dạng số.");
            }
        }

        if (costPriceStr != null && !costPriceStr.trim().isEmpty()) {
            try {
                costPrice = new BigDecimal(costPriceStr.trim());
            } catch (NumberFormatException e) {
                errors.add("Giá vốn không đúng định dạng số.");
            }
        }

        ProductRequest request = new ProductRequest();
        request.setProductCode(productCode);
        request.setProductName(productName);
        request.setProductType(productType);
        request.setUnit(unit);
        request.setListPrice(listPrice);
        request.setFloorPrice(floorPrice);
        request.setCostPrice(costPrice);
        request.setStatus(status);

        if (!errors.isEmpty()) {
            handleErrorResponse(req, resp, errors, request, currentUser);
            return;
        }

        try {
            boolean created = productService.createProduct(request, currentUser);
            if (created) {
                if (isAjaxRequest(req)) {
                    resp.setContentType("application/json;charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print("{\"success\": true, \"message\": \"Thêm sản phẩm thành công.\"}");
                    out.flush();
                } else {
                    resp.sendRedirect(req.getContextPath() + "/products?success=create");
                }
            } else {
                errors.add("Không thể lưu sản phẩm vào CSDL.");
                handleErrorResponse(req, resp, errors, request, currentUser);
            }
        } catch (ValidationException e) {
            errors.add(e.getMessage());
            handleErrorResponse(req, resp, errors, request, currentUser);
        } catch (AuthorizationException e) {
            handleForbidden(req, resp, e.getMessage());
        } catch (Exception e) {
            errors.add("Lỗi hệ thống: " + e.getMessage());
            handleErrorResponse(req, resp, errors, request, currentUser);
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

    private void handleErrorResponse(HttpServletRequest req, HttpServletResponse resp, List<String> errors, ProductRequest request, Account currentUser)
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
            req.setAttribute("productRequest", request);
            req.setAttribute("canAccessCostPrice", productService.isCostPriceAllowed(currentUser));
            req.getRequestDispatcher("/WEB-INF/views/products/create.jsp").forward(req, resp);
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
