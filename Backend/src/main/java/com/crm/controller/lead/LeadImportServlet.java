package com.crm.controller.lead;

import com.crm.dao.LeadSourceDAO;
import com.crm.dto.LeadImportRequest;
import com.crm.model.LeadSource;
import com.crm.service.LeadImportService;
import com.crm.service.LeadImportService.ImportResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet(urlPatterns = {
    "/leads/import",
    "/leads/import/preview",
    "/leads/import/commit",
    "/leads/import/template",
    "/leads/import/sample"
})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 20 * 1024 * 1024)
public class LeadImportServlet extends HttpServlet {

    private LeadImportService importService = new LeadImportService();
    private LeadSourceDAO sourceDAO = new LeadSourceDAO();

    public static class PreviewRowItem {
        private int rowNumber;
        private String fullName;
        private String email;
        private String phone;
        private String errors;

        public PreviewRowItem(int rowNumber, String fullName, String email, String phone, String errors) {
            this.rowNumber = rowNumber;
            this.fullName = fullName;
            this.email = email;
            this.phone = phone;
            this.errors = errors;
        }

        public int getRowNumber() { return rowNumber; }
        public String getFullName() { return fullName; }
        public String getEmail() { return email; }
        public String getPhone() { return phone; }
        public String getErrors() { return errors; }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        String action = req.getParameter("action");

        // 1. Endpoint tải file Excel mẫu (.xlsx) gồm đúng 10 cột
        if (uri.endsWith("/template") || uri.endsWith("/sample") || "template".equalsIgnoreCase(action) || "sample".equalsIgnoreCase(action)) {
            downloadExcelTemplate(resp);
            return;
        }

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            if (isJsonRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        List<LeadSource> sources = sourceDAO.getActiveSources();
        req.setAttribute("sources", sources);

        if (req.getParameter("imported") != null) {
            req.setAttribute("successMessage", "Nhập thành công " + req.getParameter("imported") + " Lead vào hệ thống!");
        }

        req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        boolean isJson = isJsonRequest(req);

        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String uri = req.getRequestURI();
        String action = req.getParameter("action");

        if (uri.endsWith("/commit") || "commit".equalsIgnoreCase(action) || "execute".equalsIgnoreCase(action)) {
            handleExecuteImport(req, resp, session, isJson);
        } else {
            handlePreviewImport(req, resp, session, userId, isJson);
        }
    }

    private void handlePreviewImport(HttpServletRequest req, HttpServletResponse resp, HttpSession session, Integer userId, boolean isJson)
            throws ServletException, IOException {
        Part filePart = null;
        try {
            filePart = req.getPart("file");
        } catch (Exception ignore) {}

        if (filePart == null || filePart.getSize() <= 0) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn file Excel để upload.");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST, "Định dạng file không được hỗ trợ. Vui lòng upload file Excel (.xlsx, .xls).");
            return;
        }

        String globalSourceStr = req.getParameter("source");
        Integer globalSourceId = null;
        if (globalSourceStr != null && !globalSourceStr.trim().isEmpty()) {
            try {
                globalSourceId = Integer.parseInt(globalSourceStr.trim());
            } catch (NumberFormatException ignore) {}
        }

        try (InputStream is = filePart.getInputStream()) {
            ImportResult result = importService.parseAndValidateExcel(is, userId, globalSourceId);

            String importToken = UUID.randomUUID().toString();
            session.setAttribute("pendingLeadImportRequests", result.getDetails());
            session.setAttribute("pending_import_" + importToken, result.getDetails());

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(buildPreviewJson(result, importToken));
            } else {
                List<PreviewRowItem> previewRows = new ArrayList<>();
                for (LeadImportRequest r : result.getDetails()) {
                    String error = "";
                    if (r.getError() != null && !r.getError().trim().isEmpty()) {
                        error = r.getError();
                    } else if (r.isDuplicate()) {
                        error = r.getDuplicateReason();
                    }
                    previewRows.add(new PreviewRowItem(r.getRowIndex(), r.getFullName(), r.getEmail(), r.getPhone(), error));
                }

                req.setAttribute("previewMode", true);
                req.setAttribute("validCount", result.getValidRows());
                req.setAttribute("invalidCount", result.getFailedRows() + result.getDuplicateRows());
                req.setAttribute("previewRows", previewRows);
                req.setAttribute("importToken", importToken);
                req.setAttribute("sources", sourceDAO.getActiveSources());
                req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi đọc file Excel: " + e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    private void handleExecuteImport(HttpServletRequest req, HttpServletResponse resp, HttpSession session, boolean isJson)
            throws ServletException, IOException {
        String importToken = req.getParameter("importToken");
        List<LeadImportRequest> pendingRequests = null;

        if (importToken != null && !importToken.trim().isEmpty()) {
            pendingRequests = (List<LeadImportRequest>) session.getAttribute("pending_import_" + importToken.trim());
        }
        if (pendingRequests == null) {
            pendingRequests = (List<LeadImportRequest>) session.getAttribute("pendingLeadImportRequests");
        }

        if (pendingRequests == null || pendingRequests.isEmpty()) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST, "Không có dữ liệu import chờ xử lý hoặc phiên đã hết hạn. Vui lòng upload lại file Excel.");
            return;
        }

