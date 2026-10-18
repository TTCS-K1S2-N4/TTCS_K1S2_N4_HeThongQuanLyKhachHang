package com.crm.service;

import com.crm.dto.LeadFilterRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Lead;
import com.crm.util.DBConnection;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test hồi quy kiểm tra luồng: Gửi Public Web Form (formId=11) -> Bản ghi được lưu thật vào DB
 * -> Tìm kiếm trên CRM (/leads) bởi các vai trò (Admin, Quản lý, Nhân viên) đều tìm thấy Lead.
 */
public class PublicLeadFormSearchInCrmTest {

    private final LeadWebFormService webFormService = new LeadWebFormService();
    private final LeadFilterService filterService = new LeadFilterService();

    @Test
    @DisplayName("TC-01: Xác minh Lead #225 'Trần Minh Đức' tồn tại trong DB và tìm thấy được trên CRM")
    void testSearchExistingTranMinhDucLead() throws Exception {
        int targetLeadId = 225;
        String keyword = "Trần Minh Đức";

        // 1. Kiểm tra trực tiếp cơ sở dữ liệu
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT lead_id, full_name, email, phone, web_form_id, owner_id FROM leads WHERE lead_id = ?")) {
            ps.setInt(1, targetLeadId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Lead #225 phải tồn tại trong cơ sở dữ liệu");
                assertEquals(keyword, rs.getString("full_name"));
                assertEquals(11, rs.getInt("web_form_id"));
                assertNull(rs.getObject("owner_id"), "Lead từ Web Form ban đầu chưa phân công người phụ trách (owner_id IS NULL)");
            }
        }

        // 2. Tìm kiếm trên CRM với tài khoản Admin (user_id = 1, role_id = 1)
        LeadFilterRequest req = new LeadFilterRequest();
        req.setKeyword(keyword);
        List<LeadResponse> adminResults = filterService.filterLeads(req, 1, Collections.singletonList(1));
        assertFalse(adminResults.isEmpty(), "Admin phải tìm thấy Lead 'Trần Minh Đức'");
        boolean foundInAdmin = adminResults.stream().anyMatch(l -> l.getLeadId() == targetLeadId);
        assertTrue(foundInAdmin, "Lead #225 phải có mặt trong kết quả tìm kiếm của Admin");

        // 3. Tìm kiếm trên CRM với tài khoản Giám đốc kinh doanh (user_id = 9, role_id = 4)
        List<LeadResponse> directorResults = filterService.filterLeads(req, 9, Collections.singletonList(4));
        assertFalse(directorResults.isEmpty(), "Giám đốc kinh doanh (scope ALL) phải tìm thấy Lead 'Trần Minh Đức'");
        boolean foundInDirector = directorResults.stream().anyMatch(l -> l.getLeadId() == targetLeadId);
        assertTrue(foundInDirector, "Lead #225 phải có mặt trong kết quả tìm kiếm của Giám đốc kinh doanh");

        // 4. Tìm kiếm trên CRM với tài khoản Trưởng nhóm kinh doanh (user_id = 3, role_id = 3)
        List<LeadResponse> teamLeadResults = filterService.filterLeads(req, 3, Collections.singletonList(3));
        assertFalse(teamLeadResults.isEmpty(), "Trưởng nhóm (scope TEAM) phải tìm thấy Lead chưa phân công để phân bổ");
        boolean foundInTeamLead = teamLeadResults.stream().anyMatch(l -> l.getLeadId() == targetLeadId);
        assertTrue(foundInTeamLead, "Lead #225 phải có mặt trong kết quả tìm kiếm của Trưởng nhóm");

        // 5. Kiểm tra phân quyền chặt chẽ: Nhân viên Sales (user_id = 4, role_id = 2, scope MY)
        // Không được nới lỏng xem Lead chưa phân công của người khác/toàn hệ thống
        List<LeadResponse> salesResults = filterService.filterLeads(req, 4, Collections.singletonList(2));
        boolean foundInSales = salesResults.stream().anyMatch(l -> l.getLeadId() == targetLeadId);
        assertFalse(foundInSales, "Nhân viên Sales (chỉ có quyền MY) KHÔNG ĐƯỢC tự ý xem Lead chưa phân công khi chưa được bàn giao");
    }

    @Test
    @DisplayName("TC-02: Gửi public web form mới -> Lưu DB thật -> Tìm kiếm trên CRM thành công ngay lập tức")
    void testSubmitPublicFormAndSearchInCrm() throws Exception {
        int formId = 11;
        String testEmail = "duc.regression." + System.currentTimeMillis() + "@crm-test.vn";
        String fullName = "Trần Minh Đức Test Auto";
        String phone = "0933888999";
        String company = "Công Ty Công Nghệ Phần Mềm Test";
        String notes = "Đăng ký tư vấn giải pháp tự động";

        String clientIp = "10.99." + (int)(Math.random() * 200 + 1) + "." + (int)(Math.random() * 200 + 1);

        // Bước 1: Gửi form và lưu Lead
        Lead created = webFormService.submitAndCreateLead(
                formId, fullName, testEmail, phone, company, notes, "http://crm.local/form", clientIp, null, null);

        assertNotNull(created, "Lead tạo mới từ form không được null");
        assertTrue(created.getLeadId() > 0, "Lead ID tạo mới phải lớn hơn 0");

        // Bước 2: Kiểm tra trực tiếp trong DB
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT lead_id, full_name, email, web_form_id, owner_id FROM leads WHERE email = ? AND web_form_id = ?")) {
            ps.setString(1, testEmail);
            ps.setInt(2, formId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Lead vừa gửi phải tồn tại trong bảng leads");
                assertEquals(created.getLeadId(), rs.getInt("lead_id"), "Lead ID khớp với bản ghi DB");
                assertNull(rs.getObject("owner_id"), "owner_id phải là NULL khi mới tạo từ web form");
            }
        }

        // Bước 3: Tìm kiếm trên CRM bằng họ tên
        LeadFilterRequest searchReq = new LeadFilterRequest();
        searchReq.setKeyword(fullName);

        // Với Admin
        List<LeadResponse> searchByAdmin = filterService.filterLeads(searchReq, 1, Collections.singletonList(1));
        assertTrue(searchByAdmin.stream().anyMatch(l -> l.getLeadId() == created.getLeadId()),
                "Admin phải tìm thấy Lead vừa gửi theo từ khóa họ tên");

        // Với Giám đốc kinh doanh (Director)
        List<LeadResponse> searchByDirector = filterService.filterLeads(searchReq, 9, Collections.singletonList(4));
        assertTrue(searchByDirector.stream().anyMatch(l -> l.getLeadId() == created.getLeadId()),
                "Giám đốc phải tìm thấy Lead unassigned vừa gửi theo từ khóa họ tên");

        // Với Sales Rep (scope MY): Không được xem khi chưa phân công
        List<LeadResponse> searchBySales = filterService.filterLeads(searchReq, 4, Collections.singletonList(2));
        assertFalse(searchBySales.stream().anyMatch(l -> l.getLeadId() == created.getLeadId()),
                "Sales Rep (scope MY) không xem được Lead unassigned khi chưa phân công");

        // Bước 4: Tìm kiếm trên CRM bằng email
        searchReq.setKeyword(testEmail);
        List<LeadResponse> searchByEmail = filterService.filterLeads(searchReq, 1, Collections.singletonList(1));
        assertTrue(searchByEmail.stream().anyMatch(l -> l.getLeadId() == created.getLeadId()),
                "Tìm kiếm theo email trên CRM phải trả về Lead vừa gửi");
    }
}
