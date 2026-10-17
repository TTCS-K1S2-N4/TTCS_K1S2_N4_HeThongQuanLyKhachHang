# BÁO CÁO HOÀN THIỆN TÍNH NĂNG DRILL-DOWN DỮ LIỆU TRANG CHI TIẾT CHIẾN DỊCH MARKETING
**Mã tài liệu:** `S4-03_CAMPAIGN_DETAIL_DRILLDOWN_REPORT.md`  
**User Story:** S4-03 — Theo dõi Lead, Cơ hội và Doanh thu thực tế theo từng chiến dịch Marketing  
**Trạng thái kiểm thử:** PASS 100% (Xác thực trên Tomcat 10.1.60 & MySQL 8.0 thực tế)  
**Ngày thực hiện:** 17/10/2026  

---

## 1. Danh sách các file đã tạo và chỉnh sửa

### 1.1. Model & DTO
1. [`Backend/src/main/java/com/crm/model/Lead.java`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/model/Lead.java)
   - Bổ sung alias method `getId()` trả về `getLeadId()` nhằm đồng bộ với các biểu thức EL `${lead.id}` và `${lead.leadId}` trong JSP.
2. [`Backend/src/main/java/com/crm/model/Opportunity.java`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/model/Opportunity.java)
   - Bổ sung 2 trường hiển thị `customerName` và `ownerName` kèm getter/setter để hiển thị tên khách hàng và người phụ trách trong bảng drill-down.

### 1.2. DAO & Service
3. [`Backend/src/main/java/com/crm/dao/CampaignDAO.java`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/dao/CampaignDAO.java)
   - `getLeadsByCampaignId(int campaignId)`: Truy vấn danh sách Lead theo `campaign_id` liên kết `lead_sources` và `users`, sắp xếp mới nhất lên đầu.
   - `getOpportunitiesByCampaignId(int campaignId)`: Truy vấn danh sách Cơ hội theo `campaign_id` liên kết `customers`, `users`, `pipeline_stages`.
   - `getClosedWonOpportunitiesByCampaignId(int campaignId)`: Truy vấn các cơ hội chốt thắng thành công theo điều kiện chuẩn `(UPPER(stage) LIKE '%WON%' OR UPPER(status) LIKE '%WON%') AND UPPER(stage) NOT LIKE '%LOST%' AND UPPER(status) NOT LIKE '%LOST%'`. Đồng bộ 100% với công thức tính tổng trong `loadMetrics()`.
4. [`Backend/src/main/java/com/crm/service/CampaignService.java`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/service/CampaignService.java)
   - Bổ sung 3 phương thức nghiệp vụ: `getCampaignLeads`, `getCampaignOpportunities`, `getCampaignClosedWonOpportunities`.
   - Thực hiện kiểm tra quyền truy cập và chống IDOR thông qua `getCampaignDetail(...)` trước khi lấy dữ liệu danh sách chi tiết.

### 1.3. Controller & Servlet
5. [`Backend/src/main/java/com/crm/controller/campaign/CampaignDetailServlet.java`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/java/com/crm/controller/campaign/CampaignDetailServlet.java)
   - Tải đầy đủ 3 tập dữ liệu danh sách chi tiết: `campaignLeads`, `campaignOpportunities`, `campaignClosedWonOpps`.
   - Đưa vào `request.setAttribute` để JSP render theo cấu trúc Frostline Executive.

