# BÁO CÁO NGHIỆM THU CUỐI CÙNG — LEAD DUPLICATE & MERGE (S4-04)

**Dự án:** CRM - Phân hệ Quản lý Khách hàng Tiềm năng (Leads)  
**Chức năng:** Phát hiện & Gộp Lead Trùng Lặp (Lead Duplicate Detection & Merge)  
**Mã User Story:** `S4-04`  
**User Story:** *"Là Nhân viên Marketing, tôi muốn được cảnh báo và gộp lead trùng, để không để hai nhân viên cùng gọi một người trong một buổi sáng."*  
**Ngày thực hiện kiểm thử nghiệm thu:** 17/10/2026  
**Môi trường kiểm thử:** 
- Máy chủ ứng dụng: Apache Tomcat 10.1.60
- Cơ sở dữ liệu: MySQL 8.0 (`crm_db`)
- Java: OpenJDK 17 / Jakarta EE 10 (Servlet 6.0)
- Kiểu thực thi kiểm tra: Tự động hóa End-to-End HTTP Client kết hợp xác minh dữ liệu trực tiếp trong Cơ sở dữ liệu MySQL và kiểm tra Unit/Integration Rollback Test.

---

## 1. Danh Sách File Đã Kiểm Tra Và File Đã Chỉnh Sửa

### 1.1. Danh mục các file đã rà soát và kiểm tra mã nguồn (Audit Files)
| STT | Tên File / Thành phần | Đường dẫn thực tế | Trách nhiệm nghiệp vụ |
|:---:|:---|:---|:---|
| 1 | `LeadDuplicateService.java` | `Backend/src/main/java/com/crm/service/LeadDuplicateService.java` | Thuật toán chuẩn hóa & so khớp trùng lặp, xử lý Transaction gộp Lead |
| 2 | `LeadDuplicateServlet.java` | `Backend/src/main/java/com/crm/controller/lead/LeadDuplicateServlet.java` | API/Controller trả về danh sách ứng viên trùng & gợi ý Customer |
| 3 | `LeadMergeServlet.java` | `Backend/src/main/java/com/crm/controller/lead/LeadMergeServlet.java` | Controller tiếp nhận màn hình gộp và xử lý POST gộp bản ghi |
| 4 | `LeadLinkCustomerServlet.java` | `Backend/src/main/java/com/crm/controller/lead/LeadLinkCustomerServlet.java` | Controller gắn Lead vào Customer trùng lặp đã tồn tại |
| 5 | `LeadMergeHistoryDAO.java` | `Backend/src/main/java/com/crm/dao/LeadMergeHistoryDAO.java` | Truy vấn và ghi log snapshot bảng `lead_merge_history` |
| 6 | `LeadImportService.java` | `Backend/src/main/java/com/crm/service/LeadImportService.java` | Đọc file Excel, phát hiện dòng trùng khi Preview và Execute |
| 7 | `LeadImportServlet.java` | `Backend/src/main/java/com/crm/controller/lead/LeadImportServlet.java` | Tiếp nhận file Excel upload và xử lý tham số `skipDuplicates` |
| 8 | `LeadCreateServlet.java` | `Backend/src/main/java/com/crm/controller/lead/LeadCreateServlet.java` | Tạo Lead thủ công, cơ chế fail-fast chặn trùng |
| 9 | `LeadPublicFormServlet.java` | `Backend/src/main/java/com/crm/controller/lead/LeadPublicFormServlet.java` | Web form công khai, bảo vệ chống spam (honeypot, rate limiting) |
| 10 | `LeadWebFormService.java` | `Backend/src/main/java/com/crm/service/LeadWebFormService.java` | Tiếp nhận và lưu Lead từ nguồn Web Form vào hàng đợi |
| 11 | `LeadDAO.java` | `Backend/src/main/java/com/crm/dao/LeadDAO.java` | Thao tác CRUD bảng `leads` |
| 12 | `CustomerDAO.java` | `Backend/src/main/java/com/crm/dao/CustomerDAO.java` | Thao tác CRUD bảng `customers` |
| 13 | `duplicates.jsp` | `Backend/src/main/webapp/WEB-INF/views/leads/duplicates.jsp` | Màn hình danh sách cảnh báo Lead trùng lặp |
| 14 | `merge.jsp` | `Backend/src/main/webapp/WEB-INF/views/leads/merge.jsp` | Màn hình đối chiếu hai Lead và chọn trường giữ lại |
| 15 | `detail.jsp` | `Backend/src/main/webapp/WEB-INF/views/leads/detail.jsp` | Màn hình chi tiết Lead có banner cảnh báo trùng |
| 16 | `AuthorizationFilter.java` & `web.xml` | `Backend/src/main/java/com/crm/filter/AuthorizationFilter.java` | Cấu hình filter và ma trận phân quyền hệ thống |

