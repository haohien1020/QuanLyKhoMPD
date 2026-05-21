package dao;

import util.DBUtil;
import model.StockTransferDetail;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class StockTransferDetailDAO extends BaseDAO {

    private StockTransferDetail mapResultSet(ResultSet rs) throws Exception {
        StockTransferDetail item = new StockTransferDetail();
        item.setDetailId(rs.getInt("detail_id"));
        item.setTransferId(rs.getInt("transfer_id"));
        item.setItemType(rs.getString("item_type"));
        item.setGeneratorId(getNullableInt(rs, "generator_id"));
        item.setPartId(getNullableInt(rs, "part_id"));
        item.setQuantity(rs.getInt("quantity"));
        return item;
    }

    public StockTransferDetail findById(int id) throws Exception {
        String sql = "SELECT detail_id, transfer_id, item_type, generator_id, part_id, quantity FROM stock_transfer_details WHERE detail_id = ?";
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

    public List<StockTransferDetail> findAll() throws Exception {
        String sql = "SELECT detail_id, transfer_id, item_type, generator_id, part_id, quantity FROM stock_transfer_details ORDER BY detail_id DESC";
        List<StockTransferDetail> list = new ArrayList<StockTransferDetail>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(StockTransferDetail item) throws Exception {
        String sql = "INSERT INTO stock_transfer_details (transfer_id, item_type, generator_id, part_id, quantity) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getTransferId());
            ps.setString(2, item.getItemType());
            setNullableInt(ps, 3, item.getGeneratorId());
            setNullableInt(ps, 4, item.getPartId());
            ps.setInt(5, item.getQuantity());
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

    public boolean update(StockTransferDetail item) throws Exception {
        String sql = "UPDATE stock_transfer_details SET transfer_id = ?, item_type = ?, generator_id = ?, part_id = ?, quantity = ? WHERE detail_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getTransferId());
            ps.setString(2, item.getItemType());
            setNullableInt(ps, 3, item.getGeneratorId());
            setNullableInt(ps, 4, item.getPartId());
            ps.setInt(5, item.getQuantity());
            ps.setInt(6, item.getDetailId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM stock_transfer_details WHERE detail_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}