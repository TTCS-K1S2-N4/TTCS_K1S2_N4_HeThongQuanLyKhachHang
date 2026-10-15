package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dao.LeadScoringRuleDAO;
import com.crm.dto.LeadScoreResponse;
import com.crm.dto.LeadScoringRuleRequest;
import com.crm.model.Lead;
import com.crm.model.LeadScoringRule;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý logic nghiệp vụ Chấm điểm Lead (S4-05).
 * - S4-05-AC-01: Khai báo tiêu chí và số điểm cụ thể.
 * - S4-05-AC-02: Điểm được tính toán lại tự động khi thông tin lead thay đổi.
 * - S4-05-AC-03: Phân loại Nóng, Ấm, Lạnh theo ngưỡng điểm khai báo được.
 * - S4-05-AC-04: Điểm chỉ để sắp xếp ưu tiên, không tự động loại bỏ lead.
 */
public class LeadScoringService {

    private static final Logger LOGGER = Logger.getLogger(LeadScoringService.class.getName());

    private final LeadScoringRuleDAO ruleDAO;
    private final LeadDAO leadDAO;

    public LeadScoringService() {
        this.ruleDAO = new LeadScoringRuleDAO();
        this.leadDAO = new LeadDAO();
    }

    public LeadScoringService(LeadScoringRuleDAO ruleDAO, LeadDAO leadDAO) {
        this.ruleDAO = Objects.requireNonNull(ruleDAO, "LeadScoringRuleDAO không được để null");
        this.leadDAO = Objects.requireNonNull(leadDAO, "LeadDAO không được để null");
    }

    public List<LeadScoringRule> getAllRules() {
        return ruleDAO.getAllRules();
    }

    public List<LeadScoringRule> getActiveRules() {
        return ruleDAO.getActiveRules();
    }

    public LeadScoringRule getRuleById(int ruleId) {
        return ruleDAO.getById(ruleId);
    }

    /**
     * Tạo mới hoặc cập nhật một quy tắc chấm điểm.
     * Khi có thay đổi quy tắc, tự động kích hoạt tính toán lại toàn bộ điểm của Lead (S4-05-AC-02).
     */
    public boolean saveOrUpdateRule(LeadScoringRuleRequest request) {
        if (request == null || !request.isValid()) {
            throw new IllegalArgumentException(request != null ? request.getValidationErrorMessage() : "Yêu cầu không hợp lệ.");
        }

        boolean success;
        if (request.getRuleId() != null && request.getRuleId() > 0) {
            LeadScoringRule existing = ruleDAO.getById(request.getRuleId());
            if (existing == null) {
                return false;
            }
            existing.setCriterion(request.getCriterion().trim());
            existing.setOperator(request.getOperator());
            existing.setConditionValue(request.getConditionValue().trim());
            existing.setScore(request.getScore());
            if (request.getIsActive() != null) {
                existing.setActive(request.getIsActive());
            }
            success = ruleDAO.updateRule(existing);
        } else {
            LeadScoringRule newRule = new LeadScoringRule();
            newRule.setCriterion(request.getCriterion().trim());
            newRule.setOperator(request.getOperator());
            newRule.setConditionValue(request.getConditionValue().trim());
            newRule.setScore(request.getScore());
            newRule.setActive(request.getIsActive() != null ? request.getIsActive() : true);
            success = ruleDAO.createRule(newRule);
        }

        if (success) {
            // Tự động tính toán lại điểm Lead theo quy tắc mới
            recalculateAllLeadScores();
        }

        return success;
    }

    /**
     * Xóa một quy tắc chấm điểm và tự động tính toán lại điểm Lead (S4-05-AC-02).
     */
    public boolean deleteRule(int ruleId) {
        boolean success = ruleDAO.deleteRule(ruleId);
        if (success) {
            recalculateAllLeadScores();
        }
        return success;
    }

    public int getHotThreshold() {
        return ruleDAO.getHotThreshold();
    }

    public int getWarmThreshold() {
        return ruleDAO.getWarmThreshold();
    }

    /**
     * Cập nhật ngưỡng phân loại Nóng, Ấm, Lạnh (S4-05-AC-03).
     * Ràng buộc: Ngưỡng Nóng phải lớn hơn ngưỡng Ấm.
     */
    public boolean updateThresholds(int hotThreshold, int warmThreshold) {
        if (hotThreshold <= warmThreshold) {
            throw new IllegalArgumentException("Ngưỡng Lead Nóng (" + hotThreshold + ") phải lớn hơn ngưỡng Lead Ấm (" + warmThreshold + ").");
        }

        boolean updated = ruleDAO.updateThresholds(hotThreshold, warmThreshold);
        if (updated) {
            // Khi ngưỡng thay đổi, phân loại lại toàn bộ Lead
            recalculateAllLeadScores();
        }
        return updated;
    }

    /**
     * Đánh giá chi tiết điểm của một Lead dựa trên các tiêu chí cấu hình.
     */
    public LeadScoreResponse evaluateLead(Lead lead) {
        if (lead == null) return null;

        List<LeadScoringRule> rules = ruleDAO.getActiveRules();
        int totalScore = 0;
        LeadScoreResponse response = new LeadScoreResponse(lead.getLeadId(), lead.getFullName(), lead.getCompany(), 0, "COLD");

        for (LeadScoringRule rule : rules) {
            if (matchesRule(lead, rule)) {
                totalScore += rule.getScore();
                response.addMatchedRule(describeRuleMatch(rule));
            }
        }

        response.setScore(totalScore);
        response.setClassification(determineClassification(totalScore));
        return response;
    }

