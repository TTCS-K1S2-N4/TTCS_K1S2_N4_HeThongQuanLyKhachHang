package com.crm.model;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class CustomerTest {

    @Test
    public void testCustomerFields() {
        Customer c = new Customer();
        c.setCustomerId(1);
        c.setCustomerName("Công ty ABC");
        c.setPhone("0901234567");
        c.setTaxCode("0101234567");
        c.setIndustry("Công nghệ thông tin");
        c.setSize("100-500 nhân sự");
        c.setWebsite("https://abc.com");
        c.setAddress("123 Phố Huế, Hà Nội");
        c.setStatus("Khách hàng");
        c.setOwnerId(5);

        assertEquals(1, c.getCustomerId());
        assertEquals("Công ty ABC", c.getCustomerName());
        assertEquals("0901234567", c.getPhone());
        assertEquals("0101234567", c.getTaxCode());
        assertEquals("0101234567", c.getTaxcode());
        assertEquals("Công nghệ thông tin", c.getIndustry());
        assertEquals("100-500 nhân sự", c.getSize());
        assertEquals("https://abc.com", c.getWebsite());
        assertEquals("123 Phố Huế, Hà Nội", c.getAddress());
        assertEquals("Khách hàng", c.getStatus());
        assertEquals(5, c.getOwnerId());
    }
}
