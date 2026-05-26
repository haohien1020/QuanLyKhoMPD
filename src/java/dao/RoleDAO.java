package dao;

import util.DBUtil;
import model.Role;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends BaseDAO {

    private Role mapResultSet(ResultSet rs) throws Exception {
        Role item = new Role();
        item.setRoleId(rs.getInt("role_id"));
        item.setRoleName(rs.getString("role_name"));
        item.setDescription(rs.getString("description"));
        item.setStatus(rs.getString("status"));
        return item;
    }

    public Role findById(int id) throws Exception {
        String sql = "SELECT role_id, role_name, description, status FROM roles WHERE role_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public List<Role> findAll() throws Exception {
        String sql = "SELECT role_id, role_name, description, status FROM roles ORDER BY role_id DESC";
        List<Role> list = new ArrayList<Role>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public List<Role> findRoles(String keyword, String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT role_id, role_name, description, status FROM roles WHERE 1 = 1 ");
        List<Object> params = new ArrayList<Object>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(role_name) LIKE ? OR LOWER(description) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
        }

        if ("active".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = 'ACTIVE' ");
        } else if ("inactive".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status <> 'ACTIVE' ");
        }

        sql.append("ORDER BY role_id ASC");

        List<Role> list = new ArrayList<Role>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public List<String> findActiveRoleNames() throws Exception {
        String sql = "SELECT role_name FROM roles WHERE status = 'ACTIVE' ORDER BY role_id ASC";
        List<String> list = new ArrayList<String>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("role_name"));
            }
        }
        return list;
    }

    public Role findByName(String roleName) throws Exception {
        String sql = "SELECT role_id, role_name, description, status FROM roles WHERE role_name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public boolean isRoleNameUsedByAnotherRole(String roleName, int roleId) throws Exception {
        String sql = "SELECT COUNT(*) FROM roles WHERE LOWER(role_name) = LOWER(?) AND role_id <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            ps.setInt(2, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public int insert(Role item) throws Exception {
        String sql = "INSERT INTO roles (role_name, description, status) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getRoleName());
            ps.setString(2, item.getDescription());
            ps.setString(3, item.getStatus());
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

    public boolean update(Role item) throws Exception {
        String sql = "UPDATE roles SET role_name = ?, description = ?, status = ? WHERE role_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getRoleName());
            ps.setString(2, item.getDescription());
            ps.setString(3, item.getStatus());
            ps.setInt(4, item.getRoleId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int roleId, String status) throws Exception {
        String sql = "UPDATE roles SET status = ? WHERE role_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, roleId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM roles WHERE role_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}
