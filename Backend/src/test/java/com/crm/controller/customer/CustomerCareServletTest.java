package com.crm.controller.customer;

import com.crm.dto.CustomerCareResponse;
import com.crm.model.CustomerCareState;
import com.crm.service.CustomerCareService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Timestamp;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class CustomerCareServletTest {

    private CustomerCareServlet servlet;
    private CustomerCareService mockService;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private StringWriter responseWriter;

    @BeforeEach
    public void setUp() throws Exception {
        servlet = new CustomerCareServlet();
        mockService = mock(CustomerCareService.class);
        servlet.setCustomerCareService(mockService);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        responseWriter = new StringWriter();

        when(request.getSession(false)).thenReturn(session);
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
    }

    @Test
    public void testDoGet_NotLoggedIn_RedirectsToLogin() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("/crm");

        servlet.doGet(request, response);

        verify(response).sendRedirect("/crm/auth/login");
    }

    @Test
    public void testDoGet_NotLoggedIn_JsonRequest_ReturnsUnauthorized() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("application/json");

        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Bạn cần đăng nhập"));
    }

    @Test
    public void testDoGet_ConfigJson_ReturnsThreshold() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(request.getPathInfo()).thenReturn("/config");
        when(request.getHeader("Accept")).thenReturn("application/json");

        when(mockService.getConfiguredInactiveDays()).thenReturn(45);

        servlet.doGet(request, response);

        verify(response).setContentType("application/json;charset=UTF-8");
        assertTrue(responseWriter.toString().contains("\"inactiveThresholdDays\": 45"));
    }

    @Test
    public void testDoGet_CareList_ForwardsToJsp() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(request.getParameter("inactiveDays")).thenReturn("30");
        RequestDispatcher rd = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/WEB-INF/views/customers/care-list.jsp")).thenReturn(rd);

        CustomerCareResponse respDto = new CustomerCareResponse();
        respDto.setCustomerId(101);
        respDto.setCustomerName("Test Customer");
        respDto.setContractValue(5000000.0);
        respDto.setDaysInactive(40);

        when(mockService.getInactiveCustomers(eq(30), eq(1), eq(20), eq(1), anyList()))
                .thenReturn(Collections.singletonList(respDto));
        when(mockService.countInactiveCustomers(eq(30), eq(1), anyList())).thenReturn(1);

        servlet.doGet(request, response);

        verify(request).setAttribute(eq("careList"), anyList());
        verify(rd).forward(request, response);
    }

    @Test
    public void testDoPost_Config_InvalidDays_ReturnsBadRequest() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(request.getPathInfo()).thenReturn("/config");
        when(request.getParameter("inactiveDays")).thenReturn("-5");
        when(request.getHeader("Accept")).thenReturn("application/json");

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(responseWriter.toString().contains("Số ngày cấu hình không hợp lệ"));
    }

    @Test
    public void testDoPost_Config_ValidDays_Success() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(request.getPathInfo()).thenReturn("/config");
        when(request.getParameter("inactiveDays")).thenReturn("60");
        when(request.getContextPath()).thenReturn("/crm");

        when(mockService.updateConfiguredInactiveDays(eq(60), eq(1), anyList())).thenReturn(true);

        servlet.doPost(request, response);

        verify(response).sendRedirect("/crm/customers/care?inactiveDays=60&success=config");
    }

    @Test
    public void testDoPost_MarkContacted_MissingCustomerId_ReturnsBadRequest() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(request.getPathInfo()).thenReturn("/mark-contacted");
        when(request.getParameter("customerId")).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("application/json");

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(responseWriter.toString().contains("ID khách hàng không hợp lệ"));
    }

    @Test
    public void testDoPost_MarkContacted_ValidParam_SuccessJson() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(request.getPathInfo()).thenReturn("/mark-contacted");
        when(request.getParameter("customerId")).thenReturn("101");
        when(request.getParameter("note")).thenReturn("Đã gọi điện hỏi thăm");
        when(request.getHeader("Accept")).thenReturn("application/json");

        CustomerCareState state = new CustomerCareState();
        state.setCareId(99);
        state.setCustomerId(101);
        state.setLastContactedAt(new Timestamp(System.currentTimeMillis()));

        when(mockService.markContacted(eq(101), eq("Đã gọi điện hỏi thăm"), eq(1), anyList()))
                .thenReturn(state);

        servlet.doPost(request, response);

        verify(response).setContentType("application/json;charset=UTF-8");
        assertTrue(responseWriter.toString().contains("\"success\": true"));
        assertTrue(responseWriter.toString().contains("\"customerId\": 101"));
        assertTrue(responseWriter.toString().contains("Ghi nhận chăm sóc khách hàng thành công"));
    }
}
