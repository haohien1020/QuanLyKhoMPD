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
        item.setWarehouseManagerId(getNullableInt(rs, "warehouse_manager_id"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setManagerName(rs.getString("manager_name"));
        item.setWarehouseManagerName(rs.getString("warehouse_manager_name"));
        return item;
    }

    public Warehouse findById(int id) throws Exception {
        String sql = "SELECT w.warehouse_id, w.warehouse_name, w.address, w.manager_id, w.warehouse_manager_id, w.status, w.created_at, "
                + "u1.full_name AS manager_name, "
                + "u2.full_name AS warehouse_manager_name "
                + "FROM warehouses w "
                + "LEFT JOIN users u1 ON w.manager_id = u1.user_id "
                + "LEFT JOIN users u2 ON w.warehouse_manager_id = u2.user_id "
                + "WHERE w.warehouse_id = ?";
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
        String sql = "SELECT w.warehouse_id, w.warehouse_name, w.address, w.manager_id, w.warehouse_manager_id, w.status, w.created_at, "
                + "u1.full_name AS manager_name, "
                + "u2.full_name AS warehouse_manager_name "
                + "FROM warehouses w "
                + "LEFT JOIN users u1 ON w.manager_id = u1.user_id "
                + "LEFT JOIN users u2 ON w.warehouse_manager_id = u2.user_id "
                + "ORDER BY w.warehouse_id DESC";
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

    public List<Warehouse> findWarehouses(String keyword, String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT w.warehouse_id, w.warehouse_name, w.address, w.manager_id, w.warehouse_manager_id, w.status, w.created_at, "
                + "u1.full_name AS manager_name, "
                + "u2.full_name AS warehouse_manager_name "
                + "FROM warehouses w "
                + "LEFT JOIN users u1 ON w.manager_id = u1.user_id "
                + "LEFT JOIN users u2 ON w.warehouse_manager_id = u2.user_id "
                + "WHERE 1 = 1 "
        );
        List<Object> params = new ArrayList<Object>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (w.warehouse_name LIKE ? OR w.address LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND w.status = ? ");
            params.add(statusFilter.trim());
        }
        
        sql.append("ORDER BY w.warehouse_id DESC");
        
        List<Warehouse> list = new ArrayList<Warehouse>();
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

    public int insert(Warehouse item) throws Exception {
        String sql = "INSERT INTO warehouses (warehouse_name, address, manager_id, warehouse_manager_id, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getWarehouseName());
            ps.setString(2, item.getAddress());
            setNullableInt(ps, 3, item.getManagerId());
            setNullableInt(ps, 4, item.getWarehouseManagerId());
            ps.setString(5, item.getStatus());
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
        String sql = "UPDATE warehouses SET warehouse_name = ?, address = ?, manager_id = ?, warehouse_manager_id = ?, status = ? WHERE warehouse_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getWarehouseName());
            ps.setString(2, item.getAddress());
            setNullableInt(ps, 3, item.getManagerId());
            setNullableInt(ps, 4, item.getWarehouseManagerId());
            ps.setString(5, item.getStatus());
            ps.setInt(6, item.getWarehouseId());
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

    public boolean isWarehouseManagerAssignedToAnotherWarehouse(int warehouseManagerId, int warehouseId) throws Exception {
        String sql = "SELECT COUNT(*) FROM warehouses WHERE warehouse_manager_id = ? AND warehouse_id <> ? AND status = 'ACTIVE'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseManagerId);
            ps.setInt(2, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public boolean existsByName(String name, int excludeId) throws Exception {
        String sql = "SELECT COUNT(*) FROM warehouses WHERE LOWER(TRIM(warehouse_name)) = LOWER(TRIM(?)) AND warehouse_id <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public boolean existsByAddress(String address, int excludeId) throws Exception {
        String sql = "SELECT COUNT(*) FROM warehouses WHERE LOWER(TRIM(address)) = LOWER(TRIM(?)) AND warehouse_id <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, address);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<Integer> findAssignedWarehouseManagerIds() throws Exception {
        String sql = "SELECT warehouse_manager_id FROM warehouses WHERE warehouse_manager_id IS NOT NULL AND status = 'ACTIVE'";
        List<Integer> list = new ArrayList<Integer>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getInt("warehouse_manager_id"));
            }
        }
        return list;
    }

    public List<Warehouse> findActiveWarehouseManagerAssignments() throws Exception {
        String sql = "SELECT warehouse_id, warehouse_name, warehouse_manager_id FROM warehouses WHERE warehouse_manager_id IS NOT NULL AND status = 'ACTIVE'";
        List<Warehouse> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Warehouse w = new Warehouse();
                w.setWarehouseId(rs.getInt("warehouse_id"));
                w.setWarehouseName(rs.getString("warehouse_name"));
                w.setWarehouseManagerId(rs.getInt("warehouse_manager_id"));
                list.add(w);
            }
        }
        return list;
    }


    public Warehouse findWarehouseByManager(int userId) throws Exception {
        String sql = "SELECT w.warehouse_id, w.warehouse_name, w.address, w.manager_id, w.warehouse_manager_id, w.status, w.created_at, "
                + "u1.full_name AS manager_name, "
                + "u2.full_name AS warehouse_manager_name "
                + "FROM warehouses w "
                + "LEFT JOIN users u1 ON w.manager_id = u1.user_id "
                + "LEFT JOIN users u2 ON w.warehouse_manager_id = u2.user_id "
                + "WHERE w.warehouse_manager_id = ? AND w.status = 'ACTIVE'";
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

    public List<Warehouse> findBySupervisingManager(int managerId, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT w.warehouse_id, w.warehouse_name, w.address, w.manager_id, w.warehouse_manager_id, w.status, w.created_at, "
                + "u1.full_name AS manager_name, "
                + "u2.full_name AS warehouse_manager_name, "
                + "u2.email AS warehouse_manager_email, "
                + "u2.phone AS warehouse_manager_phone, "
                + "(SELECT COUNT(*) FROM generators g WHERE g.warehouse_id = w.warehouse_id) AS total_generators, "
                + "(SELECT COUNT(*) FROM parts p WHERE p.warehouse_id = w.warehouse_id) AS total_parts, "
                + "(SELECT COUNT(*) FROM parts p WHERE p.warehouse_id = w.warehouse_id AND p.quantity < p.min_quantity) AS low_stock_parts "
                + "FROM warehouses w "
                + "LEFT JOIN users u1 ON w.manager_id = u1.user_id "
                + "LEFT JOIN users u2 ON w.warehouse_manager_id = u2.user_id "
                + "WHERE w.manager_id = ? "
        );
        List<Object> params = new ArrayList<>();
        params.add(managerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (w.warehouse_name LIKE ? OR w.address LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY w.warehouse_id DESC");

        List<Warehouse> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Warehouse item = new Warehouse();
                    item.setWarehouseId(rs.getInt("warehouse_id"));
                    item.setWarehouseName(rs.getString("warehouse_name"));
                    item.setAddress(rs.getString("address"));
                    item.setManagerId(getNullableInt(rs, "manager_id"));
                    item.setWarehouseManagerId(getNullableInt(rs, "warehouse_manager_id"));
                    item.setStatus(rs.getString("status"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setManagerName(rs.getString("manager_name"));
                    item.setWarehouseManagerName(rs.getString("warehouse_manager_name"));
                    item.setWarehouseManagerEmail(rs.getString("warehouse_manager_email"));
                    item.setWarehouseManagerPhone(rs.getString("warehouse_manager_phone"));
                    item.setTotalGenerators(rs.getInt("total_generators"));
                    item.setTotalParts(rs.getInt("total_parts"));
                    item.setLowStockParts(rs.getInt("low_stock_parts"));
                    list.add(item);
                }
            }
        }
        return list;
    }
}