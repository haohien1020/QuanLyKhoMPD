package dao;

import util.DBUtil;
import model.StockTransfer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class StockTransferDAO extends BaseDAO {

    private StockTransfer mapResultSet(ResultSet rs) throws Exception {
        StockTransfer item = new StockTransfer();
        item.setTransferId(rs.getInt("transfer_id"));
        item.setFromWarehouseId(rs.getInt("from_warehouse_id"));
        item.setToWarehouseId(rs.getInt("to_warehouse_id"));
        item.setCreatedBy(rs.getInt("created_by"));
        item.setApprovedBy(getNullableInt(rs, "approved_by"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setApprovedAt(rs.getTimestamp("approved_at"));
        return item;
    }

    public StockTransfer findById(int id) throws Exception {
        String sql = "SELECT transfer_id, from_warehouse_id, to_warehouse_id, created_by, approved_by, status, created_at, approved_at FROM stock_transfers WHERE transfer_id = ?";
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

    public List<StockTransfer> findAll() throws Exception {
        String sql = "SELECT transfer_id, from_warehouse_id, to_warehouse_id, created_by, approved_by, status, created_at, approved_at FROM stock_transfers ORDER BY transfer_id DESC";
        List<StockTransfer> list = new ArrayList<StockTransfer>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(StockTransfer item) throws Exception {
        String sql = "INSERT INTO stock_transfers (from_warehouse_id, to_warehouse_id, created_by, approved_by, status, approved_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getFromWarehouseId());
            ps.setInt(2, item.getToWarehouseId());
            ps.setInt(3, item.getCreatedBy());
            setNullableInt(ps, 4, item.getApprovedBy());
            ps.setString(5, item.getStatus());
            ps.setTimestamp(6, item.getApprovedAt());
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

    public boolean update(StockTransfer item) throws Exception {
        String sql = "UPDATE stock_transfers SET from_warehouse_id = ?, to_warehouse_id = ?, created_by = ?, approved_by = ?, status = ?, approved_at = ? WHERE transfer_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getFromWarehouseId());
            ps.setInt(2, item.getToWarehouseId());
            ps.setInt(3, item.getCreatedBy());
            setNullableInt(ps, 4, item.getApprovedBy());
            ps.setString(5, item.getStatus());
            ps.setTimestamp(6, item.getApprovedAt());
            ps.setInt(7, item.getTransferId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM stock_transfers WHERE transfer_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}