package com.qlkh.service;

import com.qlkh.entity.DataScope;
import com.qlkh.entity.Team;
import com.qlkh.entity.User;
import com.qlkh.repository.TeamRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * S1-05 - Phân quyền dữ liệu.
 * Cung cấp cho tầng service/controller khác biết: user hiện tại được xem
 * dữ liệu của những ai, dựa trên Role.dataScope (MY / TEAM / ALL).
 *
 * Cách dùng ở nơi truy vấn khách hàng / cơ hội (ví dụ CustomerService):
 *
 *   DataScopeFilter filter = permissionService.resolveDataScope(currentUser);
 *   if (filter.isAll()) { ... không thêm điều kiện ... }
 *   else { query.where("owner_id IN :ownerIds", filter.getOwnerUserIds()); }
 */
@Service
public class PermissionService {

    private final TeamRepository teamRepository;

    public PermissionService(TeamRepository teamRepository) {
        this.teamRepository = teamRepository;
    }

    /**
     * Trả về đối tượng mô tả phạm vi dữ liệu mà user được phép xem.
     */
    public DataScopeFilter resolveDataScope(User user) {
        DataScope scope = user.getRole().getDataScope();

        switch (scope) {
            case ALL:
                return DataScopeFilter.all();

            case TEAM:
                if (user.getTeam() == null) {
                    // Không thuộc nhóm nào -> coi như chỉ thấy dữ liệu của chính mình
                    return DataScopeFilter.ownerIds(List.of(user.getId()));
                }
                List<Long> teamIds = collectTeamAndSubTeamIds(user.getTeam().getId());
                return DataScopeFilter.teamIds(teamIds);

            case MY:
            default:
                return DataScopeFilter.ownerIds(List.of(user.getId()));
        }
    }

    /**
     * Lấy id của một nhóm và toàn bộ nhóm con (đệ quy) — dùng khi trưởng nhóm
     * cần thấy dữ liệu của các nhóm con thuộc nhóm mình quản lý.
     */
    public List<Long> collectTeamAndSubTeamIds(Long rootTeamId) {
        List<Long> result = new ArrayList<>();
        collectRecursive(rootTeamId, result);
        return result;
    }

    private void collectRecursive(Long teamId, List<Long> acc) {
        acc.add(teamId);
        List<Team> children = teamRepository.findByParentId(teamId);
        for (Team child : children) {
            collectRecursive(child.getId(), acc);
        }
    }

    /**
     * Kiểm tra quyền truy cập màn hình/chức năng theo mã menu (dùng trong
     * interceptor hoặc @PreAuthorize tuỳ chọn).
     */
    public boolean hasMenuAccess(User user, String menuCode, List<String> allowedMenuCodesForRole) {
        return allowedMenuCodesForRole.contains(menuCode);
    }

    /**
     * Kết quả phân giải phạm vi dữ liệu, dùng để build điều kiện WHERE.
     */
    public static class DataScopeFilter {
        private final boolean all;
        private final List<Long> ownerUserIds; // dùng khi scope = MY
        private final List<Long> teamIds;      // dùng khi scope = TEAM

        private DataScopeFilter(boolean all, List<Long> ownerUserIds, List<Long> teamIds) {
            this.all = all;
            this.ownerUserIds = ownerUserIds;
            this.teamIds = teamIds;
        }

        public static DataScopeFilter all() {
            return new DataScopeFilter(true, null, null);
        }

        public static DataScopeFilter ownerIds(List<Long> ownerUserIds) {
            return new DataScopeFilter(false, ownerUserIds, null);
        }

        public static DataScopeFilter teamIds(List<Long> teamIds) {
            return new DataScopeFilter(false, null, teamIds);
        }

        public boolean isAll() { return all; }
        public boolean isByOwner() { return ownerUserIds != null; }
        public boolean isByTeam() { return teamIds != null; }
        public List<Long> getOwnerUserIds() { return ownerUserIds; }
        public List<Long> getTeamIds() { return teamIds; }
    }
}
