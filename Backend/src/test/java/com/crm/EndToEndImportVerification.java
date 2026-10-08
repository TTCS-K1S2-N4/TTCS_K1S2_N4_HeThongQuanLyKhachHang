package com.crm;

import com.crm.dao.AccountDAO;
import com.crm.model.Account;
import org.junit.jupiter.api.Test;

import java.io.*;
import java.net.CookieManager;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import static org.junit.jupiter.api.Assertions.*;

public class EndToEndImportVerification {

    private static final String BASE_URL = "http://localhost:8080/CRM";

    @Test
    void testEndToEndImportFlowOnRunningServer() throws Exception {
        // Clean up pre-existing test accounts from DB
        try (java.sql.Connection conn = com.crm.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE email IN ('test1.import@example.com', 'test2.import@example.com')")) {
            ps.executeUpdate();
        }

        CookieManager cookieManager = new CookieManager();
        HttpClient client = HttpClient.newBuilder()
                .cookieHandler(cookieManager)
                .followRedirects(HttpClient.Redirect.ALWAYS)
                .build();

        // 1. GET Login page
        HttpRequest loginPageReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .GET()
                .build();
        HttpResponse<String> loginPageRes = client.send(loginPageReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, loginPageRes.statusCode(), "Trang đăng nhập phải trả về HTTP 200 OK");

        // 2. POST Login as Admin
        String formBody = "username=admin%40company.com&password=Admin12345";
        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();
        HttpResponse<String> loginRes = client.send(loginReq, HttpResponse.BodyHandlers.ofString());
        assertTrue(loginRes.statusCode() == 200 || loginRes.statusCode() == 302, "Đăng nhập admin phải thành công");

        // 3. GET Accounts list page
        HttpRequest accountsPageReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/accounts/list"))
                .GET()
                .build();
        HttpResponse<String> accountsPageRes = client.send(accountsPageReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, accountsPageRes.statusCode(), "Trang danh sách tài khoản phải trả về HTTP 200 OK");
        assertTrue(accountsPageRes.body().contains("Nhập từ Excel"), "Trang danh sách tài khoản phải chứa nút 'Nhập từ Excel'");

        // 4. GET Import page
        HttpRequest importPageReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/import/excel"))
                .GET()
                .build();
        HttpResponse<String> importPageRes = client.send(importPageReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, importPageRes.statusCode(), "Trang Import Excel phải trả về HTTP 200 OK");
        assertTrue(importPageRes.body().contains("Nhập người dùng hàng loạt từ Excel"), "Trang import phải chứa tiêu đề chuẩn");

        // 5. POST Preview Excel File
        File fileToUpload = new File("c:\\Users\\tuyet\\Downloads\\TTCS_K1S2_N4_HeThongQuanLyKhachHang\\test_user_import.xlsx");
        assertTrue(fileToUpload.exists(), "Tệp test_user_import.xlsx phải tồn tại");

        String boundary = "---Boundary" + System.currentTimeMillis();
        byte[] fileBytes = Files.readAllBytes(fileToUpload.toPath());

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        baos.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
        baos.write(("Content-Disposition: form-data; name=\"file\"; filename=\"" + fileToUpload.getName() + "\"\r\n").getBytes(StandardCharsets.UTF_8));
        baos.write(("Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        baos.write(fileBytes);
        baos.write(("\r\n--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));

        HttpRequest previewReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/import/excel/preview"))
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .header("X-Requested-With", "XMLHttpRequest")
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.ofByteArray(baos.toByteArray()))
                .build();

        HttpResponse<String> previewRes = client.send(previewReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, previewRes.statusCode(), "Preview phải trả về HTTP 200 JSON");
        String previewJson = previewRes.body();
        System.out.println("PREVIEW_JSON_OUTPUT: " + previewJson);

        assertTrue(previewJson.contains("\"validRows\":2"), "Preview phải đếm đúng 2 dòng hợp lệ");
        assertTrue(previewJson.contains("\"invalidRows\":3"), "Preview phải đếm đúng 3 dòng lỗi");
        assertTrue(previewJson.contains("test1.import@example.com"), "Preview phải chứa test1.import@example.com");
        assertTrue(previewJson.contains("test2.import@example.com"), "Preview phải chứa test2.import@example.com");
        assertTrue(previewJson.contains("invalid-email-format"), "Preview phải chứa dòng lỗi định dạng email");
        assertTrue(previewJson.contains("admin@company.com"), "Preview phải chứa dòng lỗi email đã tồn tại");

        // 6. POST Execute Import
        HttpRequest executeReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/import/excel/execute"))
                .header("X-Requested-With", "XMLHttpRequest")
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.noBody())
                .build();

        HttpResponse<String> executeRes = client.send(executeReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, executeRes.statusCode(), "Execute import phải trả về HTTP 200 JSON");
        String executeJson = executeRes.body();
        System.out.println("EXECUTE_JSON_OUTPUT: " + executeJson);

        assertTrue(executeJson.contains("\"totalRows\":5"), "Tổng số dòng báo cáo phải là 5");
        assertTrue(executeJson.contains("\"successCount\":2"), "Số dòng thành công phải là 2");
        assertTrue(executeJson.contains("\"failedCount\":3"), "Số dòng thất bại/bỏ qua phải là 3");

        // 7. Verify Database Records
        AccountDAO accountDAO = new AccountDAO();
        Account acc1 = accountDAO.findByEmail("test1.import@example.com");
        Account acc2 = accountDAO.findByEmail("test2.import@example.com");
        Account accInvalid = accountDAO.findByEmail("invalid-email-format");

        assertNotNull(acc1, "Tài khoản test1.import@example.com phải được tạo thành công trong DB");
        assertNotNull(acc2, "Tài khoản test2.import@example.com phải được tạo thành công trong DB");
        assertNull(accInvalid, "Tài khoản lỗi invalid-email-format KHÔNG ĐƯỢC tạo trong DB");

        System.out.println("END_TO_END_TEST_PASSED_ALL_VERIFICATIONS_SUCCESSFUL");
    }
}