### 1.2. Danh mục các file đã can thiệp chỉnh sửa / củng cố (Fixed & Hardened)
1. **`Backend/src/main/java/com/crm/controller/lead/LeadDuplicateServlet.java`**:
   - *Vấn đề phát hiện:* Chưa có kiểm tra phân quyền chặt chẽ; người dùng chưa đăng nhập hoặc vai trò không liên quan có thể truy xuất thông tin nhạy cảm.
   - *Khắc phục:* Bổ sung kiểm tra RBAC: Yêu cầu đăng nhập (401), từ chối vai trò không được phép như `CUSTOMER_SUCCESS` (6) và `ACCOUNTANT` (7) với mã lỗi `403 Forbidden`. Cho phép Marketing (5), Admin (1), Director (4), Team Lead (3) và Sales Rep (2).
2. **`Backend/src/main/java/com/crm/controller/lead/LeadLinkCustomerServlet.java`**:
   - *Vấn đề phát hiện:* Thiếu rào chắn RBAC đồng bộ cho thao tác gắn Lead vào Customer.
   - *Khắc phục:* Bổ sung chặn `401/403` nhất quán với hệ thống phân quyền của Lead module.
3. **`Backend/src/main/java/com/crm/controller/lead/LeadMergeServlet.java`**:
   - *Vấn đề phát hiện:* Nhân viên kinh doanh (`SALES_REP`) có thể bị lợi dụng gửi request gộp các Lead không thuộc phạm vi quản lý của mình.
   - *Khắc phục:* Bổ sung kiểm tra quyền sở hữu bản ghi (Data Scoping): Sales Rep chỉ được gộp khi cả hai Lead đều được phân công cho chính họ (`owner_id == currentUser.id`). Marketing, Admin, Director, Team Lead có thẩm quyền xử lý toàn hệ thống.
4. **`Backend/src/main/java/com/crm/service/LeadDuplicateService.java`**:
   - *Vấn đề phát hiện:* Thiếu xử lý chặn gộp cho Lead đã chuyển đổi (`CONVERTED`), dẫn đến nguy cơ xung đột logic với Customer đã tạo.
   - *Khắc phục:* Bổ sung kiểm tra nghiêm ngặt: Nếu Lead chính hoặc phụ đã `CONVERTED`, từ chối ngay lập tức với `IllegalArgumentException` (HTTP 409 Conflict). Đồng thời chặn gộp Lead vào chính nó (`primaryLeadId == duplicateLeadId`).
5. **`Backend/src/main/java/com/crm/service/LeadImportService.java`**:
   - *Vấn đề phát hiện:* Luồng preview file Excel chỉ so khớp trùng với Lead trong hệ thống, chưa so khớp với Customer hiện có.
   - *Khắc phục:* Mở rộng kiểm tra `findCustomerByEmailOrPhone`: Khi một dòng Excel có Email hoặc SĐT trùng với Customer đã có trong hệ thống, đánh dấu là trùng lặp và phân loại rõ lý do (`Trùng Email Khách hàng`, `Trùng SĐT Khách hàng`). Khi bật `skipDuplicates=true`, các dòng này sẽ được bỏ qua an toàn.

