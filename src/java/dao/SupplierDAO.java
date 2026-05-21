package dao;

import util.DBUtil;
import model.Supplier;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SupplierDAO extends BaseDAO {

    private Supplier mapResultSet(ResultSet rs) throws Exception {
        Supplier item = new Supplier();
        item.setSupplierId(rs.getInt("supplier_id"));
        item.setSupplierName(rs.getString("supplier_name"));
        item.setPhone(rs.getString("phone"));
        item.setEmail(rs.getString("email"));
        item.setAddress(rs.getString("address"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    public Supplier findById(int id) throws Exception {
        String sql = "SELECT supplier_id, supplier_name, phone, email, address, status, created_at FROM suppliers WHERE supplier_id = ?";
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

    public List<Supplier> findAll() throws Exception {
        String sql = "SELECT supplier_id, supplier_name, phone, email, address, status, created_at FROM suppliers ORDER BY supplier_id DESC";
        List<Supplier> list = new ArrayList<Supplier>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    public int insert(Supplier item) throws Exception {
        String sql = "INSERT INTO suppliers (supplier_name, phone, email, address, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getSupplierName());
            ps.setString(2, item.getPhone());
            ps.setString(3, item.getEmail());
            ps.setString(4, item.getAddress());
            ps.setString(5, item.getStatus());
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

    public boolean update(Supplier item) throws Exception {
        String sql = "UPDATE suppliers SET supplier_name = ?, phone = ?, email = ?, address = ?, status = ? WHERE supplier_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getSupplierName());
            ps.setString(2, item.getPhone());
            ps.setString(3, item.getEmail());
            ps.setString(4, item.getAddress());
            ps.setString(5, item.getStatus());
            ps.setInt(6, item.getSupplierId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM suppliers WHERE supplier_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}