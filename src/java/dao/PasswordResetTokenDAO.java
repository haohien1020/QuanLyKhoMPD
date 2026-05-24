package dao;

import util.DBUtil;
import model.PasswordResetToken;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PasswordResetTokenDAO extends BaseDAO {

    private PasswordResetToken mapResultSet(ResultSet rs) throws Exception {
        PasswordResetToken item = new PasswordResetToken();
        item.setTokenId(rs.getInt("token_id"));
        item.setUserId(rs.getInt("user_id"));
        item.setToken(rs.getString("token"));
        item.setExpiredAt(rs.getTimestamp("expired_at"));
        item.setUsed(rs.getBoolean("is_used"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    public PasswordResetToken findById(int id) throws Exception {
        String sql = "SELECT token_id, user_id, token, expired_at, is_used, created_at FROM password_reset_tokens WHERE token_id = ?";
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

    public List<PasswordResetToken> findAll() throws Exception {
        String sql = "SELECT token_id, user_id, token, expired_at, is_used, created_at FROM password_reset_tokens ORDER BY token_id DESC";
        List<PasswordResetToken> list = new ArrayList<PasswordResetToken>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(PasswordResetToken item) throws Exception {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, expired_at, is_used) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getUserId());
            ps.setString(2, item.getToken());
            ps.setTimestamp(3, item.getExpiredAt());
            ps.setBoolean(4, item.isUsed());
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

    public PasswordResetToken findValidByToken(String token) throws Exception {
        String sql = "SELECT token_id, user_id, token, expired_at, is_used, created_at "
                + "FROM password_reset_tokens "
                + "WHERE token = ? AND is_used = 0 AND expired_at > GETDATE()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public boolean markUsed(int tokenId) throws Exception {
        String sql = "UPDATE password_reset_tokens SET is_used = 1 WHERE token_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tokenId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean markUserTokensUsed(int userId) throws Exception {
        String sql = "UPDATE password_reset_tokens SET is_used = 1 WHERE user_id = ? AND is_used = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        }
    }

    public boolean update(PasswordResetToken item) throws Exception {
        String sql = "UPDATE password_reset_tokens SET user_id = ?, token = ?, expired_at = ?, is_used = ? WHERE token_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getUserId());
            ps.setString(2, item.getToken());
            ps.setTimestamp(3, item.getExpiredAt());
            ps.setBoolean(4, item.isUsed());
            ps.setInt(5, item.getTokenId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM password_reset_tokens WHERE token_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}
