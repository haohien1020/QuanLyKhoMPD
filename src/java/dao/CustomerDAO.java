package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Customer;
import util.DBUtil;

public class CustomerDAO {

    private Customer mapResultSet(ResultSet rs) throws Exception {
        return new Customer(
                rs.getInt("customer_id"),
                rs.getString("customer_name"),
                rs.getString("phone"),
                rs.getString("email"),
                rs.getString("address"),
                rs.getString("status"),
                rs.getTimestamp("created_at"),
                rs.getTimestamp("updated_at")
        );
    }

    public Customer findById(int customerId) throws Exception {
        String sql = "SELECT customer_id, customer_name, phone, email, address, status, created_at, updated_at "
                + "FROM customers WHERE customer_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    public List<Customer> findCustomers(String keyword, String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT customer_id, customer_name, phone, email, address, status, created_at, updated_at ")
                .append("FROM customers WHERE 1 = 1 ");

        List<Object> params = new ArrayList<Object>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(customer_name) LIKE ? OR LOWER(email) LIKE ? OR phone LIKE ? OR LOWER(address) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
            params.add("%" + keyword.trim() + "%");
            params.add(search);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim());
        }

        sql.append("ORDER BY customer_id DESC");

        List<Customer> customers = new ArrayList<Customer>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    customers.add(mapResultSet(rs));
                }
            }
        }

        return customers;
    }

    public int insert(Customer customer) throws Exception {
        String sql = "INSERT INTO customers (customer_name, phone, email, address, status) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customer.getCustomerName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());
            ps.setString(4, customer.getAddress());
            ps.setString(5, customer.getStatus());

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

    public boolean update(Customer customer) throws Exception {
        String sql = "UPDATE customers "
                + "SET customer_name = ?, phone = ?, email = ?, address = ?, status = ?, updated_at = NOW() "
                + "WHERE customer_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customer.getCustomerName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());
            ps.setString(4, customer.getAddress());
            ps.setString(5, customer.getStatus());
            ps.setInt(6, customer.getCustomerId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int customerId, String status) throws Exception {
        String sql = "UPDATE customers SET status = ?, updated_at = NOW() WHERE customer_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean isEmailUsedByAnotherCustomer(String email, int customerId) throws Exception {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM customers WHERE LOWER(email) = LOWER(?) AND customer_id <> ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }
}
