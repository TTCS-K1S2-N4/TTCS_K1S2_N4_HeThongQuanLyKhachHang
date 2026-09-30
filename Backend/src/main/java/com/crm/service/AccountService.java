package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.AccountCreateRequest;
import com.crm.dto.AccountUpdateRequest;
import com.crm.model.Account;
import com.crm.security.PasswordUtil;
import com.crm.util.EmailUtil;

import java.util.List;

public class AccountService {
    private final AccountDAO accountDAO = new AccountDAO();

    public boolean isEmailExists(String email) {
        return accountDAO.isEmailExists(email, 0);
    }

    public enum CreateAccountStatus {
        SUCCESS_EMAIL_SENT,
        SUCCESS_EMAIL_FAILED,
        CREATE_FAILED
    }

    public static class CreateAccountResult {
        private final CreateAccountStatus status;
        private final String errorMessage;

        public CreateAccountResult(CreateAccountStatus status, String errorMessage) {
            this.status = status;
            this.errorMessage = errorMessage;
        }

        public CreateAccountStatus getStatus() { return status; }
        public String getErrorMessage() { return errorMessage; }
    }

    public CreateAccountResult createAccountResult(AccountCreateRequest req) {
        // Sinh mật khẩu tạm thời đáp ứng chuẩn bảo mật (min 8 chars, letter, digit, special char)
        String tempPassword = PasswordUtil.generateTemporaryPassword();
        String passwordHash = PasswordUtil.hash(tempPassword);
        
        // Lưu mật khẩu dưới dạng BCrypt hash trong cơ sở dữ liệu (tài khoản trạng thái is_active = 1)
        boolean created = accountDAO.createAccount(req.getEmail(), passwordHash, req.getFullName(), req.getPhone(), req.getRoleIds(), req.getTeamId(), null, null);
        
        if (!created) {
            return new CreateAccountResult(CreateAccountStatus.CREATE_FAILED, "Không thể lưu thông tin tài khoản vào cơ sở dữ liệu.");
        }

        // Gửi email chứa thông tin tài khoản và mật khẩu tạm thời
        try {
            sendAccountCreationEmail(req.getEmail(), req.getFullName(), tempPassword);
            return new CreateAccountResult(CreateAccountStatus.SUCCESS_EMAIL_SENT, null);
        } catch (Exception e) {
            String errorMsg = e.getMessage() != null ? e.getMessage() : "Không thể gửi mail qua SMTP.";
            System.err.println("Gửi email tạo tài khoản thất bại cho " + req.getEmail() + ": " + errorMsg);
            return new CreateAccountResult(CreateAccountStatus.SUCCESS_EMAIL_FAILED, errorMsg);
        }
    }

    public boolean createAccount(AccountCreateRequest req) {
        CreateAccountResult res = createAccountResult(req);
        return res.getStatus() == CreateAccountStatus.SUCCESS_EMAIL_SENT || res.getStatus() == CreateAccountStatus.SUCCESS_EMAIL_FAILED;
    }

    public boolean resendTemporaryPassword(int accountId) throws Exception {
        Account account = accountDAO.getAccountById(accountId);
        if (account == null) {
            throw new Exception("Tài khoản không tồn tại.");
        }
        String newTempPassword = PasswordUtil.generateTemporaryPassword();
        String passwordHash = PasswordUtil.hash(newTempPassword);
        boolean updated = accountDAO.updatePassword(accountId, passwordHash);
        if (!updated) {
            throw new Exception("Không thể cập nhật mật khẩu mới cho tài khoản.");
        }
        sendAccountCreationEmail(account.getEmail(), account.getFullName(), newTempPassword);
        return true;
    }

    private void sendAccountCreationEmail(String toEmail, String fullName, String tempPassword) throws Exception {
        String htmlContent = "<div style=\"font-family: Arial, sans-serif; padding: 20px; color: #333;\">"
            + "<h2>Thông tin tài khoản CRM</h2>"
            + "<p>Xin chào <b>" + (fullName != null ? fullName : toEmail) + "</b>,</p>"
            + "<p>Tài khoản sử dụng hệ thống CRM của bạn đã được khởi tạo/cập nhật mật khẩu thành công.</p>"
            + "<div style=\"background: #f8fafc; border-left: 4px solid #4f46e5; padding: 15px; margin: 15px 0;\">"
            + "<p style=\"margin: 5px 0;\">Email đăng nhập: <b>" + toEmail + "</b></p>"
            + "<p style=\"margin: 5px 0;\">Mật khẩu tạm thời: <b style=\"color: #4f46e5; font-size: 16px;\">" + tempPassword + "</b></p>"
            + "</div>"
            + "<p>Vui lòng sử dụng thông tin trên để đăng nhập vào hệ thống và đổi lại mật khẩu mới.</p>"
            + "</div>";

        EmailUtil.sendEmail(toEmail, "Thông tin tài khoản CRM của bạn", htmlContent);
    }

    public List<Account> getAllActiveAccounts() {
        return accountDAO.getAllActiveAccounts();
    }

    public boolean unlockAccount(int accountId) {
        return accountDAO.unlockAccount(accountId);
    }

    public List<Account> getAccountList(String keyword, Integer teamId, Integer roleId, String status, int page) {
        int limit = 20;
        int offset = (page - 1) * limit;
        return accountDAO.getAccounts(keyword, teamId, roleId, status, offset, limit);
    }

    public int countTotalAccounts(String keyword, Integer teamId, Integer roleId, String status) {
        return accountDAO.countAccounts(keyword, teamId, roleId, status);
    }

    public Account getAccountDetail(int accountId) {
        return accountDAO.getAccountById(accountId);
    }

    public boolean updateAccount(AccountUpdateRequest req) {
        return accountDAO.updateAccount(req.getAccountId(), req.getFullName(), req.getPhone(), req.getTeamId(), req.getRoleIds());
    }

    public int countOwnedAssets(int accountId) {
        return accountDAO.countOwnedRecords(accountId);
    }

    public boolean lockAndTransferData(int accountId, Integer receiverId, int adminId, String reason) {
        if (receiverId == null || receiverId <= 0) {
            return false;
        }
        if (reason == null || reason.trim().isEmpty()) return false;
        if (accountId == adminId || accountId == receiverId) {
            return false;
        }
        
        Account recipient = accountDAO.getAccountById(receiverId);
        if (recipient == null || !"ACTIVE".equals(recipient.getStatus())) {
            return false;
        }

        Account target = accountDAO.getAccountById(accountId);
        if (target == null || !"ACTIVE".equals(target.getStatus())) return false;

        return accountDAO.lockAccountAndTransfer(accountId, receiverId, adminId, reason.trim());
    }
}
