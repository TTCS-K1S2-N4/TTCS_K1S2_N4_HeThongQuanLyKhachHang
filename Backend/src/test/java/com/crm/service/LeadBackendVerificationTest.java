package com.crm.service;

import com.crm.controller.lead.LeadImportServlet;
import com.crm.controller.lead.LeadListServlet;
import com.crm.controller.lead.LeadPublicFormServlet;
import com.crm.controller.lead.LeadUpdateServlet;
import com.crm.controller.lead.LeadWebFormServlet;
import com.crm.dto.LeadImportRequest;
import com.crm.dto.LeadResponse;
import com.crm.dto.LeadResponse.LeadSourceValue;
import com.crm.model.Lead;
import com.crm.model.LeadSource;
import com.crm.model.LeadWebForm;
import com.crm.util.ExcelImportUtil;
import com.crm.util.LeadSpamProtectionUtil;
import jakarta.servlet.annotation.WebServlet;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class LeadBackendVerificationTest {

    @Test
    @DisplayName("S401 - Kiểm tra Model & Aliases của LeadWebForm và LeadSource")
    void testLeadWebFormAndSourceModel() {
        LeadWebForm form = new LeadWebForm();
        form.setFormId(101);
        form.setFormName("Biểu mẫu Marketing Demo");
        form.setLeadSourceId(3);
        form.setSourceName("Trực tiếp / Khách đến");

        assertEquals(101, form.getId());
        assertEquals("Biểu mẫu Marketing Demo", form.getName());
        assertEquals(3, form.getSource());
        assertEquals("Trực tiếp / Khách đến", form.getSourceName());

        LeadSource source = new LeadSource(5, "COLD_CALL", "Telesales", "Gọi điện thoại", true);
        assertEquals(5, source.getId());
        assertEquals("Telesales", source.getName());
    }

    @Test
    @DisplayName("S401 - Kiểm tra bộ lọc chống Spam (Honeypot, Từ khóa, Rate-limit, Email tạm)")
    void testSpamProtection() {
        assertTrue(LeadSpamProtectionUtil.isHoneypotTriggered("bot_input"));
        assertFalse(LeadSpamProtectionUtil.isHoneypotTriggered(""));
        assertFalse(LeadSpamProtectionUtil.isHoneypotTriggered(null));

        assertTrue(LeadSpamProtectionUtil.containsSpamKeywords("Click here for online casino bonus"));
        assertTrue(LeadSpamProtectionUtil.containsSpamKeywords("<script>alert('xss')</script>"));
        assertFalse(LeadSpamProtectionUtil.containsSpamKeywords("Tôi quan tâm giải pháp CRM cho 50 nhân sự"));

        assertTrue(LeadSpamProtectionUtil.isSuspiciousEmail("spammer@mailinator.com"));
        assertTrue(LeadSpamProtectionUtil.isSuspiciousEmail("fake@tempmail.com"));
        assertFalse(LeadSpamProtectionUtil.isSuspiciousEmail("contact@company.com.vn"));

        assertTrue(LeadSpamProtectionUtil.isDomainAllowed("https://mycompany.com/landing", "mycompany.com, partner.vn"));
        assertFalse(LeadSpamProtectionUtil.isDomainAllowed("https://malicious.net/page", "mycompany.com, partner.vn"));
        assertTrue(LeadSpamProtectionUtil.isDomainAllowed("https://anywhere.com", "*"));
    }

    @Test
    @DisplayName("S402 - Kiểm tra tương thích JSP EL của LeadResponse (id, interest, source)")
    void testLeadResponseCompatibility() {
        Lead lead = new Lead();
        lead.setLeadId(88);
        lead.setFullName("Nguyễn Văn Test");
        lead.setNotes("Tìm hiểu CRM cho chuỗi cửa hàng");
        lead.setLeadSourceId(2);
        lead.setSourceName("Nhập từ Excel");

        LeadResponse response = LeadResponse.fromModel(lead);

        assertEquals(88, response.getId());
        assertEquals(88, response.getLeadId());
        assertEquals("Tìm hiểu CRM cho chuỗi cửa hàng", response.getInterest());
        assertEquals("Tìm hiểu CRM cho chuỗi cửa hàng", response.getNotes());

        Object sourceObj = response.getSource();
        assertNotNull(sourceObj);
        assertTrue(sourceObj instanceof LeadSourceValue);

        // Hiển thị dạng text trong detail.jsp (${lead.source})
        assertEquals("Nhập từ Excel", sourceObj.toString());

        // So sánh với số nguyên trong edit.jsp (${lead.source == src.id})
        assertTrue(sourceObj.equals(2));
        assertTrue(sourceObj.equals("Nhập từ Excel"));
        assertFalse(sourceObj.equals(99));
    }

    @Test
    @DisplayName("S402 - Kiểm tra đọc Excel với WorkbookFactory hỗ trợ đúng 10 cột")
    void testWorkbookFactoryTenColumns() throws Exception {
        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Leads");
            Row header = sheet.createRow(0);
            String[] headers = {
                "Họ và tên", "Chức danh", "Công ty", "Email", "Số điện thoại",
                "Nguồn Lead", "Trạng thái", "Đánh giá", "Ngành nghề", "Ghi chú"
            };
            for (int i = 0; i < headers.length; i++) {
                header.createCell(i).setCellValue(headers[i]);
            }

            Row row1 = sheet.createRow(1);
            row1.createCell(0).setCellValue("Lê Văn Tuấn");
            row1.createCell(1).setCellValue("Giám đốc");
            row1.createCell(2).setCellValue("Công ty Tuấn Phát");
            row1.createCell(3).setCellValue("tuan.le@tuanphat.vn");
            row1.createCell(4).setCellValue("0912345678");
            row1.createCell(5).setCellValue("Nhập từ Excel");
            row1.createCell(6).setCellValue("NEW");
            row1.createCell(7).setCellValue("HOT");
            row1.createCell(8).setCellValue("Sản xuất");
            row1.createCell(9).setCellValue("Cần tư vấn trong tuần");

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            wb.write(baos);

            try (InputStream in = new ByteArrayInputStream(baos.toByteArray())) {
                List<LeadImportRequest> list = ExcelImportUtil.parseLeadImport(in);
                assertEquals(1, list.size());
                LeadImportRequest r = list.get(0);
                assertEquals("Lê Văn Tuấn", r.getFullName());
                assertEquals("Giám đốc", r.getTitle());
                assertEquals("Công ty Tuấn Phát", r.getCompany());
                assertEquals("tuan.le@tuanphat.vn", r.getEmail());
                assertEquals("0912345678", r.getPhone());
                assertEquals("Nhập từ Excel", r.getSourceName());
                assertEquals("NEW", r.getStatus());
                assertEquals("HOT", r.getRating());
                assertEquals("Sản xuất", r.getIndustry());
                assertEquals("Cần tư vấn trong tuần", r.getNotes());
            }
        }
    }

    @Test
    @DisplayName("S401 & S402 - Kiểm tra Servlet URL mappings đồng bộ với giao diện")
    void testServletMappings() {
        assertServletHasMapping(LeadUpdateServlet.class, "/leads/edit");
        assertServletHasMapping(LeadUpdateServlet.class, "/leads/update");

        assertServletHasMapping(LeadWebFormServlet.class, "/lead-forms");
        assertServletHasMapping(LeadWebFormServlet.class, "/leads/web-forms");

        assertServletHasMapping(LeadPublicFormServlet.class, "/public/leads");
        assertServletHasMapping(LeadPublicFormServlet.class, "/leads/public-form");

        assertServletHasMapping(LeadImportServlet.class, "/leads/import");
        assertServletHasMapping(LeadImportServlet.class, "/leads/import/preview");
        assertServletHasMapping(LeadImportServlet.class, "/leads/import/commit");
        assertServletHasMapping(LeadImportServlet.class, "/leads/import/template");

        assertServletHasMapping(LeadListServlet.class, "/leads");
        assertServletHasMapping(LeadListServlet.class, "/leads/list");
    }

    private void assertServletHasMapping(Class<?> servletClass, String expectedUrl) {
        WebServlet ws = servletClass.getAnnotation(WebServlet.class);
        assertNotNull(ws, "Servlet " + servletClass.getSimpleName() + " phải có annotation @WebServlet");
        List<String> urls = Arrays.asList(ws.urlPatterns());
        assertTrue(urls.contains(expectedUrl),
                "Servlet " + servletClass.getSimpleName() + " thiếu mapping: " + expectedUrl + ". Hiện có: " + urls);
    }
}
