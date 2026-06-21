package dao;

import util.DBUtil;
import model.Supplier;
import model.PurchaseOrder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SupplierPortalDAO extends BaseDAO {

    public Supplier findSupplierByEmail(String email) {
        String sql = "SELECT supplier_id, supplier_name, phone, email, address, status, created_at FROM suppliers WHERE LOWER(email) = LOWER(?) AND status = 'ACTIVE'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Supplier item = new Supplier();
                    item.setSupplierId(rs.getInt("supplier_id"));
                    item.setSupplierName(rs.getString("supplier_name"));
                    item.setPhone(rs.getString("phone"));
                    item.setEmail(rs.getString("email"));
                    item.setAddress(rs.getString("address"));
                    item.setStatus(rs.getString("status"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    return item;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<PurchaseOrder> findOrdersForSupplier(int supplierId) {
        List<PurchaseOrder> list = new ArrayList<PurchaseOrder>();
        String sql = "SELECT purchase_order_id, supplier_id, warehouse_id, created_by, status, order_date, note FROM purchase_orders WHERE supplier_id = ? ORDER BY purchase_order_id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PurchaseOrder item = new PurchaseOrder();
                    item.setPurchaseOrderId(rs.getInt("purchase_order_id"));
                    item.setSupplierId(rs.getInt("supplier_id"));
                    item.setWarehouseId(rs.getInt("warehouse_id"));
                    item.setCreatedBy(rs.getInt("created_by"));
                    item.setStatus(rs.getString("status"));
                    item.setOrderDate(rs.getTimestamp("order_date"));
                    item.setNote(rs.getString("note"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateOrderStatus(int orderId, String status, String note) {
        String sql = "UPDATE purchase_orders SET status = ?, note = ? WHERE purchase_order_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, note);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
