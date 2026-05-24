package dao;

import model.Role;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends BaseDAO {

    private static final String ROLE_SELECT_COLUMNS =
            "SELECT "
                    + "`role_id`, "
                    + "`role_name`, "
                    + "`description`, "
                    + "`status` "
                    + "FROM `roles` ";

    private Role mapResultSet(ResultSet rs) throws Exception {
        Role role = new Role();
        role.setRoleId(rs.getInt("role_id"));
        role.setRoleName(rs.getString("role_name"));
        role.setDescription(rs.getString("description"));
        role.setStatus(rs.getString("status"));
        return role;
    }

    private void bindParameters(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private Role findOne(String whereClause, Object... params) throws Exception {
        String sql = ROLE_SELECT_COLUMNS + whereClause;

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

    public Role findById(int roleId) throws Exception {
        return findOne(
                "WHERE `role_id` = ?",
                roleId
        );
    }

    public Role findByName(String roleName) throws Exception {
        return findOne(
                "WHERE `role_name` = ?",
                roleName
        );
    }

    public List<Role> findAll() throws Exception {
        String sql = ROLE_SELECT_COLUMNS + "ORDER BY `role_id` DESC";

        List<Role> roles = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                roles.add(mapResultSet(rs));
            }
        }

        return roles;
    }

    public List<Role> findRoles(String keyword, String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder(ROLE_SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (")
                    .append("LOWER(`role_name`) LIKE ? ")
                    .append("OR LOWER(`description`) LIKE ?")
                    .append(") ");

            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
        }

        if ("active".equalsIgnoreCase(statusFilter)) {
            sql.append("AND `status` = 'ACTIVE' ");
        } else if ("inactive".equalsIgnoreCase(statusFilter)) {
            sql.append("AND `status` <> 'ACTIVE' ");
        }

        sql.append("ORDER BY `role_id` ASC");

        List<Role> roles = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(mapResultSet(rs));
                }
            }
        }

        return roles;
    }

    public List<String> findActiveRoleNames() throws Exception {
        String sql = "SELECT `role_name` "
                + "FROM `roles` "
                + "WHERE `status` = 'ACTIVE' "
                + "ORDER BY `role_id` ASC";

        List<String> roleNames = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                roleNames.add(rs.getString("role_name"));
            }
        }

        return roleNames;
    }

    public boolean isRoleNameUsedByAnotherRole(String roleName, int roleId) throws Exception {
        String sql = "SELECT COUNT(*) "
                + "FROM `roles` "
                + "WHERE LOWER(`role_name`) = LOWER(?) "
                + "AND `role_id` <> ?";

        return existsByCount(sql, roleName, roleId);
    }

    public int insert(Role role) throws Exception {
        String sql = "INSERT INTO `roles` "
                + "(`role_name`, `description`, `status`) "
                + "VALUES (?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, role.getRoleName());
            ps.setString(2, role.getDescription());
            ps.setString(3, role.getStatus());

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

    public boolean update(Role role) throws Exception {
        String sql = "UPDATE `roles` "
                + "SET `role_name` = ?, "
                + "`description` = ?, "
                + "`status` = ? "
                + "WHERE `role_id` = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, role.getRoleName());
            ps.setString(2, role.getDescription());
            ps.setString(3, role.getStatus());
            ps.setInt(4, role.getRoleId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int roleId, String status) throws Exception {
        String sql = "UPDATE `roles` "
                + "SET `status` = ? "
                + "WHERE `role_id` = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, roleId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int roleId) throws Exception {
        String sql = "DELETE FROM `roles` WHERE `role_id` = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);

            return ps.executeUpdate() > 0;
        }
    }
}