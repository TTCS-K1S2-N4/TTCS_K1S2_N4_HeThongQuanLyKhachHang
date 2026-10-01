# Phân tích Thay đổi Code & Tóm tắt Pull Request (PR)

Tài liệu này tổng hợp và phân loại chi tiết toàn bộ các thay đổi trong workspace/branch `feature/BE-02-forgot-password` thuộc hệ thống CRM, chia theo hai tính năng **S1-03 (Forgot Password)** và **S1-07 (Error Pages)**.

---

## 🔐 1. Tính năng S1-03: Forgot Password (Quên mật khẩu)

Bao gồm các file, class và logic xử lý toàn bộ luồng gửi yêu cầu khôi phục, tạo token xác thực có thời hạn, kiểm tra tính hợp lệ và đặt lại mật khẩu mới.

### Danh sách các file & Vai trò chi tiết:

1. **`ForgotPasswordServlet.java`**
   - **Đường dẫn:** `src/main/java/com/crm/controller/auth/ForgotPasswordServlet.java` (và `Backend/...`)
   - **Vai trò:** Controller (Servlet) xử lý HTTP request tại URL `/forgot-password`.
     - Phương thức `GET`: Điều hướng người dùng đến giao diện nhập email hoặc giao diện đặt lại mật khẩu mới khi có token.
     - Phương thức `POST`: Xử lý gửi yêu cầu tạo token khôi phục mật khẩu dựa trên email, hoặc xác thực token và cập nhật mật khẩu mới cho tài khoản.

2. **`forgot-password.jsp`**
   - **Đường dẫn:** `src/main/webapp/WEB-INF/views/auth/forgot-password.jsp` (và `Backend/...`)
   - **Vai trò:** View (JSP) giao diện người dùng cho tính năng Quên mật khẩu. Hỗ trợ hiển thị 2 trạng thái: form nhập Email để lấy mã/link reset và form nhập Mật khẩu mới + Xác nhận mật khẩu.

3. **`AuthService.java`**
   - **Đường dẫn:** `src/main/java/com/crm/service/AuthService.java` (và `Backend/...`)
   - **Vai trò:** Service xử lý nghiệp vụ chính liên quan đến xác thực và quên mật khẩu:
     - `generateResetToken(email)`: Kiểm tra thông tin tài khoản, tạo UUID Token có thời gian hết hạn trong 30 phút và gọi DAO lưu vào CSDL.
     - `validateResetToken(token)`: Kiểm tra token có hợp lệ và còn thời hạn hay không.
     - `resetPasswordWithToken(token, newPassword, confirmPassword)`: Kiểm tra mật khẩu hợp lệ (tối thiểu 6 ký tự, khớp xác nhận), băm mật khẩu mới và gọi DAO cập nhật, đồng thời xóa token.

4. **`AccountDAO.java`**
   - **Đường dẫn:** `src/main/java/com/crm/dao/AccountDAO.java` (và `Backend/...`)
   - **Vai trò:** Data Access Object thao tác trực tiếp với CSDL MySQL:
     - `findByEmail(email)`: Truy vấn tài khoản người dùng theo địa chỉ email.
     - `findByResetToken(token)`: Tìm kiếm thông tin tài khoản gắn liền với token khôi phục.
     - `saveResetToken(accountId, token, expiry)`: Cập nhật `reset_token` và `reset_token_expiry` vào bảng người dùng.
     - `updatePasswordAndClearResetToken(accountId, newPasswordHash)`: Đặt lại `password_hash` mới và reset `reset_token` / `reset_token_expiry` về `NULL`.

5. **`Account.java`**
   - **Đường dẫn:** `src/main/java/com/crm/model/Account.java` (và `Backend/...`)
   - **Vai trò:** Model Entity đại diện cho tài khoản người dùng. Được bổ sung 2 thuộc tính `resetToken` (String) và `resetTokenExpiry` (Timestamp) cùng các phương thức Getter/Setter tương ứng.

6. **`PasswordUtil.java`**
   - **Đường dẫn:** `src/main/java/com/crm/security/PasswordUtil.java` (và `Backend/...`)
   - **Vai trò:** Class tiện ích mã hóa bảo mật. Hỗ trợ băm mật khẩu (Hash) bằng BCrypt / SHA-256 và so khớp mật khẩu người dùng nhập với chuỗi băm lưu trong CSDL.

7. **`schema.sql`**
   - **Đường dẫn:** `Backend/src/main/resources/sql/schema.sql`
   - **Vai trò:** Script SQL khởi tạo CSDL, được cập nhật câu lệnh `CREATE TABLE users` bổ sung 2 cột mới:
     - `reset_token VARCHAR(255) NULL`
     - `reset_token_expiry TIMESTAMP NULL`

8. **`AuthServiceTest.java`**
   - **Đường dẫn:** `src/test/java/com/crm/service/AuthServiceTest.java`
   - **Vai trò:** Unit Test kiểm thử tự động cho `AuthService`. Bao gồm các test case cho tạo token thành công/thất bại, validate token hết hạn, và đặt lại mật khẩu với dữ liệu hợp lệ/không hợp lệ.

---

## 🚫 2. Tính năng S1-07: Error Pages (Trang xử lý lỗi)

