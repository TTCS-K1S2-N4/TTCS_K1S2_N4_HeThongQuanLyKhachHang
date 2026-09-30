package com.crm.exception;

/**
 * Ngoại lệ tùy chỉnh (Custom Exception) cho xử lý Phân quyền dữ liệu và Chức năng.
 * Ném ra khi người dùng không có quyền truy cập dữ liệu hoặc tính năng tương ứng.
 * Chứa thông báo lỗi bằng tiếng Việt rõ ràng theo yêu cầu Acceptance Criteria S1-05.
 */
public class AuthorizationException extends RuntimeException {
    private static final long serialVersionUID = 1L;

    private final String errorCode;

    public AuthorizationException(String message) {
        super(message);
        this.errorCode = "ERR_FORBIDDEN";
    }

    public AuthorizationException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public AuthorizationException(String message, Throwable cause) {
        super(message, cause);
        this.errorCode = "ERR_FORBIDDEN";
    }

    public String getErrorCode() {
        return errorCode;
    }
}
