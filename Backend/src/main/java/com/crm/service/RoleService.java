package com.crm.service;

import com.crm.dao.RoleDAO;
import com.crm.dao.TeamDAO;
import com.crm.model.Role;
import com.crm.model.Team;

import java.sql.SQLException;
import java.util.List;

public class RoleService {

    private final RoleDAO roleDAO;
    private final TeamDAO teamDAO;

    public RoleService() {
        this.roleDAO = new RoleDAO();
        this.teamDAO = new TeamDAO();
    }

    public List<Role> getAllRoles() throws SQLException {
        return roleDAO.findAll();
    }

    public List<Team> getAllTeams() throws SQLException {
        return teamDAO.findAll();
    }

    public boolean isValidRole(int roleId) throws SQLException {
        return roleDAO.findById(roleId) != null;
    }

    public boolean isValidTeam(int teamId) throws SQLException {
        return teamDAO.findById(teamId) != null;
    }
}