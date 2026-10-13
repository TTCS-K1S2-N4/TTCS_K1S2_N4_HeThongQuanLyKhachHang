package com.crm.controller.contact;

import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactResponse;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.ContactCompanyHistory;
import com.crm.model.Customer;
import com.crm.service.ContactService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit test cho ContactDetailServlet.
 * Kiểm tra:
 * - Yêu cầu JSON trả về đầy đủ các trường cũ và trường "history" mới (cả có dữ liệu, rỗng, null).
 * - Yêu cầu HTML forward tới /WEB-INF/views/contacts/detail.jsp với các attributes (contact, customer, history).
 * - Xử lý ngoại lệ 401, 400, 403, 404.
 */
public class ContactDetailServletTest {

    private ContactDetailServlet servlet;
    private ContactService mockContactService;
    private CustomerDAO mockCustomerDAO;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;
    private StringWriter responseWriter;

    @BeforeEach
    public void setUp() throws Exception {
        servlet = new ContactDetailServlet();
        mockContactService = mock(ContactService.class);
        mockCustomerDAO = mock(CustomerDAO.class);

        servlet.setContactService(mockContactService);
        servlet.setCustomerDAO(mockCustomerDAO);

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

    private ContactResponse createMockContactResponse(int contactId, int customerId) {
        ContactResponse resp = new ContactResponse();
        resp.setContactId(contactId);
        resp.setCustomerId(customerId);
        resp.setFullName("Nguyễn Văn A");
        resp.setTitle("Trưởng phòng Mua hàng");
        resp.setEmail("nva@company.com");
        resp.setPhone("0987654321");
        resp.setBuyingRole("DECISION_MAKER");
        resp.setPrimary(true);
        return resp;
    }

    @Test
    @DisplayName("Chưa đăng nhập - JSON request trả về 401 Unauthorized")
    public void testDoGet_NotLoggedIn_JsonRequest_Returns401() throws Exception {
        when(session.getAttribute("userId")).thenReturn(null);
        when(request.getHeader("Accept")).thenReturn("application/json");

        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(responseWriter.toString().contains("\"status\": 401"));
        assertTrue(responseWriter.toString().contains("Bạn cần đăng nhập"));
        verifyNoInteractions(mockContactService);
    }

    @Test
    @DisplayName("Tham số id không hợp lệ - Trả về 400 Bad Request")
    public void testDoGet_InvalidId_ReturnsBadRequest() throws Exception {
        when(session.getAttribute("userId")).thenReturn(10);
        when(session.getAttribute("roleIds")).thenReturn(Collections.singletonList(1));
        when(request.getHeader("Accept")).thenReturn("application/json");
        when(request.getParameter("id")).thenReturn("abc");

        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        assertTrue(responseWriter.toString().contains("\"status\": 400"));
        verifyNoInteractions(mockContactService);
    }

    @Test
    @DisplayName("Yêu cầu JSON có lịch sử chuyển công ty - Trả về đầy đủ trường gốc và history array")
    public void testDoGet_JsonRequest_WithHistory_ReturnsCompleteJson() throws Exception {
        int contactId = 25;
        int customerId = 100;
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);

        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getParameter("id")).thenReturn(String.valueOf(contactId));
        when(request.getHeader("Accept")).thenReturn("application/json");

        ContactResponse contact = createMockContactResponse(contactId, customerId);
        when(mockContactService.getContactById(contactId, userId, roles)).thenReturn(contact);

        Customer cust = new Customer();
        cust.setCustomerId(customerId);
        cust.setCustomerName("Công ty TNHH Alpha");
        when(mockCustomerDAO.findById(customerId)).thenReturn(cust);

        // Tạo 2 bản ghi lịch sử chuyển công ty
        ContactCompanyHistory h1 = new ContactCompanyHistory();
        h1.setHistoryId(1);
        h1.setContactId(contactId);
        h1.setFromCustomerId(90);
        h1.setFromCustomerName("Công ty Cũ 90");
        h1.setToCustomerId(100);
        h1.setToCustomerName("Công ty TNHH Alpha");
        h1.setTransferredAt(new Timestamp(System.currentTimeMillis() - 86400000L));
        h1.setReason("Khách hàng đổi pháp nhân");
        h1.setTransferredBy(5);
        h1.setTransferredByName("Admin Tuyết");

