package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dao.SavedFilterDAO;
import com.crm.dto.CustomerFilterRequest;
import com.crm.model.Customer;
import com.crm.model.SavedFilter;

import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class CustomerFilterService {

    private final CustomerDAO customerDAO;
    private final SavedFilterDAO savedFilterDAO;
    private final PermissionService permissionService;

    public CustomerFilterService() {
        this.customerDAO = new CustomerDAO();
        this.savedFilterDAO = new SavedFilterDAO();
        this.permissionService = new PermissionService();
    }

    public CustomerFilterService(CustomerDAO customerDAO, SavedFilterDAO savedFilterDAO, PermissionService permissionService) {
        this.customerDAO = Objects.requireNonNull(customerDAO, "CustomerDAO không được để null");
        this.savedFilterDAO = Objects.requireNonNull(savedFilterDAO, "SavedFilterDAO không được để null");
        this.permissionService = Objects.requireNonNull(permissionService, "PermissionService không được để null");
    }

    private List<Integer> getEffectiveOwnerIds(CustomerFilterRequest request, int userId, List<Integer> roleIds) {
        List<Integer> roles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(0);
        List<Integer> accessibleOwnerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roles, "ACCOUNT");

        if (request != null && request.getOwnerId() != null && request.getOwnerId() > 0) {
            int requestedOwnerId = request.getOwnerId();
            if (accessibleOwnerIds != null && !accessibleOwnerIds.contains(requestedOwnerId)) {
                return Collections.emptyList();
            }
            return Collections.singletonList(requestedOwnerId);
        }

        return accessibleOwnerIds;
    }

    public List<Customer> filterCustomers(CustomerFilterRequest request, int userId, List<Integer> roleIds) {
        List<Integer> effectiveOwnerIds = getEffectiveOwnerIds(request, userId, roleIds);
        return customerDAO.getList(request, effectiveOwnerIds);
    }

    public int countFilteredCustomers(CustomerFilterRequest request, int userId, List<Integer> roleIds) {
        List<Integer> effectiveOwnerIds = getEffectiveOwnerIds(request, userId, roleIds);
        return customerDAO.count(request, effectiveOwnerIds);
    }

    public boolean saveFilter(SavedFilter filter, int userId) {
        if (filter == null) return false;
        filter.setUserId(userId);
        return savedFilterDAO.createSavedFilter(filter);
    }

    public List<SavedFilter> getSavedFilters(int userId) {
        return savedFilterDAO.getSavedFiltersByUserId(userId);
    }

    public boolean deleteSavedFilter(int filterId, int userId) {
        return savedFilterDAO.deleteSavedFilter(filterId, userId);
    }
}
