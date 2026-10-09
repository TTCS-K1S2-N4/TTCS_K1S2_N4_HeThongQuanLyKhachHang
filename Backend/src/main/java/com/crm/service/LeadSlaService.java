package com.crm.service;

import java.sql.Timestamp;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * Lead SLA Service
 * Manages Lead SLA tracking, Overdue flagging, and Accept/Reject business logic.
 * Uses an in-memory repository to simulate the missing 'leads' table.
 */
public class LeadSlaService {
    private static final Logger LOGGER = Logger.getLogger(LeadSlaService.class.getName());

    // SLA Configuration (24 hours in milliseconds)
    private static final long SLA_DURATION_MS = 24 * 60 * 60 * 1000L; 
    
    // Background worker for SLA monitoring
    private ScheduledExecutorService scheduler;

    // --- MOCK DATABASE FOR LEADS (For S4-07 Implementation) ---
    public static class MockLead {
        public int id;
        public Integer ownerId;
        public String status; // 'QUEUED', 'ASSIGNED', 'IN_PROGRESS', 'OVERDUE'
        public Timestamp assignedAt;
        public boolean isOverdue;
        
        public MockLead(int id, Integer ownerId, String status, Timestamp assignedAt) {
            this.id = id;
            this.ownerId = ownerId;
            this.status = status;
            this.assignedAt = assignedAt;
            this.isOverdue = false;
        }
    }

    // Shared thread-safe mock repository
    private static final Map<Integer, MockLead> mockLeads = new ConcurrentHashMap<>();
    
    // Seed some initial data for testing
    static {
        long now = System.currentTimeMillis();
        // Lead 1: Assigned to user 1, fresh
        mockLeads.put(1, new MockLead(1, 1, "ASSIGNED", new Timestamp(now)));
        // Lead 2: Assigned to user 1, SLA violated (assigned 25 hours ago)
        mockLeads.put(2, new MockLead(2, 1, "ASSIGNED", new Timestamp(now - (25 * 3600 * 1000L))));
        // Lead 3: Queued, no owner
        mockLeads.put(3, new MockLead(3, null, "QUEUED", null));
    }

    // --- BUSINESS LOGIC ---

    /**
     * 1 & 2: Nhân viên nhận Lead
     */
    public boolean acceptLead(int leadId, int userId) {
        MockLead lead = mockLeads.get(leadId);
        if (lead == null) return false;
        
        synchronized (lead) {
            // Chỉ Lead đang được assign cho user này mới được nhận
            if (lead.ownerId != null && lead.ownerId == userId && "ASSIGNED".equals(lead.status)) {
                lead.status = "IN_PROGRESS"; // Trạng thái: Đang chăm sóc
                LOGGER.info("User " + userId + " accepted Lead " + leadId + ". Status changed to IN_PROGRESS.");
                return true;
            }
        }
        return false;
    }

    /**
     * 3 & 4: Nhân viên từ chối Lead
     */
    public boolean rejectLead(int leadId, int userId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("Reject reason is mandatory");
        }
        
        MockLead lead = mockLeads.get(leadId);
        if (lead == null) return false;
        
        synchronized (lead) {
            if (lead.ownerId != null && lead.ownerId == userId) {
                // Đưa Lead về hàng chờ
                lead.ownerId = null;
                lead.status = "QUEUED"; // Quay lại hàng chờ phân bổ
                lead.assignedAt = null;
                lead.isOverdue = false;
                LOGGER.info("User " + userId + " rejected Lead " + leadId + " with reason: '" + reason + "'. Lead returned to QUEUED.");
                // Note: Logic kích hoạt lại phân bổ tự động sẽ được gọi qua LeadAssignmentService
                return true;
            }
        }
        return false;
    }

    // --- BACKGROUND SLA MONITORING ---

    /**
     * Khởi động worker quét định kỳ SLA
     */
    public synchronized void startSlaMonitor() {
        if (scheduler == null || scheduler.isShutdown()) {
            scheduler = Executors.newSingleThreadScheduledExecutor();
            // Chạy mỗi 1 phút để quét các vi phạm SLA
            scheduler.scheduleAtFixedRate(this::checkSlaOverdue, 0, 1, TimeUnit.MINUTES);
            LOGGER.info("Lead SLA Monitor Background Worker started.");
        }
    }

    public synchronized void stopSlaMonitor() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            LOGGER.info("Lead SLA Monitor Background Worker stopped.");
        }
    }

    /**
     * 5 & 6 & 7: Theo dõi SLA, gắn cờ và thông báo
     */
    public void checkSlaOverdue() {
        LOGGER.info("Running SLA Check for assigned leads...");
        long now = System.currentTimeMillis();
        
        for (MockLead lead : mockLeads.values()) {
            synchronized (lead) {
                // Chỉ kiểm tra SLA cho các Lead đang chờ phản hồi (ASSIGNED)
                if ("ASSIGNED".equals(lead.status) && lead.assignedAt != null) {
                    long timeElapsed = now - lead.assignedAt.getTime();
                    
                    if (timeElapsed > SLA_DURATION_MS && !lead.isOverdue) {
                        // 6: Gắn cờ quá hạn
                        lead.isOverdue = true;
                        lead.status = "OVERDUE";
                        
                        LOGGER.warning("SLA VIOLATION: Lead " + lead.id + " is overdue! (Assigned to User " + lead.ownerId + ")");
                        
                        // 7: Thông báo cho trưởng nhóm
                        notifyTeamLeader(lead);
                    }
                }
            }
        }
    }
    
    private void notifyTeamLeader(MockLead lead) {
        // Stub for Notification System
        LOGGER.info("NOTIFICATION SENT TO TEAM LEADER: Lead " + lead.id + " assigned to User " + lead.ownerId + " has exceeded the SLA of 24 hours.");
    }
}
