package dao;

import util.DBUtil;
import model.Warehouse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class WarehouseDAO extends BaseDAO {

    private Warehouse mapResultSet(ResultSet rs) throws Exception {
        Warehouse item = new Warehouse();
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setWarehouseName(rs.getString("warehouse_name"));
        item.setAddress(rs.getString("address"));
        item.setManagerId(getNullableInt(rs, "manager_id"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    public Warehouse findById(int id) throws Exception {
        String sql = "SELECT warehouse_id, warehouse_name, address, manager_id, status, created_at FROM warehouses WHERE warehouse_id = ?";
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

    public List<Warehouse> findAll() throws Exception {
        String sql = "SELECT warehouse_id, warehouse_name, address, manager_id, status, created_at FROM warehouses ORDER BY warehouse_id DESC";
        List<Warehouse> list = new ArrayList<Warehouse>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(Warehouse item) throws Exception {
        String sql = "INSERT INTO warehouses (warehouse_name, address, manager_id, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getWarehouseName());
            ps.setString(2, item.getAddress());
            setNullableInt(ps, 3, item.getManagerId());
            ps.setString(4, item.getStatus());
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

    public boolean update(Warehouse item) throws Exception {
        String sql = "UPDATE warehouses SET warehouse_name = ?, address = ?, manager_id = ?, status = ? WHERE warehouse_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getWarehouseName());
            ps.setString(2, item.getAddress());
            setNullableInt(ps, 3, item.getManagerId());
            ps.setString(4, item.getStatus());
            ps.setInt(5, item.getWarehouseId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM warehouses WHERE warehouse_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}