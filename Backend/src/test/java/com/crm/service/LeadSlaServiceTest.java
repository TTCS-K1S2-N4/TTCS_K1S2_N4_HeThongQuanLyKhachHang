package com.crm.service;

import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.model.LeadAssignmentHistory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.sql.Timestamp;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Test chứng minh các tiêu chí chấp nhận cho S4-07:
 * Lead Acceptance, Rejection & Response SLA.
 */
class LeadSlaServiceTest {

    @Mock
    private LeadAssignmentHistoryDAO historyDAO;

    private LeadSlaService slaService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        slaService = new LeadSlaService(historyDAO);
    }

    @Test
    @DisplayName("S4-07 UT-01: Tính toán thời hạn SLA phản hồi (calculateSlaDueDate)")
    void testCalculateSlaDueDate() {
        long now = 1700000000000L;
        Timestamp assignedAt = new Timestamp(now);
        int responseMinutes = 120; // 2 giờ

        Timestamp dueDate = slaService.calculateSlaDueDate(assignedAt, responseMinutes);
        assertNotNull(dueDate);
        assertEquals(now + (120 * 60 * 1000L), dueDate.getTime(), "Thời hạn phản hồi phải bằng mốc bắt đầu + số phút cấu hình");

        assertNull(slaService.calculateSlaDueDate(null, 120), "assignedAt null phải trả về null");
        assertNull(slaService.calculateSlaDueDate(assignedAt, 0), "responseMinutes <= 0 phải trả về null");
    }

    @Test
    @DisplayName("S4-07 UT-02: Kiểm tra bắt buộc lý do từ chối Lead (rejectReason mandatory)")
    void testRejectLead_MandatoryReason() {
        IllegalArgumentException ex1 = assertThrows(IllegalArgumentException.class, () -> {
            slaService.rejectLead(1, 101, null);
        });
        assertTrue(ex1.getMessage().contains("bắt buộc"));

        IllegalArgumentException ex2 = assertThrows(IllegalArgumentException.class, () -> {
            slaService.rejectLead(1, 101, "   ");
        });
        assertTrue(ex2.getMessage().contains("bắt buộc"));
    }

    @Test
    @DisplayName("S4-07 UT-03: Kiểm tra cấu hình Model LeadRecord")
    void testLeadRecord_Properties() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        Timestamp due = new Timestamp(now.getTime() + 3600000);
        LeadSlaService.LeadRecord record = new LeadSlaService.LeadRecord(10, 101, "ASSIGNED", now, due, false);

        assertEquals(10, record.getLeadId());
        assertEquals(101, record.getOwnerId());
        assertEquals("ASSIGNED", record.getStatus());
        assertEquals(now, record.getAssignedAt());
        assertEquals(due, record.getSlaDueDate());
        assertFalse(record.isOverdue());
    }

    @Test
    @DisplayName("S4-07 UT-04: Kiểm tra tính toán SLA với các mốc thời gian biên khác nhau")
    void testCalculateSlaDueDate_VariousIntervals() {
        Timestamp base = new Timestamp(1700000000000L);

        // 1 phút
        Timestamp due1 = slaService.calculateSlaDueDate(base, 1);
        assertEquals(1700000000000L + 60000L, due1.getTime());

        // 24 giờ (1440 phút)
        Timestamp due24h = slaService.calculateSlaDueDate(base, 1440);
        assertEquals(1700000000000L + (1440L * 60000L), due24h.getTime());

        // Âm hoặc 0 phút -> null
        assertNull(slaService.calculateSlaDueDate(base, -10));
    }

    @Test
    @DisplayName("S4-07 UT-05: Kiểm tra vòng đời Scheduler (start/stop) an toàn")
    void testSchedulerLifecycle_Safe() {
        assertDoesNotThrow(() -> {
            slaService.startSlaMonitor();
            slaService.startSlaMonitor(); // idempotent
            slaService.stopSlaMonitor();
            slaService.stopSlaMonitor();  // idempotent
        });
    }
}
