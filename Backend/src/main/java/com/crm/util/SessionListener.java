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
    private static final Map<Integer, HttpSession> activeSessions = new ConcurrentHashMap<>();
    private static final Set<String> kickedSessionIds = ConcurrentHashMap.newKeySet();
    private static final Object SESSION_LOCK = new Object();

    public static void registerUserSession(int userId, HttpSession session) {
        if (session == null) return;
        HttpSession oldSession = null;
        synchronized (SESSION_LOCK) {
            oldSession = activeSessions.put(userId, session);
        }
        if (oldSession != null && !oldSession.getId().equals(session.getId())) {
            try {
                kickedSessionIds.add(oldSession.getId());
                oldSession.invalidate();
            } catch (IllegalStateException ignored) {}
        }
    }

    public static void invalidateUserSession(int userId) {
        HttpSession oldSession = null;
        synchronized (SESSION_LOCK) {
            oldSession = activeSessions.remove(userId);
        }
        if (oldSession != null) {
            try { 
                kickedSessionIds.add(oldSession.getId());
                oldSession.invalidate(); 
            } catch (IllegalStateException ignored) {}
        }
    }

    public static void invalidateOtherUserSessions(int userId, String currentSessionId) {
        if (currentSessionId == null) return;
        HttpSession oldSession = null;
        synchronized (SESSION_LOCK) {
            HttpSession s = activeSessions.get(userId);
            if (s != null && !currentSessionId.equals(s.getId())) {
                oldSession = activeSessions.remove(userId);
            }
        }
        if (oldSession != null) {
            try { 
                kickedSessionIds.add(oldSession.getId());
                oldSession.invalidate(); 
            } catch (IllegalStateException ignored) {}
        }
    }

    public static boolean isKickedSession(String sessionId) {
        if (sessionId == null) return false;
        return kickedSessionIds.contains(sessionId);
    }

    public static boolean hasActiveSession(int userId) {
        synchronized (SESSION_LOCK) {
            HttpSession session = activeSessions.get(userId);
            return session != null;
        }
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        if (session == null) return;
        String destroyedId = session.getId();

        synchronized (SESSION_LOCK) {
            activeSessions.entrySet().removeIf(entry -> {
                try {
                    return entry.getValue() == null || destroyedId.equals(entry.getValue().getId());
                } catch (Exception e) {
                    return true;
                }
            });
        }
    }
}

