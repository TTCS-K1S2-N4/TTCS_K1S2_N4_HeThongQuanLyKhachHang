package com.qlkh.service;

import com.qlkh.entity.DataScope;
import com.qlkh.entity.Role;
import com.qlkh.entity.Team;
import com.qlkh.entity.User;
import com.qlkh.repository.TeamRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PermissionServiceTest {

    @Mock
    private TeamRepository teamRepository;

    @InjectMocks
    private PermissionService permissionService;

    private User adminUser;
    private User teamLeaderUser;
    private User salesStaffUser;
    private Team parentTeam;
    private Team childTeam;

    @BeforeEach
    void setUp() {
        // Role ALL (Admin / Director)
        Role adminRole = new Role();
        adminRole.setId(1L);
        adminRole.setCode("ADMIN");
        adminRole.setDataScope(DataScope.ALL);

        adminUser = new User();
        adminUser.setId(100L);
        adminUser.setRole(adminRole);

        // Teams hierarchy
        parentTeam = new Team();
        parentTeam.setId(10L);
        parentTeam.setName("Sales Region 1");

        childTeam = new Team();
        childTeam.setId(20L);
        childTeam.setName("Sales Team A");
        childTeam.setParent(parentTeam);

        // Role TEAM (Leader)
        Role leaderRole = new Role();
        leaderRole.setId(2L);
        leaderRole.setCode("TEAM_LEADER");
        leaderRole.setDataScope(DataScope.TEAM);

        teamLeaderUser = new User();
        teamLeaderUser.setId(200L);
        teamLeaderUser.setRole(leaderRole);
        teamLeaderUser.setTeam(parentTeam);

        // Role MY (Staff)
        Role staffRole = new Role();
        staffRole.setId(3L);
        staffRole.setCode("SALES_STAFF");
        staffRole.setDataScope(DataScope.MY);

        salesStaffUser = new User();
        salesStaffUser.setId(300L);
        salesStaffUser.setRole(staffRole);
        salesStaffUser.setTeam(childTeam);
    }

    @Test
    @DisplayName("S1-05: DataScope.ALL returns all() filter")
    void resolveDataScope_ScopeALL_ReturnsAllFilter() {
        PermissionService.DataScopeFilter filter = permissionService.resolveDataScope(adminUser);

        assertTrue(filter.isAll());
        assertFalse(filter.isByOwner());
        assertFalse(filter.isByTeam());
    }

    @Test
    @DisplayName("S1-05: DataScope.MY returns filter by owner user id")
    void resolveDataScope_ScopeMY_ReturnsOwnerIdFilter() {
        PermissionService.DataScopeFilter filter = permissionService.resolveDataScope(salesStaffUser);

        assertFalse(filter.isAll());
        assertTrue(filter.isByOwner());
        assertEquals(List.of(300L), filter.getOwnerUserIds());
    }

    @Test
    @DisplayName("S1-05: DataScope.TEAM resolves current team and recursively child teams")
    void resolveDataScope_ScopeTEAM_ReturnsRecursiveTeamIds() {
        when(teamRepository.findByParentId(10L)).thenReturn(List.of(childTeam));
        when(teamRepository.findByParentId(20L)).thenReturn(Collections.emptyList());

        PermissionService.DataScopeFilter filter = permissionService.resolveDataScope(teamLeaderUser);

        assertFalse(filter.isAll());
        assertTrue(filter.isByTeam());
        assertEquals(List.of(10L, 20L), filter.getTeamIds());
        verify(teamRepository, times(1)).findByParentId(10L);
        verify(teamRepository, times(1)).findByParentId(20L);
    }

    @Test
    @DisplayName("S1-05: DataScope.TEAM with no team fallback to owner filter")
    void resolveDataScope_ScopeTEAM_NoTeam_FallbackToOwner() {
        Role leaderRole = new Role();
        leaderRole.setDataScope(DataScope.TEAM);

        User userNoTeam = new User();
        userNoTeam.setId(250L);
        userNoTeam.setRole(leaderRole);
        userNoTeam.setTeam(null);

        PermissionService.DataScopeFilter filter = permissionService.resolveDataScope(userNoTeam);

        assertFalse(filter.isAll());
        assertTrue(filter.isByOwner());
        assertEquals(List.of(250L), filter.getOwnerUserIds());
    }

    @Test
    @DisplayName("S1-06: Check menu code permission helper")
    void hasMenuAccess_ChecksAllowedList() {
        List<String> allowed = List.of("DASHBOARD", "CUSTOMER_LIST");

        assertTrue(permissionService.hasMenuAccess(salesStaffUser, "DASHBOARD", allowed));
        assertFalse(permissionService.hasMenuAccess(salesStaffUser, "USER_MGMT", allowed));
    }
}
