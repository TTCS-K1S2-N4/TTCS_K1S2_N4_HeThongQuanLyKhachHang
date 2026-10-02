package com.crm.dao;

import com.crm.model.PipelineStage;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PipelineStageDAO {

    public List<PipelineStage> findAll() {
        List<PipelineStage> list = new ArrayList<>();
        String sql = "SELECT * FROM pipeline_stages ORDER BY display_order ASC";
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

    public PipelineStage findById(int id) {
        String sql = "SELECT * FROM pipeline_stages WHERE pipeline_stage_id = ?";
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

    public boolean insert(PipelineStage stage) {
        String sql = "INSERT INTO pipeline_stages (stage_name, display_order, default_probability, exit_condition, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, stage.getStageName());
            ps.setInt(2, stage.getDisplayOrder());
            ps.setDouble(3, stage.getDefaultProbability());
            ps.setString(4, stage.getExitCondition());
            ps.setString(5, stage.getStatus());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        stage.setPipelineStageId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(PipelineStage stage) {
        String sql = "UPDATE pipeline_stages SET stage_name = ?, display_order = ?, default_probability = ?, exit_condition = ?, status = ? WHERE pipeline_stage_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stage.getStageName());
            ps.setInt(2, stage.getDisplayOrder());
            ps.setDouble(3, stage.getDefaultProbability());
            ps.setString(4, stage.getExitCondition());
            ps.setString(5, stage.getStatus());
            ps.setInt(6, stage.getPipelineStageId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int pipelineStageId, String status) {
        String sql = "UPDATE pipeline_stages SET status = ? WHERE pipeline_stage_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, pipelineStageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean updateOrder(int pipelineStageId, int displayOrder) {
        String sql = "UPDATE pipeline_stages SET display_order = ? WHERE pipeline_stage_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, displayOrder);
            ps.setInt(2, pipelineStageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private PipelineStage mapRow(ResultSet rs) throws SQLException {
        PipelineStage p = new PipelineStage();
        p.setPipelineStageId(rs.getInt("pipeline_stage_id"));
        p.setStageName(rs.getString("stage_name"));
        p.setDisplayOrder(rs.getInt("display_order"));
        p.setDefaultProbability(rs.getDouble("default_probability"));
        p.setExitCondition(rs.getString("exit_condition"));
        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }
}
