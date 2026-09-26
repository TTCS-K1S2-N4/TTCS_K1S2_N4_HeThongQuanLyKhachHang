package com.crm.security;

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
    }
}
