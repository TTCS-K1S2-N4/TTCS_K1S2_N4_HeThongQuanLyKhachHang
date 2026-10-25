package com.crm.dao;

import com.crm.model.Competitor;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CompetitorDAO {

    public List<Competitor> findAll() {
        List<Competitor> list = new ArrayList<>();
        String sql = "SELECT * FROM competitors ORDER BY competitor_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Competitor findById(int id) {
        String sql = "SELECT * FROM competitors WHERE competitor_id = ?";
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

    public boolean insert(Competitor comp) {
        String sql = "INSERT INTO competitors (competitor_name, status) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, comp.getCompetitorName());
            ps.setString(2, comp.getStatus());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        comp.setCompetitorId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Competitor comp) {
        String sql = "UPDATE competitors SET competitor_name = ?, status = ? WHERE competitor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, comp.getCompetitorName());
            ps.setString(2, comp.getStatus());
            ps.setInt(3, comp.getCompetitorId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Competitor mapRow(ResultSet rs) throws SQLException {
        Competitor c = new Competitor();
        c.setCompetitorId(rs.getInt("competitor_id"));
        c.setCompetitorName(rs.getString("competitor_name"));
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        return c;
    }
}
