package com.crm.service;

import com.crm.dao.ContactCompanyHistoryDAO;
import com.crm.dao.ContactDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactRequest;
import com.crm.dto.ContactResponse;
import com.crm.dto.ContactTransferRequest;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Contact;
import com.crm.model.ContactCompanyHistory;
import com.crm.model.Customer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Kiểm thử toàn diện nghiệp vụ Contact Management (Task S30-03 / S3-02).
 * Phủ đầy đủ 6 nhóm kiểm thử A - F theo yêu cầu báo cáo.
 */
public class ContactServiceTest {

    private ContactService contactService;
    private ContactDAO mockContactDAO;
    private ContactCompanyHistoryDAO mockHistoryDAO;
    private CustomerDAO mockCustomerDAO;
    private PermissionService mockPermissionService;

    private static final int USER_ID = 10;
    private static final List<Integer> ROLE_IDS = Collections.singletonList(1);

    @BeforeEach
    public void setUp() {
        contactService = new ContactService();
        mockContactDAO = mock(ContactDAO.class);
        mockHistoryDAO = mock(ContactCompanyHistoryDAO.class);
        mockCustomerDAO = mock(CustomerDAO.class);
        mockPermissionService = mock(PermissionService.class);

        contactService.setContactDAO(mockContactDAO);
        contactService.setContactCompanyHistoryDAO(mockHistoryDAO);
        contactService.setCustomerDAO(mockCustomerDAO);
        contactService.setPermissionService(mockPermissionService);
    }

    private Customer createMockCustomer(int customerId, int ownerId) {
        Customer c = new Customer();
        c.setCustomerId(customerId);
        c.setCustomerName("Công ty Khách Hàng " + customerId);
        c.setOwnerId(ownerId);
        return c;
    }

    private Contact createMockContact(int contactId, int customerId, String fullName, String role, boolean isPrimary) {
        Contact c = new Contact();
        c.setContactId(contactId);
        c.setCustomerId(customerId);
        c.setFullName(fullName);
        c.setTitle("Giám đốc");
        c.setEmail("contact" + contactId + "@test.com");
        c.setPhone("0987654321");
        c.setBuyingRole(role);
        c.setPrimary(isPrimary);
        c.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return c;
    }

    // =========================================================================
    // NHÓM A: QUẢN LÝ NGƯỜI LIÊN HỆ
    // =========================================================================
    @Nested
    @DisplayName("Nhóm A: Quản lý người liên hệ cơ bản")
    class ContactCrudTests {

        @Test
        @DisplayName("Tạo người liên hệ hợp lệ - Thành công")
        public void testCreateContact_Success() throws Exception {
            Customer cust = createMockCustomer(100, 5);
            when(mockCustomerDAO.findById(100)).thenReturn(cust);
            when(mockContactDAO.insert(any(Contact.class))).thenReturn(501);

            ContactRequest req = new ContactRequest();
            req.setCustomerId(100);
            req.setFullName("Nguyễn Văn A");
            req.setTitle("Trưởng phòng IT");
            req.setEmail("nva@company.com");
            req.setPhone("0912345678");
            req.setBuyingRole("DECIDER");
            req.setIsPrimary(false);

            Contact result = contactService.createContact(req, USER_ID, ROLE_IDS);
            assertNotNull(result);
            assertEquals(501, result.getContactId());
            assertEquals("Nguyễn Văn A", result.getFullName());
            assertEquals("DECIDER", result.getBuyingRole());
            assertFalse(result.isPrimary());

            verify(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 5);
        }

        @Test
        @DisplayName("Từ chối tạo người liên hệ khi họ tên để trống")
        public void testCreateContact_EmptyFullName_ThrowsValidationException() {
            ContactRequest req = new ContactRequest();
            req.setCustomerId(100);
            req.setFullName("   ");

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.createContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Họ và tên người liên hệ không được để trống"));
        }

        @Test
        @DisplayName("Từ chối tạo người liên hệ với email không đúng định dạng")
        public void testCreateContact_InvalidEmail_ThrowsValidationException() {
            ContactRequest req = new ContactRequest();
            req.setCustomerId(100);
            req.setFullName("Trần Văn B");
            req.setEmail("email_khong_hop_le_khong_co_at");

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.createContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Định dạng email không hợp lệ"));
        }

