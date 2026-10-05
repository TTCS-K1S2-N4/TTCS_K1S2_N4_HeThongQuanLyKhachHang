package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dao.SavedFilterDAO;
import com.crm.dto.CustomerFilterRequest;
import com.crm.model.Customer;
import com.crm.model.SavedFilter;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class CustomerFilterServiceTest {

    private CustomerDAO customerDAO;
    private SavedFilterDAO savedFilterDAO;
    private PermissionService permissionService;
    private CustomerFilterService filterService;

    @BeforeEach
    public void setUp() {
        customerDAO = mock(CustomerDAO.class);
        savedFilterDAO = mock(SavedFilterDAO.class);
        permissionService = mock(PermissionService.class);
        filterService = new CustomerFilterService(customerDAO, savedFilterDAO, permissionService);
    }

    @Test
    public void testFilterCustomersWithDataScopeMy() {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setKeyword("FPT");
        req.setStatus("ACTIVE");

        Customer c = new Customer();
        c.setCustomerId(101);
        c.setCustomerName("FPT Global");
        c.setOwnerId(4);

        // Scope MY returns accessible owner ID = [4]
        when(permissionService.getAccessibleAccountIdsForRoles(eq(4), anyList(), eq("ACCOUNT")))
                .thenReturn(Collections.singletonList(4));
        when(customerDAO.getList(eq(req), eq(Collections.singletonList(4))))
                .thenReturn(Collections.singletonList(c));

        List<Customer> result = filterService.filterCustomers(req, 4, Collections.singletonList(1));

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("FPT Global", result.get(0).getCustomerName());
    }

    @Test
    public void testFilterCustomersRequestedOwnerOutsideScopeReturnsEmpty() {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setOwnerId(5); // Requesting owner 5

        // User 4 only has access to owner [4]
        when(permissionService.getAccessibleAccountIdsForRoles(eq(4), anyList(), eq("ACCOUNT")))
                .thenReturn(Collections.singletonList(4));
        when(customerDAO.getList(eq(req), eq(Collections.emptyList())))
                .thenReturn(Collections.emptyList());

        List<Customer> result = filterService.filterCustomers(req, 4, Collections.singletonList(1));

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    public void testSaveAndRetrieveSavedFilters() {
        SavedFilter filter = new SavedFilter();
        filter.setFilterName("Active IT Companies");
        filter.setIndustry("IT");

        when(savedFilterDAO.createSavedFilter(any(SavedFilter.class))).thenReturn(true);
        when(savedFilterDAO.getSavedFiltersByUserId(4)).thenReturn(Collections.singletonList(filter));

        boolean saved = filterService.saveFilter(filter, 4);
        assertTrue(saved);

        List<SavedFilter> list = filterService.getSavedFilters(4);
        assertNotNull(list);
        assertEquals(1, list.size());
        assertEquals("Active IT Companies", list.get(0).getFilterName());
    }
}
