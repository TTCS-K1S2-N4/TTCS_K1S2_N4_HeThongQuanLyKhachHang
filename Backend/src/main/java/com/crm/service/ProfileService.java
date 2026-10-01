package com.crm.service;

import com.crm.dao.ProfileDAO;
import com.crm.dto.ProfileUpdateRequest;
import com.crm.model.UserProfile;

public class ProfileService {
    
    private final ProfileDAO profileDAO;

    public ProfileService() {
        this.profileDAO = new ProfileDAO();
    }

    public UserProfile getProfile(int userId) {
        return profileDAO.getProfileById(userId);
    }

    public String updateProfile(int userId, ProfileUpdateRequest request) {
        if (request == null) {
            return "Dữ liệu yêu cầu không hợp lệ.";
        }
        
        if (request.getFullName() == null || request.getFullName().trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        
        // Basic phone validation if present
        if (request.getPhone() != null && !request.getPhone().trim().isEmpty()) {
            if (!request.getPhone().matches("^[0-9]{10,15}$")) {
                return "Số điện thoại không hợp lệ.";
            }
        }
        
        boolean success = profileDAO.updateProfile(userId, 
                                                   request.getFullName().trim(), 
                                                   request.getPhone() != null ? request.getPhone().trim() : null, 
                                                   request.getEmailSignature() != null ? request.getEmailSignature().trim() : null);
        
        if (success) {
            return null; // No errors
        } else {
            return "Cập nhật hồ sơ thất bại do lỗi hệ thống.";
        }
    }
}
