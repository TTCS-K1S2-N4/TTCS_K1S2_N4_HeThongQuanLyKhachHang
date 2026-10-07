package com.crm.dao;

import com.crm.model.Customer;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer obj = new Customer();
        obj.setCustomerid(rs.getInt("customer_id"));
        obj.setCustomername(rs.getString("customer_name"));
        obj.setPhone(rs.getString("phone"));
        obj.setOwnerId(rs.getInt("owner_id"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));
        return obj;
    }

    public List<Customer> getList(String keyword, List<Integer> ownerIds, int page, int pageSize) {
        return getList(keyword, ownerIds, null, null, page, pageSize);
    }

    public List<Customer> getList(String keyword, List<Integer> ownerIds, Integer filterFieldId, String filterFieldValue, int page, int pageSize) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Customer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT DISTINCT c.* FROM customers c ");
        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("JOIN custom_field_values cfv ON c.customer_id = cfv.entity_id AND cfv.entity_type = 'CUSTOMER' ");
        }
        sql.append("WHERE 1=1 ");
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND c.customer_name LIKE ? ");
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append("AND c.owner_id IN (").append(inClause).append(") ");
        }

        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("AND cfv.field_id = ? AND cfv.field_value LIKE ? ");
        }
        
        sql.append("ORDER BY c.customer_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
                ps.setInt(idx++, filterFieldId);
                ps.setString(idx++, "%" + filterFieldValue.trim() + "%");
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx++, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Customer> getListForExport(String keyword, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM customers WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND customer_name LIKE ?";
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }
        
        sql += " ORDER BY customer_id DESC";

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
            while (rs.next()) {
                list.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int count(String keyword, List<Integer> ownerIds) {
        return count(keyword, ownerIds, null, null);
    }

    public int count(String keyword, List<Integer> ownerIds, Integer filterFieldId, String filterFieldValue) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;
        
        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT c.customer_id) FROM customers c ");
        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("JOIN custom_field_values cfv ON c.customer_id = cfv.entity_id AND cfv.entity_type = 'CUSTOMER' ");
        }
        sql.append("WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND c.customer_name LIKE ? ");
        }
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append("AND c.owner_id IN (").append(inClause).append(") ");
        }
        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("AND cfv.field_id = ? AND cfv.field_value LIKE ? ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
                ps.setInt(idx++, filterFieldId);
                ps.setString(idx++, "%" + filterFieldValue.trim() + "%");
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

    public Customer findById(int id) {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(Customer customer) {
        String sql = "INSERT INTO customers (customer_name, phone, owner_id) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customer.getCustomerName());
            ps.setString(2, customer.getPhone());
            ps.setInt(3, customer.getOwnerId());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        customer.setCustomerId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Customer customer) {
        String sql = "UPDATE customers SET customer_name = ?, phone = ?, owner_id = ? WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customer.getCustomerName());
            ps.setString(2, customer.getPhone());
            ps.setInt(3, customer.getOwnerId());
            ps.setInt(4, customer.getCustomerId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int customerId) {
        String sql = "DELETE FROM customers WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

