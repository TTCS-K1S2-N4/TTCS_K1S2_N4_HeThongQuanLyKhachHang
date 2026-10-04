package com.crm.service;

import com.crm.dao.CustomerRelationshipDAO;
import com.crm.model.CustomerRelationship;
import java.util.List;

public class CustomerHierarchyService {
    
    private CustomerRelationshipDAO relationshipDAO = new CustomerRelationshipDAO();
    
    public List<CustomerRelationship> getChildren(int parentId) {
        return relationshipDAO.getChildren(parentId);
    }
    
    public List<CustomerRelationship> getParents(int childId) {
        return relationshipDAO.getParents(childId);
    }
    
    public boolean addRelationship(int parentId, int childId, String type) {
        if (parentId == childId) {
            return false;
        }
        return relationshipDAO.addRelationship(parentId, childId, type);
    }
    
    public boolean deleteRelationship(int relationshipId) {
        return relationshipDAO.deleteRelationship(relationshipId);
    }
}
