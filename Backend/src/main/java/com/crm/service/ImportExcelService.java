package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.ImportExcelRequest;

import com.crm.dao.RoleDAO;
import com.crm.model.Role;
import com.crm.security.PasswordUtil;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.crm.dto.AccountCreateRequest;

public class ImportExcelService {

    private final AccountDAO accountDAO;
    private final RoleDAO roleDAO;
    private final AccountService accountService;

    public ImportExcelService() {
        this.accountDAO = new AccountDAO();
        this.roleDAO = new RoleDAO();
        this.accountService = new AccountService();
    }

    public Map<String, Object> validatePreview(List<ImportExcelRequest> rows) {

        if (rows == null) {
            rows = Collections.emptyList();
        }

        int validRows = 0;
        int invalidRows = 0;
        List<ImportExcelRequest> rowErrors = new java.util.ArrayList<>();

        java.util.Set<String> emailsInFile = new java.util.HashSet<>();

        for (ImportExcelRequest row : rows) {
            if (row.isValid()
                    && row.getEmail() != null
                    && !row.getEmail().trim().isEmpty()) {

                String normalizedEmail = row.getEmail().trim().toLowerCase(java.util.Locale.ROOT);

                if (!emailsInFile.add(normalizedEmail)) {
                    row.setError("Email bị trùng trong file import");
                }
            }

            if (row.isValid()
                    && accountDAO.isEmailExists(row.getEmail(), -1)) {
                row.setError("Email đã tồn tại trong hệ thống");
            }

            if (row.isValid()) {
                validRows++;
            } else {
                invalidRows++;
                rowErrors.add(row);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("validRows", validRows);
        result.put("invalidRows", invalidRows);
        result.put("rowErrors", rowErrors);

        return result;
    }

    public Map<String, Object> executeImport(List<ImportExcelRequest> rows) {

        if (rows == null || rows.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", 0);
            result.put("successCount", 0);
            result.put("failedCount", 0);
            result.put(
                    "errors",
                    Collections.singletonList(
                            "Không có dữ liệu để import."));
            return result;
        }

        int successCount = 0;
        int failedCount = 0;
        List<String> errors = new java.util.ArrayList<>();

        Role defaultRole;

        try {
            defaultRole = roleDAO.findByCode("SALES_REP");
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", rows.size());
            result.put("successCount", 0);
            result.put("failedCount", rows.size());
            result.put(
                    "errors",
                    Collections.singletonList(
                            "Không thể tải role mặc định: " + e.getMessage()));
            return result;
        }

        if (defaultRole == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", rows.size());
            result.put("successCount", 0);
            result.put("failedCount", rows.size());
            result.put(
                    "errors",
                    Collections.singletonList(
                            "Không tìm thấy role mặc định SALES_REP."));
            return result;
        }

        for (ImportExcelRequest row : rows) {

            // 1. Bỏ qua dòng đã không hợp lệ từ bước preview/validate
            if (!row.isValid()) {
                failedCount++;
                errors.add(
                        "Dòng không hợp lệ: "
                                + row.getEmail()
                                + " - "
                                + row.getError());
                continue;
            }

            // 2. Revalidate email ngay trước khi ghi DB
            // Tránh trường hợp email được tạo sau bước preview
            if (accountDAO.isEmailExists(row.getEmail(), -1)) {
                failedCount++;
                errors.add(
                        "Email đã tồn tại trong hệ thống: "
                                + row.getEmail());
                continue;
            }

            try {
                AccountCreateRequest accountRequest =
        new AccountCreateRequest(
                row.getEmail(),
                null,
                row.getFullName(),
                row.getPhone(),
                Collections.singletonList(defaultRole.getId()),
                row.getTeamId());

AccountService.CreateAccountResult createResult =
        accountService.createAccountResult(accountRequest);

if (createResult.getStatus()
        == AccountService.CreateAccountStatus.SUCCESS_EMAIL_SENT) {

    successCount++;

} else if (createResult.getStatus()
        == AccountService.CreateAccountStatus.SUCCESS_EMAIL_FAILED) {

    successCount++;

    errors.add(
            "Đã tạo tài khoản nhưng gửi email mật khẩu tạm thất bại: "
                    + row.getEmail()
                    + (createResult.getErrorMessage() != null
                            ? " - " + createResult.getErrorMessage()
                            : ""));

} else {

    failedCount++;

    errors.add(
            "Không thể tạo tài khoản cho email: "
                    + row.getEmail()
                    + (createResult.getErrorMessage() != null
                            ? " - " + createResult.getErrorMessage()
                            : ""));
                }
            } catch (Exception e) {
                failedCount++;
                errors.add("Lỗi tạo tài khoản cho email " + row.getEmail() + ": " + e.getMessage());
            }
        }

        Map<String, Object> result = new HashMap<>();

        result.put("totalRows", rows.size());
        result.put("successCount", successCount);
        result.put("failedCount", failedCount);
        result.put("errors", errors);

        return result;
    }
}
