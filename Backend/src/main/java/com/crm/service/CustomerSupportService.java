package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.SupportRequestDAO;
import com.crm.dto.SupportRequestDto;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Account;
import com.crm.model.Customer;
import com.crm.model.SupportRequest;
import com.crm.util.ValidationUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Yêu cầu hỗ trợ sau bán (Support Request).
 * Task S30-09 / S3-08.
 */
public class CustomerSupportService {

    public static final List<String> PRIORITIES = Arrays.asList("LOW", "MEDIUM", "HIGH", "URGENT");
    public static final List<String> STATUSES = Arrays.asList("OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED");

    private SupportRequestDAO supportRequestDAO = new SupportRequestDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private AccountDAO accountDAO = new AccountDAO();
    private PermissionService permissionService = new PermissionService();

    public void setSupportRequestDAO(SupportRequestDAO dao) { this.supportRequestDAO = dao; }
    public void setCustomerDAO(CustomerDAO dao) { this.customerDAO = dao; }
    public void setAccountDAO(AccountDAO dao) { this.accountDAO = dao; }
    public void setPermissionService(PermissionService ps) { this.permissionService = ps; }

    public List<SupportRequestDto> getSupportRequestsByCustomer(int customerId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + customerId + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        List<SupportRequest> list = supportRequestDAO.findByCustomerId(customerId);
        List<SupportRequestDto> dtos = new ArrayList<>();
        for (SupportRequest sr : list) {
            dtos.add(mapToDto(sr));
        }
        return dtos;
    }

    public SupportRequestDto getSupportRequestById(int requestId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        SupportRequest sr = supportRequestDAO.findById(requestId);
        if (sr == null) {
            throw new ValidationException("Yêu cầu hỗ trợ không tồn tại (ID: " + requestId + ").");
        }

        Customer customer = customerDAO.findById(sr.getCustomerId());
        if (customer == null) {
            throw new ValidationException("Khách hàng liên quan không tồn tại.");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        return mapToDto(sr);
    }

    public SupportRequestDto createSupportRequest(SupportRequestDto dto, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (dto == null) {
            throw new ValidationException("Dữ liệu yêu cầu hỗ trợ không được để trống.");
        }
        if (dto.getCustomerId() == null || dto.getCustomerId() <= 0) {
            throw new ValidationException("ID khách hàng không hợp lệ.");
        }
        if (!ValidationUtil.isNotEmpty(dto.getTitle())) {
            throw new ValidationException("Tiêu đề yêu cầu hỗ trợ không được để trống.");
        }

        Customer customer = customerDAO.findById(dto.getCustomerId());
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + dto.getCustomerId() + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        String priority = (dto.getPriority() != null && !dto.getPriority().trim().isEmpty())
                ? dto.getPriority().toUpperCase().trim()
                : "MEDIUM";
        if (!PRIORITIES.contains(priority)) {
            throw new ValidationException("Mức độ ưu tiên không hợp lệ (" + dto.getPriority() + "). Cho phép: " + String.join(", ", PRIORITIES));
        }

        String status = (dto.getStatus() != null && !dto.getStatus().trim().isEmpty())
                ? dto.getStatus().toUpperCase().trim()
                : "OPEN";
        if (!STATUSES.contains(status)) {
            throw new ValidationException("Trạng thái không hợp lệ (" + dto.getStatus() + "). Cho phép: " + String.join(", ", STATUSES));
        }

        if (dto.getAssigneeId() != null && dto.getAssigneeId() > 0) {
            Account assignee = accountDAO.getAccountById(dto.getAssigneeId());
            if (assignee == null) {
                throw new ValidationException("Nhân viên phụ trách không tồn tại (ID: " + dto.getAssigneeId() + ").");
            }
        }

        SupportRequest sr = new SupportRequest();
        sr.setCustomerId(dto.getCustomerId());
        sr.setTitle(dto.getTitle().trim());
        sr.setDescription(dto.getDescription() != null ? dto.getDescription().trim() : null);
        sr.setPriority(priority);
        sr.setStatus(status);
        sr.setAssigneeId(dto.getAssigneeId() != null && dto.getAssigneeId() > 0 ? dto.getAssigneeId() : null);
        sr.setCreatedBy(userId);

        int generatedId = supportRequestDAO.insert(sr);
        if (generatedId <= 0) {
            throw new ValidationException("Không thể lưu yêu cầu hỗ trợ vào CSDL.");
        }
        sr.setRequestId(generatedId);

        return mapToDto(sr);
    }

    public SupportRequestDto updateSupportRequest(SupportRequestDto dto, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (dto == null || dto.getRequestId() == null || dto.getRequestId() <= 0) {
            throw new ValidationException("ID yêu cầu hỗ trợ không hợp lệ.");
        }

        SupportRequest existing = supportRequestDAO.findById(dto.getRequestId());
        if (existing == null) {
            throw new ValidationException("Yêu cầu hỗ trợ không tồn tại (ID: " + dto.getRequestId() + ").");
        }

        Customer customer = customerDAO.findById(existing.getCustomerId());
        if (customer == null) {
            throw new ValidationException("Khách hàng liên quan không tồn tại.");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        if (ValidationUtil.isNotEmpty(dto.getTitle())) {
            existing.setTitle(dto.getTitle().trim());
        }
        if (dto.getDescription() != null) {
            existing.setDescription(dto.getDescription().trim());
        }
        if (ValidationUtil.isNotEmpty(dto.getPriority())) {
            String p = dto.getPriority().toUpperCase().trim();
            if (!PRIORITIES.contains(p)) {
                throw new ValidationException("Mức độ ưu tiên không hợp lệ: " + dto.getPriority());
            }
            existing.setPriority(p);
        }
        if (ValidationUtil.isNotEmpty(dto.getStatus())) {
            String s = dto.getStatus().toUpperCase().trim();
            if (!STATUSES.contains(s)) {
                throw new ValidationException("Trạng thái không hợp lệ: " + dto.getStatus());
            }
            existing.setStatus(s);
        }
        if (dto.getAssigneeId() != null) {
            if (dto.getAssigneeId() > 0) {
                Account assignee = accountDAO.getAccountById(dto.getAssigneeId());
                if (assignee == null) {
                    throw new ValidationException("Nhân viên phụ trách không tồn tại (ID: " + dto.getAssigneeId() + ").");
                }
                existing.setAssigneeId(dto.getAssigneeId());
            } else {
                existing.setAssigneeId(null);
            }
        }

        boolean updated = supportRequestDAO.update(existing);
        if (!updated) {
            throw new ValidationException("Không thể cập nhật yêu cầu hỗ trợ.");
        }

        return mapToDto(existing);
    }

    private SupportRequestDto mapToDto(SupportRequest sr) {
        SupportRequestDto dto = new SupportRequestDto();
        dto.setRequestId(sr.getRequestId());
        dto.setCustomerId(sr.getCustomerId());
        dto.setTitle(sr.getTitle());
        dto.setDescription(sr.getDescription());
        dto.setPriority(sr.getPriority());
        dto.setStatus(sr.getStatus());
        dto.setAssigneeId(sr.getAssigneeId());
        dto.setAssigneeName(sr.getAssigneeName());
        dto.setCreatedAt(sr.getCreatedAt());
        return dto;
    }
}