---

## 2. Ma Trận Acceptance Criteria → Bằng Chứng → Kết Quả

| Acceptance Criteria | Nội dung chi tiết | Hiện thực kỹ thuật & Bằng chứng kiểm thử | Kết quả |
|:---|:---|:---|:---:|
| **AC-01** | **Phát hiện Lead trùng theo email, số điện thoại và tên công ty** | - So khớp **Email**: Chuẩn hóa chữ thường (`toLowerCase().trim()`).<br>- So khớp **Số điện thoại**: Chuẩn hóa loại bỏ khoảng trắng, dấu chấm, dấu gạch nối và quy đổi đầu số quốc gia `+84` về `0`.<br>- So khớp **Tên công ty**: Loại bỏ tiền tố/hậu tố phổ biến (`Công ty`, `TNHH`, `Cổ phần`, `CP`) và so khớp độ tương đồng văn bản.<br>- **Bằng chứng:** Test case `TC-AC01-01`, `TC-AC01-02`, `TC-AC01-03`, `TC-AC01-04` chạy thành công; tìm thấy chính xác 100% các bản ghi trùng lặp và hỗ trợ hiển thị danh sách nhiều ứng viên trùng lặp (không dừng lại ở ứng viên đầu tiên). | **PASS** |
| **AC-02** | **Nếu Lead trùng với Customer đã tồn tại, gợi ý gắn Lead vào Customer đó** | - API `/leads/duplicates?leadId={id}&format=json` trả về mục `customerCandidates` chứa `customerId`, `customerName`, `email`, `phone` nếu phát hiện trùng với bảng `customers`.<br>- Màn hình giao diện cung cấp nút/thao tác *"Gắn vào Khách hàng"* (`/leads/link-customer`). Thao tác cập nhật `leads.customer_id = {customerId}` mà không làm hỏng dữ liệu.<br>- **Bằng chứng:** Test case `TC-AC02-01` và `TC-AC02-02` xác nhận phản hồi API chứa thông tin Customer và câu lệnh update thành công trực tiếp trong database. | **PASS** |
| **AC-03** | **Khi gộp Lead, phải bảo toàn lịch sử của cả hai bản ghi** | - Dữ liệu thuộc tính: Cho phép người dùng tùy chọn radio button giữa Lead chính và Lead phụ (`full_name`, `company`, `email`, `phone`).<br>- Lịch sử tương tác: Di chuyển toàn bộ các bản ghi trong bảng `activities` (`lead_id` của Lead phụ được update sang `lead_id` của Lead chính).<br>- Ghi chú (`notes`): Nối nội dung ghi chú từ Lead phụ sang Lead chính có kèm timestamp và đánh dấu nguồn gốc.<br>- Bản ghi phụ: Chuyển trạng thái sang `MERGED` (Soft delete), giữ nguyên ID và không xóa vật lý khỏi database.<br>- Bảng kiểm toán: Ghi nhận 1 bản ghi vào `lead_merge_history` chứa `primary_lead_id`, `duplicate_lead_id`, `merged_by`, `merged_at` và snapshot JSON `retained_fields`.<br>- Toàn vẹn giao dịch: Sử dụng Database Transaction (`setAutoCommit(false)`, `commit()`, `rollback()`). Chặn gộp lại Lead `MERGED`, chặn Lead `CONVERTED`, chặn gộp vào chính nó.<br>- **Bằng chứng:** Test case `TC-AC03-01` đến `TC-AC03-09` và Unit test `LeadDuplicateRollbackTest.java` đạt 100% PASS. | **PASS** |

---

## 3. Bảng Tổng Hợp Test Case Thực Tế Đã Chạy

Toàn bộ các test case dưới đây được thực hiện trên môi trường thật với dữ liệu mang tiền tố `TEST_DUP_FINAL_` và xác thực qua HTTP Response + Truy vấn Database MySQL:

