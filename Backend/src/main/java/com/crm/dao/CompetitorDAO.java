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

public class CompetitorDAO {

    private static final Logger LOGGER = Logger.getLogger(CompetitorDAO.class.getName());

    public static class CompetitorItem {
        private int competitorId;
        private String competitorName;
        private String website;
        private String strengths;
        private String weaknesses;
        private String notes;

        public CompetitorItem() {}

        public CompetitorItem(int competitorId, String competitorName, String website, String strengths, String weaknesses, String notes) {
            this.competitorId = competitorId;
            this.competitorName = competitorName;
            this.website = website;
            this.strengths = strengths;
            this.weaknesses = weaknesses;
            this.notes = notes;
        }

        public int getCompetitorId() { return competitorId; }
        public void setCompetitorId(int competitorId) { this.competitorId = competitorId; }

        public String getCompetitorName() { return competitorName; }
        public void setCompetitorName(String competitorName) { this.competitorName = competitorName; }

        public String getWebsite() { return website; }
        public void setWebsite(String website) { this.website = website; }

        public String getStrengths() { return strengths; }
        public void setStrengths(String strengths) { this.strengths = strengths; }

        public String getWeaknesses() { return weaknesses; }
        public void setWeaknesses(String weaknesses) { this.weaknesses = weaknesses; }

        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; }
    }

    public List<CompetitorItem> getAllCompetitors() {
        List<CompetitorItem> list = new ArrayList<>();
        String sql = "SELECT competitor_id, competitor_name, website, strengths, weaknesses, notes FROM competitors ORDER BY competitor_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CompetitorItem item = new CompetitorItem();
                item.setCompetitorId(rs.getInt("competitor_id"));
                item.setCompetitorName(rs.getString("competitor_name"));
                item.setWebsite(rs.getString("website"));
                item.setStrengths(rs.getString("strengths"));
                item.setWeaknesses(rs.getString("weaknesses"));
                item.setNotes(rs.getString("notes"));
                list.add(item);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách đối thủ cạnh tranh", e);
        }
        return list;
    }

    public CompetitorItem getCompetitorById(int competitorId) {
        String sql = "SELECT competitor_id, competitor_name, website, strengths, weaknesses, notes FROM competitors WHERE competitor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, competitorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CompetitorItem item = new CompetitorItem();
                    item.setCompetitorId(rs.getInt("competitor_id"));
                    item.setCompetitorName(rs.getString("competitor_name"));
                    item.setWebsite(rs.getString("website"));
                    item.setStrengths(rs.getString("strengths"));
                    item.setWeaknesses(rs.getString("weaknesses"));
                    item.setNotes(rs.getString("notes"));
                    return item;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy chi tiết đối thủ ID: " + competitorId, e);
        }
        return null;
    }

    public boolean createCompetitor(CompetitorItem item) {
        String sql = "INSERT INTO competitors (competitor_name, website, strengths, weaknesses, notes) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getCompetitorName());
            ps.setString(2, item.getWebsite());
            ps.setString(3, item.getStrengths());
            ps.setString(4, item.getWeaknesses());
            ps.setString(5, item.getNotes());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setCompetitorId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo đối thủ mới", e);
        }
        return false;
    }

    public boolean updateCompetitor(CompetitorItem item) {
        String sql = "UPDATE competitors SET competitor_name = ?, website = ?, strengths = ?, weaknesses = ?, notes = ? WHERE competitor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getCompetitorName());
            ps.setString(2, item.getWebsite());
            ps.setString(3, item.getStrengths());
            ps.setString(4, item.getWeaknesses());
            ps.setString(5, item.getNotes());
            ps.setInt(6, item.getCompetitorId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật đối thủ ID: " + item.getCompetitorId(), e);
        }
        return false;
    }

    public boolean deleteCompetitor(int competitorId) {
        String sql = "DELETE FROM competitors WHERE competitor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, competitorId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa đối thủ ID: " + competitorId, e);
        }
        return false;
    }
}
