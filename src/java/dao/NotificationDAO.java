package dao;

import util.DBUtil;
import model.Notification;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO extends BaseDAO {

    private Notification mapResultSet(ResultSet rs) throws Exception {
        Notification item = new Notification();
        item.setNotificationId(rs.getInt("notification_id"));
        item.setUserId(rs.getInt("user_id"));
        item.setTitle(rs.getString("title"));
        item.setMessage(rs.getString("message"));
        item.setType(rs.getString("type"));
        item.setRead(rs.getBoolean("is_read"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    public Notification findById(int id) throws Exception {
        String sql = "SELECT notification_id, user_id, title, message, type, is_read, created_at FROM notifications WHERE notification_id = ?";
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

    public List<Notification> findAll() throws Exception {
        String sql = "SELECT notification_id, user_id, title, message, type, is_read, created_at FROM notifications ORDER BY notification_id DESC";
        List<Notification> list = new ArrayList<Notification>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(Notification item) throws Exception {
        String sql = "INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getUserId());
            ps.setString(2, item.getTitle());
            ps.setString(3, item.getMessage());
            ps.setString(4, item.getType());
            ps.setBoolean(5, item.isRead());
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

    public boolean update(Notification item) throws Exception {
        String sql = "UPDATE notifications SET user_id = ?, title = ?, message = ?, type = ?, is_read = ? WHERE notification_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getUserId());
            ps.setString(2, item.getTitle());
            ps.setString(3, item.getMessage());
            ps.setString(4, item.getType());
            ps.setBoolean(5, item.isRead());
            ps.setInt(6, item.getNotificationId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM notifications WHERE notification_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}