package com.crm.dao;

import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PipelineStageDAO {

    private static final Logger LOGGER = Logger.getLogger(PipelineStageDAO.class.getName());

    public static class PipelineStageItem {
        private int stageId;
        private String stageName;
        private int probability; // % win chance
        private int displayOrder;
        private String description;

        public PipelineStageItem() {}

        public PipelineStageItem(int stageId, String stageName, int probability, int displayOrder, String description) {
            this.stageId = stageId;
            this.stageName = stageName;
            this.probability = probability;
            this.displayOrder = displayOrder;
            this.description = description;
        }

        public int getStageId() { return stageId; }
        public void setStageId(int stageId) { this.stageId = stageId; }

        public String getStageName() { return stageName; }
        public void setStageName(String stageName) { this.stageName = stageName; }

        public int getProbability() { return probability; }
        public void setProbability(int probability) { this.probability = probability; }

        public int getDisplayOrder() { return displayOrder; }
        public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
    }

    public List<PipelineStageItem> getAllStages() {
        List<PipelineStageItem> list = new ArrayList<>();
        String sql = "SELECT stage_id, stage_name, probability, display_order, description FROM pipeline_stages ORDER BY display_order ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PipelineStageItem item = new PipelineStageItem();
                item.setStageId(rs.getInt("stage_id"));
                item.setStageName(rs.getString("stage_name"));
                item.setProbability(rs.getInt("probability"));
                item.setDisplayOrder(rs.getInt("display_order"));
                item.setDescription(rs.getString("description"));
                list.add(item);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách giai đoạn cơ hội", e);
        }
        return list;
    }

    public PipelineStageItem getStageById(int stageId) {
        String sql = "SELECT stage_id, stage_name, probability, display_order, description FROM pipeline_stages WHERE stage_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stageId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PipelineStageItem item = new PipelineStageItem();
                    item.setStageId(rs.getInt("stage_id"));
                    item.setStageName(rs.getString("stage_name"));
                    item.setProbability(rs.getInt("probability"));
                    item.setDisplayOrder(rs.getInt("display_order"));
                    item.setDescription(rs.getString("description"));
                    return item;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy chi tiết giai đoạn ID: " + stageId, e);
        }
        return null;
    }

    public boolean createStage(PipelineStageItem item) {
        String sql = "INSERT INTO pipeline_stages (stage_name, probability, display_order, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getStageName());
            ps.setInt(2, item.getProbability());
            ps.setInt(3, item.getDisplayOrder());
            ps.setString(4, item.getDescription());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setStageId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo giai đoạn mới", e);
        }
        return false;
    }

    public boolean updateStage(PipelineStageItem item) {
        String sql = "UPDATE pipeline_stages SET stage_name = ?, probability = ?, display_order = ?, description = ? WHERE stage_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getStageName());
            ps.setInt(2, item.getProbability());
            ps.setInt(3, item.getDisplayOrder());
            ps.setString(4, item.getDescription());
            ps.setInt(5, item.getStageId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật giai đoạn ID: " + item.getStageId(), e);
        }
        return false;
    }

    public boolean deleteStage(int stageId) {
        String sql = "DELETE FROM pipeline_stages WHERE stage_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa giai đoạn ID: " + stageId, e);
        }
        return false;
    }
}
