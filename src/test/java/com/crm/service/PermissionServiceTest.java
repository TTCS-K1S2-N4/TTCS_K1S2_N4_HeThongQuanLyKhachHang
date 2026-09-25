package com.crm.service;

import com.crm.dao.PermissionDAO;
import com.crm.exception.AuthorizationException;
import com.crm.model.DataScope;
import com.crm.model.MenuItem;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Unit Test chứng minh các tiêu chí chấp nhận (Acceptance Criteria) cho User Story S1-05 & S1-06.
 * Đặc biệt kiểm tra test case cốt lõi: Nhân viên A KHÔNG THỂ đọc dữ liệu của Nhân viên B khi DataScope = MY.
 */
class PermissionServiceTest {

    @Mock
    private PermissionDAO permissionDAO;

    @InjectMocks
    private PermissionService permissionService;

    // Khai báo các hằng số test case
    private static final int ROLE_EMPLOYEE = 1;     // Vai trò Nhân viên Kinh doanh (DataScope = MY)
    private static final int ROLE_TEAM_LEAD = 2;   // Vai trò Trưởng nhóm (DataScope = TEAM)
    private static final int ROLE_DIRECTOR = 3;    // Vai trò Giám đốc (DataScope = ALL)

    private static final int USER_A_ID = 101; // Nhân viên A (Team 1)
    private static final int USER_B_ID = 102; // Nhân viên B (Team 1)
    private static final int USER_C_ID = 301; // Nhân viên C (Team 2)
    private static final int TEAM_LEAD_ID = 201; // Trưởng nhóm (Team 1)

    private static final String MODULE_ACCOUNT = "ACCOUNT";
    private static final String MODULE_DEAL = "DEAL";

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        // Giả lập DataScope cho các Role
        when(permissionDAO.findDataScopeByRoleAndModule(ROLE_EMPLOYEE, MODULE_ACCOUNT)).thenReturn(DataScope.MY);
        when(permissionDAO.findDataScopeByRoleAndModule(ROLE_EMPLOYEE, MODULE_DEAL)).thenReturn(DataScope.MY);

        when(permissionDAO.findDataScopeByRoleAndModule(ROLE_TEAM_LEAD, MODULE_ACCOUNT)).thenReturn(DataScope.TEAM);
        when(permissionDAO.findDataScopeByRoleAndModule(ROLE_DIRECTOR, MODULE_ACCOUNT)).thenReturn(DataScope.ALL);

        // Giả lập thành viên thuộc Team 1 (gồm User A, User B, Team Lead)
        when(permissionDAO.findTeamMemberUserIdsByUserId(USER_A_ID))
                .thenReturn(Arrays.asList(USER_A_ID, USER_B_ID, TEAM_LEAD_ID));
        when(permissionDAO.findTeamMemberUserIdsByUserId(TEAM_LEAD_ID))
                .thenReturn(Arrays.asList(USER_A_ID, USER_B_ID, TEAM_LEAD_ID));

