package com.crm.controller.importdata;

import com.crm.dto.ImportExcelRequest;
import com.crm.service.ImportExcelService;
import com.crm.util.ExcelImportUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet({ "/import/excel", "/import/excel/template", "/import/excel/preview", "/import/excel/execute" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 15)
public class ImportExcelServlet extends HttpServlet {

    private ImportExcelService importExcelService;

    @Override
    public void init() throws ServletException {
        this.importExcelService = new ImportExcelService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/import/excel".equals(path)) {
            request.getRequestDispatcher("/pages/import/excel.html").forward(request, response);
        } else if ("/import/excel/template".equals(path)) {
            response.setContentType(
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

            response.setHeader(
                    "Content-Disposition",
                    "attachment; filename=\"user-import-template.xlsx\"");

            try (Workbook workbook = new XSSFWorkbook();
                    OutputStream out = response.getOutputStream()) {

                Sheet sheet = workbook.createSheet("Users");

                Row header = sheet.createRow(0);
                header.createCell(0).setCellValue("Họ và tên");
                header.createCell(1).setCellValue("Email");
                header.createCell(2).setCellValue("Số điện thoại");

                Row example = sheet.createRow(1);
                example.createCell(0).setCellValue("Nguyễn Văn A");
                example.createCell(1).setCellValue("nguyenvana@example.com");
                example.createCell(2).setCellValue("0912345678");

                sheet.autoSizeColumn(0);
                sheet.autoSizeColumn(1);
                sheet.autoSizeColumn(2);

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

        if ("/import/excel/preview".equals(path)) {
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                writeErrorJson(
                        response,
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Vui lòng chọn file Excel.");
                return;
            }

            String submittedFileName = filePart.getSubmittedFileName();

            if (submittedFileName == null
                    || !submittedFileName.toLowerCase().endsWith(".xlsx")) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Chỉ chấp nhận file Excel định dạng .xlsx");
                return;
            }
            if (submittedFileName == null
                    || !submittedFileName.toLowerCase().endsWith(".xlsx")) {

                writeErrorJson(
                        response,
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Chỉ chấp nhận file Excel định dạng .xlsx");
                return;
            }

            try (InputStream is = filePart.getInputStream()) {
                List<ImportExcelRequest> rows = ExcelImportUtil.parsePreview(is);
                Map<String, Object> result = importExcelService.validatePreview(rows);

                // Lưu dữ liệu preview vào session để bước execute sử dụng lại
                request.getSession().setAttribute("importRows", rows);

                // Trả kết quả preview dưới dạng JSON cho frontend
                writePreviewJson(response, result);
            }
        } else if ("/import/excel/execute".equals(path)) {

            @SuppressWarnings("unchecked")
            List<ImportExcelRequest> rows = (List<ImportExcelRequest>) request.getSession()
                    .getAttribute("importRows");

            if (rows == null) {
                writeErrorJson(
                        response,
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Không tìm thấy dữ liệu preview. Vui lòng xem trước dữ liệu trước khi import.");
                return;
            }

            Map<String, Object> result = importExcelService.executeImport(rows);

            // Xóa dữ liệu session sau khi import
            request.getSession().removeAttribute("importRows");

            // Trả kết quả JSON cho frontend
            writeExecuteJson(response, result);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void prepareJsonResponse(HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private void writePreviewJson(
            HttpServletResponse response,
            Map<String, Object> result) throws IOException {

        prepareJsonResponse(response);

        @SuppressWarnings("unchecked")
        List<ImportExcelRequest> rowErrors = (List<ImportExcelRequest>) result.get("rowErrors");

        StringBuilder json = new StringBuilder();

        json.append("{");

        json.append("\"validRows\":")
                .append(result.get("validRows"))
                .append(",");

        json.append("\"invalidRows\":")
                .append(result.get("invalidRows"))
                .append(",");

        json.append("\"rowErrors\":[");

        if (rowErrors != null) {
            for (int i = 0; i < rowErrors.size(); i++) {

                ImportExcelRequest row = rowErrors.get(i);

                if (i > 0) {
                    json.append(",");
                }

                json.append("{");

                json.append("\"fullName\":\"")
                        .append(escapeJson(row.getFullName()))
                        .append("\",");

                json.append("\"email\":\"")
                        .append(escapeJson(row.getEmail()))
                        .append("\",");

                json.append("\"phone\":\"")
                        .append(escapeJson(row.getPhone()))
                        .append("\",");

                json.append("\"error\":\"")
                        .append(escapeJson(row.getError()))
                        .append("\"");

                json.append("}");
            }
        }

        json.append("]");

        json.append("}");

        response.getWriter().write(json.toString());
    }

    private void writeExecuteJson(
            HttpServletResponse response,
            Map<String, Object> result) throws IOException {

        prepareJsonResponse(response);

        @SuppressWarnings("unchecked")
        List<String> errors = (List<String>) result.get("errors");

        StringBuilder json = new StringBuilder();

        json.append("{");

        json.append("\"totalRows\":")
                .append(result.get("totalRows"))
                .append(",");

        json.append("\"successCount\":")
                .append(result.get("successCount"))
                .append(",");

        json.append("\"failedCount\":")
                .append(result.get("failedCount"))
                .append(",");

        json.append("\"errors\":[");

        if (errors != null) {
            for (int i = 0; i < errors.size(); i++) {

                if (i > 0) {
                    json.append(",");
                }

                json.append("\"")
                        .append(escapeJson(errors.get(i)))
                        .append("\"");
            }
        }

        json.append("]");

        json.append("}");

        response.getWriter().write(json.toString());
    }

    private void writeErrorJson(
            HttpServletResponse response,
            int status,
            String message) throws IOException {

        prepareJsonResponse(response);

        response.setStatus(status);

        String json = "{\"error\":\""
                + escapeJson(message)
                + "\"}";

        response.getWriter().write(json);
    }
}
