package dao;

import util.DBUtil;
import model.Generator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class GeneratorDAO extends BaseDAO {
// Data Access Object
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

    public int insertImportToStock(Generator item, int createdBy) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            item.setStatus("IN_STOCK");
            int generatorId = insert(conn, item);
            if (generatorId <= 0) {
                conn.rollback();
                return 0;
            }

            int transactionId = insertImportTransaction(conn, item, generatorId, createdBy);
            if (transactionId <= 0) {
                conn.rollback();
                return 0;
            }

            conn.commit();
            return generatorId;
        } catch (Exception ex) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    ex.addSuppressed(rollbackEx);
                }
            }
            throw ex;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
                conn.close();
            }
        }
    }

    private int insert(Connection conn, Generator item) throws Exception {
        String sql = "INSERT INTO generators (warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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

    private int insertImportTransaction(Connection conn, Generator item, int generatorId, int createdBy) throws Exception {
        String sql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) VALUES (?, ?, ?, 'IMPORT', 'GENERATOR', ?, NULL, 1, ?, 'COMPLETED')";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getWarehouseId());
            setNullableInt(ps, 2, item.getSupplierId());
            ps.setInt(3, createdBy);
            ps.setInt(4, generatorId);
            ps.setString(5, buildImportNote(item));
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

    private String buildImportNote(Generator item) {
        StringBuilder note = new StringBuilder("Nhap kho may phat");
        if (item.getSerialNumber() != null && !item.getSerialNumber().trim().isEmpty()) {
            note.append(" - Serial: ").append(item.getSerialNumber().trim());
        }
        if (item.getNote() != null && !item.getNote().trim().isEmpty()) {
            note.append(". Ghi chu: ").append(item.getNote().trim());
        }
        return note.toString();
    }

    public boolean update(Generator item) throws Exception {
        String sql = "UPDATE generators SET warehouse_id = ?, supplier_id = ?, generator_name = ?, serial_number = ?, brand = ?, power_value = ?, fuel_type = ?, origin_type = ?, import_date = ?, purchase_price = ?, location = ?, status = ?, note = ?, updated_at = NOW() WHERE generator_id = ?";
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

    public List<Generator> findGenerators(String keyword, Integer warehouseId, String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT generator_id, warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, created_at, updated_at FROM generators WHERE 1 = 1 ");
        List<Object> params = new ArrayList<Object>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(generator_name) LIKE ? OR LOWER(serial_number) LIKE ? OR LOWER(brand) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
        }

        if (warehouseId != null && warehouseId > 0) {
            sql.append("AND warehouse_id = ? ");
            params.add(warehouseId);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim());
        }

        sql.append("ORDER BY generator_id DESC");

        List<Generator> list = new ArrayList<Generator>();
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

    public boolean isSerialNumberUsed(String serialNumber, int generatorId) throws Exception {
        String sql = "SELECT COUNT(*) FROM generators WHERE LOWER(serial_number) = LOWER(?) AND generator_id <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serialNumber);
            ps.setInt(2, generatorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
}
