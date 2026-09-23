package com.qlkh.service;

import com.qlkh.entity.MenuItem;
import com.qlkh.entity.Role;
import com.qlkh.entity.User;
import com.qlkh.repository.MenuItemRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MenuServiceTest {

    @Mock
    private MenuItemRepository menuItemRepository;

    @InjectMocks
    private MenuService menuService;

    private User staffUser;
    private MenuItem item1;
    private MenuItem item2;

    @BeforeEach
    void setUp() {
        Role role = new Role();
        role.setId(1L);
        role.setCode("SALES_STAFF");

        staffUser = new User();
        staffUser.setId(100L);
        staffUser.setRole(role);

        item1 = new MenuItem();
        item1.setId(1L);
        item1.setCode("DASHBOARD");
        item1.setName("Trang chủ");
        item1.setOrderIndex(1);

        item2 = new MenuItem();
        item2.setId(2L);
        item2.setCode("CUSTOMER_LIST");
        item2.setName("Danh mục khách hàng");
        item2.setOrderIndex(2);
    }

    @Test
    @DisplayName("S1-06: getMenuForUser returns menu sorted by orderIndex")
    void getMenuForUser_ReturnsSortedMenuItems() {
        when(menuItemRepository.findAllByRoleId(1L)).thenReturn(List.of(item2, item1));

        List<MenuItem> result = menuService.getMenuForUser(staffUser);

        assertEquals(2, result.size());
        assertEquals("DASHBOARD", result.get(0).getCode());
        assertEquals("CUSTOMER_LIST", result.get(1).getCode());
    }

    @Test
    @DisplayName("S1-06: getAllowedMenuCodes returns set of menu codes")
    void getAllowedMenuCodes_ReturnsSetOfCodes() {
        when(menuItemRepository.findAllByRoleId(1L)).thenReturn(List.of(item1, item2));

        Set<String> codes = menuService.getAllowedMenuCodes(staffUser);

        assertEquals(2, codes.size());
        assertTrue(codes.contains("DASHBOARD"));
        assertTrue(codes.contains("CUSTOMER_LIST"));
    }
}
