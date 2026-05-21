package dao;

import util.DBUtil;
import model.ActivityLog;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ActivityLogDAO extends BaseDAO {

    private ActivityLog mapResultSet(ResultSet rs) throws Exception {
        ActivityLog item = new ActivityLog();
        item.setLogId(rs.getInt("log_id"));
        item.setUserId(getNullableInt(rs, "user_id"));
        item.setAction(rs.getString("action"));
        item.setTableName(rs.getString("table_name"));
        item.setRecordId(getNullableInt(rs, "record_id"));
        item.setDescription(rs.getString("description"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    public ActivityLog findById(int id) throws Exception {
        String sql = "SELECT log_id, user_id, action, table_name, record_id, description, created_at FROM activity_logs WHERE log_id = ?";
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

    public List<ActivityLog> findAll() throws Exception {
        String sql = "SELECT log_id, user_id, action, table_name, record_id, description, created_at FROM activity_logs ORDER BY log_id DESC";
        List<ActivityLog> list = new ArrayList<ActivityLog>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(ActivityLog item) throws Exception {
        String sql = "INSERT INTO activity_logs (user_id, action, table_name, record_id, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setNullableInt(ps, 1, item.getUserId());
            ps.setString(2, item.getAction());
            ps.setString(3, item.getTableName());
            setNullableInt(ps, 4, item.getRecordId());
            ps.setString(5, item.getDescription());
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

    public boolean update(ActivityLog item) throws Exception {
        String sql = "UPDATE activity_logs SET user_id = ?, action = ?, table_name = ?, record_id = ?, description = ? WHERE log_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setNullableInt(ps, 1, item.getUserId());
            ps.setString(2, item.getAction());
            ps.setString(3, item.getTableName());
            setNullableInt(ps, 4, item.getRecordId());
            ps.setString(5, item.getDescription());
            ps.setInt(6, item.getLogId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM activity_logs WHERE log_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}