package dao;

import util.DBUtil;
import model.PurchaseOrder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PurchaseOrderDAO extends BaseDAO {

    private PurchaseOrder mapResultSet(ResultSet rs) throws Exception {
        PurchaseOrder item = new PurchaseOrder();
        item.setPurchaseOrderId(rs.getInt("purchase_order_id"));
        item.setSupplierId(rs.getInt("supplier_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setCreatedBy(rs.getInt("created_by"));
        item.setStatus(rs.getString("status"));
        item.setOrderDate(rs.getTimestamp("order_date"));
        item.setNote(rs.getString("note"));
        return item;
    }

    public PurchaseOrder findById(int id) throws Exception {
        String sql = "SELECT purchase_order_id, supplier_id, warehouse_id, created_by, status, order_date, note FROM purchase_orders WHERE purchase_order_id = ?";
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

    public List<PurchaseOrder> findAll() throws Exception {
        String sql = "SELECT purchase_order_id, supplier_id, warehouse_id, created_by, status, order_date, note FROM purchase_orders ORDER BY purchase_order_id DESC";
        List<PurchaseOrder> list = new ArrayList<PurchaseOrder>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(PurchaseOrder item) throws Exception {
        String sql = "INSERT INTO purchase_orders (supplier_id, warehouse_id, created_by, status, note) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getSupplierId());
            ps.setInt(2, item.getWarehouseId());
            ps.setInt(3, item.getCreatedBy());
            ps.setString(4, item.getStatus());
            ps.setString(5, item.getNote());
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

    public boolean update(PurchaseOrder item) throws Exception {
        String sql = "UPDATE purchase_orders SET supplier_id = ?, warehouse_id = ?, created_by = ?, status = ?, order_date = ?, note = ? WHERE purchase_order_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getSupplierId());
            ps.setInt(2, item.getWarehouseId());
            ps.setInt(3, item.getCreatedBy());
            ps.setString(4, item.getStatus());
            ps.setTimestamp(5, item.getOrderDate());
            ps.setString(6, item.getNote());
            ps.setInt(7, item.getPurchaseOrderId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM purchase_orders WHERE purchase_order_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}