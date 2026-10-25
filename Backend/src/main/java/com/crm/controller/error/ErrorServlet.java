package com.crm.controller.error;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet xu ly loi S1-07: Error Handler cho HTTP status 403 va 404.
 */
@WebServlet(urlPatterns = {"/error/403", "/error/404", "/errors/403", "/errors/404"})
public class ErrorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processError(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processError(request, response);
    }

    private void processError(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
        String uri = request.getRequestURI();
        String servletPath = request.getServletPath();

        if (statusCode == null) {
            if (uri.contains("403") || servletPath.contains("403")) {
                statusCode = HttpServletResponse.SC_FORBIDDEN;
            } else if (uri.contains("404") || servletPath.contains("404")) {
                statusCode = HttpServletResponse.SC_NOT_FOUND;
            } else {
                statusCode = HttpServletResponse.SC_NOT_FOUND;
            }
        }

        if (isAjaxRequest(request)) {
            response.setStatus(statusCode);
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            String message = (statusCode == 403)
                    ? "Bạn không có quyền truy cập tài nguyên này."
                    : "Trang không tồn tại.";
            out.print("{\"status\": " + statusCode + ", \"message\": \"" + message + "\"}");
            out.flush();
            return;
        }

        if (statusCode == HttpServletResponse.SC_FORBIDDEN) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            String errorMsg = (String) request.getAttribute("errorMessage");
            if (errorMsg == null) {
                errorMsg = "Tài khoản hiện tại không được cấp quyền truy cập chức năng này.";
            }
            request.setAttribute("errorMessage", errorMsg);
            request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            String errorMsg = (String) request.getAttribute("errorMessage");
            if (errorMsg == null) {
                errorMsg = "Trang bạn đang tìm kiếm không tồn tại, đã được di chuyển hoặc đường dẫn không chính xác.";
            }
            request.setAttribute("errorMessage", errorMsg);
            request.getRequestDispatcher("/WEB-INF/views/errors/404.jsp").forward(request, response);
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }
}
