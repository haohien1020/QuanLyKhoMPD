package dao;

import util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class UserDAO {

    private User mapResultSet(ResultSet rs) throws Exception {
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
                + "WHERE u.username = ? AND u.[password] = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    public User findByEmail(String email) throws Exception {
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
                + "WHERE LOWER(u.email) = LOWER(?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    public User findById(int userId) throws Exception {
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
                + "WHERE u.user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    public List<User> findUsers(String keyword, String statusFilter, String roleFilter) throws Exception {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("u.user_id, ")
                .append("u.role_id, ")
                .append("r.role_name, ")
                .append("u.full_name, ")
                .append("u.email, ")
                .append("u.username, ")
                .append("u.phone, ")
                .append("u.address, ")
                .append("u.avatar, ")
                .append("u.status ")
                .append("FROM users u ")
                .append("INNER JOIN roles r ON u.role_id = r.role_id ")
                .append("WHERE 1 = 1 ");

        List<Object> params = new ArrayList<Object>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(u.username) LIKE ? OR LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
        }

        if ("active".equalsIgnoreCase(statusFilter)) {
            sql.append("AND u.status = 'ACTIVE' ");
        } else if ("banned".equalsIgnoreCase(statusFilter)) {
            sql.append("AND u.status <> 'ACTIVE' ");
        }

        if (roleFilter != null && !roleFilter.trim().isEmpty()) {
            sql.append("AND r.role_name = ? ");
            params.add(roleFilter.trim());
        }

        sql.append("ORDER BY u.user_id DESC");

        List<User> users = new ArrayList<User>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSet(rs));
                }
            }
        }
        return users;
    }

    public int insertUser(int roleId, String fullName, String email, String username,
            String password, String phone, String status) throws Exception {
        String sql = "INSERT INTO users (role_id, full_name, email, username, [password], phone, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roleId);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, username);
            ps.setString(5, password);
            ps.setString(6, phone);
            ps.setString(7, status);

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                return 0;
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }

        return 0;
    }

    public boolean updateAdminUser(int userId, String username, String fullName, String email, String phone)
            throws Exception {
        String sql = "UPDATE users "
                + "SET username = ?, full_name = ?, email = ?, phone = ?, updated_at = GETDATE() "
                + "WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setInt(5, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int userId, String status) throws Exception {
        String sql = "UPDATE users SET status = ?, updated_at = GETDATE() WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public int countByRoleId(int roleId) throws Exception {
        String sql = "SELECT COUNT(*) FROM users WHERE role_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public boolean isUsernameUsedByAnotherUser(String username, int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM users WHERE LOWER(username) = LOWER(?) AND user_id <> ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }
    
     public boolean checkOldPassword(int userId, String oldPassword) {
        String sql = "SELECT COUNT(*) "
                + "FROM users "
                + "WHERE user_id = ? AND [password] = ?";

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
                + "SET [password] = ?, updated_at = GETDATE() "
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

    public boolean updateProfile(int userId, String fullName, String email, String phone) throws Exception {
        String sql = "UPDATE users "
                + "SET full_name = ?, email = ?, phone = ?, updated_at = GETDATE() "
                + "WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setInt(4, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean isEmailUsedByAnotherUser(String email, int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM users WHERE LOWER(email) = LOWER(?) AND user_id <> ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }
}
