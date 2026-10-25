package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.exception.AuthorizationException;
import com.crm.model.Customer;
import com.crm.model.CustomerRelationship;
import com.crm.service.CustomerHierarchyService;
import com.crm.service.PermissionService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class CustomerHierarchyServletTest {

    private CustomerHierarchyServlet servlet;
    private CustomerHierarchyService mockHierarchyService;
    private CustomerDAO mockCustomerDAO;
    private OpportunityDAO mockOpportunityDAO;
    private PermissionService mockPermissionService;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher requestDispatcher;

    @BeforeEach
    public void setUp() {
        servlet = new CustomerHierarchyServlet();
        mockHierarchyService = mock(CustomerHierarchyService.class);
        mockCustomerDAO = mock(CustomerDAO.class);
        mockOpportunityDAO = mock(OpportunityDAO.class);
        mockPermissionService = mock(PermissionService.class);

        servlet.setHierarchyService(mockHierarchyService);
        servlet.setCustomerDAO(mockCustomerDAO);
        servlet.setOpportunityDAO(mockOpportunityDAO);
        servlet.setPermissionService(mockPermissionService);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        requestDispatcher = mock(RequestDispatcher.class);

        when(request.getSession(false)).thenReturn(session);
        when(request.getRequestDispatcher(anyString())).thenReturn(requestDispatcher);
        when(request.getContextPath()).thenReturn("/crm");
    }

    // 1. ACCOUNT_VIEW được GET nhưng không được POST
    @Test
    @DisplayName("Test 1: Quyền ACCOUNT_VIEW được GET nhưng bị chặn HTTP 403 khi POST")
    public void test01_AccountView_CanGet_CannotPost() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(2);
        when(request.getParameter("id")).thenReturn("10");

        Customer c10 = new Customer();
        c10.setCustomerId(10);
        c10.setCustomerName("Cty A");
        c10.setOwnerId(1);
        when(mockCustomerDAO.findById(10)).thenReturn(c10);
        when(mockPermissionService.getAccessibleAccountIdsForRoles(eq(1), anyList(), eq("ACCOUNT")))
                .thenReturn(Collections.singletonList(1));

        // GET thành công
        servlet.doGet(request, response);
        verify(requestDispatcher).forward(request, response);

        // POST bị chặn vì chỉ có quyền VIEW, không có ACCOUNT_EDIT
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(false);
        servlet.doPost(request, response);
        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), contains("ACCOUNT_EDIT"));
    }

    // 2. ACCOUNT_EDIT hợp lệ được thao tác trong Data Scope
    @Test
    @DisplayName("Test 2: Tài khoản có ACCOUNT_EDIT được tạo quan hệ trong Data Scope")
    public void test02_AccountEdit_Valid_CanAddRelationship_WithinDataScope() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("20");
        when(request.getParameter("relationshipType")).thenReturn("SUBSIDIARY");

        Customer parent = new Customer();
        parent.setCustomerId(10);
        parent.setOwnerId(1);

        Customer child = new Customer();
        child.setCustomerId(20);
        child.setOwnerId(1);

        when(mockCustomerDAO.findById(10)).thenReturn(parent);
        when(mockCustomerDAO.findById(20)).thenReturn(child);
        when(mockHierarchyService.addRelationship(10, 20, "SUBSIDIARY")).thenReturn(true);

        servlet.doPost(request, response);

        verify(session).setAttribute(eq("successMessage"), contains("thành công"));
        verify(response).sendRedirect(contains("/crm/customers/hierarchy"));
    }

    // 3. MY không thao tác được với công ty ngoài phạm vi
    @Test
    @DisplayName("Test 3: Scope MY bị từ chối HTTP 403 khi thao tác công ty của nhân viên khác")
    public void test03_ScopeMy_CannotManipulateCompanyOutsideScope() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("20");

        Customer parent = new Customer();
        parent.setCustomerId(10);
        parent.setOwnerId(2); // Thuộc owner khác

        Customer child = new Customer();
        child.setCustomerId(20);
        child.setOwnerId(1);

        when(mockCustomerDAO.findById(10)).thenReturn(parent);
        when(mockCustomerDAO.findById(20)).thenReturn(child);

        doThrow(new AuthorizationException("Bạn không có quyền xem hoặc thao tác trên dữ liệu này."))
                .when(mockPermissionService).validateDataAccessForRoles(eq(1), anyList(), eq("ACCOUNT"), eq(2));

        servlet.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(mockHierarchyService, never()).addRelationship(anyInt(), anyInt(), anyString());
    }

    // 4. TEAM chỉ thao tác trong phạm vi nhóm
    @Test
    @DisplayName("Test 4: Scope TEAM thao tác được các công ty trong team, chặn ngoài team")
    public void test04_ScopeTeam_CanOnlyManipulateWithinTeam() throws Exception {
        when(session.getAttribute("userId")).thenReturn(5); // Trưởng nhóm
        when(session.getAttribute("roleId")).thenReturn(3); // Leader role
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("30");

        Customer parent = new Customer();
        parent.setCustomerId(10);
        parent.setOwnerId(6); // Member in team

        Customer childOut = new Customer();
        childOut.setCustomerId(30);
        childOut.setOwnerId(99); // Member outside team

        when(mockCustomerDAO.findById(10)).thenReturn(parent);
        when(mockCustomerDAO.findById(30)).thenReturn(childOut);

        // Parent in team -> ok, Child out of team -> AuthorizationException
        doNothing().when(mockPermissionService).validateDataAccessForRoles(eq(5), anyList(), eq("ACCOUNT"), eq(6));
        doThrow(new AuthorizationException("Không thuộc team")).when(mockPermissionService)
                .validateDataAccessForRoles(eq(5), anyList(), eq("ACCOUNT"), eq(99));

        servlet.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(mockHierarchyService, never()).addRelationship(anyInt(), anyInt(), anyString());
    }

    // 5. ALL thao tác theo quyền được cấp
    @Test
    @DisplayName("Test 5: Scope ALL được thao tác bất kỳ công ty nào trong hệ thống")
    public void test05_ScopeAll_CanManipulateAnyCompany() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1); // Admin
        when(session.getAttribute("roleId")).thenReturn(1); // Admin role
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("20");

        Customer parent = new Customer();
        parent.setCustomerId(10);
        parent.setOwnerId(101);

        Customer child = new Customer();
        child.setCustomerId(20);
        child.setOwnerId(202);

        when(mockCustomerDAO.findById(10)).thenReturn(parent);
        when(mockCustomerDAO.findById(20)).thenReturn(child);
        when(mockHierarchyService.addRelationship(10, 20, "SUBSIDIARY")).thenReturn(true);

        servlet.doPost(request, response);

        verify(mockHierarchyService).addRelationship(10, 20, "SUBSIDIARY");
        verify(session).setAttribute(eq("successMessage"), anyString());
    }

    // 6. Không thể xóa quan hệ khác bằng relationshipId giả mạo (Chống IDOR)
    @Test
    @DisplayName("Test 6: Chống IDOR - Truy xuất DB xác định quan hệ thực tế, chặn IDOR khi mismatch hoặc ngoài scope")
    public void test06_CannotDelete_ForgedRelationshipId_IDOR() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(2);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("delete");
        when(request.getParameter("relationshipId")).thenReturn("555");
        when(request.getParameter("customerId")).thenReturn("10"); // User gửi customerId=10

        // Nhưng quan hệ 555 trong DB là của công ty 80 và 90
        CustomerRelationship fakeRel = new CustomerRelationship();
        fakeRel.setRelationshipId(555);
        fakeRel.setParentCustomerId(80);
        fakeRel.setChildCustomerId(90);

        when(mockHierarchyService.getRelationshipById(555)).thenReturn(fakeRel);

        servlet.doPost(request, response);

        // Bị chặn vì 555 không gắn với customerId=10
        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), contains("không thuộc về"));
        verify(mockHierarchyService, never()).deleteRelationship(555);
    }

    // 7. Không thể gắn công ty con ngoài phạm vi
    @Test
    @DisplayName("Test 7: Không thể gắn công ty con ngoài Data Scope")
    public void test07_CannotLinkSubsidiaryOutsideScope() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("20");

        Customer parent = new Customer();
        parent.setCustomerId(10);
        parent.setOwnerId(1); // Trong scope

        Customer child = new Customer();
        child.setCustomerId(20);
        child.setOwnerId(999); // Ngoài scope

        when(mockCustomerDAO.findById(10)).thenReturn(parent);
        when(mockCustomerDAO.findById(20)).thenReturn(child);

        doNothing().when(mockPermissionService).validateDataAccessForRoles(eq(1), anyList(), eq("ACCOUNT"), eq(1));
        doThrow(new AuthorizationException("Ngoài phạm vi")).when(mockPermissionService)
                .validateDataAccessForRoles(eq(1), anyList(), eq("ACCOUNT"), eq(999));

        servlet.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(mockHierarchyService, never()).addRelationship(anyInt(), anyInt(), anyString());
    }

    // 8. Không thể tự liên kết
    @Test
    @DisplayName("Test 8: Không thể tự liên kết parentId == childId")
    public void test08_CannotSelfLink() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("10");

        servlet.doPost(request, response);

        verify(session).setAttribute(eq("errorMessage"), contains("chính nó"));
        verify(mockHierarchyService, never()).addRelationship(anyInt(), anyInt(), anyString());
    }

    // 9. Không thể tạo chu trình (Cycle Prevention)
    @Test
    @DisplayName("Test 9: Chặn tạo quan hệ tạo chu trình phân cấp (Cycle)")
    public void test09_CannotCreateCycle() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("parentId")).thenReturn("10");
        when(request.getParameter("childId")).thenReturn("20");

        Customer parent = new Customer();
        parent.setCustomerId(10);
        parent.setOwnerId(1);
        Customer child = new Customer();
        child.setCustomerId(20);
        child.setOwnerId(1);

        when(mockCustomerDAO.findById(10)).thenReturn(parent);
        when(mockCustomerDAO.findById(20)).thenReturn(child);
        when(mockHierarchyService.addRelationship(10, 20, "SUBSIDIARY")).thenReturn(false); // Cycle detected

        servlet.doPost(request, response);

        verify(session).setAttribute(eq("errorMessage"), contains("vòng lặp"));
    }

    // 10. Quan hệ không tồn tại được xử lý đúng (404)
    @Test
    @DisplayName("Test 10: Xóa quan hệ không tồn tại trả về HTTP 404")
    public void test10_NonExistentRelationship_HandledCorrectly() throws Exception {
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(mockPermissionService.hasPermissionForRoles(anyList(), eq("ACCOUNT_EDIT"))).thenReturn(true);

        when(request.getParameter("action")).thenReturn("delete");
        when(request.getParameter("relationshipId")).thenReturn("9999");

        when(mockHierarchyService.getRelationshipById(9999)).thenReturn(null);

        servlet.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_NOT_FOUND), contains("không tồn tại"));
    }

    // 11. Request thiếu session bị từ chối
    @Test
    @DisplayName("Test 11: Request không có phiên đăng nhập bị từ chối")
    public void test11_MissingSession_Rejected() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        // GET không có session -> chuyển hướng login
        servlet.doGet(request, response);
        verify(response).sendRedirect(contains("/auth/login"));

        // POST không có session -> trả về HTTP 401 Unauthorized
        servlet.doPost(request, response);
        verify(response).sendError(eq(HttpServletResponse.SC_UNAUTHORIZED), anyString());
    }
}
