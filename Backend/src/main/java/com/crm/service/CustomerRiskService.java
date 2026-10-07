package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dao.CustomerRiskDAO;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Customer;
import com.crm.model.CustomerRisk;

import java.util.List;

/**
 * Service đánh giá rủi ro rời bỏ của Khách hàng (Churn Risk).
 * Task S30-09 / S3-08.
 */
public class CustomerRiskService {

    public static final int DEFAULT_CHURN_THRESHOLD = 3;

    private CustomerRiskDAO customerRiskDAO = new CustomerRiskDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private PermissionService permissionService = new PermissionService();

    public void setCustomerRiskDAO(CustomerRiskDAO dao) { this.customerRiskDAO = dao; }
    public void setCustomerDAO(CustomerDAO dao) { this.customerDAO = dao; }
    public void setPermissionService(PermissionService ps) { this.permissionService = ps; }

    public CustomerRisk getCustomerRisk(int customerId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        return getCustomerRisk(customerId, DEFAULT_CHURN_THRESHOLD, userId, roleIds);
    }

    public CustomerRisk getCustomerRisk(int customerId, int threshold, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (customerId <= 0) {
            throw new ValidationException("ID khách hàng không hợp lệ.");
        }

        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + customerId + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        int safeThreshold = threshold > 0 ? threshold : DEFAULT_CHURN_THRESHOLD;
        return customerRiskDAO.calculateRisk(customerId, safeThreshold);
    }
}
