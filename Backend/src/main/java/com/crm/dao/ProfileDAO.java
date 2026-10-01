package com.crm.dao;

import com.crm.model.UserProfile;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProfileDAO {

    public UserProfile getProfileById(int userId) {
        String sql = "SELECT u.user_id, u.full_name, u.email, u.phone, u.email_signature, u.avatar, t.team_name, r.role_name " +
                     "FROM users u " +
                     "LEFT JOIN teams t ON u.team_id = t.team_id " +
                     "LEFT JOIN user_roles ur ON u.user_id = ur.user_id " +
                     "LEFT JOIN roles r ON ur.role_id = r.role_id " +
                     "WHERE u.user_id = ?";

        UserProfile profile = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (profile == null) {
                        profile = new UserProfile();
                        profile.setUserId(rs.getInt("user_id"));
                        profile.setFullName(rs.getString("full_name"));
                        profile.setEmail(rs.getString("email"));
                        profile.setPhone(rs.getString("phone"));
                        
                        try {
                            profile.setEmailSignature(rs.getString("email_signature"));
                        } catch (Exception e) {
                            // Column might not exist in old schema instances, ignore if missing
                        }
                        try {
                            profile.setAvatar(rs.getString("avatar"));
                        } catch (Exception e) {
                            // Column might not exist
                        }
                        
                        profile.setTeam(rs.getString("team_name"));
                        profile.setRoles(new ArrayList<>());
                    }
                    String roleName = rs.getString("role_name");
                    if (roleName != null && !profile.getRoles().contains(roleName)) {
                        profile.getRoles().add(roleName);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return profile;
    }

    public boolean updateProfile(int userId, String fullName, String phone, String emailSignature) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, email_signature = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, emailSignature);
            ps.setInt(4, userId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
