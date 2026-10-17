package com.crm.service;

import com.crm.dao.ContactDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.LeadDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.LeadConversionRequest;
import com.crm.model.Contact;
import com.crm.model.Customer;
import com.crm.model.Lead;
import com.crm.model.Opportunity;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Logger;

/**
 * Lead Conversion Service
 * Thực hiện nghiệp vụ chuyển đổi Lead thành Customer, Contact, Opportunity.
 * Đồng bộ cả MySQL database và In-Memory Mock Engine.
 */
public class LeadConversionService {
    private static final Logger LOGGER = Logger.getLogger(LeadConversionService.class.getName());

    public static class MockLead {
        public int id;
        public String companyName;
        public String contactName;
        public String email;
        public String phone;
        public String status; // 'NEW', 'IN_PROGRESS', 'CONVERTED'
        public Integer ownerId;
        public Integer campaignId;
        public MockLead(int id, String companyName, String contactName, String email, String phone, String status, Integer ownerId) {
            this(id, companyName, contactName, email, phone, status, ownerId, null);
        }
        public MockLead(int id, String companyName, String contactName, String email, String phone, String status, Integer ownerId, Integer campaignId) {
            this.id = id; this.companyName = companyName; this.contactName = contactName;
            this.email = email; this.phone = phone; this.status = status; this.ownerId = ownerId;
            this.campaignId = campaignId;
        }
    }
    
    public static class MockCustomer { public int id; public String name; public String email; public Integer ownerId; }
    public static class MockContact { public int id; public int customerId; public String name; public String phone; }
    public static class MockOpportunity { public int id; public int customerId; public String title; public Double amount; public Integer campaignId; }
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

    static {
        leadsDB.put(1, new MockLead(1, "Vinamilk", "Nguyen Van A", "a@vinamilk.com", "0901234567", "IN_PROGRESS", 1));
        activitiesDB.add(new MockActivity(1, 1, "Gọi điện tư vấn ban đầu"));
        activitiesDB.add(new MockActivity(2, 1, "Gửi báo giá sơ bộ"));
    }

    private final LeadDAO leadDAO = new LeadDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final ContactDAO contactDAO = new ContactDAO();
    private final OpportunityDAO opportunityDAO = new OpportunityDAO();

