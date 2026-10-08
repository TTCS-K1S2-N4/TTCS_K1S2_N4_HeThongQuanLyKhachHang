package com.crm.service;

import com.crm.dao.CustomerCareDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dto.CustomerCareResponse;
import com.crm.exception.ValidationException;
import com.crm.model.Customer;
import com.crm.model.CustomerCareState;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Timestamp;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class CustomerCareServiceTest {

    private CustomerCareService careService;
    private CustomerCareDAO mockCareDAO;
    private CustomerDAO mockCustomerDAO;
    private PermissionService mockPermissionService;

    @BeforeEach
    public void setUp() {
        careService = new CustomerCareService();
        mockCareDAO = mock(CustomerCareDAO.class);
        mockCustomerDAO = mock(CustomerDAO.class);
        mockPermissionService = mock(PermissionService.class);

        careService.setCustomerCareDAO(mockCareDAO);
        careService.setCustomerDAO(mockCustomerDAO);
        careService.setPermissionService(mockPermissionService);
    }

    @Test
    public void testGetInactiveCustomers_ReturnsListSorted() {
        when(mockCareDAO.getInactiveThreshold()).thenReturn(30);
        when(mockPermissionService.getAccessibleAccountIdsForRoles(1, Collections.singletonList(1), "ACCOUNT")).thenReturn(Collections.singletonList(4));

        CustomerCareResponse r1 = new CustomerCareResponse();
        r1.setCustomerId(101);
        r1.setContractValue(1000000.0);
        r1.setDaysInactive(45);

        when(mockCareDAO.findInactiveCustomers(30, Collections.singletonList(4), 1, 20))
                .thenReturn(Collections.singletonList(r1));

        List<CustomerCareResponse> result = careService.getInactiveCustomers(30, 1, 20, 1, Collections.singletonList(1));
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(101, result.get(0).getCustomerId());
        assertEquals(1000000.0, result.get(0).getContractValue());
    }

    @Test
    public void testMarkContacted_Success() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        when(mockCustomerDAO.findById(101)).thenReturn(c);
        when(mockCareDAO.recordContacted(101, 1, "Ghi chú liên hệ")).thenReturn(true);

        CustomerCareState state = new CustomerCareState();
        state.setCustomerId(101);
        state.setLastContactedAt(new Timestamp(System.currentTimeMillis()));

        when(mockCareDAO.findByCustomerId(101)).thenReturn(state);

        CustomerCareState res = careService.markContacted(101, "Ghi chú liên hệ", 1, Collections.singletonList(1));
        assertNotNull(res);
        assertEquals(101, res.getCustomerId());
        verify(mockPermissionService).validateDataAccessForRoles(1, Collections.singletonList(1), "ACCOUNT", 4);
    }

    @Test
    public void testUpdateConfiguredInactiveDays_Invalid_ThrowsValidationException() {
        assertThrows(ValidationException.class, () -> {
            careService.updateConfiguredInactiveDays(0, 1, Collections.singletonList(1));
        });
    }
}
