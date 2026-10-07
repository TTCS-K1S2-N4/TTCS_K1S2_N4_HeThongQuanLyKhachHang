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

    public boolean isCircularHierarchy(int teamId, Integer proposedParentId) {
        if (proposedParentId == null || proposedParentId <= 0) {
            return false;
        }
        if (teamId > 0 && teamId == proposedParentId) {
            return true;
        }
        Integer currentId = proposedParentId;
        int maxDepth = 100;
        int depth = 0;
        while (currentId != null && currentId > 0 && depth < maxDepth) {
            if (teamId > 0 && currentId == teamId) {
                return true;
            }
            try {
                Team parent = teamDAO.findById(currentId);
                if (parent == null) break;
                currentId = parent.getParentTeamId();
            } catch (SQLException e) {
                break;
            }
            depth++;
        }
        return false;
    }

    public boolean updateUserTeamId(int userId, Integer newTeamId) {
        if (accountDAO != null) {
            return accountDAO.updateUserTeam(userId, newTeamId);
        }
        String sql = "UPDATE users SET team_id = ? WHERE user_id = ?";
        try (java.sql.Connection conn = com.crm.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (newTeamId != null && newTeamId > 0) {
                ps.setInt(1, newTeamId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi chuyển nhóm cho user ID=" + userId, e);
            return false;
        }
    }

    public boolean transferUserToTeam(int userId, Integer sourceTeamId, Integer targetTeamId, List<String> errors) {
        if (userId <= 0) {
            errors.add("Vui lòng chọn nhân viên cần chuyển nhóm.");
            return false;
        }
        com.crm.model.Account acc = accountDAO.getAccountById(userId);
        if (acc == null) {
            errors.add("Người dùng không tồn tại với ID: " + userId);
            return false;
        }
        if (sourceTeamId == null || sourceTeamId <= 0) {
            errors.add("Vui lòng chọn nhóm nguồn (nhóm hiện tại) của nhân viên.");
            return false;
        }
        if (targetTeamId == null || targetTeamId <= 0) {
            errors.add("Vui lòng chọn nhóm đích chuyển đến.");
            return false;
        }
        if (sourceTeamId.equals(targetTeamId)) {
            errors.add("Nhóm đích phải khác với nhóm hiện tại.");
            return false;
        }

        try {
            Team sourceTeam = teamDAO.findById(sourceTeamId);
            if (sourceTeam == null) {
                errors.add("Nhóm nguồn không tồn tại với ID: " + sourceTeamId);
                return false;
            }
            Team targetTeam = teamDAO.findById(targetTeamId);
            if (targetTeam == null) {
                errors.add("Nhóm đích không tồn tại với ID: " + targetTeamId);
                return false;
            }

            // Verify user actually belongs to source team
            if (acc.getTeamId() == null || !acc.getTeamId().equals(sourceTeamId)) {
                errors.add("Nhân viên '" + acc.getFullName() + "' không thuộc nhóm nguồn '" + sourceTeam.getName() + "'.");
                return false;
            }

            // Check if user is the active leader of source team
            if (sourceTeam.getLeaderId() != null && sourceTeam.getLeaderId().equals(userId)) {
                errors.add("Nhân viên '" + acc.getFullName() + "' đang là Trưởng nhóm của '" + sourceTeam.getName() + "'. Không thể chuyển Trưởng nhóm sang nhóm khác khi chưa bổ nhiệm Trưởng nhóm mới.");
                return false;
            }
        } catch (SQLException e) {
            errors.add("Lỗi cơ sở dữ liệu khi kiểm tra chuyển nhóm: " + e.getMessage());
            return false;
        }

        return updateUserTeamId(userId, targetTeamId);
    }

    public boolean transferUserToTeam(int userId, Integer targetTeamId, List<String> errors) {
        Integer currentTeamId = null;
        com.crm.model.Account acc = accountDAO.getAccountById(userId);
        if (acc != null) currentTeamId = acc.getTeamId();
        return transferUserToTeam(userId, currentTeamId, targetTeamId, errors);
    }

    public List<com.crm.model.Account> getAllActiveUsers() {
        return accountDAO.getAllActiveAccounts();
    }

    public boolean isQualifiedLeader(com.crm.model.Account user) {
        if (user == null) return false;
        List<String> codes = user.getRoleCodes();
        if (codes != null) {
            for (String code : codes) {
                if (code != null) {
                    String c = code.toUpperCase().trim();
                    if (c.equals("TEAM_LEAD") || c.equals("DIRECTOR") || c.equals("ADMIN") || c.contains("LEAD") || c.contains("MANAGER")) {
                        return true;
                    }
                }
            }
        }
        List<String> names = user.getRoleNames();
        if (names != null) {
            for (String name : names) {
                if (name != null) {
                    String n = name.toLowerCase().trim();
                    if (n.contains("trưởng nhóm") || n.contains("giám đốc") || n.contains("quản trị") || n.contains("leader") || n.contains("manager")) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public List<com.crm.model.Account> getLeaderCandidateUsers() {
        List<com.crm.model.Account> activeUsers = getAllActiveUsers();
        List<com.crm.model.Account> candidates = new java.util.ArrayList<>();
        if (activeUsers != null) {
            for (com.crm.model.Account u : activeUsers) {
                if (isQualifiedLeader(u)) {
                    candidates.add(u);
                }
            }
        }
        return candidates;
    }

    public List<com.crm.model.Account> getTeamMembers(int teamId) {
        if (teamId <= 0) return java.util.Collections.emptyList();
        return accountDAO.getAccounts(null, teamId, null, "ACTIVE", 0, 1000);
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

            // Parent team validation (Multi-level cycle check)
            if (team.getParentTeamId() != null && team.getParentTeamId() > 0) {
                if (team.getId() > 0 && team.getParentTeamId().equals(team.getId())) {
                    errors.add("Nhóm kinh doanh không thể chọn chính mình làm nhóm cha.");
                } else if (isCircularHierarchy(team.getId(), team.getParentTeamId())) {
                    errors.add("Không thể chọn nhóm cha vì sẽ tạo thành vòng lặp trong cây tổ chức.");
                } else {
                    Team parentTeam = teamDAO.findById(team.getParentTeamId());
                    if (parentTeam == null) {
                        errors.add("Nhóm cha với ID " + team.getParentTeamId() + " không tồn tại.");
                    }
                }
            } else {
                team.setParentTeamId(null);
            }

            // Leader validation strictly checking DB roles
            if (team.getLeaderId() != null && team.getLeaderId() > 0) {
                com.crm.model.Account leader = accountDAO.getAccountById(team.getLeaderId());
                if (leader == null) {
                    errors.add("Trưởng nhóm (Leader) với ID " + team.getLeaderId() + " không tồn tại.");
                } else if (!isQualifiedLeader(leader)) {
                    String roleDisplay = (leader.getRoleNames() != null && !leader.getRoleNames().isEmpty()) 
                            ? String.join(", ", leader.getRoleNames()) 
                            : "chức vụ hiện tại";
                    errors.add("Người dùng '" + leader.getFullName() + "' (" + roleDisplay + ") không có quyền làm Trưởng nhóm. Vui lòng chọn người dùng có chức vụ phù hợp từ Database.");
                } else {
                    Team existingLeadTeam = teamDAO.findTeamByLeaderIdExcludingTeamId(team.getLeaderId(), team.getId());
                    if (existingLeadTeam != null) {
                        errors.add("Người dùng '" + leader.getFullName() + "' đã là Trưởng nhóm của '" + existingLeadTeam.getName() + "'. Mỗi người dùng chỉ có thể làm Trưởng nhóm của 1 nhóm.");
                    }
                }
            } else {
                team.setLeaderId(null);
            }

            if (!errors.isEmpty()) {
                return false;
            }

            // Insert or Update
            boolean success = false;
            if (team.getId() > 0) {
                Team existing = teamDAO.findById(team.getId());
                if (existing == null) {
                    errors.add("Không tìm thấy nhóm kinh doanh với ID: " + team.getId());
                    return false;
                }
                success = teamDAO.update(team);
            } else {
                success = teamDAO.insert(team);
            }

            // Synchronize leader's team assignment to this team
            if (success && team.getLeaderId() != null && team.getLeaderId() > 0) {
                updateUserTeamId(team.getLeaderId(), team.getId());
            }

            return success;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lưu thông tin nhóm kinh doanh: ", e);
            errors.add("Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        }
    }
}
