package com.crm.service;

import com.crm.controller.lead.LeadConvertServlet;
import com.crm.dto.LeadConversionRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Unit Test suite cho S4-08: Lead Conversion.
 */
class LeadConversionServiceTest {

    private LeadConversionService conversionService;

    @BeforeEach
    void setUp() {
        conversionService = new LeadConversionService();
    }

    @Test
    @DisplayName("S4-08 UT-01: Kiểm tra tính hợp lệ của LeadConversionRequest")
    void testLeadConversionRequest_Validation() {
        LeadConversionRequest reqNull = new LeadConversionRequest();
        assertFalse(reqNull.isValid(), "Request chưa có leadId phải là invalid");

        LeadConversionRequest reqZero = new LeadConversionRequest(0, "Cơ hội");
        assertFalse(reqZero.isValid(), "leadId <= 0 phải là invalid");

        LeadConversionRequest reqNegative = new LeadConversionRequest(-5, "Cơ hội");
        assertFalse(reqNegative.isValid(), "leadId âm phải là invalid");

        LeadConversionRequest reqValid = new LeadConversionRequest(10, "Cơ hội Vinamilk", 50000000.0, 101);
        assertTrue(reqValid.isValid(), "leadId > 0 phải là valid");
        assertEquals(10, reqValid.getLeadId());
        assertEquals("Cơ hội Vinamilk", reqValid.getOpportunityName());
        assertEquals(50000000.0, reqValid.getExpectedRevenue());
        assertEquals(101, reqValid.getAccountId());
    }

    @Test
    @DisplayName("S4-08 UT-02: Kiểm tra ConversionResult model")
    void testConversionResult_Model() {
        LeadConversionService.ConversionResult resultWithOpp = new LeadConversionService.ConversionResult(1, 2, 3, 5);
        assertEquals(1, resultWithOpp.getCustomerId());
        assertEquals(2, resultWithOpp.getContactId());
        assertEquals(3, resultWithOpp.getOpportunityId());
        assertEquals(5, resultWithOpp.getActivityCount());

        LeadConversionService.ConversionResult resultNoOpp = new LeadConversionService.ConversionResult(1, 2, null, 0);
        assertNull(resultNoOpp.getOpportunityId());
        assertEquals(0, resultNoOpp.getActivityCount());
    }

    @Test
    @DisplayName("S4-08 UT-03: Kiểm tra đầu vào convertLead khi request null hoặc invalid")
    void testConvertLead_InputValidation() {
        assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(null, 101, false);
        });

        LeadConversionRequest invalidReq = new LeadConversionRequest(0, "Tên");
        assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(invalidReq, 101, false);
        });
    }

    @Test
    @DisplayName("S4-08 UT-04: LeadConvertServlet từ chối khi chưa đăng nhập (Session null) -> HTTP 401")
    void testServlet_Unauthenticated_SessionNull() throws Exception {
        LeadConvertServlet servlet = new LeadConvertServlet();
        servlet.setConversionService(conversionService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(null);
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(sw.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @DisplayName("S4-08 UT-05: LeadConvertServlet từ chối khi thiếu tham số leadId -> HTTP 400")
    void testServlet_MissingLeadId() throws Exception {
        LeadConvertServlet servlet = new LeadConvertServlet();
        servlet.setConversionService(conversionService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(101);
        when(req.getParameter("leadId")).thenReturn(null);
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(sw.toString().contains("leadId là bắt buộc"));
    }
}
