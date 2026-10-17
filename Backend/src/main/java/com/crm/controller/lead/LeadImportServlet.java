package com.crm.controller.lead;

import com.crm.dao.LeadSourceDAO;
import com.crm.dto.LeadImportRequest;
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
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;

@WebServlet(urlPatterns = { "/leads/import", "/leads/import/template" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 20 * 1024 * 1024)
public class LeadImportServlet extends HttpServlet {

    private LeadImportService importService = new LeadImportService();
    private LeadSourceDAO sourceDAO = new LeadSourceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String servletPath = req.getServletPath();
        String action = req.getParameter("action");

        // Hỗ trợ tải file Excel mẫu trực tiếp
        if ("/leads/import/template".equals(servletPath) || "template".equalsIgnoreCase(action)) {
            handleDownloadTemplate(resp);
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

        req.setAttribute("sources", sourceDAO.getActiveSources());
        req.setAttribute("campaigns", new com.crm.dao.CampaignDAO().findAll(null, "ACTIVE", null, null, null, null, 1, 100));
        req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
    }

    private void handleDownloadTemplate(HttpServletResponse resp) throws IOException {
        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"Lead_Import_Template.xlsx\"");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = resp.getOutputStream()) {

            Sheet sheet = workbook.createSheet("DanhSachLead");

            Row header = sheet.createRow(0);
            String[] headers = {
                "Họ và tên (*)", "Chức danh", "Công ty", "Email", "Số điện thoại",
                "Nguồn Lead (*)", "Trạng thái", "Đánh giá", "Ngành nghề", "Nhu cầu quan tâm"
            };
            for (int i = 0; i < headers.length; i++) {
                header.createCell(i).setCellValue(headers[i]);
            }

            // Dòng mẫu 1: Khách hàng thu thập từ Hội thảo / Sự kiện
            Row row1 = sheet.createRow(1);
            row1.createCell(0).setCellValue("Nguyễn Văn An");
            row1.createCell(1).setCellValue("Giám đốc Vận hành");
            row1.createCell(2).setCellValue("Công ty CP Công Nghệ Sao Việt");
            row1.createCell(3).setCellValue("an.nguyen@saoviet.vn");
            row1.createCell(4).setCellValue("0987654321");
            row1.createCell(5).setCellValue("Hội thảo / Sự kiện");
            row1.createCell(6).setCellValue("NEW");
            row1.createCell(7).setCellValue("HOT");
            row1.createCell(8).setCellValue("Công nghệ thông tin");
            row1.createCell(9).setCellValue("Gặp gỡ tại Hội thảo TechExpo 2026, quan tâm giải pháp CRM");

            // Dòng mẫu 2: Khách hàng từ danh thiếp sự kiện
            Row row2 = sheet.createRow(2);
            row2.createCell(0).setCellValue("Trần Thị Mai");
            row2.createCell(1).setCellValue("Trưởng phòng Mua hàng");
            row2.createCell(2).setCellValue("Tập đoàn Bán Lẻ Phúc Thịnh");
            row2.createCell(3).setCellValue("mai.tran@phucthinh.com");
            row2.createCell(4).setCellValue("0912345678");
            row2.createCell(5).setCellValue("Hội thảo / Sự kiện");
            row2.createCell(6).setCellValue("NEW");
            row2.createCell(7).setCellValue("WARM");
            row2.createCell(8).setCellValue("Bán lẻ & Thương mại điện tử");
            row2.createCell(9).setCellValue("Để lại danh thiếp sau phiên hội thảo, cần gửi báo giá chi tiết");

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            out.flush();
        }
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

        String action = req.getParameter("action");

        if ("execute".equalsIgnoreCase(action)) {
            handleExecuteImport(req, resp, session, isJson);
        } else {
            handlePreviewImport(req, resp, session, userId, isJson);
        }
    }

    private void handlePreviewImport(HttpServletRequest req, HttpServletResponse resp, HttpSession session,
            Integer userId, boolean isJson)
            throws ServletException, IOException {
        Part filePart = null;
        try {
            filePart = req.getPart("file");
        } catch (Exception ignore) {
        }

        if (filePart == null || filePart.getSize() <= 0) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST,
                    "Vui lòng chọn file Excel để upload.");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null
                || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST,
                    "Định dạng file không được hỗ trợ. Vui lòng upload file Excel (.xlsx, .xls).");
            return;
        }

        String defaultSourceIdStr = req.getParameter("defaultSourceId");
        Integer defaultSourceId = null;
        if (defaultSourceIdStr != null && !defaultSourceIdStr.trim().isEmpty()) {
            try {
                defaultSourceId = Integer.parseInt(defaultSourceIdStr.trim());
            } catch (NumberFormatException ignore) {}
        }

        String campaignIdStr = req.getParameter("campaignId");
        Integer campaignId = null;
        if (campaignIdStr != null && !campaignIdStr.trim().isEmpty()) {
            try {
                int cid = Integer.parseInt(campaignIdStr.trim());
                if (cid > 0 && new com.crm.dao.CampaignDAO().findById(cid) != null) {
                    campaignId = cid;
                }
            } catch (NumberFormatException ignore) {}
        }

        try (InputStream is = filePart.getInputStream()) {
            ImportResult result = importService.parseAndValidateExcel(is, userId, defaultSourceId);
            if (campaignId != null) {
                for (LeadImportRequest item : result.getDetails()) {
                    item.setCampaignId(campaignId);
                }
            }
            session.setAttribute("pendingLeadImportRequests", result.getDetails());

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(buildPreviewJson(result));
            } else {
                req.setAttribute("importResult", result);
                req.setAttribute("sources", sourceDAO.getActiveSources());
                req.setAttribute("campaigns", new com.crm.dao.CampaignDAO().findAll(null, "ACTIVE", null, null, null, null, 1, 100));
                req.setAttribute("selectedSourceId", defaultSourceId);
                req.setAttribute("selectedCampaignId", campaignId);
                req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("unsupported file type") || msg.contains("Can't open workbook") || msg.contains("Invalid header signature") || msg.contains("OLE2")) {
                sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST,
                        "Tệp tải lên không phải là định dạng Excel chuẩn (.xlsx, .xls) hoặc tệp đã bị lỗi/hư hỏng. Vui lòng bấm nút 'Tải file mẫu' ở góc trên để tải tệp mẫu chuẩn và nhập lại dữ liệu.");
            } else {
                sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Lỗi đọc file Excel: " + msg);
            }
        }
    }

    @SuppressWarnings("unchecked")
    private void handleExecuteImport(HttpServletRequest req, HttpServletResponse resp, HttpSession session,
            boolean isJson)
            throws ServletException, IOException {
        List<LeadImportRequest> pendingRequests = (List<LeadImportRequest>) session
                .getAttribute("pendingLeadImportRequests");
        if (pendingRequests == null || pendingRequests.isEmpty()) {
            sendErrorResponse(resp, req, isJson, HttpServletResponse.SC_BAD_REQUEST,
                    "Không có dữ liệu import chờ xử lý. Vui lòng upload lại file Excel.");
            return;
        }

        boolean skipDuplicates = req.getParameter("skipDuplicates") == null
                || "true".equalsIgnoreCase(req.getParameter("skipDuplicates"))
                || "on".equalsIgnoreCase(req.getParameter("skipDuplicates"));

        int importedCount = importService.executeImport(pendingRequests, skipDuplicates);
        session.removeAttribute("pendingLeadImportRequests");

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"success\",\"message\":\"Import thành công " + importedCount
                    + " Lead vào hệ thống!\",\"importedCount\":" + importedCount + "}");
        } else {
            req.setAttribute("importedCount", importedCount);
            req.setAttribute("sources", sourceDAO.getActiveSources());
            req.getRequestDispatcher("/WEB-INF/views/leads/import.jsp").forward(req, resp);
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private void sendErrorResponse(HttpServletResponse resp, HttpServletRequest req, boolean isJson, int statusCode,
            String message) throws ServletException, IOException {
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

    private String buildPreviewJson(ImportResult res) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"totalRows\":").append(res.getTotalRows())
                .append(",\"validRows\":").append(res.getValidRows())
                .append(",\"duplicateRows\":").append(res.getDuplicateRows())
                .append(",\"failedRows\":").append(res.getFailedRows())
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
            if (i < details.size() - 1)
                sb.append(",");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null)
            return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
