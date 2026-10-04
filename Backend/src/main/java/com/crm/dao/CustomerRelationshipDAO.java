package com.crm.dao;

import com.crm.model.CustomerRelationship;
import com.crm.model.Customer;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerRelationshipDAO {

    private CustomerRelationship mapResultSet(ResultSet rs) throws SQLException {
        CustomerRelationship cr = new CustomerRelationship();
        cr.setRelationshipId(rs.getInt("relationship_id"));
        cr.setParentCustomerId(rs.getInt("parent_customer_id"));
        cr.setChildCustomerId(rs.getInt("child_customer_id"));
        cr.setRelationshipType(rs.getString("relationship_type"));
        cr.setCreatedAt(rs.getTimestamp("created_at"));
        
        try {
            String pName = rs.getString("parent_name");
            if (pName != null) {
                Customer p = new Customer();
                p.setCustomerId(rs.getInt("parent_customer_id"));
                p.setCustomerName(pName);
                cr.setParentCustomer(p);
            }
        } catch (SQLException ignore) {}

        try {
            String cName = rs.getString("child_name");
            if (cName != null) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("child_customer_id"));
                c.setCustomerName(cName);
                cr.setChildCustomer(c);
            }
        } catch (SQLException ignore) {}

        return cr;
    }

    public List<CustomerRelationship> getChildren(int parentId) {
        List<CustomerRelationship> list = new ArrayList<>();
        String sql = "SELECT cr.*, c.customer_name AS child_name " +
                     "FROM customer_relationships cr " +
                     "JOIN customers c ON cr.child_customer_id = c.customer_id " +
                     "WHERE cr.parent_customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomerRelationship> getParents(int childId) {
        List<CustomerRelationship> list = new ArrayList<>();
        String sql = "SELECT cr.*, c.customer_name AS parent_name " +
                     "FROM customer_relationships cr " +
                     "JOIN customers c ON cr.parent_customer_id = c.customer_id " +
                     "WHERE cr.child_customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, childId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addRelationship(int parentId, int childId, String type) {
        String sql = "INSERT INTO customer_relationships(parent_customer_id, child_customer_id, relationship_type) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, childId);
            ps.setString(3, type != null ? type : "SUBSIDIARY");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteRelationship(int relationshipId) {
        String sql = "DELETE FROM customer_relationships WHERE relationship_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, relationshipId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