### 1.4. Giao diện người dùng (JSP & CSS)
6. [`Backend/src/main/webapp/WEB-INF/views/campaigns/detail.jsp`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/webapp/WEB-INF/views/campaigns/detail.jsp)
   - Nâng cấp 3 thẻ thống kê KPI thành thẻ tương tác đa chức năng: có hiệu ứng hover luxury, border highlight, footer "Xem danh sách" / "Xem giao dịch", hỗ trợ click chuột và phím Enter/Space (`tabindex="0"`).
   - Bổ sung phân khu Drill-down `#drilldown-section` với 3 Tab chuyên biệt:
     - **Tab 1: Danh sách Lead sinh ra**: Bảng chi tiết gồm Mã Lead, Họ tên, Email, SĐT, Công ty, Trạng thái (badge), Ngày tạo, Người phụ trách, Thao tác "Chi tiết" liên kết `/leads/detail?id=...`.
     - **Tab 2: Cơ hội bán hàng (Opportunity)**: Bảng chi tiết gồm Mã Cơ hội, Tên Cơ hội, Khách hàng, Giá trị cơ hội, Giai đoạn pipeline (badge), Trạng thái, Ngày tạo/dự kiến chốt, Người phụ trách, Thao tác "Chi tiết" liên kết `/deals/detail?id=...`.
     - **Tab 3: Doanh thu đã chốt (Closed Won)**: Banner xác nhận khớp 100% doanh thu, bảng giao dịch thắng với giá trị doanh thu thực tế được cộng dồn, ngày chốt, người phụ trách và liên kết chi tiết `/deals/detail?id=...`.
   - Bộ lọc tìm kiếm nhanh Client-side (`filterDrilldownTable`) lọc real-time trên bảng đang kích hoạt.
   - Trạng thái rỗng (Empty state) cho từng tab khi chiến dịch chưa có Lead, Cơ hội hoặc Doanh thu.
