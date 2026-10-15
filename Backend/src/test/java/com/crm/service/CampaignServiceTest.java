package com.crm.service;

import com.crm.dto.CampaignRequest;
import com.crm.model.Campaign;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Test kiểm thử logic nghiệp vụ Chiến dịch tiếp thị (Campaign Tracking S4-03).
 */
public class CampaignServiceTest {

    private CampaignService campaignService;

    @BeforeEach
    public void setUp() {
        campaignService = new CampaignService();
    }

    @Test
    public void testCampaignRequestValidationSuccess() {
        CampaignRequest req = new CampaignRequest();
        req.setName("Chiến dịch Mùa Thu 2026");
        req.setBudget("15000000");
        req.setChannel("Email");
        req.setStartDate("2026-10-01");
        req.setEndDate("2026-10-31");

        List<String> errors = req.validate();
        assertTrue(errors.isEmpty(), "Dữ liệu hợp lệ không được có lỗi: " + errors);
    }

    @Test
    public void testCampaignRequestValidationEmptyName() {
        CampaignRequest req = new CampaignRequest();
        req.setName("");
        req.setBudget(new BigDecimal("10000000"));
        req.setStartDate("2026-10-01");
        req.setEndDate("2026-10-31");

        List<String> errors = req.validate();
        assertFalse(errors.isEmpty());
        assertTrue(errors.stream().anyMatch(e -> e.contains("Tên chiến dịch")));
    }

    @Test
    public void testCampaignRequestValidationNegativeBudget() {
        CampaignRequest req = new CampaignRequest();
        req.setName("Chiến dịch Test");
        req.setBudget(new BigDecimal("-500000"));
        req.setStartDate("2026-10-01");

        List<String> errors = req.validate();
        assertFalse(errors.isEmpty());
        assertTrue(errors.stream().anyMatch(e -> e.contains("Ngân sách")));
    }

    @Test
    public void testCampaignRequestValidationEndDateBeforeStartDate() {
        CampaignRequest req = new CampaignRequest();
        req.setName("Chiến dịch Test Ngày");
        req.setBudget(BigDecimal.ZERO);
        req.setStartDate("2026-10-20");
        req.setEndDate("2026-10-10");

        List<String> errors = req.validate();
        assertFalse(errors.isEmpty());
        assertTrue(errors.stream().anyMatch(e -> e.toLowerCase().contains("ngày kết thúc")));
    }

    @Test
    public void testCampaignModelAliasMethodsForJsp() {
        Campaign c = new Campaign();
        c.setCampaignId(88);
        c.setCampaignName("Chiến dịch Q4");

        assertEquals(88, c.getId());
        assertEquals("Chiến dịch Q4", c.getName());

        c.setId(99);
        c.setName("Chiến dịch Tết");

        assertEquals(99, c.getCampaignId());
        assertEquals("Chiến dịch Tết", c.getCampaignName());
    }

    @Test
    public void testAvailableChannelsList() {
        List<String> channels = campaignService.getAvailableChannels();
        assertNotNull(channels);
        assertTrue(channels.contains("Email"));
        assertTrue(channels.contains("Facebook"));
        assertTrue(channels.contains("Google Ads"));
        assertTrue(channels.contains("Sự kiện"));
    }

    @Test
    public void testCreateCampaignNullRequestThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> {
            campaignService.createCampaign(null, 1);
        });
    }

    @Test
    public void testUpdateCampaignInvalidIdThrowsException() {
        CampaignRequest req = new CampaignRequest();
        req.setId(0);
        req.setName("Test");

        assertThrows(IllegalArgumentException.class, () -> {
            campaignService.updateCampaign(req, 1, 1, null);
        });
    }

    @Test
    public void testGetCampaignDetailInvalidIdThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> {
            campaignService.getCampaignDetail(0, 1, 1, null);
        });
        assertThrows(IllegalArgumentException.class, () -> {
            campaignService.getCampaignDetail(-5, 1, 1, null);
        });
    }
}