        ContactCompanyHistory h2 = new ContactCompanyHistory();
        h2.setHistoryId(2);
        h2.setContactId(contactId);
        h2.setFromCustomerId(100);
        h2.setFromCustomerName("Công ty TNHH Alpha");
        h2.setToCustomerId(110);
        h2.setToCustomerName("Tập đoàn Beta");
        h2.setTransferredAt(new Timestamp(System.currentTimeMillis()));
        h2.setReason("Chuyển công tác sang tập đoàn mẹ");
        h2.setTransferredBy(10);
        h2.setTransferredByName("Sales Manager");

        when(mockContactService.getTransferHistory(contactId, userId, roles)).thenReturn(Arrays.asList(h1, h2));

        servlet.doGet(request, response);

        verify(response).setContentType("application/json;charset=UTF-8");
        String jsonOutput = responseWriter.toString();

        // Kiểm tra các trường contact gốc vẫn hiện diện đầy đủ
        assertTrue(jsonOutput.contains("\"contactId\": 25"), "Thiếu contactId");
        assertTrue(jsonOutput.contains("\"customerId\": 100"), "Thiếu customerId");
        assertTrue(jsonOutput.contains("\"fullName\": \"Nguyễn Văn A\""), "Thiếu fullName");
        assertTrue(jsonOutput.contains("\"title\": \"Trưởng phòng Mua hàng\""), "Thiếu title");
        assertTrue(jsonOutput.contains("\"email\": \"nva@company.com\""), "Thiếu email");
        assertTrue(jsonOutput.contains("\"phone\": \"0987654321\""), "Thiếu phone");
        assertTrue(jsonOutput.contains("\"buyingRole\": \"DECISION_MAKER\""), "Thiếu buyingRole");
        assertTrue(jsonOutput.contains("\"isPrimary\": true"), "Thiếu isPrimary");

        // Kiểm tra trường history mảng có 2 phần tử và đầy đủ thông tin
        assertTrue(jsonOutput.contains("\"history\": ["), "Thiếu mảng history");
        assertTrue(jsonOutput.contains("\"historyId\": 1"), "Thiếu historyId 1");
        assertTrue(jsonOutput.contains("\"fromCustomerName\": \"Công ty Cũ 90\""), "Thiếu fromCustomerName 1");
        assertTrue(jsonOutput.contains("\"reason\": \"Khách hàng đổi pháp nhân\""), "Thiếu reason 1");
        assertTrue(jsonOutput.contains("\"transferredByName\": \"Admin Tuyết\""), "Thiếu transferredByName 1");

