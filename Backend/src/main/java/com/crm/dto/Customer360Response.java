package com.crm.dto;

import com.crm.model.Activity;
import com.crm.model.Customer;
import com.crm.model.Opportunity;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Customer360Response {
    private Customer customer;
    private List<Map<String, Object>> contacts = new ArrayList<>();
    private List<Opportunity> openOpportunities = new ArrayList<>();
    private List<Opportunity> closedOpportunities = new ArrayList<>();
    private double totalOpenOpportunityValue = 0.0;
    private double signedValue = 0.0;
    private List<Activity> activities = new ArrayList<>();
    private int totalActivities = 0;
    private List<Map<String, Object>> attachments = new ArrayList<>();

    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }

    public List<Map<String, Object>> getContacts() { return contacts; }
    public void setContacts(List<Map<String, Object>> contacts) { this.contacts = contacts; }

    public List<Opportunity> getOpenOpportunities() { return openOpportunities; }
    public void setOpenOpportunities(List<Opportunity> openOpportunities) { this.openOpportunities = openOpportunities; }

    public List<Opportunity> getClosedOpportunities() { return closedOpportunities; }
    public void setClosedOpportunities(List<Opportunity> closedOpportunities) { this.closedOpportunities = closedOpportunities; }

    public double getTotalOpenOpportunityValue() { return totalOpenOpportunityValue; }
    public void setTotalOpenOpportunityValue(double totalOpenOpportunityValue) { this.totalOpenOpportunityValue = totalOpenOpportunityValue; }

    public double getSignedValue() { return signedValue; }
    public void setSignedValue(double signedValue) { this.signedValue = signedValue; }

    public List<Activity> getActivities() { return activities; }
    public void setActivities(List<Activity> activities) { this.activities = activities; }

    public int getTotalActivities() { return totalActivities; }
    public void setTotalActivities(int totalActivities) { this.totalActivities = totalActivities; }

    public List<Map<String, Object>> getAttachments() { return attachments; }
    public void setAttachments(List<Map<String, Object>> attachments) { this.attachments = attachments; }
}
