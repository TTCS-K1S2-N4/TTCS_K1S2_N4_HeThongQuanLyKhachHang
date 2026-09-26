package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.exception.AuthenticationException;
import com.crm.model.Account;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Timestamp;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

public class AuthServiceTest {

    private AccountDAO accountDAO;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        accountDAO = mock(AccountDAO.class);
        authService = new AuthService(accountDAO);
    }

    @Test
    void testGenerateResetToken_Success() throws AuthenticationException {
        Account mockAcc = new Account();
        mockAcc.setAccountId(1);
        mockAcc.setEmail("user@example.com");
        mockAcc.setStatus("ACTIVE");

        when(accountDAO.findByEmail("user@example.com")).thenReturn(mockAcc);
        when(accountDAO.saveResetToken(eq(1), anyString(), any(Timestamp.class))).thenReturn(true);

        String token = authService.generateResetToken("user@example.com");
        assertNotNull(token);
        assertFalse(token.isEmpty());
        verify(accountDAO).saveResetToken(eq(1), anyString(), any(Timestamp.class));
    }

    @Test
    void testGenerateResetToken_EmailNotFound() {
        when(accountDAO.findByEmail("unknown@example.com")).thenReturn(null);

        assertThrows(AuthenticationException.class, () -> {
            authService.generateResetToken("unknown@example.com");
        });
    }

    @Test
    void testValidateResetToken_Valid() {
        Account mockAcc = new Account();
        mockAcc.setResetToken("valid-token-123");
        mockAcc.setResetTokenExpiry(new Timestamp(System.currentTimeMillis() + 600000)); // Future

        when(accountDAO.findByResetToken("valid-token-123")).thenReturn(mockAcc);

        boolean result = authService.validateResetToken("valid-token-123");
        assertTrue(result);
    }

    @Test
    void testValidateResetToken_Expired() {
        Account mockAcc = new Account();
        mockAcc.setResetToken("expired-token-123");
        mockAcc.setResetTokenExpiry(new Timestamp(System.currentTimeMillis() - 600000)); // Past

        when(accountDAO.findByResetToken("expired-token-123")).thenReturn(mockAcc);

        boolean result = authService.validateResetToken("expired-token-123");
        assertFalse(result);
    }

    @Test
    void testResetPasswordWithToken_Success() throws AuthenticationException {
        Account mockAcc = new Account();
        mockAcc.setAccountId(1);
        mockAcc.setResetToken("token-xyz");
        mockAcc.setResetTokenExpiry(new Timestamp(System.currentTimeMillis() + 600000));

        when(accountDAO.findByResetToken("token-xyz")).thenReturn(mockAcc);
        when(accountDAO.updatePasswordAndClearResetToken(eq(1), anyString())).thenReturn(true);

        authService.resetPasswordWithToken("token-xyz", "newPassword123", "newPassword123");
        verify(accountDAO).updatePasswordAndClearResetToken(eq(1), anyString());
    }

    @Test
    void testResetPasswordWithToken_PasswordMismatch() {
        assertThrows(AuthenticationException.class, () -> {
            authService.resetPasswordWithToken("token-xyz", "newPassword123", "differentPassword");
        });
    }
}
