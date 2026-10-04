package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.model.Customer;
import com.crm.model.CustomerRelationship;
import com.crm.service.CustomerHierarchyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/customers/hierarchy")
public class CustomerHierarchyServlet extends HttpServlet {

    private CustomerHierarchyService hierarchyService = new CustomerHierarchyService();
    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
                request.setAttribute("customer", customer);
                request.setAttribute("parents", parents);
                request.setAttribute("children", children);
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
        String action = request.getParameter("action");
        String customerIdStr = request.getParameter("customerId");
        
        try {
            if ("add".equals(action)) {
                int parentId = Integer.parseInt(request.getParameter("parentId"));
                int childId = Integer.parseInt(request.getParameter("childId"));
                String type = request.getParameter("relationshipType");
                hierarchyService.addRelationship(parentId, childId, type);
            } else if ("delete".equals(action)) {
                int relationshipId = Integer.parseInt(request.getParameter("relationshipId"));
                hierarchyService.deleteRelationship(relationshipId);
            }
        } catch (NumberFormatException ignore) {
        }
        
        response.sendRedirect(request.getContextPath() + "/customers/hierarchy?id=" + customerIdStr);
    }
}
