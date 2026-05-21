package dao;

import util.DBUtil;
import model.PurchaseRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PurchaseRequestDAO extends BaseDAO {

    private PurchaseRequest mapResultSet(ResultSet rs) throws Exception {
        PurchaseRequest item = new PurchaseRequest();
        item.setPurchaseRequestId(rs.getInt("purchase_request_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setRequestedBy(rs.getInt("requested_by"));
        item.setApprovedBy(getNullableInt(rs, "approved_by"));
        item.setReason(rs.getString("reason"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setApprovedAt(rs.getTimestamp("approved_at"));
        return item;
    }

    public PurchaseRequest findById(int id) throws Exception {
        String sql = "SELECT purchase_request_id, warehouse_id, requested_by, approved_by, reason, status, created_at, approved_at FROM purchase_requests WHERE purchase_request_id = ?";
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

    public List<PurchaseRequest> findAll() throws Exception {
        String sql = "SELECT purchase_request_id, warehouse_id, requested_by, approved_by, reason, status, created_at, approved_at FROM purchase_requests ORDER BY purchase_request_id DESC";
        List<PurchaseRequest> list = new ArrayList<PurchaseRequest>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(PurchaseRequest item) throws Exception {
        String sql = "INSERT INTO purchase_requests (warehouse_id, requested_by, approved_by, reason, status, approved_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getWarehouseId());
            ps.setInt(2, item.getRequestedBy());
            setNullableInt(ps, 3, item.getApprovedBy());
            ps.setString(4, item.getReason());
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

    public boolean update(PurchaseRequest item) throws Exception {
        String sql = "UPDATE purchase_requests SET warehouse_id = ?, requested_by = ?, approved_by = ?, reason = ?, status = ?, approved_at = ? WHERE purchase_request_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getWarehouseId());
            ps.setInt(2, item.getRequestedBy());
            setNullableInt(ps, 3, item.getApprovedBy());
            ps.setString(4, item.getReason());
            ps.setString(5, item.getStatus());
            ps.setTimestamp(6, item.getApprovedAt());
            ps.setInt(7, item.getPurchaseRequestId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM purchase_requests WHERE purchase_request_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}