        boolean skipDuplicates = req.getParameter("skipDuplicates") == null || "true".equalsIgnoreCase(req.getParameter("skipDuplicates")) || "on".equalsIgnoreCase(req.getParameter("skipDuplicates"));

        int importedCount = importService.executeImport(pendingRequests, skipDuplicates);

        session.removeAttribute("pendingLeadImportRequests");
        if (importToken != null) {
            session.removeAttribute("pending_import_" + importToken.trim());
        }

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"success\",\"message\":\"Import thành công " + importedCount + " Lead vào hệ thống!\",\"importedCount\":" + importedCount + "}");
        } else {
            resp.sendRedirect(req.getContextPath() + "/leads?imported=" + importedCount);
        }
    }

    private void downloadExcelTemplate(HttpServletResponse resp) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Danh sách Lead");

            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerFont.setFontHeightInPoints((short) 11);

            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.ROYAL_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);

            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);

            // Đúng 10 cột theo yêu cầu S402
            String[] headers = {
                "Họ và tên",
                "Chức danh",
                "Công ty",
                "Email",
                "Số điện thoại",
                "Nguồn Lead",
                "Trạng thái",
                "Đánh giá",
                "Ngành nghề",
                "Ghi chú"
            };

            Row headerRow = sheet.createRow(0);
            headerRow.setHeightInPoints(24);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            String[][] sampleData = {
                {
                    "Nguyễn Văn An", "Trưởng phòng Mua hàng", "Công ty TNHH Giải Pháp Việt",
                    "nguyen.an@vietphap.com", "0912345678", "Biểu mẫu Website",
                    "NEW", "HOT", "Công nghệ thông tin", "Khách hàng cần triển khai ngay trong tháng tới"
                },
                {
                    "Trần Thị Bình", "Giám đốc Kinh doanh", "Tập đoàn Đầu Tư Sao Mai",
                    "binh.tran@saomai.vn", "0987654321", "Nhập từ Excel",
                    "NEW", "WARM", "Tài chính / Ngân hàng", "Quan tâm giải pháp CRM quản trị đa chi nhánh"
                }
            };

            for (int r = 0; r < sampleData.length; r++) {
                Row row = sheet.createRow(r + 1);
                row.setHeightInPoints(20);
                for (int c = 0; c < sampleData[r].length; c++) {
                    Cell cell = row.createCell(c);
                    cell.setCellValue(sampleData[r][c]);
                    cell.setCellStyle(dataStyle);
                }
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                sheet.setColumnWidth(i, Math.max(sheet.getColumnWidth(i) + 1200, 4200));
            }

            resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            resp.setHeader("Content-Disposition", "attachment; filename=\"lead_import_template.xlsx\"");
            workbook.write(resp.getOutputStream());
            resp.getOutputStream().flush();
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private void sendErrorResponse(HttpServletResponse resp, HttpServletRequest req, boolean isJson, int statusCode, String message) throws ServletException, IOException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            req.setAttribute("error", message);
            req.setAttribute("sources", sourceDAO.getActiveSources());
            req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
        }
    }

    private String buildPreviewJson(ImportResult res, String importToken) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"totalRows\":").append(res.getTotalRows())
          .append(",\"validRows\":").append(res.getValidRows())
          .append(",\"duplicateRows\":").append(res.getDuplicateRows())
          .append(",\"failedRows\":").append(res.getFailedRows())
          .append(",\"importToken\":\"").append(escapeJson(importToken)).append("\"")
          .append(",\"details\":[");

        List<LeadImportRequest> details = res.getDetails();
        for (int i = 0; i < details.size(); i++) {
            LeadImportRequest item = details.get(i);
            sb.append("{\"rowIndex\":").append(item.getRowIndex())
              .append(",\"fullName\":\"").append(escapeJson(item.getFullName())).append("\"")
              .append(",\"company\":\"").append(escapeJson(item.getCompany())).append("\"")
              .append(",\"email\":\"").append(escapeJson(item.getEmail())).append("\"")
              .append(",\"phone\":\"").append(escapeJson(item.getPhone())).append("\"")
              .append(",\"sourceName\":\"").append(escapeJson(item.getSourceName())).append("\"")
              .append(",\"valid\":").append(item.isValid())
              .append(",\"duplicate\":").append(item.isDuplicate())
              .append(",\"duplicateReason\":\"").append(escapeJson(item.getDuplicateReason())).append("\"")
              .append(",\"error\":\"").append(escapeJson(item.getError())).append("\"}");
            if (i < details.size() - 1) sb.append(",");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

