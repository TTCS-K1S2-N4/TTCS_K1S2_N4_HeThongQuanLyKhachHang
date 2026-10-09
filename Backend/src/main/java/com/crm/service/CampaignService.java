package com.crm.service;

import com.crm.dao.CampaignDAO;
import com.crm.dto.CampaignRequest;
import com.crm.exception.AuthorizationException;
import com.crm.model.Campaign;
import com.crm.model.DataScope;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

/**
 * Service xử lý nghiệp vụ Chiến dịch tiếp thị (Campaign Tracking).
 * Phục vụ cho User Story S4-03 (AC-01, AC-02, AC-03).
 */
public class CampaignService {

    private static final Logger LOGGER = Logger.getLogger(CampaignService.class.getName());

    private final CampaignDAO campaignDAO;
    private final PermissionService permissionService;

    public CampaignService() {
        this.campaignDAO = new CampaignDAO();
        this.permissionService = new PermissionService();
    }

    public CampaignService(CampaignDAO campaignDAO, PermissionService permissionService) {
        this.campaignDAO = campaignDAO != null ? campaignDAO : new CampaignDAO();
        this.permissionService = permissionService != null ? permissionService : new PermissionService();
    }

    /**
     * Khai báo/tạo mới chiến dịch tiếp thị (S4-03-AC-01).
     */
    public Campaign createCampaign(CampaignRequest req, int userId) {
        if (req == null) {
            throw new IllegalArgumentException("Dữ liệu yêu cầu chiến dịch không được để null.");
        }

        List<String> errors = req.validate();
        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(String.join("; ", errors));
        }

        Campaign campaign = new Campaign();
        campaign.setCampaignName(req.getName().trim());
        campaign.setBudget(req.getBudget());
        campaign.setStartDate(req.getStartDate());
        campaign.setEndDate(req.getEndDate());
        campaign.setChannel(req.getChannel() != null ? req.getChannel().trim() : null);
        campaign.setDescription(req.getDescription() != null ? req.getDescription().trim() : null);
        campaign.setStatus(req.getStatus() != null && !req.getStatus().trim().isEmpty() ? req.getStatus().trim() : "PLANNING");
        campaign.setCreatedBy(userId);

        int generatedId = campaignDAO.insert(campaign);
        if (generatedId <= 0) {
            throw new RuntimeException("Không thể lưu chiến dịch vào cơ sở dữ liệu.");
        }

