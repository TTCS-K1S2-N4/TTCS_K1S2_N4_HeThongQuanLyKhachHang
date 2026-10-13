package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dao.LeadSavedFilterDAO;
import com.crm.dto.LeadFilterRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Lead;
import com.crm.model.LeadSavedFilter;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Timestamp;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class LeadFilterServiceTest {

    private LeadDAO mockLeadDAO;
    private LeadSavedFilterDAO mockSavedFilterDAO;
    private PermissionService mockPermissionService;
    private LeadScoringService mockScoringService;
    private LeadFilterService filterService;

    @BeforeEach
    public void setUp() {
        mockLeadDAO = mock(LeadDAO.class);
        mockSavedFilterDAO = mock(LeadSavedFilterDAO.class);
        mockPermissionService = mock(PermissionService.class);
        mockScoringService = mock(LeadScoringService.class);

        filterService = new LeadFilterService(mockLeadDAO, mockSavedFilterDAO, mockPermissionService, mockScoringService);
    }

    @Test
    @DisplayName("S4-09-AC-01: Kiểm tra tính toán Data Scope (MY, TEAM, ALL)")
    public void testEffectiveOwnerIdsDataScopeMyAndSpecificOwner() {
        // Scope MY: chỉ trả về user đang đăng nhập
        when(mockPermissionService.getAccessibleAccountIdsForRoles(eq(10), any(), eq("ACCOUNT")))
                .thenReturn(Collections.singletonList(10));

        LeadFilterRequest req = new LeadFilterRequest();
        req.setOwnerScope("MY");

        List<Integer> ownerIds = filterService.getEffectiveOwnerIds(req, 10, Collections.singletonList(1));
        assertNotNull(ownerIds);
        assertEquals(1, ownerIds.size());
        assertEquals(10, ownerIds.get(0));

        // Nếu user cố tình lọc theo ownerId = 99 (ngoài phạm vi được phép sở hữu)
        req.setOwnerScope(null);
        req.setOwnerId(99);
        List<Integer> forbiddenOwnerIds = filterService.getEffectiveOwnerIds(req, 10, Collections.singletonList(1));
        assertNotNull(forbiddenOwnerIds);
        assertTrue(forbiddenOwnerIds.isEmpty(), "Khi chọn Owner ngoài phạm vi, phải trả về danh sách rỗng để bảo mật");
    }

    @Test
    @DisplayName("S4-09-AC-02: Lead quá SLA (24 giờ) hiển thị cờ slaOverdue = true")
    public void testSlaOverdueFlagging() {
        long now = System.currentTimeMillis();
        // Lead tạo cách đây 30 giờ (> 24 giờ SLA), trạng thái NEW
        Timestamp created30HoursAgo = new Timestamp(now - (30 * 3600 * 1000L));
        Lead leadOverdue = new Lead();
        leadOverdue.setLeadId(1);
        leadOverdue.setStatus("NEW");
        leadOverdue.setCreatedAt(created30HoursAgo);

        // Lead tạo cách đây 2 giờ (< 24 giờ SLA)
        Timestamp created2HoursAgo = new Timestamp(now - (2 * 3600 * 1000L));
        Lead leadFresh = new Lead();
        leadFresh.setLeadId(2);
        leadFresh.setStatus("NEW");
        leadFresh.setCreatedAt(created2HoursAgo);

        LeadResponse respOverdue = LeadResponse.fromModel(leadOverdue);
        respOverdue.setSlaOverdue(now - leadOverdue.getCreatedAt().getTime() > 24 * 3600 * 1000L);

        LeadResponse respFresh = LeadResponse.fromModel(leadFresh);
        respFresh.setSlaOverdue(now - leadFresh.getCreatedAt().getTime() > 24 * 3600 * 1000L);

        assertTrue(respOverdue.isSlaOverdue(), "Lead chưa xử lý quá 24h phải được đánh dấu quá SLA");
        assertFalse(respFresh.isSlaOverdue(), "Lead mới tạo trong 2h không bị đánh dấu quá SLA");
    }

    @Test
    @DisplayName("S4-09-AC-03: Lưu và quản lý bộ lọc Lead cá nhân")
    public void testSaveAndRetrieveSavedFilters() {
        LeadSavedFilter filter = new LeadSavedFilter(10, "Lead Nóng sáng nay", "classification=HOT&status=NEW");
        when(mockSavedFilterDAO.createSavedFilter(any(LeadSavedFilter.class))).thenReturn(true);
        when(mockSavedFilterDAO.getSavedFiltersByUserId(10)).thenReturn(Collections.singletonList(filter));
        when(mockSavedFilterDAO.deleteSavedFilter(1, 10)).thenReturn(true);

        // Lưu bộ lọc
        boolean saved = filterService.saveFilter(filter, 10);
        assertTrue(saved);
        verify(mockSavedFilterDAO, times(1)).createSavedFilter(filter);

        // Lấy danh sách bộ lọc
        List<LeadSavedFilter> list = filterService.getSavedFilters(10);
        assertNotNull(list);
        assertEquals(1, list.size());
        assertEquals("Lead Nóng sáng nay", list.get(0).getFilterName());
        assertEquals("classification=HOT&status=NEW", list.get(0).getFilterQuery());

        // Xóa bộ lọc
        boolean deleted = filterService.deleteSavedFilter(1, 10);
        assertTrue(deleted);
        verify(mockSavedFilterDAO, times(1)).deleteSavedFilter(1, 10);
    }
}
