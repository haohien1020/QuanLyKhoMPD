package dao;

import util.DBUtil;
import model.InventoryTransaction;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
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
}