package com.crm.controller.opportunity;

import com.crm.dao.OpportunityDAO;
import com.crm.model.Opportunity;
import com.crm.service.CustomFieldService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/deals/create", "/deals/edit", "/deals/delete", "/api/deals/save"})
public class OpportunitySaveServlet extends HttpServlet {

    private final OpportunityDAO opportunityDAO = new OpportunityDAO();
    private final CustomFieldService customFieldService = new CustomFieldService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().print("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        if (uri.endsWith("/delete")) {
            handleDelete(req, resp);
            return;
        }

        handleSave(req, resp);
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String idStr = req.getParameter("opportunityId");
        String title = req.getParameter("title");
        String amountStr = req.getParameter("amount");
        String ownerIdStr = req.getParameter("ownerId");
        String stageIdStr = req.getParameter("pipelineStageId");
        String probabilityStr = req.getParameter("probability");
        String reasonIdStr = req.getParameter("winLossReasonId");
        String competitorIdStr = req.getParameter("competitorId");

        if (title == null || title.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Tiêu đề cơ hội không được để trống\"}");
            return;
        }

        Double amount = 0.0;
        if (amountStr != null && !amountStr.trim().isEmpty()) {
            try { amount = Double.parseDouble(amountStr.trim()); } catch (Exception ignored) {}
        }

        Integer ownerId = (Integer) req.getSession().getAttribute("userId");
        if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try { ownerId = Integer.parseInt(ownerIdStr.trim()); } catch (Exception ignored) {}
        }

        Integer pipelineStageId = null;
        if (stageIdStr != null && !stageIdStr.trim().isEmpty()) {
            try { pipelineStageId = Integer.parseInt(stageIdStr.trim()); } catch (Exception ignored) {}
        }

        Double probability = null;
        if (probabilityStr != null && !probabilityStr.trim().isEmpty()) {
            try { probability = Double.parseDouble(probabilityStr.trim()); } catch (Exception ignored) {}
        }

        Integer winLossReasonId = null;
        if (reasonIdStr != null && !reasonIdStr.trim().isEmpty()) {
            try { winLossReasonId = Integer.parseInt(reasonIdStr.trim()); } catch (Exception ignored) {}
        }

        Integer competitorId = null;
        if (competitorIdStr != null && !competitorIdStr.trim().isEmpty()) {
            try { competitorId = Integer.parseInt(competitorIdStr.trim()); } catch (Exception ignored) {}
        }

        com.crm.dao.PipelineStageDAO stageDAO = new com.crm.dao.PipelineStageDAO();
        com.crm.dao.WinLossReasonDAO reasonDAO = new com.crm.dao.WinLossReasonDAO();
        com.crm.model.PipelineStage selectedStage = null;

        if (pipelineStageId != null) {
            selectedStage = stageDAO.findById(pipelineStageId);
            if (selectedStage != null && probability == null) {
                probability = selectedStage.getDefaultProbability();
            }
        }

        // Validate closing rules (S2-10)
        java.sql.Timestamp closeDate = null;
        if (selectedStage != null) {
            double defaultProb = selectedStage.getDefaultProbability();
            String nameLower = selectedStage.getStageName().toLowerCase();
            boolean isWon = (defaultProb >= 100.0 || nameLower.contains("won") || nameLower.contains("thành công"));
            boolean isLost = (defaultProb <= 0.0 || nameLower.contains("lost") || nameLower.contains("thất bại"));

            if (isWon) {
                if (winLossReasonId == null) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Cơ hội ở trạng thái Thắng (Won) bắt buộc phải chọn Lý do thắng từ danh sách.\"}");
                    return;
                }
                com.crm.model.WinLossReason r = reasonDAO.findById(winLossReasonId);
                if (r == null || !"WIN".equalsIgnoreCase(r.getReasonType())) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Lý do thắng chọn không hợp lệ hoặc không đúng loại WIN.\"}");
                    return;
                }
                closeDate = new java.sql.Timestamp(System.currentTimeMillis());
            } else if (isLost) {
                if (winLossReasonId == null) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Cơ hội ở trạng thái Thất bại (Lost) bắt buộc phải chọn Lý do thua từ danh sách.\"}");
                    return;
                }
                com.crm.model.WinLossReason r = reasonDAO.findById(winLossReasonId);
                if (r == null || !"LOSS".equalsIgnoreCase(r.getReasonType())) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Lý do thua chọn không hợp lệ hoặc không đúng loại LOSS.\"}");
                    return;
                }
                closeDate = new java.sql.Timestamp(System.currentTimeMillis());
            }
        }

        // Extract custom fields from request parameters
        Map<Integer, String> customFieldValues = new HashMap<>();
        req.getParameterMap().forEach((key, vals) -> {
            if (key.startsWith("customField_") && vals != null && vals.length > 0) {
                try {
                    int fieldId = Integer.parseInt(key.substring("customField_".length()));
                    customFieldValues.put(fieldId, vals[0]);
                } catch (NumberFormatException ignored) {}
            }
        });

        // Backend Required & Data Type Validation
        List<String> validationErrors = customFieldService.validateSubmittedCustomFields("OPPORTUNITY", customFieldValues);
        if (!validationErrors.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            StringBuilder sb = new StringBuilder("{\"error\":\"Validation failed\", \"details\":[");
            for (int i = 0; i < validationErrors.size(); i++) {
                sb.append("\"").append(escapeJson(validationErrors.get(i))).append("\"");
                if (i < validationErrors.size() - 1) sb.append(",");
            }
            sb.append("]}");
            out.print(sb.toString());
            return;
        }

        Opportunity opp = new Opportunity();
        opp.setTitle(title.trim());
        opp.setAmount(amount);
        opp.setOwnerId(ownerId != null ? ownerId : 1);
        opp.setPipelineStageId(pipelineStageId);
        opp.setProbability(probability != null ? probability : 0.0);
        opp.setWinLossReasonId(winLossReasonId);
        opp.setCompetitorId(competitorId);
        opp.setCloseDate(closeDate);

        boolean isEdit = (idStr != null && !idStr.trim().isEmpty());
        boolean success;

        if (isEdit) {
            int oppId = Integer.parseInt(idStr.trim());
            opp.setOpportunityId(oppId);
            success = opportunityDAO.update(opp);
        } else {
            success = opportunityDAO.insert(opp);
        }

        if (success) {
            customFieldService.saveBatchValues("OPPORTUNITY", opp.getOpportunityId(), customFieldValues);
            resp.setStatus(isEdit ? HttpServletResponse.SC_OK : HttpServletResponse.SC_CREATED);
            out.print("{\"message\":\"Lưu cơ hội kinh doanh thành công\", \"opportunityId\":" + opp.getOpportunityId() + "}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Không thể lưu cơ hội kinh doanh vào cơ sở dữ liệu\"}");
        }
    }


    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idStr = req.getParameter("opportunityId");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("id");
        }

        if (idStr == null || idStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu ID cơ hội cần xóa\"}");
            return;
        }

        try {
            int oppId = Integer.parseInt(idStr.trim());
            customFieldService.deleteValuesByEntity("OPPORTUNITY", oppId);
            boolean ok = opportunityDAO.delete(oppId);
            if (ok) {
                out.print("{\"message\":\"Xóa cơ hội thành công\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Không tìm thấy cơ hội để xóa\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID cơ hội không hợp lệ\"}");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
