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

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM roles WHERE role_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}