        assertTrue(jsonOutput.contains("\"historyId\": 2"), "Thiếu historyId 2");
        assertTrue(jsonOutput.contains("\"toCustomerName\": \"Tập đoàn Beta\""), "Thiếu toCustomerName 2");
        assertTrue(jsonOutput.contains("\"reason\": \"Chuyển công tác sang tập đoàn mẹ\""), "Thiếu reason 2");
    }

    @Test
    @DisplayName("Yêu cầu JSON không có lịch sử (danh sách rỗng) - Trả về history là mảng rỗng []")
    public void testDoGet_JsonRequest_EmptyHistory_ReturnsEmptyArray() throws Exception {
        int contactId = 25;
        int customerId = 100;
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);

        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getParameter("id")).thenReturn(String.valueOf(contactId));
        when(request.getHeader("Accept")).thenReturn("application/json");

        ContactResponse contact = createMockContactResponse(contactId, customerId);
        when(mockContactService.getContactById(contactId, userId, roles)).thenReturn(contact);
        when(mockCustomerDAO.findById(customerId)).thenReturn(new Customer());
        when(mockContactService.getTransferHistory(contactId, userId, roles)).thenReturn(Collections.emptyList());

        servlet.doGet(request, response);

        verify(response).setContentType("application/json;charset=UTF-8");
        String jsonOutput = responseWriter.toString();

        assertTrue(jsonOutput.contains("\"contactId\": 25"));
        assertTrue(jsonOutput.contains("\"history\": []"), "Trường history phải là mảng rỗng []");
    }

    @Test
    @DisplayName("Yêu cầu JSON khi lịch sử trả về null - Xử lý an toàn null trả về history []")
    public void testDoGet_JsonRequest_NullHistory_ReturnsEmptyArraySafely() throws Exception {
        int contactId = 25;
        int customerId = 100;
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);

        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getParameter("id")).thenReturn(String.valueOf(contactId));
        when(request.getHeader("Accept")).thenReturn("application/json");

        ContactResponse contact = createMockContactResponse(contactId, customerId);
        when(mockContactService.getContactById(contactId, userId, roles)).thenReturn(contact);
        when(mockCustomerDAO.findById(customerId)).thenReturn(new Customer());
        when(mockContactService.getTransferHistory(contactId, userId, roles)).thenReturn(null);

        servlet.doGet(request, response);

        verify(response).setContentType("application/json;charset=UTF-8");
        String jsonOutput = responseWriter.toString();

        assertTrue(jsonOutput.contains("\"contactId\": 25"));
        assertTrue(jsonOutput.contains("\"history\": []"), "Trường history null phải được xử lý thành []");
    }

    @Test
    @DisplayName("Yêu cầu HTML thông thường - Forward tới JSP với các attributes hợp lệ")
    public void testDoGet_HtmlRequest_ForwardsToJsp() throws Exception {
        int contactId = 25;
        int customerId = 100;
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);

        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getParameter("id")).thenReturn(String.valueOf(contactId));
        when(request.getHeader("Accept")).thenReturn("text/html");

        ContactResponse contact = createMockContactResponse(contactId, customerId);
        Customer customer = new Customer();
        customer.setCustomerId(customerId);
        List<ContactCompanyHistory> historyList = new ArrayList<>();

        when(mockContactService.getContactById(contactId, userId, roles)).thenReturn(contact);
        when(mockContactService.getTransferHistory(contactId, userId, roles)).thenReturn(historyList);
        when(mockCustomerDAO.findById(customerId)).thenReturn(customer);

        servlet.doGet(request, response);

        verify(request).setAttribute("contact", contact);
        verify(request).setAttribute("customer", customer);
        verify(request).setAttribute("history", historyList);
        verify(request).getRequestDispatcher("/WEB-INF/views/contacts/detail.jsp");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("Không tìm thấy liên hệ - Trả về 404 Not Found")
    public void testDoGet_ContactNotFound_Returns404() throws Exception {
        int contactId = 999;
        int userId = 10;
        List<Integer> roles = Collections.singletonList(1);

        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getParameter("id")).thenReturn(String.valueOf(contactId));
        when(request.getHeader("Accept")).thenReturn("application/json");

        when(mockContactService.getContactById(contactId, userId, roles))
                .thenThrow(new ValidationException("Không tìm thấy người liên hệ với ID: " + contactId));

        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_NOT_FOUND);
        assertTrue(responseWriter.toString().contains("\"status\": 404"));
        assertTrue(responseWriter.toString().contains("Không tìm thấy"));
    }

    @Test
    @DisplayName("Không có quyền truy cập Data Scope - Trả về 403 Forbidden")
    public void testDoGet_AuthorizationException_Returns403() throws Exception {
        int contactId = 25;
        int userId = 10;
        List<Integer> roles = Collections.singletonList(3);

        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("roleIds")).thenReturn(roles);
        when(request.getParameter("id")).thenReturn(String.valueOf(contactId));
        when(request.getHeader("Accept")).thenReturn("application/json");

        when(mockContactService.getContactById(contactId, userId, roles))
                .thenThrow(new AuthorizationException("Bạn không có quyền xem thông tin người liên hệ này."));

        servlet.doGet(request, response);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        assertTrue(responseWriter.toString().contains("\"status\": 403"));
        assertTrue(responseWriter.toString().contains("không có quyền xem"));
    }
}