    /**
     * Tính toán và gán điểm số + phân loại trực tiếp lên đối tượng Lead (dùng trước khi lưu).
     */
    public void applyScoring(Lead lead) {
        if (lead == null) return;
        LeadScoreResponse evaluated = evaluateLead(lead);
        if (evaluated != null) {
            lead.setScore(evaluated.getScore());
            lead.setRating(evaluated.getClassification());
        }
    }

    /**
     * Tự động tính toán lại điểm và phân loại cho một Lead cụ thể và lưu vào DB (S4-05-AC-02).
     */
    public boolean recalculateLeadScore(int leadId) {
        Lead lead = leadDAO.getById(leadId);
        if (lead == null) return false;

        LeadScoreResponse result = evaluateLead(lead);
        if (result == null) return false;

        String sql = "UPDATE leads SET score = ?, rating = ? WHERE lead_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, result.getScore());
            ps.setString(2, result.getClassification());
            ps.setInt(3, leadId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật điểm cho Lead #" + leadId + ": " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Tự động tính toán lại điểm và phân loại cho TOÀN BỘ Lead trong hệ thống (S4-05-AC-02).
     * Chỉ sắp xếp thứ tự ưu tiên cuộc gọi, không tự động loại bỏ Lead (S4-05-AC-04).
     */
    public int recalculateAllLeadScores() {
        List<Lead> leads = leadDAO.getAllLeads();
        if (leads == null || leads.isEmpty()) return 0;

        List<LeadScoringRule> rules = ruleDAO.getActiveRules();
        int hotThreshold = ruleDAO.getHotThreshold();
        int warmThreshold = ruleDAO.getWarmThreshold();

        String updateSql = "UPDATE leads SET score = ?, rating = ? WHERE lead_id = ?";
        int updatedCount = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            conn.setAutoCommit(false);

            for (Lead lead : leads) {
                int totalScore = 0;
                for (LeadScoringRule rule : rules) {
                    if (matchesRule(lead, rule)) {
                        totalScore += rule.getScore();
                    }
                }
                String classification = (totalScore >= hotThreshold) ? "HOT" :
                                        (totalScore >= warmThreshold ? "WARM" : "COLD");

                ps.setInt(1, totalScore);
                ps.setString(2, classification);
                ps.setInt(3, lead.getLeadId());
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            conn.commit();
            conn.setAutoCommit(true);

            for (int r : results) {
                if (r >= 0 || r == PreparedStatement.SUCCESS_NO_INFO) updatedCount++;
            }
            LOGGER.info("Đã tự động tính toán lại điểm cho " + updatedCount + " Lead.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tính toán lại điểm toàn bộ Lead: " + e.getMessage(), e);
        }

        return updatedCount;
    }

    /**
     * Kiểm tra đối sánh giữa thông tin Lead và điều kiện của quy tắc.
     */
    private boolean matchesRule(Lead lead, LeadScoringRule rule) {
        if (lead == null || rule == null) return false;

        String criterion = rule.getCriterion();
        String operator = rule.getOperator();
        String targetValue = rule.getConditionValue();

        if (criterion == null || targetValue == null) return false;

        String actualValue = "";

        switch (criterion.toUpperCase()) {
            case "INDUSTRY":
                actualValue = lead.getIndustry();
                break;
            case "SOURCE":
                actualValue = lead.getSourceName();
                break;
            case "COMPANY_SIZE":
                // Kiểm tra trong tên công ty hoặc trường ghi chú
                actualValue = extractCompanySize(lead);
                break;
            case "INTEREST":
                // Mức độ quan tâm từ ghi chú hoặc rating hiện tại
                actualValue = extractInterest(lead);
                break;
            default:
                actualValue = lead.getNotes();
                break;
        }

        if (actualValue == null || actualValue.trim().isEmpty()) {
            return false;
        }

        actualValue = actualValue.trim();
        targetValue = targetValue.trim();

        if ("CONTAINS".equalsIgnoreCase(operator)) {
            return actualValue.toLowerCase().contains(targetValue.toLowerCase());
        } else {
            // Mặc định là EQUALS
            return actualValue.equalsIgnoreCase(targetValue);
        }
    }

    private String extractCompanySize(Lead lead) {
        if (lead.getNotes() != null && !lead.getNotes().isEmpty()) {
            return lead.getNotes();
        }
        return lead.getCompany();
    }

    private String extractInterest(Lead lead) {
        if (lead.getNotes() != null && !lead.getNotes().isEmpty()) {
            return lead.getNotes();
        }
        return lead.getRating();
    }

    private String determineClassification(int score) {
        int hot = ruleDAO.getHotThreshold();
        int warm = ruleDAO.getWarmThreshold();
        if (score >= hot) return "HOT";
        if (score >= warm) return "WARM";
        return "COLD";
    }

    private String describeRuleMatch(LeadScoringRule rule) {
        String critLabel = rule.getCriterion();
        if ("INDUSTRY".equalsIgnoreCase(critLabel)) critLabel = "Ngành nghề";
        else if ("COMPANY_SIZE".equalsIgnoreCase(critLabel)) critLabel = "Quy mô";
        else if ("SOURCE".equalsIgnoreCase(critLabel)) critLabel = "Nguồn";
        else if ("INTEREST".equalsIgnoreCase(critLabel)) critLabel = "Mức độ quan tâm";

        return critLabel + " (" + rule.getOperator() + " '" + rule.getConditionValue() + "'): " +
                (rule.getScore() > 0 ? "+" : "") + rule.getScore() + " điểm";
    }
}
