package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dao.RoleDAO;
import com.crm.dto.AccountCreateRequest;
import com.crm.dto.ImportExcelRequest;
import com.crm.model.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class ImportExcelServiceTest {

    private AccountDAO accountDAO;
    private RoleDAO roleDAO;
    private AccountService accountService;
    private ImportExcelService importExcelService;

    @BeforeEach
    void setUp() {
        accountDAO = mock(AccountDAO.class);
        roleDAO = mock(RoleDAO.class);
        accountService = mock(AccountService.class);
        importExcelService = new ImportExcelService(accountDAO, roleDAO, accountService);
    }

    @Test
    void testValidatePreview_AllValid() {
        List<ImportExcelRequest> rows = new ArrayList<>();
        
        ImportExcelRequest row1 = new ImportExcelRequest();
        row1.setRowIndex(2);
        row1.setFullName("Nguyễn Văn A");
        row1.setEmail("nguyenvana@example.com");
        row1.setPhone("0912345678");
        rows.add(row1);

        ImportExcelRequest row2 = new ImportExcelRequest();
        row2.setRowIndex(3);
        row2.setFullName("Trần Thị B");
        row2.setEmail("tranthib@example.com");
        row2.setPhone("0987654321");
        rows.add(row2);

        when(accountDAO.isEmailExists(anyString(), eq(-1))).thenReturn(false);

        Map<String, Object> result = importExcelService.validatePreview(rows);

        assertEquals(2, result.get("validRows"));
        assertEquals(0, result.get("invalidRows"));
        
        @SuppressWarnings("unchecked")
        List<ImportExcelRequest> allRows = (List<ImportExcelRequest>) result.get("allRows");
        assertEquals(2, allRows.size());
        assertTrue(allRows.get(0).isValid());
        assertTrue(allRows.get(1).isValid());
    }

    @Test
    void testValidatePreview_DuplicateEmailInFile() {
        List<ImportExcelRequest> rows = new ArrayList<>();

        ImportExcelRequest row1 = new ImportExcelRequest();
        row1.setRowIndex(2);
        row1.setFullName("Nguyễn Văn A");
        row1.setEmail("duplicate@example.com");
        row1.setPhone("0912345678");
        rows.add(row1);

        ImportExcelRequest row2 = new ImportExcelRequest();
        row2.setRowIndex(3);
        row2.setFullName("Nguyễn Văn A2");
        row2.setEmail("duplicate@example.com");
        row2.setPhone("0912345679");
        rows.add(row2);

        when(accountDAO.isEmailExists(anyString(), eq(-1))).thenReturn(false);

        Map<String, Object> result = importExcelService.validatePreview(rows);

        assertEquals(1, result.get("validRows"));
        assertEquals(1, result.get("invalidRows"));

        @SuppressWarnings("unchecked")
        List<ImportExcelRequest> rowErrors = (List<ImportExcelRequest>) result.get("rowErrors");
        assertEquals(1, rowErrors.size());
        assertTrue(rowErrors.get(0).getError().contains("bị trùng trong file import"));
    }

    @Test
    void testValidatePreview_DuplicateEmailInDB() {
        List<ImportExcelRequest> rows = new ArrayList<>();

        ImportExcelRequest row = new ImportExcelRequest();
        row.setRowIndex(2);
        row.setFullName("Lê Văn C");
        row.setEmail("exist@example.com");
        row.setPhone("0912345678");
        rows.add(row);

        when(accountDAO.isEmailExists("exist@example.com", -1)).thenReturn(true);

        Map<String, Object> result = importExcelService.validatePreview(rows);

        assertEquals(0, result.get("validRows"));
        assertEquals(1, result.get("invalidRows"));

        @SuppressWarnings("unchecked")
        List<ImportExcelRequest> rowErrors = (List<ImportExcelRequest>) result.get("rowErrors");
        assertEquals(1, rowErrors.size());
        assertTrue(rowErrors.get(0).getError().contains("đã tồn tại trong hệ thống"));
    }

    @Test
    void testExecuteImport_PartialSuccess_ValidImported_InvalidSkipped() throws Exception {
        Role salesRole = new Role();
        salesRole.setId(5);
        salesRole.setCode("SALES_REP");
        salesRole.setName("Nhân viên kinh doanh");

        when(roleDAO.findByCode("SALES_REP")).thenReturn(salesRole);

        List<ImportExcelRequest> rows = new ArrayList<>();

        // Valid Row
        ImportExcelRequest validRow = new ImportExcelRequest();
        validRow.setRowIndex(2);
        validRow.setFullName("Nguyễn Văn Valid");
        validRow.setEmail("valid@example.com");
        validRow.setPhone("0912345678");
        rows.add(validRow);

        // Invalid Row
        ImportExcelRequest invalidRow = new ImportExcelRequest();
        invalidRow.setRowIndex(3);
        invalidRow.setFullName("Nguyễn Văn Invalid");
        invalidRow.setEmail("invalid@example.com");
        invalidRow.setPhone("0912345678");
        invalidRow.setError("Email đã tồn tại trong hệ thống");
        rows.add(invalidRow);

        when(accountDAO.isEmailExists("valid@example.com", -1)).thenReturn(false);
        when(accountService.createAccountResult(any(AccountCreateRequest.class)))
                .thenReturn(new AccountService.CreateAccountResult(AccountService.CreateAccountStatus.SUCCESS_EMAIL_SENT, null));

        Map<String, Object> result = importExcelService.executeImport(rows);

        assertEquals(2, result.get("totalRows"));
        assertEquals(1, result.get("successCount"));
        assertEquals(1, result.get("failedCount"));

        @SuppressWarnings("unchecked")
        List<String> errors = (List<String>) result.get("errors");
        assertEquals(1, errors.size());
        assertTrue(errors.get(0).contains("bị bỏ qua do lỗi"));

        verify(accountService, times(1)).createAccountResult(any(AccountCreateRequest.class));
    }

    @Test
    void generateTestExcelFile() throws Exception {
        try (org.apache.poi.ss.usermodel.Workbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
             java.io.FileOutputStream out = new java.io.FileOutputStream("c:\\Users\\tuyet\\Downloads\\TTCS_K1S2_N4_HeThongQuanLyKhachHang\\test_user_import.xlsx")) {

            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Users");

            // Header
            org.apache.poi.ss.usermodel.Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("STT");
            header.createCell(1).setCellValue("Họ và tên");
            header.createCell(2).setCellValue("Email");
            header.createCell(3).setCellValue("Số điện thoại");

            // Row 2: Valid
            org.apache.poi.ss.usermodel.Row r1 = sheet.createRow(1);
            r1.createCell(0).setCellValue(1);
            r1.createCell(1).setCellValue("Trần Văn Test1");
            r1.createCell(2).setCellValue("test1.import@example.com");
            r1.createCell(3).setCellValue("0912345671");

            // Row 3: Valid
            org.apache.poi.ss.usermodel.Row r2 = sheet.createRow(2);
            r2.createCell(0).setCellValue(2);
            r2.createCell(1).setCellValue("Nguyễn Thị Test2");
            r2.createCell(2).setCellValue("test2.import@example.com");
            r2.createCell(3).setCellValue("0987654321");

            // Row 4: Invalid email format
            org.apache.poi.ss.usermodel.Row r3 = sheet.createRow(3);
            r3.createCell(0).setCellValue(3);
            r3.createCell(1).setCellValue("Phạm Văn Invalid");
            r3.createCell(2).setCellValue("invalid-email-format");
            r3.createCell(3).setCellValue("0912345673");

            // Row 5: Duplicate email in file
            org.apache.poi.ss.usermodel.Row r4 = sheet.createRow(4);
            r4.createCell(0).setCellValue(4);
            r4.createCell(1).setCellValue("Lê Thị Duplicate");
            r4.createCell(2).setCellValue("test1.import@example.com");
            r4.createCell(3).setCellValue("0912345674");

            // Row 6: Existing email in DB
            org.apache.poi.ss.usermodel.Row r5 = sheet.createRow(5);
            r5.createCell(0).setCellValue(5);
            r5.createCell(1).setCellValue("Admin Existing");
            r5.createCell(2).setCellValue("admin@company.com");
            r5.createCell(3).setCellValue("0912345675");

            workbook.write(out);
            System.out.println("TEST_EXCEL_FILE_CREATED_SUCCESSFULLY");
        }
    }
}
