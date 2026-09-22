package com.crm.controller;
import com.crm.config.SessionListener;
import com.crm.dao.HandoverDAO;
import com.crm.dao.UserDAO;
import com.crm.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users/lock")
public class LockUserServlet extends HttpServlet {
    private HandoverDAO handoverDAO = new HandoverDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int userId = Integer.parseInt(req.getParameter("id"));
        int ownedCount = handoverDAO.countOwnedRecords(userId);
        User targetUser = userDAO.getUserById(userId);

        // Lấy danh sách các nhân viên đang hoạt động để làm danh sách bàn giao
        List activeUsers = userDAO.getUsers("", null, 1, 1);

        req.setAttribute("targetUser", targetUser);
        req.setAttribute("ownedCount", ownedCount);
        req.setAttribute("activeUsers", activeUsers);
        req.getRequestDispatcher("/views/user-lock.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int lockedUserId = Integer.parseInt(req.getParameter("lockedUserId"));
        String receiverIdStr = req.getParameter("receiverId");
        
        int ownedCount = handoverDAO.countOwnedRecords(lockedUserId);

        // Tiêu chí S1-10: Bắt buộc chọn người nhận nếu có dữ liệu sở hữu
        if (ownedCount > 0 && (receiverIdStr == null || receiverIdStr.trim().isEmpty())) {
            req.setAttribute("error", "Tài khoản đang quản lý " + ownedCount + " khách hàng/cơ hội. Bắt buộc phải chọn người tiếp nhận bàn giao!");
            doGet(req, resp);
            return;
        }

        Integer receiverId = (receiverIdStr != null && !receiverIdStr.isEmpty()) ? Integer.parseInt(receiverIdStr) : null;
        
        // Giả sử admin ID đang đăng nhập được lưu trong session (nếu chưa có mặc định là 1)
        Integer adminId = (Integer) req.getSession().getAttribute("userId");
        if (adminId == null) adminId = 1;

        boolean success = handoverDAO.lockAndHandover(lockedUserId, receiverId, adminId);
        if (success) {
            // Tiêu chí S1-10: Thu hồi phiên đăng nhập ngay lập tức
            SessionListener.invalidateUserSession(lockedUserId);
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=lock_success");
        } else {
            req.setAttribute("error", "Lỗi trong quá trình bàn giao và khóa tài khoản!");
            doGet(req, resp);
        }
    }
}