package com.crm.service;

import com.crm.dao.ContactCompanyHistoryDAO;
import com.crm.dao.ContactDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactRequest;
import com.crm.dto.ContactResponse;
import com.crm.dto.ContactTransferRequest;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Contact;
import com.crm.model.ContactCompanyHistory;
import com.crm.model.Customer;
import com.crm.util.DBConnection;
import com.crm.util.ValidationUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý nghiệp vụ Quản lý người liên hệ (Contact).
 * Quản lý vai trò mua, Primary Contact (Transaction), và Chuyển công ty (Transaction).
 * Task S30-03 / S3-02.
 */
public class ContactService {

    private static final Logger LOGGER = Logger.getLogger(ContactService.class.getName());
    public static final List<String> BUYING_ROLES = Arrays.asList("DECIDER", "INFLUENCER", "END_USER", "BLOCKER");

    private ContactDAO contactDAO = new ContactDAO();
    private ContactCompanyHistoryDAO contactCompanyHistoryDAO = new ContactCompanyHistoryDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private PermissionService permissionService = new PermissionService();

    public void setContactDAO(ContactDAO dao) { this.contactDAO = dao; }
    public void setContactCompanyHistoryDAO(ContactCompanyHistoryDAO dao) { this.contactCompanyHistoryDAO = dao; }
    public void setCustomerDAO(CustomerDAO dao) { this.customerDAO = dao; }
    public void setPermissionService(PermissionService ps) { this.permissionService = ps; }

    public List<ContactResponse> getContactsByCustomerId(int customerId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + customerId + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        List<Contact> contacts = contactDAO.findByCustomerId(customerId);
        List<ContactResponse> result = new ArrayList<>();
        for (Contact c : contacts) {
            result.add(mapToResponse(c));
        }
        return result;
    }

