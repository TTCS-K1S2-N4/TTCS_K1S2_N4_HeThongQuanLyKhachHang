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
                "SELECT t.team_id AS id, t.team_name AS name, t.description, " +
                "       t.parent_team_id, pt.team_name AS parent_team_name, " +
                "       t.leader_id, u.full_name AS leader_name, " +
                "       t.region, t.created_at, t.updated_at " +
                "FROM teams t " +
                "LEFT JOIN teams pt ON t.parent_team_id = pt.team_id " +
                "LEFT JOIN users u ON t.leader_id = u.user_id " +
                "ORDER BY t.team_id ASC";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql);
            ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                teams.add(mapResultSetToTeam(resultSet));
            }
        }
        return teams;
    }

    public Team findById(int id) throws SQLException {
        String sql =
                "SELECT t.team_id AS id, t.team_name AS name, t.description, " +
                "       t.parent_team_id, pt.team_name AS parent_team_name, " +
                "       t.leader_id, u.full_name AS leader_name, " +
                "       t.region, t.created_at, t.updated_at " +
                "FROM teams t " +
                "LEFT JOIN teams pt ON t.parent_team_id = pt.team_id " +
                "LEFT JOIN users u ON t.leader_id = u.user_id " +
                "WHERE t.team_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToTeam(resultSet);
                }
            }
        }
        return null;
    }

    public Team findByName(String teamName) throws SQLException {
        String sql =
                "SELECT t.team_id AS id, t.team_name AS name, t.description, " +
                "       t.parent_team_id, pt.team_name AS parent_team_name, " +
                "       t.leader_id, u.full_name AS leader_name, " +
                "       t.region, t.created_at, t.updated_at " +
                "FROM teams t " +
                "LEFT JOIN teams pt ON t.parent_team_id = pt.team_id " +
                "LEFT JOIN users u ON t.leader_id = u.user_id " +
                "WHERE t.team_name = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, teamName);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToTeam(resultSet);
                }
            }
        }
        return null;
    }

    public boolean existsByNameExcludingId(String teamName, int excludeTeamId) throws SQLException {
        String sql = "SELECT 1 FROM teams WHERE LOWER(team_name) = LOWER(?) AND team_id <> ?";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, teamName);
            statement.setInt(2, excludeTeamId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public Team findTeamByLeaderIdExcludingTeamId(int leaderId, int excludeTeamId) throws SQLException {
        if (leaderId <= 0) return null;
        String sql =
                "SELECT t.team_id AS id, t.team_name AS name, t.description, " +
                "       t.parent_team_id, pt.team_name AS parent_team_name, " +
                "       t.leader_id, u.full_name AS leader_name, " +
                "       t.region, t.created_at, t.updated_at " +
                "FROM teams t " +
                "LEFT JOIN teams pt ON t.parent_team_id = pt.team_id " +
                "LEFT JOIN users u ON t.leader_id = u.user_id " +
                "WHERE t.leader_id = ? AND t.team_id <> ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, leaderId);
            statement.setInt(2, excludeTeamId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToTeam(resultSet);
                }
            }
        }
        return null;
    }

    public boolean insert(Team team) throws SQLException {
        String sql =
                "INSERT INTO teams (team_name, description, parent_team_id, leader_id, region) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            statement.setString(1, team.getName());
            statement.setString(2, team.getDescription());

            if (team.getParentTeamId() != null && team.getParentTeamId() > 0) {
                statement.setInt(3, team.getParentTeamId());
            } else {
                statement.setNull(3, Types.INTEGER);
            }

            if (team.getLeaderId() != null && team.getLeaderId() > 0) {
                statement.setInt(4, team.getLeaderId());
            } else {
                statement.setNull(4, Types.INTEGER);
            }

            statement.setString(5, team.getRegion());

            int affectedRows = statement.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        team.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public boolean update(Team team) throws SQLException {
        String sql =
                "UPDATE teams SET team_name = ?, description = ?, parent_team_id = ?, leader_id = ?, region = ? " +
                "WHERE team_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, team.getName());
            statement.setString(2, team.getDescription());

            if (team.getParentTeamId() != null && team.getParentTeamId() > 0) {
                statement.setInt(3, team.getParentTeamId());
            } else {
                statement.setNull(3, Types.INTEGER);
            }

            if (team.getLeaderId() != null && team.getLeaderId() > 0) {
                statement.setInt(4, team.getLeaderId());
            } else {
                statement.setNull(4, Types.INTEGER);
            }

            statement.setString(5, team.getRegion());
            statement.setInt(6, team.getId());

            return statement.executeUpdate() > 0;
        }
    }

    private Team mapResultSetToTeam(ResultSet resultSet) throws SQLException {
        Team team = new Team();
        team.setId(resultSet.getInt("id"));
        team.setName(resultSet.getString("name"));
        team.setDescription(resultSet.getString("description"));

        int parentTeamId = resultSet.getInt("parent_team_id");
        if (!resultSet.wasNull()) {
            team.setParentTeamId(parentTeamId);
        }
        team.setParentTeamName(resultSet.getString("parent_team_name"));

        int leaderId = resultSet.getInt("leader_id");
        if (!resultSet.wasNull()) {
            team.setLeaderId(leaderId);
        }
        team.setLeaderName(resultSet.getString("leader_name"));

        team.setRegion(resultSet.getString("region"));
        team.setCreatedAt(resultSet.getTimestamp("created_at"));
        team.setUpdatedAt(resultSet.getTimestamp("updated_at"));

        return team;
    }
}