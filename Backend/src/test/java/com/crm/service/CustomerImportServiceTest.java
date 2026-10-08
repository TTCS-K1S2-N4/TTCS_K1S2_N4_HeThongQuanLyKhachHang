package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dto.CustomerImportRequest;
import com.crm.model.Customer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class CustomerImportServiceTest {

    private CustomerDAO customerDAO;
    private CustomerImportService service;

    @BeforeEach
    void setUp() {
        customerDAO = mock(CustomerDAO.class);
        service = new CustomerImportService(customerDAO);
    }

    @Test
    void testValidatePreview_ValidAndDuplicate() {
        List<CustomerImportRequest> rows = new ArrayList<>();

        CustomerImportRequest r1 = new CustomerImportRequest();
        r1.setRowIndex(2);
        r1.setCustomerName("Công ty Alpha");
        r1.setPhone("0912345678");
        r1.setTaxCode("010111222");
        rows.add(r1);

        CustomerImportRequest r2 = new CustomerImportRequest();
        r2.setRowIndex(3);
        r2.setCustomerName("Công ty Beta");
        r2.setPhone("0912345678"); // Duplicate phone in file
        r2.setTaxCode("010333444");
        rows.add(r2);

        when(customerDAO.findDuplicateCustomer(anyString(), anyString(), anyString())).thenReturn(null);

        Map<String, Object> result = service.validatePreview(rows, 1, Collections.singletonList(1));

        assertEquals(2, result.get("totalRows"));
        assertEquals(1, result.get("validRowsCount"));
        assertEquals(1, result.get("invalidRowsCount"));

        @SuppressWarnings("unchecked")
        List<CustomerImportRequest> duplicates = (List<CustomerImportRequest>) result.get("duplicates");
        assertEquals(1, duplicates.size());
        assertTrue(duplicates.get(0).getDuplicateReason().contains("Số điện thoại trùng lặp"));
    }

    @Test
    void testExecuteImport_SkipDuplicate() {
        List<CustomerImportRequest> rows = new ArrayList<>();

        CustomerImportRequest r1 = new CustomerImportRequest();
        r1.setRowIndex(2);
        r1.setCustomerName("Công ty Alpha");
        r1.setPhone("0912345678");
        r1.setTaxCode("010111222");
        r1.setDuplicate(true);
        r1.setExistingCustomerId(50);
        rows.add(r1);

        Customer existing = new Customer();
        existing.setCustomerId(50);
        existing.setCustomerName("Công ty Alpha Gốc");
        existing.setOwnerId(1);

        when(customerDAO.findById(50)).thenReturn(existing);
        try {
            when(customerDAO.findById(any(), eq(50))).thenReturn(existing);
        } catch (Exception ignored) {}

        Map<String, Object> result = service.executeImport(rows, "SKIP", 1, Collections.singletonList(1));

        assertEquals(1, result.get("totalRows"));
        assertEquals(0, result.get("successCount"));
        assertEquals(1, result.get("skippedCount"));

        verify(customerDAO, never()).updateCustomer(any(Customer.class));
        verify(customerDAO, never()).insertCustomer(any(Customer.class));
    }

    @Test
    void testExecuteImport_UpdateDuplicate() {
        List<CustomerImportRequest> rows = new ArrayList<>();

        CustomerImportRequest r1 = new CustomerImportRequest();
        r1.setRowIndex(2);
        r1.setCustomerName("Công ty Alpha Updated");
        r1.setPhone("0912345678");
        r1.setTaxCode("010111222");
        r1.setDuplicate(true);
        r1.setExistingCustomerId(50);
        rows.add(r1);

        Customer existing = new Customer();
        existing.setCustomerId(50);
        existing.setCustomerName("Công ty Alpha Gốc");
        existing.setOwnerId(1);

        when(customerDAO.findById(50)).thenReturn(existing);
        when(customerDAO.updateCustomer(any(Customer.class))).thenReturn(true);
        try {
            when(customerDAO.findById(any(), eq(50))).thenReturn(existing);
            when(customerDAO.updateCustomer(any(), any(Customer.class))).thenReturn(true);
        } catch (Exception ignored) {}

        Map<String, Object> result = service.executeImport(rows, "UPDATE", 1, Collections.singletonList(1));

        assertEquals(1, result.get("totalRows"));
        assertEquals(1, result.get("successCount"));
        assertEquals(0, result.get("skippedCount"));
    }
}
