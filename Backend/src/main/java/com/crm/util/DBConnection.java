package com.crm.util;

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
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();
            if (is != null) {
                prop.load(is);
                dbUrl = System.getProperty("db.url", prop.getProperty("db.url",
                    "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8"));
                dbUser = System.getProperty("db.user", prop.getProperty("db.username", prop.getProperty("db.user", "root")));
                dbPassword = System.getProperty("db.password", prop.getProperty("db.password", "root"));
                dbDriver = System.getProperty("db.driver", prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            } else {
                dbUrl = System.getProperty("db.url", "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8");
                dbUser = System.getProperty("db.user", "root");
                dbPassword = System.getProperty("db.password", "root");
                dbDriver = System.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
            }
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
        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }
}
