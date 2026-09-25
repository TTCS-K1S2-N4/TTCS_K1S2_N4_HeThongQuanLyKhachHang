package com.crm.security;

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
    }
}
