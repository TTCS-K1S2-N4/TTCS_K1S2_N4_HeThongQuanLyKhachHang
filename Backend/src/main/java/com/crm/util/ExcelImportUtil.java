package com.crm.util;

import com.crm.dto.CustomerImportRequest;
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

    public static List<CustomerImportRequest> parseCustomerImport(InputStream inputStream)
            throws IOException {

        List<CustomerImportRequest> rows = new ArrayList<>();
        DataFormatter formatter = new DataFormatter();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {

            if (workbook.getNumberOfSheets() == 0) {
                throw new IOException("File Excel không có sheet dữ liệu.");
            }

            Sheet sheet = workbook.getSheetAt(0);

            // Row 0 = header
            for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                Row excelRow = sheet.getRow(rowIndex);

                if (excelRow == null) {
                    continue;
                }

                String customerName = formatter.formatCellValue(excelRow.getCell(0)).trim();
                String phone = formatter.formatCellValue(excelRow.getCell(1)).trim();
                String taxCode = formatter.formatCellValue(excelRow.getCell(2)).trim();
                String industry = formatter.formatCellValue(excelRow.getCell(3)).trim();
                String size = formatter.formatCellValue(excelRow.getCell(4)).trim();
                String website = formatter.formatCellValue(excelRow.getCell(5)).trim();
                String address = formatter.formatCellValue(excelRow.getCell(6)).trim();
                String status = formatter.formatCellValue(excelRow.getCell(7)).trim();

                // Bỏ qua dòng hoàn toàn trống
                if (customerName.isEmpty() && phone.isEmpty() && taxCode.isEmpty()
                        && industry.isEmpty() && size.isEmpty() && website.isEmpty()
                        && address.isEmpty() && status.isEmpty()) {
                    continue;
                }

                CustomerImportRequest request = new CustomerImportRequest();
                request.setRowIndex(rowIndex + 1); // 1-based display row index
                request.setCustomerName(customerName);
                request.setPhone(phone);
                request.setTaxCode(taxCode);
                request.setIndustry(industry);
                request.setSize(size);
                request.setWebsite(website);
                request.setAddress(address);
                request.setStatus(status.isEmpty() ? "ACTIVE" : status);

                if (customerName.isEmpty()) {
                    request.addFieldError("Tên khách hàng không được để trống");
                }

                if (!phone.isEmpty() && !phone.matches("^[0-9+()\\s-]{8,20}$")) {
                    request.addFieldError("Số điện thoại không hợp lệ");
                }

                if (!website.isEmpty() && !website.matches("^(https?://)?[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(/.*)?$")) {
                    request.addFieldError("Địa chỉ website không hợp lệ");
                }

                rows.add(request);
            }
        }

        return rows;
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

            // Row 0 = header
            for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                Row excelRow = sheet.getRow(rowIndex);

                if (excelRow == null) {
                    continue;
                }

                String fullName = formatter
                        .formatCellValue(excelRow.getCell(0))
                        .trim();

                String email = formatter
                        .formatCellValue(excelRow.getCell(1))
                        .trim();

                String phone = formatter
                        .formatCellValue(excelRow.getCell(2))
                        .trim();

                // Bỏ qua dòng hoàn toàn trống
                if (fullName.isEmpty()
                        && email.isEmpty()
                        && phone.isEmpty()) {
                    continue;
                }

                ImportExcelRequest request = new ImportExcelRequest();

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
                    error.append("Email không hợp lệ; ");
                }

                if (!phone.isEmpty()
                        && !phone.matches("^0(3|5|7|8|9)[0-9]{8}$")) {
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
        return email.matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }
}