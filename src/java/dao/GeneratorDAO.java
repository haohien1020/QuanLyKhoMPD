package dao;

import util.DBUtil;
import model.Generator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class GeneratorDAO extends BaseDAO {

    private Generator mapResultSet(ResultSet rs) throws Exception {
        Generator item = new Generator();
        item.setGeneratorId(rs.getInt("generator_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setSupplierId(getNullableInt(rs, "supplier_id"));
        item.setGeneratorName(rs.getString("generator_name"));
        item.setSerialNumber(rs.getString("serial_number"));
        item.setBrand(rs.getString("brand"));
        item.setPowerValue(rs.getString("power_value"));
        item.setFuelType(rs.getString("fuel_type"));
        item.setOriginType(rs.getString("origin_type"));
        item.setImportDate(rs.getTimestamp("import_date"));
        item.setPurchasePrice(rs.getBigDecimal("purchase_price"));
        item.setLocation(rs.getString("location"));
        item.setStatus(rs.getString("status"));
        item.setNote(rs.getString("note"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        return item;
    }

    public Generator findById(int id) throws Exception {
        String sql = "SELECT generator_id, warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, created_at, updated_at FROM generators WHERE generator_id = ?";
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

    public List<Generator> findAll() throws Exception {
        String sql = "SELECT generator_id, warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, created_at, updated_at FROM generators ORDER BY generator_id DESC";
        List<Generator> list = new ArrayList<Generator>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(Generator item) throws Exception {
        String sql = "INSERT INTO generators (warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getWarehouseId());
            setNullableInt(ps, 2, item.getSupplierId());
            ps.setString(3, item.getGeneratorName());
            ps.setString(4, item.getSerialNumber());
            ps.setString(5, item.getBrand());
            ps.setString(6, item.getPowerValue());
            ps.setString(7, item.getFuelType());
            ps.setString(8, item.getOriginType());
            ps.setTimestamp(9, item.getImportDate());
            ps.setBigDecimal(10, item.getPurchasePrice());
            ps.setString(11, item.getLocation());
            ps.setString(12, item.getStatus());
            ps.setString(13, item.getNote());
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

    public boolean update(Generator item) throws Exception {
        String sql = "UPDATE generators SET warehouse_id = ?, supplier_id = ?, generator_name = ?, serial_number = ?, brand = ?, power_value = ?, fuel_type = ?, origin_type = ?, import_date = ?, purchase_price = ?, location = ?, status = ?, note = ?, updated_at = GETDATE() WHERE generator_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getWarehouseId());
            setNullableInt(ps, 2, item.getSupplierId());
            ps.setString(3, item.getGeneratorName());
            ps.setString(4, item.getSerialNumber());
            ps.setString(5, item.getBrand());
            ps.setString(6, item.getPowerValue());
            ps.setString(7, item.getFuelType());
            ps.setString(8, item.getOriginType());
            ps.setTimestamp(9, item.getImportDate());
            ps.setBigDecimal(10, item.getPurchasePrice());
            ps.setString(11, item.getLocation());
            ps.setString(12, item.getStatus());
            ps.setString(13, item.getNote());
            ps.setInt(14, item.getGeneratorId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM generators WHERE generator_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}