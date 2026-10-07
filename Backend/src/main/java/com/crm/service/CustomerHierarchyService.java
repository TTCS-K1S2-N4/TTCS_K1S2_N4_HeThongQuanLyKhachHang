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
        
        // Cycle detection: check if childId is already an ancestor of parentId
        if (isAncestor(childId, parentId, new java.util.HashSet<>())) {
            return false;
        }
        
        return relationshipDAO.addRelationship(parentId, childId, type);
    }
    
    private boolean isAncestor(int targetAncestorId, int currentId, java.util.Set<Integer> visited) {
        if (targetAncestorId == currentId) return true;
        if (!visited.add(currentId)) return false; // Prevent infinite loop if existing cycle
        
        List<CustomerRelationship> parents = getParents(currentId);
        for (CustomerRelationship rel : parents) {
            if (isAncestor(targetAncestorId, rel.getParentCustomerId(), visited)) {
                return true;
            }
        }
        return false;
    }
    
    public boolean deleteRelationship(int relationshipId) {
        return relationshipDAO.deleteRelationship(relationshipId);
    }
}
