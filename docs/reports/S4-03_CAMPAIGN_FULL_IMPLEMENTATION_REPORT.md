# BÁO CÁO TOÀN DIỆN THỰC THI VÀ NGHIỆM THU USER STORY S4-03
## THEO DÕI LEAD THEO CHIẾN DỊCH MARKETING & ĐO LƯỜNG DOANH THU THỰC TẾ

> **Mã công việc:** S4-03  
> **Hệ thống:** Frostline CRM (Java Servlet / Jakarta EE 10 / Tomcat 10.1.60 / MySQL 8.0)  
> **Thời gian hoàn thành:** 17/10/2026  
> **Trạng thái tổng thể:** **HOÀN THÀNH TOÀN DIỆN (100% PASS TRÊN TOMCAT ĐANG CHẠY)**

---

## 1. HIỆN TRẠNG BAN ĐẦU VÀ NGUYÊN NHÂN GỐC CÁC LỖI

Trước khi tiến hành sửa chữa, việc phân tích hệ thống Frostline CRM ghi nhận 3 nhóm vấn đề cốt lõi:

### 1.1. Lỗi trang trắng (White Screen) khi bấm Chỉnh sửa Chiến dịch
- **Hiện trạng:** Người dùng điều hướng tới `/crm-backend-1.0.0/campaigns`, khi bấm vào nút sửa một chiến dịch (`/campaigns/edit?id=1`), trình duyệt trả về trang trắng hoàn toàn (HTTP 500 cắt cụt response).
- **Nguyên nhân gốc:** 
  1. Trong Tomcat 10.1 (Jakarta EE 10 / Jasper / EL 5.0), trang `edit.jsp` gọi biểu thức `${campaign.id}` và `${campaign.name}`.
  2. Model `Campaign.java` ban đầu chỉ có các trường và getter theo chuẩn database là `getCampaignId()` và `getCampaignName()`, không có `getId()` hay `getName()`.
  3. Khi Jasper phân giải `${campaign.id}`, Jakarta EL ném ngoại lệ:
     ```
     jakarta.el.PropertyNotFoundException: Property [id] not found on type [com.crm.model.Campaign]
        at jakarta.el.BeanELResolver$BeanProperties.get(BeanELResolver.java:261)
        at org.apache.jsp.WEB_002dINF.views.campaigns.edit_jsp._jspService(edit_jsp.java:184)
     ```
  4. Response bị ngắt giữa chừng ngay tại dòng `<input type="hidden" name="id" value="`, dẫn đến trang trắng không hoàn tất render HTML.
  5. Đồng thời, `edit.jsp` thiếu khai báo taglib chuẩn Jakarta Core và JSTL Formatting (`<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>`), khiến việc định dạng `<input type="date">` bị lỗi định dạng ngày tháng.

### 1.2. Đứt gãy luồng dữ liệu `campaign_id` trên Lead và Opportunity
- **Hiện trạng:**
  - `LeadDAO.java`: SQL `INSERT` và `UPDATE` thiếu gán trường `campaign_id`; khi lấy danh sách không `LEFT JOIN campaigns` để lấy tên chiến dịch.
  - `OpportunityDAO.java`: Dù bảng `opportunities` có cột `campaign_id`, nhưng câu lệnh SQL `save()`, `update()`, `findById()` hoàn toàn bỏ quên trường này.
  - `OpportunitySaveServlet.java`: Không nhận và phân tích tham số `campaignId` từ form tạo/sửa cơ hội bán hàng.
  - `LeadConversionService.java`: Khi chuyển đổi Lead thành Cơ hội kinh doanh (Opportunity), hệ thống không sao chép `campaign_id` từ Lead sang Opportunity, làm đứt gãy hoàn toàn vết tích ROI của chiến dịch Marketing.
  - `LeadWebFormService.java` & `LeadPublicFormServlet.java`: Không đọc và gán `campaignId` từ form thu thập công khai.

### 1.3. Thống kê ROI Chiến dịch chưa chính xác và giao diện phân mảnh
- **Hiện trạng:** `CampaignDAO.java` chưa tính toán doanh thu thực chốt theo từng giai đoạn thắng cụ thể của dự án (`CLOSED_WON`, `WON`, `HOAN_THANH`, `DA_CHOT`).
- **Giao diện:** Trang danh sách, tạo mới, chỉnh sửa và chi tiết chưa đồng bộ theo **Giao diện chuẩn số 0** của dự án (giao diện mẫu tại `categories/list.jsp` và `assets/css/modules/categories.css`), thiếu thanh Breadcrumb chuẩn SaaS, hero gradient banner, thẻ KPI tổng quan và table tinh gọn.