        @Test
        @DisplayName("Từ chối tạo người liên hệ với số điện thoại sai định dạng")
        public void testCreateContact_InvalidPhone_ThrowsValidationException() {
            ContactRequest req = new ContactRequest();
            req.setCustomerId(100);
            req.setFullName("Trần Văn B");
            req.setEmail("b@company.com");
            req.setPhone("123"); // Quá ngắn

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.createContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Số điện thoại không hợp lệ"));
        }

        @Test
        @DisplayName("Cập nhật thông tin người liên hệ thành công")
        public void testUpdateContact_Success() throws Exception {
            Customer cust = createMockCustomer(100, 5);
            Contact existing = createMockContact(501, 100, "Nguyễn Văn A", "DECIDER", false);

            when(mockContactDAO.findById(501)).thenReturn(existing);
            when(mockCustomerDAO.findById(100)).thenReturn(cust);
            when(mockContactDAO.update(any(Contact.class))).thenReturn(true);

            ContactRequest updateReq = new ContactRequest();
            updateReq.setContactId(501);
            updateReq.setCustomerId(100);
            updateReq.setFullName("Nguyễn Văn A Cập Nhật");
            updateReq.setTitle("Phó Tổng Giám Đốc");
            updateReq.setEmail("nva_new@company.com");
            updateReq.setPhone("0988776655");
            updateReq.setBuyingRole("INFLUENCER");
            updateReq.setIsPrimary(false);

            Contact updated = contactService.updateContact(updateReq, USER_ID, ROLE_IDS);
            assertNotNull(updated);
            assertEquals("Nguyễn Văn A Cập Nhật", updated.getFullName());
            assertEquals("INFLUENCER", updated.getBuyingRole());
            verify(mockContactDAO).update(any(Contact.class));
        }

        @Test
        @DisplayName("Đọc thông tin người liên hệ theo ID")
        public void testGetContactById_Success() throws Exception {
            Customer cust = createMockCustomer(100, 5);
            Contact contact = createMockContact(501, 100, "Nguyễn Văn A", "DECIDER", true);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(100)).thenReturn(cust);

