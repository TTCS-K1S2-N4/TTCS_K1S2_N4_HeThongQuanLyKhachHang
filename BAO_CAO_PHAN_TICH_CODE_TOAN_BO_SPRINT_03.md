# BÁO CÁO PHÂN TÍCH SOURCE CODE TOÀN BỘ SPRINT 03
## HỆ THỐNG QUẢN LÝ QUAN HỆ KHÁCH HÀNG (CRM SYSTEM)
### TÀI LIỆU CHUẨN BỊ BẢO VỆ VỚI TECHNICAL MENTOR

---

## MỤC LỤC
1. [PHẦN I. Tổng quan dự án và Sprint 03](#phần-i-tổng-quan-dự-án-và-sprint-03)
2. [PHẦN II. Phân tích chi tiết từng User Story](#phần-ii-phân-tích-chi-tiết-từng-user-story)
   - [2.1. S30-02: Quản lý hồ sơ khách hàng doanh nghiệp](#21-s30-02-quản-lý-hồ-sơ-khách-hàng-doanh-nghiệp)
   - [2.2. S30-03: Quản lý người liên hệ và vai trò trong quyết định mua hàng](#22-s30-03-quản-lý-người-liên-hệ-và-vai-trò-trong-quyết-định-mua-hàng)
   - [2.3. S30-04: Hồ sơ khách hàng 360 độ và dòng thời gian hoạt động](#23-s30-04-hồ-sơ-khách-hàng-360-độ-và-dòng-thời-gian-hoạt-động)
   - [2.4. S30-05: Phát hiện khách hàng trùng lặp và gộp hồ sơ](#24-s30-05-phát-hiện-khách-hàng-trùng-lặp-và-gộp-hồ-sơ)
   - [2.5. S30-06: Quản lý quan hệ công ty mẹ – công ty con](#25-s30-06-quản-lý-quan-hệ-công-ty-mẹ--công-ty-con)
   - [2.6. S30-07: Import khách hàng từ Excel](#26-s30-07-import-khách-hàng-từ-excel)
   - [2.7. S30-08: Tìm kiếm, lọc và lưu bộ lọc khách hàng](#27-s30-08-tìm-kiếm-lọc-và-lưu-bộ-lọc-khách-hàng)
   - [2.8. S30-09: Quản lý yêu cầu hỗ trợ và cảnh báo rủi ro khách hàng](#28-s30-09-quản-lý-yêu-cầu-hỗ-trợ-và-cảnh-báo-rủi-ro-khách-hàng)
   - [2.9. S30-10: Lập danh sách khách hàng cần chăm sóc định kỳ](#29-s30-10-lập-danh-sách-khách-hàng-cần-chăm-sóc-định-kỳ)
3. [PHẦN III. So sánh và liên kết giữa các User Story](#phần-iii-so-sánh-và-liên-kết-giữa-các-user-story)
4. [PHẦN IV. Tổng hợp trạng thái triển khai Sprint 03](#phần-iv-tổng-hợp-trạng-thái-triển-khai-sprint-03)
5. [PHẦN V. Bộ tài liệu ôn tập và kịch bản bảo vệ](#phần-v-bộ-tài-liệu-ôn-tập-và-kịch-bản-bảo-vệ)

---

# PHẦN I. TỔNG QUAN DỰ ÁN VÀ SPRINT 03

### 1.1 Mục tiêu Sprint 03
Sprint 03 tập trung vào phân hệ cốt lõi của hệ thống CRM: **Phân hệ Khách hàng Doanh nghiệp (B2B Customers & Accounts Management)**. Mục tiêu nghiệp vụ bao gồm:
- Chuẩn hóa thông tin định danh pháp lý của khách hàng doanh nghiệp (Mã số thuế, Ngành nghề, Quy mô, Doanh thu, Trạng thái quan hệ).
- Quản lý sơ đồ người liên hệ (Buying Center / Mua hàng B2B) với vai trò quyết định mua.
- Tổng hợp góc nhìn toàn diện 360 độ (hợp đồng đã ký, cơ hội đang mở, lịch sử tương tác, tệp tài liệu, công ty con).
- Tối ưu hóa chất lượng dữ liệu: phát hiện trùng lặp, gộp dữ liệu bảo toàn lịch sử giao dịch, nhập khẩu hàng loạt từ Excel có kiểm tra lỗi.
- Kiểm soát rủi ro rời bỏ khách hàng (Churn Risk) dựa trên yêu cầu hỗ trợ tồn đọng và lập lịch chăm sóc định kỳ theo chu kỳ tương tác.

### 1.2 Kiến trúc kỹ thuật thực tế của dự án
Dự án được triển khai theo mô hình kiến trúc phân lớp truyền thống **Java EE / Jakarta EE MVC 2 Layered Architecture**, không dùng framework nặng (Spring Framework / Hibernate) mà trực tiếp sử dụng nền tảng Servlet và JDBC thuần:
- **Presentation Layer (Frontend / View)**: JSP (Jakarta Server Pages), JSTL (`jakarta.tags.core`), CSS tùy biến theo module, Vanilla JavaScript tương tác DOM / Fetch API.
- **Routing & Control Layer**: Jakarta Servlet (`HttpServlet`) với annotation `@WebServlet`, phân luồng HTTP GET, POST và phân phối view qua `RequestDispatcher.forward()` hoặc `HttpServletResponse.sendRedirect()`.
- **Security & Interception Layer**: Chuỗi Servlet Filter gồm `EncodingFilter` (UTF-8), `AuthenticationFilter` (xác thực phiên đăng nhập qua Session `userId`), và `AuthorizationFilter` (kiểm tra phân quyền tĩnh `PermissionCode` và Data Scope).
- **Service / Business Logic Layer**: Các lớp Java POJO Service chịu trách nhiệm xử lý nghiệp vụ, kiểm tra ràng buộc, tính toán chỉ số, điều phối Transaction liên bảng và kiểm tra quyền truy cập phạm vi dữ liệu (`DataScope`).
- **Data Access Layer (DAO)**: Data Access Object sử dụng JDBC thuần (`java.sql.Connection`, `PreparedStatement`, `ResultSet`), xử lý mapping dữ liệu thủ công sang Model / DTO.
- **Database Layer**: Hệ quản trị cơ sở dữ liệu MySQL (phiên bản 8.0), kết nối qua `com.mysql.cj.jdbc.Driver` với connection pool/quản lý tại `DBConnection`.

### 1.3 Cây thư mục rút gọn (Phạm vi Sprint 03)
```text
TTCS_K1S2_N4_HeThongQuanLyKhachHang/
├── pom.xml
├── README.md
├── BE3_Phan_Quyen_Du_Lieu_Spec.md
└── Backend/
    ├── pom.xml
    └── src/
        ├── main/
        │   ├── java/com/crm/
        │   │   ├── controller/
        │   │   │   ├── contact/
        │   │   │   │   ├── ContactCreateServlet.java
        │   │   │   │   ├── ContactDetailServlet.java
        │   │   │   │   ├── ContactListServlet.java
        │   │   │   │   ├── ContactPrimaryServlet.java
        │   │   │   │   ├── ContactTransferServlet.java
        │   │   │   │   └── ContactUpdateServlet.java
        │   │   │   └── customer/
        │   │   │       ├── Customer360Servlet.java
        │   │   │       ├── CustomerCareServlet.java
        │   │   │       ├── CustomerDetailServlet.java
        │   │   │       ├── CustomerDuplicateServlet.java
        │   │   │       ├── CustomerExportServlet.java
        │   │   │       ├── CustomerFilterServlet.java
        │   │   │       ├── CustomerHierarchyServlet.java
        │   │   │       ├── CustomerImportServlet.java
        │   │   │       ├── CustomerListServlet.java
        │   │   │       ├── CustomerMergeServlet.java
        │   │   │       ├── CustomerRiskServlet.java
        │   │   │       ├── CustomerSaveServlet.java
        │   │   │       ├── CustomerSupportServlet.java
        │   │   │       └── CustomerTimelineServlet.java
        │   │   ├── dao/
        │   │   │   ├── ContactCompanyHistoryDAO.java
        │   │   │   ├── ContactDAO.java
        │   │   │   ├── CustomerCareDAO.java
        │   │   │   ├── CustomerDAO.java
        │   │   │   ├── CustomerRelationshipDAO.java
        │   │   │   ├── CustomerRiskDAO.java
        │   │   │   ├── OpportunityDAO.java
        │   │   │   ├── PermissionDAO.java
        │   │   │   ├── SavedFilterDAO.java
        │   │   │   └── SupportRequestDAO.java
        │   │   ├── dto/
        │   │   │   ├── ContactRequest.java / ContactResponse.java / ContactTransferRequest.java
        │   │   │   ├── Customer360Response.java / CustomerCareResponse.java
        │   │   │   ├── CustomerFilterRequest.java / CustomerImportRequest.java
        │   │   │   └── DuplicateCandidate.java
        │   │   ├── filter/
        │   │   │   ├── AuthenticationFilter.java
        │   │   │   └── AuthorizationFilter.java
        │   │   ├── model/
        │   │   │   ├── Contact.java / ContactCompanyHistory.java
        │   │   │   ├── Customer.java / CustomerCareState.java / CustomerRelationship.java
        │   │   │   ├── CustomerRisk.java / DataScope.java / SavedFilter.java
        │   │   ├── service/
        │   │   │   ├── ContactService.java
        │   │   │   ├── Customer360Service.java
        │   │   │   ├── CustomerCareService.java
        │   │   │   ├── CustomerFilterService.java
        │   │   │   ├── CustomerHierarchyService.java
        │   │   │   ├── CustomerImportService.java
        │   │   │   ├── CustomerMergeService.java
        │   │   │   ├── CustomerRiskService.java
        │   │   │   ├── CustomerSupportService.java
        │   │   │   └── PermissionService.java
        │   │   └── util/
        │   │       ├── DBConnection.java
        │   │       └── ValidationUtil.java
        │   ├── resources/
        │   │   ├── db.properties
        │   │   └── sql/
        │   │       ├── schema.sql
        │   │       ├── test_data.sql
        │   │       └── restore_role_permissions.sql
        │   └── webapp/
        │       ├── WEB-INF/
        │       │   ├── web.xml
        │       │   └── views/
        │       │       ├── contacts/ (create.jsp, detail.jsp, edit.jsp, list.jsp, transfer.jsp)
        │       │       └── customers/ (360.jsp, care-list.jsp, create.jsp, detail.jsp, duplicates.jsp,
        │       │                       edit.jsp, hierarchy.jsp, import.jsp, import-preview.jsp,
        │       │                       list.jsp, merge.jsp, risks.jsp, saved-filters.jsp, support.jsp)
        └── test/java/com/crm/
            ├── controller/customer/CustomerSaveServletTest.java
            ├── model/CustomerTest.java
            └── service/
                ├── Customer360ServiceTest.java
                ├── CustomerCareServiceTest.java
                ├── CustomerFilterServiceTest.java
                ├── CustomerImportServiceTest.java
                ├── CustomerMergeServiceTest.java
                ├── CustomerSupportAndRiskServiceTest.java
                └── PermissionServiceTest.java
```

### 1.4 Cơ chế Xác thực và Phân quyền (Security & Data Scoping)
1. **Xác thực (Authentication)**: `AuthenticationFilter` kiểm tra session `userId`. Nếu chưa đăng nhập, chuyển hướng sang `/auth/login`.
2. **Phân quyền chức năng (Role-Based URL Authorization)**: `AuthorizationFilter` map từng URL với permission code:
   - `/customers/create`, `/customers/import*`: `ACCOUNT_CREATE`
   - `/customers/edit`, `/customers/merge`: `ACCOUNT_EDIT`
   - `/customers/delete`: `ACCOUNT_DELETE`
   - `/customers`, `/customers/detail`, `/customers/360`, `/customers/care`: `ACCOUNT_VIEW`
3. **Phân quyền phạm vi dữ liệu (Data Scope Guard)**:
   - `DataScope.MY`: Nhân viên kinh doanh chỉ nhìn thấy bản ghi có `owner_id = userId`.
   - `DataScope.TEAM`: Trưởng nhóm kinh doanh nhìn thấy bản ghi của toàn bộ thành viên thuộc nhóm mình (`owner_id IN (team_members)`).
   - `DataScope.ALL`: Giám đốc/Admin nhìn thấy toàn bộ bản ghi hệ thống (`owner_id` không bị ràng buộc).

---

# PHẦN II. PHÂN TÍCH CHI TIẾT TỪNG USER STORY

---

## 2.1. S30-02: Quản lý hồ sơ khách hàng doanh nghiệp

### 2.1.1 Thông tin chức năng
- **Mã User Story**: S30-02.
- **Nhu cầu nghiệp vụ**: Doanh nghiệp B2B cần quản lý đầy đủ thông tin pháp lý của đối tác doanh nghiệp, phân quyền người phụ trách, quản lý trạng thái mối quan hệ để phục vụ chiến dịch bán hàng và chăm sóc.
- **Tiêu chí nghiệm thu (AC)**:
  1. Khai báo các thông tin: Tên công ty, Mã số thuế, Ngành nghề, Quy mô, Website, Địa chỉ, Người sở hữu.
  2. Mã số thuế nếu có phải là duy nhất trên toàn hệ thống.
  3. Bốn trạng thái chuẩn: Tiềm năng (`POTENTIAL`), Đang giao dịch (`DEALING`), Khách hàng (`CUSTOMER`), Ngừng hợp tác (`STOPPED`).
  4. Phân quyền: Nhân viên chỉ thấy khách hàng mình sở hữu; Trưởng nhóm thấy khách hàng thuộc nhóm của mình.
  5. Đầy đủ các luồng Xem danh sách, Tạo mới, Xem chi tiết, Cập nhật hồ sơ.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.1.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerSaveServlet.java`: Xử lý tạo mới, sửa, xóa khách hàng.
- `Backend/src/main/java/com/crm/controller/customer/CustomerListServlet.java`: Xử lý hiển thị danh sách, phân trang, tích hợp lọc.
- `Backend/src/main/java/com/crm/controller/customer/CustomerDetailServlet.java`: Hiển thị chi tiết khách hàng và kiểm tra quyền Data Scope.
- `Backend/src/main/java/com/crm/service/CustomerFilterService.java`: Tính toán danh sách `ownerIds` hợp lệ dựa trên vai trò người dùng.
- `Backend/src/main/java/com/crm/service/PermissionService.java`: Trung tâm xác định DataScope (`MY`, `TEAM`, `ALL`).
- `Backend/src/main/java/com/crm/dao/CustomerDAO.java`: Truy vấn CSDL cho bảng `customers`.
- `Backend/src/main/java/com/crm/model/Customer.java`: Thực thể lưu trữ thuộc tính công ty.
- `Backend/src/main/webapp/WEB-INF/views/customers/list.jsp`, `create.jsp`, `edit.jsp`, `detail.jsp`: Giao diện người dùng.
- `Backend/src/test/java/com/crm/controller/customer/CustomerSaveServletTest.java`: Unit test kiểm thử validation Servlet.

### 2.1.3 Luồng hoạt động từ đầu đến cuối
1. **Tạo mới**: User mở `GET /customers/create` $\rightarrow$ Submit `POST /customers/create` $\rightarrow$ `AuthorizationFilter` kiểm tra quyền `ACCOUNT_CREATE` $\rightarrow$ `CustomerSaveServlet.handleSave()` đọc tham số form $\rightarrow$ Kiểm tra `customerName` bắt buộc $\rightarrow$ Gọi `customerDAO.isTaxCodeExists(taxCode, null)` kiểm tra trùng $\rightarrow$ Chuẩn hóa enum trạng thái $\rightarrow$ Gọi `customerDAO.insert(customer)` $\rightarrow$ MySQL thực thi `INSERT` và trả về `generatedKeys` $\rightarrow$ Chuyển hướng `302 Found` về `/customers`.
2. **Xem danh sách**: `GET /customers` $\rightarrow$ `CustomerListServlet.doGet()` lấy session `userId`, `roleId` $\rightarrow$ `CustomerFilterService.getEffectiveOwnerIds()` gọi `PermissionService` xác định Data Scope $\rightarrow$ `CustomerDAO.getList(filterReq, ownerIds)` sinh câu truy vấn SQL có `AND c.owner_id IN (...)` $\rightarrow$ Forward sang `list.jsp` hiển thị kết quả và phân trang.
3. **Xem chi tiết & Chặn IDOR**: `GET /customers/detail?id=X` $\rightarrow$ `CustomerDetailServlet.doGet()` gọi `customerDAO.findById(X)` $\rightarrow$ Gọi `permissionService.validateDataAccessForRoles(userId, effectiveRoles, "ACCOUNT", customer.getOwnerId())` $\rightarrow$ Nếu `ownerId` nằm ngoài quyền của user thì ném `AuthorizationException` và trả về `403 Forbidden`.

### 2.1.4 Giải thích code chi tiết
Tại `CustomerSaveServlet.java`:
```java
// Dòng 113-120: Kiểm tra trùng mã số thuế
if (taxCode != null && !taxCode.trim().isEmpty()) {
    taxCode = taxCode.trim();
    if (customerDAO.isTaxCodeExists(taxCode, customerId)) {
        sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Mã số thuế đã tồn tại trong hệ thống", isEdit, isJsonRequest);
        return;
    }
}
```
- Khi thêm mới, `customerId` là `null`. Khi cập nhật, `customerId` được truyền vào để câu SQL loại trừ chính khách hàng đang chỉnh sửa (`AND customer_id != ?`), tránh báo lỗi giả.

### 2.1.5 Database và SQL
- Bảng chính: `customers`. Cột: `customer_id` (PK), `customer_name`, `tax_code`, `phone`, `email`, `industry`, `size`, `website`, `address`, `status`, `owner_id` (FK tới `users.user_id`).
- Truy vấn kiểm tra trùng mã số thuế:
  ```sql
  SELECT COUNT(*) FROM customers WHERE LOWER(TRIM(tax_code)) = LOWER(TRIM(?)) [AND customer_id != ?];
  ```
- **Rủi ro thực tế**: Cơ sở dữ liệu hiện tại **chưa có `UNIQUE INDEX`** trên cột `tax_code` (chỉ có index `owner_id` và PK). Việc kiểm tra mới ở mức tầng ứng dụng (Application Level), có rủi ro race condition nếu 2 request gửi đồng thời.

### 2.1.6 Kiểm thử
- File test: `CustomerSaveServletTest.java`.
  - `testDoPost_NotLoggedIn_ReturnsUnauthorized()`: Chứng minh người dùng chưa đăng nhập nhận HTTP 401.
  - `testDoPost_EmptyName_ReturnsBadRequest()`: Chứng minh lỗi rỗng tên công ty trả về HTTP 400.
  - `testDoPost_InvalidStatus_ReturnsBadRequest()`: Chứng minh trạng thái không hợp lệ trả về HTTP 400.

---

## 2.2. S30-03: Quản lý người liên hệ và vai trò trong quyết định mua hàng

### 2.2.1 Thông tin chức năng
- **Mã User Story**: S30-03.
- **Nhu cầu nghiệp vụ**: Mua hàng B2B có chu kỳ dài và nhiều người tham gia. Cần lưu trữ các đầu mối của khách hàng, xác định vai trò của từng cá nhân trong hội đồng mua hàng và theo dõi khi người liên hệ nhảy việc sang công ty khác.
- **Tiêu chí nghiệm thu (AC)**:
  1. Một khách hàng có nhiều người liên hệ (Quan hệ 1-N).
  2. Lưu trữ đầy đủ: Họ tên, Chức danh, Email, Số điện thoại, Vai trò mua hàng.
  3. Bốn vai trò mua hàng chuẩn: Người quyết định (`DECIDER`), Người ảnh hưởng (`INFLUENCER`), Người dùng cuối (`END_USER`), Người cản trở (`BLOCKER`).
  4. Đánh dấu đầu mối chính (`is_primary = 1`), mỗi khách hàng chỉ có tối đa 1 đầu mối chính tại một thời điểm.
  5. Chuyển người liên hệ sang công ty khác kèm lý do và lưu lịch sử vào bảng riêng.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.2.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/contact/ContactCreateServlet.java`: Tiếp nhận tạo mới Contact.
- `Backend/src/main/java/com/crm/controller/contact/ContactPrimaryServlet.java`: Đặt Contact làm đầu mối chính.
- `Backend/src/main/java/com/crm/controller/contact/ContactTransferServlet.java`: Chuyển Contact sang công ty khác.
- `Backend/src/main/java/com/crm/service/ContactService.java`: Logic nghiệp vụ, Transaction đổi công ty và đổi Primary Contact.
- `Backend/src/main/java/com/crm/dao/ContactDAO.java`: Tương tác bảng `contacts`.
- `Backend/src/main/java/com/crm/dao/ContactCompanyHistoryDAO.java`: Tương tác bảng `contact_company_history`.
- `Backend/src/main/webapp/WEB-INF/views/contacts/transfer.jsp`, `create.jsp`, `detail.jsp`, `list.jsp`: Giao diện Contact.

### 2.2.3 Luồng hoạt động từ đầu đến cuối
1. **Thiết lập Primary Contact (`POST /contacts/primary`)**:
   - `ContactPrimaryServlet.doPost()` nhận `contactId` và `customerId`.
   - `ContactService.setPrimaryContact()` khởi tạo transaction:
     ```java
     conn = DBConnection.getConnection();
     conn.setAutoCommit(false);
     contactDAO.resetPrimaryForCustomer(customerId, conn); // UPDATE contacts SET is_primary = 0 WHERE customer_id = ?
     contactDAO.setPrimary(contactId, customerId, conn);   // UPDATE contacts SET is_primary = 1 WHERE contact_id = ? AND customer_id = ?
     conn.commit();
     ```
   - Đảm bảo tính nguyên tử: không bao giờ xảy ra tình trạng có 2 Primary Contact hoặc mất Primary Contact nếu xảy ra lỗi giữa chừng.
2. **Chuyển công ty (`POST /contacts/transfer`)**:
   - `ContactTransferServlet.doPost()` nhận `contactId`, `newCustomerId`, `reason`.
   - `ContactService.transferContact()` kiểm tra quyền xem của user trên cả 2 công ty (cũ và mới).
   - Mở Transaction:
     1. Cập nhật `customer_id` mới trong bảng `contacts`.
     2. Ghi bản ghi lịch sử vào `contact_company_history` gồm: `contact_id`, `from_customer_id`, `to_customer_id`, `reason`, `transferred_by`.
     3. Gọi `conn.commit()`. Nếu bất kỳ bước nào lỗi, thực hiện `conn.rollback()`.

### 2.2.4 Database và SQL
- Bảng `contacts`: `contact_id` (PK), `customer_id` (FK), `contact_name`/`full_name`, `phone`, `email`, `position`/`title`, `buying_role`, `is_primary` (TINYINT 0/1).
- Bảng `contact_company_history`: `history_id` (PK), `contact_id` (FK), `from_customer_id` (FK), `to_customer_id` (FK), `reason` (TEXT), `transferred_by` (FK users), `transferred_at` (TIMESTAMP).

---

## 2.3. S30-04: Hồ sơ khách hàng 360 độ và dòng thời gian hoạt động

### 2.3.1 Thông tin chức năng
- **Mã User Story**: S30-04.
- **Nhu cầu nghiệp vụ**: Cung cấp cho ban giám đốc và nhân viên phụ trách cái nhìn đa chiều về một khách hàng: thông tin công ty, danh sách đầu mối, các cơ hội bán hàng đang theo đuổi, giá trị hợp đồng đã ký kết, dòng thời gian tương tác (gọi điện, gặp mặt, email) và tệp hợp đồng đính kèm.
- **Tiêu chí nghiệm thu (AC)**:
  1. Tổng hợp thông tin công ty, người liên hệ, cơ hội bán hàng, dòng thời gian hoạt động và tệp đính kèm trên cùng 1 trang.
  2. Tính toán tổng giá trị hợp đồng đã ký (`Signed Value`) từ các cơ hội ở giai đoạn thành công (`WON`).
  3. Tính toán tổng giá trị cơ hội đang mở (`Open Opportunities Value`).
  4. Phân trang dòng thời gian tương tác (Timeline activities).
  5. Bảo vệ phân quyền truy cập: Kiểm tra Data Scope trước khi tổng hợp dữ liệu.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.3.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/Customer360Servlet.java`: Controller chính cho trang Customer 360 (`/customers/360`).
- `Backend/src/main/java/com/crm/controller/customer/CustomerTimelineServlet.java`: Controller API phân trang dòng thời gian (`/customers/timeline`).
- `Backend/src/main/java/com/crm/service/Customer360Service.java`: Service trung tâm điều phối tổng hợp số liệu từ các DAO.
- `Backend/src/main/java/com/crm/dao/OpportunityDAO.java`: Tính toán giá trị cơ hội và doanh số ký kết.
- `Backend/src/main/java/com/crm/dao/ActivityDAO.java`: Truy vấn dòng thời gian hoạt động.
- `Backend/src/main/webapp/WEB-INF/views/customers/360.jsp`: View giao diện hiển thị thẻ thông số (KPI cards), bảng liên hệ, cơ hội và timeline.
- `Backend/src/test/java/com/crm/service/Customer360ServiceTest.java`: Unit test kiểm thử tính đúng đắn của logic tính tổng giá trị.

### 2.3.3 Luồng hoạt động từ đầu đến cuối
1. Người dùng bấm vào nút "Customer 360" tại danh sách khách hàng (`GET /customers/360?id=X`).
2. `Customer360Servlet.doGet()` trích xuất `customerId`, gọi `Customer360Service.getCustomer360(customerId, userId, roleIds)`.
3. Trong `Customer360Service`:
   - Xác thực Data Scope thông qua `permissionService.validateDataAccessForRoles()`.
   - Lấy thông tin khách hàng và danh sách liên hệ từ `CustomerDAO`.
   - Gọi `opportunityDAO.calculateTotalSignedAmount(customerId)`:
     ```sql
     SELECT COALESCE(SUM(o.amount), 0.0) FROM opportunities o 
     LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id 
     WHERE o.customer_id = ? AND (o.stage LIKE '%WON%' OR ps.stage_name LIKE '%Won%' OR ps.default_probability = 100);
     ```
   - Gọi `opportunityDAO.calculateTotalOpenAmount(customerId)` cho các cơ hội chưa đóng.
   - Gọi `relationshipDAO.getChildren(customerId)` để tính thêm doanh số từ các công ty con vào `GroupContractTotal`.
   - Đọc danh sách hoạt động từ `ActivityDAO` và tài liệu đính kèm từ bảng `attachments`.
4. Đóng gói vào đối tượng `Customer360Response` và forward sang `/WEB-INF/views/customers/360.jsp`.

---

## 2.4. S30-05: Phát hiện khách hàng trùng lặp và gộp hồ sơ

### 2.4.1 Thông tin chức năng
- **Mã User Story**: S30-05.
- **Nhu cầu nghiệp vụ**: Dữ liệu khách hàng nhập từ nhiều nguồn (web, nhân viên, import) dễ bị phân mảnh và trùng lặp. Hệ thống cần tự động phát hiện các cặp khách hàng nghi ngờ trùng và hỗ trợ người quản trị gộp 2 hồ sơ lại làm một, đồng thời chuyển toàn bộ dữ liệu giao dịch liên quan sang hồ sơ chính mà không làm mất mát lịch sử.
- **Tiêu chí nghiệm thu (AC)**:
  1. Phát hiện trùng theo 3 tiêu chí: Trùng mã số thuế, Trùng tên miền website, Tên công ty gần giống nhau (sau khi chuẩn hóa và loại bỏ tiền tố/hậu tố pháp lý).
  2. Giao diện so sánh song song 2 hồ sơ trước khi người dùng xác nhận gộp.
  3. Gộp hồ sơ bảo toàn 100% dữ liệu con: Người liên hệ, Cơ hội, Hoạt động, Tệp đính kèm, Lịch sử chuyển công ty, Ticket hỗ trợ, Giá trị trường động.
  4. Ghi nhận nhật ký gộp vào bảng `customer_merges`.
  5. Thực hiện toàn bộ quy trình gộp trong Transaction ACID với khả năng Rollback khi có lỗi.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.4.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerDuplicateServlet.java`: Hiển thị danh sách khách hàng trùng (`/customers/duplicates`).
- `Backend/src/main/java/com/crm/controller/customer/CustomerMergeServlet.java`: Hiển thị màn hình so sánh và tiếp nhận yêu cầu gộp (`/customers/merge`).
- `Backend/src/main/java/com/crm/service/CustomerMergeService.java`: Thuật toán so khớp chuỗi và logic transaction gộp 12 bước.
- `Backend/src/main/webapp/WEB-INF/views/customers/duplicates.jsp`: Giao diện danh sách trùng lặp.
- `Backend/src/main/webapp/WEB-INF/views/customers/merge.jsp`: Giao diện so sánh 2 cột trực quan (Primary vs Secondary).
- `Backend/src/test/java/com/crm/service/CustomerMergeServiceTest.java`: Unit test kiểm thử phát hiện trùng và rollback transaction.

### 2.4.3 Luồng hoạt động và Thuật toán so khớp
1. **Thuật toán so khớp tên công ty ([CustomerMergeService.java:120-153](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/service/CustomerMergeService.java#L120-L153))**:
   - Loại bỏ toàn bộ ký tự đặc biệt `[.,\\-()\\[\\]\\\"\\']`.
   - Loại bỏ các từ dừng doanh nghiệp (Stop words): *"công ty tnhh", "công ty cổ phần", "cty cp", "co., ltd", "corporation"...*
   - Kiểm tra chuỗi con chứa nhau nếu độ dài $\ge 4$ ký tự (ví dụ: "FPT Software" và "Công ty TNHH Phần mềm FPT" sau khi chuẩn hóa sẽ nhận diện được độ tương đồng).
2. **Transaction Gộp 12 bước ([CustomerMergeService.java:160-325](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/service/CustomerMergeService.java#L160-L325))**:
   - Mở connection: `conn.setAutoCommit(false)`.
   - Chuyển `customer_id` từ khách hàng phụ sang khách hàng chính lần lượt trên các bảng:
     1. `contacts`
     2. `attachments`
     3. `custom_field_values` (dùng `UPDATE IGNORE`, sau đó dọn dẹp các giá trị trùng thừa)
     4. `customer_relationships` (cả vai trò parent và child)
     5. `contact_company_history`
     6. `support_requests`
     7. `customer_care`
     8. `opportunities`
     9. `activities`
   - Ghi nhật ký vào bảng `customer_merges` (lưu JSON thông tin khách hàng phụ và người thực hiện).
   - Xóa khách hàng phụ khỏi bảng `customers`.
   - Thực thi `conn.commit()`. Bất kỳ lỗi SQL nào xảy ra sẽ kích hoạt `conn.rollback()`.

---

## 2.5. S30-06: Quản lý quan hệ công ty mẹ – công ty con

### 2.5.1 Thông tin chức năng
- **Mã User Story**: S30-06.
- **Nhu cầu nghiệp vụ**: Doanh nghiệp lớn thường hoạt động theo mô hình tập đoàn (Tập đoàn mẹ sở hữu nhiều công ty con, chi nhánh thành viên). Hệ thống cần liên kết các hồ sơ này để quản lý doanh số tổng của toàn tập đoàn.
- **Tiêu chí nghiệm thu (AC)**:
  1. Cho phép liên kết một khách hàng làm công ty con (`child`) của một công ty mẹ (`parent`).
  2. Ngăn chặn liên kết không hợp lệ: Không thể tự liên kết với chính mình (`parentId == childId`).
  3. Ngăn chặn quan hệ vòng (Cycle Detection): Nếu A là cha của B, B là cha của C thì không thể gắn A làm con của C.
  4. Hiển thị tổng giá trị hợp đồng của toàn bộ nhóm công ty (Tập đoàn mẹ + các công ty con) trên màn hình Customer 360.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.5.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerHierarchyServlet.java`: Controller quản lý cấu trúc cây khách hàng (`/customers/hierarchy`).
- `Backend/src/main/java/com/crm/service/CustomerHierarchyService.java`: Logic kiểm tra đệ quy chống quan hệ vòng.
- `Backend/src/main/java/com/crm/dao/CustomerRelationshipDAO.java`: Thao tác bảng `customer_relationships`.
- `Backend/src/main/webapp/WEB-INF/views/customers/hierarchy.jsp`: Giao diện cây phân cấp tổ chức.

### 2.5.3 Logic kiểm tra chống quan hệ vòng (Cycle Detection)
Tại [CustomerHierarchyService.java:24-43](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/service/CustomerHierarchyService.java#L24-L43):
```java
// Kiểm tra xem childId đã là tổ tiên (Ancestor) của parentId hay chưa
if (isAncestor(childId, parentId, new java.util.HashSet<>())) {
    return false; // Ngăn chặn tạo vòng lặp
}

private boolean isAncestor(int targetAncestorId, int currentId, java.util.Set<Integer> visited) {
    if (targetAncestorId == currentId) return true;
    if (!visited.add(currentId)) return false; // Tránh lặp vô tận nếu DB đã tồn tại chu trình lỗi
    List<CustomerRelationship> parents = getParents(currentId);
    for (CustomerRelationship rel : parents) {
        if (isAncestor(targetAncestorId, rel.getParentCustomerId(), visited)) {
            return true;
        }
    }
    return false;
}
```

---

## 2.6. S30-07: Import khách hàng từ Excel

### 2.6.1 Thông tin chức năng
- **Mã User Story**: S30-07.
- **Nhu cầu nghiệp vụ**: Khi triển khai hệ thống mới hoặc nhận danh sách từ chiến dịch marketing, nhân viên cần tải danh sách hàng nghìn khách hàng từ file Excel (.xlsx / .csv) vào hệ thống một cách nhanh chóng, an toàn và có kiểm soát chất lượng dữ liệu.
- **Tiêu chí nghiệm thu (AC)**:
  1. Cho phép tải file mẫu Excel chuẩn (`/customers/import/template`).
  2. Đọc và kiểm tra từng dòng (Row validation): tên công ty bắt buộc, định dạng email, số điện thoại hợp lệ.
  3. Báo cáo chi tiết danh sách lỗi theo từng số dòng cụ thể.
  4. Phát hiện bản ghi trùng lặp trong file và trùng lặp với CSDL hiện có.
  5. Cho phép người dùng lựa chọn chế độ xử lý bản ghi trùng: Bỏ qua (`SKIP`) hoặc Cập nhật thông tin mới (`UPDATE`).
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.6.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerImportServlet.java`: Controller xử lý tải template, upload file và preview kết quả.
- `Backend/src/main/java/com/crm/service/CustomerImportService.java`: Logic kiểm tra trùng lặp trong file/DB và thực thi import hàng loạt trong Transaction.
- `Backend/src/main/java/com/crm/service/ImportExcelService.java`: Service phân tích cấu trúc file Excel bằng Apache POI.
- `Backend/src/main/webapp/WEB-INF/views/customers/import.jsp`, `import-preview.jsp`: Giao diện upload và xem trước kết quả hợp lệ/không hợp lệ trước khi lưu.
- `Backend/src/test/java/com/crm/service/CustomerImportServiceTest.java`: Unit test kiểm thử preview và xử lý trùng.

### 2.6.3 Luồng chạy thực tế
1. **Bước 1 (Upload & Preview)**: User upload file Excel tại `POST /customers/import/preview` $\rightarrow$ `ImportExcelService` dùng Apache POI đọc từng dòng tạo thành danh sách `CustomerImportRequest`.
2. `CustomerImportService.validatePreview()` duyệt qua từng dòng:
   - Dùng `Set<String> phonesInFile` và `taxCodesInFile` để phát hiện trùng nội bộ file.
   - Gọi `customerDAO.findDuplicateCustomer()` để phát hiện trùng với DB.
   - Trả về cấu trúc JSON gồm: `validRows`, `invalidRows`, `duplicates`, `rowErrors`.
3. **Bước 2 (Execute)**: User chọn hành động (`SKIP` hoặc `UPDATE`) và bấm "Xác nhận Import" (`POST /customers/import/execute`).
   - `CustomerImportService.executeImport()` mở transaction DB: thực hiện chèn các bản ghi hợp lệ hoặc cập nhật bản ghi trùng tùy theo cờ hành động.

---

## 2.7. S30-08: Tìm kiếm, lọc và lưu bộ lọc khách hàng

### 2.7.1 Thông tin chức năng
- **Mã User Story**: S30-08.
- **Nhu cầu nghiệp vụ**: Danh sách khách hàng rất lớn. Người dùng cần tìm kiếm nhanh đa trường, lọc kết hợp nhiều tiêu chí và có thể lưu lại các tiêu chí lọc thường dùng để tải lại nhanh chỉ bằng một cú nhấp chuột.
- **Tiêu chí nghiệm thu (AC)**:
  1. Lọc theo nhiều tiêu chí kết hợp: Trạng thái, Ngành nghề, Quy mô công ty, Khu vực, Người phụ trách.
  2. Tìm kiếm từ khóa: Tên công ty, Mã số thuế, Số điện thoại.
  3. Lọc theo trường mở rộng tùy chỉnh (Custom Fields).
  4. Lưu tiêu chí lọc cá nhân vào CSDL và cho phép chọn làm bộ lọc mặc định.
  5. Đảm bảo toàn vẹn phân quyền dữ liệu: Bộ lọc chỉ được tìm kiếm trong phạm vi dữ liệu mà user được phép xem.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.7.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerFilterServlet.java`: Controller CRUD bộ lọc cá nhân (`/customers/filters`).
- `Backend/src/main/java/com/crm/controller/customer/CustomerListServlet.java`: Tích hợp tiếp nhận tham số lọc vào trang danh sách.
- `Backend/src/main/java/com/crm/service/CustomerFilterService.java`: Điều phối lọc kết hợp quyền Data Scope.
- `Backend/src/main/java/com/crm/dao/SavedFilterDAO.java`: Lưu trữ và đọc bộ lọc từ bảng `saved_filters`.
- `Backend/src/main/webapp/WEB-INF/views/customers/saved-filters.jsp`: Giao diện quản lý các bộ lọc đã lưu.
- `Backend/src/test/java/com/crm/service/CustomerFilterServiceTest.java`: Unit test kiểm thử logic gán điều kiện lọc và lưu bộ lọc.

### 2.7.3 Cơ chế SQL động an toàn
Tại `CustomerDAO.java:200-224`, câu lệnh SQL được xây dựng động bằng `StringBuilder` với tham số hóa 100% qua `PreparedStatement`:
```java
StringBuilder sql = new StringBuilder("SELECT DISTINCT c.*, u.full_name AS owner_name FROM customers c LEFT JOIN users u ON c.owner_id = u.user_id WHERE 1=1");
List<Object> params = new ArrayList<>();
// Ghép điều kiện từ khóa, ngành nghề, quy mô...
buildFilterWhereClause(sql, params, filterReq, ownerIds);
// Phân trang
sql.append(" ORDER BY c.customer_id DESC LIMIT ? OFFSET ?");
params.add(pageSize);
params.add((page - 1) * pageSize);
```
Không nối chuỗi trực tiếp giá trị người dùng nhập vào câu SQL $\rightarrow$ Loại bỏ hoàn toàn nguy cơ tấn công SQL Injection.

---

## 2.8. S30-09: Quản lý yêu cầu hỗ trợ và cảnh báo rủi ro khách hàng

### 2.8.1 Thông tin chức năng
- **Mã User Story**: S30-09.
- **Nhu cầu nghiệp vụ**: Để giữ chân khách hàng (Customer Retention), hệ thống cần phát hiện sớm các dấu hiệu bất mãn của khách hàng dựa trên số lượng yêu cầu hỗ trợ (Support Ticket) chưa được xử lý để cảnh báo rủi ro rời bỏ (Churn Risk).
- **Tiêu chí nghiệm thu (AC)**:
  1. Ghi nhận và quản lý yêu cầu hỗ trợ: Mức độ ưu tiên (`LOW`, `MEDIUM`, `HIGH`, `URGENT`), Trạng thái (`OPEN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`), Người phụ trách.
  2. Quy tắc cảnh báo rủi ro rời bỏ:
     - Khách hàng có **bất kỳ yêu cầu nào ở mức khẩn cấp (`URGENT`)** đang chưa xử lý (`OPEN` hoặc `IN_PROGRESS`).
     - Hoặc khách hàng có **từ 3 yêu cầu tồn đọng trở lên** (`pending tickets >= 3`).
  3. Cờ rủi ro (`riskFlag = true`) và lý do cụ thể được hiển thị trực tiếp trên danh sách khách hàng và trang chi tiết.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.8.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerSupportServlet.java`: Quản lý yêu cầu hỗ trợ (`/customers/support`).
- `Backend/src/main/java/com/crm/controller/customer/CustomerRiskServlet.java`: Hiển thị phân tích rủi ro (`/customers/risk`).
- `Backend/src/main/java/com/crm/service/CustomerSupportService.java`: Xử lý tạo và cập nhật ticket hỗ trợ.
- `Backend/src/main/java/com/crm/service/CustomerRiskService.java`: Logic tính toán ngưỡng rủi ro.
- `Backend/src/main/java/com/crm/dao/CustomerRiskDAO.java`: Truy vấn đếm số lượng ticket pending và ticket urgent trong DB.
- `Backend/src/main/webapp/WEB-INF/views/customers/risks.jsp`, `support.jsp`: Giao diện cảnh báo rủi ro và quản lý ticket.
- `Backend/src/test/java/com/crm/service/CustomerSupportAndRiskServiceTest.java`: Unit test kiểm thử tính toán cờ rủi ro.

### 2.8.3 Logic tính toán cờ rủi ro ([CustomerRiskDAO.java:53-72](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/dao/CustomerRiskDAO.java#L53-L72))
```java
public CustomerRisk calculateRisk(int customerId, int threshold) {
    int pending = countPendingTickets(customerId);
    int urgent = countUrgentPendingTickets(customerId);
    if (urgent > 0) {
        return new CustomerRisk(customerId, true, "Khách hàng có " + urgent + " yêu cầu hỗ trợ khẩn cấp (URGENT) chưa được giải quyết.", pending, threshold);
    } else if (pending >= threshold) {
        return new CustomerRisk(customerId, true, "Khách hàng có " + pending + " yêu cầu hỗ trợ tồn đọng (vượt ngưỡng cho phép: " + threshold + ").", pending, threshold);
    } else {
        return new CustomerRisk(customerId, false, "Mức độ hài lòng ổn định (" + pending + " yêu cầu đang xử lý, dưới ngưỡng " + threshold + ").", pending, threshold);
    }
}
```

---

## 2.9. S30-10: Lập danh sách khách hàng cần chăm sóc định kỳ

### 2.9.1 Thông tin chức năng
- **Mã User Story**: S30-10.
- **Nhu cầu nghiệp vụ**: Duy trì tương tác định kỳ để tái ký hợp đồng và bán thêm (Up-sell/Cross-sell). Hệ thống tự động lọc ra các khách hàng lâu ngày không có tương tác, sắp xếp theo giá trị hợp đồng để nhân viên ưu tiên chăm sóc khách hàng VIP trước.
- **Tiêu chí nghiệm thu (AC)**:
  1. Tự động tìm kiếm các khách hàng không có tương tác trong $N$ ngày gần nhất (với $N$ có thể cấu hình linh hoạt, mặc định là 30 ngày).
  2. Sắp xếp danh sách giảm dần theo tổng giá trị hợp đồng đã ký (`ORDER BY contract_value DESC`).
  3. Cho phép nhân viên bấm "Đánh dấu đã liên hệ", nhập ghi chú kết quả tương tác để reset lại chu kỳ chăm sóc.
  4. Lưu trữ lịch sử mốc chăm sóc trong bảng `customer_care`.
- **Trạng thái triển khai**: **Hoàn thành theo bằng chứng source code**.

### 2.9.2 Cây file liên quan
- `Backend/src/main/java/com/crm/controller/customer/CustomerCareServlet.java`: Controller danh sách chăm sóc và cấu hình số ngày (`/customers/care`).
- `Backend/src/main/java/com/crm/service/CustomerCareService.java`: Logic tính ngưỡng ngày và ghi nhận mốc liên hệ.
- `Backend/src/main/java/com/crm/dao/CustomerCareDAO.java`: Truy vấn SQL tính toán số ngày không tương tác và tổng giá trị hợp đồng.
- `Backend/src/main/webapp/WEB-INF/views/customers/care-list.jsp`: Giao diện danh sách chăm sóc định kỳ kèm modal ghi chú.
- `Backend/src/test/java/com/crm/service/CustomerCareServiceTest.java`: Unit test kiểm thử logic tính ngày và ghi nhận liên hệ.

### 2.9.3 Câu truy vấn SQL phức hợp cốt lõi ([CustomerCareDAO.java:113-138](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/dao/CustomerCareDAO.java#L113-L138))
```sql
SELECT c.customer_id, c.customer_name, c.phone, c.owner_id, u.full_name AS owner_name,
       cc.last_contacted_at,
       TIMESTAMPDIFF(DAY, COALESCE(cc.last_contacted_at, c.created_at), CURRENT_TIMESTAMP) AS days_inactive,
       COALESCE((
           SELECT SUM(o.amount) FROM opportunities o 
           LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id 
           WHERE o.customer_id = c.customer_id AND (
               o.stage LIKE '%WON%' OR ps.stage_name LIKE '%Won%' OR ps.default_probability = 100
           )
       ), 0.0) AS contract_value
FROM customers c
LEFT JOIN users u ON c.owner_id = u.user_id
LEFT JOIN customer_care cc ON c.customer_id = cc.customer_id
WHERE TIMESTAMPDIFF(DAY, COALESCE(cc.last_contacted_at, c.created_at), CURRENT_TIMESTAMP) >= ?
  AND c.owner_id IN (...)
ORDER BY contract_value DESC, days_inactive DESC, c.customer_id ASC
LIMIT ? OFFSET ?;
```
- Sử dụng hàm `TIMESTAMPDIFF(DAY, ...)` để tính khoảng cách ngày chính xác theo thời gian thực.
- Sử dụng `COALESCE` thông minh: nếu khách hàng chưa từng được chăm sóc (`cc.last_contacted_at IS NULL`), mốc tính thời gian sẽ lấy từ ngày tạo khách hàng (`c.created_at`).

---

# PHẦN III. SO SÁNH VÀ LIÊN KẾT GIỮA CÁC USER STORY

### 3.1 Bảng dữ liệu dùng chung và Mối quan hệ liên kết
```
                 ┌──────────────────────────┐
                 │       users (BE3)        │
                 └─────────────┬────────────┘
                               │ 1:N (owner_id)
                               ▼
 ┌────────────────────────────────────────────────────────┐
 │                    CUSTOMERS (S30-02)                  │
 └──────┬────────────┬─────────────┬───────────┬──────────┘
        │ 1:N        │ 1:N         │ 1:N       │ 1:1
        ▼            ▼             ▼           ▼
┌──────────────┐ ┌──────────────┐ ┌─────────┐ ┌──────────────┐
│  contacts    │ │opportunities │ │activities││customer_care │
│  (S30-03)    │ │  (S30-04)    │ │(S30-04) │ │  (S30-10)    │
└───────┬──────┘ └──────────────┘ └─────────┘ └──────────────┘
        │ 1:N
        ▼
┌──────────────────────────────┐
│ contact_company_history      │
│          (S30-03)            │
└──────────────────────────────┘
```

1. **Khách hàng (`customers`) và Người liên hệ (`contacts`)**:
   - Khóa ngoại `contacts.customer_id` trỏ tới `customers.customer_id` với thuộc tính `ON DELETE CASCADE`.
   - Khi gộp khách hàng (S30-05), toàn bộ người liên hệ của công ty phụ được chuyển giao sang công ty chính trước khi công ty phụ bị xóa.
2. **Khách hàng 360 độ (S30-04) là điểm hội tụ**:
   - Tổng hợp dữ liệu từ S30-02 (thông tin chung), S30-03 (người liên hệ), S30-06 (công ty con và tổng doanh số nhóm), S30-09 (cảnh báo rủi ro từ support tickets), và các phân hệ Cơ hội/Hoạt động.
3. **Phân quyền dữ liệu (BE3) bảo vệ xuyên suốt**:
   - `PermissionService` được tiêm (inject) vào toàn bộ các Service của Sprint 03: `CustomerFilterService`, `ContactService`, `Customer360Service`, `CustomerCareService`, `CustomerRiskService`.
   - Mọi thao tác đọc, sửa, xóa đều được lọc hoặc kiểm tra qua `validateDataAccessForRoles()`.

---

# PHẦN IV. TỔNG HỢP TRẠNG THÁI TRIỂN KHAI SPRINT 03

### 4.1 Bảng tổng kết trạng thái
| User Story | Mức độ triển khai | Bằng chứng code chính | Bằng chứng Test | Ghi chú & Giới hạn |
|---|---|---|---|---|
| **S30-02** | Hoàn thành | `CustomerSaveServlet`, `CustomerDAO` | `CustomerSaveServletTest` | CSDL chưa có UNIQUE index trên `tax_code` |
| **S30-03** | Hoàn thành | `ContactService`, `ContactTransferServlet` | Kiểm tra luồng Transaction | Đầy đủ 4 vai trò mua, chuyển công ty lưu lịch sử |
| **S30-04** | Hoàn thành | `Customer360Service`, `Customer360Servlet` | `Customer360ServiceTest` | Tổng hợp KPI, doanh số ký kết và doanh số nhóm |
| **S30-05** | Hoàn thành | `CustomerMergeService`, `merge.jsp` | `CustomerMergeServiceTest` | Transaction gộp 12 bước, chuẩn hóa tên tiếng Việt |
| **S30-06** | Hoàn thành | `CustomerHierarchyService` | Logic đệ quy `isAncestor` | Chống quan hệ vòng lặp và tự trỏ chính mình |
| **S30-07** | Hoàn thành | `CustomerImportService`, Apache POI | `CustomerImportServiceTest` | Báo lỗi theo dòng, hỗ trợ SKIP / UPDATE |
| **S30-08** | Hoàn thành | `CustomerFilterService`, `SavedFilterDAO`| `CustomerFilterServiceTest` | Lưu bộ lọc cá nhân, SQL param hóa 100% |
| **S30-09** | Hoàn thành | `CustomerRiskService`, `CustomerRiskDAO` | `CustomerSupportAndRiskServiceTest` | Cảnh báo khi có vé URGENT hoặc $\ge 3$ vé tồn |
| **S30-10** | Hoàn thành | `CustomerCareService`, `CustomerCareDAO` | `CustomerCareServiceTest` | Lọc $N$ ngày không tương tác, sort theo hợp đồng |

### 4.2 Đánh giá rủi ro và khuyến nghị cải thiện
1. **Thiếu ràng buộc UNIQUE mức CSDL**: Cột `tax_code` trong bảng `customers` chỉ được kiểm tra ở mức code Java. Cần bổ sung `ALTER TABLE customers ADD UNIQUE (tax_code);` để ngăn chặn race condition.
2. **Quản lý Transaction trong Service**: Một số thao tác ở `CustomerSaveServlet` gọi trực tiếp DAO mà không qua Service. Khuyến nghị chuẩn hóa toàn bộ lời gọi qua Service để đảm bảo tính nhất quán kiến trúc.
3. **Dropdown người sở hữu trên giao diện**: Form tạo mới khách hàng `create.jsp` cần thay thế `<input type="number">` bằng `<select>` danh sách nhân viên lấy từ `AccountDAO`.

---

# PHẦN V. BỘ TÀI LIỆU ÔN TẬP VÀ KỊCH BẢN BẢO VỆ

### 5.1 Kịch bản trình bày tổng quan Sprint 03 (5-7 phút)
> *"Kính thưa Hội đồng và Mentor, trong Sprint 03, nhóm em chịu trách nhiệm triển khai toàn bộ phân hệ **Quản lý Khách hàng Doanh nghiệp (B2B)**. Hệ thống được xây dựng trên nền tảng Java Servlet thuần, JDBC và MySQL, tuân thủ mô hình MVC 2.*
> 
> *Điểm nổi bật trong Sprint 03 của chúng em bao gồm 3 trục giá trị chính:*
> 1. * **Bảo mật và Phân quyền chặt chẽ**: Toàn bộ dữ liệu khách hàng được kiểm soát bởi cơ chế **Data Scope (MY / TEAM / ALL)** từ module BE3. Nhân viên kinh doanh chỉ nhìn thấy khách hàng của mình, Trưởng nhóm quản lý khách hàng của cả nhóm, và hệ thống tự động chặn các cuộc tấn công đoán ID trên URL bằng mã lỗi HTTP 403.
> 2. * **Toàn vẹn và Chất lượng dữ liệu**: Chúng em đã triển khai thuật toán phát hiện trùng lặp thông minh (chuẩn hóa tên doanh nghiệp, loại bỏ từ dừng pháp lý), hỗ trợ quy trình gộp hồ sơ trong một **Database Transaction 12 bước an toàn**, bảo toàn toàn bộ hợp đồng, liên hệ và tài liệu đính kèm. Ngoài ra, tính năng Import Excel hỗ trợ xem trước, báo lỗi theo dòng và tự động phát hiện trùng lặp.
> 3. * **Góc nhìn 360 độ và Giữ chân khách hàng**: Màn hình Customer 360 tổng hợp trực quan toàn bộ lịch sử tương tác, giá trị hợp đồng đã ký và doanh số của toàn tập đoàn. Hệ thống chủ động tính toán cờ rủi ro rời bỏ (Churn Risk) dựa trên ticket hỗ trợ khẩn cấp, đồng thời tự động lập danh sách khách hàng cần chăm sóc định kỳ sau $N$ ngày không tương tác, ưu tiên theo giá trị hợp đồng.*
> 
> *Sau đây, em xin phép trình bày chi tiết code thực tế của từng chức năng..."*

### 5.2 25 Câu hỏi sát thực tế Mentor thường hỏi & Câu trả lời chuẩn

#### Nhóm 1: Kiến trúc, Luồng và Phân quyền (BE3)
1. **Mentor hỏi**: *"Tại sao em không dùng Spring Boot hay Hibernate mà lại dùng Servlet thuần và JDBC?"*
   - **Trả lời**: *"Dạ, việc sử dụng Servlet thuần và JDBC giúp chúng em hiểu sâu sắc về chu kỳ sống của Request/Response, cách hoạt động của Servlet Filter, cơ chế quản lý Transaction ở mức Connection cơ bản, và kiểm soát tuyệt đối các câu lệnh SQL để tối ưu hiệu năng mà không phụ thuộc vào tầng trừu tượng ORM."*
2. **Mentor hỏi**: *"Làm sao em ngăn chặn việc nhân viên Sales xem trộm khách hàng của đồng nghiệp khác?"*
   - **Trả lời**: *"Dạ, ở tầng danh sách, `CustomerDAO` tự động thêm điều kiện `AND c.owner_id IN (...)` dựa trên danh sách ID được phép của `PermissionService`. Ở tầng xem chi tiết, `CustomerDetailServlet` gọi `permissionService.validateDataAccessForRoles()`. Nếu `ownerId` của khách hàng không hợp lệ, hệ thống ném `AuthorizationException` và trả về `403 Forbidden` ngay lập tức."*
3. **Mentor hỏi**: *"Filter nào chạy trước trong chuỗi Filter của em?"*
   - **Trả lời**: *"Dạ, theo cấu hình trong `web.xml`, thứ tự chạy là: `EncodingFilter` (UTF-8) $\rightarrow$ `AuthenticationFilter` (kiểm tra session đăng nhập) $\rightarrow$ `AuthorizationFilter` (kiểm tra quyền URL và Data Scope)."*

#### Nhóm 2: Logic nghiệp vụ & Transaction
4. **Mentor hỏi**: *"Khi em gộp 2 khách hàng, nếu giữa chừng câu lệnh chuyển cơ hội (opportunities) bị lỗi thì chuyện gì xảy ra?"*
   - **Trả lời**: *"Dạ, trong `CustomerMergeService.mergeCustomers()`, em thiết lập `conn.setAutoCommit(false)`. Nếu có lỗi SQL ở bất kỳ bước nào, khối `catch` sẽ kích hoạt `conn.rollback()`. Toàn bộ dữ liệu của cả 2 khách hàng sẽ được giữ nguyên trạng thái ban đầu, không bị mất mát hay đứt gãy khóa ngoại."*
5. **Mentor hỏi**: *"Tại sao em phải có bảng `contact_company_history`?"*
   - **Trả lời**: *"Dạ, trong B2B, người liên hệ chuyển từ công ty A sang công ty B là rất phổ biến. Nếu chỉ cập nhật đè `customer_id` trong bảng `contacts`, chúng ta sẽ làm mất ngữ cảnh các giao dịch cũ mà người đó từng đại diện ở công ty cũ. Do đó em cập nhật `customer_id` mới đồng thời ghi nhận một bản ghi lịch sử vào `contact_company_history` trong cùng một Transaction."*
6. **Mentor hỏi**: *"Làm sao em ngăn chặn khách hàng A là cha của B, B lại là cha của A?"*
   - **Trả lời**: *"Dạ, trong `CustomerHierarchyService.addRelationship()`, trước khi thêm quan hệ, em chạy thuật toán đệ quy `isAncestor()` sử dụng một `Set<Integer> visited` để kiểm tra chu trình. Nếu công ty con đã là tổ tiên của công ty cha thì hàm sẽ từ chối thêm và trả về `false`."*

#### Nhóm 3: SQL và Cơ sở dữ liệu
7. **Mentor hỏi**: *"Trong câu truy vấn Chăm sóc định kỳ (S30-10), nếu khách hàng chưa từng được liên hệ bao giờ thì em tính số ngày không tương tác thế nào?"*
   - **Trả lời**: *"Dạ, em dùng hàm `COALESCE(cc.last_contacted_at, c.created_at)` trong câu lệnh SQL tại `CustomerCareDAO`. Nếu chưa có ngày chăm sóc trong `customer_care`, hệ thống sẽ lấy ngày tạo khách hàng `created_at` làm mốc để tính `TIMESTAMPDIFF(DAY, ..., CURRENT_TIMESTAMP)`."*
8. **Mentor hỏi**: *"Mã số thuế có được đảm bảo duy nhất ở tầng Database chưa?"*
   - **Trả lời**: *"Dạ, em xin trung thực thừa nhận là hiện tại mã số thuế đang được kiểm tra duy nhất ở tầng ứng dụng Java thông qua `customerDAO.isTaxCodeExists()`. Trong schema MySQL hiện tại chưa có ràng buộc `UNIQUE` cho cột `tax_code`. Để hoàn thiện hơn khi có tải đồng thời cao, em cần bổ sung thêm `UNIQUE INDEX` ở database."*

### 5.3 Checklist tự kiểm tra trước giờ bảo vệ
- [x] Đã khởi động Tomcat và xác nhận giao diện hoạt động tại `http://localhost:8080/crm-backend-1.0.0/`.
- [x] Đã chuẩn bị tài khoản test tương ứng từng vai trò: Admin (`admin@company.com`), Trưởng nhóm (`teamlead.test@example.com`), Nhân viên (`salesrep.test@example.com`).
- [x] Nhớ vị trí các transaction quan trọng: `CustomerMergeService:160` (Merge), `ContactService:100` (Primary Contact), `ContactService:280` (Transfer Contact).
- [x] Nhớ vị trí câu truy vấn SQL phức hợp: `CustomerCareDAO:113` (Chăm sóc định kỳ), `OpportunityDAO:calculateTotalSignedAmount` (Doanh số Customer 360).
- [x] Nắm vững các điểm hạn chế cần thừa nhận trung thực để ghi điểm chuyên nghiệp với Mentor.
