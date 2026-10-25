package com.crm.controller.customer;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class CustomerSaveServletTest {

    private CustomerSaveServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private StringWriter responseWriter;

    @BeforeEach
    public void setUp() throws Exception {
        servlet = new CustomerSaveServlet();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        responseWriter = new StringWriter();

        when(request.getSession()).thenReturn(session);
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
        when(request.getRequestURI()).thenReturn("/customers/create");
    }

    @Test
    public void testDoPost_NotLoggedIn_ReturnsUnauthorized() throws Exception {
        when(session.getAttribute("userId")).thenReturn(null);

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Chưa đăng nhập"));
    }

    @Test
    public void testDoPost_EmptyName_ReturnsBadRequest() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(request.getParameter("customerName")).thenReturn("");

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(responseWriter.toString().contains("Tên khách hàng không được để trống"));
    }

    @Test
    public void testDoPost_InvalidStatus_ReturnsBadRequest() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(request.getParameter("customerName")).thenReturn("Công ty XYZ");
        when(request.getParameter("status")).thenReturn("INVALID_STATUS");

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(responseWriter.toString().contains("Trạng thái khách hàng không hợp lệ"));
    }
}