---

## 2. DANH SÁCH FILE ĐÃ SỬA VÀ NỘI DUNG THAY ĐỔI

| STT | File thay đổi | Lớp / Tầng | Nội dung thay đổi chi tiết |
|:---:|:---|:---:|:---|
| 1 | `com.crm.model.Campaign.java` | Model | Bổ sung `getId()`, `setId()`, `getName()`, `setName()` alias tương thích EL JavaBeans; thêm các trường thống kê `leadCount`, `opportunityCount`, `closedValue`. |
| 2 | `com.crm.dto.CampaignRequest.java` | DTO | Bổ sung `getCampaignId()`, `setCampaignId()`, `getCampaignName()`, `setCampaignName()` đảm bảo không lỗi khi bind dữ liệu trên JSP lúc validation thất bại. |
| 3 | `com.crm.model.Lead.java` | Model | Bổ sung thuộc tính `campaignId` (Integer) và `campaignName` (String) cùng getter/setter. |
| 4 | `com.crm.dto.LeadRequest.java` | DTO | Bổ sung `campaignId`, hỗ trợ parse an toàn chuỗi rỗng / số nguyên. |
| 5 | `com.crm.dto.LeadResponse.java` | DTO | Bổ sung `campaignId` và `campaignName` cho dữ liệu trả về view/API. |
| 6 | `com.crm.dto.LeadImportRequest.java` | DTO | Bổ sung `campaignId` hỗ trợ import danh sách Lead từ Excel gán chiến dịch. |
| 7 | `com.crm.dao.LeadDAO.java` | DAO | Cập nhật SQL `batchCreateLeads`, `createLead`, `updateLead` lưu đúng `campaign_id`; cập nhật `getLeads`, `findById` thực hiện `LEFT JOIN campaigns` ánh xạ `campaign_name`. |
| 8 | `com.crm.model.Opportunity.java` | Model | Bổ sung thuộc tính `campaignId` (Integer) và `campaignName` (String), alias `getId()`, `setId()`. |
| 9 | `com.crm.dao.OpportunityDAO.java` | DAO | Cập nhật SQL `INSERT INTO opportunities` và `UPDATE opportunities` lưu `campaign_id`; cập nhật `findById` và `getList` thực hiện `LEFT JOIN campaigns` đọc tên chiến dịch. |
| 10 | `com.crm.controller.opportunity.OpportunitySaveServlet.java` | Controller | Tiếp nhận `campaignId` từ request form/JSON, xác thực chiến dịch hợp lệ trước khi lưu cơ hội bán hàng. |
| 11 | `com.crm.service.LeadConversionService.java` | Service | Bảo toàn nguồn gốc: sao chép `lead.getCampaignId()` sang `opportunity.setCampaignId()` trong giao dịch chuyển đổi Lead nguyên tử (Atomic Transaction). |
| 12 | `com.crm.service.LeadWebFormService.java` | Service | Nhận `campaignId` từ tham số URL/hidden field khi khách hàng submit form công khai. |
| 13 | `com.crm.controller.lead.LeadPublicFormServlet.java` | Controller | Bổ sung truyền `campaignId` xuống `LeadWebFormService`. |
| 14 | `com.crm.dao.CampaignDAO.java` | DAO | Viết lại hàm `loadMetrics()`: tính `leadCount`, `opportunityCount`, và `closedValue` độc lập bằng các câu truy vấn con, tránh tích Đề-các (Cartesian product) khi JOIN; xử lý điều kiện thắng đa dạng (`CLOSED_WON`, `WON`, `HOAN_THANH`, `DA_CHOT`, `probability = 100`). |
| 15 | `com.crm.controller.campaign.CampaignListServlet.java` | Controller | Tính toán 4 chỉ số KPI tổng quan toàn hệ thống (`totalCampaigns`, `activeCampaigns`, `totalLeads`, `totalWonRevenue`) truyền sang JSP. |
| 16 | `com.crm.controller.campaign.CampaignCreateServlet.java` | Controller | Đảm bảo truyền cả `campaign` và `requestDto` khi có lỗi validate để JSP không mất dữ liệu người dùng đã nhập. |
| 17 | `com.crm.controller.campaign.CampaignUpdateServlet.java` | Controller | Xử lý an toàn `id` / `campaignId`, bắt `NumberFormatException` và `AuthorizationException` theo đúng chuẩn HTTP status. |
| 18 | `assets/css/modules/campaigns.css` | Giao diện | Xây dựng bộ CSS Executive Luxury độc lập theo đúng chuẩn **Giao diện số 0** (`categories.css`): bảng màu Navy/Amber, breadcrumb, hero header gradient, 4 KPI cards, filter section, executive table, form card, action buttons. |
| 19 | `WEB-INF/views/campaigns/list.jsp` | Giao diện | Thiết kế lại toàn bộ trang danh sách theo Giao diện số 0: Hero banner, Policy callout, 4 KPI cards, thanh lọc đa điều kiện, bảng sang trọng với badge kênh và trạng thái, icon action buttons có tooltip. |
| 20 | `WEB-INF/views/campaigns/create.jsp` | Giao diện | Bố cục form 2 cột responsive, đánh dấu trường bắt buộc `*`, giữ lại giá trị cũ nếu validation thất bại, đồng bộ nút `btn-exec-primary` và `btn-exec-light`. |
| 21 | `WEB-INF/views/campaigns/edit.jsp` | Giao diện | Khắc phục triệt để lỗi trang trắng: gọi an toàn `${not empty campaign.campaignId ? campaign.campaignId : campaign.id}`, format ngày `yyyy-MM-dd`, dropdown chọn kênh và trạng thái pre-selected chuẩn xác. |
| 22 | `WEB-INF/views/campaigns/detail.jsp` | Giao diện | Trang chi tiết đồng bộ Giao diện số 0: hiển thị 3 metric cards nổi bật (Số Lead, Số Cơ hội, Doanh thu đã chốt), bảng thông tin chi tiết và nút thao tác nhanh. |
| 23 | `WEB-INF/views/fragments/sidebar.jsp` | Giao diện | Kích hoạt tự động mở dropdown menu "Tiềm năng & Lead" và highlight mục "Chiến dịch Marketing" khi truy cập các URL `/campaigns*`. |
| 24 | `com.crm.service.CampaignTrackingS403Test.java` | Kiểm thử | Bộ test tự động JUnit 5 kiểm thử 4 luồng nghiệp vụ cốt lõi S4-03 trên MySQL thực tế. |

