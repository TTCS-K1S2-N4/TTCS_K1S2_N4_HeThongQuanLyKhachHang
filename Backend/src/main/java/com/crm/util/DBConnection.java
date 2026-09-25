package com.crm.util;

<<<<<<< HEAD
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Helper quản lý kết nối CSDL (JDBC Connection) cho ứng dụng CRM.
 * Cung cấp phương thức lấy Connection từ Driver Manager hoặc Connection Pool.
 */
public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    // Thông tin cấu hình mặc định (có thể override qua System properties hoặc setCustomCredentials)
    private static String dbUrl = System.getProperty("db.url", "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=UTC");
    private static String dbUser = System.getProperty("db.user", "root");
    private static String dbPassword = System.getProperty("db.password", "root");
    private static String dbDriver = System.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");

    static {
        try {
            Class.forName(dbDriver);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.FINE, "Thông báo: Không tìm thấy JDBC Driver {0} (có thể dùng H2 cho Unit Test)", dbDriver);
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
=======
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBConnection {
    private static String url;
    private static String username;
    private static String password;

    static {
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();
            if (is != null) {
                prop.load(is);
                url = prop.getProperty("db.url");
                username = prop.getProperty("db.username");
                password = prop.getProperty("db.password");
                Class.forName(prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            } else {
                url = "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
                username = "root";
                password = "";
                Class.forName("com.mysql.cj.jdbc.Driver");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(url, username, password);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
>>>>>>> origin/develop
}
