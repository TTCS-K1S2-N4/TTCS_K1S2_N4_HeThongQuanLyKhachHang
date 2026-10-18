package com.crm.listener;

import com.crm.service.LeadSlaService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.logging.Logger;

/**
 * LeadSlaContextListener - Tự động khởi động và dừng background worker giám sát SLA Lead (S4-07).
 * Chạy quét định kỳ kiểm tra các Lead quá hạn SLA để gắn cờ và tạo thông báo cho Trưởng nhóm.
 */
@WebListener
public class LeadSlaContextListener implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(LeadSlaContextListener.class.getName());
    private LeadSlaService slaService;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("LeadSlaContextListener: Đang khởi động tiến trình giám sát SLA định kỳ...");
        try {
            this.slaService = new LeadSlaService();
            this.slaService.startSlaMonitor();
            LOGGER.info("LeadSlaContextListener: Giám sát SLA định kỳ khởi động thành công.");
        } catch (Exception e) {
            LOGGER.warning("LeadSlaContextListener: Không thể khởi động SLA Monitor: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("LeadSlaContextListener: Đang dừng tiến trình giám sát SLA...");
        if (this.slaService != null) {
            this.slaService.stopSlaMonitor();
        }
    }
}
