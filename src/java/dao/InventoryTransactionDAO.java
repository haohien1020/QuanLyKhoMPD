package dao;

import util.DBUtil;
import model.InventoryTransaction;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class InventoryTransactionDAO extends BaseDAO {

    private InventoryTransaction mapResultSet(ResultSet rs) throws Exception {
        InventoryTransaction item = new InventoryTransaction();
        item.setTransactionId(rs.getInt("transaction_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setSupplierId(getNullableInt(rs, "supplier_id"));
        item.setCreatedBy(rs.getInt("created_by"));
        item.setTransactionType(rs.getString("transaction_type"));
        item.setItemType(rs.getString("item_type"));
        item.setGeneratorId(getNullableInt(rs, "generator_id"));
        item.setPartId(getNullableInt(rs, "part_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setTransactionDate(rs.getTimestamp("transaction_date"));
        item.setNote(rs.getString("note"));
        item.setStatus(rs.getString("status"));
        return item;
    }

    public InventoryTransaction findById(int id) throws Exception {
        String sql = "SELECT transaction_id, warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, transaction_date, note, status FROM inventory_transactions WHERE transaction_id = ?";
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

    public List<InventoryTransaction> findAll() throws Exception {
        String sql = "SELECT transaction_id, warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, transaction_date, note, status FROM inventory_transactions ORDER BY transaction_id DESC";
        List<InventoryTransaction> list = new ArrayList<InventoryTransaction>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(InventoryTransaction item) throws Exception {
        String sql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getWarehouseId());
            setNullableInt(ps, 2, item.getSupplierId());
            ps.setInt(3, item.getCreatedBy());
            ps.setString(4, item.getTransactionType());
            ps.setString(5, item.getItemType());
            setNullableInt(ps, 6, item.getGeneratorId());
            setNullableInt(ps, 7, item.getPartId());
            ps.setInt(8, item.getQuantity());
            ps.setString(9, item.getNote());
            ps.setString(10, item.getStatus());
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

    public boolean update(InventoryTransaction item) throws Exception {
        String sql = "UPDATE inventory_transactions SET warehouse_id = ?, supplier_id = ?, created_by = ?, transaction_type = ?, item_type = ?, generator_id = ?, part_id = ?, quantity = ?, transaction_date = ?, note = ?, status = ? WHERE transaction_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getWarehouseId());
            setNullableInt(ps, 2, item.getSupplierId());
            ps.setInt(3, item.getCreatedBy());
            ps.setString(4, item.getTransactionType());
            ps.setString(5, item.getItemType());
            setNullableInt(ps, 6, item.getGeneratorId());
            setNullableInt(ps, 7, item.getPartId());
            ps.setInt(8, item.getQuantity());
            ps.setTimestamp(9, item.getTransactionDate());
            ps.setString(10, item.getNote());
            ps.setString(11, item.getStatus());
            ps.setInt(12, item.getTransactionId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM inventory_transactions WHERE transaction_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public List<InventoryTransaction> findTransactions(Integer warehouseId, String transactionType, String itemType, String keyword, java.sql.Timestamp startDate, java.sql.Timestamp endDate) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT t.transaction_id, t.warehouse_id, t.supplier_id, t.created_by, t.transaction_type, t.item_type, t.generator_id, t.part_id, t.quantity, t.transaction_date, t.note, t.status, " +
            "g.generator_name, g.serial_number, p.part_name, p.part_code, w.warehouse_name, s.supplier_name, u.full_name AS creator_name " +
            "FROM inventory_transactions t " +
            "LEFT JOIN generators g ON t.generator_id = g.generator_id " +
            "LEFT JOIN parts p ON t.part_id = p.part_id " +
            "LEFT JOIN warehouses w ON t.warehouse_id = w.warehouse_id " +
            "LEFT JOIN suppliers s ON t.supplier_id = s.supplier_id " +
            "LEFT JOIN users u ON t.created_by = u.user_id " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (warehouseId != null && warehouseId > 0) {
            sql.append("AND t.warehouse_id = ? ");
            params.add(warehouseId);
        }

        if (transactionType != null && !transactionType.trim().isEmpty()) {
            sql.append("AND t.transaction_type = ? ");
            params.add(transactionType.trim());
        }

        if (itemType != null && !itemType.trim().isEmpty()) {
            sql.append("AND t.item_type = ? ");
            params.add(itemType.trim());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(t.note) LIKE ? OR LOWER(g.generator_name) LIKE ? OR LOWER(g.serial_number) LIKE ? OR LOWER(p.part_name) LIKE ? OR LOWER(p.part_code) LIKE ? OR LOWER(u.full_name) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
            params.add(search);
            params.add(search);
            params.add(search);
        }

        if (startDate != null) {
            sql.append("AND t.transaction_date >= ? ");
            params.add(startDate);
        }

        if (endDate != null) {
            sql.append("AND t.transaction_date <= ? ");
            params.add(endDate);
        }

        sql.append("ORDER BY t.transaction_id DESC");

        List<InventoryTransaction> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryTransaction item = new InventoryTransaction();
                    item.setTransactionId(rs.getInt("transaction_id"));
                    item.setWarehouseId(rs.getInt("warehouse_id"));
                    item.setSupplierId(getNullableInt(rs, "supplier_id"));
                    item.setCreatedBy(rs.getInt("created_by"));
                    item.setTransactionType(rs.getString("transaction_type"));
                    item.setItemType(rs.getString("item_type"));
                    item.setGeneratorId(getNullableInt(rs, "generator_id"));
                    item.setPartId(getNullableInt(rs, "part_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setTransactionDate(rs.getTimestamp("transaction_date"));
                    item.setNote(rs.getString("note"));
                    item.setStatus(rs.getString("status"));

                    // Joined fields
                    item.setGeneratorName(rs.getString("generator_name"));
                    item.setGeneratorSerial(rs.getString("serial_number"));
                    item.setPartName(rs.getString("part_name"));
                    item.setPartCode(rs.getString("part_code"));
                    item.setWarehouseName(rs.getString("warehouse_name"));
                    item.setSupplierName(rs.getString("supplier_name"));
                    item.setCreatorName(rs.getString("creator_name"));

                    list.add(item);
                }
            }
        }
        return list;
    }

    public boolean importPart(int partId, int quantity, int warehouseId, Integer supplierId, int createdBy, String note) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Update part quantity
            String updateSql = "UPDATE parts SET quantity = quantity + ?, updated_at = NOW() WHERE part_id = ? AND warehouse_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, quantity);
                ps.setInt(2, partId);
                ps.setInt(3, warehouseId);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Insert transaction log
            String txSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) VALUES (?, ?, ?, 'IMPORT', 'PART', NULL, ?, ?, ?, 'COMPLETED')";
            try (PreparedStatement ps = conn.prepareStatement(txSql)) {
                ps.setInt(1, warehouseId);
                setNullableInt(ps, 2, supplierId);
                ps.setInt(3, createdBy);
                ps.setInt(4, partId);
                ps.setInt(5, quantity);
                ps.setString(6, note);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
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
                } catch (SQLException ignored) {}
                conn.close();
            }
        }
    }

    public boolean exportPart(int partId, int quantity, int warehouseId, int createdBy, String note) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // Check current quantity first to make sure there's enough stock
            String selectSql = "SELECT quantity FROM parts WHERE part_id = ? AND warehouse_id = ?";
            int currentQty = 0;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, partId);
                ps.setInt(2, warehouseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentQty = rs.getInt("quantity");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (currentQty < quantity) {
                conn.rollback();
                return false; // Insufficient stock
            }

            // 1. Update part quantity
            String updateSql = "UPDATE parts SET quantity = quantity - ?, updated_at = NOW() WHERE part_id = ? AND warehouse_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, quantity);
                ps.setInt(2, partId);
                ps.setInt(3, warehouseId);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Insert transaction log
            String txSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) VALUES (?, NULL, ?, 'EXPORT', 'PART', NULL, ?, ?, ?, 'COMPLETED')";
            try (PreparedStatement ps = conn.prepareStatement(txSql)) {
                ps.setInt(1, warehouseId);
                ps.setInt(2, createdBy);
                ps.setInt(3, partId);
                ps.setInt(4, quantity);
                ps.setString(5, note);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
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
                } catch (SQLException ignored) {}
                conn.close();
            }
        }
    }
}