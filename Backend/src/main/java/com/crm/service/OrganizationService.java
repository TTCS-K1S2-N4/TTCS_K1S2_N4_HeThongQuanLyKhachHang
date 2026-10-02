package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dao.TeamDAO;
import com.crm.model.Team;

import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrganizationService {

    private static final Logger LOGGER = Logger.getLogger(OrganizationService.class.getName());

    private TeamDAO teamDAO = new TeamDAO();
    private AccountDAO accountDAO = new AccountDAO();

    public OrganizationService() {
    }

    public OrganizationService(TeamDAO teamDAO, AccountDAO accountDAO) {
        if (teamDAO != null) this.teamDAO = teamDAO;
        if (accountDAO != null) this.accountDAO = accountDAO;
    }

    public void setTeamDAO(TeamDAO teamDAO) {
        if (teamDAO != null) {
            this.teamDAO = teamDAO;
        }
    }

    public void setAccountDAO(AccountDAO accountDAO) {
        if (accountDAO != null) {
            this.accountDAO = accountDAO;
        }
    }

    public List<Team> getAllTeams() {
        try {
            return teamDAO.findAll();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách nhóm kinh doanh: ", e);
            throw new RuntimeException("Lỗi hệ thống khi lấy danh sách nhóm kinh doanh: " + e.getMessage(), e);
        }
    }

    public Team getTeamById(int teamId) {
        if (teamId <= 0) {
            return null;
        }
        try {
            return teamDAO.findById(teamId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy thông tin nhóm kinh doanh ID=" + teamId, e);
            throw new RuntimeException("Lỗi hệ thống khi lấy thông tin nhóm: " + e.getMessage(), e);
        }
    }

    public boolean saveOrUpdateTeam(Team team, List<String> errors) {
        if (team == null) {
            errors.add("Dữ liệu nhóm kinh doanh không hợp lệ.");
            return false;
        }

        // Server-side Validation
        if (team.getName() == null || team.getName().trim().isEmpty()) {
            errors.add("Tên nhóm kinh doanh không được để trống.");
        } else if (team.getName().trim().length() > 100) {
            errors.add("Tên nhóm kinh doanh không được vượt quá 100 ký tự.");
        } else {
            team.setName(team.getName().trim());
        }

        if (team.getDescription() != null) {
            team.setDescription(team.getDescription().trim());
        }

        if (team.getRegion() != null) {
            team.setRegion(team.getRegion().trim());
        }

        try {
            // Uniqueness check for teamName
            if (team.getName() != null && !team.getName().isEmpty()) {
                if (teamDAO.existsByNameExcludingId(team.getName(), team.getId())) {
                    errors.add("Tên nhóm kinh doanh '" + team.getName() + "' đã tồn tại.");
                }
            }

            // Parent team validation
            if (team.getParentTeamId() != null && team.getParentTeamId() > 0) {
                if (team.getId() > 0 && team.getParentTeamId().equals(team.getId())) {
                    errors.add("Nhóm kinh doanh không thể chọn chính mình làm nhóm cha.");
                } else {
                    Team parentTeam = teamDAO.findById(team.getParentTeamId());
                    if (parentTeam == null) {
                        errors.add("Nhóm cha với ID " + team.getParentTeamId() + " không tồn tại.");
                    }
                }
            } else {
                team.setParentTeamId(null);
            }

            // Leader validation
            if (team.getLeaderId() != null && team.getLeaderId() > 0) {
                com.crm.model.Account leader = accountDAO.getAccountById(team.getLeaderId());
                if (leader == null) {
                    errors.add("Trưởng nhóm (Leader) với ID " + team.getLeaderId() + " không tồn tại.");
                }
            } else {
                team.setLeaderId(null);
            }

            if (!errors.isEmpty()) {
                return false;
            }

            // Insert or Update
            if (team.getId() > 0) {
                Team existing = teamDAO.findById(team.getId());
                if (existing == null) {
                    errors.add("Không tìm thấy nhóm kinh doanh với ID: " + team.getId());
                    return false;
                }
                return teamDAO.update(team);
            } else {
                return teamDAO.insert(team);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lưu thông tin nhóm kinh doanh: ", e);
            errors.add("Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        }
    }
}
