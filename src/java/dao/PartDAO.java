package dao;

import util.DBUtil;
import model.Part;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PartDAO extends BaseDAO {

    private Part mapResultSet(ResultSet rs) throws Exception {
        Part item = new Part();
        item.setPartId(rs.getInt("part_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setPartName(rs.getString("part_name"));
        item.setPartCode(rs.getString("part_code"));
        item.setQuantity(rs.getInt("quantity"));
        item.setMinQuantity(rs.getInt("min_quantity"));
        item.setUnit(rs.getString("unit"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        return item;
    }

    public Part findById(int id) throws Exception {
        String sql = "SELECT part_id, warehouse_id, part_name, part_code, quantity, min_quantity, unit, status, created_at, updated_at FROM parts WHERE part_id = ?";
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

    public List<Part> findAll() throws Exception {
        String sql = "SELECT part_id, warehouse_id, part_name, part_code, quantity, min_quantity, unit, status, created_at, updated_at FROM parts ORDER BY part_id DESC";
        List<Part> list = new ArrayList<Part>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(Part item) throws Exception {
        String sql = "INSERT INTO parts (warehouse_id, part_name, part_code, quantity, min_quantity, unit, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getWarehouseId());
            ps.setString(2, item.getPartName());
            ps.setString(3, item.getPartCode());
            ps.setInt(4, item.getQuantity());
            ps.setInt(5, item.getMinQuantity());
            ps.setString(6, item.getUnit());
            ps.setString(7, item.getStatus());
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

    public boolean update(Part item) throws Exception {
        String sql = "UPDATE parts SET warehouse_id = ?, part_name = ?, part_code = ?, quantity = ?, min_quantity = ?, unit = ?, status = ?, updated_at = GETDATE() WHERE part_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getWarehouseId());
            ps.setString(2, item.getPartName());
            ps.setString(3, item.getPartCode());
            ps.setInt(4, item.getQuantity());
            ps.setInt(5, item.getMinQuantity());
            ps.setString(6, item.getUnit());
            ps.setString(7, item.getStatus());
            ps.setInt(8, item.getPartId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM parts WHERE part_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}