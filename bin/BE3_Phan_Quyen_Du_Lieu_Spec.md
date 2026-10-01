# BE3 – Phân quyền dữ liệu (Data Scope) & Menu theo quyền

> File này dùng để đưa vào **Google Antigravity** (hoặc công cụ sinh code AI tương tự) để sinh code cho phần việc của **BE3** trong dự án CRM. Chỉ chứa phạm vi công việc của BE3, đã lược bỏ các phần của BE1, BE2, BE4, SM/BE.

---

## 1. Bối cảnh dự án

Dự án: Hệ thống CRM nội bộ, backend viết bằng **Java Servlet + JSP**, kiến trúc theo tầng **Controller → Service → DAO → Model**, dữ liệu lưu trong RDBMS (kết nối qua `DBConnection`).

BE3 chịu trách nhiệm cho:
- **S1-05 – Phân quyền dữ liệu theo phạm vi sở hữu (Data Scope: My/Team/All)**
- **S1-06 – Menu điều hướng hiển thị đúng theo quyền của người dùng**

Nhiệm vụ cốt lõi: xử lý **Role**, **Data Scope (My/Team/All)**, kiểm tra quyền truy cập, và cung cấp dữ liệu quyền cho các trang JSP để các BE khác (BE1, BE4...) sử dụng khi hiển thị/lọc dữ liệu.

---

## 2. Cây thư mục Backend – CHỈ PHẦN CỦA BE3

```
Backend/
│
├── pom.xml
├── README.md
│
└── src/
    │
    ├── main/
    │   │
    │   ├── java/
    │   │   └── com/
    │   │       └── crm/
    │   │           │
    │   │           ├── service/
    │   │           │   └── PermissionService.java        [BE3]
    │   │           │
    │   │           ├── dao/
    │   │           │   └── PermissionDAO.java            [BE3]
    │   │           │
    │   │           ├── model/
    │   │           │   └── Permission.java               [BE3]
    │   │           │
    │   │           ├── filter/
    │   │           │   └── AuthorizationFilter.java       [BE3]
    │   │           │
    │   │           ├── security/
    │   │           │   └── PermissionChecker.java         [BE3]
    │   │           │
    │   │           └── exception/
    │   │               └── AuthorizationException.java    [BE3]
    │   │
    │   └── webapp/
    │       └── WEB-INF/
    │           └── views/   (BE3 chỉ CUNG CẤP DỮ LIỆU quyền cho các JSP,
    │                          không sở hữu JSP nào — JSP thuộc về FE/BE khác)
    │
    └── test/
        └── java/
            └── com/
                └── crm/
                    ├── service/    (test cho PermissionService)
                    └── dao/        (test cho PermissionDAO)
```

**Ghi chú quan hệ với module khác (để AI hiểu ranh giới, KHÔNG cần sinh code cho các phần này):**
- `Account`, `Role`, `Team` là model do BE1/BE4 sở hữu — BE3 chỉ **tham chiếu** (dùng `roleId`, `teamId`, `accountId`) chứ không định nghĩa lại.
- `AuthenticationFilter` (đăng nhập) là của SM/BE — BE3 chỉ viết `AuthorizationFilter` (kiểm tra quyền sau khi đã đăng nhập).
- Các JSP (list.jsp, detail.jsp...) thuộc BE1/BE4/FE — BE3 chỉ cung cấp dữ liệu (danh sách quyền, phạm vi dữ liệu, menu được phép) để các JSP đó render.

---

## 3. User Stories cần code

### S1-05 — Phân quyền dữ liệu theo phạm vi sở hữu
**Persona:** Giám đốc kinh doanh
**Story:** Là Giám đốc kinh doanh, tôi muốn có phân quyền vừa theo vai trò vừa theo dữ liệu sở hữu, để nhân viên chỉ thấy khách của mình, trưởng nhóm thấy toàn nhóm, còn tôi thấy tất cả.

**Điểm: 8 – Ưu tiên: Must have**

**Tiêu chí chấp nhận (Acceptance Criteria):**
1. Có **3 phạm vi dữ liệu**: `MY` (của tôi), `TEAM` (của nhóm tôi), `ALL` (tất cả) — áp dụng cho các đối tượng: khách hàng, cơ hội, hoạt động, báo giá.
2. Mọi truy vấn danh sách (list) phải **tự động lọc theo phạm vi** tương ứng với vai trò của người dùng đang đăng nhập, kể cả khi tìm kiếm (search) và khi xuất Excel.
3. Nếu người dùng cố truy cập một bản ghi **ngoài phạm vi** được phép, hệ thống phải hiển thị **thông báo lỗi bằng tiếng Việt rõ ràng** (ví dụ: "Bạn không có quyền xem dữ liệu này"), không được để lộ dữ liệu.
4. Phải có **test tự động (unit test / integration test)** chứng minh: nhân viên A **không thể đọc được** khách hàng thuộc quyền sở hữu của nhân viên B.

### S1-06 — Menu điều hướng theo quyền
**Persona:** Người dùng của hệ thống
**Story:** Là người dùng của hệ thống, tôi muốn thấy menu điều hướng đúng theo quyền của mình, để không bị rối bởi những chức năng mình không được dùng.

**Điểm: 5 – Ưu tiên: Must have**