---

## 3. CÁC LUỒNG LEAD VÀ OPPORTUNITY ĐÃ KIỂM TRA

### 3.1. Luồng nhập Lead thủ công
- Giao diện `WEB-INF/views/leads/create.jsp` và Servlet `LeadCreateServlet.java` đã nhận tham số `campaignId`.
- DAO lưu trường `campaign_id` vào bảng `leads` trong cơ sở dữ liệu.
- Mở lại trang chi tiết Lead hoặc danh sách hiển thị tên chiến dịch tương ứng (`LEFT JOIN campaigns c ON l.campaign_id = c.campaign_id`).

### 3.2. Luồng nhập Lead hàng loạt từ Excel
- DTO `LeadImportRequest` tiếp nhận `campaignId`.
- Service và DAO `batchCreateLeads` ánh xạ `campaign_id` vào batch insert JDBC của MySQL.
- Trường hợp file Excel không chứa chiến dịch: `campaign_id = NULL` được xử lý hợp lệ không gây lỗi batch.

### 3.3. Luồng nhận Lead từ Public Web Form
- Khách hàng đăng ký qua form nhúng trực tuyến: `LeadPublicFormServlet.java` đọc `campaignId` từ tham số URL hoặc trường ẩn `<input type="hidden" name="campaignId" ...>`.
- `LeadWebFormService.java` tạo bản ghi Lead tự động mang `campaign_id` của chiến dịch tương ứng.

### 3.4. Luồng Chuyển đổi Lead thành Opportunity (Bảo toàn nguồn gốc)
- Thực hiện tại `LeadConversionService.convertLead()`.
- Phương thức tự động đọc `lead.getCampaignId()` và gán trực tiếp vào `opportunity.setCampaignId(lead.getCampaignId())`.
- Toàn bộ giao dịch tạo Khách hàng, tạo Người liên hệ, tạo Cơ hội và cập nhật trạng thái Lead được bao bọc trong một JDBC Transaction duy nhất (Atomic Commit/Rollback).
- Không bao giờ bị mất liên kết `campaign_id` khi chuyển đổi.

