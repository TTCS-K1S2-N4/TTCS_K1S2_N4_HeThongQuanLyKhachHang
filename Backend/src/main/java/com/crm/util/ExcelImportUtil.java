package com.crm.util;

import com.crm.dto.ImportExcelRequest;

import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public final class ExcelImportUtil {

    private ExcelImportUtil() {
    }

    public static List<ImportExcelRequest> parsePreview(InputStream inputStream)
            throws IOException {

        List<ImportExcelRequest> rows = new ArrayList<>();
        DataFormatter formatter = new DataFormatter();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {

            if (workbook.getNumberOfSheets() == 0) {
                throw new IOException("File Excel không có sheet dữ liệu.");
            }

            Sheet sheet = workbook.getSheetAt(0);

            if (sheet.getLastRowNum() < 0) {
                return rows;
            }

            // Row 0 = header - Dynamically map column indices
            Row headerRow = sheet.getRow(0);

            int nameCol = -1;
            int emailCol = -1;
            int phoneCol = -1;

            if (headerRow != null) {
                for (int c = 0; c < headerRow.getLastCellNum(); c++) {
                    if (headerRow.getCell(c) == null) continue;
                    String cellVal = formatter.formatCellValue(headerRow.getCell(c)).trim().toLowerCase();
                    if (cellVal.isEmpty()) continue;

                    if (nameCol == -1 && (cellVal.contains("tên") || cellVal.contains("ten") || cellVal.contains("name"))) {
                        nameCol = c;
                    } else if (emailCol == -1 && (cellVal.contains("email") || cellVal.contains("thư") || cellVal.contains("thu"))) {
                        emailCol = c;
                    } else if (phoneCol == -1 && (cellVal.contains("thoại") || cellVal.contains("thoai") || cellVal.contains("sđt") || cellVal.contains("sdt") || cellVal.contains("phone"))) {
                        phoneCol = c;
                    }
                }
            }

            // Fallback column positions if header mapping missed any field
            if (nameCol == -1 || emailCol == -1 || phoneCol == -1) {
                boolean col0IsStt = false;
                if (headerRow != null && headerRow.getCell(0) != null) {
                    String col0Head = formatter.formatCellValue(headerRow.getCell(0)).trim().toLowerCase();
                    if (col0Head.equals("stt") || col0Head.equals("#") || col0Head.equals("no") || col0Head.equals("no.") || col0Head.equals("tt")) {
                        col0IsStt = true;
                    }
                }

                if (col0IsStt) {
                    if (nameCol == -1) nameCol = 1;
                    if (emailCol == -1) emailCol = 2;
                    if (phoneCol == -1) phoneCol = 3;
                } else {
                    if (nameCol == -1) nameCol = 0;
                    if (emailCol == -1) emailCol = 1;
                    if (phoneCol == -1) phoneCol = 2;
                }
            }

            for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                Row excelRow = sheet.getRow(rowIndex);

                if (excelRow == null) {
                    continue;
                }

                String fullName = (nameCol >= 0 && nameCol < excelRow.getLastCellNum() && excelRow.getCell(nameCol) != null)
                        ? formatter.formatCellValue(excelRow.getCell(nameCol)).trim()
                        : "";

                String email = (emailCol >= 0 && emailCol < excelRow.getLastCellNum() && excelRow.getCell(emailCol) != null)
                        ? formatter.formatCellValue(excelRow.getCell(emailCol)).trim()
                        : "";

                String phone = (phoneCol >= 0 && phoneCol < excelRow.getLastCellNum() && excelRow.getCell(phoneCol) != null)
                        ? formatter.formatCellValue(excelRow.getCell(phoneCol)).trim()
                        : "";

                // Auto-fix 9-digit phone numbers missing leading '0' (e.g. 912345678 -> 0912345678)
                if (phone.matches("^[35789][0-9]{8}$")) {
                    phone = "0" + phone;
                }

                // Bỏ qua dòng hoàn toàn trống
                if (fullName.isEmpty() && email.isEmpty() && phone.isEmpty()) {
                    continue;
                }

                ImportExcelRequest request = new ImportExcelRequest();
                request.setRowIndex(rowIndex + 1); // 1-based row index in Excel sheet
                request.setFullName(fullName);
                request.setEmail(email);
                request.setPhone(phone);

                StringBuilder error = new StringBuilder();

                if (fullName.isEmpty()) {
                    error.append("Họ và tên không được để trống; ");
                }

                if (email.isEmpty()) {
                    error.append("Email không được để trống; ");
                } else if (!isValidEmail(email)) {
                    error.append("Email không đúng định dạng; ");
                }

                if (!phone.isEmpty() && !isValidPhone(phone)) {
                    error.append("Số điện thoại không đúng định dạng Việt Nam; ");
                }

                if (error.length() > 0) {
                    request.setError(error.toString().trim());
                }

                rows.add(request);
            }
        }

        return rows;
    }

    private static boolean isValidEmail(String email) {
        return email != null && email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    private static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return true;
        String cleaned = phone.trim().replaceAll("[\\s\\-\\.]", "");
        return cleaned.matches("^(0|\\+?84)[35789][0-9]{8}$");
    }
}