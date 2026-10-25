package com.crm.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailUtil {

    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    public static boolean isSmtpConfigured() {
        String username = System.getenv("SMTP_USERNAME");
        String password = System.getenv("SMTP_PASSWORD");
        return username != null && !username.trim().isEmpty()
            && password != null && !password.trim().isEmpty();
    }

    public static void sendEmail(String toEmail, String subject, String htmlContent) throws Exception {
        String host = System.getenv("SMTP_HOST");
        if (host == null || host.trim().isEmpty()) {
            host = "smtp.gmail.com";
        }
        
        String port = System.getenv("SMTP_PORT");
        if (port == null || port.trim().isEmpty()) {
            port = "587";
        }
        
        String username = System.getenv("SMTP_USERNAME");
        String password = System.getenv("SMTP_PASSWORD");
        
        String from = System.getenv("SMTP_FROM");
        if (from == null || from.trim().isEmpty()) {
            from = (username != null && !username.trim().isEmpty()) ? username : "no-reply@crm.com";
        }

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            throw new Exception("Cấu hình SMTP chưa đầy đủ (Thiếu biến môi trường SMTP_USERNAME hoặc SMTP_PASSWORD).");
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.connectiontimeout", "7000");
        props.put("mail.smtp.timeout", "7000");
        props.put("mail.smtp.writetimeout", "7000");

        if ("465".equals(port)) {
            props.put("mail.smtp.ssl.enable", "true");
            props.put("mail.smtp.socketFactory.port", port);
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        } else {
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
        }
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", host);

        final String finalUsername = username;
        final String finalPassword = password;

        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(finalUsername, finalPassword);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.info("Gửi email thành công tới: " + toEmail);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gửi email tới " + toEmail + " thất bại: " + e.getMessage());
            throw new Exception("Lỗi kết nối máy chủ SMTP (" + host + ":" + port + "): " + e.getMessage());
        }
    }
}