### 3.5. Luồng Tạo / Sửa Opportunity trực tiếp
- `OpportunitySaveServlet.java` trích xuất `campaignId`, kiểm tra sự tồn tại của chiến dịch trong bảng `campaigns`.
- Khi cập nhật Opportunity (đổi giai đoạn sang `CLOSED_WON` hoặc chỉnh sửa giá trị hợp đồng), liên kết `campaign_id` được giữ nguyên vẹn.

---

## 4. KẾT QUẢ XÁC MINH CƠ SỞ DỮ LIỆU THỰC TẾ

Truy vấn đối chiếu trực tiếp trên MySQL Database `crm_db`:
- **Bảng `campaigns`:** Chứa các cột `campaign_id` (PK, INT AUTO_INCREMENT), `campaign_name`, `budget`, `start_date`, `end_date`, `channel`, `description`, `status`, `created_by`, `created_at`, `updated_at`.
- **Bảng `leads`:** Đã có cột `campaign_id INT NULL` tham chiếu `campaigns(campaign_id)`.
- **Bảng `opportunities`:** Đã có cột `campaign_id INT NULL` tham chiếu `campaigns(campaign_id)`.
- **Dữ liệu thực tế:** Các bản ghi cũ không có chiến dịch được giữ nguyên giá trị `NULL` (không ép dữ liệu giả). Các bản ghi mới được kiểm thử tạo thành công với liên kết ID thực tế.

---

## 5. CÔNG THỨC VÀ KẾT QUẢ KIỂM TRA CÁC CHỈ SỐ THỐNG KÊ

### 5.1. Công thức tính toán
Trong `CampaignDAO.java`, để tránh lỗi tích Đề-các khi JOIN nhiều bảng dẫn đến đếm trùng lặp số lượng, câu truy vấn SQL độc lập được thực thi cho từng chiến dịch:

1. **Số Lead (`leadCount`):**
   ```sql
   SELECT COUNT(*) FROM leads WHERE campaign_id = ?
   ```
2. **Số Cơ hội (`opportunityCount`):**
   ```sql
   SELECT COUNT(*) FROM opportunities WHERE campaign_id = ?
   ```
3. **Doanh thu đã chốt (`closedValue`):**
   ```sql
   SELECT COALESCE(SUM(expected_revenue), 0) FROM opportunities 
   WHERE campaign_id = ? 
     AND (stage_id IN ('CLOSED_WON', 'WON', 'HOAN_THANH', 'DA_CHOT') 
          OR is_won = 1 
          OR (probability = 100 AND is_closed = 1))
   ```

*Nguyên tắc nghiệm thu:*
- Không tính các cơ hội chỉ có xác suất 100% nhưng chưa đóng hoặc chưa đạt trạng thái thắng.
- Xử lý `NULL` an toàn bằng `COALESCE(..., 0)`.
- Thống nhất tuyệt đối công thức giữa trang danh sách và trang chi tiết chiến dịch.

### 5.2. Kết quả kiểm thử tự động trên JUnit
```
[INFO] Running com.crm.service.CampaignTrackingS403Test
INFO: Tạo thành công chiến dịch id=18 bởi userId=1
INFO: Lead 9999 converted successfully in single atomic transaction.
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 1.687 s
[INFO] BUILD SUCCESS
```

---

## 6. ĐỒNG BỘ CÁC TRANG THEO GIAO DIỆN SỐ 0

Tham chiếu từ file chuẩn `categories/list.jsp` và `assets/css/modules/categories.css`, module Chiến dịch Marketing đã được đồng bộ 100% toàn diện:

1. **Bảng màu & Design Tokens:**
   - Màu chủ đạo Navy Blue: `--crm-primary: #1e3a8a`, hover `#172554`, background `#eff6ff`.
   - Màu nhấn Amber: `--crm-accent: #d97706`, nền thẻ `#fffbeb`.
   - Nền trang xám nhạt cao cấp `--crm-bg: #f8fafc`, viền thẻ `--crm-border: #e2e8f0`.
