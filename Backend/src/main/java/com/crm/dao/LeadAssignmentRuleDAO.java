package com.crm.dao;

import com.crm.model.LeadAssignmentRule;
import java.util.ArrayList;
import java.util.List;
import java.sql.Timestamp;

public class LeadAssignmentRuleDAO {
    
    // Giả lập truy vấn DB để tránh lỗi thiếu bảng. Trong thực tế sẽ gọi JDBC.
    public List<LeadAssignmentRule> getActiveRules() {
        List<LeadAssignmentRule> mockRules = new ArrayList<>();
        
        // Rule 1: Ưu tiên cao nhất - Phân bổ theo Khu vực miền Nam cho User 10
        LeadAssignmentRule rule1 = new LeadAssignmentRule();
        rule1.setRuleId(1);
        rule1.setPriority(1);
        rule1.setCriterion("REGION");
        rule1.setCriterionValue("South");
        rule1.setAssigneeId(10);
        rule1.setActive(true);
        
        // Rule 2: Ưu tiên số 2 - Ngành IT cho User 15
        LeadAssignmentRule rule2 = new LeadAssignmentRule();
        rule2.setRuleId(2);
        rule2.setPriority(2);
        rule2.setCriterion("INDUSTRY");
        rule2.setCriterionValue("IT");
        rule2.setAssigneeId(15);
        rule2.setActive(true);

        // Rule 3: Ưu tiên cuối cùng - Round-robin cho Team 1
        LeadAssignmentRule rule3 = new LeadAssignmentRule();
        rule3.setRuleId(3);
        rule3.setPriority(99);
        rule3.setCriterion("ROUND_ROBIN");
        rule3.setTeamId(1);
        rule3.setActive(true);

        mockRules.add(rule1);
        mockRules.add(rule2);
        mockRules.add(rule3);
        
        return mockRules;
    }
    
    public void saveRule(LeadAssignmentRule rule) {
        // Thực thi SQL INSERT INTO lead_assignment_rules ...
    }
}
