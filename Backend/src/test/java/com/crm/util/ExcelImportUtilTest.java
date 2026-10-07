package com.crm.util;

import com.crm.dto.ImportExcelRequest;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class ExcelImportUtilTest {

    @Test
    void testParsePreviewWithSttColumn() throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Users");

            // Row 0 Header with STT column
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("STT");
            header.createCell(1).setCellValue("Họ và tên");
            header.createCell(2).setCellValue("Email");
            header.createCell(3).setCellValue("Số điện thoại");

            // Row 1 - Valid user
            Row row1 = sheet.createRow(1);
            row1.createCell(0).setCellValue(1);
            row1.createCell(1).setCellValue("Nguyễn Văn An");
            row1.createCell(2).setCellValue("an.nguyen@example.com");
            row1.createCell(3).setCellValue("0912345678");

            // Row 2 - Invalid Email & Phone
            Row row2 = sheet.createRow(2);
            row2.createCell(0).setCellValue(2);
            row2.createCell(1).setCellValue("Trần Thị Bình");
            row2.createCell(2).setCellValue("invalid-email");
            row2.createCell(3).setCellValue("12345");

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            workbook.write(baos);

            try (InputStream is = new ByteArrayInputStream(baos.toByteArray())) {
                List<ImportExcelRequest> result = ExcelImportUtil.parsePreview(is);

                assertEquals(2, result.size());

                ImportExcelRequest req1 = result.get(0);
                assertEquals("Nguyễn Văn An", req1.getFullName());
                assertEquals("an.nguyen@example.com", req1.getEmail());
                assertEquals("0912345678", req1.getPhone());
                assertNull(req1.getError());

                ImportExcelRequest req2 = result.get(1);
                assertEquals("Trần Thị Bình", req2.getFullName());
                assertEquals("invalid-email", req2.getEmail());
                assertEquals("12345", req2.getPhone());
                assertNotNull(req2.getError());
                assertTrue(req2.getError().contains("Email không đúng định dạng"));
                assertTrue(req2.getError().contains("Số điện thoại không đúng định dạng"));
            }
        }
    }

    @Test
    void testParsePreviewWithoutSttColumn() throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Users");

            // Row 0 Header without STT
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("Họ và tên");
            header.createCell(1).setCellValue("Email");
            header.createCell(2).setCellValue("Số điện thoại");

            // Row 1
            Row row1 = sheet.createRow(1);
            row1.createCell(0).setCellValue("Lê Văn Cường");
            row1.createCell(1).setCellValue("cuong.le@example.com");
            row1.createCell(2).setCellValue("0987654321");

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            workbook.write(baos);

            try (InputStream is = new ByteArrayInputStream(baos.toByteArray())) {
                List<ImportExcelRequest> result = ExcelImportUtil.parsePreview(is);

                assertEquals(1, result.size());

                ImportExcelRequest req1 = result.get(0);
                assertEquals("Lê Văn Cường", req1.getFullName());
                assertEquals("cuong.le@example.com", req1.getEmail());
                assertEquals("0987654321", req1.getPhone());
                assertNull(req1.getError());
            }
        }
    }
}
