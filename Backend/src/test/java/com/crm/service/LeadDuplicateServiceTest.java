package com.crm.service;

import com.crm.dto.LeadMergeRequest;
import com.crm.service.LeadDuplicateService.CustomerCandidate;
import com.crm.service.LeadDuplicateService.LeadDuplicateCandidate;
import com.crm.service.LeadDuplicateService.LeadRecord;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Test kiểm thử toàn diện các thuật toán phát hiện trùng lặp và nghiệp vụ gộp Lead (S4-04).
 */
public class LeadDuplicateServiceTest {

    private LeadDuplicateService duplicateService;

    @BeforeEach
    public void setUp() {
        duplicateService = new LeadDuplicateService();
    }

    @Test
    public void testNormalizePhoneVietnameseFormats() {
        assertEquals("0901234567", duplicateService.normalizePhone("0901234567"));
        assertEquals("0901234567", duplicateService.normalizePhone("0901 234 567"));
        assertEquals("0901234567", duplicateService.normalizePhone("0901-234-567"));
        assertEquals("0901234567", duplicateService.normalizePhone("+84901234567"));
        assertEquals("0901234567", duplicateService.normalizePhone("84901234567"));
        assertEquals("0901234567", duplicateService.normalizePhone("(0901) 234.567"));
        assertEquals("", duplicateService.normalizePhone(null));
    }

    @Test
    public void testIsSamePhone() {
        assertTrue(duplicateService.isSamePhone("0901234567", "+84901234567"));
        assertTrue(duplicateService.isSamePhone("0901-234-567", "0901 234 567"));
        assertFalse(duplicateService.isSamePhone("0901234567", "0909999999"));
        assertFalse(duplicateService.isSamePhone(null, "0901234567"));
        assertFalse(duplicateService.isSamePhone("0901234567", null));
    }

    @Test
    public void testIsSameEmail() {
        assertTrue(duplicateService.isSameEmail("test@example.com", "test@example.com"));
        assertTrue(duplicateService.isSameEmail(" Test@Example.COM ", "test@example.com"));
        assertFalse(duplicateService.isSameEmail("test1@example.com", "test2@example.com"));
        assertFalse(duplicateService.isSameEmail(null, "test@example.com"));
        assertFalse(duplicateService.isSameEmail("test@example.com", null));
    }

    @Test
    public void testNormalizeCompanyNameStopWords() {
        String n1 = duplicateService.normalizeCompanyName("Công ty TNHH Giải Pháp Công Nghệ Frostline");
        String n2 = duplicateService.normalizeCompanyName("Cty CP Giải Pháp Công Nghệ Frostline");
        String n3 = duplicateService.normalizeCompanyName("Frostline Co., Ltd");

        assertTrue(n1.contains("giải pháp công nghệ frostline"));
        assertTrue(n2.contains("giải pháp công nghệ frostline"));
        assertEquals("frostline", n3);
    }

    @Test
    public void testIsSameCompany() {
        assertTrue(duplicateService.isSameCompany("Công ty TNHH ABC", "Cty CP ABC"));
        assertTrue(duplicateService.isSameCompany("Tập đoàn Công nghệ Viettel", "Viettel"));
        assertFalse(duplicateService.isSameCompany("Công ty May 10", "Công ty Xây dựng Hòa Bình"));
        assertFalse(duplicateService.isSameCompany(null, "ABC"));
        assertFalse(duplicateService.isSameCompany("ABC", null));
    }

    @Test
    public void testEvaluateDuplicateReasons() {
        LeadRecord l1 = new LeadRecord(1, "Nguyễn Văn A", "Công ty ABC", "nva@gmail.com", "0901234567", "NEW");
        LeadRecord l2 = new LeadRecord(2, "Nguyễn A", "Cty ABC", "nva@gmail.com", "0901234567", "NEW");

        List<String> reasons = duplicateService.evaluateDuplicateReasons(l1, l2);
        assertEquals(3, reasons.size());
        assertTrue(reasons.contains("Trùng Email"));
        assertTrue(reasons.contains("Trùng Số điện thoại"));
        assertTrue(reasons.contains("Trùng Tên công ty"));
    }

    @Test
    public void testLeadRecordAliasMethodsForJsp() {
        LeadRecord l = new LeadRecord();
        l.setLeadId(100);
        l.setFullName("Lê Đức Nam");
        l.setCompanyName("Frostline Inc");

        assertEquals(100, l.getId());
        assertEquals("Lê Đức Nam", l.getName());
        assertEquals("Frostline Inc", l.getCompany());

        l.setId(101);
        l.setName("Nam Lê");
        l.setCompany("Frostline Corp");

        assertEquals(101, l.getLeadId());
        assertEquals("Nam Lê", l.getFullName());
        assertEquals("Frostline Corp", l.getCompanyName());
    }

    @Test
    public void testLeadDuplicateCandidateMatchTags() {
        LeadRecord left = new LeadRecord(1, "Lead 1", "Company A", "l1@crm.com", "0911111111", "NEW");
        LeadRecord right = new LeadRecord(2, "Lead 2", "Company A", "l1@crm.com", "0922222222", "NEW");

        LeadDuplicateCandidate candidate = new LeadDuplicateCandidate(left, right, Arrays.asList("Trùng Email", "Trùng Tên công ty"));

        assertEquals(2, candidate.getId());
        assertEquals("Lead 2", candidate.getName());
        assertEquals("l1@crm.com", candidate.getEmail());
        assertEquals("0922222222", candidate.getPhone());
        assertEquals("Company A", candidate.getCompany());

        assertTrue(candidate.isMatchEmail());
        assertFalse(candidate.isMatchPhone());
        assertTrue(candidate.isMatchCompany());
    }

    @Test
    public void testCustomerCandidateDelegateGetters() {
        com.crm.model.Customer cust = new com.crm.model.Customer();
        cust.setCustomerId(505);
        cust.setCustomerName("Khách Hàng VIP");
        cust.setEmail("vip@customer.vn");
        cust.setPhone("0988888888");

        CustomerCandidate candidate = new CustomerCandidate(cust, Arrays.asList("Trùng Số điện thoại"));

        assertEquals(505, candidate.getId());
        assertEquals("Khách Hàng VIP", candidate.getName());
        assertEquals("vip@customer.vn", candidate.getEmail());
        assertEquals("0988888888", candidate.getPhone());
    }

    @Test
    public void testMergeLeadsInvalidValidation() {
        // Null request
        assertThrows(IllegalArgumentException.class, () -> duplicateService.mergeLeads(null, 1));

        // Primary trùng Duplicate
        LeadMergeRequest sameReq = new LeadMergeRequest(10, 10);
        assertThrows(IllegalArgumentException.class, () -> duplicateService.mergeLeads(sameReq, 1));

        // ID âm hoặc bằng 0
        LeadMergeRequest invalidReq = new LeadMergeRequest(0, 10);
        assertThrows(IllegalArgumentException.class, () -> duplicateService.mergeLeads(invalidReq, 1));
    }
}
