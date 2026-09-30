package com.crm.service;

import com.crm.dao.CompetitorDAO;
import com.crm.exception.ValidationException;
import com.crm.model.Competitor;

import java.util.List;

public class CompetitorService {

    private final CompetitorDAO competitorDAO = new CompetitorDAO();

    public List<Competitor> getAllCompetitors() {
        return competitorDAO.findAll();
    }

    public void createCompetitor(String competitorName, String status) throws ValidationException {
        validateName(competitorName);

        Competitor comp = new Competitor();
        comp.setCompetitorName(competitorName);
        comp.setStatus(status != null ? status : "ACTIVE");

        boolean success = competitorDAO.insert(comp);
        if (!success) {
            throw new RuntimeException("Failed to create competitor.");
        }
    }

    public void updateCompetitor(int competitorId, String competitorName, String status) throws ValidationException {
        validateName(competitorName);

        Competitor comp = competitorDAO.findById(competitorId);
        if (comp == null) {
            throw new ValidationException("Competitor not found.");
        }

        comp.setCompetitorName(competitorName);
        if (status != null) {
            comp.setStatus(status);
        }

        boolean success = competitorDAO.update(comp);
        if (!success) {
            throw new RuntimeException("Failed to update competitor.");
        }
    }

    private void validateName(String name) throws ValidationException {
        if (name == null || name.trim().isEmpty()) {
            throw new ValidationException("Competitor name cannot be empty.");
        }
    }
}