7. [`Backend/src/main/webapp/assets/css/modules/campaigns.css`](file:///c:/Users/tuyet/Downloads/TTCS_K1S2_N4_HeThongQuanLyKhachHang/TTCS_K1S2_N4_HeThongQuanLyKhachHang/Backend/src/main/webapp/assets/css/modules/campaigns.css)
   - Thêm bộ rules CSS cho Executive Drilldown: `.metric-card-interactive`, `.drilldown-section`, `.drilldown-nav-tabs`, `.won-revenue-banner`, `.btn-table-action`, `.code-badge`.

---

## 2. Mô tả luồng dữ liệu nghiệp vụ (Data Flow)

```
[Trình duyệt / Người dùng]
       │
       ▼ (1) Click thẻ KPI hoặc nút "Xem danh sách" / "Xem giao dịch"
[detail.jsp] ──(Tải ban đầu)──► [CampaignDetailServlet.java]
                                         │
                                         ▼ (2) getCampaignDetail + validateCampaignAccess (Chống IDOR)
                                 [CampaignService.java]
                                         │
                    ┌────────────────────┼────────────────────┐
                    ▼                    ▼                    ▼
          getCampaignLeads    getCampaignOpportunities  getCampaignClosedWonOpportunities
                    │                    │                    │
                    └────────────────────┼────────────────────┘
                                         ▼ (3) PreparedStatement (Tham số hóa an toàn)
                                  [CampaignDAO.java]
                                         │
                                         ▼ (4) SQL độc lập từng bảng (Tránh fan-out Cartesian product)
                                 [MySQL Database]
                                   ├── leads (campaign_id = ?)
                                   └── opportunities (campaign_id = ?)
                                         │
                                         ▼ (5) Map DTO & chuyển tiếp về Request Attributes
                                [CampaignDetailServlet]
                                         │
                                         ▼ (6) Render bảng Frostline Luxury + Tab chuyển đổi
                                 [detail.jsp]
```

### Cách thức liên kết Campaign, Lead, Opportunity và Doanh thu:
1. **Chiến dịch → Lead**: Liên kết qua trường `leads.campaign_id = campaigns.campaign_id`. Mỗi khi có khách hàng tiềm năng sinh ra từ kênh/chiến dịch này, Lead được gán trực tiếp ID chiến dịch.
2. **Chiến dịch → Opportunity**: Liên kết qua trường `opportunities.campaign_id = campaigns.campaign_id` (được bảo toàn tự động khi chuyển đổi từ Lead sang Opportunity). 
3. **Doanh thu đã chốt (Closed Won)**:
   - Điều kiện xác định doanh thu chốt thắng trong hệ thống:
     `(UPPER(stage) LIKE '%WON%' OR UPPER(status) LIKE '%WON%') AND UPPER(stage) NOT LIKE '%LOST%' AND UPPER(status) NOT LIKE '%LOST%'`.
   - Bảng Closed Won chỉ liệt kê đúng những Opportunity thỏa mãn điều kiện này, cộng dồn tổng tiền `SUM(amount)` và đối chiếu với con số hiển thị trên thẻ KPI Closed Won. Đảm bảo tính nhất quán 100%.

---

## 3. Kết quả kiểm thử thực tế (Test Results)

Hệ thống kiểm thử tự động `test_drilldown_suite.py` được thực thi trực tiếp trên môi trường máy chủ đang chạy:

| STT | Kịch bản kiểm thử | Kết quả | Bằng chứng thực tế (Evidence) |
|---|---|:---:|---|
| 1 | Xác thực đăng nhập phiên làm việc | **PASS** | HTTP 200, Session Cookie được cấp phát hợp lệ |
| 2 | Truy cập chi tiết Chiến dịch ID=1 có đầy đủ dữ liệu | **PASS** | HTTP 200, HTML trả về 98.335 bytes |
| 3 | Kiểm tra 3 thẻ thống kê KPI tương tác | **PASS** | Tồn tại `card-metric-leads`, `card-metric-opps`, `card-metric-won` kèm hàm `switchDrilldownTab` |
| 4 | Bảng danh sách Lead của Chiến dịch 1 | **PASS** | Hiển thị chính xác 5 Lead (Mã `#L-1`, `#L-2`, `#L-4`, `#L-5`, `#L-39`), có link `/leads/detail?id=...` |
| 5 | Bảng Cơ hội bán hàng của Chiến dịch 1 | **PASS** | Hiển thị 2 cơ hội (`#OPP-9812` - PROSPECTING, `#OPP-8024` - WON), có link `/deals/detail?id=...` |
| 6 | Bảng Doanh thu đã chốt (Closed Won) | **PASS** | Hiển thị 1 giao dịch thắng `#OPP-8024`, tổng tiền `200.000.000 VNĐ` khớp 100% với thẻ KPI |
| 7 | Bảng banner đối soát doanh thu | **PASS** | Banner hiển thị `200.000.000 VNĐ` kèm tag kiểm tra "Khớp 100% với thẻ chỉ số Doanh thu" |
| 8 | Chiến dịch có Lead nhưng chưa có Opportunity (ID=2) | **PASS** | Tab Lead có 2 bản ghi (`#L-3`, `#L-9`); Tab Cơ hội & Doanh thu hiển thị Empty State chuẩn |
| 9 | Chiến dịch hoàn toàn rỗng (ID=3) | **PASS** | Cả 3 tab đều hiển thị Empty State chuyên nghiệp với icon minh họa, không có lỗi JS/HTML |
| 10 | Kiểm tra ID chiến dịch không tồn tại (ID=999999) | **PASS** | Trả về mã lỗi HTTP 404 Not Found theo chuẩn REST |
| 11 | API JSON endpoint (`format=json`) | **PASS** | Trả về JSON chuẩn: `leadCount=5`, `oppCount=2`, `closedValue=200000000.0` |
| 12 | Kiểm tra hồi quy các chức năng CRUD Chiến dịch | **PASS** | Danh sách `/campaigns`, Tạo mới `/campaigns/create`, Cập nhật `/campaigns/edit` hoạt động ổn định |

---

## 4. Minh bạch phạm vi kiểm chứng

- **Đã kiểm chứng (Verified):**
  - Toàn bộ luồng truy vấn database thật (MySQL: `leads`, `opportunities`, `campaigns`, `customers`, `users`).
  - Toàn bộ UI/UX tương tác trên giao diện Frostline CRM qua Tomcat 10.1.60.
  - Xử lý phân trang/tìm kiếm trực tiếp và hiển thị empty state khi dữ liệu trống.
  - Phân quyền theo DataScope và xử lý mã lỗi 404/403.
- **Lưu ý nghiệp vụ:**
  - Hệ thống hiện tại lưu trữ giao dịch thắng thông qua bảng `opportunities` với `stage='WON'` và trường `amount`. Việc không tạo bảng `contracts` mới đã tuân thủ đúng yêu cầu bảo toàn kiến trúc của dự án.
