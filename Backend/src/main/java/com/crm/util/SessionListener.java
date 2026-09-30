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
    private static final Set<String> kickedSessionIds = ConcurrentHashMap.newKeySet();
    private static final Object SESSION_LOCK = new Object();

    public static void registerUserSession(int userId, HttpSession session) {
        if (session == null) return;
        synchronized (SESSION_LOCK) {
            activeSessions.computeIfAbsent(userId, ignored -> ConcurrentHashMap.newKeySet()).add(session);
        }
    }

    public static void invalidateUserSession(int userId) {
        java.util.List<HttpSession> toInvalidate = new java.util.ArrayList<>();
        synchronized (SESSION_LOCK) {
            Set<HttpSession> sessions = activeSessions.remove(userId);
            if (sessions != null) {
                toInvalidate.addAll(sessions);
            }
        }
        for (HttpSession s : toInvalidate) {
            try { 
                kickedSessionIds.add(s.getId());
                s.invalidate(); 
            } catch (IllegalStateException ignored) {}
        }
    }

    public static void invalidateOtherUserSessions(int userId, String currentSessionId) {
        if (currentSessionId == null) return;
        java.util.List<HttpSession> toInvalidate = new java.util.ArrayList<>();
        synchronized (SESSION_LOCK) {
            Set<HttpSession> sessions = activeSessions.get(userId);
            if (sessions != null) {
                for (HttpSession s : sessions) {
                    try {
                        if (s != null && !currentSessionId.equals(s.getId())) {
                            toInvalidate.add(s);
                        }
                    } catch (IllegalStateException ignored) {}
                }
                sessions.removeAll(toInvalidate);
            }
        }
        for (HttpSession s : toInvalidate) {
            try { 
                kickedSessionIds.add(s.getId());
                s.invalidate(); 
            } catch (IllegalStateException ignored) {}
        }
    }

    public static boolean isKickedSession(String sessionId) {
        if (sessionId == null) return false;
        return kickedSessionIds.remove(sessionId);
    }

    public static boolean hasActiveSession(int userId) {
        synchronized (SESSION_LOCK) {
            Set<HttpSession> sessions = activeSessions.get(userId);
            return sessions != null && !sessions.isEmpty();
        }
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        if (session == null) return;
        String destroyedId = session.getId();

        synchronized (SESSION_LOCK) {
            activeSessions.forEach((userId, sessions) -> {
                sessions.removeIf(s -> {
                    try {
                        return s == null || destroyedId.equals(s.getId());
                    } catch (Exception e) {
                        return true;
                    }
                });
            });
            activeSessions.entrySet().removeIf(entry -> entry.getValue().isEmpty());
        }
    }
}
