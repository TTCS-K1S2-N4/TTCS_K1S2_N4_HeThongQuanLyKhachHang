package com.crm.service;

import com.crm.dao.ActivityDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.Customer360Response;
import com.crm.exception.AuthorizationException;
import com.crm.model.Activity;
import com.crm.model.Customer;
import com.crm.model.Opportunity;

import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class Customer360Service {

    private final CustomerDAO customerDAO;
    private final OpportunityDAO opportunityDAO;
    private final ActivityDAO activityDAO;
    private final PermissionService permissionService;

    public Customer360Service() {
        this.customerDAO = new CustomerDAO();
        this.opportunityDAO = new OpportunityDAO();
        this.activityDAO = new ActivityDAO();
        this.permissionService = new PermissionService();
    }

    public Customer360Service(CustomerDAO customerDAO, OpportunityDAO opportunityDAO, ActivityDAO activityDAO, PermissionService permissionService) {
        this.customerDAO = Objects.requireNonNull(customerDAO, "CustomerDAO không được để null");
        this.opportunityDAO = Objects.requireNonNull(opportunityDAO, "OpportunityDAO không được để null");
        this.activityDAO = Objects.requireNonNull(activityDAO, "ActivityDAO không được để null");
        this.permissionService = Objects.requireNonNull(permissionService, "PermissionService không được để null");
    }

    public Customer360Response getCustomer360(int customerId, int userId, List<Integer> roleIds) throws AuthorizationException {
        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            return null;
        }

        List<Integer> roles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(0);
        permissionService.validateDataAccessForRoles(userId, roles, "ACCOUNT", customer.getOwnerId());

        Customer360Response response = new Customer360Response();
        response.setCustomer(customer);
        response.setContacts(customerDAO.getContactsByCustomerId(customerId));

        List<Opportunity> openOpps = opportunityDAO.getOpenOpportunitiesByCustomerId(customerId);
        List<Opportunity> closedOpps = opportunityDAO.getClosedOpportunitiesByCustomerId(customerId);
        double openAmount = opportunityDAO.calculateTotalOpenAmount(customerId);

        response.setOpenOpportunities(openOpps);
        response.setClosedOpportunities(closedOpps);
        response.setTotalOpenOpportunityValue(openAmount);

        List<Activity> activities = activityDAO.getActivitiesByCustomerId(customerId, 1, 10);
        int totalActivities = activityDAO.countByCustomerId(customerId);
        response.setActivities(activities);
        response.setTotalActivities(totalActivities);

        response.setAttachments(customerDAO.getAttachmentsByCustomerId(customerId));

        return response;
    }

    public List<Activity> getCustomerTimeline(int customerId, int page, int pageSize, int userId, List<Integer> roleIds) throws AuthorizationException {
        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            return Collections.emptyList();
        }

        List<Integer> roles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(0);
        permissionService.validateDataAccessForRoles(userId, roles, "ACCOUNT", customer.getOwnerId());

        return activityDAO.getActivitiesByCustomerId(customerId, page, pageSize);
    }
}
