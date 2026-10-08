package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.model.Customer;
import com.crm.model.CustomerRelationship;
import com.crm.service.CustomerHierarchyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/customers/hierarchy")
public class CustomerHierarchyServlet extends HttpServlet {

    private CustomerHierarchyService hierarchyService = new CustomerHierarchyService();
    private CustomerDAO customerDAO = new CustomerDAO();
    private OpportunityDAO opportunityDAO = new OpportunityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String errorMessage = (String) session.getAttribute("errorMessage");
        String successMessage = (String) session.getAttribute("successMessage");
        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
            session.removeAttribute("errorMessage");
        }
        if (successMessage != null) {
            request.setAttribute("successMessage", successMessage);
            session.removeAttribute("successMessage");
        }

        List<Customer> allCustomers = customerDAO.findAll();
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
        HttpSession session = request.getSession();
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
                    int parentId = Integer.parseInt(parentIdStr);
                    int childId = Integer.parseInt(childIdStr);
                    
                    if (parentId == childId) {
                        session.setAttribute("errorMessage", "Không thể gán công ty làm công ty con của chính nó.");
                    } else {
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
                if (relIdStr != null && !relIdStr.trim().isEmpty()) {
                    int relationshipId = Integer.parseInt(relIdStr);
                    boolean ok = hierarchyService.deleteRelationship(relationshipId);
                    if (ok) {
                        session.setAttribute("successMessage", "Đã xóa quan hệ thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể xóa quan hệ.");
                    }
                }
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu ID nhập vào không hợp lệ.");
        }
        
        String redirectUrl = request.getContextPath() + "/customers/hierarchy";
        if (customerIdStr != null && !customerIdStr.trim().isEmpty() && !"0".equals(customerIdStr)) {
            redirectUrl += "?id=" + customerIdStr;
        }
        response.sendRedirect(redirectUrl);
    }
}
