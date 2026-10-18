package com.crm.controller.lead;

import com.crm.model.Account;
import com.crm.service.LeadAssignmentService;
import com.crm.service.LeadConversionService;
import com.crm.service.LeadDuplicateService;
import com.crm.service.LeadService;
import com.crm.service.LeadSlaService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.*;

/**
 * LeadServletSecurityAuthTest - Kiểm thử an toàn bảo mật, chống giả mạo danh tính
 * và chống leo thang quyền hạn trên 5 Lead Servlets.
 */
public class LeadServletSecurityAuthTest {

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private StringWriter responseWriter;

    @BeforeEach
    public void setUp() throws Exception {
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        responseWriter = new StringWriter();
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
    }

    // =========================================================================
    // 1. LeadAssignServlet Security Tests
    // =========================================================================

    @Test
    @DisplayName("LeadAssignServlet: Từ chối 401 khi chưa đăng nhập (Session = null)")
    public void testLeadAssignServlet_Unauthenticated_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        LeadAssignServlet servlet = new LeadAssignServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @DisplayName("LeadAssignServlet: Từ chối 401 khi giả mạo X-User-Id header mà không có Session")
    public void testLeadAssignServlet_SpoofedXUserId_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getHeader("X-User-Id")).thenReturn("1"); // Giả mạo admin id

        LeadAssignServlet servlet = new LeadAssignServlet();
        servlet.doPost(request, response);

        // Header X-User-Id bị vô hiệu hóa hoàn toàn -> phải trả về 401
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @DisplayName("LeadAssignServlet: Từ chối 403 khi Sales Rep giả mạo X-User-Role: TEAM_LEADER")
    public void testLeadAssignServlet_SalesRepSpoofingXUserRole_Returns403() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);

        // Người dùng thực tế là Sales Rep (roleId = 2)
        Account salesRep = new Account();
        salesRep.setAccountId(5);
        salesRep.setRoleId(2);
        salesRep.setRoleCodes(Collections.singletonList("SALES_REP"));
        when(session.getAttribute("currentUser")).thenReturn(salesRep);
        when(session.getAttribute("roleId")).thenReturn(2);

        // Kẻ tấn công gửi kèm header X-User-Role: TEAM_LEADER
        when(request.getHeader("X-User-Role")).thenReturn("TEAM_LEADER");

        LeadAssignServlet servlet = new LeadAssignServlet();
        servlet.doPost(request, response);

        // Phải bị từ chối 403 Forbidden do role thực tế trong Session là SALES_REP
        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        assertTrue(responseWriter.toString().contains("Chỉ Trưởng nhóm hoặc Quản trị viên mới có quyền"));
    }

    // =========================================================================
    // 2. LeadAcceptServlet Security Tests
    // =========================================================================

    @Test
    @DisplayName("LeadAcceptServlet: Từ chối 401 khi Session = null")
    public void testLeadAcceptServlet_Unauthenticated_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        LeadAcceptServlet servlet = new LeadAcceptServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @DisplayName("LeadAcceptServlet: Không tin cậy X-User-Id header nếu không có session")
    public void testLeadAcceptServlet_SpoofedXUserId_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getHeader("X-User-Id")).thenReturn("2");

        LeadAcceptServlet servlet = new LeadAcceptServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    // =========================================================================
    // 3. LeadRejectServlet Security Tests
    // =========================================================================

    @Test
    @DisplayName("LeadRejectServlet: Từ chối 401 khi Session = null")
    public void testLeadRejectServlet_Unauthenticated_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        LeadRejectServlet servlet = new LeadRejectServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @DisplayName("LeadRejectServlet: Không tin cậy X-User-Id header nếu không có session")
    public void testLeadRejectServlet_SpoofedXUserId_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getHeader("X-User-Id")).thenReturn("2");

        LeadRejectServlet servlet = new LeadRejectServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    // =========================================================================
    // 4. LeadConvertServlet Security Tests
    // =========================================================================

    @Test
    @DisplayName("LeadConvertServlet: Từ chối 401 khi Session = null trên doPost")
    public void testLeadConvertServlet_Unauthenticated_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        LeadConvertServlet servlet = new LeadConvertServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @DisplayName("LeadConvertServlet: Chuyển hướng /auth/login khi Session = null trên doGet")
    public void testLeadConvertServlet_UnauthenticatedDoGet_Redirects() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("/crm");

        LeadConvertServlet servlet = new LeadConvertServlet();
        servlet.doGet(request, response);

        verify(response).sendRedirect("/crm/auth/login");
    }

    @Test
    @DisplayName("LeadConvertServlet: Không tin cậy X-User-Id header nếu không có session")
    public void testLeadConvertServlet_SpoofedXUserId_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getHeader("X-User-Id")).thenReturn("2");

        LeadConvertServlet servlet = new LeadConvertServlet();
        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Yêu cầu đăng nhập"));
    }

    // =========================================================================
    // 5. LeadDuplicateServlet Security Tests
    // =========================================================================

    @Test
    @DisplayName("LeadDuplicateServlet: Từ chối 401 khi chưa đăng nhập (JSON request)")
    public void testLeadDuplicateServlet_UnauthenticatedJson_Returns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("application/json");

        LeadDuplicateServlet servlet = new LeadDuplicateServlet();
        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("Vui lòng đăng nhập"));
    }

    @Test
    @DisplayName("LeadDuplicateServlet: Từ chối 403 khi người dùng không có role hợp lệ")
    public void testLeadDuplicateServlet_UnauthorizedRole_Returns403() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(99);
        when(session.getAttribute("roleId")).thenReturn(999); // Role lạ, không thuộc 1,2,3,4,5
        when(session.getAttribute("roleIds")).thenReturn(Collections.singletonList(999));
        when(request.getHeader("Accept")).thenReturn("application/json");

        LeadDuplicateServlet servlet = new LeadDuplicateServlet();
        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        assertTrue(responseWriter.toString().contains("Bạn không có quyền truy cập"));
    }
}
