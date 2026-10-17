package com.crm.util;

/**
 * Utility class phục vụ xử lý và định dạng JSON chuẩn RFC 8259 cho toàn hệ thống CRM.
 * Giúp serialize an toàn các chuỗi dữ liệu chứa ký tự đặc biệt, dấu nháy, xuống dòng, tab, v.v.
 */
public final class JsonUtil {

    private JsonUtil() {
        // Private constructor ngăn khởi tạo utility class
    }

    /**
     * Escape an toàn chuỗi đầu vào theo đặc tả RFC 8259.
     *
     * @param input Chuỗi cần escape
     * @return Chuỗi đã được escape an toàn để chèn vào JSON
     */
    public static String escape(String input) {
        if (input == null) {
            return "";
        }

        StringBuilder sb = new StringBuilder(input.length() + 16);
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\b':
                    sb.append("\\b");
                    break;
                case '\f':
                    sb.append("\\f");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    if (ch < 0x20) {
                        // Ký tự điều khiển ASCII
                        sb.append(String.format("\\u%04x", (int) ch));
                    } else {
                        sb.append(ch);
                    }
                    break;
            }
        }
        return sb.toString();
    }

    /**
     * Sinh JSON phản hồi thành công chuẩn: {"success":true,"message":"..."}
     */
    public static String successResponse(String message) {
        return "{\"success\":true,\"message\":\"" + escape(message) + "\"}";
    }

    /**
     * Sinh JSON phản hồi thất bại chuẩn: {"success":false,"message":"..."}
     */
    public static String errorResponse(String message) {
        return "{\"success\":false,\"message\":\"" + escape(message) + "\"}";
    }
}