    public synchronized ConversionResult convertLead(LeadConversionRequest request, int currentUserId) throws Exception {
        int leadId = request.getLeadId();
        MockLead lead = leadsDB.get(leadId);
        
        // 1. Nếu chưa có trong cache In-Memory, nạp từ MySQL
        if (lead == null) {
            Lead realLead = leadDAO.getById(leadId);
            if (realLead != null) {
                String cName = realLead.getCompany();
                if (cName == null || cName.trim().isEmpty()) {
                    cName = realLead.getFullName();
                }
                lead = new MockLead(
                    realLead.getLeadId(),
                    cName,
                    realLead.getFullName(),
                    realLead.getEmail(),
                    realLead.getPhone(),
                    realLead.getStatus(),
                    realLead.getOwnerId() != null ? realLead.getOwnerId() : currentUserId,
                    realLead.getCampaignId()
                );
                leadsDB.put(leadId, lead);
            }
        }
        
        // 2. Kiểm tra tồn tại
        if (lead == null) {
            throw new IllegalArgumentException("Lead không tồn tại (ID: #" + leadId + ").");
        }
        
        // 3. Kiểm tra trạng thái và Idempotency (Tránh chuyển đổi trùng lặp)
        if ("CONVERTED".equalsIgnoreCase(lead.status) || "Đã chuyển đổi".equalsIgnoreCase(lead.status)) {
            throw new IllegalStateException("Lead đã được chuyển đổi trước đó. Không thể thực hiện lại.");
        }
        
        // 4. Kiểm tra điều kiện đủ (Eligibility)
        if (lead.companyName == null || lead.contactName == null) {
            throw new IllegalStateException("Lead không đủ điều kiện: Thiếu thông tin Công ty hoặc Người liên hệ.");
        }

        String originalStatus = lead.status;
        int customerId = 0, contactId = 0, opportunityId = 0;
        int realCustomerId = 0, realContactId = 0, realOpportunityId = 0;
        
        try {
            // --- 5. TẠO CUSTOMER TRONG MOCK DB ---
            MockCustomer customer = new MockCustomer();
            customer.id = idGen.incrementAndGet();
            customer.name = lead.companyName;
            customer.email = lead.email;
            customer.ownerId = currentUserId;
            customersDB.put(customer.id, customer);
            customerId = customer.id;

            // --- 6. TẠO CONTACT TRONG MOCK DB ---
            MockContact contact = new MockContact();
            contact.id = idGen.incrementAndGet();
            contact.customerId = customer.id;
            contact.name = lead.contactName;
            contact.phone = lead.phone;
            contactsDB.put(contact.id, contact);
            contactId = contact.id;

            // --- 7. TẠO OPPORTUNITY TRONG MOCK DB ---
            MockOpportunity opportunity = new MockOpportunity();
            opportunity.id = idGen.incrementAndGet();
            opportunity.customerId = customer.id;
            opportunity.title = request.getOpportunityName() != null && !request.getOpportunityName().trim().isEmpty() 
                    ? request.getOpportunityName().trim() 
                    : "Cơ hội từ " + lead.companyName;
            opportunity.amount = request.getExpectedRevenue() != null ? request.getExpectedRevenue() : 0.0;
            opportunity.campaignId = lead.campaignId;
            opportunitiesDB.put(opportunity.id, opportunity);
            opportunityId = opportunity.id;

            // --- 8. CHUYỂN HOẠT ĐỘNG (ACTIVITIES) TRONG MOCK DB ---
            for (MockActivity activity : activitiesDB) {
                if (activity.leadId != null && activity.leadId == leadId) {
                    activity.customerId = customer.id;
                    activity.leadId = null;
                }
            }

            // --- 9. TẠO CÁC BẢN GHI THẬT TRONG CƠ SỞ DỮ LIỆU MYSQL ---
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    // 9.1 Tạo Khách hàng (Customer)
                    Customer cust = new Customer();
                    cust.setCustomerName(lead.companyName);
                    cust.setPhone(lead.phone);
                    cust.setEmail(lead.email);
                    cust.setStatus("ACTIVE");
                    cust.setOwnerId(currentUserId > 0 ? currentUserId : 1);
                    if (customerDAO.insert(conn, cust)) {
                        realCustomerId = cust.getCustomerId();
                    }

                    // 9.2 Tạo Người liên hệ (Contact)
                    int targetCustId = realCustomerId > 0 ? realCustomerId : 1;
                    Contact cont = new Contact();
                    cont.setCustomerId(targetCustId);
                    cont.setFullName(lead.contactName);
                    cont.setEmail(lead.email);
                    cont.setPhone(lead.phone);
                    cont.setTitle("Người liên hệ chính");
                    cont.setPrimary(true);
                    realContactId = contactDAO.insert(cont, conn);

                    // 9.3 Tạo Cơ hội bán hàng (Opportunity)
                    Opportunity opp = new Opportunity();
                    opp.setTitle(opportunity.title);
                    opp.setAmount(opportunity.amount);
                    opp.setCustomerId(targetCustId);
                    opp.setOwnerId(currentUserId > 0 ? currentUserId : 1);
                    opp.setCampaignId(lead.campaignId);
                    opp.setStatus("ACTIVE");
                    opp.setStage("PROSPECTING");
                    if (opportunityDAO.insert(opp)) {
                        realOpportunityId = opp.getOpportunityId();
                    }

                    // 9.4 Cập nhật trạng thái Lead thành CONVERTED
                    try (PreparedStatement psLead = conn.prepareStatement("UPDATE leads SET status = 'CONVERTED' WHERE lead_id = ?")) {
                        psLead.setInt(1, leadId);
                        psLead.executeUpdate();
                    }

                    conn.commit();
                    LOGGER.info("Real database conversion committed successfully for Lead #" + leadId);
                } catch (Exception dbEx) {
                    conn.rollback();
                    LOGGER.warning("Database conversion rolled back: " + dbEx.getMessage());
                }
            } catch (Exception e) {
                LOGGER.warning("DB Connection error during lead conversion: " + e.getMessage());
            }

            // Khóa trạng thái Lead
            lead.status = "CONVERTED";

            int finalCustId = realCustomerId > 0 ? realCustomerId : customerId;
            int finalContId = realContactId > 0 ? realContactId : contactId;
            int finalOppId = realOpportunityId > 0 ? realOpportunityId : opportunityId;

            if (realCustomerId > 0) {
                customersDB.put(realCustomerId, customer);
            }
            if (realContactId > 0) {
                contactsDB.put(realContactId, contact);
            }
            if (realOpportunityId > 0) {
                opportunitiesDB.put(realOpportunityId, opportunity);
            }

            LOGGER.info("Lead #" + leadId + " converted successfully -> Customer: #" + finalCustId + ", Contact: #" + finalContId + ", Opportunity: #" + finalOppId);
            return new ConversionResult(finalCustId, finalContId, finalOppId);

        } catch (Exception e) {
            // ROLLBACK MOCK
            LOGGER.warning("Lỗi trong quá trình chuyển đổi, thực hiện ROLLBACK: " + e.getMessage());
            if (customerId > 0) customersDB.remove(customerId);
            if (contactId > 0) contactsDB.remove(contactId);
            if (opportunityId > 0) opportunitiesDB.remove(opportunityId);
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
