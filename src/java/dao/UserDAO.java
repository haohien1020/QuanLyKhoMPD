package dao;

import util.DBUtil;
import util.HashUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class UserDAO {

    private static final String USER_SELECT_COLUMNS = "u.user_id, "
            + "u.role_id, "
            + "r.role_name, "
            + "u.full_name, "
            + "u.email, "
            + "u.username, "
            + "u.`password`, "
            + "u.phone, "
            + "u.address, "
            + "u.avatar, "
            + "u.status, "
            + "u.created_at, "
            + "u.updated_at, "
            + "u.ResetToken, "
            + "u.ResetTokenExpiry, "
            + "u.warehouse_id, "
            + "u.can_import_generator, "
            + "u.can_import_inventory, "
            + "u.can_export_inventory ";

    private User mapResultSet(ResultSet rs) throws Exception {
        User u = new User(
                rs.getInt("user_id"),
                rs.getInt("role_id"),
                rs.getString("role_name"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("username"),
                rs.getString("password"),
                rs.getString("phone"),
                rs.getString("address"),
                rs.getString("avatar"),
                rs.getString("status"),
                rs.getTimestamp("created_at"),
                rs.getTimestamp("updated_at"),
                rs.getString("ResetToken"),
                rs.getTimestamp("ResetTokenExpiry")
        );
        int whId = rs.getInt("warehouse_id");
        if (!rs.wasNull()) {
            u.setWarehouseId(whId);
        }
        u.setCanImportGenerator(rs.getBoolean("can_import_generator"));
        u.setCanImportInventory(rs.getBoolean("can_import_inventory"));
        u.setCanExportInventory(rs.getBoolean("can_export_inventory"));
        return u;
    }

    public User authenticate(String username, String password) throws Exception {
        String sql = "SELECT " + USER_SELECT_COLUMNS
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.username = ? AND u.`password` = ? AND r.status = 'ACTIVE' AND u.is_deleted = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, HashUtil.hashPassword(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    public User findByEmail(String email) throws Exception {
        String sql = "SELECT " + USER_SELECT_COLUMNS
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE LOWER(u.email) = LOWER(?) AND u.is_deleted = 0";

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
        String sql = "SELECT " + USER_SELECT_COLUMNS
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ? AND u.is_deleted = 0";

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
        sql.append("SELECT ").append(USER_SELECT_COLUMNS)
                .append("FROM users u ")
                .append("INNER JOIN roles r ON u.role_id = r.role_id ")
                .append("WHERE u.is_deleted = 0 ");

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
        return insertUser(roleId, fullName, email, username, password, phone, status, null);
    }

    public int insertUser(int roleId, String fullName, String email, String username,
            String password, String phone, String status, Integer warehouseId) throws Exception {
        String sql = "INSERT INTO users (role_id, full_name, email, username, `password`, phone, status, warehouse_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roleId);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, username);
            ps.setString(5, HashUtil.hashPassword(password));
            ps.setString(6, phone);
            ps.setString(7, status);
            if (warehouseId != null) {
                ps.setInt(8, warehouseId);
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }

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
                + "SET username = ?, full_name = ?, email = ?, phone = ?, updated_at = NOW() "
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

    public boolean updateAdminUser(int userId, int roleId, String username, String fullName, String email, String phone)
            throws Exception {
        String sql = "UPDATE users "
                + "SET role_id = ?, username = ?, full_name = ?, email = ?, phone = ?, updated_at = NOW() "
                + "WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            ps.setString(2, username);
            ps.setString(3, fullName);
            ps.setString(4, email);
            ps.setString(5, phone);
            ps.setInt(6, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int userId, String status) throws Exception {
        String sql = "UPDATE users SET status = ?, updated_at = NOW() WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public int countByRoleId(int roleId) throws Exception {
        String sql = "SELECT COUNT(*) FROM users WHERE role_id = ? AND is_deleted = 0";

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
        String sql = "SELECT COUNT(*) FROM users WHERE LOWER(username) = LOWER(?) AND user_id <> ? AND is_deleted = 0";

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
                + "WHERE user_id = ? AND `password` = ? AND is_deleted = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, HashUtil.hashPassword(oldPassword));

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
                + "SET `password` = ?, updated_at = NOW() "
                + "WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, HashUtil.hashPassword(newPassword));
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateProfile(int userId, String fullName, String email, String phone) throws Exception {
        String sql = "UPDATE users "
                + "SET full_name = ?, email = ?, phone = ?, updated_at = NOW() "
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
        String sql = "SELECT COUNT(*) FROM users WHERE LOWER(email) = LOWER(?) AND user_id <> ? AND is_deleted = 0";

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

    public List<User> findUsersByRoleName(String roleName) throws Exception {
        String sql = "SELECT " + USER_SELECT_COLUMNS
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE r.role_name = ? AND u.status = 'ACTIVE' AND u.is_deleted = 0 "
                + "ORDER BY u.full_name ASC";
        List<User> list = new ArrayList<User>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public List<User> findSellersByWarehouse(int warehouseId) throws Exception {
        String sql = "SELECT " + USER_SELECT_COLUMNS
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE r.role_name = 'SELLER' AND u.warehouse_id = ? AND u.is_deleted = 0 "
                + "ORDER BY u.user_id DESC";
        List<User> list = new ArrayList<User>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public List<User> findStaffByWarehouse(int warehouseId) throws Exception {
        String sql = "SELECT " + USER_SELECT_COLUMNS
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE r.role_name = 'STAFF' AND u.warehouse_id = ? AND u.is_deleted = 0 "
                + "ORDER BY u.user_id DESC";
        List<User> list = new ArrayList<User>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public boolean updateImportPermission(int userId, boolean canImport) throws Exception {
        String sql = "UPDATE users SET can_import_generator = ?, updated_at = NOW() WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, canImport ? 1 : 0);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateImportInventoryPermission(int userId, boolean canImportInventory) throws Exception {
        String sql = "UPDATE users SET can_import_inventory = ?, updated_at = NOW() WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, canImportInventory ? 1 : 0);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateExportInventoryPermission(int userId, boolean canExportInventory) throws Exception {
        String sql = "UPDATE users SET can_export_inventory = ?, updated_at = NOW() WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, canExportInventory ? 1 : 0);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public void updateWarehouseStaff(int warehouseId, List<Integer> selectedStaffIds) throws Exception {
        String resetSql = "UPDATE users u INNER JOIN roles r ON u.role_id = r.role_id "
                + "SET u.warehouse_id = NULL, u.updated_at = NOW() "
                + "WHERE u.warehouse_id = ? AND r.role_name = 'STAFF'";
        
        String assignSql = "UPDATE users u INNER JOIN roles r ON u.role_id = r.role_id "
                + "SET u.warehouse_id = ?, u.updated_at = NOW() "
                + "WHERE u.user_id = ? AND r.role_name = 'STAFF'";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Reset all current staff of this warehouse to NULL
                try (PreparedStatement psReset = conn.prepareStatement(resetSql)) {
                    psReset.setInt(1, warehouseId);
                    psReset.executeUpdate();
                }

                // 2. Assign selected staff to this warehouse
                if (selectedStaffIds != null && !selectedStaffIds.isEmpty()) {
                    try (PreparedStatement psAssign = conn.prepareStatement(assignSql)) {
                        for (int staffId : selectedStaffIds) {
                            psAssign.setInt(1, warehouseId);
                            psAssign.setInt(2, staffId);
                            psAssign.addBatch();
                        }
                        psAssign.executeBatch();
                    }
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void updateWarehouseSellers(int warehouseId, List<Integer> selectedSellerIds) throws Exception {
        String resetSql = "UPDATE users u INNER JOIN roles r ON u.role_id = r.role_id "
                + "SET u.warehouse_id = NULL, u.updated_at = NOW() "
                + "WHERE u.warehouse_id = ? AND r.role_name = 'SELLER'";
        
        String assignSql = "UPDATE users u INNER JOIN roles r ON u.role_id = r.role_id "
                + "SET u.warehouse_id = ?, u.updated_at = NOW() "
                + "WHERE u.user_id = ? AND r.role_name = 'SELLER'";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Reset all current sellers of this warehouse to NULL
                try (PreparedStatement psReset = conn.prepareStatement(resetSql)) {
                    psReset.setInt(1, warehouseId);
                    psReset.executeUpdate();
                }

                // 2. Assign selected sellers to this warehouse
                if (selectedSellerIds != null && !selectedSellerIds.isEmpty()) {
                    try (PreparedStatement psAssign = conn.prepareStatement(assignSql)) {
                        for (int sellerId : selectedSellerIds) {
                            psAssign.setInt(1, warehouseId);
                            psAssign.setInt(2, sellerId);
                            psAssign.addBatch();
                        }
                        psAssign.executeBatch();
                    }
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public List<User> findEmployeesBySupervisingManager(int managerId) throws Exception {
        String sql = "SELECT u.user_id, u.role_id, r.role_name, u.full_name, u.email, u.username, u.password, u.phone, u.address, u.avatar, u.status, u.created_at, u.updated_at, u.ResetToken, u.ResetTokenExpiry, u.warehouse_id, u.can_import_generator, u.can_import_inventory, u.can_export_inventory, "
                + "w.warehouse_name, wm.full_name AS warehouse_manager_name "
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "LEFT JOIN warehouses w ON u.warehouse_id = w.warehouse_id "
                + "LEFT JOIN users wm ON w.warehouse_manager_id = wm.user_id "
                + "WHERE (r.role_name = 'STAFF' OR r.role_name = 'SELLER') AND u.is_deleted = 0 "
                + "  AND (w.manager_id = ? OR u.warehouse_id IS NULL) "
                + "ORDER BY u.user_id DESC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = mapResultSet(rs);
                    u.setWarehouseName(rs.getString("warehouse_name"));
                    u.setWarehouseManagerName(rs.getString("warehouse_manager_name"));
                    list.add(u);
                }
            }
        }
        return list;
    }

    public List<User> findWarehouseManagersBySupervisingManager(int managerId) throws Exception {
        String sql = "SELECT DISTINCT "
                + "u1.user_id, u1.role_id, r.role_name, u1.full_name, u1.email, u1.username, u1.password, u1.phone, u1.address, u1.avatar, u1.status, u1.created_at, u1.updated_at, u1.ResetToken, u1.ResetTokenExpiry, u1.warehouse_id, u1.can_import_generator, u1.can_import_inventory, u1.can_export_inventory "
                + "FROM users u1 "
                + "INNER JOIN roles r ON u1.role_id = r.role_id "
                + "INNER JOIN warehouses w ON u1.user_id = w.warehouse_manager_id "
                + "WHERE r.role_name = 'WAREHOUSE_MANAGER' AND w.manager_id = ? AND u1.status = 'ACTIVE' AND u1.is_deleted = 0 "
                + "ORDER BY u1.full_name ASC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public boolean updateEmployeeByManager(int userId, String fullName, String email, String phone, Integer warehouseId) throws Exception {
        String sql = "UPDATE users "
                + "SET full_name = ?, email = ?, phone = ?, warehouse_id = ?, updated_at = NOW() "
                + "WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            if (warehouseId != null) {
                ps.setInt(4, warehouseId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setInt(5, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateEmployeeWarehouse(int userId, Integer warehouseId) throws Exception {
        String sql = "UPDATE users SET warehouse_id = ?, updated_at = NOW() WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (warehouseId != null) {
                ps.setInt(1, warehouseId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "UPDATE users SET is_deleted = 1, updated_at = NOW() WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}
