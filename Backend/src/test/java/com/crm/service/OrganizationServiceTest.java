package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dao.TeamDAO;
import com.crm.model.Account;
import com.crm.model.Team;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class OrganizationServiceTest {

    @Mock
    private TeamDAO teamDAO;

    @Mock
    private AccountDAO accountDAO;

    @InjectMocks
    private OrganizationService organizationService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("STORY S2-06 AC1: Kiểm tra phát hiện vòng lặp trực tiếp (A -> A)")
    void testDirectCycleDetection() throws SQLException {
        boolean isCycle = organizationService.isCircularHierarchy(1, 1);
        assertTrue(isCycle, "Chọn chính mình làm nhóm cha phải phát hiện là vòng lặp");
    }

    @Test
    @DisplayName("STORY S2-06 AC1: Kiểm tra phát hiện vòng lặp đa cấp (A -> B -> C -> A)")
    void testMultiLevelCycleDetection() throws SQLException {
        Team team1 = new Team(1, "Team A", "Desc", null, null, "MB");
        Team team2 = new Team(2, "Team B", "Desc", 1, null, "MB");
        Team team3 = new Team(3, "Team C", "Desc", 2, null, "MB");

        when(teamDAO.findById(1)).thenReturn(team1);
        when(teamDAO.findById(2)).thenReturn(team2);
        when(teamDAO.findById(3)).thenReturn(team3);

        boolean isCycle = organizationService.isCircularHierarchy(1, 3);
        assertTrue(isCycle, "Gán nhóm cha là nhóm con cấp dưới phải phát hiện là vòng lặp");
    }

    @Test
    @DisplayName("STORY S2-06 AC1: Cho phép gán nhóm cha hợp lệ không gây vòng lặp")
    void testValidParentAssignment() throws SQLException {
        Team team1 = new Team(1, "Root", "Desc", null, null, "MB");
        when(teamDAO.findById(1)).thenReturn(team1);

        boolean isCycle = organizationService.isCircularHierarchy(2, 1);
        assertFalse(isCycle, "Gán nhóm cha hợp lệ không được báo vòng lặp");
    }

    @Test
    @DisplayName("STORY S2-06 AC1: Từ chối lưu nhóm khi vi phạm cấu trúc vòng lặp")
    void testSaveTeamRejectsCycle() throws SQLException {
        Team team1 = new Team(1, "Team A", "Desc", 3, null, "MB");
        Team team2 = new Team(2, "Team B", "Desc", 1, null, "MB");
        Team team3 = new Team(3, "Team C", "Desc", 2, null, "MB");

        when(teamDAO.findById(1)).thenReturn(team1);
        when(teamDAO.findById(2)).thenReturn(team2);
        when(teamDAO.findById(3)).thenReturn(team3);

        List<String> errors = new ArrayList<>();
        boolean saved = organizationService.saveOrUpdateTeam(team1, errors);

        assertFalse(saved, "Không được lưu nhóm khi có quan hệ vòng lặp");
        assertTrue(errors.stream().anyMatch(e -> e.contains("vòng lặp")), "Phải thông báo lỗi vòng lặp");
    }

    @Test
    @DisplayName("STORY S2-06 AC2: Chuyển nhân viên từ nhóm nguồn sang nhóm đích cập nhật users.team_id")
    void testTransferUserToTeam() throws SQLException {
        Account user = new Account();
        user.setAccountId(10);
        user.setFullName("User Test");
        user.setTeamId(1);

        Team sourceTeam = new Team(1, "Team A", "Desc", null, 99, "MB");
        Team targetTeam = new Team(2, "Team B", "Desc", null, null, "MN");

        when(accountDAO.getAccountById(10)).thenReturn(user);
        when(teamDAO.findById(1)).thenReturn(sourceTeam);
        when(teamDAO.findById(2)).thenReturn(targetTeam);
        when(accountDAO.updateUserTeam(eq(10), eq(2))).thenReturn(true);

        List<String> errors = new ArrayList<>();
        boolean transferred = organizationService.transferUserToTeam(10, 1, 2, errors);

        assertTrue(transferred, "Chuyển nhóm cho nhân viên hợp lệ phải thành công");
        assertTrue(errors.isEmpty());
    }

    @Test
    @DisplayName("STORY S2-06: Từ chối chuyển nhóm nếu nhân viên không thuộc nhóm nguồn được chọn")
    void testTransferUserRejectsIfNotInSourceTeam() throws SQLException {
        Account user = new Account();
        user.setAccountId(10);
        user.setFullName("User Test");
        user.setTeamId(1); // Belong to Team 1

        Team sourceTeam = new Team(2, "Team B", "Desc", null, null, "MN");
        Team targetTeam = new Team(3, "Team C", "Desc", null, null, "MN");

        when(accountDAO.getAccountById(10)).thenReturn(user);
        when(teamDAO.findById(2)).thenReturn(sourceTeam);
        when(teamDAO.findById(3)).thenReturn(targetTeam);

        List<String> errors = new ArrayList<>();
        boolean transferred = organizationService.transferUserToTeam(10, 2, 3, errors);

        assertFalse(transferred, "Phải từ chối nếu user không thuộc nhóm nguồn");
        assertTrue(errors.stream().anyMatch(e -> e.contains("không thuộc nhóm nguồn")));
    }

    @Test
    @DisplayName("STORY S2-06: Từ chối chuyển Trưởng nhóm sang nhóm khác khi chưa bổ nhiệm mới")
    void testTransferUserRejectsIfUserIsLeaderOfSourceTeam() throws SQLException {
        Account leaderUser = new Account();
        leaderUser.setAccountId(10);
        leaderUser.setFullName("Leader User");
        leaderUser.setTeamId(1);

        Team sourceTeam = new Team(1, "Team A", "Desc", null, 10, "MB"); // Leader is 10
        Team targetTeam = new Team(2, "Team B", "Desc", null, null, "MN");

        when(accountDAO.getAccountById(10)).thenReturn(leaderUser);
        when(teamDAO.findById(1)).thenReturn(sourceTeam);
        when(teamDAO.findById(2)).thenReturn(targetTeam);

        List<String> errors = new ArrayList<>();
        boolean transferred = organizationService.transferUserToTeam(10, 1, 2, errors);

        assertFalse(transferred, "Phải từ chối chuyển Trưởng nhóm sang nhóm khác");
        assertTrue(errors.stream().anyMatch(e -> e.contains("đang là Trưởng nhóm")));
    }

    @Test
    @DisplayName("STORY S2-06: Từ chối gán Trưởng nhóm nếu user đã làm Trưởng nhóm của nhóm khác")
    void testLeaderAssignmentRejectsIfAlreadyLeader() throws SQLException {
        Account leaderAcc = new Account();
        leaderAcc.setAccountId(50);
        leaderAcc.setFullName("Leader User");
        leaderAcc.setRoleCodes(java.util.Collections.singletonList("TEAM_LEAD"));

        Team existingLeadTeam = new Team(1, "Team A", "Desc", null, 50, "MB");
        Team newTeam = new Team(2, "Team B", "Desc", null, 50, "MN");

        when(accountDAO.getAccountById(50)).thenReturn(leaderAcc);
        when(teamDAO.findTeamByLeaderIdExcludingTeamId(50, 2)).thenReturn(existingLeadTeam);

        List<String> errors = new ArrayList<>();
        boolean saved = organizationService.saveOrUpdateTeam(newTeam, errors);

        assertFalse(saved, "Không thể gán 1 user làm Trưởng nhóm của nhiều nhóm");
        assertTrue(errors.stream().anyMatch(e -> e.contains("đã là Trưởng nhóm")));
    }

    @Test
    @DisplayName("STORY S2-06: Chức vụ hợp lệ (TEAM_LEAD, DIRECTOR, ADMIN) được phép làm Leader và cập nhật users.team_id mà KHÔNG đổi role")
    void testLeaderTeamSyncOnSaveWithQualifiedRole() throws SQLException {
        Account leaderAcc = new Account();
        leaderAcc.setAccountId(50);
        leaderAcc.setFullName("Leader User A");
        leaderAcc.setRoleCodes(java.util.Collections.singletonList("TEAM_LEAD"));
        leaderAcc.setRoleNames(java.util.Collections.singletonList("Trưởng nhóm kinh doanh"));

        Team newTeam = new Team(0, "Team Sales New", "Desc", null, 50, "MN");

        when(accountDAO.getAccountById(50)).thenReturn(leaderAcc);
        when(accountDAO.updateUserTeam(anyInt(), any())).thenReturn(true);
        when(teamDAO.findTeamByLeaderIdExcludingTeamId(50, 0)).thenReturn(null);
        when(teamDAO.existsByNameExcludingId("Team Sales New", 0)).thenReturn(false);
        when(teamDAO.insert(any(Team.class))).thenAnswer(invocation -> {
            Team t = invocation.getArgument(0);
            t.setId(99);
            return true;
        });

        List<String> errors = new ArrayList<>();
        boolean saved = organizationService.saveOrUpdateTeam(newTeam, errors);

        assertTrue(saved, "Gán Leader cho user có role hợp lệ phải thành công");
        assertEquals(99, newTeam.getId());
        verify(accountDAO).updateUserTeam(50, 99);
        verify(accountDAO, never()).updateRoleAndTeam(anyInt(), anyList(), anyInt());
    }

    @Test
    @DisplayName("STORY S2-06: Backend từ chối gán Trưởng nhóm nếu user có chức vụ không hợp lệ (SALES_REP)")
    void testLeaderAssignmentRejectsUnqualifiedRole() throws SQLException {
        Account repUser = new Account();
        repUser.setAccountId(60);
        repUser.setFullName("Sales Rep B");
        repUser.setRoleCodes(java.util.Collections.singletonList("SALES_REP"));
        repUser.setRoleNames(java.util.Collections.singletonList("Nhân viên kinh doanh"));

        Team newTeam = new Team(1, "Team Kinh Doanh 1", "Desc", null, 60, "MB");

        when(accountDAO.getAccountById(60)).thenReturn(repUser);
        when(teamDAO.findTeamByLeaderIdExcludingTeamId(60, 1)).thenReturn(null);
        when(teamDAO.existsByNameExcludingId("Team Kinh Doanh 1", 1)).thenReturn(false);

        List<String> errors = new ArrayList<>();
        boolean saved = organizationService.saveOrUpdateTeam(newTeam, errors);

        assertFalse(saved, "Phải từ chối gán Leader cho user có role SALES_REP");
        assertTrue(errors.stream().anyMatch(e -> e.contains("không có quyền làm Trưởng nhóm")), 
                "Phải trả thông báo lỗi rõ ràng khi user không đủ điều kiện làm Leader");
        verify(teamDAO, never()).update(any(Team.class));
        verify(accountDAO, never()).updateUserTeam(anyInt(), any());
    }

    @Test
    @DisplayName("STORY S2-06: Lọc đúng danh sách ứng viên Leader từ Database")
    void testGetLeaderCandidateUsers() {
        Account userA = new Account();
        userA.setAccountId(1);
        userA.setFullName("User A");
        userA.setRoleCodes(java.util.Collections.singletonList("TEAM_LEAD"));

        Account userB = new Account();
        userB.setAccountId(2);
        userB.setFullName("User B");
        userB.setRoleCodes(java.util.Collections.singletonList("SALES_REP"));

        List<Account> activeUsers = new ArrayList<>();
        activeUsers.add(userA);
        activeUsers.add(userB);

        when(accountDAO.getAllActiveAccounts()).thenReturn(activeUsers);

        List<Account> candidates = organizationService.getLeaderCandidateUsers();

        assertEquals(1, candidates.size());
        assertEquals("User A", candidates.get(0).getFullName());
    }
}
