package com.crm.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Helper quản lý kết nối CSDL (JDBC Connection) cho ứng dụng CRM.
 * Cung cấp phương thức lấy Connection từ Driver Manager hoặc Connection Pool.
 */
public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static String dbUrl;
    private static String dbUser;
    private static String dbPassword;
    private static String dbDriver;

    static {
        Properties prop = new Properties();
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                prop.load(is);
            }
        } catch (Exception ignored) {}

        // 1. Tự động kiểm tra file cấu hình cục bộ không lưu vào Git (db.local.properties)
        try (InputStream localIs = DBConnection.class.getClassLoader().getResourceAsStream("db.local.properties")) {
            if (localIs != null) {
                prop.load(localIs);
            }
        } catch (Exception ignored) {}

        // 2. Thứ tự ưu tiên: System Property -> Environment Variable -> Properties file -> Default fallback
        String defaultUrl = "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
        String envUrl = System.getenv("DB_URL");
        dbUrl = System.getProperty("db.url", (envUrl != null && !envUrl.trim().isEmpty()) ? envUrl : prop.getProperty("db.url", defaultUrl));

        String envUser = System.getenv("DB_USERNAME") != null ? System.getenv("DB_USERNAME") : System.getenv("DB_USER");
        dbUser = System.getProperty("db.user", (envUser != null && !envUser.trim().isEmpty()) ? envUser : prop.getProperty("db.username", prop.getProperty("db.user", "root")));

        String envPassword = System.getenv("DB_PASSWORD");
        dbPassword = System.getProperty("db.password", (envPassword != null) ? envPassword : prop.getProperty("db.password", "root"));

        String envDriver = System.getenv("DB_DRIVER");
        dbDriver = System.getProperty("db.driver", (envDriver != null && !envDriver.trim().isEmpty()) ? envDriver : prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));

        try {
            Class.forName(dbDriver);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.FINE, "Thông báo: Không tìm thấy JDBC Driver {0} (có thể dùng H2 cho Unit Test)", dbDriver);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Lỗi khởi tạo DBConnection", e);
        }
    }

    /**
     * Cấu hình lại thông tin kết nối DB (phục vụ unit test hoặc môi trường khác).
     */
    public static void setCustomCredentials(String url, String user, String password, String driver) {
        dbUrl = url;
        dbUser = user;
        dbPassword = password;
        dbDriver = driver;
        try {
            Class.forName(dbDriver);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.WARNING, "Driver {0} không khả dụng", dbDriver);
        }
    }

    /**
     * Lấy đối tượng Connection tới Database.
     * @return Connection JDBC
     * @throws SQLException nếu có lỗi kết nối
     */
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        } catch (SQLException e) {
            if (e.getErrorCode() == 1045 || "28000".equals(e.getSQLState())) {
                // Kiểm tra cấu hình cục bộ từ Tomcat deployment nếu môi trường dev dùng credential riêng
                File tomcatProps = new File("C:/apache-tomcat-10.1.60/webapps/crm-backend-1.0.0/WEB-INF/classes/db.properties");
                if (tomcatProps.exists()) {
                    try (InputStream fis = new FileInputStream(tomcatProps)) {
                        Properties p = new Properties();
                        p.load(fis);
                        String fallbackUrl = p.getProperty("db.url", dbUrl);
                        String fallbackUser = p.getProperty("db.username", p.getProperty("db.user", dbUser));
                        String fallbackPass = p.getProperty("db.password", dbPassword);
                        Connection fallbackConn = DriverManager.getConnection(fallbackUrl, fallbackUser, fallbackPass);
                        dbUrl = fallbackUrl;
                        dbUser = fallbackUser;
                        dbPassword = fallbackPass;
                        return fallbackConn;
                    } catch (Exception ignored) {
                    }
                }
            }
            throw e;
        }
    }
}
