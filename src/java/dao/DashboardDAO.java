package dao;

import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Set;

public class DashboardDAO {

    private static final Set<String> ALLOWED_TABLES = Set.of(
            "users",
            "roles",
            "assets",
            "part_requests",
            "purchase_requests",
            "stock_transfers",
            "maintenance_repairs"
    );

    public int count(String tableName) throws Exception {
        validateTableName(tableName);

        String sql = "SELECT COUNT(*) FROM `" + tableName + "`";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countWhere(String tableName, String whereClause) throws Exception {
        validateTableName(tableName);
        validateWhereClause(whereClause);

        String sql = "SELECT COUNT(*) FROM `" + tableName + "` WHERE " + whereClause;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countWhereInt(String tableName, String whereClause, int value) throws Exception {
        validateTableName(tableName);
        validateWhereClause(whereClause);

        String sql = "SELECT COUNT(*) FROM `" + tableName + "` WHERE " + whereClause;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, value);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countPendingWork() throws Exception {
        return countWhere("part_requests", "`status` = 'PENDING'")
                + countWhere("purchase_requests", "`status` = 'PENDING'")
                + countWhere("stock_transfers", "`status` = 'PENDING'")
                + countWhere("maintenance_repairs", "`repair_status` = 'PENDING'");
    }

    private void validateTableName(String tableName) {
        if (tableName == null || tableName.trim().isEmpty()) {
            throw new IllegalArgumentException("Table name must not be empty.");
        }

        if (!ALLOWED_TABLES.contains(tableName)) {
            throw new IllegalArgumentException("Invalid table name: " + tableName);
        }
    }

    private void validateWhereClause(String whereClause) {
        if (whereClause == null || whereClause.trim().isEmpty()) {
            throw new IllegalArgumentException("WHERE clause must not be empty.");
        }

        String lowerClause = whereClause.toLowerCase();

        if (lowerClause.contains(";")
                || lowerClause.contains("--")
                || lowerClause.contains("/*")
                || lowerClause.contains("*/")
                || lowerClause.contains(" drop ")
                || lowerClause.contains(" delete ")
                || lowerClause.contains(" update ")
                || lowerClause.contains(" insert ")) {
            throw new IllegalArgumentException("Unsafe WHERE clause.");
        }
    }
}