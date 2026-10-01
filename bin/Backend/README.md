# Module BE3 – Phân Quyền Dữ Liệu (Data Scope) & Menu Điều Hướng

Dự án CRM Backend – Module BE3 chịu trách nhiệm xử lý phân quyền dữ liệu sở hữu (**Data Scope: MY / TEAM / ALL**) và hiển thị danh sách **Menu điều hướng** theo quyền của người dùng.

---

## 📌 1. Chức năng chính (User Stories)

### **S1-05 — Phân quyền dữ liệu theo phạm vi sở hữu (Data Scope)**
- **3 Phạm vi dữ liệu (`DataScope`)**:
  - `MY`: Người dùng chỉ nhìn thấy / chỉnh sửa các bản ghi do chính mình tạo hoặc đứng tên sở hữu.
  - `TEAM`: Người dùng (Trưởng nhóm/Leader) nhìn thấy / thao tác trên dữ liệu của toàn bộ thành viên trong nhóm kinh doanh (team).
  - `ALL`: Người dùng (Giám đốc/Admin) nhìn thấy / thao tác trên toàn bộ dữ liệu hệ thống.
- Áp dụng thống nhất cho 4 đối tượng nghiệp vụ chính: **Khách hàng (`ACCOUNT`)**, **Cơ hội (`DEAL`)**, **Hoạt động (`ACTIVITY`)**, **Báo giá (`QUOTE`)**.
- Tự động lọc danh sách (khi xem, tìm kiếm, xuất Excel).
- Ném ngoai lệ `AuthorizationException` chứa **thông báo lỗi bằng tiếng Việt rõ ràng** khi cố truy cập trái phép.

### **S1-06 — Menu điều hướng theo quyền**
- Tự động lọc và chỉ trả về/hiển thị các mục Menu mà vai trò (`Role`) của người dùng có quyền truy cập. Các chức năng không có quyền bị ẩn hoàn toàn.

---

## 📁 2. Cấu trúc thư mục Module BE3

```
Backend/
├── pom.xml
├── README.md
│
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/
    │   │       └── crm/
    │   │           ├── model/
    │   │           │   ├── DataScope.java          [Enum: MY, TEAM, ALL]
    │   │           │   ├── Permission.java         [Model Quyền hạn]
    │   │           │   └── MenuItem.java           [Model Menu điều hướng]
    │   │           │
    │   │           ├── dao/
    │   │           │   └── PermissionDAO.java      [DAO truy vấn JDBC với PreparedStatement]
    │   │           │
    │   │           ├── service/
    │   │           │   └── PermissionService.java  [Service nghiệp vụ kiểm tra Scope & Menu]
    │   │           │
    │   │           ├── security/
    │   │           │   └── PermissionChecker.java  [Utility Helper kiểm tra quyền cho BE1/BE4/Controllers]
    │   │           │
    │   │           ├── filter/
    │   │           │   └── AuthorizationFilter.java [Servlet Filter chặn URL không có quyền]
    │   │           │
    │   │           ├── exception/
    │   │           │   └── AuthorizationException.java [Ngoại lệ tiếng Việt khi vi phạm quyền]
    │   │           │
    │   │           └── util/
    │   │               └── DBConnection.java       [Kết nối CSDL JDBC]
    │   │
    │   ├── resources/
    │   │   └── schema_be3.sql                     [Script DDL & Seed data cho CSDL MySQL/H2]
    │   │
    │   └── webapp/
    │       └── WEB-INF/
    │           └── web.xml                         [Cấu hình Servlet Filter mẫu]
    │
    └── test/
        └── java/
            └── com/
                └── crm/
                    └── service/
                        └── PermissionServiceTest.java [Unit tests chứng minh AC S1-05 & S1-06]
```

---

## 🚀 3. Hướng dẫn Tích hợp & Sử dụng trong hệ thống

### 3.1 Cấu hình `web.xml` (Tầng Web Filter)
Thêm `AuthorizationFilter` vào `web.xml` phía sau `AuthenticationFilter`:
```xml
<filter>
    <filter-name>AuthorizationFilter</filter-name>
    <filter-class>com.crm.filter.AuthorizationFilter</filter-class>
</filter>

<filter-mapping>
    <filter-name>AuthorizationFilter</filter-name>
    <url-pattern>/accounts/*</url-pattern>
    <url-pattern>/deals/*</url-pattern>
    <url-pattern>/activities/*</url-pattern>
    <url-pattern>/quotes/*</url-pattern>
</filter-mapping>
```

### 3.2 Kiểm tra quyền truy cập bản ghi trong Controller / Service (BE1, BE4...)
Sử dụng `PermissionChecker`:
```java
// Lấy userId và roleId từ Session người dùng
int userId = (int) session.getAttribute("userId");
int roleId = (int) session.getAttribute("roleId");

// Ví dụ 1: Kiểm tra an toàn trước khi xem chi tiết bản ghi (Ném AuthorizationException nếu vi phạm)
PermissionChecker.checkAccessOrThrow(userId, roleId, "ACCOUNT", accountOwnerId);

// Ví dụ 2: Lấy danh sách owner_id được phép truy cập để tự động nối vào SQL query (lọc MY / TEAM)
List<Integer> allowedOwnerIds = PermissionChecker.getAccessibleAccountIds(userId, roleId, "ACCOUNT");
if (!allowedOwnerIds.isEmpty()) {
    // Append SQL: WHERE owner_id IN (allowedOwnerIds...)
}
```

### 3.3 Lấy danh sách Menu hiển thị trên giao diện JSP
Trong Controller khi chuẩn bị dữ liệu render header/sidebar menu:
```java
PermissionService permissionService = new PermissionService();
List<MenuItem> userMenu = permissionService.getMenuByRole(roleId);
request.setAttribute("userMenu", userMenu);
```

---

## 🧪 4. Chạy Unit Test (Kiểm tra tự động)

Chạy lệnh Maven để kiểm tra toàn bộ các test cases (bao gồm test Nhân viên A không thể đọc dữ liệu của Nhân viên B khi scope = MY):

```bash
mvn test
```

---

## 📤 5. Hướng dẫn nộp bài lên GitHub

Thực hiện các bước sau trong terminal để commit và push code lên GitHub:

```bash
# 1. Kiểm tra trạng thái các file đã tạo
git status

# 2. Thêm tất cả các file của BE3 vào Git staging
git add .

# 3. Tạo commit với thông điệp rõ ràng
git commit -m "feat(be3): complete data scope permissions (MY/TEAM/ALL) and role-based navigation menu"

# 4. Đẩy code lên nhánh main / dev trên GitHub
git push origin main
```
