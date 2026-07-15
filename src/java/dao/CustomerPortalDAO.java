package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLSyntaxErrorException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Customer;
import model.CustomerRentalContract;
import model.CustomerRentedGenerator;
import model.Generator;
import model.Notification;
import util.DBUtil;

public class CustomerPortalDAO extends BaseDAO {

    public Customer findCustomerByEmail(String email) throws Exception {
        String sql = "SELECT customer_id, customer_name, phone, email, address, status, created_at, updated_at "
                + "FROM customers WHERE LOWER(email) = LOWER(?) AND status = 'ACTIVE'";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerId(rs.getInt("customer_id"));
                    customer.setCustomerName(rs.getString("customer_name"));
                    customer.setPhone(rs.getString("phone"));
                    customer.setEmail(rs.getString("email"));
                    customer.setAddress(rs.getString("address"));
                    customer.setStatus(rs.getString("status"));
                    customer.setCreatedAt(rs.getTimestamp("created_at"));
                    customer.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return customer;
                }
            }
        }

        return null;
    }

    public List<CustomerRentalContract> findContractsForCustomer(int customerId) throws Exception {
        String sql = "SELECT rc.rental_contract_id, rc.contract_code, c.customer_name, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, COUNT(rcd.detail_id) AS generator_count "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "LEFT JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                + "WHERE rc.customer_id = ? "
                + "GROUP BY rc.rental_contract_id, rc.contract_code, c.customer_name, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note "
                + "ORDER BY rc.rental_contract_id DESC";

        List<CustomerRentalContract> contracts = new ArrayList<CustomerRentalContract>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    contracts.add(mapContract(rs));
                }
            }
        } catch (SQLSyntaxErrorException ex) {
            if (isMissingRentalTable(ex)) {
                return contracts;
            }
            throw ex;
        }

        return contracts;
    }

    public List<CustomerRentedGenerator> findActiveGeneratorsForCustomer(int customerId) throws Exception {
        String sql = "SELECT g.generator_id, g.generator_name, COALESCE(rcd.serial_number, g.serial_number) AS serial_number, g.brand, g.power_value, "
                + "g.fuel_type, g.status AS generator_status, rc.contract_code, rc.rental_contract_id, "
                + "rc.start_date, rc.expected_return_date, rcd.rental_price "
                + "FROM rental_contracts rc "
                + "INNER JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                + "INNER JOIN generators g ON rcd.generator_id = g.generator_id "
                + "WHERE rc.customer_id = ? "
                + "AND rc.status IN ('APPROVED', 'DELIVERED', 'OVERDUE') "
                + "ORDER BY rc.expected_return_date ASC, g.generator_id DESC";

        List<CustomerRentedGenerator> generators = new ArrayList<CustomerRentedGenerator>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerRentedGenerator item = new CustomerRentedGenerator();
                    item.setGeneratorId(rs.getInt("generator_id"));
                    item.setGeneratorName(rs.getString("generator_name"));
                    item.setSerialNumber(rs.getString("serial_number"));
                    item.setBrand(rs.getString("brand"));
                    item.setPowerValue(rs.getString("power_value"));
                    item.setFuelType(rs.getString("fuel_type"));
                    item.setGeneratorStatus(rs.getString("generator_status"));
                    item.setContractCode(rs.getString("contract_code"));
                    item.setRentalContractId(rs.getInt("rental_contract_id"));
                    item.setStartDate(rs.getTimestamp("start_date"));
                    item.setExpectedReturnDate(rs.getTimestamp("expected_return_date"));
                    item.setRentalPrice(rs.getBigDecimal("rental_price"));
                    generators.add(item);
                }
            }
        } catch (SQLSyntaxErrorException ex) {
            if (isMissingRentalTable(ex)) {
                return generators;
            }
            throw ex;
        }

        return generators;
    }

    public List<Notification> findNotificationsForUser(int userId) throws Exception {
        String sql = "SELECT notification_id, user_id, title, message, type, is_read, created_at "
                + "FROM notifications WHERE user_id = ? ORDER BY notification_id DESC";
        List<Notification> notifications = new ArrayList<Notification>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification item = new Notification();
                    item.setNotificationId(rs.getInt("notification_id"));
                    item.setUserId(rs.getInt("user_id"));
                    item.setTitle(rs.getString("title"));
                    item.setMessage(rs.getString("message"));
                    item.setType(rs.getString("type"));
                    item.setRead(rs.getBoolean("is_read"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    notifications.add(item);
                }
            }
        }

        return notifications;
    }

    public List<Generator> findAvailableGeneratorsForRental() throws Exception {
        String sql = "SELECT generator_id, warehouse_id, supplier_id, generator_name, serial_number, brand, "
                + "power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note, "
                + "created_at, updated_at "
                + "FROM generators "
                + "WHERE status = 'IN_STOCK' "
                + "ORDER BY generator_name ASC, generator_id DESC";

        List<Generator> generators = new ArrayList<Generator>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Generator item = new Generator();
                item.setGeneratorId(rs.getInt("generator_id"));
                item.setWarehouseId(rs.getInt("warehouse_id"));
                item.setSupplierId(getNullableInt(rs, "supplier_id"));
                item.setGeneratorName(rs.getString("generator_name"));
                item.setSerialNumber(rs.getString("serial_number"));
                item.setBrand(rs.getString("brand"));
                item.setPowerValue(rs.getString("power_value"));
                item.setFuelType(rs.getString("fuel_type"));
                item.setOriginType(rs.getString("origin_type"));
                item.setImportDate(rs.getTimestamp("import_date"));
                item.setPurchasePrice(rs.getBigDecimal("purchase_price"));
                item.setLocation(rs.getString("location"));
                item.setStatus(rs.getString("status"));
                item.setNote(rs.getString("note"));
                item.setCreatedAt(rs.getTimestamp("created_at"));
                item.setUpdatedAt(rs.getTimestamp("updated_at"));
                generators.add(item);
            }
        }

        return generators;
    }

    public int createRentalRequest(int customerId, int createdBy, int generatorId,
            Timestamp startDate, Timestamp expectedReturnDate, String note) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            GeneratorSelection selection = findAvailableGeneratorForUpdate(conn, generatorId);
            if (selection == null) {
                conn.rollback();
                return 0;
            }

            String contractCode = "REQ-" + System.currentTimeMillis();
            int contractId = insertRentalContract(conn, customerId, selection.warehouseId, createdBy,
                    contractCode, startDate, expectedReturnDate, note);
            if (contractId <= 0) {
                conn.rollback();
                return 0;
            }

            int detailId = insertRentalContractDetail(conn, contractId, generatorId);
            if (detailId <= 0) {
                conn.rollback();
                return 0;
            }

            conn.commit();
            return contractId;
        } catch (Exception ex) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    ex.addSuppressed(rollbackEx);
                }
            }
            throw ex;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
                conn.close();
            }
        }
    }

    public int countUnreadNotifications(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private CustomerRentalContract mapContract(ResultSet rs) throws Exception {
        CustomerRentalContract item = new CustomerRentalContract();
        item.setRentalContractId(rs.getInt("rental_contract_id"));
        item.setContractCode(rs.getString("contract_code"));
        item.setCustomerName(rs.getString("customer_name"));
        item.setWarehouseName(rs.getString("warehouse_name"));
        item.setStartDate(rs.getTimestamp("start_date"));
        item.setExpectedReturnDate(rs.getTimestamp("expected_return_date"));
        item.setActualReturnDate(rs.getTimestamp("actual_return_date"));
        item.setStatus(rs.getString("status"));
        item.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        item.setTotalAmount(rs.getBigDecimal("total_amount"));
        item.setNote(rs.getString("note"));
        item.setGeneratorCount(rs.getInt("generator_count"));
        return item;
    }

    private GeneratorSelection findAvailableGeneratorForUpdate(Connection conn, int generatorId) throws Exception {
        String sql = "SELECT generator_id, warehouse_id FROM generators WHERE generator_id = ? AND status = 'IN_STOCK' FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, generatorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    GeneratorSelection selection = new GeneratorSelection();
                    selection.generatorId = rs.getInt("generator_id");
                    selection.warehouseId = rs.getInt("warehouse_id");
                    return selection;
                }
            }
        }
        return null;
    }

    private int insertRentalContract(Connection conn, int customerId, int warehouseId, int createdBy,
            String contractCode, Timestamp startDate, Timestamp expectedReturnDate, String note) throws Exception {
        String sql = "INSERT INTO rental_contracts "
                + "(customer_id, warehouse_id, created_by, approved_by, contract_code, start_date, "
                + "expected_return_date, actual_return_date, status, deposit_amount, total_amount, note) "
                + "VALUES (?, ?, ?, NULL, ?, ?, ?, NULL, 'PENDING', 0.00, 0.00, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setInt(2, warehouseId);
            ps.setInt(3, createdBy);
            ps.setString(4, contractCode);
            ps.setTimestamp(5, startDate);
            ps.setTimestamp(6, expectedReturnDate);
            ps.setString(7, note);

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

    private int insertRentalContractDetail(Connection conn, int contractId, int generatorId) throws Exception {
        String sql = "INSERT INTO rental_contract_details "
                + "(rental_contract_id, generator_id, rental_price, note) "
                + "VALUES (?, ?, 0.00, 'Customer rental request')";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contractId);
            ps.setInt(2, generatorId);

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

    private boolean isMissingRentalTable(SQLSyntaxErrorException ex) {
        String message = ex.getMessage();
        return message != null
                && (message.contains("rental_contracts")
                || message.contains("rental_contract_details"));
    }

    private static class GeneratorSelection {
        private int generatorId;
        private int warehouseId;
    }
}
