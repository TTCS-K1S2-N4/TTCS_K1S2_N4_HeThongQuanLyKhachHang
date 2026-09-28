package com.crm.controller.opportunity;

import com.crm.dao.OpportunityDAO;
import com.crm.model.Opportunity;
import com.crm.service.PermissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/deals")
public class OpportunityListServlet extends HttpServlet {
    private OpportunityDAO dao = new OpportunityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception e) {}
        int pageSize = 20;

        PermissionService permissionService = new PermissionService();
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getSession().getAttribute("roleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");
        
        if (userId == null || roleId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roleIds != null ? roleIds : java.util.Collections.singletonList(roleId), "DEAL");

        List<Opportunity> list = dao.getList(keyword, ownerIds, page, pageSize);
        int total = dao.count(keyword, ownerIds);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("list", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);

        req.getRequestDispatcher("/WEB-INF/views/deals/list.jsp").forward(req, resp);
    }
}


