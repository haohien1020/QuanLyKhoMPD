package dao;

import util.DBUtil;
import model.PurchaseRequestDetail;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PurchaseRequestDetailDAO extends BaseDAO {

    private PurchaseRequestDetail mapResultSet(ResultSet rs) throws Exception {
        PurchaseRequestDetail item = new PurchaseRequestDetail();
        item.setDetailId(rs.getInt("detail_id"));
        item.setPurchaseRequestId(rs.getInt("purchase_request_id"));
        item.setPartId(getNullableInt(rs, "part_id"));
        item.setItemName(rs.getString("item_name"));
        item.setQuantity(rs.getInt("quantity"));
        return item;
    }

    public PurchaseRequestDetail findById(int id) throws Exception {
        String sql = "SELECT detail_id, purchase_request_id, part_id, item_name, quantity FROM purchase_request_details WHERE detail_id = ?";
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

    public List<PurchaseRequestDetail> findAll() throws Exception {
        String sql = "SELECT detail_id, purchase_request_id, part_id, item_name, quantity FROM purchase_request_details ORDER BY detail_id DESC";
        List<PurchaseRequestDetail> list = new ArrayList<PurchaseRequestDetail>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(PurchaseRequestDetail item) throws Exception {
        String sql = "INSERT INTO purchase_request_details (purchase_request_id, part_id, item_name, quantity) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getPurchaseRequestId());
            setNullableInt(ps, 2, item.getPartId());
            ps.setString(3, item.getItemName());
            ps.setInt(4, item.getQuantity());
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

    public boolean update(PurchaseRequestDetail item) throws Exception {
        String sql = "UPDATE purchase_request_details SET purchase_request_id = ?, part_id = ?, item_name = ?, quantity = ? WHERE detail_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getPurchaseRequestId());
            setNullableInt(ps, 2, item.getPartId());
            ps.setString(3, item.getItemName());
            ps.setInt(4, item.getQuantity());
            ps.setInt(5, item.getDetailId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM purchase_request_details WHERE detail_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}