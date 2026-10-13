package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dao.LeadScoringRuleDAO;
import com.crm.dto.LeadScoreResponse;
import com.crm.dto.LeadScoringRuleRequest;
import com.crm.model.Lead;
import com.crm.model.LeadScoringRule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class LeadScoringServiceTest {

    private LeadScoringRuleDAO mockRuleDAO;
    private LeadDAO mockLeadDAO;
    private LeadScoringService scoringService;

    @BeforeEach
    public void setUp() {
        mockRuleDAO = mock(LeadScoringRuleDAO.class);
        mockLeadDAO = mock(LeadDAO.class);
        scoringService = new LeadScoringService(mockRuleDAO, mockLeadDAO);

        // Ngưỡng mặc định: Nóng >= 70, Ấm >= 40, Lạnh < 40
        when(mockRuleDAO.getHotThreshold()).thenReturn(70);
        when(mockRuleDAO.getWarmThreshold()).thenReturn(40);
    }

    @Test
    @DisplayName("S4-05-AC-01: Đánh giá tiêu chí và tính điểm chính xác cho Lead")
    public void testEvaluateLeadWithVariousCriteria() {
        LeadScoringRule rule1 = new LeadScoringRule("INDUSTRY", "EQUALS", "Công nghệ thông tin", 25);
        LeadScoringRule rule2 = new LeadScoringRule("SOURCE", "EQUALS", "Website", 15);
        LeadScoringRule rule3 = new LeadScoringRule("INTEREST", "CONTAINS", "Rất cao", 30);
        LeadScoringRule rule4 = new LeadScoringRule("COMPANY_SIZE", "CONTAINS", "100-500", 20);

        when(mockRuleDAO.getActiveRules()).thenReturn(Arrays.asList(rule1, rule2, rule3, rule4));

        Lead lead = new Lead();
        lead.setLeadId(101);
        lead.setFullName("Nguyễn Văn A");
        lead.setIndustry("Công nghệ thông tin"); // +25
        lead.setSourceName("Website");           // +15
        lead.setNotes("Quy mô: 100-500. Quan tâm: Rất cao"); // matches rule3 (+30) & rule4 (+20)

        LeadScoreResponse response = scoringService.evaluateLead(lead);

        assertNotNull(response);
        // Tổng điểm: 25 + 15 + 30 + 20 = 90 >= 70 -> HOT
        assertEquals(90, response.getScore());
        assertEquals("HOT", response.getClassification());
        assertEquals(4, response.getMatchedRuleDescriptions().size());
    }

    @Test
    @DisplayName("S4-05-AC-03: Phân loại Nóng, Ấm, Lạnh theo ngưỡng điểm khai báo được")
    public void testClassificationThresholds() {
        LeadScoringRule ruleIt = new LeadScoringRule("INDUSTRY", "EQUALS", "Công nghệ thông tin", 50);
        when(mockRuleDAO.getActiveRules()).thenReturn(Collections.singletonList(ruleIt));

        // Lead 1: 50 điểm -> Nằm giữa 40 và 70 -> WARM
        Lead leadWarm = new Lead();
        leadWarm.setIndustry("Công nghệ thông tin");
        LeadScoreResponse respWarm = scoringService.evaluateLead(leadWarm);
        assertEquals(50, respWarm.getScore());
        assertEquals("WARM", respWarm.getClassification());

        // Lead 2: 0 điểm (< 40) -> COLD
        Lead leadCold = new Lead();
        leadCold.setIndustry("Nông nghiệp");
        LeadScoreResponse respCold = scoringService.evaluateLead(leadCold);
        assertEquals(0, respCold.getScore());
        assertEquals("COLD", respCold.getClassification());
    }

    @Test
    @DisplayName("S4-05-AC-03: Cập nhật ngưỡng phân loại hợp lệ và bắt lỗi khi hot <= warm")
    public void testUpdateThresholdsValidation() {
        when(mockRuleDAO.updateThresholds(80, 50)).thenReturn(true);
        when(mockLeadDAO.getAllLeads()).thenReturn(Collections.emptyList());

        boolean ok = scoringService.updateThresholds(80, 50);
        assertTrue(ok);

        // Bắt lỗi khi ngưỡng Nóng <= ngưỡng Ấm
        assertThrows(IllegalArgumentException.class, () -> {
            scoringService.updateThresholds(40, 50);
        });
        assertThrows(IllegalArgumentException.class, () -> {
            scoringService.updateThresholds(40, 40);
        });
    }

    @Test
    @DisplayName("S4-05-AC-02: Điểm được tự động tính toán lại khi thêm hoặc xóa quy tắc")
    public void testAutoRecalculateOnRuleChange() {
        LeadScoringRuleRequest req = new LeadScoringRuleRequest("SOURCE", "EQUALS", "Facebook", 10);
        when(mockRuleDAO.createRule(any(LeadScoringRule.class))).thenReturn(true);

        Lead lead1 = new Lead();
        lead1.setLeadId(1);
        lead1.setSourceName("Facebook");
        when(mockLeadDAO.getAllLeads()).thenReturn(Collections.singletonList(lead1));

        boolean saved = scoringService.saveOrUpdateRule(req);
        assertTrue(saved);
        // Xác minh ruleDAO đã gọi createRule và leadDAO đã lấy toàn bộ leads để tính lại
        verify(mockRuleDAO, times(1)).createRule(any(LeadScoringRule.class));
        verify(mockLeadDAO, atLeastOnce()).getAllLeads();
    }

    @Test
    @DisplayName("S4-05-AC-04: Điểm chỉ để sắp xếp ưu tiên, không tự động loại bỏ lead")
    public void testNegativeOrLowScorePreservesLead() {
        LeadScoringRule penaltyRule = new LeadScoringRule("INDUSTRY", "EQUALS", "Bất động sản", -30);
        when(mockRuleDAO.getActiveRules()).thenReturn(Collections.singletonList(penaltyRule));

        Lead lead = new Lead();
        lead.setLeadId(202);
        lead.setFullName("Lê Văn B");
        lead.setIndustry("Bất động sản");

        LeadScoreResponse res = scoringService.evaluateLead(lead);
        assertNotNull(res);
        assertEquals(-30, res.getScore());
        assertEquals("COLD", res.getClassification());
        // Lead vẫn tồn tại, giữ nguyên ID và thông tin
        assertEquals(202, res.getLeadId());
    }
}
