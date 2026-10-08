package com.crm.controller.customer;

import com.crm.model.Customer;
import com.crm.service.CustomerMergeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/customers/duplicates")
public class CustomerDuplicateServlet extends HttpServlet {

    private CustomerMergeService mergeService = new CustomerMergeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<com.crm.dto.DuplicateCandidate> duplicateCandidates = mergeService.findDuplicatePairs();
        List<Customer> duplicates = mergeService.findDuplicates();
        request.setAttribute("duplicateCandidates", duplicateCandidates);
        request.setAttribute("duplicates", duplicates);
        request.getRequestDispatcher("/WEB-INF/views/customers/duplicates.jsp").forward(request, response);
    }
}
