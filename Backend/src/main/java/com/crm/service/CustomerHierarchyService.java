package com.crm.service;

import com.crm.dao.CustomerRelationshipDAO;
import com.crm.model.CustomerRelationship;
import java.util.List;

public class CustomerHierarchyService {
    
    private CustomerRelationshipDAO relationshipDAO;

    public CustomerHierarchyService() {
        this.relationshipDAO = new CustomerRelationshipDAO();
    }

    public CustomerHierarchyService(CustomerRelationshipDAO relationshipDAO) {
        this.relationshipDAO = (relationshipDAO != null) ? relationshipDAO : new CustomerRelationshipDAO();
    }

    public void setRelationshipDAO(CustomerRelationshipDAO dao) {
        if (dao != null) {
            this.relationshipDAO = dao;
        }
    }
    
    public List<CustomerRelationship> getChildren(int parentId) {
        return relationshipDAO.getChildren(parentId);
    }
    
    public List<CustomerRelationship> getParents(int childId) {
        return relationshipDAO.getParents(childId);
    }
    
    public boolean addRelationship(int parentId, int childId, String type) {
        if (parentId <= 0 || childId <= 0 || parentId == childId) {
            return false;
        }
        
        // Cycle detection: check if childId is already an ancestor of parentId
        if (isAncestor(childId, parentId, new java.util.HashSet<>())) {
            return false;
        }
        
        return relationshipDAO.addRelationship(parentId, childId, type != null && !type.trim().isEmpty() ? type : "SUBSIDIARY");
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
    
    public CustomerRelationship getRelationshipById(int relationshipId) {
        if (relationshipId <= 0) {
            return null;
        }
        return relationshipDAO.findById(relationshipId);
    }

    public boolean deleteRelationship(int relationshipId) {
        if (relationshipId <= 0) {
            return false;
        }
        return relationshipDAO.deleteRelationship(relationshipId);
    }
}
