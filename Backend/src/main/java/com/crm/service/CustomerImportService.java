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

        String action = (duplicateAction != null && duplicateAction.equalsIgnoreCase("UPDATE")) ? "UPDATE" : "SKIP";

        int successCount = 0;
        int failedCount = 0;
        int skippedCount = 0;
        List<String> errors = new ArrayList<>();

        for (CustomerImportRequest row : rows) {
            // 1. Nếu dòng bị lỗi cú pháp / validate cơ bản -> Thất bại
            if (!row.isValid()) {
                failedCount++;
                errors.add("Dòng " + row.getRowIndex() + ": " + (row.getError() != null ? row.getError() : "Dữ liệu không hợp lệ"));
                continue;
            }

            // 2. Re-verify trùng lặp trước khi ghi DB
            Customer existingCustomer = (row.getExistingCustomerId() != null)
                    ? customerDAO.findById(row.getExistingCustomerId())
                    : customerDAO.findDuplicateCustomer(row.getTaxCode(), row.getPhone(), row.getCustomerName());

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
                    existingCustomer.setCustomerName(row.getCustomerName());
                    if (row.getPhone() != null && !row.getPhone().trim().isEmpty()) {
                        existingCustomer.setPhone(row.getPhone());
                    }

                    boolean updated = customerDAO.updateCustomer(existingCustomer);
                    if (updated) {
                        successCount++;
                    } else {
                        failedCount++;
                        errors.add("Dòng " + row.getRowIndex() + ": Cập nhật thất bại cho khách hàng ID " + existingCustomer.getCustomerId());
                    }
                    continue;
                }
            }

            // 3. Tạo mới bản ghi khách hàng
            Customer newCustomer = new Customer();
            newCustomer.setCustomerName(row.getCustomerName());
            newCustomer.setPhone(row.getPhone());
            newCustomer.setOwnerId(currentUserId);

            boolean inserted = customerDAO.insertCustomer(newCustomer);
            if (inserted) {
                successCount++;
            } else {
                failedCount++;
                errors.add("Dòng " + row.getRowIndex() + ": Không thể lưu khách hàng '" + row.getCustomerName() + "' vào CSDL.");
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
