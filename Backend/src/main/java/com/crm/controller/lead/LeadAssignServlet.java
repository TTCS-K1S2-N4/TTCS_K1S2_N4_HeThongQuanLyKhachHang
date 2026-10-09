package com.crm.controller.lead;

import com.crm.service.LeadAssignmentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/leads/assign")
public class LeadAssignServlet extends HttpServlet {
    
    private LeadAssignmentService assignmentService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.assignmentService = new LeadAssignmentService();
        // Khởi động background worker cùng lifecycle của Servlet
        this.assignmentService.startBackgroundWorker();
    }

    @Override
    public void destroy() {
        // Dừng background worker khi Tomcat shutdown
        if (this.assignmentService != null) {
            this.assignmentService.stopBackgroundWorker();
        }
        super.destroy();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            // Phân quyền: Kiểm tra Role trưởng nhóm (giả lập do chưa có module Auth)
            String userRole = req.getHeader("X-User-Role");
            if (userRole == null || !userRole.equals("TEAM_LEADER")) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Team Leader can assign leads manually.");
                return;
            }

            String leadIdStr = req.getParameter("leadId");
            String assigneeIdStr = req.getParameter("assigneeId");
            
            if (leadIdStr == null || assigneeIdStr == null) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "leadId and assigneeId are required.");
                return;
            }
            
            int leadId = Integer.parseInt(leadIdStr);
            int assigneeId = Integer.parseInt(assigneeIdStr);

            // TODO: Bắt đầu Transaction JDBC
            // Cập nhật bảng Leads: UPDATE leads SET owner_id = assigneeId WHERE id = leadId
            // Lưu lịch sử manual assignment
            // Commit Transaction

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("{\"message\": \"Lead manually assigned successfully.\"}");
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid number format.");
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Assignment failed: " + e.getMessage());
        }
    }
}
