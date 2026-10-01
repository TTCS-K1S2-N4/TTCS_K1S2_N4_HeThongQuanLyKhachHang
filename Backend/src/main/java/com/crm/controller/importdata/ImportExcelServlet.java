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

@WebServlet({"/import/excel", "/import/excel/template", "/import/excel/preview", "/import/excel/execute"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 15)
public class ImportExcelServlet extends HttpServlet {
    
    private ImportExcelService importExcelService;

    @Override
    public void init() throws ServletException {
        this.importExcelService = new ImportExcelService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/import/excel".equals(path)) {
            request.getRequestDispatcher("/pages/import/excel.html").forward(request, response);
        } else if ("/import/excel/template".equals(path)) {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"template.csv\"");
            
            String header = "Họ và tên,Email,Số điện thoại\n";
            String example = "Nguyễn Văn A,nguyenvana@example.com,0123456789\n";
            
            try (OutputStream out = response.getOutputStream()) {
                out.write(header.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                out.write(example.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/import/excel/preview".equals(path)) {
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File is missing");
                return;
            }
            
            try (InputStream is = filePart.getInputStream()) {
                List<ImportExcelRequest> rows = ExcelImportUtil.parsePreview(is);
                Map<String, Object> result = importExcelService.validatePreview(rows);
                
                // Store in session for execution step
                request.getSession().setAttribute("importRows", rows);
                
                request.setAttribute("validRows", result.get("validRows"));
                request.setAttribute("invalidRows", result.get("invalidRows"));
                request.setAttribute("rowErrors", result.get("rowErrors"));
                
                request.getRequestDispatcher("/pages/import/excel.html").forward(request, response);
            }
        } else if ("/import/excel/execute".equals(path)) {
            @SuppressWarnings("unchecked")
            List<ImportExcelRequest> rows = (List<ImportExcelRequest>) request.getSession().getAttribute("importRows");
            
            if (rows == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No preview data found");
                return;
            }
            
            Map<String, Object> result = importExcelService.executeImport(rows);
            
            // Clear session data after execute
            request.getSession().removeAttribute("importRows");
            
            request.setAttribute("totalRows", result.get("totalRows"));
            request.setAttribute("successCount", result.get("successCount"));
            request.setAttribute("failedCount", result.get("failedCount"));
            request.setAttribute("errors", result.get("errors"));
            
            request.getRequestDispatcher("/pages/import/excel.html").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
