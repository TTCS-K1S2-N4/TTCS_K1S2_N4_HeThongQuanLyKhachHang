package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.ImportExcelRequest;

import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.mindrot.jbcrypt.BCrypt;

public class ImportExcelService {
    
    private final AccountDAO accountDAO;
    
    public ImportExcelService() {
        this.accountDAO = new AccountDAO();
    }
    
    public Map<String, Object> validatePreview(List<ImportExcelRequest> rows) {
        int validRows = 0;
        int invalidRows = 0;
        List<ImportExcelRequest> rowErrors = new java.util.ArrayList<>();
        
        for (ImportExcelRequest row : rows) {
            if (row.isValid()) {
                // Check if email exists
                if (accountDAO.isEmailExists(row.getEmail(), -1)) {
                    row.setError("Email đã tồn tại trong hệ thống");
                }
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
        int successCount = 0;
        int failedCount = 0;
        List<String> errors = new java.util.ArrayList<>();
        
        String defaultPasswordHash = BCrypt.hashpw("123456aA@", BCrypt.gensalt());
        
        for (ImportExcelRequest row : rows) {
            if (row.isValid()) {
                try {
                    String tokenHash = UUID.randomUUID().toString();
                    Timestamp expiry = new Timestamp(System.currentTimeMillis() + 86400000L); // 1 day
                    
                    boolean success = accountDAO.createAccount(
                        row.getEmail(), 
                        defaultPasswordHash, 
                        row.getFullName(), 
                        row.getPhone(), 
                        Collections.singletonList(1), // Default role (e.g. USER/STAFF) 
                        row.getTeamId(),
                        tokenHash,
                        expiry
                    );
                    
                    if (success) {
                        successCount++;
                    } else {
                        failedCount++;
                        errors.add("Lỗi lưu dữ liệu cho email: " + row.getEmail());
                    }
                } catch (Exception e) {
                    failedCount++;
                    errors.add("Lỗi hệ thống cho email: " + row.getEmail() + " - " + e.getMessage());
                }
            } else {
                failedCount++;
                errors.add("Dòng không hợp lệ: " + row.getEmail() + " - " + row.getError());
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
