package com.crm.util;

import com.crm.dto.ImportExcelRequest;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class ExcelImportUtil {
    
    // We parse CSV as a placeholder for Excel since Apache POI is not in pom.xml
    public static List<ImportExcelRequest> parsePreview(InputStream is) {
        List<ImportExcelRequest> rows = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            boolean firstLine = true;
            while ((line = reader.readLine()) != null) {
                if (firstLine) {
                    firstLine = false;
                    continue; // Skip header
                }
                
                String[] parts = line.split(",", -1);
                ImportExcelRequest req = new ImportExcelRequest();
                
                if (parts.length >= 3) {
                    String fullName = parts[0].trim();
                    String email = parts[1].trim();
                    String phone = parts[2].trim();
                    
                    req.setFullName(fullName);
                    req.setEmail(email);
                    req.setPhone(phone);
                    
                    // Validate basic info
                    StringBuilder error = new StringBuilder();
                    if (fullName.isEmpty()) error.append("Tên không được trống; ");
                    if (email.isEmpty()) error.append("Email không được trống; ");
                    else if (!email.contains("@")) error.append("Email không hợp lệ; ");
                    
                    if (error.length() > 0) {
                        req.setError(error.toString());
                    }
                } else {
                    req.setError("Dòng thiếu dữ liệu");
                }
                
                rows.add(req);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return rows;
    }
}
