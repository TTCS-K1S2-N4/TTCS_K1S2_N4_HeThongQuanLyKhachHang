package com.crm.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility ma hoa va xac thuc mat khau.
 * Su dung BCrypt va ho tro SHA-256 fallback.
 */
public class PasswordUtil {

    /**
     * Bam mat khau tho thanh chuoi bam BCrypt.
     *
     * @param plainPassword Mat khau tho
     * @return Chuoi bam BCrypt hoac fallback SHA-256
     */
    public static String hash(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Mật khẩu không được để trống.");
        }
        try {
            return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
        } catch (Throwable t) {
            return fallbackSha256(plainPassword);
        }
    }

    /**
     * Kiem tra mat khau tho khop voi chuoi bam BCrypt hay khong.
     *
     * @param plainPassword Mat khau tho do nguoi dung nhap
     * @param hashedPassword Chuoi bam luu trong CSDL
     * @return true neu trung khop, false neu khong khop hoac loi
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }
        try {
            if (hashedPassword.startsWith("$2a$") || hashedPassword.startsWith("$2b$") || hashedPassword.startsWith("$2y$")) {
                return BCrypt.checkpw(plainPassword, hashedPassword);
            }
        } catch (Throwable ignored) {
        }
        String fallbackHash = fallbackSha256(plainPassword);
        return fallbackHash.equals(hashedPassword);
    }

    /**
     * Kiem tra quy tac mat khau moi:
     * Toi thieu 8 ky tu, phai bao gom:
     * - It nhat 1 chu cai (a-z, A-Z)
     * - It nhat 1 chu so (0-9)
     * - It nhat 1 ky tu dac biet (!@#$%^&*...)
     *
     * @param password Mat khau can kiem tra
     * @return true neu hop le, false neu vi pham
     */
    public static boolean validatePasswordRules(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasLetter = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;

        for (char c : password.toCharArray()) {
            if (Character.isLetter(c)) {
                hasLetter = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            } else {
                hasSpecial = true;
            }
        }
        return hasLetter && hasDigit && hasSpecial;
    }

    /**
     * Sinh mat khau tam thoi ngau nhien dap ung day du quy tac bao mat:
     * Toi thieu 10 ky tu, gom chu hoa, chu thuong, chu so va ky tu dac biet.
     *
     * @return Chuoi mat khau tam thoi ngau nhien
     */
    public static String generateTemporaryPassword() {
        String upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        String lower = "abcdefghijkmnpqrstuvwxyz";
        String digits = "23456789";
        String specials = "!@#$%^&*";
        String all = upper + lower + digits + specials;
        
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(10);
        sb.append(upper.charAt(rnd.nextInt(upper.length())));
        sb.append(lower.charAt(rnd.nextInt(lower.length())));
        sb.append(digits.charAt(rnd.nextInt(digits.length())));
        sb.append(specials.charAt(rnd.nextInt(specials.length())));
        for (int i = 0; i < 6; i++) {
            sb.append(all.charAt(rnd.nextInt(all.length())));
        }
        
        char[] chars = sb.toString().toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = rnd.nextInt(i + 1);
            char temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
        }
        return new String(chars);
    }

    public static String hashToken(String token) {
        if (token == null) return null;
        return fallbackSha256(token);
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
    }
}
