package dao;

import util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.User;

public class UserDAO {

    public User authenticate(String username, String password) throws Exception {
        String sql = "SELECT "
                + "u.user_id, "
                + "u.role_id, "
                + "r.role_name, "
                + "u.full_name, "
                + "u.email, "
                + "u.username, "
                + "u.phone, "
                + "u.address, "
                + "u.avatar, "
                + "u.status "
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.username = ? AND u.`password` = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                            rs.getInt("user_id"),
                            rs.getInt("role_id"),
                            rs.getString("role_name"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("username"),
                            rs.getString("phone"),
                            rs.getString("address"),
                            rs.getString("avatar"),
                            rs.getString("status")
                    );
                }
            }
        }

        return null;
    }

    public boolean checkOldPassword(int userId, String oldPassword) {
        String sql = "SELECT COUNT(*) "
                + "FROM users "
                + "WHERE user_id = ? AND `password` = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, oldPassword);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users "
                + "SET `password` = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}