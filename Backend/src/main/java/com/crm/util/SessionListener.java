package com.crm.util;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@WebListener
public class SessionListener implements HttpSessionListener {
    private static final Map<Integer, Set<HttpSession>> activeSessions = new ConcurrentHashMap<>();

    public static void registerUserSession(int userId, HttpSession session) {
        activeSessions.computeIfAbsent(userId, ignored -> ConcurrentHashMap.newKeySet()).add(session);
    }

    public static void invalidateUserSession(int userId) {
        Set<HttpSession> sessions = activeSessions.remove(userId);
        if (sessions != null) {
            for (HttpSession session : sessions) {
                try { session.invalidate(); } catch (IllegalStateException ignored) {}
            }
        }
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        activeSessions.values().forEach(sessions -> sessions.remove(se.getSession()));
        activeSessions.entrySet().removeIf(entry -> entry.getValue().isEmpty());
    }
}
