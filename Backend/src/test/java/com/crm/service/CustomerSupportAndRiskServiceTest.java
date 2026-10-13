package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.CustomerRiskDAO;
import com.crm.dao.SupportRequestDAO;
import com.crm.dto.SupportRequestDto;
import com.crm.exception.ValidationException;
import com.crm.model.Account;
import com.crm.model.Customer;
import com.crm.model.CustomerRisk;
import com.crm.model.SupportRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class CustomerSupportAndRiskServiceTest {

    private SupportRequestDAO supportRequestDAO;
    private CustomerDAO customerDAO;
    private AccountDAO accountDAO;
    private PermissionService permissionService;
    private CustomerSupportService supportService;

    private CustomerRiskDAO customerRiskDAO;
    private CustomerRiskService riskService;

    @BeforeEach
    public void setUp() {
        supportRequestDAO = mock(SupportRequestDAO.class);
        customerDAO = mock(CustomerDAO.class);
        accountDAO = mock(AccountDAO.class);
        permissionService = mock(PermissionService.class);

        supportService = new CustomerSupportService();
        supportService.setSupportRequestDAO(supportRequestDAO);
        supportService.setCustomerDAO(customerDAO);
        supportService.setAccountDAO(accountDAO);
        supportService.setPermissionService(permissionService);

        customerRiskDAO = mock(CustomerRiskDAO.class);
        riskService = new CustomerRiskService();
        riskService.setCustomerRiskDAO(customerRiskDAO);
        riskService.setCustomerDAO(customerDAO);
        riskService.setPermissionService(permissionService);
    }

    @Test
    public void testCreateSupportRequestSuccess() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        Account assignee = new Account();
        assignee.setAccountId(4);
        assignee.setFullName("Nguyễn Văn Sales");

        when(customerDAO.findById(101)).thenReturn(c);
        when(accountDAO.getAccountById(4)).thenReturn(assignee);
        when(supportRequestDAO.insert(any(SupportRequest.class))).thenReturn(1);

        SupportRequestDto dto = new SupportRequestDto();
        dto.setCustomerId(101);
        dto.setTitle("Lỗi kết nối API thanh toán");
        dto.setDescription("Khách hàng báo cổng thanh toán bị timeout");
        dto.setPriority("HIGH");
        dto.setStatus("OPEN");
        dto.setAssigneeId(4);

        SupportRequestDto result = supportService.createSupportRequest(dto, 4, Collections.singletonList(1));

        assertNotNull(result);
        assertEquals(1, result.getRequestId());
        assertEquals("HIGH", result.getPriority());
        assertEquals("OPEN", result.getStatus());
        assertEquals(4, result.getAssigneeId());
    }

    @Test
    public void testCreateSupportRequestInvalidPriorityThrowsException() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        when(customerDAO.findById(101)).thenReturn(c);

        SupportRequestDto dto = new SupportRequestDto();
        dto.setCustomerId(101);
        dto.setTitle("Lỗi ngẫu nhiên");
        dto.setPriority("INVALID_PRIORITY");

        assertThrows(ValidationException.class, () -> {
            supportService.createSupportRequest(dto, 4, Collections.singletonList(1));
        });
    }

    @Test
    public void testGetCustomerRiskLow() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        when(customerDAO.findById(101)).thenReturn(c);

        CustomerRisk lowRisk = new CustomerRisk(101, false, "Bình thường", 1, 3);
        when(customerRiskDAO.calculateRisk(101, 3)).thenReturn(lowRisk);

        CustomerRisk risk = riskService.getCustomerRisk(101, 4, Collections.singletonList(1));

        assertNotNull(risk);
        assertFalse(risk.isRiskFlag());
    }

    @Test
    public void testGetCustomerRiskHighWhenPendingTicketsReachThreshold() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        when(customerDAO.findById(101)).thenReturn(c);

        CustomerRisk highRisk = new CustomerRisk(101, true, "Tồn đọng 3 vé", 3, 3);
        when(customerRiskDAO.calculateRisk(101, 3)).thenReturn(highRisk);

        CustomerRisk risk = riskService.getCustomerRisk(101, 4, Collections.singletonList(1));

        assertNotNull(risk);
        assertTrue(risk.isRiskFlag());
        assertEquals(3, risk.getPendingTicketCount());
    }

    @Test
    public void testGetCustomerRiskHighWhenUrgentTicketPresent() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        when(customerDAO.findById(101)).thenReturn(c);

        CustomerRisk urgentRisk = new CustomerRisk(101, true, "Có vé URGENT chưa giải quyết", 1, 3);
        when(customerRiskDAO.calculateRisk(101, 3)).thenReturn(urgentRisk);

        CustomerRisk risk = riskService.getCustomerRisk(101, 4, Collections.singletonList(1));

        assertNotNull(risk);
        assertTrue(risk.isRiskFlag());
    }
}
