package com.crm.service;

import com.crm.dao.CustomerCareDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dto.CustomerCareResponse;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Customer;
import com.crm.model.CustomerCareState;

import java.util.List;

/**
 * Service xử lý Chăm sóc khách hàng định kỳ N ngày.
 * Task S30-10 / S3-09.
 */
public class CustomerCareService {

    private CustomerCareDAO customerCareDAO = new CustomerCareDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private PermissionService permissionService = new PermissionService();

    public void setCustomerCareDAO(CustomerCareDAO dao) { this.customerCareDAO = dao; }
    public void setCustomerDAO(CustomerDAO dao) { this.customerDAO = dao; }
    public void setPermissionService(PermissionService ps) { this.permissionService = ps; }

    public List<CustomerCareResponse> getInactiveCustomers(int inactiveDays, int page, int pageSize, int userId, List<Integer> roleIds) {
        int threshold = inactiveDays > 0 ? inactiveDays : customerCareDAO.getInactiveThreshold();
        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roleIds, "ACCOUNT");
        return customerCareDAO.findInactiveCustomers(threshold, ownerIds, page, pageSize);
    }

    public int countInactiveCustomers(int inactiveDays, int userId, List<Integer> roleIds) {
        int threshold = inactiveDays > 0 ? inactiveDays : customerCareDAO.getInactiveThreshold();
        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roleIds, "ACCOUNT");
        return customerCareDAO.countInactiveCustomers(threshold, ownerIds);
    }

    public CustomerCareState markContacted(int customerId, String note, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (customerId <= 0) {
            throw new ValidationException("ID khách hàng không hợp lệ.");
        }

        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + customerId + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        boolean recorded = customerCareDAO.recordContacted(customerId, userId, note);
        if (!recorded) {
            throw new ValidationException("Không thể ghi nhận mốc chăm sóc khách hàng vào CSDL.");
        }

        return customerCareDAO.findByCustomerId(customerId);
    }

    public CustomerCareState getCustomerCareState(int customerId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + customerId + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        return customerCareDAO.findByCustomerId(customerId);
    }

    public int getConfiguredInactiveDays() {
        return customerCareDAO.getInactiveThreshold();
    }

    public boolean updateConfiguredInactiveDays(int days, int userId, List<Integer> roleIds) throws ValidationException {
        if (days <= 0) {
            throw new ValidationException("Số ngày định kỳ phải là số nguyên dương (> 0).");
        }
        return customerCareDAO.updateInactiveThreshold(days);
    }
}
