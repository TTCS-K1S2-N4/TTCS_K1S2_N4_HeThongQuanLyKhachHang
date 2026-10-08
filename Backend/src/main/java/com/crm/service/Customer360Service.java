package com.crm.service;

import com.crm.dao.ActivityDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.CustomerRelationshipDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.Customer360Response;
import com.crm.exception.AuthorizationException;
import com.crm.model.Activity;
import com.crm.model.Customer;
import com.crm.model.CustomerRelationship;
import com.crm.model.Opportunity;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class Customer360Service {

    private final CustomerDAO customerDAO;
    private final OpportunityDAO opportunityDAO;
    private final ActivityDAO activityDAO;
    private final PermissionService permissionService;
    private final CustomerRelationshipDAO relationshipDAO;

    public Customer360Service() {
        this.customerDAO = new CustomerDAO();
        this.opportunityDAO = new OpportunityDAO();
        this.activityDAO = new ActivityDAO();
        this.permissionService = new PermissionService();
        this.relationshipDAO = new CustomerRelationshipDAO();
    }

    public Customer360Service(CustomerDAO customerDAO, OpportunityDAO opportunityDAO, ActivityDAO activityDAO, PermissionService permissionService) {
        this.customerDAO = Objects.requireNonNull(customerDAO, "CustomerDAO không được để null");
        this.opportunityDAO = Objects.requireNonNull(opportunityDAO, "OpportunityDAO không được để null");
        this.activityDAO = Objects.requireNonNull(activityDAO, "ActivityDAO không được để null");
        this.permissionService = Objects.requireNonNull(permissionService, "PermissionService không được để null");
        this.relationshipDAO = new CustomerRelationshipDAO();
    }

    public Customer360Service(CustomerDAO customerDAO, OpportunityDAO opportunityDAO, ActivityDAO activityDAO, PermissionService permissionService, CustomerRelationshipDAO relationshipDAO) {
        this.customerDAO = Objects.requireNonNull(customerDAO, "CustomerDAO không được để null");
        this.opportunityDAO = Objects.requireNonNull(opportunityDAO, "OpportunityDAO không được để null");
        this.activityDAO = Objects.requireNonNull(activityDAO, "ActivityDAO không được để null");
        this.permissionService = Objects.requireNonNull(permissionService, "PermissionService không được để null");
        this.relationshipDAO = Objects.requireNonNull(relationshipDAO, "CustomerRelationshipDAO không được để null");
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
        double signedAmount = opportunityDAO.calculateTotalSignedAmount(customerId);

        response.setOpenOpportunities(openOpps);
        response.setClosedOpportunities(closedOpps);
        response.setTotalOpenOpportunityValue(openAmount);
        response.setSignedValue(signedAmount);

        // Calculate subsidiaries and Group Contract Total
        List<CustomerRelationship> childRels = relationshipDAO.getChildren(customerId);
        List<Customer> subsidiaries = new ArrayList<>();
        double subsidiarySignedTotal = 0.0;
        if (childRels != null) {
            for (CustomerRelationship rel : childRels) {
                Customer child = rel.getChildCustomer();
                if (child == null && rel.getChildCustomerId() > 0) {
                    child = customerDAO.findById(rel.getChildCustomerId());
                }
                if (child != null) {
                    subsidiaries.add(child);
                    subsidiarySignedTotal += opportunityDAO.calculateTotalSignedAmount(child.getCustomerId());
                }
            }
        }
        double groupContractTotal = signedAmount + subsidiarySignedTotal;
        response.setSubsidiaries(subsidiaries);
        response.setGroupContractTotal(groupContractTotal);

        List<Activity> activities = activityDAO.getActivitiesByCustomerId(customerId, 1, 10);
        int totalActivities = activityDAO.countByCustomerId(customerId);
        response.setActivities(activities);
        response.setTotalActivities(totalActivities);

        response.setAttachments(customerDAO.getAttachmentsByCustomerId(customerId));

        // Fetch Support Requests & Churn Risk for S30-09
        try {
            CustomerSupportService supportService = new CustomerSupportService();
            response.setSupportRequests(supportService.getSupportRequestsByCustomer(customerId, userId, roles));
        } catch (Exception e) {
            response.setSupportRequests(new ArrayList<>());
        }

        try {
            CustomerRiskService riskService = new CustomerRiskService();
            response.setCustomerRisk(riskService.getCustomerRisk(customerId, userId, roles));
        } catch (Exception e) {
            response.setCustomerRisk(null);
        }

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
