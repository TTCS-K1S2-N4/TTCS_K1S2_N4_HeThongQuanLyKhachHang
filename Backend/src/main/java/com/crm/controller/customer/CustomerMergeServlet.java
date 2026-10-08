package com.crm.controller.customer;

import com.crm.service.CustomerMergeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/customers/merge", "/customers/duplicates/compare"})
public class CustomerMergeServlet extends HttpServlet {

    private CustomerMergeService mergeService = new CustomerMergeService();
    private com.crm.dao.CustomerDAO customerDAO = new com.crm.dao.CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String primaryIdStr = request.getParameter("primaryId");
        if (primaryIdStr == null || primaryIdStr.isEmpty()) {
            primaryIdStr = request.getParameter("leftId");
        }
        String secondaryIdStr = request.getParameter("secondaryId");
        if (secondaryIdStr == null || secondaryIdStr.isEmpty()) {
            secondaryIdStr = request.getParameter("rightId");
        }
        
        request.setAttribute("primaryId", primaryIdStr);
        request.setAttribute("secondaryId", secondaryIdStr);
        
        try {
            if (primaryIdStr != null && !primaryIdStr.isEmpty()) {
                request.setAttribute("primaryCustomer", customerDAO.findById(Integer.parseInt(primaryIdStr)));
            }
            if (secondaryIdStr != null && !secondaryIdStr.isEmpty()) {
                request.setAttribute("secondaryCustomer", customerDAO.findById(Integer.parseInt(secondaryIdStr)));
            }
        } catch (NumberFormatException ignored) {}
        
        request.getRequestDispatcher("/WEB-INF/views/customers/merge.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String primaryParam = request.getParameter("primaryId");
        if (primaryParam == null || primaryParam.isEmpty()) {
            primaryParam = request.getParameter("leftId");
        }
        String secondaryParam = request.getParameter("secondaryId");
        if (secondaryParam == null || secondaryParam.isEmpty()) {
            secondaryParam = request.getParameter("rightId");
        }

        try {
            int primaryId = Integer.parseInt(primaryParam);
            int secondaryId = Integer.parseInt(secondaryParam);

            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login");
                return;
            }
            
            com.crm.model.Account account = (com.crm.model.Account) session.getAttribute("currentUser");
            if (account == null) {
                account = new com.crm.dao.AccountDAO().getAccountById(userId);
            }
            if (account == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Không tìm thấy thông tin tài khoản");
                return;
            }

            if (primaryId == secondaryId) {
                request.setAttribute("errorMessage", "Không thể gộp một khách hàng vào chính nó.");
                request.setAttribute("primaryId", primaryId);
                request.setAttribute("secondaryId", secondaryId);
                request.setAttribute("primaryCustomer", customerDAO.findById(primaryId));
                request.setAttribute("secondaryCustomer", customerDAO.findById(secondaryId));
                request.getRequestDispatcher("/WEB-INF/views/customers/merge.jsp").forward(request, response);
                return;
            }
            
            com.crm.model.Customer primaryCustomer = customerDAO.findById(primaryId);
            com.crm.model.Customer secondaryCustomer = customerDAO.findById(secondaryId);
            
            if (primaryCustomer == null || secondaryCustomer == null) {
                request.setAttribute("errorMessage", "ID khách hàng không tồn tại trong hệ thống.");
                request.setAttribute("primaryId", primaryId);
                request.setAttribute("secondaryId", secondaryId);
                request.getRequestDispatcher("/WEB-INF/views/customers/merge.jsp").forward(request, response);
                return;
            }
            
            com.crm.service.PermissionService permissionService = new com.crm.service.PermissionService();
            java.util.List<Integer> rIds = account.getRoleIds();
            if (rIds == null || rIds.isEmpty()) {
                Integer rId = (Integer) session.getAttribute("roleId");
                rIds = rId != null ? java.util.Collections.singletonList(rId) : new java.util.ArrayList<>();
            }
            
            try {
                permissionService.validateDataAccessForRoles(userId, rIds, "ACCOUNT", primaryCustomer.getOwnerId());
                permissionService.validateDataAccessForRoles(userId, rIds, "ACCOUNT", secondaryCustomer.getOwnerId());
            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền gộp khách hàng ngoài phạm vi dữ liệu của mình.");
                return;
            }
            
            boolean success = mergeService.mergeCustomers(primaryId, secondaryId, userId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customers/detail?id=" + primaryId + "&merged=true");
            } else {
                request.setAttribute("errorMessage", "Thao tác gộp khách hàng thất bại do lỗi hệ thống hoặc dữ liệu không hợp lệ.");
                request.setAttribute("primaryId", primaryId);
                request.setAttribute("secondaryId", secondaryId);
                request.setAttribute("primaryCustomer", primaryCustomer);
                request.setAttribute("secondaryCustomer", secondaryCustomer);
                request.getRequestDispatcher("/WEB-INF/views/customers/merge.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID khách hàng không hợp lệ.");
        }
    }
}
