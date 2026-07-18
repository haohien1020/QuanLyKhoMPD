package dao;

import util.DBUtil;
import model.Generator;
import model.GeneratorBarcode;
import model.GroupedGeneratorInventory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
        item.setBarcode(rs.getString("barcode"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        item.setRentalPrice(rs.getBigDecimal("rental_price"));
        try {
            item.setQuantity(rs.getInt("barcode_count"));
        } catch (SQLException e) {
            // ignore
        }
        try {
            item.setMinStock(rs.getInt("min_stock"));
        } catch (SQLException e) {
            // ignore
        }
        return item;
    }

    public Generator findById(int id) throws Exception {
        String sql = "SELECT g.generator_id, g.warehouse_id, g.supplier_id, g.generator_name, g.serial_number, g.brand, g.power_value, g.fuel_type, g.origin_type, g.import_date, g.purchase_price, g.location, g.status, g.note, g.barcode, g.created_at, g.updated_at, g.rental_price, g.min_stock, "
                + "(SELECT COUNT(*) FROM generator_barcodes gb WHERE gb.generator_id = g.generator_id) AS barcode_count "
                + "FROM generators g WHERE g.generator_id = ? AND g.is_deleted = 0";
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
        String sql = "SELECT g.generator_id, g.warehouse_id, g.supplier_id, g.generator_name, g.serial_number, g.brand, g.power_value, g.fuel_type, g.origin_type, g.import_date, g.purchase_price, g.location, g.status, g.note, g.barcode, g.created_at, g.updated_at, g.rental_price, g.min_stock, "
                + "(SELECT COUNT(*) FROM generator_barcodes gb WHERE gb.generator_id = g.generator_id) AS barcode_count "
                + "FROM generators g WHERE g.is_deleted = 0 ORDER BY g.generator_id DESC";
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
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            int generatorId = insert(conn, item);
            if (generatorId > 0) {
                conn.commit();
            } else {
                conn.rollback();
            }
            return generatorId;
        } catch (Exception ex) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException e) {}
            }
            throw ex;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
                conn.close();
            }
        }
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

    public int insert(Connection conn, Generator item) throws Exception {
        String sql = "INSERT INTO generators (warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, barcode, rental_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            ps.setString(14, item.getBarcode());
            ps.setBigDecimal(15, item.getRentalPrice());
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                return 0;
            }
            int generatorId = 0;
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    generatorId = keys.getInt(1);
                }
            }
            return generatorId;
        }
    }

    public int insertBarcode(Connection conn, int generatorId, String serialNumber, String barcode, String status) throws Exception {
        String sql = "INSERT INTO generator_barcodes (generator_id, serial_number, barcode, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, generatorId);
            ps.setString(2, serialNumber);
            ps.setString(3, barcode);
            ps.setString(4, status);
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

    public int insertBarcode(int generatorId, String serialNumber, String barcode, String status) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            return insertBarcode(conn, generatorId, serialNumber, barcode, status);
        }
    }

    public List<GeneratorBarcode> findBarcodesByGeneratorId(int generatorId) throws Exception {
        String sql = "SELECT barcode_id, generator_id, serial_number, barcode, status, created_at, updated_at, transfer_id "
                + "FROM generator_barcodes WHERE generator_id = ? AND is_deleted = 0 ORDER BY barcode_id DESC";
        List<GeneratorBarcode> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, generatorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GeneratorBarcode item = new GeneratorBarcode();
                    item.setBarcodeId(rs.getInt("barcode_id"));
                    item.setGeneratorId(rs.getInt("generator_id"));
                    item.setSerialNumber(rs.getString("serial_number"));
                    item.setBarcode(rs.getString("barcode"));
                    item.setStatus(rs.getString("status"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setUpdatedAt(rs.getTimestamp("updated_at"));
                    int tId = rs.getInt("transfer_id");
                    item.setTransferId(rs.wasNull() ? null : tId);
                    list.add(item);
                }
            }
        }
        return list;
    }

    public List<GeneratorBarcode> findBarcodes(Integer warehouseId, String status) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT gb.barcode_id, gb.generator_id, gb.serial_number, gb.barcode, gb.status, gb.created_at, gb.updated_at, gb.transfer_id, g.generator_name " +
            "FROM generator_barcodes gb " +
            "JOIN generators g ON gb.generator_id = g.generator_id " +
            "WHERE gb.is_deleted = 0 "
        );
        List<Object> params = new ArrayList<>();
        if (warehouseId != null && warehouseId > 0) {
            sql.append("AND g.warehouse_id = ? ");
            params.add(warehouseId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND gb.status = ? ");
            params.add(status.trim());
        }
        sql.append("ORDER BY gb.barcode_id DESC");
        
        List<GeneratorBarcode> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GeneratorBarcode item = new GeneratorBarcode();
                    item.setBarcodeId(rs.getInt("barcode_id"));
                    item.setGeneratorId(rs.getInt("generator_id"));
                    item.setSerialNumber(rs.getString("serial_number"));
                    item.setBarcode(rs.getString("barcode"));
                    item.setStatus(rs.getString("status"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setUpdatedAt(rs.getTimestamp("updated_at"));
                    item.setGeneratorName(rs.getString("generator_name"));
                    int tId = rs.getInt("transfer_id");
                    item.setTransferId(rs.wasNull() ? null : tId);
                    list.add(item);
                }
            }
        }
        return list;
    }

    public GeneratorBarcode findBarcodeById(int barcodeId) throws Exception {
        String sql = "SELECT gb.barcode_id, gb.generator_id, gb.serial_number, gb.barcode, gb.status, gb.created_at, gb.updated_at, gb.transfer_id, g.generator_name " +
                     "FROM generator_barcodes gb " +
                     "JOIN generators g ON gb.generator_id = g.generator_id " +
                     "WHERE gb.barcode_id = ? AND gb.is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, barcodeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    GeneratorBarcode item = new GeneratorBarcode();
                    item.setBarcodeId(rs.getInt("barcode_id"));
                    item.setGeneratorId(rs.getInt("generator_id"));
                    item.setSerialNumber(rs.getString("serial_number"));
                    item.setBarcode(rs.getString("barcode"));
                    item.setStatus(rs.getString("status"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setUpdatedAt(rs.getTimestamp("updated_at"));
                    item.setGeneratorName(rs.getString("generator_name"));
                    int tId = rs.getInt("transfer_id");
                    item.setTransferId(rs.wasNull() ? null : tId);
                    return item;
                }
            }
        }
        return null;
    }

    public boolean updateBarcodeStatus(Connection conn, String serialNumber, String status) throws Exception {
        String sql = "UPDATE generator_barcodes SET status = ?, updated_at = NOW() WHERE serial_number = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, serialNumber);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateBarcodeStatus(String serialNumber, String status) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            return updateBarcodeStatus(conn, serialNumber, status);
        }
    }

    public boolean updateBarcodeStatus(Connection conn, int barcodeId, String status) throws Exception {
        String sql = "UPDATE generator_barcodes SET status = ?, updated_at = NOW() WHERE barcode_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, barcodeId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateBarcodeStatus(int barcodeId, String status) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            return updateBarcodeStatus(conn, barcodeId, status);
        }
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
        String sql = "UPDATE generators SET warehouse_id = ?, supplier_id = ?, generator_name = ?, serial_number = ?, brand = ?, power_value = ?, fuel_type = ?, origin_type = ?, import_date = ?, purchase_price = ?, location = ?, status = ?, note = ?, barcode = ?, rental_price = ?, updated_at = NOW() WHERE generator_id = ?";
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
            ps.setString(14, item.getBarcode());
            ps.setBigDecimal(15, item.getRentalPrice());
            ps.setInt(16, item.getGeneratorId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "UPDATE generators SET is_deleted = 1 WHERE generator_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Generator> findGenerators(String keyword, Integer warehouseId, String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT g.generator_id, g.warehouse_id, g.supplier_id, g.generator_name, g.serial_number, g.brand, g.power_value, g.fuel_type, g.origin_type, g.import_date, g.purchase_price, g.location, g.status, g.note, g.barcode, g.created_at, g.updated_at, g.rental_price, g.min_stock, "
                + "(SELECT COUNT(*) FROM generator_barcodes gb WHERE gb.generator_id = g.generator_id) AS barcode_count "
                + "FROM generators g WHERE g.is_deleted = 0 ");
        List<Object> params = new ArrayList<Object>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(g.generator_name) LIKE ? OR LOWER(g.serial_number) LIKE ? OR LOWER(g.brand) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
        }

        if (warehouseId != null && warehouseId > 0) {
            sql.append("AND g.warehouse_id = ? ");
            params.add(warehouseId);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND g.status = ? ");
            params.add(statusFilter.trim());
        }

        sql.append("ORDER BY g.generator_id DESC");

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
        String sql = "SELECT COUNT(*) FROM generator_barcodes WHERE LOWER(serial_number) = LOWER(?) AND generator_id <> ?";
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

    public boolean isNameUsed(String generatorName, int generatorId) throws Exception {
        if (generatorName == null || generatorName.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM generators WHERE LOWER(generator_name) = LOWER(?) AND generator_id <> ? AND is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generatorName.trim());
            ps.setInt(2, generatorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<GroupedGeneratorInventory> findGroupedInventory(int warehouseId) throws Exception {
        String sql = "SELECT "
                + " g.generator_name, g.brand, g.power_value, g.fuel_type, "
                + " COUNT(CASE WHEN gb.status = 'IN_STOCK' AND (gb.serial_number NOT IN ("
                + "     SELECT rcd.serial_number FROM rental_contract_details rcd "
                + "     INNER JOIN rental_contracts rc ON rcd.rental_contract_id = rc.rental_contract_id "
                + "     WHERE rc.status IN ('PENDING', 'APPROVED') AND rcd.serial_number IS NOT NULL"
                + " )) THEN 1 END) AS in_stock_count, "
                + " COUNT(CASE WHEN gb.status = 'EXPORTED' THEN 1 END) AS rented_count, "
                + " COUNT(CASE WHEN gb.status IN ('MAINTENANCE', 'UNDER_REPAIR') THEN 1 END) AS maintenance_count, "
                + " COUNT(gb.barcode_id) AS total_count "
                + "FROM generators g "
                + "LEFT JOIN generator_barcodes gb ON g.generator_id = gb.generator_id "
                + "WHERE g.warehouse_id = ? AND g.is_deleted = 0 "
                + "GROUP BY g.generator_name, g.brand, g.power_value, g.fuel_type "
                + "ORDER BY g.brand, g.generator_name";
        List<GroupedGeneratorInventory> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GroupedGeneratorInventory item = new GroupedGeneratorInventory();
                    item.setGeneratorName(rs.getString("generator_name"));
                    item.setBrand(rs.getString("brand"));
                    item.setPowerValue(rs.getString("power_value"));
                    item.setFuelType(rs.getString("fuel_type"));
                    item.setInStockCount(rs.getInt("in_stock_count"));
                    item.setRentedCount(rs.getInt("rented_count"));
                    item.setMaintenanceCount(rs.getInt("maintenance_count"));
                    item.setTotalCount(rs.getInt("total_count"));
                    list.add(item);
                }
            }
        }
        return list;
    }

    public List<Generator> findAvailableUnitsForRent(int warehouseId) throws Exception {
        String sql = "SELECT g.generator_id, g.warehouse_id, g.supplier_id, g.generator_name, "
                + "gb.serial_number AS serial_number, g.brand, g.power_value, g.fuel_type, g.origin_type, "
                + "g.import_date, g.purchase_price, g.location, gb.status AS status, g.note, "
                + "gb.barcode AS barcode, g.created_at, g.updated_at, g.rental_price "
                + "FROM generator_barcodes gb "
                + "JOIN generators g ON gb.generator_id = g.generator_id "
                + "WHERE g.warehouse_id = ? AND g.is_deleted = 0 AND gb.status = 'IN_STOCK' AND gb.is_deleted = 0 "
                + "AND gb.serial_number NOT IN ("
                + "    SELECT rcd.serial_number FROM rental_contract_details rcd "
                + "    INNER JOIN rental_contracts rc ON rcd.rental_contract_id = rc.rental_contract_id "
                + "    WHERE rc.status IN ('PENDING', 'APPROVED') AND rcd.serial_number IS NOT NULL"
                + ") "
                + "ORDER BY gb.serial_number ASC";
        List<Generator> list = new ArrayList<>();
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

    private static String removeAccents(String text) {
        if (text == null) return "";
        String normalized = java.text.Normalizer.normalize(text, java.text.Normalizer.Form.NFD);
        return normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                          .replaceAll("[đĐ]", "D");
    }

    public String getSupplierAbbreviation(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "SUP";
        }
        String unsigned = removeAccents(name.trim().toUpperCase());
        unsigned = unsigned.replaceAll("[^A-Z0-9\\s]", "");
        String[] words = unsigned.split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) continue;
            sb.append(word.charAt(0));
        }
        String prefix = sb.toString();
        if (prefix.isEmpty()) {
            return "SUP";
        }
        if (prefix.length() > 6) {
            prefix = prefix.substring(0, 6);
        }
        return prefix;
    }

    public String getCleanGeneratorName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "GEN";
        }
        // Remove Vietnamese accents and convert to upper case
        String unsigned = removeAccents(name.trim().toUpperCase());
        // Clean all non-alphanumeric characters (including spaces)
        String cleaned = unsigned.replaceAll("[^A-Z0-9]", "");
        if (cleaned.isEmpty()) {
            return "GEN";
        }
        return cleaned;
    }

    public String generateNextSerialNumber(String name, Integer supplierId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            return generateNextSerialNumber(conn, name, supplierId);
        }
    }

    public String generateNextSerialNumber(Connection conn, String name, Integer supplierId) throws Exception {
        String supplierPrefix = "";
        if (supplierId != null && supplierId > 0) {
            SupplierDAO supplierDAO = new SupplierDAO();
            model.Supplier supplier = supplierDAO.findById(supplierId);
            if (supplier != null) {
                supplierPrefix = getSupplierAbbreviation(supplier.getSupplierName()) + "-";
            }
        }
        String prefix = supplierPrefix + getCleanGeneratorName(name) + "-";
        
        String serialNumber;
        boolean exists;
        do {
            String guidSuffix = java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
            serialNumber = prefix + guidSuffix;
            
            String sql = "SELECT COUNT(*) FROM generator_barcodes WHERE serial_number = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, serialNumber);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        exists = rs.getInt(1) > 0;
                    } else {
                        exists = false;
                    }
                }
            }
        } while (exists);
        
        return serialNumber;
    }

    public List<GeneratorBarcode> findBarcodesWithFilter(Integer generatorId, String status, String keyword) throws Exception {
        return findBarcodesWithFilter(generatorId, status, keyword, null);
    }

    public List<GeneratorBarcode> findBarcodesWithFilter(Integer generatorId, String status, String keyword, Integer warehouseId) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT gb.barcode_id, gb.generator_id, gb.serial_number, gb.barcode, gb.status, gb.created_at, gb.updated_at, gb.transfer_id, " +
            "g.generator_name " +
            "FROM generator_barcodes gb " +
            "JOIN generators g ON gb.generator_id = g.generator_id " +
            "WHERE gb.is_deleted = 0 "
        );
        List<Object> params = new ArrayList<>();

        if (generatorId != null && generatorId > 0) {
            sql.append("AND gb.generator_id = ? ");
            params.add(generatorId);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND gb.status = ? ");
            params.add(status.trim());
        }

        if (warehouseId != null && warehouseId > 0) {
            sql.append("AND g.warehouse_id = ? ");
            params.add(warehouseId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(gb.serial_number) LIKE ? OR LOWER(g.generator_name) LIKE ?) ");
            String kw = "%" + keyword.trim().toLowerCase() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY gb.generator_id ASC, gb.barcode_id ASC");

        List<GeneratorBarcode> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GeneratorBarcode gb = new GeneratorBarcode();
                    gb.setBarcodeId(rs.getInt("barcode_id"));
                    gb.setGeneratorId(rs.getInt("generator_id"));
                    gb.setSerialNumber(rs.getString("serial_number"));
                    gb.setBarcode(rs.getString("barcode"));
                    gb.setStatus(rs.getString("status"));
                    gb.setCreatedAt(rs.getTimestamp("created_at"));
                    gb.setUpdatedAt(rs.getTimestamp("updated_at"));
                    gb.setGeneratorName(rs.getString("generator_name"));
                    int tId = rs.getInt("transfer_id");
                    gb.setTransferId(rs.wasNull() ? null : tId);
                    list.add(gb);
                }
            }
        }
        return list;
    }

    public boolean lockBarcodesForTransfer(Connection conn, int generatorId, int quantity, int transferId) throws Exception {
        String sql = "UPDATE generator_barcodes SET status = 'TRANSFERRED', transfer_id = ?, updated_at = NOW() "
                   + "WHERE generator_id = ? AND status = 'IN_STOCK' LIMIT ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, transferId);
            ps.setInt(2, generatorId);
            ps.setInt(3, quantity);
            return ps.executeUpdate() == quantity;
        }
    }

    public boolean releaseBarcodes(Connection conn, int transferId) throws Exception {
        String sql = "UPDATE generator_barcodes SET status = 'IN_STOCK', transfer_id = NULL, updated_at = NOW() "
                   + "WHERE transfer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, transferId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean transferBarcodes(Connection conn, int transferId, int destGeneratorId) throws Exception {
        String sql = "UPDATE generator_barcodes SET generator_id = ?, status = 'IN_STOCK', transfer_id = NULL, updated_at = NOW() "
                   + "WHERE transfer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, destGeneratorId);
            ps.setInt(2, transferId);
            return ps.executeUpdate() > 0;
        }
    }

    public Generator findGeneratorBySpecs(Connection conn, int warehouseId, String name, String brand, String power, String fuel) throws Exception {
        String sql = "SELECT generator_id, warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, created_at, updated_at, rental_price "
                   + "FROM generators "
                   + "WHERE warehouse_id = ? AND generator_name = ? AND brand = ? AND power_value = ? AND fuel_type = ? AND is_deleted = 0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setString(2, name);
            ps.setString(3, brand);
            ps.setString(4, power);
            ps.setString(5, fuel);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Generator g = new Generator();
                    g.setGeneratorId(rs.getInt("generator_id"));
                    g.setWarehouseId(rs.getInt("warehouse_id"));
                    g.setSupplierId(getNullableInt(rs, "supplier_id"));
                    g.setGeneratorName(rs.getString("generator_name"));
                    g.setSerialNumber(rs.getString("serial_number"));
                    g.setBrand(rs.getString("brand"));
                    g.setPowerValue(rs.getString("power_value"));
                    g.setFuelType(rs.getString("fuel_type"));
                    g.setOriginType(rs.getString("origin_type"));
                    g.setImportDate(rs.getTimestamp("import_date"));
                    g.setPurchasePrice(rs.getBigDecimal("purchase_price"));
                    g.setLocation(rs.getString("location"));
                    g.setStatus(rs.getString("status"));
                    g.setNote(rs.getString("note"));
                    g.setCreatedAt(rs.getTimestamp("created_at"));
                    g.setUpdatedAt(rs.getTimestamp("updated_at"));
                    g.setRentalPrice(rs.getBigDecimal("rental_price"));
                    return g;
                }
            }
        }
        return null;
    }

    public int insertModelOnly(Connection conn, Generator item) throws Exception {
        String sql = "INSERT INTO generators (warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, barcode, rental_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            ps.setString(14, item.getBarcode());
            ps.setBigDecimal(15, item.getRentalPrice());
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

    public List<Generator> findLowStockGenerators(int warehouseId, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT * FROM ( "
            + "SELECT g.generator_id, g.warehouse_id, g.supplier_id, g.generator_name, g.serial_number, g.brand, g.power_value, g.fuel_type, g.origin_type, g.import_date, g.purchase_price, g.location, g.status, g.note, g.barcode, g.created_at, g.updated_at, g.rental_price, g.min_stock, "
            + "(SELECT COUNT(*) FROM generator_barcodes gb WHERE gb.generator_id = g.generator_id AND gb.status = 'IN_STOCK') AS barcode_count "
            + "FROM generators g "
            + "WHERE g.warehouse_id = ? AND g.is_deleted = 0 "
            + ") temp "
            + "WHERE barcode_count <= min_stock "
        );
        List<Object> params = new ArrayList<Object>();
        params.add(warehouseId);
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(generator_name) LIKE ? OR LOWER(brand) LIKE ? OR LOWER(power_value) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
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

    public boolean deleteBarcode(int barcodeId) throws Exception {
        String sql = "UPDATE generator_barcodes SET is_deleted = 1, updated_at = NOW() WHERE barcode_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, barcodeId);
            return ps.executeUpdate() > 0;
        }
    }
}
