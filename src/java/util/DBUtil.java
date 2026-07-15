package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String DB_URL = "jdbc:mysql://127.0.0.1:3306/SWP391_Generator_Management"
            + "?useUnicode=true"
            + "&characterEncoding=UTF-8"
            + "&useSSL=false"
            + "&serverTimezone=Asia/Ho_Chi_Minh"
            + "&allowPublicKeyRetrieval=true";

    private static final String DB_USER = "root";

    // Nhập đúng password root MySQL của bạn
    private static final String DB_PASS = "123456";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
}