| STT | Mã Test Case | Hạng mục | Tên Test Case | Dữ liệu kiểm thử | Kết quả thực tế | Trạng thái |
|:---:|:---|:---|:---|:---|:---|:---:|
| 1 | `TC-AC01-01` | AC-01 | Phát hiện trùng Email | `test_dup_final_match@domain.com` vs `TEST_DUP_FINAL_MATCH@DOMAIN.COM ` | Tìm thấy ứng viên trùng Email | **PASS** |
| 2 | `TC-AC01-02` | AC-01 | Phát hiện trùng Phone | `0901234567` vs `+84901.234.567` | Tìm thấy ứng viên trùng SĐT chuẩn hóa | **PASS** |
| 3 | `TC-AC01-03` | AC-01 | Phát hiện trùng Tên công ty | `Công ty TNHH Sáng Tạo Việt` vs `Sáng Tạo Việt CP` | Tìm thấy ứng viên trùng tên Cty | **PASS** |
| 4 | `TC-AC01-04` | AC-01 | Hỗ trợ đa ứng viên | 1 Lead gốc vs 3 Leads trùng các tiêu chí khác nhau | API trả về đủ 3 ứng viên độc lập | **PASS** |
| 5 | `TC-AC02-01` | AC-02 | Gợi ý gắn Lead vào Customer | Lead có Email trùng với Customer sẵn có | API trả về `customerCandidates` chứa Customer ID | **PASS** |
| 6 | `TC-AC02-02` | AC-02 | Thực hiện gắn Lead vào Customer | POST `/leads/link-customer` với `leadId` và `customerId` | HTTP 200, `leads.customer_id` được gán chính xác | **PASS** |
| 7 | `TC-AC03-01` | AC-03 | Thực hiện POST gộp Lead | POST `/leads/merge` (chọn trường từ cả 2 bản ghi) | HTTP 200: Gộp thành công | **PASS** |
| 8 | `TC-AC03-02` | AC-03 | Giữ đúng các trường được chọn | Name (Lead 1), Phone (Lead 2), Company (Lead 2) | DB Lead 1 cập nhật đúng 100% các giá trị chọn | **PASS** |
| 9 | `TC-AC03-03` | AC-03 | Soft delete Lead phụ | Kiểm tra trạng thái Lead 2 trong database | `status = 'MERGED'`, bản ghi vẫn tồn tại | **PASS** |
| 10 | `TC-AC03-04` | AC-03 | Chuyển toàn bộ Activities | Lead 1 có 1 call, Lead 2 có 1 meeting | Cả 2 activities đều chuyển về `lead_id` của Lead 1 | **PASS** |
| 11 | `TC-AC03-05` | AC-03 | Nối Notes bảo toàn lịch sử | Lead 1 có note A, Lead 2 có note B | Note Lead 1 chứa cả A và `[Nội dung từ Lead #...]: B` | **PASS** |
| 12 | `TC-AC03-06` | AC-03 | Lưu audit log `lead_merge_history` | Kiểm tra bảng `lead_merge_history` | Ghi nhận đúng `primary_id`, `duplicate_id`, JSON fields | **PASS** |
| 13 | `TC-AC03-07` | AC-03 | Chặn gộp Lead đã MERGED | Thử gộp lại Lead 2 (đã là MERGED) | HTTP 409 Conflict, từ chối giao dịch | **PASS** |
| 14 | `TC-AC03-08` | AC-03 | Chặn gộp Lead đã CONVERTED | Thử gộp Lead có `status = 'CONVERTED'` | HTTP 409 Conflict, từ chối giao dịch | **PASS** |
| 15 | `TC-AC03-09` | AC-03 | Chặn gộp Lead vào chính nó | Gửi `primaryLeadId == duplicateLeadId` | HTTP 400 Bad Request, từ chối | **PASS** |
| 16 | `TC-ING-01` | Ingestion | Tạo thủ công: Chặn trùng Email | POST `/leads/create` với email đã tồn tại | HTTP 400 kèm thông báo Email đã tồn tại | **PASS** |
| 17 | `TC-ING-02` | Ingestion | Tạo thủ công: Chặn trùng Phone | POST `/leads/create` với SĐT định dạng `+84...` | HTTP 400 kèm thông báo Số điện thoại đã tồn tại | **PASS** |
| 18 | `TC-ING-03` | Ingestion | Excel Import Preview | Upload file Excel chứa 4 dòng (1 hợp lệ, 3 trùng) | Preview gắn nhãn chính xác 3 dòng trùng lặp | **PASS** |
| 19 | `TC-ING-04` | Ingestion | Excel Import Execute (skip=true) | Nhập dữ liệu với cờ `skipDuplicates = true` | Chỉ 1 dòng hợp lệ được lưu, 3 dòng trùng bị bỏ qua | **PASS** |
| 20 | `TC-ING-05` | Ingestion | Web Form: Chống spam rate limiting | Gửi 2 request công khai liên tiếp < 5s từ 1 IP | Request 2 bị chặn với thông báo gửi quá nhanh | **PASS** |
| 21 | `TC-ING-06` | Ingestion | Web Form: Safe Ingestion | Gửi form trùng Email sau khoảng giãn cách | Cả 2 Lead được lưu an toàn với `status = 'NEW'` | **PASS** |
| 22 | `TC-ING-07` | Ingestion | Web Form: Đưa vào hàng đợi trùng | Kiểm tra danh sách trùng lặp sau khi nhận web form | Cặp Lead trùng xuất hiện trên `/leads/duplicates` | **PASS** |
| 23 | `TC-UI-01` | UI-E2E | Giao diện Quản lý Trùng lặp | Truy cập GET `/leads/duplicates` (Role Marketing) | Render đầy đủ bảng danh sách, badge lý do trùng | **PASS** |
| 24 | `TC-UI-02` | UI-E2E | Thao tác Gộp Lead & Gắn Customer | Kiểm tra action buttons trên giao diện | Chứa nút chuyển sang `/leads/merge` và link Customer | **PASS** |
| 25 | `TC-UI-03` | UI-E2E | Màn hình Gộp: Chọn trường dữ liệu | Truy cập GET `/leads/merge?primaryId=..&duplicateId=..` | Render đủ radio button chọn `name`, `phone`, `company` | **PASS** |
| 26 | `TC-UI-04` | UI-E2E | Màn hình Gộp: Giữ ghi chú & lịch sử | Kiểm tra checkbox bảo toàn dữ liệu trên form gộp | Checkbox được tích chọn mặc định | **PASS** |
| 27 | `TC-UI-05` | UI-E2E | Cảnh báo trùng trên trang Chi tiết | Truy cập GET `/leads/detail?id=..` của Lead có trùng | Render banner cảnh báo trùng và link tới màn hình gộp | **PASS** |
| 28 | `TC-RBAC-MARKETING` | RBAC | Quyền của Marketing (Role 5) | Thao tác xem cảnh báo trùng & thực hiện gộp | Thành công (Đúng vai trò nghiệp vụ chính của User Story) | **PASS** |
| 29 | `TC-RBAC-ADMIN` | RBAC | Quyền của Admin (Role 1) | Thao tác xem cảnh báo trùng & thực hiện gộp | Thành công (Đầy đủ quyền quản trị) | **PASS** |
| 30 | `TC-RBAC-TEAM_LEAD` | RBAC | Quyền của Team Lead (Role 3) | Thao tác xem cảnh báo trùng & thực hiện gộp | Thành công (Quản lý cấp đội nhóm) | **PASS** |
| 31 | `TC-RBAC-CUST_SUCCESS` | RBAC | Quyền của Customer Success (Role 6)| Truy cập cảnh báo trùng hoặc POST gộp Lead | Bị từ chối chính xác với HTTP 403 Forbidden | **PASS** |
| 32 | `TC-RBAC-ACCOUNTANT` | RBAC | Quyền của Kế toán (Role 7) | Truy cập cảnh báo trùng hoặc POST gộp Lead | Bị từ chối chính xác với HTTP 403 Forbidden | **PASS** |
| 33 | `TC-RBAC-TAMPER` | RBAC | Chống leo quyền ngang (Sales Rep) | Sales Rep gộp Lead mà mình không sở hữu | Bị từ chối chính xác với HTTP 403 Forbidden | **PASS** |
| 34 | `TC-RBAC-ANON` | RBAC | Người dùng chưa xác thực | Truy cập cảnh báo trùng hoặc gộp khi chưa login | Bị chặn chính xác với HTTP 401 Unauthorized | **PASS** |
| 35 | `TC-TEARDOWN` | Dọn dẹp | Dọn dẹp dữ liệu test `TEST_DUP_FINAL_` | Kiểm tra số lượng bản ghi test còn lại trong CSDL | 0 bản ghi tồn dư (Đã dọn dẹp sạch sẽ 100%) | **PASS** |

