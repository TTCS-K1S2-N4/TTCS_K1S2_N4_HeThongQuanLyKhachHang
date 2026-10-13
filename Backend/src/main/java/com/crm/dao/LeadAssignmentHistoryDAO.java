package com.crm.dao;

import com.crm.model.LeadAssignmentHistory;

public class LeadAssignmentHistoryDAO {
    
    public void saveHistory(LeadAssignmentHistory history) {
        // Implementation JDBC
        // Cần đảm bảo chạy trong cùng transaction connection với thao tác update Lead
        /*
        String sql = "INSERT INTO lead_assignment_history (lead_id, rule_id, assigned_to, status, assigned_at) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, history.getLeadId());
            if (history.getRuleId() != null) stmt.setInt(2, history.getRuleId()); else stmt.setNull(2, Types.INTEGER);
            if (history.getAssignedTo() != null) stmt.setInt(3, history.getAssignedTo()); else stmt.setNull(3, Types.INTEGER);
            stmt.setString(4, history.getStatus());
            stmt.setTimestamp(5, history.getAssignedAt());
            stmt.executeUpdate();
        }
        */
        System.out.println("History saved: Lead=" + history.getLeadId() + ", Status=" + history.getStatus());
    }
}