    public ContactResponse getContactById(int contactId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        Contact contact = contactDAO.findById(contactId);
        if (contact == null) {
            throw new ValidationException("Người liên hệ không tồn tại (ID: " + contactId + ").");
        }

        Customer customer = customerDAO.findById(contact.getCustomerId());
        if (customer == null) {
            throw new ValidationException("Khách hàng của người liên hệ không tồn tại.");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        return mapToResponse(contact);
    }

    public Contact createContact(ContactRequest request, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        validateContactRequest(request, false);

        Customer customer = customerDAO.findById(request.getCustomerId());
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + request.getCustomerId() + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        Contact contact = new Contact();
        contact.setCustomerId(request.getCustomerId());
        contact.setFullName(request.getFullName().trim());
        contact.setTitle(request.getTitle() != null ? request.getTitle().trim() : null);
        contact.setEmail(request.getEmail() != null ? request.getEmail().trim() : null);
        contact.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        contact.setBuyingRole(request.getBuyingRole().toUpperCase().trim());
        contact.setPrimary(request.getIsPrimary() != null && request.getIsPrimary());

        if (contact.isPrimary()) {
            // Transaction: reset primary cũ -> insert mới thành primary
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                conn.setAutoCommit(false);

                contactDAO.resetPrimaryForCustomer(contact.getCustomerId(), conn);
                int generatedId = contactDAO.insert(contact, conn);
                if (generatedId <= 0) {
                    throw new SQLException("Không thể tạo mới Contact.");
                }

                conn.commit();
                contact.setContactId(generatedId);
                return contact;
            } catch (SQLException e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
                }
                LOGGER.log(Level.SEVERE, "Lỗi transaction tạo Primary Contact", e);
                throw new ValidationException("Không thể tạo người liên hệ chính: " + e.getMessage());
            } finally {
                closeConnection(conn);
            }
        } else {
            int generatedId = contactDAO.insert(contact);
            if (generatedId <= 0) {
                throw new ValidationException("Không thể lưu người liên hệ vào CSDL.");
            }
            contact.setContactId(generatedId);
            return contact;
        }
    }

    public Contact updateContact(ContactRequest request, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (request.getContactId() == null || request.getContactId() <= 0) {
            throw new ValidationException("ID người liên hệ không hợp lệ.");
        }

        validateContactRequest(request, true);

        Contact existing = contactDAO.findById(request.getContactId());
        if (existing == null) {
            throw new ValidationException("Người liên hệ không tồn tại (ID: " + request.getContactId() + ").");
        }

        Customer customer = customerDAO.findById(existing.getCustomerId());
        if (customer == null) {
            throw new ValidationException("Khách hàng của người liên hệ không tồn tại.");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        existing.setFullName(request.getFullName().trim());
        existing.setTitle(request.getTitle() != null ? request.getTitle().trim() : null);
        existing.setEmail(request.getEmail() != null ? request.getEmail().trim() : null);
        existing.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        existing.setBuyingRole(request.getBuyingRole().toUpperCase().trim());
        boolean makePrimary = request.getIsPrimary() != null && request.getIsPrimary();

        if (makePrimary && !existing.isPrimary()) {
            // Transaction: reset primary cũ -> update contact thành primary
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                conn.setAutoCommit(false);

                contactDAO.resetPrimaryForCustomer(existing.getCustomerId(), conn);
                existing.setPrimary(true);
                contactDAO.update(existing, conn);

                conn.commit();
                return existing;
            } catch (SQLException e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
                }
                LOGGER.log(Level.SEVERE, "Lỗi transaction cập nhật Primary Contact", e);
                throw new ValidationException("Không thể cập nhật người liên hệ chính: " + e.getMessage());
            } finally {
                closeConnection(conn);
            }
        } else {
            existing.setPrimary(makePrimary);
            boolean updated = contactDAO.update(existing);
            if (!updated) {
                throw new ValidationException("Không thể cập nhật thông tin người liên hệ.");
            }
            return existing;
        }
    }

    public boolean setPrimaryContact(int contactId, int customerId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (contactId <= 0 || customerId <= 0) {
            throw new ValidationException("ID người liên hệ hoặc ID khách hàng không hợp lệ.");
        }

        Contact contact = contactDAO.findById(contactId);
        if (contact == null) {
            throw new ValidationException("Người liên hệ không tồn tại (ID: " + contactId + ").");
        }
        if (contact.getCustomerId() != customerId) {
            throw new ValidationException("Người liên hệ không thuộc khách hàng đã chỉ định.");
        }

        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new ValidationException("Khách hàng không tồn tại (ID: " + customerId + ").");
        }

        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());

        // BẮT BUỘC TRANSACTION: reset primary cũ -> set primary mới trên cùng Connection
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            contactDAO.resetPrimaryForCustomer(customerId, conn);
            boolean success = contactDAO.setPrimary(contactId, customerId, conn);
            if (!success) {
                throw new SQLException("Không thể thiết lập Primary Contact.");
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "Lỗi transaction thiết lập Primary Contact", e);
            throw new ValidationException("Lỗi thiết lập người liên hệ chính: " + e.getMessage());
        } finally {
            closeConnection(conn);
        }
    }

    public boolean transferContact(ContactTransferRequest request, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        if (request == null) {
            throw new ValidationException("Dữ liệu chuyển đổi không được để trống.");
        }
        if (request.getContactId() == null || request.getContactId() <= 0) {
            throw new ValidationException("ID người liên hệ không hợp lệ.");
        }
        if (request.getNewCustomerId() == null || request.getNewCustomerId() <= 0) {
            throw new ValidationException("ID khách hàng mới không hợp lệ.");
        }
        if (request.getReason() == null || request.getReason().trim().isEmpty()) {
            throw new ValidationException("Lý do chuyển đổi công ty không được để trống.");
        }

        Contact contact = contactDAO.findById(request.getContactId());
        if (contact == null) {
            throw new ValidationException("Người liên hệ không tồn tại (ID: " + request.getContactId() + ").");
        }

        int fromCustomerId = contact.getCustomerId();
        int toCustomerId = request.getNewCustomerId();

        if (fromCustomerId == toCustomerId) {
            throw new ValidationException("Khách hàng đích phải khác khách hàng hiện tại.");
        }

        Customer fromCustomer = customerDAO.findById(fromCustomerId);
        if (fromCustomer == null) {
            throw new ValidationException("Khách hàng nguồn không tồn tại.");
        }
        Customer toCustomer = customerDAO.findById(toCustomerId);
        if (toCustomer == null) {
            throw new ValidationException("Khách hàng đích không tồn tại.");
        }

        // Kiểm tra Data Scope cả customer cũ và customer mới
        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", fromCustomer.getOwnerId());
        permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", toCustomer.getOwnerId());

        // BẮT BUỘC TRANSACTION: update customer_id -> insert history trên cùng Connection
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            boolean updated = contactDAO.updateCustomerId(contact.getContactId(), toCustomerId, conn);
            if (!updated) {
                throw new SQLException("Không thể cập nhật thông tin khách hàng của Contact.");
            }

            ContactCompanyHistory history = new ContactCompanyHistory();
            history.setContactId(contact.getContactId());
            history.setFromCustomerId(fromCustomerId);
            history.setToCustomerId(toCustomerId);
            history.setReason(request.getReason().trim());
            history.setTransferredBy(userId);

            boolean insertedHistory = contactCompanyHistoryDAO.insert(history, conn);
            if (!insertedHistory) {
                throw new SQLException("Không thể lưu lịch sử chuyển đổi công ty.");
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "Lỗi transaction chuyển đổi công ty cho Contact", e);
            throw new ValidationException("Lỗi chuyển đổi công ty cho người liên hệ: " + e.getMessage());
        } finally {
            closeConnection(conn);
        }
    }

    public boolean deleteContact(int contactId, int userId, List<Integer> roleIds)
            throws ValidationException, AuthorizationException {
        Contact contact = contactDAO.findById(contactId);
        if (contact == null) {
            throw new ValidationException("Người liên hệ không tồn tại (ID: " + contactId + ").");
        }

        Customer customer = customerDAO.findById(contact.getCustomerId());
        if (customer != null) {
            permissionService.validateDataAccessForRoles(userId, roleIds, "ACCOUNT", customer.getOwnerId());
        }

        return contactDAO.delete(contactId);
    }

    private void validateContactRequest(ContactRequest request, boolean isUpdate) throws ValidationException {
        if (request == null) {
            throw new ValidationException("Dữ liệu người liên hệ không được để trống.");
        }
        if (!isUpdate && (request.getCustomerId() == null || request.getCustomerId() <= 0)) {
            throw new ValidationException("ID khách hàng không hợp lệ.");
        }
        if (!ValidationUtil.isNotEmpty(request.getFullName())) {
            throw new ValidationException("Họ và tên người liên hệ không được để trống.");
        }
        if (ValidationUtil.isNotEmpty(request.getEmail()) && !ValidationUtil.isValidEmail(request.getEmail())) {
            throw new ValidationException("Định dạng email không hợp lệ: " + request.getEmail());
        }
        if (ValidationUtil.isNotEmpty(request.getPhone()) && !ValidationUtil.isValidPhone(request.getPhone())) {
            throw new ValidationException("Số điện thoại không hợp lệ (phải từ 10-11 chữ số): " + request.getPhone());
        }
        if (request.getBuyingRole() == null || request.getBuyingRole().trim().isEmpty()) {
            request.setBuyingRole("END_USER");
        } else {
            String roleUpper = request.getBuyingRole().toUpperCase().trim();
            if (!BUYING_ROLES.contains(roleUpper)) {
                throw new ValidationException("Vai trò quyết định mua không hợp lệ (" + request.getBuyingRole() +
                        "). Cho phép: " + String.join(", ", BUYING_ROLES));
            }
            request.setBuyingRole(roleUpper);
        }
    }

    private ContactResponse mapToResponse(Contact c) {
        return new ContactResponse(
                c.getContactId(),
                c.getCustomerId(),
                c.getFullName(),
                c.getTitle(),
                c.getEmail(),
                c.getPhone(),
                c.getBuyingRole(),
                c.isPrimary(),
                c.getCreatedAt()
        );
    }

    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ex) {
                LOGGER.log(Level.WARNING, "Không thể đóng kết nối", ex);
            }
        }
    }
}
