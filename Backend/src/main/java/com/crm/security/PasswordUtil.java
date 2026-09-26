package com.crm.security;

<<<<<<< HEAD
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/**
 * Utility ma hoa va xac thuc mat khau.
 * Su dung BCrypt va ho tro SHA-256 fallback.
 */
public class PasswordUtil {

    public static String hash(String password) {
        if (password == null) return null;
        try {
            return org.mindrot.jbcrypt.BCrypt.hashpw(password, org.mindrot.jbcrypt.BCrypt.gensalt(12));
        } catch (Throwable t) {
            return fallbackSha256(password);
        }
    }

    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            if (hashedPassword.startsWith("$2a$") || hashedPassword.startsWith("$2b$") || hashedPassword.startsWith("$2y$")) {
                return org.mindrot.jbcrypt.BCrypt.checkpw(plainPassword, hashedPassword);
            }
        } catch (Throwable ignored) {
        }
        String fallbackHash = fallbackSha256(plainPassword);
        return fallbackHash.equals(hashedPassword) || plainPassword.equals(hashedPassword);
    }

    private static String fallbackSha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return input;
        }
=======
import org.mindrot.jbcrypt.BCrypt;

/**
 * Lớp tiện ích mã hóa và xác thực mật khẩu sử dụng thư viện BCrypt.
 */
public class PasswordUtil {

    /**
     * Băm mật khẩu thô thành chuỗi băm BCrypt.
     *
     * @param plainPassword Mật khẩu thô
     * @return Chuỗi băm BCrypt
     */
    public static String hash(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Mật khẩu không được để trống.");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }

    /**
     * Kiểm tra mật khẩu thô khớp với chuỗi băm BCrypt hay không.
     *
     * @param plainPassword Mật khẩu thô do người dùng nhập
     * @param hashedPassword Chuỗi băm lưu trong CSDL
     * @return true nếu trùng khớp, false nếu không khớp hoặc lỗi
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Kiểm tra quy tắc mật khẩu mới:
     * Tối thiểu 8 ký tự, phải bao gồm cả chữ cái (a-z, A-Z) và chữ số (0-9).
     *
     * @param password Mật khẩu cần kiểm tra
     * @return true nếu hợp lệ, false nếu vi phạm
     */
    public static boolean validatePasswordRules(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasLetter = false;
        boolean hasDigit = false;

        for (char c : password.toCharArray()) {
            if (Character.isLetter(c)) {
                hasLetter = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }
        return hasLetter && hasDigit;
>>>>>>> 7fce5e7ab1eaee1129210db9c6741f90e73167f9
    }
}
