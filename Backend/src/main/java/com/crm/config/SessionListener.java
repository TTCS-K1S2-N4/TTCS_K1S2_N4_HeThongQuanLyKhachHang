package com.crm.config;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@WebListener
public class SessionListener implements HttpSessionListener {
    private static final Map<Integer, HttpSession> activeSessions = new ConcurrentHashMap<>();

    public static void registerUserSession(int userId, HttpSession session) {
        activeSessions.put(userId, session);
    }

    public static void invalidateUserSession(int userId) {
        HttpSession session = activeSessions.remove(userId);
        if (session != null) {
            try {
                session.invalidate();
            } catch (IllegalStateException ignored) {}
        }
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        activeSessions.values().remove(se.getSession());
    }
}