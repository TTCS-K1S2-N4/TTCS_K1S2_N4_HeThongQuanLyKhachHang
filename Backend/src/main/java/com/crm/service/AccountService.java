package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.AccountCreateRequest;
import com.crm.dto.AccountUpdateRequest;
import com.crm.model.Account;
import com.crm.security.PasswordUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.Timestamp;
import java.util.List;

public class AccountService {
    private final AccountDAO accountDAO = new AccountDAO();

    public boolean isEmailExists(String email) {
        return accountDAO.isEmailExists(email, 0);
    }

    public boolean createAccount(AccountCreateRequest req) {
        String tempPassword = generateTemporaryPassword();
        String passwordHash = BCrypt.hashpw(tempPassword, BCrypt.gensalt(12));
        
        String rawToken = generateActivationToken();
        String tokenHash = PasswordUtil.hashToken(rawToken);
        Timestamp expiry = new Timestamp(System.currentTimeMillis() + 24 * 3600 * 1000L); // 24 hours
        
        boolean created = accountDAO.createAccount(req.getEmail(), passwordHash, req.getFullName(), req.getPhone(), req.getRoleIds(), req.getTeamId(), tokenHash, expiry);
        
        if (created) {
            try {
                sendAccountCreationEmail(req.getEmail(), tempPassword, rawToken);
            } catch (Exception e) {
                // Account created but email failed. We shouldn't rollback account, but log the error securely.
                System.err.println("Gửi email kích hoạt thất bại cho " + req.getEmail() + ". LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i kÃƒÂ¡Ã‚Â»Ã‚Â¹ thuÃƒÂ¡Ã‚ÂºÃ‚Â­t Ãƒâ€žÃ¢â‚¬ËœÃƒÆ’Ã‚Â£ Ãƒâ€žÃ¢â‚¬ËœÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Â£c ghi nhÃƒÂ¡Ã‚ÂºÃ‚Â­n.");
            }
        }
        return created;
    }

    private String generateTemporaryPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String all = upper + lower + digits;
        java.security.SecureRandom rnd = new java.security.SecureRandom();
        StringBuilder sb = new StringBuilder(10);
        sb.append(upper.charAt(rnd.nextInt(upper.length())));
        sb.append(lower.charAt(rnd.nextInt(lower.length())));
        sb.append(digits.charAt(rnd.nextInt(digits.length())));
        for (int i = 0; i < 7; i++) {
            sb.append(all.charAt(rnd.nextInt(all.length())));
        }
        return sb.toString();
    }

    private String generateActivationToken() {
        java.security.SecureRandom random = new java.security.SecureRandom();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private void sendAccountCreationEmail(String toEmail, String tempPassword, String rawToken) throws Exception {
        String host = System.getenv("SMTP_HOST");
        if (host == null) host = "smtp.gmail.com";
        String port = System.getenv("SMTP_PORT");
        if (port == null) port = "587";
        String username = System.getenv("SMTP_USERNAME");
        String password = System.getenv("SMTP_PASSWORD");
        String from = System.getenv("SMTP_FROM");
        if (from == null) from = "no-reply@crm.com";

        if (username == null || password == null) {
            System.err.println("SMTP credentials not configured. Skipping email delivery.");
            return;
        }

        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);

        jakarta.mail.Session session = jakarta.mail.Session.getInstance(props, new jakarta.mail.Authenticator() {
            @Override
            protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                return new jakarta.mail.PasswordAuthentication(username, password);
            }
        });

        jakarta.mail.Message message = new jakarta.mail.internet.MimeMessage(session);
        message.setFrom(new jakarta.mail.internet.InternetAddress(from));
        message.setRecipients(jakarta.mail.Message.RecipientType.TO, jakarta.mail.internet.InternetAddress.parse(toEmail));
        message.setSubject("Kích hoạt tài khoản CRM của bạn");
        
        // Base URL should ideally come from env or config. Using contextPath via HTTP request isn't available here easily.
        // Assuming base URL is configured, or we can use a relative link if we pass the context from the Servlet.
        // But the Servlet isn't passing it right now. Let's assume an env variable APP_URL or default to localhost:8080/crm-backend
        String appUrl = System.getenv("APP_URL");
        if (appUrl == null) appUrl = "http://localhost:8080/crm-backend";
        
        String activationLink = appUrl + "/auth/activate?token=" + java.net.URLEncoder.encode(rawToken, java.nio.charset.StandardCharsets.UTF_8);

        String htmlContent = "<p>Xin chào,</p>"
            + "<p>Tài khoản CRM của bạn đã được tạo thành công.</p>"
            + "<p>Email đăng nhập: <b>" + toEmail + "</b></p>"
            + "<p>MÃƒÂ¡Ã‚ÂºÃ‚Â­t khÃƒÂ¡Ã‚ÂºÃ‚Â©u tÃƒÂ¡Ã‚ÂºÃ‚Â¡m thÃƒÂ¡Ã‚Â»Ã‚Âi: <b>" + tempPassword + "</b></p>"
            + "<p>Ãƒâ€žÃ‚ÂÃƒÂ¡Ã‚Â»Ã†â€™ sÃƒÂ¡Ã‚Â»Ã‚Â­ dÃƒÂ¡Ã‚Â»Ã‚Â¥ng tÃƒÆ’Ã‚Â i khoÃƒÂ¡Ã‚ÂºÃ‚Â£n, bÃƒÂ¡Ã‚ÂºÃ‚Â¡n cÃƒÂ¡Ã‚ÂºÃ‚Â§n kÃƒÆ’Ã‚Â­ch hoÃƒÂ¡Ã‚ÂºÃ‚Â¡t bÃƒÂ¡Ã‚ÂºÃ‚Â±ng liÃƒÆ’Ã‚Âªn kÃƒÂ¡Ã‚ÂºÃ‚Â¿t dÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã¢â‚¬Âºi Ãƒâ€žÃ¢â‚¬ËœÃƒÆ’Ã‚Â¢y (cÃƒÆ’Ã‚Â³ hiÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡u lÃƒÂ¡Ã‚Â»Ã‚Â±c trong 24 giÃƒÂ¡Ã‚Â»Ã‚Â):</p>"
            + "<p><a href=\"" + activationLink + "\">Kích hoạt tài khoản ngay</a></p>"
            + "<p>Vui lòng đăng nhập và đổi mật khẩu sau khi kích hoạt.</p>";
            
        message.setContent(htmlContent, "text/html; charset=UTF-8");

        jakarta.mail.Transport.send(message);
    }

        public List<Account> getAllActiveAccounts() {
        return accountDAO.getAllActiveAccounts();
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
            return false; // Cannot lock self, cannot transfer to self
        }
        
        // Ensure recipient is valid and active
        Account recipient = accountDAO.getAccountById(receiverId);
        if (recipient == null || !"ACTIVE".equals(recipient.getStatus())) {
            return false;
        }

        Account target = accountDAO.getAccountById(accountId);
        if (target == null || !"ACTIVE".equals(target.getStatus())) return false;

        return accountDAO.lockAccountAndTransfer(accountId, receiverId, adminId, reason.trim());
    }
}



