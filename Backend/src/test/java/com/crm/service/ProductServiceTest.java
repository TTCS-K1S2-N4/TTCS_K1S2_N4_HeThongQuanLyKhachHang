package com.crm.service;

import com.crm.model.Account;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class ProductServiceTest {

    private ProductService productService;
    private PermissionService permissionService;

    @BeforeEach
    public void setUp() {
        productService = new ProductService();
        permissionService = mock(PermissionService.class);
        productService.setPermissionService(permissionService);
    }

    @Test
    public void testCanManageProducts_WithProductManagePermission_ShouldReturnTrue() {
        Account user = new Account();
        List<Integer> roles = Collections.singletonList(2);
        user.setRoleIds(roles);

        when(permissionService.hasPermissionForRoles(roles, "PRODUCT_MANAGE")).thenReturn(true);

        boolean result = productService.canManageProducts(user);

        assertTrue(result);
        verify(permissionService, times(1)).hasPermissionForRoles(roles, "PRODUCT_MANAGE");
    }

    @Test
    public void testCanManageProducts_WithoutProductManagePermission_ShouldReturnFalse() {
        Account user = new Account();
        List<Integer> roles = Collections.singletonList(5);
        user.setRoleIds(roles);

        when(permissionService.hasPermissionForRoles(roles, "PRODUCT_MANAGE")).thenReturn(false);

        boolean result = productService.canManageProducts(user);

        assertFalse(result);
        verify(permissionService, times(1)).hasPermissionForRoles(roles, "PRODUCT_MANAGE");
    }

    @Test
    public void testIsCostPriceAllowed_ForDirector_ShouldReturnTrue() {
        Account user = new Account();
        user.setRoleCodes(Collections.singletonList("DIRECTOR"));

        boolean result = productService.isCostPriceAllowed(user);

        assertTrue(result);
    }

    @Test
    public void testIsCostPriceAllowed_ForSalesRep_ShouldReturnFalse() {
        Account user = new Account();
        user.setRoleCodes(Collections.singletonList("SALES_REP"));

        boolean result = productService.isCostPriceAllowed(user);

        assertFalse(result);
    }

    @Test
    public void testValidateProduct_FloorPriceGreaterThanListPrice_ShouldThrowException() {
        com.crm.dto.ProductRequest request = new com.crm.dto.ProductRequest();
        request.setProductCode("SP001");
        request.setProductName("Sản phẩm 001");
        request.setProductType("ONE_TIME");
        request.setUnit("Cái");
        request.setListPrice(new java.math.BigDecimal("100"));
        request.setFloorPrice(new java.math.BigDecimal("150"));

        Account user = new Account();
        user.setRoleIds(Collections.singletonList(1));
        when(permissionService.hasPermissionForRoles(user.getRoleIds(), "PRODUCT_MANAGE")).thenReturn(true);

        assertThrows(com.crm.exception.ValidationException.class, () -> {
            productService.createProduct(request, user);
        });
    }
}
