package com.crm.controller.quote;

import com.crm.dao.QuoteDAO;
import com.crm.model.Quote;
import com.crm.service.PermissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/quotes")
public class QuoteListServlet extends HttpServlet {
    private QuoteDAO dao = new QuoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception e) {}
        int pageSize = 20;

        PermissionService permissionService = new PermissionService();
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");
        
        if (userId == null || roleId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roleIds != null && !roleIds.isEmpty() ? roleIds : java.util.Collections.singletonList(roleId), "QUOTE");

        List<Quote> list = dao.getList(keyword, ownerIds, page, pageSize);
        int total = dao.count(keyword, ownerIds);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("list", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);

        req.getRequestDispatcher("/WEB-INF/views/quotes/list.jsp").forward(req, resp);
    }
}


