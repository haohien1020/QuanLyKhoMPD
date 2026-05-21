package dao;

import util.DBUtil;
import model.MaintenanceRepair;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceRepairDAO extends BaseDAO {

    private MaintenanceRepair mapResultSet(ResultSet rs) throws Exception {
        MaintenanceRepair item = new MaintenanceRepair();
        item.setRepairId(rs.getInt("repair_id"));
        item.setGeneratorId(rs.getInt("generator_id"));
        item.setReportedBy(rs.getInt("reported_by"));
        item.setAssignedTo(getNullableInt(rs, "assigned_to"));
        item.setIssueDescription(rs.getString("issue_description"));
        item.setRepairStatus(rs.getString("repair_status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setCompletedAt(rs.getTimestamp("completed_at"));
        return item;
    }

    public MaintenanceRepair findById(int id) throws Exception {
        String sql = "SELECT repair_id, generator_id, reported_by, assigned_to, issue_description, repair_status, created_at, completed_at FROM maintenance_repairs WHERE repair_id = ?";
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

    public List<MaintenanceRepair> findAll() throws Exception {
        String sql = "SELECT repair_id, generator_id, reported_by, assigned_to, issue_description, repair_status, created_at, completed_at FROM maintenance_repairs ORDER BY repair_id DESC";
        List<MaintenanceRepair> list = new ArrayList<MaintenanceRepair>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(MaintenanceRepair item) throws Exception {
        String sql = "INSERT INTO maintenance_repairs (generator_id, reported_by, assigned_to, issue_description, repair_status, completed_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getGeneratorId());
            ps.setInt(2, item.getReportedBy());
            setNullableInt(ps, 3, item.getAssignedTo());
            ps.setString(4, item.getIssueDescription());
            ps.setString(5, item.getRepairStatus());
            ps.setTimestamp(6, item.getCompletedAt());
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

    public boolean update(MaintenanceRepair item) throws Exception {
        String sql = "UPDATE maintenance_repairs SET generator_id = ?, reported_by = ?, assigned_to = ?, issue_description = ?, repair_status = ?, completed_at = ? WHERE repair_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getGeneratorId());
            ps.setInt(2, item.getReportedBy());
            setNullableInt(ps, 3, item.getAssignedTo());
            ps.setString(4, item.getIssueDescription());
            ps.setString(5, item.getRepairStatus());
            ps.setTimestamp(6, item.getCompletedAt());
            ps.setInt(7, item.getRepairId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM maintenance_repairs WHERE repair_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}