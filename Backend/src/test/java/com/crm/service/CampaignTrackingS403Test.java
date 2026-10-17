package com.crm.service;

import com.crm.dao.CampaignDAO;
import com.crm.dao.LeadDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.CampaignRequest;
import com.crm.dto.LeadConversionRequest;
import com.crm.dto.LeadRequest;
import com.crm.model.Campaign;
import com.crm.model.Lead;
import com.crm.model.Opportunity;
import org.junit.jupiter.api.*;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class CampaignTrackingS403Test {

    private static CampaignDAO campaignDAO;
    private static LeadDAO leadDAO;
    private static OpportunityDAO opportunityDAO;
    private static CampaignService campaignService;
    private static LeadService leadService;
    private static LeadConversionService conversionService;

    private static List<Integer> cleanupCampaignIds = new ArrayList<>();
    private static List<Integer> cleanupLeadIds = new ArrayList<>();
    private static List<Integer> cleanupOppIds = new ArrayList<>();

    @BeforeAll
    public static void setUp() {
        campaignDAO = new CampaignDAO();
        leadDAO = new LeadDAO();
        opportunityDAO = new OpportunityDAO();
        campaignService = new CampaignService();
        leadService = new LeadService();
        conversionService = new LeadConversionService();
    }

    @AfterAll
    public static void tearDown() {
        // Clean up created test entities in reverse order
        for (Integer oppId : cleanupOppIds) {
            try { opportunityDAO.delete(oppId); } catch (Exception ignored) {}
        }
        for (Integer leadId : cleanupLeadIds) {
            try { leadDAO.deleteLead(leadId); } catch (Exception ignored) {}
        }
        // Clean up campaigns
        for (Integer campId : cleanupCampaignIds) {
            try {
                // Delete test campaign
                try (java.sql.Connection conn = com.crm.util.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM campaigns WHERE campaign_id = ?")) {
                    ps.setInt(1, campId);
                    ps.executeUpdate();
                }
            } catch (Exception ignored) {}
        }
    }

    // --- TEST A: CRUD CHIẾN DỊCH ---
    @Test
    @Order(1)
    public void testA_CampaignCrud() throws Exception {
        CampaignRequest req = new CampaignRequest();
        req.setName("Test Chiến dịch A - Marketing Q4");
        req.setBudget("10000000");
        req.setStartDate("2026-10-01");
        req.setEndDate("2026-12-31");
        req.setChannel("Digital");
        req.setDescription("Kiểm thử CRUD chiến dịch S4-03");
        req.setStatus("ACTIVE");

        Campaign created = campaignService.createCampaign(req, 1);
        assertNotNull(created);
        assertTrue(created.getCampaignId() > 0);
        assertEquals(created.getCampaignId(), created.getId()); // alias test
        assertEquals(created.getCampaignName(), created.getName()); // alias test
        cleanupCampaignIds.add(created.getCampaignId());

        // Update campaign
        req.setId(created.getCampaignId());
        req.setName("Test Chiến dịch A - Marketing Q4 (Updated)");
        req.setBudget("15000000");
        Campaign updated = campaignService.updateCampaign(req, 1, 1, Collections.singletonList(1));
        assertNotNull(updated);
        assertEquals("Test Chiến dịch A - Marketing Q4 (Updated)", updated.getCampaignName());
        assertEquals(new BigDecimal("15000000.00"), updated.getBudget());
    }

    // --- TEST B: LIÊN KẾT LEAD VỚI CHIẾN DỊCH ---
    @Test
    @Order(2)
    public void testB_LeadCampaignLink() throws Exception {
        // 1. Tạo campaign làm mốc
        CampaignRequest campReq = new CampaignRequest();
        campReq.setName("Test Campaign Lead Link");
        campReq.setBudget("5000000");
        campReq.setChannel("Facebook");
        campReq.setStatus("ACTIVE");
        Campaign camp = campaignService.createCampaign(campReq, 1);
        cleanupCampaignIds.add(camp.getCampaignId());

        // 2. Tạo lead có campaignId hợp lệ
        LeadRequest leadReq = new LeadRequest();
        leadReq.setFullName("Nguyen Van Lead Campaign");
        leadReq.setEmail("lead_camp_" + System.currentTimeMillis() + "@gmail.com");
        leadReq.setPhone("09" + String.format("%08d", (int)(Math.random() * 90000000 + 10000000)));
        leadReq.setCompany("Công ty ABC");
        leadReq.setLeadSourceId(1);
        leadReq.setCampaignId(camp.getCampaignId());
        leadReq.setStatus("NEW");

        var leadResp = leadService.createLead(leadReq, 1);
        assertNotNull(leadResp);
        assertTrue(leadResp.getLeadId() > 0);
        assertEquals(camp.getCampaignId(), leadResp.getCampaignId());
        cleanupLeadIds.add(leadResp.getLeadId());

        // Đọc lại từ DAO để kiểm tra JOIN campaign_name
        Lead fetchedLead = leadDAO.getById(leadResp.getLeadId());
        assertNotNull(fetchedLead);
        assertEquals(camp.getCampaignId(), fetchedLead.getCampaignId());
        assertEquals("Test Campaign Lead Link", fetchedLead.getCampaignName());

        // 3. Tạo lead không thuộc chiến dịch (campaignId null)
        LeadRequest leadNoCamp = new LeadRequest();
        leadNoCamp.setFullName("Nguyen Van Lead No Camp");
        leadNoCamp.setEmail("lead_nocamp_" + System.currentTimeMillis() + "@gmail.com");
        leadNoCamp.setPhone("09" + String.format("%08d", (int)(Math.random() * 90000000 + 10000000)));
        leadNoCamp.setCompany("Công ty XYZ");
        leadNoCamp.setLeadSourceId(1);
        leadNoCamp.setCampaignId(null);

        var leadNoCampResp = leadService.createLead(leadNoCamp, 1);
        assertNotNull(leadNoCampResp);
        assertNull(leadNoCampResp.getCampaignId());
        cleanupLeadIds.add(leadNoCampResp.getLeadId());

        // 4. Gửi campaignId không tồn tại -> phải từ chối
        LeadRequest leadInvalidCamp = new LeadRequest();
        leadInvalidCamp.setFullName("Nguyen Van Lead Invalid Camp");
        leadInvalidCamp.setEmail("lead_invalid_" + System.currentTimeMillis() + "@gmail.com");
        leadInvalidCamp.setCampaignId(999999); // ID không tồn tại
        assertThrows(IllegalArgumentException.class, () -> {
            leadService.createLead(leadInvalidCamp, 1);
        });
    }

    // --- TEST C: LIÊN KẾT OPPORTUNITY VỚI CHIẾN DỊCH ---
    @Test
    @Order(3)
    public void testC_OpportunityCampaignLink() throws Exception {
        // Tạo campaign
        CampaignRequest campReq = new CampaignRequest();
        campReq.setName("Test Campaign Opp Link");
        campReq.setBudget("20000000");
        campReq.setStatus("ACTIVE");
        Campaign camp = campaignService.createCampaign(campReq, 1);
        cleanupCampaignIds.add(camp.getCampaignId());

        // 1. Tạo Opportunity gắn campaignId
        Opportunity opp = new Opportunity();
        opp.setTitle("Cơ hội bán phần mềm ERP");
        opp.setAmount(10000000.0);
        opp.setOwnerId(1);
        opp.setCampaignId(camp.getCampaignId());
        opp.setStage("OPEN");
        opp.setStatus("ACTIVE");
        boolean inserted = opportunityDAO.insert(opp);
        assertTrue(inserted);
        assertTrue(opp.getOpportunityId() > 0);
        cleanupOppIds.add(opp.getOpportunityId());

        // Đọc lại từ DAO
        Opportunity fetchedOpp = opportunityDAO.findById(opp.getOpportunityId());
        assertNotNull(fetchedOpp);
        assertEquals(camp.getCampaignId(), fetchedOpp.getCampaignId());
        assertEquals("Test Campaign Opp Link", fetchedOpp.getCampaignName());

        // 2. Sửa Opportunity và bảo toàn liên kết
        fetchedOpp.setTitle("Cơ hội bán phần mềm ERP (Updated)");
        fetchedOpp.setAmount(12000000.0);
        boolean updated = opportunityDAO.update(fetchedOpp);
        assertTrue(updated);

        Opportunity reFetched = opportunityDAO.findById(opp.getOpportunityId());
        assertEquals("Cơ hội bán phần mềm ERP (Updated)", reFetched.getTitle());
        assertEquals(camp.getCampaignId(), reFetched.getCampaignId());

        // 3. Kế thừa campaignId khi chuyển đổi Lead
        LeadConversionService.MockLead mockLead = new LeadConversionService.MockLead(
                9999, "Công ty Cổ phần Alpha", "Le Van B", "b@alpha.com", "0933333333",
                "IN_PROGRESS", 1, camp.getCampaignId()
        );
        // Lưu vào in-memory map
        try {
            java.lang.reflect.Field field = LeadConversionService.class.getDeclaredField("leadsDB");
            field.setAccessible(true);
            @SuppressWarnings("unchecked")
            java.util.Map<Integer, LeadConversionService.MockLead> db = 
                    (java.util.Map<Integer, LeadConversionService.MockLead>) field.get(null);
            db.put(9999, mockLead);

            LeadConversionRequest convReq = new LeadConversionRequest();
            convReq.setLeadId(9999);
            convReq.setOpportunityName("Deal Chuyển Đổi Alpha");
            convReq.setExpectedRevenue(25000000.0);

            LeadConversionService.ConversionResult res = conversionService.convertLead(convReq, 1);
            assertNotNull(res);
            assertTrue(res.opportunityId > 0);

            // Kiểm tra Opportunity sinh ra đã kế thừa đúng campaignId từ Lead
            java.lang.reflect.Field oppField = LeadConversionService.class.getDeclaredField("opportunitiesDB");
            oppField.setAccessible(true);
            @SuppressWarnings("unchecked")
            java.util.Map<Integer, LeadConversionService.MockOpportunity> oppDb = 
                    (java.util.Map<Integer, LeadConversionService.MockOpportunity>) oppField.get(null);
            LeadConversionService.MockOpportunity convertedOpp = oppDb.get(res.opportunityId);
            assertNotNull(convertedOpp);
            assertEquals(camp.getCampaignId(), convertedOpp.campaignId);
        } catch (Exception e) {
            fail("Lỗi kiểm tra kế thừa campaignId trong LeadConversionService: " + e.getMessage());
        }
    }

    // --- TEST D: CHỈ SỐ CHIẾN DỊCH (S4-03-AC-03) ---
    @Test
    @Order(4)
    public void testD_CampaignMetricsCalculation() throws Exception {
        // Tạo Chiến dịch A
        CampaignRequest reqA = new CampaignRequest();
        reqA.setName("Chiến dịch Đo Lường A");
        reqA.setBudget("10000000");
        reqA.setStatus("ACTIVE");
        Campaign campA = campaignService.createCampaign(reqA, 1);
        cleanupCampaignIds.add(campA.getCampaignId());

        // Tạo Chiến dịch B
        CampaignRequest reqB = new CampaignRequest();
        reqB.setName("Chiến dịch Đo Lường B");
        reqB.setBudget("5000000");
        reqB.setStatus("ACTIVE");
        Campaign campB = campaignService.createCampaign(reqB, 1);
        cleanupCampaignIds.add(campB.getCampaignId());

        // Gắn vào Chiến dịch A: 3 Lead
        for (int i = 1; i <= 3; i++) {
            LeadRequest l = new LeadRequest();
            l.setFullName("Lead A" + i);
            l.setEmail("leadA" + i + "_" + System.currentTimeMillis() + "_" + i + "@test.com");
            l.setPhone("09" + String.format("%08d", (int)(Math.random() * 90000000 + 10000000)));
            l.setLeadSourceId(1);
            l.setCampaignId(campA.getCampaignId());
            var createdL = leadService.createLead(l, 1);
            cleanupLeadIds.add(createdL.getLeadId());
        }

        // Gắn vào Chiến dịch A: 2 Opportunity (1 thắng 5.000.000, 1 mở 3.000.000)
        Opportunity oppWonA = new Opportunity();
        oppWonA.setTitle("Opp Won A");
        oppWonA.setAmount(5000000.0);
        oppWonA.setOwnerId(1);
        oppWonA.setCampaignId(campA.getCampaignId());
        oppWonA.setStage("CLOSED_WON");
        oppWonA.setStatus("WON");
        opportunityDAO.insert(oppWonA);
        cleanupOppIds.add(oppWonA.getOpportunityId());

        Opportunity oppOpenA = new Opportunity();
        oppOpenA.setTitle("Opp Open A");
        oppOpenA.setAmount(3000000.0);
        oppOpenA.setOwnerId(1);
        oppOpenA.setCampaignId(campA.getCampaignId());
        oppOpenA.setStage("OPEN");
        oppOpenA.setStatus("ACTIVE");
        opportunityDAO.insert(oppOpenA);
        cleanupOppIds.add(oppOpenA.getOpportunityId());

        // Gắn vào Chiến dịch B: 1 Lead, 1 Opportunity mở 2.000.000 (chưa thắng)
        LeadRequest lB = new LeadRequest();
        lB.setFullName("Lead B1");
        lB.setEmail("leadB1_" + System.currentTimeMillis() + "@test.com");
        lB.setPhone("09" + String.format("%08d", (int)(Math.random() * 90000000 + 10000000)));
        lB.setLeadSourceId(1);
        lB.setCampaignId(campB.getCampaignId());
        var createdLB = leadService.createLead(lB, 1);
        cleanupLeadIds.add(createdLB.getLeadId());

        Opportunity oppOpenB = new Opportunity();
        oppOpenB.setTitle("Opp Open B");
        oppOpenB.setAmount(2000000.0);
        oppOpenB.setOwnerId(1);
        oppOpenB.setCampaignId(campB.getCampaignId());
        oppOpenB.setStage("PROSPECTING");
        oppOpenB.setStatus("ACTIVE");
        opportunityDAO.insert(oppOpenB);
        cleanupOppIds.add(oppOpenB.getOpportunityId());

        // Kiểm tra số liệu Chiến dịch A:
        // Phải có: leadCount = 3, opportunityCount = 2, closedValue = 5,000,000 VNĐ
        Campaign metricsA = campaignDAO.findById(campA.getCampaignId());
        assertNotNull(metricsA);
        assertEquals(3, metricsA.getLeadCount(), "Số lead của Chiến dịch A phải đúng bằng 3");
        assertEquals(2, metricsA.getOpportunityCount(), "Số opportunity của Chiến dịch A phải đúng bằng 2");
        assertEquals(0, new BigDecimal("5000000.00").compareTo(metricsA.getClosedValue()),
                "Doanh thu đã chốt của Chiến dịch A phải bằng 5.000.000 VNĐ");

        // Kiểm tra số liệu Chiến dịch B:
        // Phải có: leadCount = 1, opportunityCount = 1, closedValue = 0 VNĐ
        Campaign metricsB = campaignDAO.findById(campB.getCampaignId());
        assertNotNull(metricsB);
        assertEquals(1, metricsB.getLeadCount(), "Số lead của Chiến dịch B phải đúng bằng 1");
        assertEquals(1, metricsB.getOpportunityCount(), "Số opportunity của Chiến dịch B phải đúng bằng 1");
        assertEquals(0, BigDecimal.ZERO.compareTo(metricsB.getClosedValue()),
                "Doanh thu đã chốt của Chiến dịch B phải bằng 0 VNĐ");
    }
}
