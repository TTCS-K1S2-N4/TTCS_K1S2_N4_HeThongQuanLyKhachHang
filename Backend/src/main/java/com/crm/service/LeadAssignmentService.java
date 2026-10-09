package com.crm.service;

import com.crm.dao.LeadAssignmentRuleDAO;
import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.model.LeadAssignmentRule;
import com.crm.model.LeadAssignmentHistory;

import java.sql.Timestamp;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Logger;

public class LeadAssignmentService {
    private static final Logger LOGGER = Logger.getLogger(LeadAssignmentService.class.getName());
    
    private final LeadAssignmentRuleDAO ruleDAO;
    private final LeadAssignmentHistoryDAO historyDAO;
    
    // Background worker for processing assignment queue
    private ScheduledExecutorService scheduler;
    
    // Round-robin state: TeamId -> current index of assignee
    private final Map<Integer, AtomicInteger> roundRobinState = new ConcurrentHashMap<>();

    public LeadAssignmentService() {
        this.ruleDAO = new LeadAssignmentRuleDAO();
        this.historyDAO = new LeadAssignmentHistoryDAO();
    }

    /**
     * Khởi động background worker chạy nền mỗi 5 phút.
     */
    public synchronized void startBackgroundWorker() {
        if (scheduler == null || scheduler.isShutdown()) {
            scheduler = Executors.newSingleThreadScheduledExecutor();
            scheduler.scheduleAtFixedRate(this::processUnassignedLeads, 0, 5, TimeUnit.MINUTES);
            LOGGER.info("Lead Assignment Background Worker started.");
        }
    }

    /**
     * Dừng background worker an toàn.
     */
    public synchronized void stopBackgroundWorker() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            LOGGER.info("Lead Assignment Background Worker stopped.");
        }
    }

    /**
     * Logic chạy nền: Quét hàng chờ và phân bổ.
     * (Cần LeadDAO để lấy danh sách leadId, hiện tại stub)
     */
    private void processUnassignedLeads() {
        LOGGER.info("Running background assignment process...");
        // Stub: Fetch unassigned leads from DB where status = 'UNASSIGNED'
        // For each lead, fetch region and industry, then call assignLead(...)
    }

    /**
     * Thuật toán phân bổ Lead lõi, trả về assigneeId hoặc null nếu vào Hàng chờ.
     */
    public Integer assignLead(int leadId, String region, String industry) {
        List<LeadAssignmentRule> rules = ruleDAO.getActiveRules();
        
        // Sắp xếp rules theo priority tăng dần (1 là ưu tiên cao nhất)
        rules.sort(Comparator.comparingInt(LeadAssignmentRule::getPriority));

        Integer matchedAssigneeId = null;
        Integer matchedRuleId = null;

        for (LeadAssignmentRule rule : rules) {
            if (!rule.isActive()) continue;

            if (isRuleMatched(rule, region, industry)) {
                matchedRuleId = rule.getRuleId();
                if ("ROUND_ROBIN".equalsIgnoreCase(rule.getCriterion())) {
                    matchedAssigneeId = getNextRoundRobinAssignee(rule.getTeamId());
                } else {
                    matchedAssigneeId = rule.getAssigneeId();
                }
                break; // First-match wins
            }
        }

        LeadAssignmentHistory history = new LeadAssignmentHistory();
        history.setLeadId(leadId);
        history.setRuleId(matchedRuleId);
        history.setAssignedAt(new Timestamp(System.currentTimeMillis()));

        if (matchedAssigneeId != null) {
            // Phân bổ thành công
            history.setAssignedTo(matchedAssigneeId);
            history.setStatus("SUCCESS");
            LOGGER.info("Lead " + leadId + " assigned to " + matchedAssigneeId + " by rule " + matchedRuleId);
        } else {
            // Đưa vào hàng chờ
            history.setStatus("QUEUED");
            LOGGER.info("Lead " + leadId + " unassigned, placed in QUEUE.");
        }

        // Lưu lịch sử (Sử dụng Transaction trong thực tế)
        historyDAO.saveHistory(history);
        
        return matchedAssigneeId;
    }

    /**
     * Kiểm tra điều kiện Rule với thông tin Lead.
     */
    private boolean isRuleMatched(LeadAssignmentRule rule, String region, String industry) {
        if (rule.getCriterion() == null) return false;
        
        switch (rule.getCriterion().toUpperCase()) {
            case "REGION":
                return rule.getCriterionValue() != null && rule.getCriterionValue().equalsIgnoreCase(region);
            case "INDUSTRY":
                return rule.getCriterionValue() != null && rule.getCriterionValue().equalsIgnoreCase(industry);
            case "ROUND_ROBIN":
                return rule.getTeamId() != null;
            default:
                return false;
        }
    }

    /**
     * Thuật toán Xoay vòng (Round-Robin) an toàn trong môi trường đa luồng.
     */
    private Integer getNextRoundRobinAssignee(Integer teamId) {
        if (teamId == null) return null;
        
        // Trong thực tế, gọi TeamDAO lấy danh sách userId thuộc teamId
        List<Integer> teamMembers = getMockTeamMembers(teamId);
        if (teamMembers == null || teamMembers.isEmpty()) {
            return null;
        }

        AtomicInteger currentIndex = roundRobinState.computeIfAbsent(teamId, k -> new AtomicInteger(0));
        
        // Sử dụng getAndIncrement để đảm bảo thread-safe
        int nextIndex = Math.abs(currentIndex.getAndIncrement()) % teamMembers.size();
        return teamMembers.get(nextIndex);
    }
    
    // Stub logic thay thế cho việc truy vấn DB lấy thành viên nhóm
    private List<Integer> getMockTeamMembers(int teamId) {
        return List.of(1, 2, 3); // Giả lập team có 3 thành viên: ID 1, 2, 3
    }
}
