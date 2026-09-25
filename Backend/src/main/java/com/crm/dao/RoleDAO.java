package com.crm.dao;

import com.crm.model.Role;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {

    public List<Role> findAll() throws SQLException {

        List<Role> roles = new ArrayList<>();

        String sql =
                "SELECT id, code, name, description " +
                "FROM roles ORDER BY name";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement =
                    connection.prepareStatement(sql);
            ResultSet resultSet = statement.executeQuery()
        ) {

            while (resultSet.next()) {

                Role role = new Role();

                role.setId(resultSet.getInt("id"));
                role.setCode(resultSet.getString("code"));
                role.setName(resultSet.getString("name"));
                role.setDescription(
                        resultSet.getString("description")
                );

                roles.add(role);
            }
        }

        return roles;
    }

    public Role findById(int id) throws SQLException {

        String sql =
                "SELECT id, code, name, description " +
                "FROM roles WHERE id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement =
                    connection.prepareStatement(sql)
        ) {

            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Role role = new Role();

                    role.setId(resultSet.getInt("id"));
                    role.setCode(resultSet.getString("code"));
                    role.setName(resultSet.getString("name"));
                    role.setDescription(
                            resultSet.getString("description")
                    );

                    return role;
                }
            }
        }

        return null;
    }
}