package com.crm.dao;

import com.crm.model.Quote;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuoteDAO {

    private Quote mapResultSetToQuote(ResultSet rs) throws SQLException {
        Quote obj = new Quote();
        obj.setQuoteid(rs.getInt("quote_id"));
        obj.setQuotenumber(rs.getString("quote_number"));
        obj.setOwnerId(rs.getInt("owner_id"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));
        return obj;
    }

    public List<Quote> getList(String keyword, List<Integer> ownerIds, int page, int pageSize) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Quote> list = new ArrayList<>();
        String sql = "SELECT * FROM quotes WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND quote_number LIKE ?";
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }
        
        sql += " ORDER BY quote_id DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx++, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToQuote(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int count(String keyword, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;
        
        String sql = "SELECT COUNT(*) FROM quotes WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND quote_number LIKE ?";
        }
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Quote findById(int id) {
        String sql = "SELECT * FROM quotes WHERE quote_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToQuote(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