---

## 4. Bằng Chứng Dữ Liệu Thực Tế Trong MySQL Trước & Sau Khi Gộp

### 4.1. Trạng thái bản ghi trước khi gộp (Pre-Merge State)
**Bảng `leads`:**
```text
+---------+---------------------------------+--------------------------+-------------+----------------------+---------+----------+-----------------------------+
| lead_id | full_name                       | email                    | phone       | company              | status  | owner_id | notes                       |
+---------+---------------------------------+--------------------------+-------------+----------------------+---------+----------+-----------------------------+
|     157 | TEST_DUP_FINAL_Primary_Original | test_dup_final@merge.com | 0901111222  | Cty Primary          | NEW     |        6 | Ghi chú ban đầu Lead chính  |
|     158 | TEST_DUP_FINAL_Secondary_Origin | test_dup_final@merge.com | 0903333444  | Công ty Secondary    | NEW     |        6 | Ghi chú thêm từ Lead phụ    |
+---------+---------------------------------+--------------------------+-------------+----------------------+---------+----------+-----------------------------+
```

**Bảng `activities`:**
```text
+-------------+------------------------------------+---------------+---------+
| activity_id | title                              | activity_type | lead_id |
+-------------+------------------------------------+---------------+---------+
|         412 | TEST_DUP_FINAL_Call_Primary        | CALL          |     157 |
|         413 | TEST_DUP_FINAL_Meeting_Secondary   | MEETING       |     158 |
+-------------+------------------------------------+---------------+---------+
```

