package com.crm.filter;

import com.crm.service.PermissionService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class AuthorizationFilterTest {

    private AuthorizationFilter authorizationFilter;
    private PermissionService permissionService;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private FilterChain chain;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    @BeforeEach
    public void setUp() throws Exception {
        authorizationFilter = new AuthorizationFilter();
        permissionService = mock(PermissionService.class);
        authorizationFilter.setPermissionService(permissionService);
        authorizationFilter.init(null);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        chain = mock(FilterChain.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);

        when(request.getSession(false)).thenReturn(session);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
    }

    // 1. /products với người có PRODUCT_VIEW -> Cho phép đi tiếp
    @Test
    public void testProductsWithPermission_ShouldAllow() throws Exception {
        when(request.getServletPath()).thenReturn("/products");
        when(session.getAttribute("userId")).thenReturn(101);
        when(session.getAttribute("roleId")).thenReturn(2);
        List<Integer> roles = Collections.singletonList(2);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(permissionService.hasPermissionForRoles(roles, "PRODUCT_VIEW")).thenReturn(true);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
        verify(response, never()).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 2. /products với người KHÔNG có PRODUCT_VIEW -> 403 Forbidden
    @Test
    public void testProductsWithoutPermission_ShouldDeny() throws Exception {
        when(request.getServletPath()).thenReturn("/products");
        when(session.getAttribute("userId")).thenReturn(102);
        when(session.getAttribute("roleId")).thenReturn(5);
        List<Integer> roles = Collections.singletonList(5);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(permissionService.hasPermissionForRoles(roles, "PRODUCT_VIEW")).thenReturn(false);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 3. /products/ (dấu / ở cuối) với người KHÔNG có PRODUCT_VIEW -> 403 Forbidden
    @Test
    public void testProductsTrailingSlashWithoutPermission_ShouldDeny() throws Exception {
        when(request.getServletPath()).thenReturn("/products/");
        when(session.getAttribute("userId")).thenReturn(102);
        when(session.getAttribute("roleId")).thenReturn(5);
        List<Integer> roles = Collections.singletonList(5);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(permissionService.hasPermissionForRoles(roles, "PRODUCT_VIEW")).thenReturn(false);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 4. /categories/ (dấu / ở cuối) với người KHÔNG có CATEGORY_VIEW -> 403 Forbidden
    @Test
    public void testCategoriesTrailingSlashWithoutPermission_ShouldDeny() throws Exception {
        when(request.getServletPath()).thenReturn("/categories/");
        when(session.getAttribute("userId")).thenReturn(103);
        when(session.getAttribute("roleId")).thenReturn(5);
        List<Integer> roles = Collections.singletonList(5);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(permissionService.hasPermissionForRoles(roles, "CATEGORY_VIEW")).thenReturn(false);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 5. /organization/teams/ (dấu / ở cuối) với người KHÔNG có ORG_VIEW -> 403 Forbidden
    @Test
    public void testOrganizationTeamsTrailingSlashWithoutPermission_ShouldDeny() throws Exception {
        when(request.getServletPath()).thenReturn("/organization/teams/");
        when(session.getAttribute("userId")).thenReturn(104);
        when(session.getAttribute("roleId")).thenReturn(5);
        List<Integer> roles = Collections.singletonList(5);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(permissionService.hasPermissionForRoles(roles, "ORG_VIEW")).thenReturn(false);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 6. Endpoint tạo, sửa, xóa, xuất dữ liệu được gán đúng permission code
    @Test
    public void testEndpointPermissionMappings() {
        assertEquals("ACCOUNT_CREATE", authorizationFilter.matchRequiredPermission("/customers/create"));
        assertEquals("ACCOUNT_EDIT", authorizationFilter.matchRequiredPermission("/customers/edit"));
        assertEquals("ACCOUNT_DELETE", authorizationFilter.matchRequiredPermission("/customers/delete"));
        assertEquals("ACCOUNT_EXPORT", authorizationFilter.matchRequiredPermission("/customers/export"));

        assertEquals("USER_CREATE", authorizationFilter.matchRequiredPermission("/accounts/create"));
        assertEquals("USER_EDIT", authorizationFilter.matchRequiredPermission("/accounts/edit"));
        assertEquals("USER_DELETE", authorizationFilter.matchRequiredPermission("/accounts/delete"));

        assertEquals("PRODUCT_MANAGE", authorizationFilter.matchRequiredPermission("/products/create"));
        assertEquals("PRODUCT_MANAGE", authorizationFilter.matchRequiredPermission("/products/edit"));
        assertEquals("PRODUCT_VIEW", authorizationFilter.matchRequiredPermission("/products/detail"));
    }

    // 7. Endpoint công khai (/auth/login) và endpoint hồ sơ (/profile) vẫn hoạt động
    @Test
    public void testPublicAndProfileEndpoints_ShouldAllow() throws Exception {
        // Public endpoint
        when(request.getServletPath()).thenReturn("/auth/login");
        authorizationFilter.doFilter(request, response, chain);
        verify(chain, times(1)).doFilter(request, response);

        // Profile endpoint với user đã đăng nhập
        reset(chain, request, response);
        when(request.getSession(false)).thenReturn(session);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getServletPath()).thenReturn("/profile");
        when(session.getAttribute("userId")).thenReturn(101);
        authorizationFilter.doFilter(request, response, chain);
        verify(chain, times(1)).doFilter(request, response);
    }

    // 8. URL không xác định dưới protected prefix không tự động vượt qua (Fail Closed)
    @Test
    public void testUnknownProtectedUrl_ShouldFailClosed() throws Exception {
        when(request.getServletPath()).thenReturn("/products/unknown-action");
        when(session.getAttribute("userId")).thenReturn(101);
        when(session.getAttribute("roleId")).thenReturn(2);
        List<Integer> roles = Collections.singletonList(2);
        when(session.getAttribute("roleIds")).thenReturn(roles);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 9. Tài khoản ADMIN (roleId 1) có full quyền
    @Test
    public void testAdminAccess_ShouldAllowAll() throws Exception {
        List<Integer> adminRoles = Collections.singletonList(1);
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1);
        when(session.getAttribute("roleIds")).thenReturn(adminRoles);
        when(permissionService.hasPermissionForRoles(eq(adminRoles), anyString())).thenReturn(true);

        when(request.getServletPath()).thenReturn("/accounts/create");
        authorizationFilter.doFilter(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
    }

    // 10. DIRECTOR (roleId 4) xem được danh sách người dùng nhưng KHÔNG tạo/sửa/xóa được
    @Test
    public void testDirectorPermissions() throws Exception {
        List<Integer> directorRoles = Collections.singletonList(4);
        when(session.getAttribute("userId")).thenReturn(40);
        when(session.getAttribute("roleId")).thenReturn(4);
        when(session.getAttribute("roleIds")).thenReturn(directorRoles);

        // DIRECTOR có USER_VIEW
        when(permissionService.hasPermissionForRoles(directorRoles, "USER_VIEW")).thenReturn(true);
        // DIRECTOR không có USER_CREATE, USER_EDIT, USER_DELETE
        when(permissionService.hasPermissionForRoles(directorRoles, "USER_CREATE")).thenReturn(false);
        when(permissionService.hasPermissionForRoles(directorRoles, "USER_EDIT")).thenReturn(false);
        when(permissionService.hasPermissionForRoles(directorRoles, "USER_DELETE")).thenReturn(false);

        // 10a. Xem danh sách -> Allowed
        when(request.getServletPath()).thenReturn("/accounts/list");
        authorizationFilter.doFilter(request, response, chain);
        verify(chain, times(1)).doFilter(request, response);

        // 10b. Tạo tài khoản -> Forbidden 403
        reset(chain, response);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getServletPath()).thenReturn("/accounts/create");
        authorizationFilter.doFilter(request, response, chain);
        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);

        // 10c. Sửa tài khoản -> Forbidden 403
        reset(chain, response);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getServletPath()).thenReturn("/accounts/edit");
        authorizationFilter.doFilter(request, response, chain);
        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);

        // 10d. Khóa tài khoản -> Forbidden 403
        reset(chain, response);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getServletPath()).thenReturn("/accounts/lock");
        authorizationFilter.doFilter(request, response, chain);
        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    // 11. Request thông thường không có dấu / ở cuối tiếp tục hoạt động bình thường
    @Test
    public void testNormalRequestWithoutTrailingSlash() {
        assertEquals("/products", authorizationFilter.normalizePath("/products"));
        assertEquals("/categories", authorizationFilter.normalizePath("/categories"));
        assertEquals("PRODUCT_VIEW", authorizationFilter.matchRequiredPermission("/products"));
        assertEquals("CATEGORY_VIEW", authorizationFilter.matchRequiredPermission("/categories"));
    }

    // 12. Matrix Parameter URL (;jsessionid=...) được chuẩn hóa và bảo vệ đúng
    @Test
    public void testMatrixParameterUrlNormalization() throws Exception {
        String urlWithMatrix = "/products;jsessionid=3A8F2901B1C8";
        assertEquals("/products", authorizationFilter.normalizePath(urlWithMatrix));
        assertEquals("PRODUCT_VIEW", authorizationFilter.matchRequiredPermission(urlWithMatrix));

        when(request.getServletPath()).thenReturn(urlWithMatrix);
        when(session.getAttribute("userId")).thenReturn(105);
        when(session.getAttribute("roleId")).thenReturn(5);
        List<Integer> roles = Collections.singletonList(5);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(permissionService.hasPermissionForRoles(roles, "PRODUCT_VIEW")).thenReturn(false);

        authorizationFilter.doFilter(request, response, chain);

        verify(chain, never()).doFilter(request, response);
        verify(response, times(1)).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }
}
