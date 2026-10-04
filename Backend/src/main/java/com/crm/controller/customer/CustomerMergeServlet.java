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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String primaryIdStr = request.getParameter("primaryId");
        String secondaryIdStr = request.getParameter("secondaryId");
        
        request.setAttribute("primaryId", primaryIdStr);
        request.setAttribute("secondaryId", secondaryIdStr);
        
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