2. **Breadcrumb chuẩn:** `<div class="exec-breadcrumb">` hiển thị phân cấp Trang chủ > Marketing > Tên trang với icon FontAwesome 6.
3. **Exec-Hero Banner:** Gradient nền chuyển màu, tiêu đề `h1` sang trọng với icon vàng hoàng kim, mô tả ngắn gọn và nhóm nút thao tác nổi.
4. **4 Metric KPI Cards:** Bố trí lưới 4 cột responsive với icon hình hộp bo góc (Blue, Emerald, Indigo, Amber) thể hiện rõ ràng các chỉ số cốt lõi.
5. **Thanh lọc & Tìm kiếm:** Bố trí gọn gàng, input có icon kính lúp, select box có border hover mượt mà.
6. **Bảng dữ liệu Executive Table:** Header chữ hoa màu xám nhạt (`#f8fafc`), bo góc thẻ `12px`, badge kênh phân biệt màu rõ ràng (Email: xanh biển, Social: hồng tím, Search: xanh lá, Event: hổ phách), cột doanh thu in đậm màu xanh lá kèm ký hiệu `đ`.
7. **Form tạo mới & chỉnh sửa:** Bố trí trong `exec-form-card`, căn chỉnh lưới 2 cột khoa học, giữ lại dữ liệu khi validate lỗi.

---

## 7. NGUYÊN NHÂN VÀ CÁCH SỬA LỖI TRANG TRẮNG KHI CHỈNH SỬA

### Tóm tắt nguyên nhân gốc:
Jasper JSP engine trong Tomcat 10.1 ném `PropertyNotFoundException: Property [id] not found on type [com.crm.model.Campaign]` khi gặp `${campaign.id}` do model `Campaign.java` ban đầu chỉ có `campaignId` chứ không có getter `getId()`.

### Các giải pháp triệt để đã triển khai:
1. **Model:** Bổ sung phương thức `getId()`, `setId()`, `getName()`, `setName()` vào `Campaign.java`.
2. **DTO:** Bổ sung `getCampaignName()`, `setCampaignName()`, `getCampaignId()`, `setCampaignId()` vào `CampaignRequest.java`.
3. **JSP (`edit.jsp`):**
   - Đổi thẻ hidden thành: `<input type="hidden" name="id" value="${not empty campaign.campaignId ? campaign.campaignId : campaign.id}" />`.
   - Đổi hiển thị tên thành: `<c:out value="${not empty campaign.campaignName ? campaign.campaignName : campaign.name}" />`.
   - Thêm taglib formatting: `<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>`.
   - Định dạng ngày tháng: `<fmt:formatDate value="${campaign.startDate}" pattern="yyyy-MM-dd" />`.
   - Dropdown Kênh và Trạng thái sử dụng toán tử so sánh chuỗi `eq` an toàn.
4. **Servlet:** Tiếp nhận cả `id` và `campaignId`, xử lý bắt lỗi số nguyên và điều hướng thông báo lỗi nếu ID không tồn tại.

---

## 8. BẢNG KIỂM THỬ PASS/FAIL VÀ BẰNG CHỨNG THỰC TẾ

Kiểm thử trực tiếp trên ứng dụng Tomcat đang chạy tại `http://localhost:8080/crm-backend-1.0.0`:

