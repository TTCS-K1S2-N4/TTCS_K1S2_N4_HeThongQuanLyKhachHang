package com.crm.controller.auth;

import com.crm.dao.AccountDAO;
import com.crm.model.Account;
import com.crm.security.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;

@WebServlet("/auth/activate")
public class ActivationServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=invalid_activation");
            return;
        }

        String tokenHash = PasswordUtil.hashToken(token);
        Account account = accountDAO.findByActivationToken(tokenHash);

        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=invalid_activation");
            return;
        }

        if (account.getActivationTokenExpiry() == null || account.getActivationTokenExpiry().before(new Timestamp(System.currentTimeMillis()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=expired_activation");
            return;
        }

        if (!"0".equals(account.getStatus()) && !"LOCKED".equals(account.getStatus()) && !account.getStatus().equals("INACTIVE")) { 
            // the DB is_active = 0 is mapped to LOCKED or INACTIVE somehow.
            // Let's just rely on the activateAccount query which specifies is_active = 0
        }
        
        // Wait, Account DAO maps is_active = 1 to "ACTIVE" and 0 to "LOCKED".
        if (!"LOCKED".equals(account.getStatus())) {
            // Already activated or unexpected state
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=already_activated");
            return;
        }

        boolean success = accountDAO.activateAccount(tokenHash);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?msg=activated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=activation_failed");
        }
    }
}
