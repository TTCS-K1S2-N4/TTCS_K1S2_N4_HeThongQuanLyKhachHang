package com.crm.service;

import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.dao.LeadAssignmentRuleDAO;
import com.crm.model.LeadAssignmentRule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Test chứng minh các tiêu chí chấp nhận (Acceptance Criteria) cho S4-06:
 * Phân bổ Lead tự động theo Region, Industry, và Persistent Round-Robin.
 */
class LeadAssignmentServiceTest {

    @Mock
    private LeadAssignmentRuleDAO ruleDAO;

    @Mock
    private LeadAssignmentHistoryDAO historyDAO;

    private LeadAssignmentService assignmentService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        assignmentService = new LeadAssignmentService(ruleDAO, historyDAO);
    }

    @Test
    @DisplayName("S4-06 AC1: Kiểm tra đối chiếu quy tắc theo Khu vực (Region Matching)")
    void testRuleMatching_Region() {
        LeadAssignmentRule rule = new LeadAssignmentRule();
        rule.setRuleId(1);
        rule.setCriterion("REGION");
        rule.setCriterionValue("South");
        rule.setActive(true);

        assertTrue(assignmentService.isRuleMatched(rule, "South", "IT"));
        assertTrue(assignmentService.isRuleMatched(rule, "south", "Finance"), "Phải so khớp không phân biệt hoa thường");
        assertFalse(assignmentService.isRuleMatched(rule, "North", "IT"));
        assertFalse(assignmentService.isRuleMatched(rule, null, "IT"));
    }

    @Test
    @DisplayName("S4-06 AC2: Kiểm tra đối chiếu quy tắc theo Ngành nghề (Industry Matching)")
    void testRuleMatching_Industry() {
        LeadAssignmentRule rule = new LeadAssignmentRule();
        rule.setRuleId(2);
        rule.setCriterion("INDUSTRY");
        rule.setCriterionValue("Technology");
        rule.setActive(true);

        assertTrue(assignmentService.isRuleMatched(rule, "North", "Technology"));
        assertTrue(assignmentService.isRuleMatched(rule, "North", "technology"), "Phải so khớp không phân biệt hoa thường");
        assertFalse(assignmentService.isRuleMatched(rule, "North", "Healthcare"));
        assertFalse(assignmentService.isRuleMatched(rule, "North", null));
    }

    @Test
    @DisplayName("S4-06 AC3: Kiểm tra đối chiếu quy tắc Round-Robin theo Nhóm (Team Matching)")
    void testRuleMatching_RoundRobin() {
        LeadAssignmentRule rule = new LeadAssignmentRule();
        rule.setRuleId(3);
        rule.setCriterion("ROUND_ROBIN");
        rule.setTeamId(10);
        rule.setActive(true);

        assertTrue(assignmentService.isRuleMatched(rule, "Central", "Banking"));

        rule.setTeamId(null);
        assertFalse(assignmentService.isRuleMatched(rule, "Central", "Banking"), "Nếu teamId null thì không hợp lệ");
    }

    @Test
    @DisplayName("S4-06 AC4: Thuật toán Round-Robin khi chưa có ai được gán trước đó")
    void testCalculateNextRoundRobinUser_InitialAssignment() {
        List<Integer> memberIds = Arrays.asList(101, 102, 103);
        Integer nextUser = LeadAssignmentService.calculateNextRoundRobinUser(memberIds, null);

        assertNotNull(nextUser);
        assertEquals(101, nextUser, "Lần đầu tiên phải chọn thành viên đầu tiên trong danh sách");
    }

    @Test
    @DisplayName("S4-06 AC5: Thuật toán Round-Robin xoay vòng tuần tự qua các thành viên")
    void testCalculateNextRoundRobinUser_SequentialRotation() {
        List<Integer> memberIds = Arrays.asList(101, 102, 103);

        Integer user1 = LeadAssignmentService.calculateNextRoundRobinUser(memberIds, 101);
        assertEquals(102, user1, "Sau 101 phải là 102");

        Integer user2 = LeadAssignmentService.calculateNextRoundRobinUser(memberIds, 102);
        assertEquals(103, user2, "Sau 102 phải là 103");

        Integer user3 = LeadAssignmentService.calculateNextRoundRobinUser(memberIds, 103);
        assertEquals(101, user3, "Sau 103 phải quay vòng lại thành viên đầu tiên (101)");
    }

    @Test
    @DisplayName("S4-06 AC6: Thuật toán Round-Robin xử lý khi nhân viên trước đó bị khóa hoặc rời nhóm")
    void testCalculateNextRoundRobinUser_PreviousUserRemoved() {
        List<Integer> activeMembers = Arrays.asList(102, 103, 104); // 101 đã bị khóa/xóa
        Integer nextUser = LeadAssignmentService.calculateNextRoundRobinUser(activeMembers, 101);

        assertNotNull(nextUser);
        assertEquals(102, nextUser, "Nếu lastUserId không còn trong team, phải an toàn reset về thành viên đầu tiên");
    }

    @Test
    @DisplayName("S4-06 AC7: Thuật toán Round-Robin khi nhóm không có thành viên hoạt động")
    void testCalculateNextRoundRobinUser_EmptyTeam() {
        assertNull(LeadAssignmentService.calculateNextRoundRobinUser(new ArrayList<>(), 101));
        assertNull(LeadAssignmentService.calculateNextRoundRobinUser(null, 101));
    }

    @Test
    @DisplayName("S4-06 AC8: Kiểm tra tính hợp lệ của nhân viên (UserEligibilityRecord)")
    void testUserEligibilityRecord() {
        LeadAssignmentRuleDAO.UserEligibilityRecord activeUser =
                new LeadAssignmentRuleDAO.UserEligibilityRecord(10, 1, true, false);
        assertTrue(activeUser.isEligible(), "Nhân viên active và không bị khóa phải hợp lệ");
        assertEquals(1, activeUser.getTeamId());

        LeadAssignmentRuleDAO.UserEligibilityRecord inactiveUser =
                new LeadAssignmentRuleDAO.UserEligibilityRecord(11, 1, false, false);
        assertFalse(inactiveUser.isEligible(), "Nhân viên inactive không được nhận Lead");

        LeadAssignmentRuleDAO.UserEligibilityRecord lockedUser =
                new LeadAssignmentRuleDAO.UserEligibilityRecord(12, 1, true, true);
        assertFalse(lockedUser.isEligible(), "Nhân viên bị lockout không được nhận Lead");
    }

    @Test
    @DisplayName("S4-06 AC9: Xác minh tính năng trích xuất JSON trong LeadAssignServlet")
    void testLeadAssignServlet_ExtractJsonField() {
        String json = "{\"leadId\": \"123\", \"assigneeId\": 456, \"region\": \"South\", \"industry\": \"IT\"}";
        assertEquals("123", com.crm.controller.lead.LeadAssignServlet.extractJsonField(json, "leadId"));
        assertEquals("456", com.crm.controller.lead.LeadAssignServlet.extractJsonField(json, "assigneeId"));
        assertEquals("South", com.crm.controller.lead.LeadAssignServlet.extractJsonField(json, "region"));
        assertEquals("IT", com.crm.controller.lead.LeadAssignServlet.extractJsonField(json, "industry"));
        assertNull(com.crm.controller.lead.LeadAssignServlet.extractJsonField(json, "nonExistent"));
    }
}
