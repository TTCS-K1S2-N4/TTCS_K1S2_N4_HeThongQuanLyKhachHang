package com.crm.service;

import com.crm.dao.WinLossReasonDAO;
import com.crm.exception.ValidationException;
import com.crm.model.WinLossReason;

import java.util.List;

public class WinLossService {

    private final WinLossReasonDAO winLossReasonDAO = new WinLossReasonDAO();

    public List<WinLossReason> getReasons(String reasonType) throws ValidationException {
        if (reasonType != null && !reasonType.isEmpty()) {
            validateReasonType(reasonType);
        }
        return winLossReasonDAO.findAll(reasonType);
    }

    public void createReason(String reasonType, String reasonName, int displayOrder, String status) throws ValidationException {
        validateReasonType(reasonType);
        validateName(reasonName);

        WinLossReason reason = new WinLossReason();
        reason.setReasonType(reasonType);
        reason.setReasonName(reasonName);
        reason.setDisplayOrder(displayOrder);
        reason.setStatus(status != null ? status : "ACTIVE");

        boolean success = winLossReasonDAO.insert(reason);
        if (!success) {
            throw new RuntimeException("Failed to create win/loss reason.");
        }
    }

    public void updateReason(int reasonId, String reasonType, String reasonName, int displayOrder, String status) throws ValidationException {
        validateReasonType(reasonType);
        validateName(reasonName);

        WinLossReason reason = winLossReasonDAO.findById(reasonId);
        if (reason == null) {
            throw new ValidationException("Reason not found.");
        }

        reason.setReasonType(reasonType);
        reason.setReasonName(reasonName);
        reason.setDisplayOrder(displayOrder);
        if (status != null) {
            reason.setStatus(status);
        }

        boolean success = winLossReasonDAO.update(reason);
        if (!success) {
            throw new RuntimeException("Failed to update win/loss reason.");
        }
    }

    private void validateReasonType(String type) throws ValidationException {
        if (!"WIN".equals(type) && !"LOSS".equals(type)) {
            throw new ValidationException("Invalid reason type. Must be WIN or LOSS.");
        }
    }

    private void validateName(String name) throws ValidationException {
        if (name == null || name.trim().isEmpty()) {
            throw new ValidationException("Reason name cannot be empty.");
        }
    }
}