        LOGGER.info("Tạo thành công chiến dịch id=" + generatedId + " bởi userId=" + userId);
        return campaignDAO.findById(generatedId);
    }

    /**
     * Cập nhật thông tin chiến dịch đã có.
     */
    public Campaign updateCampaign(CampaignRequest req, int userId, int roleId, List<Integer> roleIds) throws AuthorizationException {
        if (req == null || req.getId() == null || req.getId() <= 0) {
            throw new IllegalArgumentException("ID chiến dịch không hợp lệ.");
        }

        List<String> errors = req.validate();
        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(String.join("; ", errors));
        }

        Campaign existing = campaignDAO.findById(req.getId());
        if (existing == null) {
            throw new IllegalArgumentException("Chiến dịch không tồn tại với ID: " + req.getId());
        }

        // Kiểm tra phân quyền truy cập và chỉnh sửa theo phạm vi sở hữu
        validateCampaignAccess(existing, userId, roleId, roleIds);

        existing.setCampaignName(req.getName().trim());
        existing.setBudget(req.getBudget());
        existing.setStartDate(req.getStartDate());
        existing.setEndDate(req.getEndDate());
        existing.setChannel(req.getChannel() != null ? req.getChannel().trim() : null);
        existing.setDescription(req.getDescription() != null ? req.getDescription().trim() : null);
        if (req.getStatus() != null && !req.getStatus().trim().isEmpty()) {
            existing.setStatus(req.getStatus().trim());
        }

        boolean updated = campaignDAO.update(existing);
        if (!updated) {
            throw new RuntimeException("Không thể cập nhật thông tin chiến dịch.");
        }

        LOGGER.info("Cập nhật thành công chiến dịch id=" + existing.getCampaignId() + " bởi userId=" + userId);
        return campaignDAO.findById(existing.getCampaignId());
    }

    /**
     * Xem chi tiết chiến dịch và các chỉ số hiệu quả (S4-03-AC-03).
     */
    public Campaign getCampaignDetail(int campaignId, int userId, int roleId, List<Integer> roleIds) throws AuthorizationException {
        if (campaignId <= 0) {
            throw new IllegalArgumentException("ID chiến dịch không hợp lệ.");
        }

        Campaign campaign = campaignDAO.findById(campaignId);
        if (campaign == null) {
            return null;
        }

        validateCampaignAccess(campaign, userId, roleId, roleIds);
        return campaign;
    }

    /**
     * Lấy danh sách chiến dịch theo bộ lọc và phạm vi phân quyền người dùng.
     */
    public List<Campaign> getCampaigns(String keyword, String status, String channel, int page, int pageSize, int userId, int roleId, List<Integer> roleIds) {
        DataScope scope = resolveScope(roleId, roleIds);
        List<Integer> teamUserIds = resolveTeamUserIds(scope, userId, roleId, roleIds);

        return campaignDAO.findAll(keyword, status, channel, userId, teamUserIds, scope, page, pageSize);
    }

    /**
     * Đếm tổng số chiến dịch thỏa mãn điều kiện.
     */
    public int countCampaigns(String keyword, String status, String channel, int userId, int roleId, List<Integer> roleIds) {
        DataScope scope = resolveScope(roleId, roleIds);
        List<Integer> teamUserIds = resolveTeamUserIds(scope, userId, roleId, roleIds);

        return campaignDAO.countAll(keyword, status, channel, userId, teamUserIds, scope);
    }

    /**
     * Danh sách kênh tiếp thị chuẩn trong hệ thống.
     */
    public List<String> getAvailableChannels() {
        return Arrays.asList("Email", "Facebook", "Google Ads", "LinkedIn", "Sự kiện", "Website", "Telesales", "Khác");
    }

    private void validateCampaignAccess(Campaign campaign, int userId, int roleId, List<Integer> roleIds) throws AuthorizationException {
        if (campaign == null) return;
        DataScope scope = resolveScope(roleId, roleIds);
        if (scope == DataScope.ALL) return;

        Integer ownerId = campaign.getCreatedBy();
        if (ownerId == null) return;

        if (scope == DataScope.MY && ownerId != userId) {
            throw new AuthorizationException("Bạn không có quyền thao tác trên chiến dịch của người khác.");
        }

        if (scope == DataScope.TEAM) {
            List<Integer> teamIds = resolveTeamUserIds(scope, userId, roleId, roleIds);
            if (teamIds != null && !teamIds.contains(ownerId)) {
                throw new AuthorizationException("Bạn không có quyền thao tác trên chiến dịch ngoài nhóm của bạn.");
            }
        }
    }

    private DataScope resolveScope(int roleId, List<Integer> roleIds) {
        if (roleIds != null && !roleIds.isEmpty()) {
            return permissionService.getDataScopeForRoles(roleIds, "CATEGORY");
        }
        return permissionService.getDataScope(roleId, "CATEGORY");
    }

    private List<Integer> resolveTeamUserIds(DataScope scope, int userId, int roleId, List<Integer> roleIds) {
        if (scope != DataScope.TEAM) return Collections.emptyList();
        if (roleIds != null && !roleIds.isEmpty()) {
            return permissionService.getAccessibleAccountIdsForRoles(userId, roleIds, "CATEGORY");
        }
        return permissionService.getAccessibleAccountIds(userId, roleId, "CATEGORY");
    }
}
