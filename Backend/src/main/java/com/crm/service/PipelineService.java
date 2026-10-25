package com.crm.service;

import com.crm.dao.PipelineStageDAO;
import com.crm.exception.ValidationException;
import com.crm.model.PipelineStage;

import java.util.List;

public class PipelineService {

    private final PipelineStageDAO pipelineStageDAO = new PipelineStageDAO();

    public List<PipelineStage> getAllStages() {
        return pipelineStageDAO.findAll();
    }

    public void createStage(String stageName, int displayOrder, double defaultProbability, String exitCondition, String status) throws ValidationException {
        validateProbability(defaultProbability);
        validateName(stageName);

        PipelineStage stage = new PipelineStage();
        stage.setStageName(stageName);
        stage.setDisplayOrder(displayOrder);
        stage.setDefaultProbability(defaultProbability);
        stage.setExitCondition(exitCondition);
        stage.setStatus(status != null ? status : "ACTIVE");

        boolean success = pipelineStageDAO.insert(stage);
        if (!success) {
            throw new RuntimeException("Failed to create pipeline stage.");
        }
    }

    public void updateStage(int pipelineStageId, String stageName, int displayOrder, double defaultProbability, String exitCondition, String status) throws ValidationException {
        validateProbability(defaultProbability);
        validateName(stageName);

        PipelineStage stage = pipelineStageDAO.findById(pipelineStageId);
        if (stage == null) {
            throw new ValidationException("Pipeline stage not found.");
        }

        stage.setStageName(stageName);
        stage.setDisplayOrder(displayOrder);
        stage.setDefaultProbability(defaultProbability);
        stage.setExitCondition(exitCondition);
        if (status != null) {
            stage.setStatus(status);
        }

        boolean success = pipelineStageDAO.update(stage);
        if (!success) {
            throw new RuntimeException("Failed to update pipeline stage.");
        }
    }

    public void updateOrder(int pipelineStageId, int displayOrder) throws ValidationException {
        PipelineStage stage = pipelineStageDAO.findById(pipelineStageId);
        if (stage == null) {
            throw new ValidationException("Pipeline stage not found.");
        }
        boolean success = pipelineStageDAO.updateOrder(pipelineStageId, displayOrder);
        if (!success) {
            throw new RuntimeException("Failed to update pipeline stage order.");
        }
    }

    public void deactivateStage(int pipelineStageId) throws ValidationException {
        PipelineStage stage = pipelineStageDAO.findById(pipelineStageId);
        if (stage == null) {
            throw new ValidationException("Pipeline stage not found.");
        }
        boolean success = pipelineStageDAO.updateStatus(pipelineStageId, "INACTIVE");
        if (!success) {
            throw new RuntimeException("Failed to deactivate pipeline stage.");
        }
    }

    private void validateProbability(double probability) throws ValidationException {
        if (probability < 0 || probability > 100) {
            throw new ValidationException("Default probability must be between 0 and 100.");
        }
    }

    private void validateName(String name) throws ValidationException {
        if (name == null || name.trim().isEmpty()) {
            throw new ValidationException("Stage name cannot be empty.");
        }
    }
}
