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
        java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");
        
        if (userId == null || roleId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roleIds != null && !roleIds.isEmpty() ? roleIds : java.util.Collections.singletonList(roleId), "DEAL");

        String filterFieldIdStr = req.getParameter("filterFieldId");
        String filterFieldValue = req.getParameter("filterFieldValue");
        Integer filterFieldId = null;
        if (filterFieldIdStr != null && !filterFieldIdStr.trim().isEmpty()) {
            try { filterFieldId = Integer.parseInt(filterFieldIdStr.trim()); } catch (Exception ignored) {}
        }

        com.crm.service.CustomFieldService customFieldService = new com.crm.service.CustomFieldService();
        List<com.crm.model.CustomFieldDefinition> customFieldDefs = customFieldService.getDefinitions("OPPORTUNITY", "ACTIVE");

        com.crm.dao.PipelineStageDAO stageDAO = new com.crm.dao.PipelineStageDAO();
        com.crm.dao.WinLossReasonDAO reasonDAO = new com.crm.dao.WinLossReasonDAO();
        com.crm.dao.CompetitorDAO competitorDAO = new com.crm.dao.CompetitorDAO();

        List<com.crm.model.PipelineStage> pipelineStages = stageDAO.findAll();
        List<com.crm.model.WinLossReason> winReasons = reasonDAO.findAll("WIN");
        List<com.crm.model.WinLossReason> lossReasons = reasonDAO.findAll("LOSS");
        List<com.crm.model.Competitor> competitors = competitorDAO.findAll();

        List<Opportunity> list = dao.getList(keyword, ownerIds, filterFieldId, filterFieldValue, page, pageSize);
        int total = dao.count(keyword, ownerIds, filterFieldId, filterFieldValue);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("list", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);
        req.setAttribute("customFieldDefinitions", customFieldDefs);
        req.setAttribute("filterFieldId", filterFieldId);
        req.setAttribute("filterFieldValue", filterFieldValue);

        req.setAttribute("pipelineStages", pipelineStages);
        req.setAttribute("winReasons", winReasons);
        req.setAttribute("lossReasons", lossReasons);
        req.setAttribute("competitors", competitors);

        req.getRequestDispatcher("/WEB-INF/views/deals/list.jsp").forward(req, resp);
    }
}



