package com.crm.controller.customer;

import com.crm.dto.CustomerImportRequest;
import com.crm.service.CustomerImportService;
import com.crm.service.PermissionService;
import com.crm.util.ExcelImportUtil;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@WebServlet({ "/customers/import", "/customers/import/template", "/customers/import/preview", "/customers/import/execute" })
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 15      // 15MB
)
public class CustomerImportServlet extends HttpServlet {

    private CustomerImportService customerImportService;
    private PermissionService permissionService;

    @Override
    public void init() throws ServletException {
        this.customerImportService = new CustomerImportService();
        this.permissionService = new PermissionService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        Integer userId = getUserIdFromSession(request);
        if (userId == null) {
            handleUnauthorized(request, response);
            return;
        }

        if ("/customers/import".equals(path)) {
            request.getRequestDispatcher("/WEB-INF/views/customers/import.jsp").forward(request, response);
        } else if ("/customers/import/template".equals(path)) {
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"Customer_Import_Template.xlsx\"");

            try (Workbook workbook = new XSSFWorkbook();
                 OutputStream out = response.getOutputStream()) {

                Sheet sheet = workbook.createSheet("KhachHang");

                Row header = sheet.createRow(0);
                header.createCell(0).setCellValue("Tên khách hàng (*)");
                header.createCell(1).setCellValue("Số điện thoại");
                header.createCell(2).setCellValue("Mã số thuế");
                header.createCell(3).setCellValue("Ngành nghề");
                header.createCell(4).setCellValue("Quy mô");
                header.createCell(5).setCellValue("Website");
                header.createCell(6).setCellValue("Địa chỉ");
                header.createCell(7).setCellValue("Trạng thái");

                Row example = sheet.createRow(1);
                example.createCell(0).setCellValue("Công ty TNHH Mẫu");
                example.createCell(1).setCellValue("0987654321");
                example.createCell(2).setCellValue("0101234567");
                example.createCell(3).setCellValue("Công nghệ");
                example.createCell(4).setCellValue("50-100");
                example.createCell(5).setCellValue("https://example.com");
                example.createCell(6).setCellValue("123 Nguyễn Trãi, Hà Nội");
                example.createCell(7).setCellValue("ACTIVE");

                for (int i = 0; i <= 7; i++) {
                    sheet.autoSizeColumn(i);
                }

                workbook.write(out);
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        Integer userId = getUserIdFromSession(request);
        if (userId == null) {
            handleUnauthorized(request, response);
            return;
        }

        List<Integer> accessibleOwnerIds = getAccessibleOwnerIds(request, userId);

        if ("/customers/import/preview".equals(path)) {
            Part filePart = null;
            try {
                filePart = request.getPart("file");
            } catch (Exception e) {
                writeErrorJsonOrForward(request, response, HttpServletResponse.SC_BAD_REQUEST, "Kích thước file vượt quá giới hạn cho phép (tối đa 10MB).");
                return;
            }

            if (filePart == null || filePart.getSize() == 0) {
                writeErrorJsonOrForward(request, response, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn file Excel để tải lên.");
                return;
            }

            String submittedFileName = filePart.getSubmittedFileName();
            if (submittedFileName == null || (!submittedFileName.toLowerCase().endsWith(".xlsx") && !submittedFileName.toLowerCase().endsWith(".xls"))) {
                writeErrorJsonOrForward(request, response, HttpServletResponse.SC_BAD_REQUEST, "Chỉ chấp nhận tệp định dạng Excel (.xlsx hoặc .xls).");
                return;
            }

            try (InputStream is = filePart.getInputStream()) {
                List<CustomerImportRequest> rows = ExcelImportUtil.parseCustomerImport(is);
                Map<String, Object> result = customerImportService.validatePreview(rows, userId, accessibleOwnerIds);

                request.getSession().setAttribute("customerImportPreviewRows", rows);

                if (isJsonRequest(request)) {
                    writeJsonResponse(response, result);
                } else {
                    request.setAttribute("validRows", result.get("validRows"));
                    request.setAttribute("invalidRows", result.get("invalidRows"));
                    request.setAttribute("duplicates", result.get("duplicates"));
                    request.setAttribute("rowErrors", result.get("rowErrors"));
                    request.setAttribute("totalRows", result.get("totalRows"));
                    request.getRequestDispatcher("/WEB-INF/views/customers/import.jsp").forward(request, response);
                }
            } catch (Exception e) {
                writeErrorJsonOrForward(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi xử lý đọc file Excel: " + e.getMessage());
            }

        } else if ("/customers/import/execute".equals(path)) {
            String duplicateAction = request.getParameter("duplicateAction");
            if (duplicateAction == null || duplicateAction.trim().isEmpty()) {
                duplicateAction = "SKIP";
            }

            @SuppressWarnings("unchecked")
            List<CustomerImportRequest> rows = (List<CustomerImportRequest>) request.getSession().getAttribute("customerImportPreviewRows");

            if (rows == null || rows.isEmpty()) {
                writeErrorJsonOrForward(request, response, HttpServletResponse.SC_BAD_REQUEST, "Không tìm thấy dữ liệu xem trước. Vui lòng tải lên và xem trước file trước khi thực thi.");
                return;
            }

            Map<String, Object> result = customerImportService.executeImport(rows, duplicateAction, userId, accessibleOwnerIds);

            request.getSession().removeAttribute("customerImportPreviewRows");

            if (isJsonRequest(request)) {
                writeJsonResponse(response, result);
            } else {
                request.setAttribute("total", result.get("totalRows"));
                request.setAttribute("success", result.get("successCount"));
                request.setAttribute("failed", result.get("failedCount"));
                request.setAttribute("skipped", result.get("skippedCount"));
                request.setAttribute("errors", result.get("errors"));
                request.setAttribute("message", "Thực thi import hoàn tất. Thành công: " + result.get("successCount") + ", Thất bại: " + result.get("failedCount"));
                request.getRequestDispatcher("/WEB-INF/views/customers/import.jsp").forward(request, response);
            }

        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private Integer getUserIdFromSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("userId") instanceof Integer) {
            return (Integer) session.getAttribute("userId");
        }
        return null;
    }

    private List<Integer> getAccessibleOwnerIds(HttpServletRequest request, int userId) {
        HttpSession session = request.getSession(false);
        Integer roleId = (session != null && session.getAttribute("roleId") instanceof Integer)
                ? (Integer) session.getAttribute("roleId")
                : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(request.getAttribute("effectiveRoleIds"));
        if (roleIds == null || roleIds.isEmpty()) {
            if (roleId != null) {
                roleIds = Collections.singletonList(roleId);
            }
        }
        if (roleIds == null || roleIds.isEmpty()) {
            return Collections.singletonList(userId);
        }
        return permissionService.getAccessibleAccountIdsForRoles(userId, roleIds, "ACCOUNT");
    }

    private boolean isJsonRequest(HttpServletRequest request) {
        String acceptHeader = request.getHeader("Accept");
        String requestedWith = request.getHeader("X-Requested-With");
        return (acceptHeader != null && acceptHeader.contains("application/json"))
                || "XMLHttpRequest".equalsIgnoreCase(requestedWith);
    }

    private void handleUnauthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (isJsonRequest(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"Bạn cần đăng nhập để thực hiện chức năng này.\"}");
        } else {
            response.sendRedirect(request.getContextPath() + "/auth/login");
        }
    }

    private void writeErrorJsonOrForward(HttpServletRequest request, HttpServletResponse response, int status, String errorMessage) throws IOException, ServletException {
        if (isJsonRequest(request)) {
            response.setStatus(status);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"" + escapeJson(errorMessage) + "\"}");
        } else {
            response.setStatus(status);
            request.setAttribute("errorMessage", errorMessage);
            request.getRequestDispatcher("/WEB-INF/views/customers/import.jsp").forward(request, response);
        }
    }

    private void writeJsonResponse(HttpServletResponse response, Map<String, Object> map) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) json.append(",");
            json.append("\"").append(escapeJson(entry.getKey())).append("\":");
            json.append(toJsonValue(entry.getValue()));
            first = false;
        }
        json.append("}");
        response.getWriter().write(json.toString());
    }

    private String toJsonValue(Object value) {
        if (value == null) return "null";
        if (value instanceof Number || value instanceof Boolean) return value.toString();
        if (value instanceof List<?>) {
            StringBuilder sb = new StringBuilder("[");
            List<?> list = (List<?>) value;
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append(toJsonValue(list.get(i)));
            }
            sb.append("]");
            return sb.toString();
        }
        if (value instanceof CustomerImportRequest) {
            CustomerImportRequest req = (CustomerImportRequest) value;
            return String.format(
                "{\"rowIndex\":%d,\"customerName\":\"%s\",\"phone\":\"%s\",\"taxCode\":\"%s\",\"valid\":%b,\"duplicate\":%b,\"duplicateReason\":\"%s\",\"error\":\"%s\"}",
                req.getRowIndex(),
                escapeJson(req.getCustomerName()),
                escapeJson(req.getPhone()),
                escapeJson(req.getTaxCode()),
                req.isValid(),
                req.isDuplicate(),
                escapeJson(req.getDuplicateReason()),
                escapeJson(req.getError())
            );
        }
        return "\"" + escapeJson(value.toString()) + "\"";
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
