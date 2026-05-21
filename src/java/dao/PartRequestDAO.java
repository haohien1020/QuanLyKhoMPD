package dao;

import util.DBUtil;
import model.PartRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PartRequestDAO extends BaseDAO {

    private PartRequest mapResultSet(ResultSet rs) throws Exception {
        PartRequest item = new PartRequest();
        item.setRequestId(rs.getInt("request_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
        item.setPartId(rs.getInt("part_id"));
        item.setRequestedBy(rs.getInt("requested_by"));
        item.setApprovedBy(getNullableInt(rs, "approved_by"));
        item.setQuantity(rs.getInt("quantity"));
        item.setReason(rs.getString("reason"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setApprovedAt(rs.getTimestamp("approved_at"));
        return item;
    }

    public PartRequest findById(int id) throws Exception {
        String sql = "SELECT request_id, warehouse_id, part_id, requested_by, approved_by, quantity, reason, status, created_at, approved_at FROM part_requests WHERE request_id = ?";
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

    public List<PartRequest> findAll() throws Exception {
        String sql = "SELECT request_id, warehouse_id, part_id, requested_by, approved_by, quantity, reason, status, created_at, approved_at FROM part_requests ORDER BY request_id DESC";
        List<PartRequest> list = new ArrayList<PartRequest>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(PartRequest item) throws Exception {
        String sql = "INSERT INTO part_requests (warehouse_id, part_id, requested_by, approved_by, quantity, reason, status, approved_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getWarehouseId());
            ps.setInt(2, item.getPartId());
            ps.setInt(3, item.getRequestedBy());
            setNullableInt(ps, 4, item.getApprovedBy());
            ps.setInt(5, item.getQuantity());
            ps.setString(6, item.getReason());
            ps.setString(7, item.getStatus());
            ps.setTimestamp(8, item.getApprovedAt());
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

    public boolean update(PartRequest item) throws Exception {
        String sql = "UPDATE part_requests SET warehouse_id = ?, part_id = ?, requested_by = ?, approved_by = ?, quantity = ?, reason = ?, status = ?, approved_at = ? WHERE request_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getWarehouseId());
            ps.setInt(2, item.getPartId());
            ps.setInt(3, item.getRequestedBy());
            setNullableInt(ps, 4, item.getApprovedBy());
            ps.setInt(5, item.getQuantity());
            ps.setString(6, item.getReason());
            ps.setString(7, item.getStatus());
            ps.setTimestamp(8, item.getApprovedAt());
            ps.setInt(9, item.getRequestId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM part_requests WHERE request_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}