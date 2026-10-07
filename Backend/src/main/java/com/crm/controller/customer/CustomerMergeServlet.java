package com.crm.controller.customer;

import com.crm.service.CustomerMergeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/customers/merge")
public class CustomerMergeServlet extends HttpServlet {

    private CustomerMergeService mergeService = new CustomerMergeService();

    private com.crm.dao.CustomerDAO customerDAO = new com.crm.dao.CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String primaryIdStr = request.getParameter("primaryId");
        String secondaryIdStr = request.getParameter("secondaryId");
        
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
        try {
            int primaryId = Integer.parseInt(request.getParameter("primaryId"));
            int secondaryId = Integer.parseInt(request.getParameter("secondaryId"));
            
            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login");
                return;
            }
            
            com.crm.model.Account account = (com.crm.model.Account) session.getAttribute("currentUser");
            if (account == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Không tìm thấy thông tin tài khoản");
                return;
            }
            java.util.List<String> roleCodes = account.getRoleCodes();
            if (roleCodes == null || (!roleCodes.contains("TEAM_LEAD") && !roleCodes.contains("DIRECTOR") && !roleCodes.contains("ADMIN"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Trưởng nhóm trở lên mới có quyền gộp khách hàng");
                return;
            }
            
            com.crm.model.Customer primaryCustomer = customerDAO.findById(primaryId);
            com.crm.model.Customer secondaryCustomer = customerDAO.findById(secondaryId);
            
            if (primaryCustomer == null || secondaryCustomer == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID khách hàng không tồn tại");
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
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền gộp khách hàng ngoài phạm vi dữ liệu của mình (IDOR prevention).");
                return;
            }
            
            boolean success = mergeService.mergeCustomers(primaryId, secondaryId, userId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customers/detail?id=" + primaryId);
            } else {
                response.sendRedirect(request.getContextPath() + "/customers/duplicates?error=1");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
