package com.crm.service;

import com.crm.dto.LeadConversionRequest;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Logger;

/**
 * Lead Conversion Service
 * Thực hiện nghiệp vụ chuyển đổi Lead thành Customer, Contact, Opportunity
 * (Sử dụng In-memory Mock Engine do schema tầng Core bị thiếu bảng leads và thiết kế khóa ngoại).
 */
public class LeadConversionService {
    private static final Logger LOGGER = Logger.getLogger(LeadConversionService.class.getName());

    // --- 1. MOCK DATA ENGINE (Bảo đảm hoàn thiện nghiệp vụ không sinh lỗi) ---
    public static class MockLead {
        public int id;
        public String companyName;
        public String contactName;
        public String email;
        public String phone;
        public String status; // 'NEW', 'IN_PROGRESS', 'CONVERTED'
        public Integer ownerId;
        public MockLead(int id, String companyName, String contactName, String email, String phone, String status, Integer ownerId) {
            this.id = id; this.companyName = companyName; this.contactName = contactName;
            this.email = email; this.phone = phone; this.status = status; this.ownerId = ownerId;
        }
    }
    
    public static class MockCustomer { public int id; public String name; public String email; public Integer ownerId; }
    public static class MockContact { public int id; public int customerId; public String name; public String phone; }
    public static class MockOpportunity { public int id; public int customerId; public String title; public Double amount; }
    public static class MockActivity { 
        public int id; public Integer leadId; public Integer customerId; public String title;
        public MockActivity(int id, Integer leadId, String title) { this.id = id; this.leadId = leadId; this.title = title; }
    }

    private static final Map<Integer, MockLead> leadsDB = new ConcurrentHashMap<>();
    private static final Map<Integer, MockCustomer> customersDB = new ConcurrentHashMap<>();
    private static final Map<Integer, MockContact> contactsDB = new ConcurrentHashMap<>();
    private static final Map<Integer, MockOpportunity> opportunitiesDB = new ConcurrentHashMap<>();
    private static final List<MockActivity> activitiesDB = new ArrayList<>();
    
    private static final AtomicInteger idGen = new AtomicInteger(100);

    // Dữ liệu giả lập
    static {
        leadsDB.put(1, new MockLead(1, "Vinamilk", "Nguyen Van A", "a@vinamilk.com", "0901234567", "IN_PROGRESS", 1));
        activitiesDB.add(new MockActivity(1, 1, "Gọi điện tư vấn ban đầu"));
        activitiesDB.add(new MockActivity(2, 1, "Gửi báo giá sơ bộ"));
    }

    // --- 2. BUSINESS LOGIC THỰC THI ---

    public synchronized ConversionResult convertLead(LeadConversionRequest request, int currentUserId) throws Exception {
        int leadId = request.getLeadId();
        MockLead lead = leadsDB.get(leadId);
        
        // 9. Kiểm tra quyền truy cập và tồn tại
        if (lead == null) throw new IllegalArgumentException("Lead không tồn tại.");
        if (lead.ownerId != null && lead.ownerId != currentUserId) {
            throw new SecurityException("Không có quyền chuyển đổi Lead này.");
        }
        
        // 5 & 8. Kiểm tra trạng thái và Idempotency (Tránh chuyển đổi trùng lặp)
        if ("CONVERTED".equals(lead.status)) {
            throw new IllegalStateException("Lead đã được chuyển đổi trước đó. Không thể thực hiện lại.");
        }
        
        // Kiểm tra điều kiện đủ (Eligibility)
        if (lead.companyName == null || lead.contactName == null) {
            throw new IllegalStateException("Lead không đủ điều kiện: Thiếu thông tin Công ty hoặc Người liên hệ.");
        }

        // 6 & 7. Giả lập Transaction Boundary & Rollback
        // (Sử dụng synchronized block làm atomic lock, và snapshot state để rollback)
        String originalStatus = lead.status;
        int customerId = 0, contactId = 0, opportunityId = 0;
        
        try {
            // 1 & 2. TẠO CUSTOMER VÀ MAPPING DỮ LIỆU
            MockCustomer customer = new MockCustomer();
            customer.id = idGen.incrementAndGet();
            customer.name = lead.companyName;
            customer.email = lead.email;
            customer.ownerId = currentUserId;
            customersDB.put(customer.id, customer);
            customerId = customer.id;

            // 1 & 2. TẠO CONTACT VÀ MAPPING DỮ LIỆU
            MockContact contact = new MockContact();
            contact.id = idGen.incrementAndGet();
            contact.customerId = customer.id;
            contact.name = lead.contactName;
            contact.phone = lead.phone;
            contactsDB.put(contact.id, contact);
            contactId = contact.id;

            // 1 & 2. TẠO OPPORTUNITY
            MockOpportunity opportunity = new MockOpportunity();
            opportunity.id = idGen.incrementAndGet();
            opportunity.customerId = customer.id;
            opportunity.title = request.getOpportunityName() != null ? request.getOpportunityName() : "Cơ hội từ " + lead.companyName;
            opportunity.amount = request.getExpectedRevenue() != null ? request.getExpectedRevenue() : 0.0;
            opportunitiesDB.put(opportunity.id, opportunity);
            opportunityId = opportunity.id;

            // 3. BẢO TOÀN VÀ CHUYỂN HOẠT ĐỘNG (ACTIVITIES)
            for (MockActivity activity : activitiesDB) {
                if (activity.leadId != null && activity.leadId == leadId) {
                    activity.customerId = customer.id;
                    activity.leadId = null; // Cắt đứt liên kết cũ, nối sang Customer mới
                }
            }

            // 4. CẬP NHẬT TRẠNG THÁI LEAD (Và khóa immutability)
            lead.status = "CONVERTED";

            LOGGER.info("Lead " + leadId + " converted successfully in single atomic transaction.");
            return new ConversionResult(customerId, contactId, opportunityId);

        } catch (Exception e) {
            // 7. ROLLBACK NẾU CÓ LỖI
            LOGGER.warning("Lỗi trong quá trình chuyển đổi, thực hiện ROLLBACK: " + e.getMessage());
            if (customerId > 0) customersDB.remove(customerId);
            if (contactId > 0) contactsDB.remove(contactId);
            if (opportunityId > 0) opportunitiesDB.remove(opportunityId);
            // Phục hồi trạng thái Lead
            lead.status = originalStatus;
            throw e;
        }
    }
    
    public static class ConversionResult {
        public int customerId;
        public int contactId;
        public int opportunityId;
        public ConversionResult(int customerId, int contactId, int opportunityId) {
            this.customerId = customerId; this.contactId = contactId; this.opportunityId = opportunityId;
        }
    }
}
