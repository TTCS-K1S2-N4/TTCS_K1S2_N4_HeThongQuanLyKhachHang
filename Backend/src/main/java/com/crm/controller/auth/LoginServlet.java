package com.crm.controller.auth;

import com.crm.dto.LoginRequest;
import com.crm.exception.AuthenticationException;
import com.crm.model.Account;
import com.crm.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/auth/login")
public class LoginServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() {
        authService = new AuthService();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.getRequestDispatcher(
                "/WEB-INF/views/auth/login.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        LoginRequest loginRequest =
                new LoginRequest(username, password);

        try {

            Account account =
                    authService.authenticate(loginRequest);

            HttpSession session = request.getSession(true);

            session.setAttribute("currentUser", account);

            response.sendRedirect(
                    request.getContextPath() + "/"
            );

        } catch (AuthenticationException e) {

            request.setAttribute(
                    "loginError",
                    e.getMessage()
            );

            request.setAttribute(
                    "username",
                    username
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/auth/login.jsp"
            ).forward(request, response);
        }
    }
}