        // Giả lập thành viên thuộc Team 2 (chỉ có User C)
        when(permissionDAO.findTeamMemberUserIdsByUserId(USER_C_ID))
                .thenReturn(Arrays.asList(USER_C_ID));
    }

    @Test
    @DisplayName("S1-05 AC4: Nhân viên A KHÔNG THỂ đọc dữ liệu của Nhân viên B khi DataScope = MY")
    void testEmployeeACannotAccessEmployeeBDataWhenScopeIsMy() {
        // ACT: Kiểm tra quyền xem bản ghi của B bởi A
        boolean canAccess = permissionService.canAccessData(USER_A_ID, ROLE_EMPLOYEE, MODULE_ACCOUNT, USER_B_ID);

        // ASSERT: Phải trả về false
        assertFalse(canAccess, "Nhân viên A không được xem bản ghi của nhân viên B khi scope = MY");

        // ACT & ASSERT: Kiểm tra ném ngoại lệ AuthorizationException với thông báo tiếng Việt
        AuthorizationException exception = assertThrows(AuthorizationException.class, () -> {
            permissionService.validateDataAccess(USER_A_ID, ROLE_EMPLOYEE, MODULE_ACCOUNT, USER_B_ID);
        });

        assertEquals("Bạn không có quyền xem hoặc thao tác trên dữ liệu này.", exception.getMessage());
    }

    @Test
    @DisplayName("S1-05: Nhân viên A ĐƯỢC PHÉP đọc dữ liệu của chính mình khi DataScope = MY")
    void testEmployeeACanAccessOwnDataWhenScopeIsMy() {
        // ACT
        boolean canAccess = permissionService.canAccessData(USER_A_ID, ROLE_EMPLOYEE, MODULE_ACCOUNT, USER_A_ID);

        // ASSERT
        assertTrue(canAccess, "Nhân viên A phải đọc được dữ liệu do chính mình sở hữu");
        assertDoesNotThrow(() -> permissionService.validateDataAccess(USER_A_ID, ROLE_EMPLOYEE, MODULE_ACCOUNT, USER_A_ID));
    }

    @Test
    @DisplayName("S1-05: Trưởng nhóm ĐƯỢC xem dữ liệu của thành viên cùng nhóm, KHÔNG xem được khác nhóm khi Scope = TEAM")
    void testTeamLeaderAccessInTeamScope() {
        // Trưởng nhóm xem dữ liệu của Nhân viên A (cùng Team 1) -> ĐƯỢC PHÉP
        boolean canAccessSameTeam = permissionService.canAccessData(TEAM_LEAD_ID, ROLE_TEAM_LEAD, MODULE_ACCOUNT, USER_A_ID);
        assertTrue(canAccessSameTeam, "Trưởng nhóm phải đọc được dữ liệu của thành viên cùng team");

        // Trưởng nhóm xem dữ liệu của Nhân viên C (Team 2) -> KHÔNG ĐƯỢC PHÉP
        boolean canAccessOtherTeam = permissionService.canAccessData(TEAM_LEAD_ID, ROLE_TEAM_LEAD, MODULE_ACCOUNT, USER_C_ID);
        assertFalse(canAccessOtherTeam, "Trưởng nhóm không được xem dữ liệu của thành viên thuộc team khác");
    }

    @Test
    @DisplayName("S1-05: Giám đốc ĐƯỢC xem tất cả dữ liệu bất kể người sở hữu khi Scope = ALL")
    void testDirectorCanAccessAllData() {
        assertTrue(permissionService.canAccessData(1, ROLE_DIRECTOR, MODULE_ACCOUNT, USER_A_ID));
        assertTrue(permissionService.canAccessData(1, ROLE_DIRECTOR, MODULE_ACCOUNT, USER_B_ID));
        assertTrue(permissionService.canAccessData(1, ROLE_DIRECTOR, MODULE_ACCOUNT, USER_C_ID));
    }

    @Test
    @DisplayName("S1-05: getAccessibleAccountIds trả về danh sách lọc tương ứng theo scope")
    void testGetAccessibleAccountIdsByScope() {
        // Scope MY -> Chỉ chứa ID của chính mình
        List<Integer> myAccessibleIds = permissionService.getAccessibleAccountIds(USER_A_ID, ROLE_EMPLOYEE, MODULE_ACCOUNT);
        assertEquals(1, myAccessibleIds.size());
        assertTrue(myAccessibleIds.contains(USER_A_ID));

        // Scope TEAM -> Chứa tất cả ID trong team
        List<Integer> teamAccessibleIds = permissionService.getAccessibleAccountIds(TEAM_LEAD_ID, ROLE_TEAM_LEAD, MODULE_ACCOUNT);
        assertEquals(3, teamAccessibleIds.size());
        assertTrue(teamAccessibleIds.containsAll(Arrays.asList(USER_A_ID, USER_B_ID, TEAM_LEAD_ID)));

        // Scope ALL -> Trả về danh sách trống biểu thị không cần thêm điều kiện lọc owner_id
        List<Integer> allAccessibleIds = permissionService.getAccessibleAccountIds(1, ROLE_DIRECTOR, MODULE_ACCOUNT);
        assertTrue(allAccessibleIds.isEmpty());
    }

    @Test
    @DisplayName("S1-06: getMenuByRole trả về danh sách menu được phép")
    void testGetMenuByRole() {
        MenuItem m1 = new MenuItem(1, "Khách hàng", "/accounts", "fa-users", "ACCOUNT_VIEW", 1, 0);
        MenuItem m2 = new MenuItem(2, "Cơ hội", "/deals", "fa-chart-line", "DEAL_VIEW", 2, 0);

        when(permissionDAO.findMenuItemsByRoleId(ROLE_EMPLOYEE)).thenReturn(Arrays.asList(m1, m2));

        List<MenuItem> menu = permissionService.getMenuByRole(ROLE_EMPLOYEE);
        assertEquals(2, menu.size());
        assertEquals("Khách hàng", menu.get(0).getTitle());
        assertEquals("Cơ hội", menu.get(1).getTitle());
    }
}
