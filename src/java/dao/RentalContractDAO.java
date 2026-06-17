package dao;

import util.DBUtil;
import model.CustomerRentalContract;
import model.CustomerRentedGenerator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class RentalContractDAO extends BaseDAO {

    private CustomerRentalContract mapResultSet(ResultSet rs) throws Exception {
        CustomerRentalContract item = new CustomerRentalContract();
        item.setRentalContractId(rs.getInt("rental_contract_id"));
        item.setCustomerId(rs.getInt("customer_id"));
        item.setWarehouseId(rs.getInt("warehouse_id"));
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
        return item;
    }

    public List<CustomerRentalContract> findContractsByWarehouse(int warehouseId) throws Exception {
        String sql = "SELECT rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "WHERE rc.warehouse_id = ? "
                + "ORDER BY rc.rental_contract_id DESC";

        List<CustomerRentalContract> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerRentalContract item = mapResultSet(rs);
                    list.add(item);
                }
            }
        }
        return list;
    }

    public CustomerRentalContract findContractById(int contractId) throws Exception {
        String sql = "SELECT rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "WHERE rc.rental_contract_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public List<CustomerRentedGenerator> getGeneratorsForContract(int contractId) throws Exception {
        String sql = "SELECT g.generator_id, g.generator_name, g.serial_number, g.brand, g.power_value, "
                + "g.fuel_type, g.status AS generator_status, rcd.rental_price "
                + "FROM rental_contract_details rcd "
                + "INNER JOIN generators g ON rcd.generator_id = g.generator_id "
                + "WHERE rcd.rental_contract_id = ?";

        List<CustomerRentedGenerator> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
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
                    item.setRentalPrice(rs.getBigDecimal("rental_price"));
                    item.setRentalContractId(contractId);
                    list.add(item);
                }
            }
        }
        return list;
    }

    public boolean updateContractStatus(int contractId, String status, Integer approvedBy) throws Exception {
        String sql = "UPDATE rental_contracts SET status = ?, approved_by = ?, actual_return_date = ? WHERE rental_contract_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            setNullableInt(ps, 2, approvedBy);
            if ("COMPLETED".equals(status)) {
                ps.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            } else {
                ps.setTimestamp(3, null);
            }
            ps.setInt(4, contractId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean assignStaffToCheck(int generatorId, int reportedBy, int assignedTo, String issueDescription) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Check if generator is currently in stock
            // 2. Create record in maintenance_repairs
            String insertRepairSql = "INSERT INTO maintenance_repairs (generator_id, reported_by, assigned_to, issue_description, repair_status) VALUES (?, ?, ?, ?, 'IN_PROGRESS')";
            int repairId = 0;
            try (PreparedStatement ps = conn.prepareStatement(insertRepairSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, generatorId);
                ps.setInt(2, reportedBy);
                setNullableInt(ps, 3, assignedTo);
                ps.setString(4, issueDescription);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        repairId = keys.getInt(1);
                    }
                }
            }

            if (repairId <= 0) {
                conn.rollback();
                return false;
            }

            // 3. Update generator status to 'UNDER_REPAIR'
            String updateGenSql = "UPDATE generators SET status = 'UNDER_REPAIR' WHERE generator_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateGenSql)) {
                ps.setInt(1, generatorId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception ex) {
            if (conn != null) {
                conn.rollback();
            }
            throw ex;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public List<CustomerRentalContract> findAllContracts() throws Exception {
        String sql = "SELECT rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "ORDER BY rc.rental_contract_id DESC";

        List<CustomerRentalContract> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerRentalContract item = mapResultSet(rs);
                list.add(item);
            }
        }
        return list;
    }

    public int createContract(int customerId, int warehouseId, int createdBy, String contractCode, 
                              Timestamp startDate, Timestamp expectedReturnDate, double depositAmount, 
                              double totalAmount, String note, int generatorId, double rentalPrice) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String sql = "INSERT INTO rental_contracts "
                    + "(customer_id, warehouse_id, created_by, approved_by, contract_code, start_date, "
                    + "expected_return_date, actual_return_date, status, deposit_amount, total_amount, note) "
                    + "VALUES (?, ?, ?, NULL, ?, ?, ?, NULL, 'PENDING', ?, ?, ?)";

            int contractId = 0;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, warehouseId);
                ps.setInt(3, createdBy);
                ps.setString(4, contractCode);
                ps.setTimestamp(5, startDate);
                ps.setTimestamp(6, expectedReturnDate);
                ps.setDouble(7, depositAmount);
                ps.setDouble(8, totalAmount);
                ps.setString(9, note);

                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        contractId = keys.getInt(1);
                    }
                }
            }

            if (contractId <= 0) {
                conn.rollback();
                return 0;
            }

            String sqlDetail = "INSERT INTO rental_contract_details (rental_contract_id, generator_id, rental_price, note) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                ps.setInt(1, contractId);
                ps.setInt(2, generatorId);
                ps.setDouble(3, rentalPrice);
                ps.setString(4, "Seller rental request");
                ps.executeUpdate();
            }

            conn.commit();
            return contractId;
        } catch (Exception ex) {
            if (conn != null) {
                conn.rollback();
            }
            throw ex;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public boolean updateContract(int contractId, int customerId, int warehouseId, Timestamp startDate, 
                                  Timestamp expectedReturnDate, double depositAmount, double totalAmount, 
                                  String note, int generatorId, double rentalPrice) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String sql = "UPDATE rental_contracts SET customer_id = ?, warehouse_id = ?, start_date = ?, "
                    + "expected_return_date = ?, deposit_amount = ?, total_amount = ?, note = ? WHERE rental_contract_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, customerId);
                ps.setInt(2, warehouseId);
                ps.setTimestamp(3, startDate);
                ps.setTimestamp(4, expectedReturnDate);
                ps.setDouble(5, depositAmount);
                ps.setDouble(6, totalAmount);
                ps.setString(7, note);
                ps.setInt(8, contractId);
                ps.executeUpdate();
            }

            // Delete existing details and insert new details
            String sqlDeleteDetail = "DELETE FROM rental_contract_details WHERE rental_contract_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteDetail)) {
                ps.setInt(1, contractId);
                ps.executeUpdate();
            }

            String sqlDetail = "INSERT INTO rental_contract_details (rental_contract_id, generator_id, rental_price, note) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                ps.setInt(1, contractId);
                ps.setInt(2, generatorId);
                ps.setDouble(3, rentalPrice);
                ps.setString(4, "Seller rental request updated");
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception ex) {
            if (conn != null) {
                conn.rollback();
            }
            throw ex;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
}
