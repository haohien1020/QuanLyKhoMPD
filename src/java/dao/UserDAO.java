package dao;

import model.User;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private static final String USER_SELECT_COLUMNS =
            "SELECT "
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
                    + "INNER JOIN roles r ON u.role_id = r.role_id ";

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

    private void bindParameters(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private User findOne(String whereClause, Object... params) throws Exception {
        String sql = USER_SELECT_COLUMNS + whereClause;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    private boolean existsByCount(String sql, Object... params) throws Exception {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public User authenticate(String username, String password) throws Exception {
        return findOne(
                "WHERE u.username = ? AND u.`password` = ?",
                username,
                password
        );
    }

    public User findByEmail(String email) throws Exception {
        return findOne(
                "WHERE LOWER(u.email) = LOWER(?)",
                email
        );
    }

    public User findById(int userId) throws Exception {
        return findOne(
                "WHERE u.user_id = ?",
                userId
        );
    }

    public List<User> findUsers(String keyword, String statusFilter, String roleFilter) throws Exception {
        StringBuilder sql = new StringBuilder(USER_SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (")
                    .append("LOWER(u.username) LIKE ? ")
                    .append("OR LOWER(u.full_name) LIKE ? ")
                    .append("OR LOWER(u.email) LIKE ?")
                    .append(") ");

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

        List<User> users = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSet(rs));
                }
            }
        }

        return users;
    }

    public int insertUser(
            int roleId,
            String fullName,
            String email,
            String username,
            String password,
            String phone,
            String status
    ) throws Exception {
        String sql = "INSERT INTO users "
                + "(role_id, full_name, email, username, `password`, phone, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

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

    public boolean updateAdminUser(
            int userId,
            String username,
            String fullName,
            String email,
            String phone
    ) throws Exception {
        String sql = "UPDATE users "
                + "SET username = ?, "
                + "full_name = ?, "
                + "email = ?, "
                + "phone = ?, "
                + "updated_at = NOW() "
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
        String sql = "UPDATE users "
                + "SET status = ?, "
                + "updated_at = NOW() "
                + "WHERE user_id = ?";

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
        String sql = "SELECT COUNT(*) "
                + "FROM users "
                + "WHERE LOWER(username) = LOWER(?) "
                + "AND user_id <> ?";

        return existsByCount(sql, username, userId);
    }

    public boolean checkOldPassword(int userId, String oldPassword) {
        String sql = "SELECT COUNT(*) "
                + "FROM users "
                + "WHERE user_id = ? "
                + "AND `password` = ?";

        try {
            return existsByCount(sql, userId, oldPassword);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users "
                + "SET `password` = ?, "
                + "updated_at = NOW() "
                + "WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProfile(int userId, String fullName, String email, String phone) throws Exception {
        String sql = "UPDATE users "
                + "SET full_name = ?, "
                + "email = ?, "
                + "phone = ?, "
                + "updated_at = NOW() "
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
        String sql = "SELECT COUNT(*) "
                + "FROM users "
                + "WHERE LOWER(email) = LOWER(?) "
                + "AND user_id <> ?";

        return existsByCount(sql, email, userId);
    }
}