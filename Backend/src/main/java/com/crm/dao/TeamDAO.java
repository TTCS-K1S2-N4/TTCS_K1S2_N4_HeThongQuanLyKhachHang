package com.crm.dao;

import com.crm.model.Team;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TeamDAO {

    public List<Team> findAll() throws SQLException {

        List<Team> teams = new ArrayList<>();

        String sql =
                "SELECT id, name, description " +
                "FROM teams ORDER BY name";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement =
                    connection.prepareStatement(sql);
            ResultSet resultSet = statement.executeQuery()
        ) {

            while (resultSet.next()) {

                Team team = new Team();

                team.setId(resultSet.getInt("id"));
                team.setName(resultSet.getString("name"));
                team.setDescription(
                        resultSet.getString("description")
                );

                teams.add(team);
            }
        }

        return teams;
    }

    public Team findById(int id) throws SQLException {

        String sql =
                "SELECT id, name, description " +
                "FROM teams WHERE id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement =
                    connection.prepareStatement(sql)
        ) {

            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Team team = new Team();

                    team.setId(resultSet.getInt("id"));
                    team.setName(resultSet.getString("name"));
                    team.setDescription(
                            resultSet.getString("description")
                    );

                    return team;
                }
            }
        }

        return null;
    }
}