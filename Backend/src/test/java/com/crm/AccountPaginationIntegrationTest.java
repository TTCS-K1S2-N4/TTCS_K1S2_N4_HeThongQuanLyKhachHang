package com.crm;

import org.junit.jupiter.api.Test;

import java.net.CookieManager;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.*;

public class AccountPaginationIntegrationTest {

    private static final String BASE_URL = "http://localhost:8080/CRM";

    @Test
    void testAccountsPaginationAndFiltersOnServer() throws Exception {
        CookieManager cookieManager = new CookieManager();
        HttpClient client = HttpClient.newBuilder()
                .cookieHandler(cookieManager)
                .followRedirects(HttpClient.Redirect.ALWAYS)
                .build();

        // 1. Admin Login
        String formBody = "username=admin%40company.com&password=Admin12345";
        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
        .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();
        HttpResponse<String> loginRes = client.send(loginReq, HttpResponse.BodyHandlers.ofString());
        assertTrue(loginRes.statusCode() == 200 || loginRes.statusCode() == 302, "Login must succeed");

        // 2. GET /accounts/list (Default page 1, pageSize 10)
        HttpRequest req1 = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/accounts/list"))
                .GET()
                .build();
        HttpResponse<String> res1 = client.send(req1, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, res1.statusCode());
        String body1 = res1.body();

        assertTrue(body1.contains("Quản lý tài khoản"), "Must contain page title");
        assertTrue(body1.contains("accounts-filters"), "Must contain accounts-filters container");
        assertTrue(body1.contains("name=\"pageSize\""), "Must contain pageSize dropdown");
        assertTrue(body1.contains("Hiển thị"), "Must contain pagination info summary");

        // 3. GET with Search & Filters (Keyword + Status + PageSize 10)
        HttpRequest req2 = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/accounts/list?keyword=Admin&status=ACTIVE&pageSize=10"))
                .GET()
                .build();
        HttpResponse<String> res2 = client.send(req2, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, res2.statusCode());
        String body2 = res2.body();
        assertTrue(body2.contains("Admin"), "Must filter by keyword Admin");
        assertTrue(body2.contains("10 / trang"), "Must select 10 / trang");

        // 4. GET with Page 2
        HttpRequest req3 = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/accounts/list?page=2&pageSize=10"))
                .GET()
                .build();
        HttpResponse<String> res3 = client.send(req3, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, res3.statusCode());

        System.out.println("PAGINATION_INTEGRATION_TEST_PASSED_SUCCESSFULLY");
    }
}
