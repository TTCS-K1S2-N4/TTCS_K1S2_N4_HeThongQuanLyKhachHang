package com.crm.dao;

import com.crm.model.WinLossReason;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WinLossReasonDAO {

    public List<WinLossReason> findAll(String reasonType) {
        List<WinLossReason> list = new ArrayList<>();
        String sql = "SELECT * FROM win_loss_reasons ";
        if (reasonType != null && !reasonType.isEmpty()) {
            sql += "WHERE reason_type = ? ";
        }
        sql += "ORDER BY display_order ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            if (reasonType != null && !reasonType.isEmpty()) {
                ps.setString(1, reasonType);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public WinLossReason findById(int id) {
        String sql = "SELECT * FROM win_loss_reasons WHERE reason_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(WinLossReason reason) {
        String sql = "INSERT INTO win_loss_reasons (reason_type, reason_name, display_order, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, reason.getReasonType());
            ps.setString(2, reason.getReasonName());
            ps.setInt(3, reason.getDisplayOrder());
            ps.setString(4, reason.getStatus());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        reason.setReasonId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(WinLossReason reason) {
        String sql = "UPDATE win_loss_reasons SET reason_type = ?, reason_name = ?, display_order = ?, status = ? WHERE reason_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason.getReasonType());
            ps.setString(2, reason.getReasonName());
            ps.setInt(3, reason.getDisplayOrder());
            ps.setString(4, reason.getStatus());
            ps.setInt(5, reason.getReasonId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private WinLossReason mapRow(ResultSet rs) throws SQLException {
        WinLossReason r = new WinLossReason();
        r.setReasonId(rs.getInt("reason_id"));
        r.setReasonType(rs.getString("reason_type"));
        r.setReasonName(rs.getString("reason_name"));
        r.setDisplayOrder(rs.getInt("display_order"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        return r;
    }
}
