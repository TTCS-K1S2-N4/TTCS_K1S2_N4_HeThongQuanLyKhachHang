package com.crm.util;

import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class SessionListenerTest {

    @BeforeEach
    void setUp() {
        // Clear existing session mappings if any
        SessionListener.invalidateUserSession(999);
    }

    @Test
    void testInvalidateOtherUserSessions_KeepCurrentSessionOnly() {
        HttpSession s1 = mock(HttpSession.class);
        when(s1.getId()).thenReturn("session-1");
        
        HttpSession s2 = mock(HttpSession.class);
        when(s2.getId()).thenReturn("session-2");

        SessionListener.registerUserSession(999, s1);
        SessionListener.registerUserSession(999, s2);

        assertTrue(SessionListener.hasActiveSession(999));

        // Invalidate all sessions of user 999 EXCEPT s2
        SessionListener.invalidateOtherUserSessions(999, "session-2");

        verify(s1, times(1)).invalidate();
        verify(s2, never()).invalidate();

        assertTrue(SessionListener.hasActiveSession(999));

        // Clean up
        SessionListener.invalidateUserSession(999);
        verify(s2, times(1)).invalidate();
        assertFalse(SessionListener.hasActiveSession(999));
    }
}
