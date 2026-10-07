package com.crm.dao;

import com.crm.model.CustomerRisk;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO tính toán rủi ro rời bỏ khách hàng (Churn Risk) dựa trên yêu cầu hỗ trợ tồn đọng.
 * 100% PreparedStatement, Task S30-09 / S3-08.
 */
public class CustomerRiskDAO {

    private static final Logger LOGGER = Logger.getLogger(CustomerRiskDAO.class.getName());

    public int countPendingTickets(int customerId) {
        String sql = "SELECT COUNT(*) FROM support_requests WHERE customer_id = ? AND status IN ('OPEN', 'IN_PROGRESS')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng vé pending cho customerId: " + customerId, e);
        }
        return 0;
    }

    public int countUrgentPendingTickets(int customerId) {
        String sql = "SELECT COUNT(*) FROM support_requests WHERE customer_id = ? AND status IN ('OPEN', 'IN_PROGRESS') AND priority = 'URGENT'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng vé URGENT pending cho customerId: " + customerId, e);
        }
        return 0;
    }

    public CustomerRisk calculateRisk(int customerId, int threshold) {
        int pending = countPendingTickets(customerId);
        int urgent = countUrgentPendingTickets(customerId);

        boolean isRisk = false;
        String reason;

        if (urgent > 0) {
            isRisk = true;
            reason = "Khách hàng có " + urgent + " yêu cầu hỗ trợ khẩn cấp (URGENT) chưa được giải quyết.";
        } else if (pending >= threshold) {
            isRisk = true;
            reason = "Khách hàng có " + pending + " yêu cầu hỗ trợ tồn đọng (vượt ngưỡng cho phép: " + threshold + ").";
        } else {
            isRisk = false;
            reason = "Mức độ hài lòng ổn định (" + pending + " yêu cầu đang xử lý, dưới ngưỡng " + threshold + ").";
        }

        return new CustomerRisk(customerId, isRisk, reason, pending, threshold);
    }
}
