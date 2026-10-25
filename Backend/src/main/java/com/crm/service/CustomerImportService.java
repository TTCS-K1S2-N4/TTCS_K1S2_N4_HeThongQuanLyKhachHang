package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dto.CustomerImportRequest;
import com.crm.model.Customer;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class CustomerImportService {

    private final CustomerDAO customerDAO;

    public CustomerImportService() {
        this.customerDAO = new CustomerDAO();
    }

    public CustomerImportService(CustomerDAO customerDAO) {
        this.customerDAO = customerDAO;
    }

    public Map<String, Object> validatePreview(List<CustomerImportRequest> rows, int currentUserId, List<Integer> accessibleOwnerIds) {
        if (rows == null) {
            rows = Collections.emptyList();
        }

        int validRowsCount = 0;
        int invalidRowsCount = 0;

        List<CustomerImportRequest> validRows = new ArrayList<>();
        List<CustomerImportRequest> invalidRows = new ArrayList<>();
        List<CustomerImportRequest> duplicates = new ArrayList<>();
        List<CustomerImportRequest> rowErrors = new ArrayList<>();

        Set<String> phonesInFile = new HashSet<>();
        Set<String> taxCodesInFile = new HashSet<>();

        for (CustomerImportRequest row : rows) {
            boolean hasError = !row.isValid();

            // 1. Kiểm tra trùng trong file
            if (row.getPhone() != null && !row.getPhone().trim().isEmpty()) {
                String normalizedPhone = row.getPhone().trim();
                if (!phonesInFile.add(normalizedPhone)) {
                    row.setDuplicate(true);
                    row.setDuplicateReason("Số điện thoại trùng lặp trong file import");
                }
            }

            if (row.getTaxCode() != null && !row.getTaxCode().trim().isEmpty()) {
                String normalizedTaxCode = row.getTaxCode().trim();
                if (!taxCodesInFile.add(normalizedTaxCode)) {
                    row.setDuplicate(true);
                    row.setDuplicateReason("Mã số thuế trùng lặp trong file import");
                }
            }

            // 2. Kiểm tra trùng trong DB nếu chưa phát hiện trùng file
            Customer existingCustomer = customerDAO.findDuplicateCustomer(row.getTaxCode(), row.getPhone(), row.getCustomerName());
            if (existingCustomer != null) {
                row.setDuplicate(true);
                row.setExistingCustomerId(existingCustomer.getCustomerId());
                if (row.getDuplicateReason() == null) {
                    row.setDuplicateReason("Đã tồn tại trong hệ thống (ID: " + existingCustomer.getCustomerId() + ")");
                }
            }

            if (row.isDuplicate()) {
                duplicates.add(row);
            }

            if (hasError || !row.isValid() || row.isDuplicate()) {
                invalidRowsCount++;
                invalidRows.add(row);
                rowErrors.add(row);
            } else {
                validRowsCount++;
                validRows.add(row);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("totalRows", rows.size());
        result.put("validRowsCount", validRowsCount);
        result.put("invalidRowsCount", invalidRowsCount);
        result.put("validRows", validRows);
        result.put("invalidRows", invalidRows);
        result.put("duplicates", duplicates);
        result.put("rowErrors", rowErrors);

        return result;
    }

    public Map<String, Object> executeImport(List<CustomerImportRequest> rows, String duplicateAction, int currentUserId, List<Integer> accessibleOwnerIds) {
        if (rows == null || rows.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", 0);
            result.put("successCount", 0);
            result.put("failedCount", 0);
            result.put("skippedCount", 0);
            result.put("errors", Collections.singletonList("Không có dữ liệu để import."));
            return result;
        }

        java.sql.Connection conn = null;
        try {
            conn = com.crm.util.DBConnection.getConnection();
        } catch (Exception e) {
            conn = null;
        }

        return executeImportWithConnection(conn, rows, duplicateAction, currentUserId, accessibleOwnerIds);
    }

    public Map<String, Object> executeImportWithConnection(java.sql.Connection conn, List<CustomerImportRequest> rows, String duplicateAction, int currentUserId, List<Integer> accessibleOwnerIds) {
        if (rows == null || rows.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", 0);
            result.put("successCount", 0);
            result.put("failedCount", 0);
            result.put("skippedCount", 0);
            result.put("errors", Collections.singletonList("Không có dữ liệu để import."));
            return result;
        }

        String action = (duplicateAction != null && duplicateAction.equalsIgnoreCase("UPDATE")) ? "UPDATE" : "SKIP";

        int successCount = 0;
        int failedCount = 0;
        int skippedCount = 0;
        List<String> errors = new ArrayList<>();

        boolean isTransactionMode = (conn != null);
        boolean previousAutoCommit = true;

        try {
            if (isTransactionMode) {
                previousAutoCommit = conn.getAutoCommit();
                conn.setAutoCommit(false);
            }

            boolean rollbackNeeded = false;

            for (CustomerImportRequest row : rows) {
                // 1. Nếu dòng bị lỗi cú pháp / validate cơ bản -> Thất bại
                if (!row.isValid()) {
                    failedCount++;
                    errors.add("Dòng " + row.getRowIndex() + ": " + (row.getError() != null ? row.getError() : "Dữ liệu không hợp lệ"));
                    continue;
                }

                // 2. Re-verify trùng lặp trước khi ghi DB
                Customer existingCustomer = null;
                try {
                    if (conn != null) {
                        existingCustomer = (row.getExistingCustomerId() != null)
                                ? customerDAO.findById(conn, row.getExistingCustomerId())
                                : customerDAO.findDuplicateCustomer(conn, row.getTaxCode(), row.getPhone(), row.getCustomerName());
                    } else {
                        existingCustomer = (row.getExistingCustomerId() != null)
                                ? customerDAO.findById(row.getExistingCustomerId())
                                : customerDAO.findDuplicateCustomer(row.getTaxCode(), row.getPhone(), row.getCustomerName());
                    }
                } catch (Exception e) {
                    existingCustomer = null;
                }

                if (existingCustomer != null) {
                    row.setDuplicate(true);
                    row.setExistingCustomerId(existingCustomer.getCustomerId());

                    if ("SKIP".equals(action)) {
                        skippedCount++;
                        errors.add("Dòng " + row.getRowIndex() + ": Bỏ qua bản ghi trùng (Khách hàng ID " + existingCustomer.getCustomerId() + ")");
                        continue;
                    } else if ("UPDATE".equals(action)) {
                        // Kiểm tra Data Scope cho bản ghi trùng
                        boolean canUpdate = (accessibleOwnerIds == null || accessibleOwnerIds.contains(existingCustomer.getOwnerId()));
                        if (!canUpdate) {
                            failedCount++;
                            errors.add("Dòng " + row.getRowIndex() + ": Không có quyền cập nhật khách hàng ID " + existingCustomer.getCustomerId() + " (ngoài phạm vi Data Scope)");
                            continue;
                        }

                        // Cập nhật thông tin khách hàng hiện có
                        if (row.getCustomerName() != null && !row.getCustomerName().trim().isEmpty()) {
                            existingCustomer.setCustomerName(row.getCustomerName());
                        }
                        if (row.getPhone() != null && !row.getPhone().trim().isEmpty()) {
                            existingCustomer.setPhone(row.getPhone());
                        }
                        if (row.getTaxCode() != null && !row.getTaxCode().trim().isEmpty()) {
                            existingCustomer.setTaxCode(row.getTaxCode());
                        }
                        if (row.getIndustry() != null && !row.getIndustry().trim().isEmpty()) {
                            existingCustomer.setIndustry(row.getIndustry());
                        }
                        if (row.getSize() != null && !row.getSize().trim().isEmpty()) {
                            existingCustomer.setSize(row.getSize());
                        }
                        if (row.getWebsite() != null && !row.getWebsite().trim().isEmpty()) {
                            existingCustomer.setWebsite(row.getWebsite());
                        }
                        if (row.getAddress() != null && !row.getAddress().trim().isEmpty()) {
                            existingCustomer.setAddress(row.getAddress());
                        }
                        if (row.getStatus() != null && !row.getStatus().trim().isEmpty()) {
                            existingCustomer.setStatus(row.getStatus());
                        }

                        boolean updated = false;
                        try {
                            updated = (conn != null) ? customerDAO.updateCustomer(conn, existingCustomer) : customerDAO.updateCustomer(existingCustomer);
                        } catch (Exception e) {
                            updated = false;
                        }

                        if (updated) {
                            successCount++;
                        } else {
                            failedCount++;
                            rollbackNeeded = true;
                            errors.add("Dòng " + row.getRowIndex() + ": Cập nhật thất bại cho khách hàng ID " + existingCustomer.getCustomerId());
                        }
                        continue;
                    }
                }

                // 3. Tạo mới bản ghi khách hàng
                Customer newCustomer = new Customer();
                newCustomer.setCustomerName(row.getCustomerName());
                newCustomer.setPhone(row.getPhone());
                newCustomer.setTaxCode(row.getTaxCode());
                newCustomer.setIndustry(row.getIndustry());
                newCustomer.setSize(row.getSize());
                newCustomer.setWebsite(row.getWebsite());
                newCustomer.setAddress(row.getAddress());
                newCustomer.setStatus(row.getStatus() != null && !row.getStatus().trim().isEmpty() ? row.getStatus() : "ACTIVE");
                newCustomer.setOwnerId(currentUserId);

                boolean inserted = false;
                try {
                    inserted = (conn != null) ? customerDAO.insertCustomer(conn, newCustomer) : customerDAO.insertCustomer(newCustomer);
                } catch (Exception e) {
                    inserted = false;
                }

                if (inserted) {
                    successCount++;
                } else {
                    failedCount++;
                    rollbackNeeded = true;
                    errors.add("Dòng " + row.getRowIndex() + ": Không thể lưu khách hàng '" + row.getCustomerName() + "' vào CSDL.");
                }
            }

            if (isTransactionMode) {
                if (rollbackNeeded && successCount > 0) {
                    conn.rollback();
                    errors.add(0, "Xảy ra lỗi CSDL khi ghi nhận dữ liệu. Toàn bộ giao dịch đã được khôi phục (Rollback).");
                    failedCount += successCount;
                    successCount = 0;
                } else {
                    conn.commit();
                }
            }
        } catch (Exception e) {
            if (isTransactionMode) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    // ignore
                }
            }
            errors.add("Lỗi giao dịch CSDL: " + e.getMessage());
        } finally {
            if (isTransactionMode) {
                try {
                    conn.setAutoCommit(previousAutoCommit);
                    conn.close();
                } catch (Exception e) {
                    // ignore
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("totalRows", rows.size());
        result.put("successCount", successCount);
        result.put("failedCount", failedCount);
        result.put("skippedCount", skippedCount);
        result.put("errors", errors);

        return result;
    }
}
