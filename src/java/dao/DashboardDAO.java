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
}
