package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBUtil;

public class DashboardDAO {

    public int count(String tableName) throws Exception {
        String sql = "SELECT COUNT(*) FROM " + tableName;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countWhere(String tableName, String whereClause) throws Exception {
        String sql = "SELECT COUNT(*) FROM " + tableName + " WHERE " + whereClause;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countPendingWork() throws Exception {
        return countWhere("stock_transfers", "status = 'PENDING'");
    }

    public int countWhereInt(String tableName, String whereClause, int value) throws Exception {
        String sql = "SELECT COUNT(*) FROM " + tableName + " WHERE " + whereClause;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countWarehouseBarcodes(int warehouseId, String status) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM generator_barcodes gb " +
            "INNER JOIN generators g ON gb.generator_id = g.generator_id " +
            "WHERE g.warehouse_id = ? AND g.is_deleted = 0 AND gb.is_deleted = 0"
        );
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND gb.status = ?");
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, warehouseId);
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(2, status.trim());
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countWarehousePendingTransfers(int warehouseId) throws Exception {
        String sql = "SELECT COUNT(*) FROM stock_transfers WHERE status = 'PENDING' AND (from_warehouse_id = ? OR to_warehouse_id = ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
