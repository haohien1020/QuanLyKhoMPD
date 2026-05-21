package dao;

import util.DBUtil;
import model.ReportExport;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ReportExportDAO extends BaseDAO {

    private ReportExport mapResultSet(ResultSet rs) throws Exception {
        ReportExport item = new ReportExport();
        item.setReportId(rs.getInt("report_id"));
        item.setCreatedBy(rs.getInt("created_by"));
        item.setReportName(rs.getString("report_name"));
        item.setReportType(rs.getString("report_type"));
        item.setFileType(rs.getString("file_type"));
        item.setFilePath(rs.getString("file_path"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    public ReportExport findById(int id) throws Exception {
        String sql = "SELECT report_id, created_by, report_name, report_type, file_type, file_path, created_at FROM report_exports WHERE report_id = ?";
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

    public List<ReportExport> findAll() throws Exception {
        String sql = "SELECT report_id, created_by, report_name, report_type, file_type, file_path, created_at FROM report_exports ORDER BY report_id DESC";
        List<ReportExport> list = new ArrayList<ReportExport>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(ReportExport item) throws Exception {
        String sql = "INSERT INTO report_exports (created_by, report_name, report_type, file_type, file_path) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getCreatedBy());
            ps.setString(2, item.getReportName());
            ps.setString(3, item.getReportType());
            ps.setString(4, item.getFileType());
            ps.setString(5, item.getFilePath());
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

    public boolean update(ReportExport item) throws Exception {
        String sql = "UPDATE report_exports SET created_by = ?, report_name = ?, report_type = ?, file_type = ?, file_path = ? WHERE report_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getCreatedBy());
            ps.setString(2, item.getReportName());
            ps.setString(3, item.getReportType());
            ps.setString(4, item.getFileType());
            ps.setString(5, item.getFilePath());
            ps.setInt(6, item.getReportId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM report_exports WHERE report_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}