Bao gồm các file xử lý điều hướng và giao diện hiển thị thông báo lỗi hệ thống thân thiện với người dùng.

### Danh sách các file & Vai trò chi tiết:

1. **`ErrorServlet.java`**
   - **Đường dẫn:** `src/main/java/com/crm/controller/error/ErrorServlet.java` (và `Backend/...`)
   - **Vai trò:** Controller tiếp nhận và xử lý tập trung các lỗi HTTP (mã 403, 404...). Đọc `status_code` từ request hoặc tham số URL để forward request tới đúng view JSP tương ứng (`403.jsp` hoặc `404.jsp`).

2. **`403.jsp`**
   - **Đường dẫn:** `src/main/webapp/WEB-INF/views/errors/403.jsp` (và `Backend/...`)
   - **Vai trò:** Giao diện trang lỗi **403 Access Denied / Forbidden**. Hiển thị thông báo người dùng không có đủ quyền hạn để truy cập tài nguyên hoặc thực hiện hành động này.

3. **`404.jsp`**
   - **Đường dẫn:** `src/main/webapp/WEB-INF/views/errors/404.jsp` (và `Backend/...`)
   - **Vai trò:** Giao diện trang lỗi **404 Not Found**. Hiển thị thông báo không tìm thấy trang hoặc địa chỉ URL không tồn tại trên hệ thống.

4. **`web.xml`**
   - **Đường dẫn:** `src/main/webapp/WEB-INF/web.xml` (và `Backend/...`)
   - **Vai trò:** Deployment Descriptor cấu hình các thẻ `<error-page>` trong Servlet Container để tự động bắt các mã lỗi HTTP `403` và `404`, điều hướng tự động sang `/error/403` và `/error/404`.

5. **`AuthorizationFilter.java`**
   - **Đường dẫn:** `src/main/java/com/crm/filter/AuthorizationFilter.java` (và `Backend/...`)
   - **Vai trò:** Servlet Filter kiểm tra phân quyền truy cập người dùng. Được cập nhật lại đường dẫn forward từ trang cũ `/WEB-INF/views/403.jsp` sang cấu trúc mới `/WEB-INF/views/errors/403.jsp`.

---

## ⚙️ 3. Cấu hình & Bổ trợ chung (General / Build Config)

1. **`pom.xml`**
   - **Đường dẫn:** `pom.xml` (và `Backend/pom.xml`)
   - **Vai trò:** Cấu hình quản lý thư viện Maven. Thêm dependency `jbcrypt` (version `0.4`) phục vụ mã hóa mật khẩu an toàn và cập nhật tên dự án chuẩn hóa (`crm-backend`).

2. **`LoginRequest.java` & `AuthenticationException.java`**
   - **Đường dẫn:** `src/main/java/com/crm/dto/LoginRequest.java`, `src/main/java/com/crm/exception/AuthenticationException.java`
   - **Vai trò:** DTO chứa dữ liệu đăng nhập và Custom Exception xử lý ngoại lệ trong quá trình xác thực / phục hồi mật khẩu.

---

## 📝 Nội dung tóm tắt sẵn sàng cho Mô tả Pull Request (PR Description)

```markdown
## 🚀 Các thay đổi trong Pull Request này

### 🔐 1. Tính năng S1-03: Forgot Password (Quên mật khẩu)
- **`ForgotPasswordServlet.java`**: Controller xử lý luồng yêu cầu reset password & cập nhật mật khẩu mới qua URL `/forgot-password`.
- **`forgot-password.jsp`**: Giao diện người dùng cho phép nhập Email nhận mã và form đặt lại mật khẩu mới.
- **`AuthService.java`**: Bổ sung các phương thức nghiệp vụ: `generateResetToken()`, `validateResetToken()`, `resetPasswordWithToken()`.
- **`AccountDAO.java`**: Thêm các câu lệnh truy vấn tìm tài khoản theo Email/Token và cập nhật mật khẩu + xóa Token.
- **`Account.java`**: Bổ sung trường `resetToken` và `resetTokenExpiry`.
- **`PasswordUtil.java`**: Utility hỗ trợ băm và kiểm tra mật khẩu an toàn với BCrypt.
- **`schema.sql`**: Bổ sung 2 cột `reset_token` và `reset_token_expiry` vào bảng `users`.
- **`AuthServiceTest.java`**: Viết Unit Test cho toàn bộ luồng Quên mật khẩu.

### 🚫 2. Tính năng S1-07: Error Pages (Trang xử lý lỗi)
- **`ErrorServlet.java`**: Controller điều hướng tập trung cho các mã lỗi HTTP.
- **`403.jsp`**: Trang hiển thị giao diện lỗi 403 Forbidden (Truy cập bị từ chối).
- **`404.jsp`**: Trang hiển thị giao diện lỗi 404 Not Found (Không tìm thấy trang).
- **`web.xml`**: Cấu hình thẻ `<error-page>` mapping mã lỗi 403, 404 tới Servlet xử lý lỗi.
- **`AuthorizationFilter.java`**: Cập nhật đường dẫn forward khi chặn quyền truy cập sang view lỗi 403 mới.

### ⚙️ 3. Build & Configuration
- **`pom.xml`**: Thêm thư viện `jbcrypt` cho việc mã hoá mật khẩu.
```
