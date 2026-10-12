package com.crm.util;

import java.net.URI;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public final class LeadSpamProtectionUtil {

    private static final Map<String, Long> IP_SUBMISSION_TIME_MAP = new ConcurrentHashMap<>();
    private static final long MIN_SUBMISSION_INTERVAL_MS = 5000; // 5 seconds rate limit per IP

    private LeadSpamProtectionUtil() {}

    /**
     * Kiểm tra xem IP gửi request có bị nghi ngờ là spam / gửi quá dồn dập hay không.
     */
    public static boolean isRateLimited(String clientIp) {
        if (clientIp == null || clientIp.trim().isEmpty()) {
            return false;
        }
        long now = System.currentTimeMillis();
        Long lastTime = IP_SUBMISSION_TIME_MAP.get(clientIp);
        if (lastTime != null && (now - lastTime) < MIN_SUBMISSION_INTERVAL_MS) {
            return true;
        }
        IP_SUBMISSION_TIME_MAP.put(clientIp, now);
        return false;
    }

    /**
     * Kiểm tra domain của referrer có nằm trong danh sách domain cho phép (allowedDomains) hay không.
     */
    public static boolean isDomainAllowed(String refererHeader, String allowedDomains) {
        if (allowedDomains == null || allowedDomains.trim().isEmpty() || "*".equals(allowedDomains.trim())) {
            return true;
        }
        if (refererHeader == null || refererHeader.trim().isEmpty()) {
            return false;
        }

        try {
            URI uri = new URI(refererHeader);
            String refererHost = uri.getHost();
            if (refererHost == null) return false;

            String[] domains = allowedDomains.split("[,;]");
            for (String domain : domains) {
                String cleanDomain = domain.trim().toLowerCase();
                if (cleanDomain.isEmpty()) continue;
                if (refererHost.equalsIgnoreCase(cleanDomain) || refererHost.endsWith("." + cleanDomain)) {
                    return true;
                }
            }
        } catch (Exception e) {
            return false;
        }
        return false;
    }

    /**
     * Kiểm tra honeypot field (nếu bot tự động điền trường ẩn).
     */
    public static boolean isHoneypotTriggered(String honeypotValue) {
        return honeypotValue != null && !honeypotValue.trim().isEmpty();
    }

    /**
     * Kiểm tra nội dung rác / spam chứa từ khóa độc hại hoặc link spam.
     */
    public static boolean containsSpamKeywords(String text) {
        if (text == null || text.trim().isEmpty()) return false;
        String lower = text.toLowerCase();
        return lower.contains("casino") || lower.contains("viagra") || lower.contains("crypto-loan")
                || lower.contains("buy-followers") || lower.contains("http://bit.ly") || lower.contains("https://bit.ly");
    }
}
