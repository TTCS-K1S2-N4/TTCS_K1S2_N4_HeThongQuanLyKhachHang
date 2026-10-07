package com.crm.service;

import com.crm.dao.ActivityDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.Customer360Response;
import com.crm.exception.AuthorizationException;
import com.crm.model.Activity;
import com.crm.model.Customer;
import com.crm.model.Opportunity;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class Customer360ServiceTest {

    private CustomerDAO customerDAO;
    private OpportunityDAO opportunityDAO;
    private ActivityDAO activityDAO;
    private PermissionService permissionService;
    private Customer360Service customer360Service;

    @BeforeEach
    public void setUp() {
        customerDAO = mock(CustomerDAO.class);
        opportunityDAO = mock(OpportunityDAO.class);
        activityDAO = mock(ActivityDAO.class);
        permissionService = mock(PermissionService.class);
        customer360Service = new Customer360Service(customerDAO, opportunityDAO, activityDAO, permissionService);
    }

    @Test
    public void testGetCustomer360Success() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setCustomerName("FPT Global");
        c.setOwnerId(4);

        Opportunity opp1 = new Opportunity();
        opp1.setOpportunityId(201);
        opp1.setAmount(100000.0);
        opp1.setStage("QUALIFICATION");

        Activity act1 = new Activity();
        act1.setActivityId(301);
        act1.setTitle("Meeting with CEO");

        when(customerDAO.findById(101)).thenReturn(c);
        when(opportunityDAO.getOpenOpportunitiesByCustomerId(101)).thenReturn(Collections.singletonList(opp1));
        when(opportunityDAO.getClosedOpportunitiesByCustomerId(101)).thenReturn(Collections.emptyList());
        when(opportunityDAO.calculateTotalOpenAmount(101)).thenReturn(100000.0);
        when(activityDAO.getActivitiesByCustomerId(101, 1, 10)).thenReturn(Collections.singletonList(act1));
        when(activityDAO.countByCustomerId(101)).thenReturn(1);

        Customer360Response res = customer360Service.getCustomer360(101, 4, Collections.singletonList(1));

        assertNotNull(res);
        assertEquals("FPT Global", res.getCustomer().getCustomerName());
        assertEquals(100000.0, res.getTotalOpenOpportunityValue());
        assertEquals(1, res.getOpenOpportunities().size());
        assertEquals(1, res.getActivities().size());

        verify(permissionService).validateDataAccessForRoles(eq(4), org.mockito.ArgumentMatchers.<List<Integer>>any(), eq("ACCOUNT"), eq(4));
    }

    @Test
    public void testGetCustomer360UnauthorizedThrowsException() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(5); // Owned by user 5

        when(customerDAO.findById(101)).thenReturn(c);
        doThrow(new AuthorizationException("Bạn không có quyền xem dữ liệu này."))
                .when(permissionService).validateDataAccessForRoles(eq(4), org.mockito.ArgumentMatchers.<List<Integer>>any(), eq("ACCOUNT"), eq(5));

        assertThrows(AuthorizationException.class, () -> {
            customer360Service.getCustomer360(101, 4, Collections.singletonList(1));
        });
    }

    @Test
    public void testGetCustomerTimelinePagination() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);

        Activity act1 = new Activity();
        act1.setActivityId(301);

        when(customerDAO.findById(101)).thenReturn(c);
        when(activityDAO.getActivitiesByCustomerId(101, 2, 20)).thenReturn(Collections.singletonList(act1));

        List<Activity> list = customer360Service.getCustomerTimeline(101, 2, 20, 4, Collections.singletonList(1));

        assertNotNull(list);
        assertEquals(1, list.size());
        assertEquals(301, list.get(0).getActivityId());
    }

    @Test
    public void testPerformanceWith500Activities() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setOwnerId(4);
        when(customerDAO.findById(101)).thenReturn(c);

        List<Activity> mock500List = new java.util.ArrayList<>();
        for (int i = 1; i <= 500; i++) {
            Activity act = new Activity();
            act.setActivityId(i);
            act.setTitle("Activity " + i);
            act.setCustomerId(101);
            mock500List.add(act);
        }

        when(activityDAO.getActivitiesByCustomerId(eq(101), anyInt(), anyInt())).thenReturn(mock500List.subList(0, 10));
        when(activityDAO.countByCustomerId(101)).thenReturn(500);

        long start = System.currentTimeMillis();
        Customer360Response res = customer360Service.getCustomer360(101, 4, Collections.singletonList(1));
        long duration = System.currentTimeMillis() - start;

        assertNotNull(res);
        assertEquals(500, res.getTotalActivities());
        assertTrue(duration < 1500, "Performance test failed: took " + duration + " ms (limit 1500 ms)");
    }
}
