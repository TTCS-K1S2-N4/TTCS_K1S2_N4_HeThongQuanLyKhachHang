package com.crm.service;

import com.crm.dao.ContactCompanyHistoryDAO;
import com.crm.dao.ContactDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactRequest;
import com.crm.dto.ContactTransferRequest;
import com.crm.exception.AuthorizationException;
import com.crm.model.Contact;
import com.crm.model.ContactCompanyHistory;
import com.crm.model.Customer;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ContactService {
    private static final Logger LOGGER = Logger.getLogger(ContactService.class.getName());

    private final ContactDAO contactDAO;
    private final ContactCompanyHistoryDAO historyDAO;
    private final CustomerDAO customerDAO;
    private final PermissionService permissionService;

    public ContactService() {
        this.contactDAO = new ContactDAO();
        this.historyDAO = new ContactCompanyHistoryDAO();
        this.customerDAO = new CustomerDAO();
        this.permissionService = new PermissionService();
    }

    public ContactService(ContactDAO contactDAO, ContactCompanyHistoryDAO historyDAO, CustomerDAO customerDAO, PermissionService permissionService) {
        this.contactDAO = contactDAO;
        this.historyDAO = historyDAO;
        this.customerDAO = customerDAO;
        this.permissionService = permissionService;
    }

    private List<Integer> resolveRoleIds(int roleId, List<Integer> roleIds) {
        if (roleIds != null && !roleIds.isEmpty()) {
            return roleIds;
        }
        if (roleId > 0) {
            return Collections.singletonList(roleId);
        }
        return Collections.emptyList();
    }

    private Customer validateAndFetchCustomerAccess(int customerId, int userId, List<Integer> roleIds) throws AuthorizationException {
        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new IllegalArgumentException("Khách hàng không tồn tại trên hệ thống.");
        }
        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());
        return customer;
    }

    public List<Contact> getContactsByCustomer(int customerId, int userId, int roleId, List<Integer> roleIds) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);
        validateAndFetchCustomerAccess(customerId, userId, effectiveRoles);
        return contactDAO.getByCustomerId(customerId);
    }

    public Contact getContactById(int contactId, int userId, int roleId, List<Integer> roleIds) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);
        Contact contact = contactDAO.findById(contactId);
        if (contact == null) {
            throw new IllegalArgumentException("Người liên hệ không tồn tại.");
        }
        validateAndFetchCustomerAccess(contact.getCustomerId(), userId, effectiveRoles);
        return contact;
    }

    public List<ContactCompanyHistory> getContactHistory(int contactId, int userId, int roleId, List<Integer> roleIds) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);
        Contact contact = contactDAO.findById(contactId);
        if (contact == null) {
            throw new IllegalArgumentException("Người liên hệ không tồn tại.");
        }
        validateAndFetchCustomerAccess(contact.getCustomerId(), userId, effectiveRoles);
        return historyDAO.getByContactId(contactId);
    }

    public boolean createContact(ContactRequest request, int userId, int roleId, List<Integer> roleIds, Map<String, String> errors) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);
        
        Map<String, String> valErrors = request.validate();
        if (!valErrors.isEmpty()) {
            errors.putAll(valErrors);
            return false;
        }

        if (request.getCustomerId() == null || request.getCustomerId() <= 0) {
            errors.put("customerId", "Vui lòng chọn khách hàng hợp lệ.");
            return false;
        }

        validateAndFetchCustomerAccess(request.getCustomerId(), userId, effectiveRoles);

        Contact contact = new Contact();
        contact.setCustomerId(request.getCustomerId());
        contact.setFullName(request.getFullName().trim());
        contact.setTitle(request.getTitle() != null ? request.getTitle().trim() : null);
        contact.setEmail(request.getEmail() != null ? request.getEmail().trim() : null);
        contact.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        contact.setBuyingRole(request.getBuyingRole().trim().toUpperCase());
        contact.setPrimary(request.isPrimary());

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            if (request.isPrimary()) {
                contactDAO.resetPrimaryForCustomer(request.getCustomerId(), conn);
            }

            int contactId = contactDAO.insert(contact, conn);
            if (contactId <= 0) {
                conn.rollback();
                errors.put("system", "Không thể lưu thông tin người liên hệ.");
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi tạo người liên hệ", e);
            errors.put("system", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean updateContact(ContactRequest request, int userId, int roleId, List<Integer> roleIds, Map<String, String> errors) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);

        Map<String, String> valErrors = request.validate();
        if (!valErrors.isEmpty()) {
            errors.putAll(valErrors);
            return false;
        }

        if (request.getContactId() == null || request.getContactId() <= 0) {
            errors.put("contactId", "ID người liên hệ không hợp lệ.");
            return false;
        }

        Contact existingContact = contactDAO.findById(request.getContactId());
        if (existingContact == null) {
            errors.put("contactId", "Người liên hệ không tồn tại.");
            return false;
        }

        validateAndFetchCustomerAccess(existingContact.getCustomerId(), userId, effectiveRoles);

        existingContact.setFullName(request.getFullName().trim());
        existingContact.setTitle(request.getTitle() != null ? request.getTitle().trim() : null);
        existingContact.setEmail(request.getEmail() != null ? request.getEmail().trim() : null);
        existingContact.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        existingContact.setBuyingRole(request.getBuyingRole().trim().toUpperCase());
        existingContact.setPrimary(request.isPrimary());

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            if (request.isPrimary()) {
                contactDAO.resetPrimaryForCustomer(existingContact.getCustomerId(), conn);
            }

            boolean updated = contactDAO.update(existingContact, conn);
            if (!updated) {
                conn.rollback();
                errors.put("system", "Không thể cập nhật người liên hệ.");
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật người liên hệ contactId=" + request.getContactId(), e);
            errors.put("system", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean setPrimaryContact(int contactId, int userId, int roleId, List<Integer> roleIds, Map<String, String> errors) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);

        Contact contact = contactDAO.findById(contactId);
        if (contact == null) {
            errors.put("contactId", "Người liên hệ không tồn tại.");
            return false;
        }

        validateAndFetchCustomerAccess(contact.getCustomerId(), userId, effectiveRoles);

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            contactDAO.resetPrimaryForCustomer(contact.getCustomerId(), conn);
            boolean updated = contactDAO.setPrimary(contactId, contact.getCustomerId(), conn);

            if (!updated) {
                conn.rollback();
                errors.put("system", "Không thể thiết lập đầu mối chính.");
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi thiết lập đầu mối chính contactId=" + contactId, e);
            errors.put("system", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean transferContact(ContactTransferRequest request, int userId, int roleId, List<Integer> roleIds, Map<String, String> errors) throws AuthorizationException {
        List<Integer> effectiveRoles = resolveRoleIds(roleId, roleIds);

        Map<String, String> valErrors = request.validate();
        if (!valErrors.isEmpty()) {
            errors.putAll(valErrors);
            return false;
        }

        Contact contact = contactDAO.findById(request.getContactId());
        if (contact == null) {
            errors.put("contactId", "Người liên hệ không tồn tại.");
            return false;
        }

        int oldCustomerId = contact.getCustomerId();
        int newCustomerId = request.getNewCustomerId();

        if (oldCustomerId == newCustomerId) {
            errors.put("newCustomerId", "Người liên hệ hiện tại đã thuộc công ty này.");
            return false;
        }

        // Validate permissions on BOTH old and new customer
        validateAndFetchCustomerAccess(oldCustomerId, userId, effectiveRoles);
        validateAndFetchCustomerAccess(newCustomerId, userId, effectiveRoles);

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Update customer link on contact record (set isPrimary=false to preserve invariant of new customer)
            boolean updated = contactDAO.updateCustomerId(request.getContactId(), newCustomerId, false, conn);
            if (!updated) {
                conn.rollback();
                errors.put("system", "Không thể chuyển công ty cho người liên hệ.");
                return false;
            }

            // Record history entry
            ContactCompanyHistory history = new ContactCompanyHistory(request.getContactId(), oldCustomerId, newCustomerId, userId);
            boolean historyRecorded = historyDAO.insert(history, conn);

            if (!historyRecorded) {
                conn.rollback();
                errors.put("system", "Không thể ghi nhận lịch sử chuyển công ty.");
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi chuyển công ty cho contactId=" + request.getContactId(), e);
            errors.put("system", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
}
