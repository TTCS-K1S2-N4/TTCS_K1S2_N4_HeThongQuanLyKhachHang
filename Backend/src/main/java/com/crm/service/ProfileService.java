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

        String fullName = request.getFullName() != null
                ? request.getFullName().trim()
                : null;

        if (fullName == null || fullName.isEmpty()) {
            return "Họ và tên không được để trống.";
        }

        String phone = request.getPhone() != null
                ? request.getPhone().trim()
                : null;

        if (phone != null && phone.isEmpty()) {
            phone = null;
        }

        if (phone != null && !phone.isEmpty()) {
            if (!phone.matches("^0(3|5|7|8|9)[0-9]{8}$")) {
                return "Số điện thoại không đúng định dạng Việt Nam.";
            }
        }

        String emailSignature = request.getEmailSignature() != null
                ? request.getEmailSignature().trim()
                : null;

        boolean success = profileDAO.updateProfile(
                userId,
                fullName,
                phone,
                emailSignature);

        return success
                ? null
                : "Cập nhật hồ sơ thất bại do lỗi hệ thống.";
    }
}