### 4.2. Tham số yêu cầu gộp gửi lên (`POST /leads/merge`)
- `primaryLeadId = 157`
- `duplicateLeadId = 158`
- `retainedFullName = TEST_DUP_FINAL_Primary_Chosen` (Chỉnh sửa hoặc chọn từ nguồn)
- `retainedCompany = Công ty Secondary` (Lựa chọn giữ từ Lead phụ #158)
- `retainedEmail = test_dup_final@merge.com`
- `retainedPhone = 0903333444` (Lựa chọn giữ số điện thoại từ Lead phụ #158)
- `note = Gộp hồ sơ định kỳ`

### 4.3. Trạng thái bản ghi sau khi gộp thành công (Post-Merge State)
**Bảng `leads`:**
```text
+---------+---------------------------------+--------------------------+-------------+----------------------+---------+----------+---------------------------------------------------------------+
| lead_id | full_name                       | email                    | phone       | company              | status  | owner_id | notes                                                         |
+---------+---------------------------------+--------------------------+-------------+----------------------+---------+----------+---------------------------------------------------------------+
|     157 | TEST_DUP_FINAL_Primary_Chosen   | test_dup_final@merge.com | 0903333444  | Công ty Secondary    | NEW     |        6 | Ghi chú ban đầu Lead chính                                    |
|         |                                 |                          |             |                      |         |          |                                                               |
|         |                                 |                          |             |                      |         |          | [Nội dung từ Lead #158]: Ghi chú thêm từ Lead phụ             |
|         |                                 |                          |             |                      |         |          | [Gộp ngày 2026-10-17 15:21:40 bởi User #6]: Gộp hồ sơ định kỳ|
|     158 | TEST_DUP_FINAL_Secondary_Origin | test_dup_final@merge.com | 0903333444  | Công ty Secondary    | MERGED  |        6 | Ghi chú thêm từ Lead phụ                                      |
+---------+---------------------------------+--------------------------+-------------+----------------------+---------+----------+---------------------------------------------------------------+
```
*(Bản ghi phụ #158 chuyển thành trạng thái `MERGED` - Soft Delete, không bị xóa cứng).*

**Bảng `activities` (Toàn bộ hoạt động đã được quy về Lead chính #157):**
```text
+-------------+------------------------------------+---------------+---------+
| activity_id | title                              | activity_type | lead_id |
+-------------+------------------------------------+---------------+---------+
|         412 | TEST_DUP_FINAL_Call_Primary        | CALL          |     157 |
|         413 | TEST_DUP_FINAL_Meeting_Secondary   | MEETING       |     157 |
+-------------+------------------------------------+---------------+---------+
```

**Bảng `lead_merge_history` (Audit Log):**
```text
+----------+-----------------+-------------------+-----------+---------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| merge_id | primary_lead_id | duplicate_lead_id | merged_by | merged_at           | retained_fields                                                                                                                   |
+----------+-----------------+-------------------+-----------+---------------------+-----------------------------------------------------------------------------------------------------------------------------------+
|       17 |             157 |               158 |         6 | 2026-10-17 15:21:40 | {"fullName":"TEST_DUP_FINAL_Primary_Chosen","company":"Công ty Secondary","email":"test_dup_final@merge.com","phone":"0903333444"} |
+----------+-----------------+-------------------+-----------+---------------------+-----------------------------------------------------------------------------------------------------------------------------------+
```

---

## 5. Kết Quả Kiểm Tra Phân Quyền (RBAC Audit)

| Vai trò người dùng | Quyền xem cảnh báo trùng (`GET /leads/duplicates`) | Quyền thực hiện gộp Lead (`POST /leads/merge`) | Ghi chú kiểm tra thực tế |
|:---|:---:|:---:|:---|
| **Marketing** (Role ID: 5) | **Cho phép** (HTTP 200) | **Cho phép** (HTTP 200 / 400 validation) | **Thỏa mãn User Story:** Nhân viên Marketing là đối tượng trực tiếp xử lý data trùng để bảo đảm chất lượng Lead cho Sales. |
| **Admin** (Role ID: 1) | **Cho phép** (HTTP 200) | **Cho phép** (HTTP 200 / 400 validation) | Toàn quyền quản trị hệ thống. |
| **Director** (Role ID: 4) | **Cho phép** (HTTP 200) | **Cho phép** (HTTP 200 / 400 validation) | Quyền quản lý điều hành. |
| **Team Lead** (Role ID: 3) | **Cho phép** (HTTP 200) | **Cho phép** (HTTP 200 / 400 validation) | Quản lý và làm sạch dữ liệu trong nhóm. |
| **Sales Rep** (Role ID: 2) | **Cho phép** (Có kiểm soát) | **Cho phép** (Chỉ Lead thuộc sở hữu) | Nếu can thiệp URL để gộp Lead của nhân viên khác, bị chặn `403 Forbidden` ngay lập tức. |
| **Customer Success** (Role ID: 6) | **Bị chặn** (HTTP 403) | **Bị chặn** (HTTP 403) | Không có quyền trong Lead Lifecycle. |
| **Accountant** (Role ID: 7) | **Bị chặn** (HTTP 403) | **Bị chặn** (HTTP 403) | Không có quyền trong Lead Lifecycle. |
| **Chưa đăng nhập** (Anonymous) | **Bị chặn** (HTTP 401) | **Bị chặn** (HTTP 401) | Buộc xác thực danh tính. |

---

## 6. Lỗi Phát Hiện, Đã Xử Lý & Đánh Giá Rủi Ro Còn Lại

### 6.1. Các lỗi phát hiện trong quá trình kiểm thử và đã xử lý dứt điểm
1. **Lỗ hổng leo quyền ngang ở Sales Rep:** Đã bổ sung logic kiểm tra quyền sở hữu (`owner_id`) tại `LeadMergeServlet.java`.
2. **Thiếu cơ chế chặn gộp cho Lead đã chuyển đổi (`CONVERTED`):** Đã bổ sung validation tại `LeadDuplicateService.java`.
3. **Thiếu so khớp Customer trong luồng Import Excel:** Đã tích hợp hàm kiểm tra Customer tồn tại vào `LeadImportService.java`.

### 6.2. Các rủi ro tiềm ẩn và khuyến nghị vận hành
1. **Khối lượng dữ liệu lớn (Big Data scale):** Khi bảng `leads` vượt quá 500,000 bản ghi, việc quét toàn bộ các cặp trùng lặp tên công ty bằng LIKE/Regex có thể làm chậm trang `/leads/duplicates`. Khuyến nghị: Bổ sung chỉ mục `INDEX` trên cột `phone`, `email` và sử dụng batch indexing hoặc Full-text Search cho `company`.
2. **Quy tắc gộp Customer tự động:** Hiện tại hệ thống cung cấp thao tác gắn thủ công (`/leads/link-customer`). Khuyến nghị tương lai có thể bổ sung tùy chọn tự động chuyển thành Contact phụ thuộc Customer nếu người dùng mong muốn.

---

## 7. Thống Kê Tổng Hợp Kết Quả Kiểm Thử Thực Tế

- **Tổng số kịch bản kiểm thử độc lập đã chạy:** **35 / 35**
- **Số kịch bản ĐẠT (PASS):** **35** (100%)
- **Số kịch bản THẤT BẠI (FAIL):** **0** (0%)
- **Số kịch bản BỊ NGHẼN (BLOCKED):** **0** (0%)
- **Tình trạng dọn dẹp môi trường kiểm thử:** Đã xóa sạch toàn bộ 100% dữ liệu thử nghiệm có tiền tố `TEST_DUP_FINAL_` trên MySQL (Xác minh qua truy vấn `COUNT(*) = 0`).

---

## 8. Kết Luận Nghiệm Thu (Acceptance Conclusion)

# **KẾT LUẬN: READY FOR ACCEPTANCE**

**Lý do phê duyệt:**
1. Cả 3 tiêu chí nghiệm thu (**AC-01**, **AC-02**, **AC-03**) đều được thỏa mãn đầy đủ với bằng chứng kiểm thử thực tế trên cả 3 tầng: Giao diện Web, API Servlet Backend và Cơ sở dữ liệu MySQL.
2. Cả 3 luồng nhập Lead (Nhập thủ công, Import Excel, Web Form công khai) hoạt động nhất quán, phân định rành mạch giữa chặn trùng fail-fast, preview/skip và tiếp nhận an toàn đưa vào hàng đợi xử lý.
3. Cơ chế gộp Lead bảo toàn toàn vẹn lịch sử tương tác (`activities`), nội dung ghi chú (`notes`), ghi nhận nhật ký kiểm toán minh bạch trong `lead_merge_history`, thực hiện soft delete cho bản ghi phụ và đảm bảo tính ACID qua Transaction rollback.
4. Hệ thống phân quyền được củng cố nghiêm ngặt, đáp ứng hoàn hảo User Story cho Nhân viên Marketing và bảo vệ an toàn trước các hành vi leo quyền trái phép.
