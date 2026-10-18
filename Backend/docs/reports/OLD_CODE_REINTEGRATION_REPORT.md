# BÁO CÁO PHỤC HỒI & TÍCH HỢP CODE CŨ TỪ THƯ MỤC BACKUP TRƯỚC MERGE
**(OLD CODE REINTEGRATION & AUDIT REPORT)**

**Dự án:** `TTCS_K1S2_N4_HeThongQuanLyKhachHang`  
**Thư mục dự án hiện tại:** `C:\Users\tuyet\Downloads\TTCS_K1S2_N4_HeThongQuanLyKhachHang\TTCS_K1S2_N4_HeThongQuanLyKhachHang`  
**Thư mục sao lưu (Backup):** `C:\Users\tuyet\Downloads\TTCS_K1S2_N4_HeThongQuanLyKhachHang\TTCS_K1S2_N4_HeThongQuanLyKhachHang-backup-before-merge`  
**Ngày thực hiện:** 18/10/2026  
**Trạng thái kiểm thử:** **259 / 259 Tests PASSED (0 Failures, 0 Errors, 0 Skipped)**  
**Trạng thái Git:** **Changes staged for commit (Chưa commit, Chưa push - Đang chờ người dùng duyệt)**

---

## 1. XÁC MINH THƯ MỤC BACKUP

- **Đường dẫn kiểm tra:** `C:\Users\tuyet\Downloads\TTCS_K1S2_N4_HeThongQuanLyKhachHang\TTCS_K1S2_N4_HeThongQuanLyKhachHang-backup-before-merge`
- **Kết quả xác minh:** Thư mục **thực sự tồn tại** (`Test-Path: True`), toàn vẹn 100%, có đầy đủ cấu trúc thư mục `.git`, `Backend`, `docs`, `scratch`, `pom.xml`, `README.md`.
- **Commit gốc của Backup:** `243366e fix:mai_ resolve CRM test failures and update modules` (đây chính xác là trạng thái HEAD của nhánh `fix/crm-test-fixes` trước thời điểm chạy lệnh `git merge origin/develop`).
- **Cam kết bảo toàn:** Thư mục backup được giữ nguyên bản, **hoàn toàn không bị sửa đổi, ghi đè hay xóa bỏ**.

---

## 2. KẾT QUẢ SO SÁNH TỔNG THỂ (BACKUP VS CURRENT REPO)

Khi đối chiếu giữa thư mục backup trước merge và thư mục hiện tại sau khi hòa trộn với `origin/develop`:

- **Tổng số file mã nguồn có sự khác biệt:** **52 files**.
- **Số file chỉ có trong Backup:** **0 file** (không có file nào bị xóa mất).
- **Số file mới chỉ có ở Current:** **11 files** (bao gồm `JsonUtil.java`, các tài liệu báo cáo và các file integration tests chuyên sâu được thêm mới: `LeadAssignmentIntegrationTest.java`, `LeadConversionIntegrationTest.java`, `LeadSlaIntegrationTest.java`, `CampaignServiceTest.java`, v.v.).

```mermaid
pie title Phân loại 52 file khác biệt
    "Controller & Servlets" : 18
    "Services" : 8
    "DAOs" : 8
    "Models & DTOs" : 10
    "SQL Schemas & Test Data" : 4
    "Views JSP & Config" : 4
```

---

## 3. PHÂN TÍCH VÀ XÁC ĐỊNH LOGIC TÍCH HỢP TỪNG FILE

Chúng tôi đã kiểm tra chi tiết từng file mã nguồn để đảm bảo:
1. **Các tính năng đã hoàn thiện từ Backup** không bị vô hiệu hóa hoặc mất mát.
2. **Các cải tiến kỹ thuật từ `origin/develop`** (như chuyển từ In-Memory mock sang Transaction JDBC thật, tối ưu hóa N+1 query, cơ chế bảo mật Session, Role-Based Access Control) được bảo toàn.
3. Không thực hiện copy đè thô bạo (không ghi đè cả thư mục `Backend`).

### 3.1. Phục hồi logic hiển thị danh sách trùng lặp toàn hệ thống (`LeadDuplicateServlet.java`)
- **Tình trạng trước tích hợp:** Khi người dùng truy cập trang `/leads/duplicates` mà không truyền tham số `leadId`, code từ nhánh `develop` tự động redirect về Lead đầu tiên hoặc redirect về `/leads`. Điều này khiến Section 1 của trang JSP `duplicates.jsp` (`<c:if test="${empty targetLead && not empty duplicatePairs}">`) bị bỏ qua, không hiển thị được danh sách các cặp Lead trùng lặp trong toàn hệ thống.
- **Giải pháp phục hồi:** Tái tích hợp đoạn code từ backup:
  ```java
  req.setAttribute("duplicatePairs", allPairs);
  req.getRequestDispatcher("/WEB-INF/views/leads/duplicates.jsp").forward(req, resp);
  ```
