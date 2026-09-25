package com.crm;

import com.crm.dto.AccountCreateRequest;
import com.crm.model.Account;
import com.crm.service.AccountService;
import com.crm.util.DBConnection;
import java.sql.Connection;
import java.util.List;

public class MainTest {
    public static void main(String[] args) {
        System.out.println("================================================================================");
        System.out.println("                  KIEM TRA HE THONG BACKEND BE4 (SPRINT 1)                      ");
        System.out.println("================================================================================\n");

        // 1. KIEM TRA KET NOI DATABASE (com.crm.util.DBConnection)
        System.out.println(">>> [BƯỚC 1] KIỂM TRA KẾT NỐI DATABASE MYSQL");
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("  -> [OK] Kết nối MySQL crm_db thành công!\n");
            } else {
                System.err.println("  -> [FAIL] Kết nối thất bại. Vui lòng kiểm tra lại db.properties hoặc MySQL Server!");
                return;
            }
        } catch (Exception e) {
            System.err.println("  -> [ERROR] Lỗi ngoại lệ khi kết nối CSDL: " + e.getMessage());
            e.printStackTrace();
            return;
        }

        AccountService accountService = new AccountService();

        // 2. KIEM TRA S1-08: TẠO TÀI KHOẢN & PHÂN TRANG (AccountCreateRequest & AccountService)
        System.out.println(">>> [BƯỚC 2] KIỂM THỬ S1-08: QUẢN LÝ TÀI KHOẢN (CREATE & PAGINATION)");
        String testEmail = "test_be4_" + System.currentTimeMillis() + "@company.com";
        AccountCreateRequest createReq = new AccountCreateRequest(
                testEmail,
                "Password@123",
                "Lê Đức Hải Nam - BE4",
                "0987654321",
                1 // teamId
        );

        boolean isCreated = accountService.createAccount(createReq);
        System.out.println("  * Thử tạo tài khoản mới (" + testEmail + "): " + (isCreated ? "THÀNH CÔNG" : "THẤT BẠI"));

        // Thử tạo trùng email vừa tạo
        boolean isDuplicateCreated = accountService.createAccount(createReq);
        System.out.println("  * Thử tạo lại với email trùng lặp (kỳ vọng chặn lại): " + (!isDuplicateCreated ? "CHẶN THÀNH CÔNG (HỢP LỆ)" : "LỖI (VẪN TẠO ĐƯỢC)"));

        // Kiểm tra phân trang và đếm tổng số
        int totalAccounts = accountService.countTotalAccounts("", null, null);
        int totalPages = (int) Math.ceil((double) totalAccounts / 20);
        List<Account> page1List = accountService.getAccountList("", null, null, 1);

        System.out.println("  * Tổng số tài khoản trong hệ thống: " + totalAccounts);
        System.out.println("  * Tổng số trang (20 tài khoản/trang): " + totalPages);
        System.out.println("  * Số tài khoản tải về ở trang 1: " + page1List.size());
        System.out.println("  * Danh sách tài khoản mẫu ở trang 1:");
        for (Account acc : page1List) {
            System.out.println("    - [ID: " + acc.getAccountId() + "] " 
                    + acc.getFullName() + " | Email: " + acc.getEmail() 
                    + " | Trạng thái: " + acc.getStatus()
                    + " | Team: " + (acc.getTeamName() != null ? acc.getTeamName() : "Chưa phân nhóm"));
        }
        System.out.println();

        // 3. KIEM TRA S1-10: KHÓA TÀI KHOẢN VÀ BÀN GIAO TÀI SẢN
        System.out.println(">>> [BƯỚC 3] KIỂM THỬ S1-10: KHÓA TÀI KHOẢN & BÀN GIAO DỮ LIỆU");
        int targetAccountId = 2;   // ID tài khoản cần khóa thử nghiệm
        int receiverAccountId = 1; // ID tài khoản nhận bàn giao (Admin)
        int adminPerformerId = 1;  // ID admin thực hiện hành động

        Account targetAccount = accountService.getAccountDetail(targetAccountId);
        if (targetAccount != null) {
            int ownedAssets = accountService.countOwnedAssets(targetAccountId);
            System.out.println("  * Kiểm tra tài khoản ID " + targetAccountId + " (" + targetAccount.getFullName() + "):");
            System.out.println("    - Số lượng tài sản đang sở hữu (Khách hàng + Cơ hội): " + ownedAssets);

            if (ownedAssets > 0) {
                System.out.println("    - Phát hiện tài sản tồn đọng -> Bắt buộc bàn giao sang Account ID: " + receiverAccountId);
            } else {
                System.out.println("    - Tài khoản không sở hữu tài sản -> Có thể khóa trực tiếp.");
            }

            boolean isLocked = accountService.lockAndTransferData(targetAccountId, receiverAccountId, adminPerformerId);
            System.out.println("  * Kết quả khóa và chuyển giao tài sản: " + (isLocked ? "THÀNH CÔNG" : "THẤT BẠI"));

            Account afterLock = accountService.getAccountDetail(targetAccountId);
            System.out.println("  * Trạng thái tài khoản sau xử lý: " + afterLock.getStatus());
            System.out.println("  * Số tài sản còn lại của tài khoản sau bàn giao: " + accountService.countOwnedAssets(targetAccountId));
        } else {
            System.out.println("  * Không tìm thấy Account ID " + targetAccountId + " để test bàn giao, hoàn tất các kiểm thử khác.");
        }

        System.out.println("\n================================================================================");
        System.out.println("                  HOÀN TẤT KIỂM THỬ TOÀN DIỆN BACKEND BE4                       ");
        System.out.println("================================================================================");
    }
}
