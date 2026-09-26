package com.crm.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility ma hoa va xac thuc mat khau.
 * Su dung BCrypt va ho tro SHA-256 fallback.
 */
public class PasswordUtil {

    /**
     * Bam mat khau tho thanh chuoi bam BCrypt (hoac SHA-256 fallback).
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
        return fallbackHash.equals(hashedPassword) || plainPassword.equals(hashedPassword);
    }

    /**
     * Kiem tra quy tac mat khau moi:
     * Toi thieu 8 ky tu, phai bao gom ca chu cai (a-z, A-Z) va chu so (0-9).
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

        for (char c : password.toCharArray()) {
            if (Character.isLetter(c)) {
                hasLetter = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }
        return hasLetter && hasDigit;
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
