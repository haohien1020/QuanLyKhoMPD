package dao;

import util.DBUtil;
import model.PurchaseOrderDetail;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PurchaseOrderDetailDAO extends BaseDAO {

    private PurchaseOrderDetail mapResultSet(ResultSet rs) throws Exception {
        PurchaseOrderDetail item = new PurchaseOrderDetail();
        item.setDetailId(rs.getInt("detail_id"));
        item.setPurchaseOrderId(rs.getInt("purchase_order_id"));
        item.setPartId(getNullableInt(rs, "part_id"));
        item.setItemName(rs.getString("item_name"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        return item;
    }

    public PurchaseOrderDetail findById(int id) throws Exception {
        String sql = "SELECT detail_id, purchase_order_id, part_id, item_name, quantity, unit_price FROM purchase_order_details WHERE detail_id = ?";
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

    public List<PurchaseOrderDetail> findAll() throws Exception {
        String sql = "SELECT detail_id, purchase_order_id, part_id, item_name, quantity, unit_price FROM purchase_order_details ORDER BY detail_id DESC";
        List<PurchaseOrderDetail> list = new ArrayList<PurchaseOrderDetail>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(PurchaseOrderDetail item) throws Exception {
        String sql = "INSERT INTO purchase_order_details (purchase_order_id, part_id, item_name, quantity, unit_price) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getPurchaseOrderId());
            setNullableInt(ps, 2, item.getPartId());
            ps.setString(3, item.getItemName());
            ps.setInt(4, item.getQuantity());
            ps.setBigDecimal(5, item.getUnitPrice());
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

    public boolean update(PurchaseOrderDetail item) throws Exception {
        String sql = "UPDATE purchase_order_details SET purchase_order_id = ?, part_id = ?, item_name = ?, quantity = ?, unit_price = ? WHERE detail_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getPurchaseOrderId());
            setNullableInt(ps, 2, item.getPartId());
            ps.setString(3, item.getItemName());
            ps.setInt(4, item.getQuantity());
            ps.setBigDecimal(5, item.getUnitPrice());
            ps.setInt(6, item.getDetailId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM purchase_order_details WHERE detail_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}