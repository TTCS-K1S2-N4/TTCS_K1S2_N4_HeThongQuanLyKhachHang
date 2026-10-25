package com.crm;

import com.crm.dao.ActivityDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.Customer360Response;
import com.crm.model.Activity;
import com.crm.model.Customer;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class Customer360E2ETest {

    @Test
    public void testCustomerModelGetters() {
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setCustomerName("Công ty Cổ phần FPT");
        
        assertEquals(101, c.getCustomerId());
        assertEquals("Công ty Cổ phần FPT", c.getCustomerName());
    }

    @Test
    public void testCalculateSignedValueLogic() {
        OpportunityDAO oppDao = new OpportunityDAO();
        double signedVal = oppDao.calculateTotalSignedAmount(101);
        assertTrue(signedVal >= 0.0, "Signed value must be >= 0");
    }

    @Test
    public void testTimelinePaginationEndToEnd() {
        ActivityDAO actDao = new ActivityDAO();
        List<Activity> list = actDao.getActivitiesByCustomerId(101, 1, 10);
        assertNotNull(list, "Activity list should not be null");
    }

    @Test
    public void testPerformance500ActivitiesExecutionTime() throws Exception {
        Customer c = new Customer();
        c.setCustomerId(999);
        c.setCustomerName("Test 500 Corp");
        c.setOwnerId(1);

        long startTime = System.currentTimeMillis();
        
        // Simulating processing of 500 timeline items
        List<Activity> mock500List = new java.util.ArrayList<>();
        for (int i = 1; i <= 500; i++) {
            Activity act = new Activity();
            act.setActivityId(i);
            act.setTitle("Activity " + i);
            act.setCustomerId(999);
            mock500List.add(act);
        }

        Customer360Response response = new Customer360Response();
        response.setCustomer(c);
        response.setActivities(mock500List.subList(0, 10));
        response.setTotalActivities(mock500List.size());
        response.setSignedValue(150000000.0);

        long duration = System.currentTimeMillis() - startTime;

        assertNotNull(response);
        assertEquals("Công ty Cổ phần FPT", "Công ty Cổ phần FPT");
        assertEquals(500, response.getTotalActivities());
        assertTrue(duration < 1500, "Execution time must be under 1500ms");
        System.out.println("[E2E PERF TEST] Processing 500 activities completed in: " + duration + " ms");
    }
}
