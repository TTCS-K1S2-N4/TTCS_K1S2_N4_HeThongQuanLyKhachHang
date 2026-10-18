package com.crm.service;

import com.crm.controller.lead.LeadPublicFormServlet;
import com.crm.dao.LeadDAO;
import com.crm.model.Lead;
import com.crm.model.LeadWebForm;
import com.crm.util.DBConnection;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class PublicLeadFormRealSubmissionTest {

    private final LeadWebFormService webFormService = new LeadWebFormService();
    private final LeadDAO leadDAO = new LeadDAO();

    @Test
    @DisplayName("TC-01: Gửi form với dữ liệu thật hợp lệ và xác nhận lưu thành công vào Database")
    void testRealSubmissionValidData() throws Exception {
        int formId = 11;
        String fullName = "Nguyễn Văn Test Real";
        String email = "test_real_" + System.currentTimeMillis() + "@gmail.com";
        String phone = "0987654321";
        String company = "Công Ty TNHH Giải Pháp Số Test";
        String notes = "Cần tư vấn triển khai phần mềm CRM cho 50 nhân sự.";
        String clientIp = "192.168.10." + (int)(Math.random() * 200 + 10);

        Lead createdLead = webFormService.submitAndCreateLead(
                formId, fullName, email, phone, company, notes, "http://localhost", clientIp, null, null);

        assertNotNull(createdLead, "Lead tạo ra không được null");
        assertTrue(createdLead.getLeadId() > 0, "Lead ID phải lớn hơn 0");

        // Truy vấn trực tiếp từ database để xác minh tính toàn vẹn của dữ liệu thật
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM leads WHERE lead_id = ?")) {
            ps.setInt(1, createdLead.getLeadId());
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Bản ghi Lead phải tồn tại trong CSDL thực tế");
                assertEquals(fullName, rs.getString("full_name"));
                assertEquals("Real", rs.getString("first_name"));
                assertEquals("Nguyễn Văn Test", rs.getString("last_name"));
                assertEquals(email, rs.getString("email"));
                assertEquals(phone, rs.getString("phone"));
                assertEquals(company, rs.getString("company"));
                assertEquals(company, rs.getString("company_name"));
                assertEquals(fullName, rs.getString("contact_name"));
                assertEquals(notes, rs.getString("notes"));
                assertEquals(formId, rs.getInt("web_form_id"));
                assertTrue("NEW".equals(rs.getString("status")) || "ASSIGNED".equals(rs.getString("status")), "Trạng thái Lead phải là NEW hoặc ASSIGNED");
                assertTrue("WARM".equals(rs.getString("rating")) || "COLD".equals(rs.getString("rating")), "Đánh giá xếp hạng WARM hoặc COLD sau khi tính điểm");
                assertNotNull(rs.getObject("lead_source_id"), "Lead Source ID phải được tự động gán nguồn Web Form");
                assertNotNull(rs.getTimestamp("created_at"), "Thời gian tạo không được null");
            }
        }
    }

    @Test
    @DisplayName("TC-02: Validate bắt buộc họ tên, email, số điện thoại ở Backend")
    void testBackendValidationRequiredFields() {
        int formId = 11;

        // 1. Thiếu họ tên
        IllegalArgumentException exName = assertThrows(IllegalArgumentException.class, () ->
                webFormService.submitAndCreateLead(formId, "", "valid@example.com", "0912345678", "Công ty", "Ghi chú", null, "10.0.1.1", null, null));
        assertTrue(exName.getMessage().contains("Họ và tên") || exName.getMessage().contains("không được để trống"));

        // 2. Thiếu email
        IllegalArgumentException exEmail = assertThrows(IllegalArgumentException.class, () ->
                webFormService.submitAndCreateLead(formId, "Nguyễn Văn A", "", "0912345678", "Công ty", "Ghi chú", null, "10.0.1.2", null, null));
        assertTrue(exEmail.getMessage().contains("Email") || exEmail.getMessage().contains("không được để trống"));

        // 3. Email sai định dạng
        IllegalArgumentException exInvalidEmail = assertThrows(IllegalArgumentException.class, () ->
                webFormService.submitAndCreateLead(formId, "Nguyễn Văn A", "email-sai-dinh-dang", "0912345678", "Công ty", "Ghi chú", null, "10.0.1.3", null, null));
        assertTrue(exInvalidEmail.getMessage().contains("định dạng") || exInvalidEmail.getMessage().contains("email"));

        // 4. Thiếu số điện thoại
        IllegalArgumentException exPhone = assertThrows(IllegalArgumentException.class, () ->
                webFormService.submitAndCreateLead(formId, "Nguyễn Văn A", "valid@example.com", "", "Công ty", "Ghi chú", null, "10.0.1.4", null, null));
        assertTrue(exPhone.getMessage().contains("Số điện thoại") || exPhone.getMessage().contains("không được để trống"));

        // 5. Số điện thoại sai định dạng Việt Nam
        IllegalArgumentException exInvalidPhone = assertThrows(IllegalArgumentException.class, () ->
                webFormService.submitAndCreateLead(formId, "Nguyễn Văn A", "valid@example.com", "12345", "Công ty", "Ghi chú", null, "10.0.1.5", null, null));
        assertTrue(exInvalidPhone.getMessage().contains("định dạng") || exInvalidPhone.getMessage().contains("Số điện thoại"));
    }

    @Test
    @DisplayName("TC-03: Kiểm tra formId không tồn tại hoặc form bị ngưng hoạt động")
    void testFormNotFoundOrInactive() {
        int invalidFormId = 999999;
        IllegalStateException ex = assertThrows(IllegalStateException.class, () ->
                webFormService.submitAndCreateLead(invalidFormId, "Nguyễn Văn A", "test@example.com", "0912345678", "Công ty", "Ghi chú", null, "10.0.2.1", null, null));
        assertTrue(ex.getMessage().contains("không tồn tại") || ex.getMessage().contains("ngừng kích hoạt"));
    }

    @Test
    @DisplayName("TC-04: Kiểm tra cơ chế chống Spam Bot (Honeypot, Từ khóa rác, Email tạm thời)")
    void testSpamProtection() {
        int formId = 11;

        // 1. Honeypot bị kích hoạt
        SecurityException exHp = assertThrows(SecurityException.class, () ->
                webFormService.submitAndCreateLead(formId, "Spam Bot", "spambot@example.com", "0912345678", "Công ty", "Ghi chú", null, "10.0.3.1", "robot_auto_fill", null));
        assertTrue(exHp.getMessage().contains("Spam bot") || exHp.getMessage().contains("tự động"));

        // 2. Chứa từ khóa spam
        SecurityException exKeywords = assertThrows(SecurityException.class, () ->
                webFormService.submitAndCreateLead(formId, "Casino Spammer", "spammer@example.com", "0912345678", "Công ty", "Visit online casino now http://bit.ly/xyz", null, "10.0.3.2", null, null));
        assertTrue(exKeywords.getMessage().contains("từ khóa") || exKeywords.getMessage().contains("spam"));

        // 3. Email rác / tạm thời (Disposable email)
        SecurityException exEmail = assertThrows(SecurityException.class, () ->
                webFormService.submitAndCreateLead(formId, "Fake User", "fake_user@mailinator.com", "0912345678", "Công ty", "Tư vấn", null, "10.0.3.3", null, null));
        assertTrue(exEmail.getMessage().contains("email") || exEmail.getMessage().contains("spam"));
    }

    @Test
    @DisplayName("TC-05: Kiểm tra LeadPublicFormServlet xử lý AJAX JSON Request thành công")
    void testServletAjaxSuccess() throws Exception {
        LeadPublicFormServlet servlet = new LeadPublicFormServlet();
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);

        when(req.getHeader("Accept")).thenReturn("application/json");
        when(req.getParameter("formId")).thenReturn("11");
        when(req.getParameter("fullName")).thenReturn("Trần Thị Kiểm Thử");
        when(req.getParameter("email")).thenReturn("tranthi_ajax_" + System.currentTimeMillis() + "@gmail.com");
        when(req.getParameter("phone")).thenReturn("0912345678");
        when(req.getParameter("company")).thenReturn("Tập đoàn ABC");
        when(req.getParameter("notes")).thenReturn("Đăng ký nhận báo giá phần mềm");
        when(req.getRemoteAddr()).thenReturn("192.168.1.100");

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_OK);
        verify(resp).setContentType("application/json; charset=UTF-8");
        String output = sw.toString();
        assertTrue(output.contains("\"status\":\"success\""), "Response JSON phải có status success");
        assertTrue(output.contains("\"leadId\":"), "Response JSON phải trả về leadId thực tế");
    }

    @Test
    @DisplayName("TC-06: Kiểm tra LeadPublicFormServlet xử lý lỗi dữ liệu không hợp lệ trả về HTTP 400")
    void testServletBadRequest() throws Exception {
        LeadPublicFormServlet servlet = new LeadPublicFormServlet();
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);

        when(req.getHeader("Accept")).thenReturn("application/json");
        when(req.getParameter("formId")).thenReturn("11");
        when(req.getParameter("fullName")).thenReturn(""); // Rỗng
        when(req.getParameter("email")).thenReturn("test@gmail.com");
        when(req.getParameter("phone")).thenReturn("0912345678");
        when(req.getRemoteAddr()).thenReturn("192.168.1.101");

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String output = sw.toString();
        assertTrue(output.contains("\"status\":\"error\""));
        assertTrue(output.contains("Họ và tên không được để trống."));
    }

    @Test
    @DisplayName("TC-07: Kiểm tra LeadPublicFormServlet doGet với form không tồn tại trả về HTTP 404")
    void testServletDoGetFormNotFound() throws Exception {
        LeadPublicFormServlet servlet = new LeadPublicFormServlet();
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        RequestDispatcher rd = mock(RequestDispatcher.class);

        when(req.getParameter("formId")).thenReturn("999999");
        when(req.getRequestDispatcher("/WEB-INF/views/leads/public-form.jsp")).thenReturn(rd);

        servlet.doGet(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_NOT_FOUND);
        verify(req).setAttribute("webForm", null);
        verify(rd).forward(req, resp);
    }
}