            ContactResponse response = contactService.getContactById(501, USER_ID, ROLE_IDS);
            assertNotNull(response);
            assertEquals(501, response.getContactId());
            assertEquals("Nguyễn Văn A", response.getFullName());
            assertTrue(response.isPrimary());
            verify(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 5);
        }
    }

    // =========================================================================
    // NHÓM B: VAI TRÒ QUYẾT ĐỊNH MUA (BUYING ROLES)
    // =========================================================================
    @Nested
    @DisplayName("Nhóm B: Vai trò trong quyết định mua")
    class BuyingRoleTests {

        @Test
        @DisplayName("Chấp nhận cả 4 vai trò mua: DECIDER, INFLUENCER, END_USER, BLOCKER")
        public void testAcceptValidBuyingRoles() throws Exception {
            Customer cust = createMockCustomer(100, 5);
            when(mockCustomerDAO.findById(100)).thenReturn(cust);
            when(mockContactDAO.insert(any(Contact.class))).thenReturn(1);

            for (String role : ContactService.BUYING_ROLES) {
                ContactRequest req = new ContactRequest();
                req.setCustomerId(100);
                req.setFullName("User " + role);
                req.setBuyingRole(role);

                Contact c = contactService.createContact(req, USER_ID, ROLE_IDS);
                assertEquals(role, c.getBuyingRole(), "Phải chấp nhận vai trò: " + role);
            }
        }

        @Test
        @DisplayName("Gán mặc định END_USER nếu vai trò không được truyền")
        public void testDefaultBuyingRoleIsEndUser() throws Exception {
            Customer cust = createMockCustomer(100, 5);
            when(mockCustomerDAO.findById(100)).thenReturn(cust);
            when(mockContactDAO.insert(any(Contact.class))).thenReturn(1);

            ContactRequest req = new ContactRequest();
            req.setCustomerId(100);
            req.setFullName("User No Role");
            req.setBuyingRole(null);

            Contact c = contactService.createContact(req, USER_ID, ROLE_IDS);
            assertEquals("END_USER", c.getBuyingRole());
        }

        @Test
        @DisplayName("Từ chối vai trò quyết định mua không hợp lệ")
        public void testRejectInvalidBuyingRole() {
            ContactRequest req = new ContactRequest();
            req.setCustomerId(100);
            req.setFullName("User Invalid Role");
            req.setBuyingRole("UNKNOWN_ROLE");

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.createContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Vai trò quyết định mua không hợp lệ"));
        }
    }

    // =========================================================================
    // NHÓM C: ĐẦU MỐI CHÍNH (PRIMARY CONTACT)
    // =========================================================================
    @Nested
    @DisplayName("Nhóm C: Quản lý đầu mối chính và Transaction")
    class PrimaryContactTests {

        @Test
        @DisplayName("Đặt đầu mối chính - Chuyển quyền từ người cũ sang người mới")
        public void testSetPrimaryContact_Success() throws Exception {
            Customer cust = createMockCustomer(100, 5);
            Contact contactB = createMockContact(502, 100, "Người Liên Hệ B", "DECIDER", false);

            when(mockContactDAO.findById(502)).thenReturn(contactB);
            when(mockCustomerDAO.findById(100)).thenReturn(cust);
            when(mockContactDAO.resetPrimaryForCustomer(eq(100), any(Connection.class))).thenReturn(true);
            when(mockContactDAO.setPrimary(eq(502), eq(100), any(Connection.class))).thenReturn(true);

            boolean result = contactService.setPrimaryContact(502, 100, USER_ID, ROLE_IDS);
            assertTrue(result);

            verify(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 5);
        }

        @Test
        @DisplayName("Từ chối đặt đầu mối chính nếu người liên hệ không thuộc khách hàng")
        public void testSetPrimaryContact_MismatchedCustomer_ThrowsValidationException() {
            Contact contact = createMockContact(501, 100, "Người A", "DECIDER", false);
            when(mockContactDAO.findById(501)).thenReturn(contact);

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.setPrimaryContact(501, 200, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Người liên hệ không thuộc khách hàng đã chỉ định"));
        }

        @Test
        @DisplayName("Từ chối đặt đầu mối chính cho người liên hệ không tồn tại")
        public void testSetPrimaryContact_NotFound_ThrowsValidationException() {
            when(mockContactDAO.findById(999)).thenReturn(null);

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.setPrimaryContact(999, 100, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Người liên hệ không tồn tại"));
        }
    }

    // =========================================================================
    // NHÓM D: CHUYỂN CÔNG TY VÀ GHI LỊCH SỬ (TRANSFER CONTACT)
    // =========================================================================
    @Nested
    @DisplayName("Nhóm D: Chuyển công ty cho người liên hệ")
    class TransferContactTests {

        @Test
        @DisplayName("Chuyển từ khách hàng A sang B thành công và ghi lịch sử")
        public void testTransferContact_Success() throws Exception {
            Customer custA = createMockCustomer(101, 5);
            Customer custB = createMockCustomer(102, 6);
            Contact contact = createMockContact(501, 101, "Người A", "DECIDER", true);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(custA);
            when(mockCustomerDAO.findById(102)).thenReturn(custB);

            when(mockContactDAO.updateCustomerId(eq(501), eq(102), any(Connection.class))).thenReturn(true);
            when(mockHistoryDAO.insert(any(ContactCompanyHistory.class), any(Connection.class))).thenReturn(true);

            ContactTransferRequest req = new ContactTransferRequest(501, 102, "Chuyển công tác sang công ty con");

            boolean success = contactService.transferContact(req, USER_ID, ROLE_IDS);
            assertTrue(success);

            // Xác minh kiểm tra Data Scope trên cả khách hàng nguồn và đích
            verify(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 5);
            verify(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 6);
        }

        @Test
        @DisplayName("Từ chối chuyển sang chính khách hàng hiện tại")
        public void testTransferContact_SameCustomer_ThrowsValidationException() {
            Contact contact = createMockContact(501, 101, "Người A", "DECIDER", false);
            when(mockContactDAO.findById(501)).thenReturn(contact);

            ContactTransferRequest req = new ContactTransferRequest(501, 101, "Lý do chuyển");

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.transferContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Khách hàng đích phải khác khách hàng hiện tại"));
        }

        @Test
        @DisplayName("Từ chối chuyển khi khách hàng đích không tồn tại")
        public void testTransferContact_DestinationNotFound_ThrowsValidationException() {
            Customer custA = createMockCustomer(101, 5);
            Contact contact = createMockContact(501, 101, "Người A", "DECIDER", false);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(custA);
            when(mockCustomerDAO.findById(999)).thenReturn(null);

            ContactTransferRequest req = new ContactTransferRequest(501, 999, "Lý do chuyển");

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.transferContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Khách hàng đích không tồn tại"));
        }

        @Test
        @DisplayName("Từ chối chuyển khi lý do chuyển để trống")
        public void testTransferContact_EmptyReason_ThrowsValidationException() {
            ContactTransferRequest req = new ContactTransferRequest(501, 102, "   ");

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.transferContact(req, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Lý do chuyển đổi công ty không được để trống"));
        }

        @Test
        @DisplayName("Từ chối chuyển khi người dùng không có quyền trên khách hàng nguồn hoặc đích")
        public void testTransferContact_Unauthorized_ThrowsAuthorizationException() throws Exception {
            Customer custA = createMockCustomer(101, 5);
            Customer custB = createMockCustomer(102, 6);
            Contact contact = createMockContact(501, 101, "Người A", "DECIDER", false);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(custA);
            when(mockCustomerDAO.findById(102)).thenReturn(custB);

            doThrow(new AuthorizationException("Không có quyền truy cập dữ liệu khách hàng"))
                    .when(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 6);

            ContactTransferRequest req = new ContactTransferRequest(501, 102, "Chuyển công tác");

            assertThrows(AuthorizationException.class, () ->
                    contactService.transferContact(req, USER_ID, ROLE_IDS));
        }
    }

    // =========================================================================
    // NHÓM E: HIỂN THỊ LỊCH SỬ CHUYỂN CÔNG TY
    // =========================================================================
    @Nested
    @DisplayName("Nhóm E: Hiển thị lịch sử chuyển công ty")
    class HistoryDisplayTests {

        @Test
        @DisplayName("Người liên hệ chưa từng chuyển - Trả về danh sách rỗng")
        public void testGetTransferHistory_EmptyHistory() throws Exception {
            Customer cust = createMockCustomer(101, 5);
            Contact contact = createMockContact(501, 101, "Người A", "DECIDER", false);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(cust);
            when(mockHistoryDAO.findByContactId(501)).thenReturn(Collections.emptyList());

            List<ContactCompanyHistory> history = contactService.getTransferHistory(501, USER_ID, ROLE_IDS);
            assertNotNull(history);
            assertTrue(history.isEmpty());
        }

        @Test
        @DisplayName("Người liên hệ đã chuyển nhiều lần - Trả về đầy đủ theo thứ tự thời gian")
        public void testGetTransferHistory_MultipleRecords() throws Exception {
            Customer cust = createMockCustomer(103, 5);
            Contact contact = createMockContact(501, 103, "Người A", "DECIDER", false);

            ContactCompanyHistory h1 = new ContactCompanyHistory(501, 101, 102, "Chuyển đợt 1", 10);
            h1.setFromCustomerName("Công ty A");
            h1.setToCustomerName("Công ty B");

            ContactCompanyHistory h2 = new ContactCompanyHistory(501, 102, 103, "Chuyển đợt 2", 10);
            h2.setFromCustomerName("Công ty B");
            h2.setToCustomerName("Công ty C");

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(103)).thenReturn(cust);
            when(mockHistoryDAO.findByContactId(501)).thenReturn(Arrays.asList(h2, h1));

            List<ContactCompanyHistory> history = contactService.getTransferHistory(501, USER_ID, ROLE_IDS);
            assertNotNull(history);
            assertEquals(2, history.size());
            assertEquals("Công ty C", history.get(0).getToCustomerName());
            assertEquals("Công ty B", history.get(1).getToCustomerName());
        }

        @Test
        @DisplayName("Không trả về lịch sử khi người dùng không có quyền truy cập người liên hệ")
        public void testGetTransferHistory_Unauthorized_ThrowsAuthorizationException() throws Exception {
            Customer cust = createMockCustomer(101, 5);
            Contact contact = createMockContact(501, 101, "Người A", "DECIDER", false);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(cust);
            doThrow(new AuthorizationException("Từ chối truy cập"))
                    .when(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 5);

            assertThrows(AuthorizationException.class, () ->
                    contactService.getTransferHistory(501, USER_ID, ROLE_IDS));
        }
    }

    // =========================================================================
    // NHÓM F: XÓA AN TOÀN VÀ BẢO TOÀN DỮ LIỆU (SAFE DELETE)
    // =========================================================================
    @Nested
    @DisplayName("Nhóm F: Xóa an toàn và bảo toàn dữ liệu lịch sử")
    class SafeDeleteTests {

        @Test
        @DisplayName("Xóa thành công khi người liên hệ chưa từng có lịch sử chuyển công ty")
        public void testDeleteContact_NoHistory_Success() throws Exception {
            Customer cust = createMockCustomer(101, 5);
            Contact contact = createMockContact(501, 101, "Người A", "END_USER", false);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(cust);
            when(mockHistoryDAO.findByContactId(501)).thenReturn(Collections.emptyList());
            when(mockContactDAO.delete(501)).thenReturn(true);

            boolean result = contactService.deleteContact(501, USER_ID, ROLE_IDS);
            assertTrue(result);
            verify(mockContactDAO).delete(501);
        }

        @Test
        @DisplayName("TỪ CHỐI XÓA khi người liên hệ ĐÃ CÓ LỊCH SỬ chuyển công ty - Bảo toàn kiểm toán")
        public void testDeleteContact_WithHistory_ThrowsValidationException() {
            Customer cust = createMockCustomer(102, 5);
            Contact contact = createMockContact(501, 102, "Người A", "DECIDER", false);

            ContactCompanyHistory h = new ContactCompanyHistory(501, 101, 102, "Chuyển đợt 1", 10);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(102)).thenReturn(cust);
            when(mockHistoryDAO.findByContactId(501)).thenReturn(Collections.singletonList(h));

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.deleteContact(501, USER_ID, ROLE_IDS));

            assertTrue(ex.getMessage().contains("Không thể xóa người liên hệ đã có lịch sử chuyển công ty"));
            verify(mockContactDAO, never()).delete(anyInt());
        }

        @Test
        @DisplayName("Từ chối xóa khi người liên hệ không tồn tại")
        public void testDeleteContact_NotFound_ThrowsValidationException() {
            when(mockContactDAO.findById(999)).thenReturn(null);

            ValidationException ex = assertThrows(ValidationException.class, () ->
                    contactService.deleteContact(999, USER_ID, ROLE_IDS));
            assertTrue(ex.getMessage().contains("Người liên hệ không tồn tại"));
        }

        @Test
        @DisplayName("Từ chối xóa khi người dùng không có quyền trên khách hàng sở hữu")
        public void testDeleteContact_Unauthorized_ThrowsAuthorizationException() throws Exception {
            Customer cust = createMockCustomer(101, 5);
            Contact contact = createMockContact(501, 101, "Người A", "END_USER", false);

            when(mockContactDAO.findById(501)).thenReturn(contact);
            when(mockCustomerDAO.findById(101)).thenReturn(cust);
            doThrow(new AuthorizationException("Từ chối quyền xóa"))
                    .when(mockPermissionService).validateDataAccessForRoles(USER_ID, ROLE_IDS, "ACCOUNT", 5);

            assertThrows(AuthorizationException.class, () ->
                    contactService.deleteContact(501, USER_ID, ROLE_IDS));
            verify(mockContactDAO, never()).delete(anyInt());
        }
    }
}
