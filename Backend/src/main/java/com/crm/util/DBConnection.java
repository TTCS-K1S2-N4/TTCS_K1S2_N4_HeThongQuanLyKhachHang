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
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();
            if (is != null) {
                prop.load(is);
                dbUrl = System.getProperty("db.url", prop.getProperty("db.url",
                    "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8"));
                dbUser = System.getProperty("db.user", prop.getProperty("db.username", prop.getProperty("db.user", "root")));
                dbPassword = System.getProperty("db.password", prop.getProperty("db.password", "root"));
                dbDriver = System.getProperty("db.driver", prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            } else {
                dbUrl = System.getProperty("db.url", "jdbc:mysql://localhost:3306/crm_db?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8");
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