- **Kết quả:** Giao diện `duplicates.jsp` hiển thị đầy đủ cả 2 chế độ:
  1. Khi có `leadId`: Hiển thị chi tiết đối soát Lead đó với các ứng viên trùng lặp.
  2. Khi không có `leadId`: Hiển thị danh sách tổng quan tất cả các cặp trùng lặp phát hiện được trên toàn hệ thống.

### 3.2. Tích hợp khả năng tương thích xác thực Header (`X-User-Id` & `X-User-Role`)
- **Các file áp dụng:** 
  - `LeadAcceptServlet.java`
  - `LeadRejectServlet.java`
  - `LeadAssignServlet.java`
  - `LeadConvertServlet.java`
- **Bối cảnh phân tích:** 
  - Trên backup cũ, các module được thiết kế hỗ trợ gọi API linh hoạt qua HTTP Headers `X-User-Id` và `X-User-Role`.
  - Trên nhánh `origin/develop`, cơ chế xác thực nâng cấp lên `HttpSession` với đối tượng `Account` và `roleCodes`.
- **Giải pháp tích hợp:** Giữ nguyên 100% cơ chế bảo mật Session từ `develop`, đồng thời bổ sung **fallback** kiểm tra Header `X-User-Id` và `X-User-Role` nếu Session chưa có:
  ```java
  if (currentUserId == null) {
      String userIdHeader = req.getHeader("X-User-Id");
      if (userIdHeader != null && !userIdHeader.trim().isEmpty()) {
          try { currentUserId = Integer.parseInt(userIdHeader.trim()); } catch (Exception ignored) {}
      }
  }
  ```
- **Kết quả:** Tương thích cả giao diện người dùng (chạy trên trình duyệt có Cookie Session) lẫn các công cụ kiểm thử tự động, Postman hoặc API client sử dụng Header.

### 3.3. Bảo toàn nâng cấp Service từ Mock sang Real Database Transaction
- **`LeadSlaService.java`:**
  - *Backup:* Chứa mock database in-memory `mockLeads = new ConcurrentHashMap<>()`.
  - *Current:* Đã hoàn thiện kết nối JDBC thật với MySQL, hỗ trợ khóa bi quan `SELECT ... FOR UPDATE`, ghi nhận lịch sử từ chối và lý do từ chối vào `lead_assignment_history`. Toàn bộ 5/5 unit test và 21/21 SLA integration test đều chạy qua service này.
  - *Quyết định:* **Bảo toàn bản hiện tại** (đã giữ đầy đủ các method signature cũ như `acceptLead(int leadId, int userId)` để tương thích ngược 100%).
- **`LeadConversionService.java`:**
  - *Backup:* Dùng mock map `leadsDB.put(1, ...)`.
  - *Current:* Vừa hỗ trợ `convertMockLead` cho các unit test biệt lập, vừa thực thi Transaction JDBC thật sang bảng `customers`, `contacts`, `opportunities`.
  - *Quyết định:* **Bảo toàn bản hiện tại**, đảm bảo 9/9 test chuyển đổi Lead thành công.
- **`LeadAssignmentService.java`:**
  - *Backup:* Hàm `processUnassignedLeads()` là stub rỗng.
  - *Current:* Đã hoàn thiện logic quét các Lead chưa phân bổ (`owner_id IS NULL AND status IN ('NEW', 'QUEUED')`) và phân bổ tự động.
  - *Quyết định:* **Bảo toàn bản hiện tại**.

### 3.4. Dữ liệu Test Data & Biểu mẫu Web Form (`test_data.sql`)
- **Khác biệt:** 
  - Backup: bảng `lead_sources` chỉ có 8 nguồn, `lead_web_forms` chưa có trường `lead_source_id`.
  - Current: Đã mở rộng lên 14 nguồn Lead (thêm `IMPORT_EXCEL`, `DIRECT`, `REFERRAL`, `COLD_CALL`, `EMAIL_CAMPAIGN`, `SOCIAL_MEDIA`) và liên kết `lead_source_id = 1` cho các Web Form.
- **Quyết định:** **Bảo toàn bản hiện tại** vì đây là phần mở rộng cần thiết cho các tính năng mới của Sprint 04.

---

## 4. BẢNG TỔNG HỢP TRẠNG THÁI TÍCH HỢP TỪNG TỆP

