package com.crm;

import com.crm.config.DBConnection;
import com.crm.dao.HandoverDAO;
import com.crm.dao.UserDAO;
import com.crm.model.User;
import java.sql.Connection;
import java.util.List;

public class MainTest {
    public static void main(String[] args) {
        System.out.println("========== 1. KIEM TRA KET NOI DATABASE ==========");
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                System.out.println("-> Ket noi MySQL thanh cong!\n");
            } else {
                System.err.println("-> Ket noi that bai. Kiem tra lai XAMPP MySQL.");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }

        UserDAO userDAO = new UserDAO();
        HandoverDAO handoverDAO = new HandoverDAO();

        System.out.println("========== 2. TEST S1-08: CRUD & PHAN TRANG ==========");
        boolean exists = userDAO.isEmailExists("admin@company.com", 0);
        System.out.println("Kiem tra email 'admin@company.com' ton tai: " + exists);

        String testEmail = "test_" + System.currentTimeMillis() + "@company.com";
        boolean created = userDAO.createUser(testEmail, "MatKhau@123", "Nhan Vien Moi", "0909999888", 1);
        System.out.println("Tao user moi (" + testEmail + "): " + (created ? "THANH CONG" : "THAT BAI"));

        List<User> list = userDAO.getUsers("", null, null, 1);
        System.out.println("So luong user lay ra o trang 1: " + list.size());
        for (User u : list) {
            System.out.println(" - ID: " + u.getUserId() + " | Email: " + u.getEmail() + " | Trang thai: " + (u.isActive() ? "Hoat dong" : "Bi khoa"));
        }

        System.out.println("\n========== 3. TEST S1-10: KHOA TAI KHOAN & BAN GIAO ==========");
        int lockedUserId = 2;
        int receiverId = 3;
        int adminId = 1;

        int ownedCount = handoverDAO.countOwnedRecords(lockedUserId);
        System.out.println("So luong tai san cua User " + lockedUserId + ": " + ownedCount);

        if (ownedCount > 0) {
            System.out.println("-> Thuc hien ban giao sang User " + receiverId + " va khoa User " + lockedUserId + "...");
            boolean handoverOk = handoverDAO.lockAndHandover(lockedUserId, receiverId, adminId);
            System.out.println("Ket qua ban giao: " + (handoverOk ? "THANH CONG" : "THAT BAI"));

            int remaining = handoverDAO.countOwnedRecords(lockedUserId);
            System.out.println("So tai san con lai cua User " + lockedUserId + " sau ban giao: " + remaining);
        }
    }
}