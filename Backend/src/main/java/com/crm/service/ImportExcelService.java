package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.ImportExcelRequest;

import com.crm.dao.RoleDAO;
import com.crm.model.Role;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.crm.dto.AccountCreateRequest;

public class ImportExcelService {

    private final AccountDAO accountDAO;
    private final RoleDAO roleDAO;
    private final AccountService accountService;

    public ImportExcelService() {
        this(new AccountDAO(), new RoleDAO(), new AccountService());
    }

    public ImportExcelService(AccountDAO accountDAO, RoleDAO roleDAO, AccountService accountService) {
        this.accountDAO = accountDAO;
        this.roleDAO = roleDAO;
        this.accountService = accountService;
    }

    public Map<String, Object> validatePreview(List<ImportExcelRequest> rows) {

        if (rows == null) {
            rows = Collections.emptyList();
        }

        int validRows = 0;
        int invalidRows = 0;
        List<ImportExcelRequest> rowErrors = new java.util.ArrayList<>();
        List<ImportExcelRequest> allRows = new java.util.ArrayList<>();

        java.util.Set<String> emailsInFile = new java.util.HashSet<>();

        for (ImportExcelRequest row : rows) {
            allRows.add(row);

            if (row.isValid()
                    && row.getEmail() != null
                    && !row.getEmail().trim().isEmpty()) {

                String normalizedEmail = row.getEmail().trim().toLowerCase(java.util.Locale.ROOT);

                if (!emailsInFile.add(normalizedEmail)) {
                    row.setError("Email bị trùng trong file import");
                }
            }

            if (row.isValid()
                    && row.getEmail() != null
                    && !row.getEmail().trim().isEmpty()
                    && accountDAO.isEmailExists(row.getEmail().trim(), -1)) {
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
        result.put("allRows", allRows);
        result.put("rowErrors", rowErrors);

        return result;
    }

    public Map<String, Object> executeImport(List<ImportExcelRequest> rows) {

        if (rows == null || rows.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", 0);
            result.put("successCount", 0);
            result.put("failedCount", 0);
            result.put("errors", Collections.singletonList("Không có dữ liệu để import."));
            return result;
        }

        int successCount = 0;
        int failedCount = 0;
        List<String> errors = new java.util.ArrayList<>();

        Role defaultRole = null;

        try {
            defaultRole = roleDAO.findByCode("SALES_REP");
            if (defaultRole == null) {
                // Fallback to first role if SALES_REP not found
                List<Role> roles = roleDAO.findAll();
                if (roles != null && !roles.isEmpty()) {
                    defaultRole = roles.get(0);
                }
            }
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", rows.size());
            result.put("successCount", 0);
            result.put("failedCount", rows.size());
            result.put("errors", Collections.singletonList("Không thể tải vai trò mặc định: " + e.getMessage()));
            return result;
        }

        if (defaultRole == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalRows", rows.size());
            result.put("successCount", 0);
            result.put("failedCount", rows.size());
            result.put("errors", Collections.singletonList("Không tìm thấy vai trò hệ thống cho tài khoản mới."));
            return result;
        }

        for (ImportExcelRequest row : rows) {
            String rowLabel = "Dòng " + (row.getRowIndex() > 0 ? row.getRowIndex() : "?");
            String emailLabel = (row.getEmail() != null && !row.getEmail().isEmpty()) ? row.getEmail() : "Chưa có email";

            // 1. Bỏ qua dòng đã không hợp lệ từ bước preview/validate
            if (!row.isValid()) {
                failedCount++;
                errors.add(rowLabel + " (" + emailLabel + ") bị bỏ qua do lỗi: " + row.getError());
                continue;
            }

            // 2. Revalidate email ngay trước khi ghi DB (phòng race condition)
            if (accountDAO.isEmailExists(row.getEmail(), -1)) {
                failedCount++;
                errors.add(rowLabel + " (" + emailLabel + "): Email đã tồn tại trong hệ thống");
                continue;
            }

            try {
                AccountCreateRequest accountRequest = new AccountCreateRequest(
                        row.getEmail(),
                        null,
                        row.getFullName(),
                        row.getPhone(),
                        Collections.singletonList(defaultRole.getId()),
                        row.getTeamId());

                AccountService.CreateAccountResult createResult = accountService.createAccountResult(accountRequest);

                if (createResult.getStatus() == AccountService.CreateAccountStatus.SUCCESS_EMAIL_SENT) {
                    successCount++;
                } else if (createResult.getStatus() == AccountService.CreateAccountStatus.SUCCESS_EMAIL_FAILED) {
                    successCount++;
                    errors.add(rowLabel + " (" + emailLabel + "): Tạo thành công nhưng không gửi được email thông báo ("
                            + (createResult.getErrorMessage() != null ? createResult.getErrorMessage() : "Lỗi SMTP") + ")");
                } else {
                    failedCount++;
                    errors.add(rowLabel + " (" + emailLabel + "): Thất bại - "
                            + (createResult.getErrorMessage() != null ? createResult.getErrorMessage() : "Không thể tạo tài khoản"));
                }
            } catch (Exception e) {
                failedCount++;
                errors.add(rowLabel + " (" + emailLabel + "): Lỗi ngoại lệ - " + e.getMessage());
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