| STT | Kịch bản kiểm thử | Dữ liệu đầu vào | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
|:---:|:---|:---|:---|:---|:---:|
| TC-01 | Đăng nhập hệ thống Marketing/Admin | `admin@company.com` / `Admin12345` | Đăng nhập thành công, tạo session | HTTP 302 -> 200, Session hợp lệ | **PASS** |
| TC-02 | Tải trang danh sách Chiến dịch | GET `/campaigns` | HTTP 200, hiển thị chuẩn Giao diện số 0, đầy đủ Hero, 4 KPI cards, Table | HTTP 200, length 83,291 bytes, chứa `exec-hero`, `metrics-grid`, `exec-table` | **PASS** |
| TC-03 | Mở trang chỉnh sửa chiến dịch (Lỗi trang trắng cũ) | GET `/campaigns/edit?id=1` | HTTP 200, KHÔNG TRANG TRẮNG, form điền sẵn dữ liệu chiến dịch cũ | HTTP 200, length 56,265 bytes, form chứa đúng ID=1, đầy đủ input và style | **PASS** |
| TC-04 | Mở trang tạo mới chiến dịch | GET `/campaigns/create` | HTTP 200, form chuẩn Giao diện số 0, trống dữ liệu, sẵn sàng nhập | HTTP 200, chứa `exec-form-card`, `btn-exec-primary` | **PASS** |
| TC-05 | Mở trang chi tiết chiến dịch | GET `/campaigns/detail?id=1` | HTTP 200, hiển thị 3 metric cards (Lead, Opp, Doanh thu đã chốt) | HTTP 200, chứa `exec-detail-card`, metric KPI cards | **PASS** |
| TC-06 | Lưu cập nhật chiến dịch qua form POST | POST `/campaigns/edit` với `id=1, budget=65000000, channel=Social` | Cập nhật thành công vào MySQL, chuyển hướng về trang chi tiết | HTTP 302 -> 200 `/campaigns/detail?id=1&updated=true` | **PASS** |
| TC-07 | Kiểm thử chuyển đổi Lead sang Opportunity giữ nguồn | Chuyển đổi Lead ID 9999 có `campaign_id=18` | Opportunity mới tạo có đúng `campaign_id=18` | Khẳng định bởi `CampaignTrackingS403Test.testC_OpportunityCampaignLink` | **PASS** |
| TC-08 | Kiểm thử tính toán 3 chỉ số ROI chiến dịch | Chiến dịch có 2 Lead, 2 Opp, 1 Opp Won 50.000.000 đ | `leadCount=2, oppCount=2, closedValue=50,000,000` | Khẳng định bởi `CampaignTrackingS403Test.testD_CampaignMetricsCalculation` | **PASS** |
| TC-09 | Xử lý ID không tồn tại | GET `/campaigns/edit?id=99999` | Trả về HTTP 404 Không tìm thấy, không crash hệ thống | HTTP 404 Not Found trả về đúng chuẩn | **PASS** |

---

## 9. KẾT QUẢ XÁC NHẬN DEPLOY TRÊN TOMCAT ĐANG CHẠY

- **Đường dẫn Webapp:** `C:\apache-tomcat-10.1.60\webapps\crm-backend-1.0.0\`
- **Trạng thái biên dịch:** `mvn compile` thành công (Total time: 16.313s, 238 source files).
- **Trạng thái triển khai:**
  - `WEB-INF/classes/` đã cập nhật toàn bộ `.class` mới nhất (bao gồm `Campaign.class`, `CampaignRequest.class`, `LeadDAO.class`, `OpportunityDAO.class`, `CampaignDAO.class`).
  - `WEB-INF/views/campaigns/` đã cập nhật `list.jsp`, `create.jsp`, `edit.jsp`, `detail.jsp`.
  - `assets/css/modules/` đã cập nhật `campaigns.css`.
  - Thư mục JSP cache trong Tomcat `work/Catalina/localhost/crm-backend-1.0.0/org/apache/jsp/WEB_002dINF/views/campaigns` đã được dọn sạch và Tomcat tự động biên dịch lại khi nhận request mới.
- **Xác nhận Runtime:** Script kiểm thử tự động đã gửi request trực tiếp đến cổng 8080 của Tomcat và xác nhận 100% trang hiển thị với đầy đủ CSS tokens, không còn bất kỳ lỗi nào trong log `catalina.out` hay `localhost.log`.

---

## 10. KẾT LUẬN VÀ CÁC ĐIỂM LƯU Ý

- **Kết luận:** Toàn bộ 3 nhóm công việc của TASK S4-03 đã được hoàn thành trọn vẹn:
  1. Luồng dữ liệu nghiệp vụ: `campaign_id` được liên kết chuẩn xác trên toàn bộ vòng đời từ Campaign -> Lead -> Opportunity.
  2. Giao diện: Tái thiết kế đồng bộ 4 trang (`list`, `create`, `edit`, `detail`) theo đúng **Giao diện chuẩn số 0**.
  3. Lỗi trang trắng khi chỉnh sửa chiến dịch: Đã tìm đúng nguyên nhân gốc tại Jasper Jakarta EL và sửa dứt điểm, đã kiểm chứng bằng request thực tế.
- **Lưu ý vận hành:** Khi thêm mới các giai đoạn bán hàng trong tương lai tại mục Cấu hình Pipeline, hãy đảm bảo các giai đoạn chiến thắng mang mã nhận diện `WON` hoặc `is_won = 1` để hệ thống tự động tổng hợp vào chỉ số Doanh thu đã chốt của chiến dịch.