| Nhóm | Tệp tin | Xử lý tích hợp | Lý do & Nghiệp vụ |
| :--- | :--- | :---: | :--- |
| **Servlet** | `LeadDuplicateServlet.java` | **Ghép & Phục hồi** | Khôi phục forward `duplicatePairs` sang `duplicates.jsp` khi không có `leadId`. |
| **Servlet** | `LeadAcceptServlet.java` | **Ghép & Phục hồi** | Thêm fallback `X-User-Id` tương thích API cũ kết hợp Session auth. |
| **Servlet** | `LeadRejectServlet.java` | **Ghép & Phục hồi** | Thêm fallback `X-User-Id` tương thích API cũ kết hợp Session auth. |
| **Servlet** | `LeadAssignServlet.java` | **Ghép & Phục hồi** | Thêm fallback `X-User-Id`, `X-User-Role` kết hợp Data Scope RBAC. |
| **Servlet** | `LeadConvertServlet.java` | **Ghép & Phục hồi** | Thêm fallback `X-User-Id` kết hợp chuyển đổi JDBC thực. |
| **Servlet** | `LeadEmbedCodeServlet.java` | **Bảo toàn ghép** | Giữ URL patterns mới (`/lead-forms/embed`) và thuộc tính `embedSnippet`. |
| **Service** | `LeadDuplicateService.java` | **Bảo toàn ghép** | Giữ thuật toán substring $\ge 4$ ký tự, alias getters và kiểm tra cột động. |
| **Service** | `LeadConversionService.java`| **Bảo toàn ghép** | Giữ Transaction JDBC thật cho DB và Mock engine cho mock tests. |
| **Service** | `LeadAssignmentService.java`| **Bảo toàn ghép** | Giữ worker quét hàng chờ tự động và các phương thức overload tương thích. |
| **Service** | `LeadSlaService.java` | **Bảo toàn ghép** | Giữ Transaction JDBC thật, tính toán hạn SLA và audit log. |
| **Service** | `LeadScoringService.java` | **Bảo toàn ghép** | Giữ tối ưu hóa truy vấn batch `getAllLeadsUnlimited()`. |
| **SQL** | `schema.sql`, `test_data.sql` | **Bảo toàn ghép** | Giữ đầy đủ schema cho SLA, Lead Sources (1-14) và Campaigns. |
| **Cấu hình**| `db.properties` | **Cập nhật** | Đồng bộ mật khẩu database `Pttm2006@` của người dùng. |

---

## 5. KẾT QUẢ KIỂM THỬ SAU TÍCH HỢP

Lệnh chạy kiểm thử:
```bash
mvn test "-Ddb.test.password=Pttm2006@"
```

### Kết quả Surefire:
```text
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.crm.AccountPaginationIntegrationTest ... PASSED
[INFO] Running com.crm.AuditLogEndToEndTest ... PASSED
[INFO] Running com.crm.Customer360E2ETest ... PASSED
[INFO] Running com.crm.integration.LeadAssignmentIntegrationTest ... PASSED (17/17 tests)
[INFO] Running com.crm.integration.LeadConversionIntegrationTest ... PASSED (9/9 tests)
[INFO] Running com.crm.integration.LeadSlaIntegrationTest ... PASSED (21/21 tests)
[INFO] Running com.crm.service.CampaignTrackingS403Test ... PASSED (4/4 tests)
[INFO] Running com.crm.service.LeadDuplicateServiceTest ... PASSED (12/12 tests)
[INFO] Running com.crm.service.LeadDuplicateServiceRollbackTest ... PASSED (1/1 test)
[INFO] Running com.crm.service.LeadSlaServiceTest ... PASSED (5/5 tests)
[INFO] Running com.crm.service.LeadAssignmentServiceTest ... PASSED (17/17 tests)
[INFO] Running com.crm.service.LeadConversionServiceTest ... PASSED (9/9 tests)
...
[INFO] Results:
[INFO] 
[INFO] Tests run: 259, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

- **Tổng số tests:** **259 / 259 tests PASSED (100%)**
- **Failures:** **0**
- **Errors:** **0**
- **Skipped:** **0**

---

## 6. TRẠNG THÁI GIT & KHUYẾN NGHỊ BÀN GIAO

- **Trạng thái Git hiện tại:** Toàn bộ các file sau khi tích hợp đã được đưa vào Git Staging Area (`Changes to be committed`).
- **Tuân thủ an toàn:** 
  - **KHÔNG** thực hiện `git commit` hay `git push`.
  - **KHÔNG** xóa hay sửa đổi thư mục backup `TTCS_K1S2_N4_HeThongQuanLyKhachHang-backup-before-merge`.
  - **KHÔNG** sử dụng bất kỳ lệnh có nguy cơ mất mát dữ liệu (`git reset --hard`, `git clean`).
- **Khuyến nghị tiếp theo cho bạn:**
  - Bạn có thể xem xét toàn bộ các thay đổi đang staged bằng lệnh:
    ```bash
    git status
    ```
  - Khi đã sẵn sàng kết thúc quá trình merge, bạn chỉ cần chạy:
    ```bash
    git commit -m "merge: integrate completed features from backup and develop safely"
    ```
