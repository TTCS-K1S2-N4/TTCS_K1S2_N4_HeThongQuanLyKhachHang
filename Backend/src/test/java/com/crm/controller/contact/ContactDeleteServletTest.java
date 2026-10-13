package com.crm.controller.contact;

import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.service.ContactService;
import com.crm.service.PermissionService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit test cho ContactDeleteServlet.
 * Kiểm tra xác thực, phân quyền (ACCOUNT_DELETE theo effectiveRoles),
 * xử lý form POST và JSON POST, xử lý lỗi 401, 403, 400.
 */
public class ContactDeleteServletTest {

    private ContactDeleteServlet servlet;
    private ContactService mockContactService;
    private PermissionService mockPermissionService;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;
    private StringWriter responseWriter;

    @BeforeEach
    public void setUp() throws Exception {
        servlet = new ContactDeleteServlet();
        mockContactService = mock(ContactService.class);
        mockPermissionService = mock(PermissionService.class);

        servlet.setContactService(mockContactService);
        servlet.setPermissionService(mockPermissionService);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);
        responseWriter = new StringWriter();

        when(request.getSession(false)).thenReturn(session);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
        when(request.getContextPath()).thenReturn("/crm");
    }

    @Test
    @DisplayName("Chưa đăng nhập - JSON request trả về 401 Unauthorized")
    public void testDoPost_NotLoggedIn_JsonRequest_Returns401() throws Exception {
        when(session.getAttribute("userId")).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("application/json");

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("\"status\": 401"));
        assertTrue(responseWriter.toString().contains("Bạn cần đăng nhập"));
        verifyNoInteractions(mockContactService);
    }

    @Test
    @DisplayName("Chưa đăng nhập - Form request chuyển hướng đến /auth/login")
    public void testDoPost_NotLoggedIn_FormRequest_RedirectsToLogin() throws Exception {
        when(session.getAttribute("userId")).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("text/html");

        servlet.doPost(request, response);

        verify(response).sendRedirect("/crm/auth/login");
        verifyNoInteractions(mockContactService);
    }

    @Test
    @DisplayName("Không có quyền ACCOUNT_DELETE - JSON request trả về 403 Forbidden")
    public void testDoPost_NoPermission_JsonRequest_Returns403() throws Exception {
        when(session.getAttribute("userId")).thenReturn(10);
        when(session.getAttribute("roleIds")).thenReturn(Arrays.asList(2, 3));
        when(request.getHeader("Accept")).thenReturn("application/json");

        // Giả lập roleIds không có quyền ACCOUNT_DELETE
        when(mockPermissionService.hasPermissionForRoles(Arrays.asList(2, 3), "ACCOUNT_DELETE")).thenReturn(false);

        servlet.doPost(request, response);

        verify(mockPermissionService).hasPermissionForRoles(Arrays.asList(2, 3), "ACCOUNT_DELETE");
        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        assertTrue(responseWriter.toString().contains("\"status\": 403"));
        assertTrue(responseWriter.toString().contains("ACCOUNT_DELETE"));
        verifyNoInteractions(mockContactService);
    }

    @Test
    @DisplayName("Không có quyền ACCOUNT_DELETE - Form request forward đến 403.jsp")
    public void testDoPost_NoPermission_FormRequest_ForwardsTo403() throws Exception {
        when(session.getAttribute("userId")).thenReturn(10);
        when(session.getAttribute("roleId")).thenReturn(2);
        when(session.getAttribute("roleIds")).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("text/html");

        // Giả lập roleId duy nhất không có quyền
        when(mockPermissionService.hasPermissionForRoles(Collections.singletonList(2), "ACCOUNT_DELETE")).thenReturn(false);

        servlet.doPost(request, response);

        verify(mockPermissionService).hasPermissionForRoles(Collections.singletonList(2), "ACCOUNT_DELETE");
        verify(request).getRequestDispatcher("/WEB-INF/views/errors/403.jsp");
        verify(dispatcher).forward(request, response);
        verifyNoInteractions(mockContactService);
    }

    @Test
    @DisplayName("Có quyền ACCOUNT_DELETE - Form POST hợp lệ - Xóa thành công và chuyển hướng")
    public void testDoPost_HasPermission_FormRequest_Success() throws Exception {
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);
        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getHeader("Accept")).thenReturn("text/html");
        when(request.getParameter("contactId")).thenReturn("55");
        when(request.getParameter("customerId")).thenReturn("100");

        when(mockPermissionService.hasPermissionForRoles(roles, "ACCOUNT_DELETE")).thenReturn(true);
        when(mockContactService.deleteContact(55, userId, roles)).thenReturn(true);

        servlet.doPost(request, response);

        verify(mockPermissionService).hasPermissionForRoles(roles, "ACCOUNT_DELETE");
        verify(mockContactService).deleteContact(55, userId, roles);
        verify(session).setAttribute("message", "Đã xóa người liên hệ thành công.");
        verify(response).sendRedirect("/crm/contacts?customerId=100");
    }

    @Test
    @DisplayName("Có quyền ACCOUNT_DELETE - JSON POST hợp lệ - Xóa thành công trả về JSON 200")
    public void testDoPost_HasPermission_JsonRequest_Success() throws Exception {
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);
        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getContentType()).thenReturn("application/json");
        when(request.getHeader("Accept")).thenReturn("application/json");

        String jsonBody = "{\"contactId\": 55, \"customerId\": 100}";
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(jsonBody)));

        when(mockPermissionService.hasPermissionForRoles(roles, "ACCOUNT_DELETE")).thenReturn(true);
        when(mockContactService.deleteContact(55, userId, roles)).thenReturn(true);

        servlet.doPost(request, response);

        verify(mockPermissionService).hasPermissionForRoles(roles, "ACCOUNT_DELETE");
        verify(mockContactService).deleteContact(55, userId, roles);
        assertTrue(responseWriter.toString().contains("\"success\": true"));
        assertTrue(responseWriter.toString().contains("\"contactId\": 55"));
    }

    @Test
    @DisplayName("Có quyền ACCOUNT_DELETE nhưng vi phạm Data Scope trong Service - Trả về 403 Forbidden")
    public void testDoPost_HasPermission_DataScopeViolation_Returns403() throws Exception {
        int userId = 10;
        List<Integer> roles = Collections.singletonList(2);
        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getHeader("Accept")).thenReturn("application/json");
        when(request.getParameter("contactId")).thenReturn("55");

        when(mockPermissionService.hasPermissionForRoles(roles, "ACCOUNT_DELETE")).thenReturn(true);
        when(mockContactService.deleteContact(55, userId, roles))
                .thenThrow(new AuthorizationException("Bạn không có quyền truy cập người liên hệ thuộc khách hàng này."));

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        assertTrue(responseWriter.toString().contains("\"status\": 403"));
        assertTrue(responseWriter.toString().contains("không có quyền truy cập"));
    }

    @Test
    @DisplayName("Thiếu contactId - Trả về 400 Bad Request")
    public void testDoPost_MissingContactId_ReturnsBadRequest() throws Exception {
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);
        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getHeader("Accept")).thenReturn("application/json");
        when(request.getParameter("contactId")).thenReturn(null);
        when(request.getParameter("id")).thenReturn("");

        when(mockPermissionService.hasPermissionForRoles(roles, "ACCOUNT_DELETE")).thenReturn(true);

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(responseWriter.toString().contains("\"status\": 400"));
        verifyNoInteractions(mockContactService);
    }
}
