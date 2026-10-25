package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.exception.AuthorizationException;
import com.crm.model.Customer;
import com.crm.model.CustomerRelationship;
import com.crm.service.CustomerHierarchyService;
import com.crm.service.PermissionService;
import com.crm.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/customers/hierarchy")
public class CustomerHierarchyServlet extends HttpServlet {

    private CustomerHierarchyService hierarchyService = new CustomerHierarchyService();
    private CustomerDAO customerDAO = new CustomerDAO();
    private OpportunityDAO opportunityDAO = new OpportunityDAO();
    private PermissionService permissionService = new PermissionService();

    public void setHierarchyService(CustomerHierarchyService hierarchyService) {
        if (hierarchyService != null) this.hierarchyService = hierarchyService;
    }

    public void setCustomerDAO(CustomerDAO customerDAO) {
        if (customerDAO != null) this.customerDAO = customerDAO;
    }

    public void setOpportunityDAO(OpportunityDAO opportunityDAO) {
        if (opportunityDAO != null) this.opportunityDAO = opportunityDAO;
    }

    public void setPermissionService(PermissionService permissionService) {
        if (permissionService != null) this.permissionService = permissionService;
    }

    private List<Integer> getEffectiveRoles(HttpServletRequest request, HttpSession session) {
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(request.getAttribute("effectiveRoleIds"));
        if (roleIds == null || roleIds.isEmpty()) {
            if (session != null) {
                roleIds = ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds"));
                if (roleIds == null || roleIds.isEmpty()) {
                    Integer roleId = (Integer) session.getAttribute("roleId");
                    if (roleId != null) {
                        roleIds = Collections.singletonList(roleId);
                    }
                }
            }
        }
        return (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.emptyList();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        List<Integer> effectiveRoles = getEffectiveRoles(request, session);

        String errorMessage = (session != null) ? (String) session.getAttribute("errorMessage") : null;
        String successMessage = (session != null) ? (String) session.getAttribute("successMessage") : null;
        if (errorMessage != null && session != null) {
            request.setAttribute("errorMessage", errorMessage);
            session.removeAttribute("errorMessage");
        }
        if (successMessage != null && session != null) {
            request.setAttribute("successMessage", successMessage);
            session.removeAttribute("successMessage");
        }

        List<Customer> allCustomers = customerDAO.findAll();
        List<Integer> accessibleOwnerIds = permissionService.getAccessibleAccountIdsForRoles(userId, effectiveRoles, "ACCOUNT");
        if (accessibleOwnerIds != null && allCustomers != null) {
            allCustomers.removeIf(c -> !accessibleOwnerIds.contains(c.getOwnerId()));
        }
        request.setAttribute("allCustomers", allCustomers);

        String customerIdStr = request.getParameter("id");
        if (customerIdStr != null && !customerIdStr.isEmpty()) {
            try {
                int customerId = Integer.parseInt(customerIdStr);
                Customer customer = customerDAO.findById(customerId);
                if (customer == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                // Enforce Data Scope access control
                try {
                    permissionService.validateDataAccessForRoles(userId, effectiveRoles, "ACCOUNT", customer.getOwnerId());
                } catch (AuthorizationException e) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
                    return;
                }
                
                List<CustomerRelationship> parents = hierarchyService.getParents(customerId);
                List<CustomerRelationship> children = hierarchyService.getChildren(customerId);
                
                // Group Contract Total = Parent Signed Amount + Sum of Children Signed Amounts
                double parentSigned = opportunityDAO.calculateTotalSignedAmount(customerId);
                double childrenSignedTotal = 0.0;
                if (children != null) {
                    for (CustomerRelationship rel : children) {
                        childrenSignedTotal += opportunityDAO.calculateTotalSignedAmount(rel.getChildCustomerId());
                    }
                }
                double groupContractTotal = parentSigned + childrenSignedTotal;

                request.setAttribute("customer", customer);
                request.setAttribute("parents", parents);
                request.setAttribute("children", children);
                request.setAttribute("groupContractTotal", groupContractTotal);
                request.setAttribute("customerId", customerId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        
        request.getRequestDispatcher("/WEB-INF/views/customers/hierarchy.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Bạn cần đăng nhập để thực hiện thao tác này.");
            return;
        }

        List<Integer> effectiveRoles = getEffectiveRoles(request, session);

        // Bước 4: Bắt buộc quyền ACCOUNT_EDIT đối với mọi thao tác POST làm thay đổi dữ liệu
        if (!permissionService.hasPermissionForRoles(effectiveRoles, "ACCOUNT_EDIT")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa quan hệ khách hàng (yêu cầu quyền ACCOUNT_EDIT).");
            return;
        }

        String action = request.getParameter("action");
        String customerIdStr = request.getParameter("customerId");
        
        try {
            if ("add".equals(action)) {
                String parentIdStr = request.getParameter("parentId");
                String childIdStr = request.getParameter("childId");
                String type = request.getParameter("relationshipType");
                
                if (parentIdStr == null || parentIdStr.trim().isEmpty() || childIdStr == null || childIdStr.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng chọn đầy đủ công ty mẹ và công ty con.");
                } else {
                    int parentId = Integer.parseInt(parentIdStr.trim());
                    int childId = Integer.parseInt(childIdStr.trim());
                    
                    if (parentId <= 0 || childId <= 0) {
                        session.setAttribute("errorMessage", "ID công ty mẹ hoặc công ty con không hợp lệ.");
                    } else if (parentId == childId) {
                        session.setAttribute("errorMessage", "Không thể gán công ty làm công ty con của chính nó.");
                    } else {
                        Customer parent = customerDAO.findById(parentId);
                        Customer child = customerDAO.findById(childId);
                        if (parent == null || child == null) {
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Công ty mẹ hoặc công ty con không tồn tại trong hệ thống.");
                            return;
                        }

                        // Bước 3: Kiểm tra Data Scope cho cả công ty mẹ và công ty con
                        try {
                            permissionService.validateDataAccessForRoles(userId, effectiveRoles, "ACCOUNT", parent.getOwnerId());
                            permissionService.validateDataAccessForRoles(userId, effectiveRoles, "ACCOUNT", child.getOwnerId());
                        } catch (AuthorizationException e) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý phân cấp cho công ty ngoài phạm vi dữ liệu được phép.");
                            return;
                        }

                        boolean ok = hierarchyService.addRelationship(parentId, childId, type != null && !type.trim().isEmpty() ? type : "SUBSIDIARY");
                        if (ok) {
                            session.setAttribute("successMessage", "Khai báo quan hệ công ty mẹ - công ty con thành công!");
                        } else {
                            session.setAttribute("errorMessage", "Không thể tạo quan hệ. Quan hệ có thể đã tồn tại hoặc tạo vòng lặp phân cấp.");
                        }
                    }
                }
            } else if ("delete".equals(action)) {
                String relIdStr = request.getParameter("relationshipId");
                if (relIdStr == null || relIdStr.trim().isEmpty()) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã định danh quan hệ cần xóa.");
                    return;
                }

                int relationshipId = Integer.parseInt(relIdStr.trim());
                if (relationshipId <= 0) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã quan hệ không hợp lệ.");
                    return;
                }

                // Bước 2: Khắc phục IDOR - Không tin tưởng customerId/relationshipId do client gửi, truy xuất quan hệ thực tế từ DB
                CustomerRelationship rel = hierarchyService.getRelationshipById(relationshipId);
                if (rel == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Quan hệ công ty mẹ - con không tồn tại.");
                    return;
                }

                int parentId = rel.getParentCustomerId();
                int childId = rel.getChildCustomerId();

                // Nếu client gửi kèm customerId, xác thực quan hệ này có thực sự thuộc về customerId đó hay không
                if (customerIdStr != null && !customerIdStr.trim().isEmpty() && !"0".equals(customerIdStr.trim())) {
                    try {
                        int clientCustId = Integer.parseInt(customerIdStr.trim());
                        if (clientCustId > 0 && parentId != clientCustId && childId != clientCustId) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Quan hệ được yêu cầu xóa không thuộc về khách hàng đang thao tác.");
                            return;
                        }
                    } catch (NumberFormatException ignored) {}
                }

                Customer parent = customerDAO.findById(parentId);
                Customer child = customerDAO.findById(childId);
                if (parent == null || child == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khách hàng trong quan hệ phân cấp không còn tồn tại.");
                    return;
                }

                // Xác minh Data Scope cho cả hai bên
                try {
                    permissionService.validateDataAccessForRoles(userId, effectiveRoles, "ACCOUNT", parent.getOwnerId());
                    permissionService.validateDataAccessForRoles(userId, effectiveRoles, "ACCOUNT", child.getOwnerId());
                } catch (AuthorizationException e) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xóa quan hệ của công ty ngoài phạm vi dữ liệu được phép.");
                    return;
                }

                boolean ok = hierarchyService.deleteRelationship(relationshipId);
                if (ok) {
                    session.setAttribute("successMessage", "Đã xóa quan hệ thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể xóa quan hệ.");
                }
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu ID nhập vào không hợp lệ.");
            return;
        }
        
        String redirectUrl = request.getContextPath() + "/customers/hierarchy";
        if (customerIdStr != null && !customerIdStr.trim().isEmpty() && !"0".equals(customerIdStr)) {
            redirectUrl += "?id=" + customerIdStr;
        }
        response.sendRedirect(redirectUrl);
    }
}