**Tiêu chí chấp nhận (Acceptance Criteria):**
1. Mục menu mà người dùng **không có quyền** thì **không hiển thị** (không chỉ là disable, mà ẩn hẳn).
2. Menu/header phải hiển thị: **tên người dùng**, **vai trò (role)**, và **nhóm kinh doanh (team)** mà người dùng đang thuộc về.
3. Giao diện menu phải dùng được thuận tiện trên màn hình có độ rộng tối thiểu **360px** (responsive, mobile-friendly).

---

## 4. Yêu cầu kỹ thuật chi tiết cho từng file

### 4.1 `model/Permission.java`
- Đại diện cho một quyền/khả năng trong hệ thống.
- Gợi ý field: `permissionId`, `permissionCode` (ví dụ `ACCOUNT_VIEW`, `ACCOUNT_CREATE`, `MENU_ACCOUNT`), `permissionName`, `module` (nhóm chức năng), `dataScope` (enum: `MY`, `TEAM`, `ALL`).
- Cần một enum riêng `DataScope { MY, TEAM, ALL }`.

### 4.2 `dao/PermissionDAO.java`
- Truy vấn danh sách quyền theo `roleId`.
- Truy vấn `DataScope` áp dụng cho một `roleId` + một `module` cụ thể (khách hàng/cơ hội/hoạt động/báo giá).
- Truy vấn danh sách `accountId` thuộc cùng team với một người dùng (phục vụ scope `TEAM`).
- Sử dụng `DBConnection` (đã có sẵn ở tầng `util`, không cần sinh lại) qua JDBC (PreparedStatement, chống SQL injection).

### 4.3 `service/PermissionService.java`
- `getMenuByRole(int roleId)`: trả về danh sách các mục menu mà role đó được phép thấy.
- `getDataScope(int roleId, String module)`: trả về `DataScope` (MY/TEAM/ALL) áp dụng cho module.
- `getAccessibleAccountIds(int userId, String module)`: trả về danh sách ID người dùng/bản ghi mà `userId` hiện tại được phép truy cập, dựa trên scope (nếu MY → chỉ chính mình; nếu TEAM → toàn bộ thành viên team; nếu ALL → không giới hạn).
- `hasPermission(int roleId, String permissionCode)`: kiểm tra quyền cụ thể (ví dụ tạo, sửa, xoá).
- Áp dụng cho 4 đối tượng nghiệp vụ: khách hàng, cơ hội, hoạt động, báo giá — nên thiết kế generic (dùng tham số `module`) thay vì viết lặp lại 4 lần.

### 4.4 `security/PermissionChecker.java`
- Lớp tiện ích (utility) dùng ở tầng Service/Controller của các BE khác để kiểm tra nhanh: "userId X có được xem record Y (thuộc module Z, sở hữu bởi ownerId O) không?"
- Hàm chính: `boolean canAccess(int userId, String module, int ownerId)`.
- Dùng `PermissionService` bên trong để lấy scope rồi đối chiếu.

### 4.5 `filter/AuthorizationFilter.java`
- Servlet Filter chạy sau `AuthenticationFilter` (của SM/BE).
- Kiểm tra: người dùng đã đăng nhập (lấy từ session) có quyền truy cập URL/servlet đang gọi hay không (dựa trên `PermissionService.hasPermission`).
- Nếu không có quyền → forward sang trang lỗi 403 (trang 403.jsp thuộc BE2, không cần sinh) với thông báo tiếng Việt.
- Cấu hình để BE3 tự khai báo các URL-pattern cần bảo vệ mà không đụng tới `web.xml` phần của SM/BE (ghi chú rõ trong code phần cần thêm vào `web.xml`).

### 4.6 `exception/AuthorizationException.java`
- Custom exception, ném ra khi vi phạm quyền (không phải lỗi hệ thống), chứa thông báo tiếng Việt rõ ràng, để tầng trên bắt và hiển thị đúng UX (403 hoặc thông báo inline).

---

## 5. Yêu cầu phi chức năng (Non-functional)
- Toàn bộ thông báo lỗi hiển thị cho người dùng: **bằng tiếng Việt**.
- Không dùng string nối SQL trực tiếp — luôn dùng `PreparedStatement`.
- Viết **Javadoc** ngắn gọn cho các hàm public.
- Viết kèm **unit test** (JUnit) cho `PermissionService`, đặc biệt test case: nhân viên A không đọc được dữ liệu của nhân viên B khi scope = MY.
- Code cần tương thích để BE1 (Role), BE4 (Account) gọi vào (thiết kế API/method rõ ràng, không phụ thuộc ngược lại BE1/BE4).

---

## 6. Yêu cầu đối với Google Antigravity khi sinh code

Hãy sinh đầy đủ code Java cho các file liệt kê ở mục 2 (đánh dấu `[BE3]`), tuân thủ:
1. Package `com.crm.*` đúng theo cây thư mục ở mục 2.
2. Đáp ứng toàn bộ Acceptance Criteria ở mục 3.
3. Thiết kế theo mục 4 (generic theo `module`, không lặp code cho 4 đối tượng nghiệp vụ).
4. Kèm unit test tối thiểu cho case "nhân viên A không đọc được dữ liệu nhân viên B".
5. Không sinh code cho các file/model không thuộc BE3 (Account, Role, Team, AuthenticationFilter, các JSP...) — chỉ **tham chiếu** tên class/field khi cần, giả định chúng đã tồn tại.
