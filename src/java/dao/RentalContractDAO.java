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
        
        // Additional mapped columns with try-catch for optional selection in different queries
        try {
            item.setSellerName(rs.getString("seller_name"));
        } catch (java.sql.SQLException e) {}
        try {
            item.setCustomerPhone(rs.getString("customer_phone"));
        } catch (java.sql.SQLException e) {}
        try {
            item.setCustomerEmail(rs.getString("customer_email"));
        } catch (java.sql.SQLException e) {}
        try {
            item.setGeneratorName(rs.getString("generator_name"));
        } catch (java.sql.SQLException e) {}
        try {
            String txNote = null;
            try {
                txNote = rs.getString("transaction_note");
            } catch (java.sql.SQLException e) {}
            
            if (txNote != null && txNote.contains("Serial:")) {
                int idx = txNote.indexOf("Serial:");
                String sub = txNote.substring(idx + 7).trim();
                if (sub.endsWith(")")) {
                    sub = sub.substring(0, sub.length() - 1).trim();
                }
                item.setSerialNumber(sub);
            } else {
                String genSerial = rs.getString("serial_number");
                item.setSerialNumber(genSerial != null && !genSerial.isEmpty() ? genSerial : "Chưa cập nhật");
            }
        } catch (java.sql.SQLException e) {
            item.setSerialNumber("Chưa cập nhật");
        }
        try {
            item.setBrand(rs.getString("brand"));
        } catch (java.sql.SQLException e) {}
        try {
            item.setPowerValue(rs.getString("power_value"));
        } catch (java.sql.SQLException e) {}
        try {
            item.setFuelType(rs.getString("fuel_type"));
        } catch (java.sql.SQLException e) {}
        try {
            item.setRentalPrice(rs.getBigDecimal("rental_price"));
        } catch (java.sql.SQLException e) {}
        try {
            int staffId = rs.getInt("assigned_staff_id");
            item.setAssignedStaffId(rs.wasNull() ? null : staffId);
            item.setAssignedStaffName(rs.getString("assigned_staff_name"));
        } catch (java.sql.SQLException e) {}
        try {
            int genId = rs.getInt("generator_id");
            item.setGeneratorId(rs.wasNull() ? null : genId);
        } catch (java.sql.SQLException e) {}
        try {
            item.setCreatedBy(rs.getInt("created_by"));
        } catch (java.sql.SQLException e) {}
        
        return item;
    }

    public List<CustomerRentalContract> findContractsByWarehouse(int warehouseId) throws Exception {
        String sql = "SELECT rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, "
                + "c.phone AS customer_phone, c.email AS customer_email, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, rc.created_by, u.full_name AS seller_name, "
                + "MAX(g.generator_name) AS generator_name, "
                + "GROUP_CONCAT(COALESCE(rcd.serial_number, g.serial_number) ORDER BY rcd.detail_id SEPARATOR ', ') AS serial_number, "
                + "MAX(g.brand) AS brand, MAX(g.power_value) AS power_value, MAX(g.fuel_type) AS fuel_type, "
                + "MAX(rcd.rental_price) AS rental_price, MAX(rcd.generator_id) AS generator_id, "
                + "rc.assigned_staff_id, u2.full_name AS assigned_staff_name, "
                + "(SELECT t.note FROM inventory_transactions t "
                + " WHERE t.transaction_type = 'EXPORT' "
                + "   AND t.item_type = 'GENERATOR' "
                + "   AND t.note LIKE CONCAT('%', rc.contract_code, '%') "
                + " LIMIT 1) AS transaction_note "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "INNER JOIN users u ON rc.created_by = u.user_id "
                + "LEFT JOIN users u2 ON rc.assigned_staff_id = u2.user_id "
                + "LEFT JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                + "LEFT JOIN generators g ON rcd.generator_id = g.generator_id "
                + "WHERE rc.warehouse_id = ? "
                + "GROUP BY rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, "
                + "c.phone, c.email, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, rc.created_by, u.full_name, "
                + "rc.assigned_staff_id, u2.full_name "
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
        String sql = "SELECT rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, "
                + "c.phone AS customer_phone, c.email AS customer_email, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, rc.created_by, u.full_name AS seller_name, "
                + "MAX(g.generator_name) AS generator_name, "
                + "GROUP_CONCAT(COALESCE(rcd.serial_number, g.serial_number) ORDER BY rcd.detail_id SEPARATOR ', ') AS serial_number, "
                + "MAX(g.brand) AS brand, MAX(g.power_value) AS power_value, MAX(g.fuel_type) AS fuel_type, "
                + "MAX(rcd.rental_price) AS rental_price, MAX(rcd.generator_id) AS generator_id, "
                + "rc.assigned_staff_id, u2.full_name AS assigned_staff_name, "
                + "(SELECT t.note FROM inventory_transactions t "
                + " WHERE t.transaction_type = 'EXPORT' "
                + "   AND t.item_type = 'GENERATOR' "
                + "   AND t.note LIKE CONCAT('%', rc.contract_code, '%') "
                + " LIMIT 1) AS transaction_note "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "INNER JOIN users u ON rc.created_by = u.user_id "
                + "LEFT JOIN users u2 ON rc.assigned_staff_id = u2.user_id "
                + "LEFT JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                + "LEFT JOIN generators g ON rcd.generator_id = g.generator_id "
                + "WHERE rc.rental_contract_id = ? "
                + "GROUP BY rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, "
                + "c.phone, c.email, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, rc.created_by, u.full_name, "
                + "rc.assigned_staff_id, u2.full_name";

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
        String sql = "SELECT g.generator_id, g.generator_name, COALESCE(rcd.serial_number, g.serial_number) AS serial_number, g.brand, g.power_value, "
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
                              double totalAmount, String note, String[] generatorIds, String serialNumbersStr, double rentalPrice) throws Exception {
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

            String sqlDetail = "INSERT INTO rental_contract_details (rental_contract_id, generator_id, rental_price, serial_number, note) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                if (serialNumbersStr != null && !serialNumbersStr.trim().isEmpty()) {
                    String[] serials = serialNumbersStr.split(",\\s*");
                    for (String serial : serials) {
                        if (serial == null || serial.trim().isEmpty()) continue;
                        serial = serial.trim();
                        
                        // Find generator_id from generator_barcodes
                        int genId = 0;
                        String sqlGetGenId = "SELECT generator_id FROM generator_barcodes WHERE serial_number = ? AND is_deleted = 0";
                        try (PreparedStatement psGen = conn.prepareStatement(sqlGetGenId)) {
                            psGen.setString(1, serial);
                            try (ResultSet rsGen = psGen.executeQuery()) {
                                if (rsGen.next()) {
                                    genId = rsGen.getInt("generator_id");
                                }
                            }
                        }
                        
                        // If not found in barcodes (fallback), look up in generators table
                        if (genId == 0) {
                            String sqlGetGenIdFallback = "SELECT generator_id FROM generators WHERE serial_number = ?";
                            try (PreparedStatement psGenFallback = conn.prepareStatement(sqlGetGenIdFallback)) {
                                psGenFallback.setString(1, serial);
                                try (ResultSet rsGenFallback = psGenFallback.executeQuery()) {
                                    if (rsGenFallback.next()) {
                                        genId = rsGenFallback.getInt("generator_id");
                                    }
                                }
                            }
                        }
                        
                        ps.setInt(1, contractId);
                        ps.setInt(2, genId);
                        ps.setDouble(3, rentalPrice);
                        ps.setString(4, serial);
                        ps.setString(5, "Seller rental request");
                        ps.addBatch();
                    }
                    ps.executeBatch();
                } else if (generatorIds != null) {
                    for (String gIdStr : generatorIds) {
                        if (gIdStr == null || gIdStr.trim().isEmpty()) continue;
                        int genId = Integer.parseInt(gIdStr.trim());
                        
                        // Retrieve serial number for this generator
                        String serialNumber = "";
                        String sqlGetSerial = "SELECT serial_number FROM generators WHERE generator_id = ?";
                        try (PreparedStatement psSerial = conn.prepareStatement(sqlGetSerial)) {
                            psSerial.setInt(1, genId);
                            try (ResultSet rsSerial = psSerial.executeQuery()) {
                                if (rsSerial.next()) {
                                    serialNumber = rsSerial.getString("serial_number");
                                }
                            }
                        }
                        
                        ps.setInt(1, contractId);
                        ps.setInt(2, genId);
                        ps.setDouble(3, rentalPrice);
                        ps.setString(4, serialNumber);
                        ps.setString(5, "Seller rental request");
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
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
                                  String note, String[] generatorIds, String serialNumbersStr, double rentalPrice) throws Exception {
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

            String sqlDetail = "INSERT INTO rental_contract_details (rental_contract_id, generator_id, rental_price, serial_number, note) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                if (serialNumbersStr != null && !serialNumbersStr.trim().isEmpty()) {
                    String[] serials = serialNumbersStr.split(",\\s*");
                    for (String serial : serials) {
                        if (serial == null || serial.trim().isEmpty()) continue;
                        serial = serial.trim();
                        
                        // Find generator_id from generator_barcodes
                        int genId = 0;
                        String sqlGetGenId = "SELECT generator_id FROM generator_barcodes WHERE serial_number = ? AND is_deleted = 0";
                        try (PreparedStatement psGen = conn.prepareStatement(sqlGetGenId)) {
                            psGen.setString(1, serial);
                            try (ResultSet rsGen = psGen.executeQuery()) {
                                if (rsGen.next()) {
                                    genId = rsGen.getInt("generator_id");
                                }
                            }
                        }
                        
                        // If not found in barcodes (fallback), look up in generators table
                        if (genId == 0) {
                            String sqlGetGenIdFallback = "SELECT generator_id FROM generators WHERE serial_number = ?";
                            try (PreparedStatement psGenFallback = conn.prepareStatement(sqlGetGenIdFallback)) {
                                psGenFallback.setString(1, serial);
                                try (ResultSet rsGenFallback = psGenFallback.executeQuery()) {
                                    if (rsGenFallback.next()) {
                                        genId = rsGenFallback.getInt("generator_id");
                                    }
                                }
                            }
                        }
                        
                        ps.setInt(1, contractId);
                        ps.setInt(2, genId);
                        ps.setDouble(3, rentalPrice);
                        ps.setString(4, serial);
                        ps.setString(5, "Seller rental request updated");
                        ps.addBatch();
                    }
                    ps.executeBatch();
                } else if (generatorIds != null) {
                    for (String gIdStr : generatorIds) {
                        if (gIdStr == null || gIdStr.trim().isEmpty()) continue;
                        int genId = Integer.parseInt(gIdStr.trim());
                        
                        // Retrieve serial number for this generator
                        String serialNumber = "";
                        String sqlGetSerial = "SELECT serial_number FROM generators WHERE generator_id = ?";
                        try (PreparedStatement psSerial = conn.prepareStatement(sqlGetSerial)) {
                            psSerial.setInt(1, genId);
                            try (ResultSet rsSerial = psSerial.executeQuery()) {
                                if (rsSerial.next()) {
                                    serialNumber = rsSerial.getString("serial_number");
                                }
                            }
                        }
                        
                        ps.setInt(1, contractId);
                        ps.setInt(2, genId);
                        ps.setDouble(3, rentalPrice);
                        ps.setString(4, serialNumber);
                        ps.setString(5, "Seller rental request updated");
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
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
    public boolean assignStaff(int contractId, int staffId) throws Exception {
        String sql = "UPDATE rental_contracts SET assigned_staff_id = ?, updated_at = NOW() WHERE rental_contract_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, contractId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Integer> findAssignedGeneratorIds(int staffId) throws Exception {
        String sql = "SELECT rcd.generator_id FROM rental_contracts rc "
                   + "JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                   + "WHERE rc.assigned_staff_id = ? AND rc.status IN ('APPROVED', 'DELIVERED')";
        List<Integer> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("generator_id"));
                }
            }
        }
        return list;
    }

    public List<CustomerRentalContract> findContractsAssignedToStaff(int staffId) throws Exception {
        try {
            syncDeliveredContracts();
        } catch (Exception e) {
            e.printStackTrace();
        }
        String sql = "SELECT rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, "
                + "c.phone AS customer_phone, c.email AS customer_email, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, rc.created_by, u.full_name AS seller_name, "
                + "MAX(g.generator_name) AS generator_name, "
                + "GROUP_CONCAT(COALESCE(rcd.serial_number, g.serial_number) ORDER BY rcd.detail_id SEPARATOR ', ') AS serial_number, "
                + "MAX(g.brand) AS brand, MAX(g.power_value) AS power_value, MAX(g.fuel_type) AS fuel_type, "
                + "MAX(rcd.rental_price) AS rental_price, MAX(rcd.generator_id) AS generator_id, "
                + "rc.assigned_staff_id, u2.full_name AS assigned_staff_name, "
                + "(SELECT t.note FROM inventory_transactions t "
                + " WHERE t.transaction_type = 'EXPORT' "
                + "   AND t.item_type = 'GENERATOR' "
                + "   AND t.note LIKE CONCAT('%', rc.contract_code, '%') "
                + " LIMIT 1) AS transaction_note "
                + "FROM rental_contracts rc "
                + "INNER JOIN customers c ON rc.customer_id = c.customer_id "
                + "INNER JOIN warehouses w ON rc.warehouse_id = w.warehouse_id "
                + "INNER JOIN users u ON rc.created_by = u.user_id "
                + "LEFT JOIN users u2 ON rc.assigned_staff_id = u2.user_id "
                + "LEFT JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                + "LEFT JOIN generators g ON rcd.generator_id = g.generator_id "
                + "WHERE rc.assigned_staff_id = ? "
                + "GROUP BY rc.rental_contract_id, rc.customer_id, rc.warehouse_id, rc.contract_code, c.customer_name, "
                + "c.phone, c.email, w.warehouse_name, "
                + "rc.start_date, rc.expected_return_date, rc.actual_return_date, rc.status, "
                + "rc.deposit_amount, rc.total_amount, rc.note, rc.created_by, u.full_name, "
                + "rc.assigned_staff_id, u2.full_name "
                + "ORDER BY rc.rental_contract_id DESC";

        List<CustomerRentalContract> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerRentalContract item = mapResultSet(rs);
                    list.add(item);
                }
            }
        }
        return list;
    }

    public void syncDeliveredContracts() {
        String sqlSelect = "SELECT rc.rental_contract_id, rc.contract_code FROM rental_contracts rc WHERE rc.status = 'DELIVERED'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlSelect);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                int contractId = rs.getInt("rental_contract_id");
                String contractCode = rs.getString("contract_code");
                
                // Check if all generators in this contract are now returned (none are EXPORTED)
                String sqlCheckGens = "SELECT COUNT(*) FROM rental_contract_details rcd "
                        + "JOIN generator_barcodes gb ON rcd.serial_number = gb.serial_number "
                        + "WHERE rcd.rental_contract_id = ? AND gb.status = 'EXPORTED'";
                
                boolean allReturned = true;
                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckGens)) {
                    psCheck.setInt(1, contractId);
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                            allReturned = false;
                        }
                    }
                }
                
                if (allReturned) {
                    // Update this contract to COMPLETED
                    // Find actual return date from latest IMPORT transaction, fallback to NOW()
                    Timestamp returnDate = new Timestamp(System.currentTimeMillis());
                    String sqlGetDate = "SELECT MAX(transaction_date) FROM inventory_transactions t "
                            + "WHERE t.transaction_type = 'IMPORT' AND t.note LIKE ?";
                    try (PreparedStatement psDate = conn.prepareStatement(sqlGetDate)) {
                        psDate.setString(1, "%" + contractCode + "%");
                        try (ResultSet rsDate = psDate.executeQuery()) {
                            if (rsDate.next() && rsDate.getTimestamp(1) != null) {
                                returnDate = rsDate.getTimestamp(1);
                            }
                        }
                    }
                    
                    String sqlUpdate = "UPDATE rental_contracts SET status = 'COMPLETED', actual_return_date = ? "
                            + "WHERE rental_contract_id = ?";
                    try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                        psUpdate.setTimestamp(1, returnDate);
                        psUpdate.setInt(2, contractId);
                        psUpdate.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void checkAndCompleteContractForReturnedBarcode(String serialNumber, int userId) {
        if (serialNumber == null || serialNumber.trim().isEmpty()) {
            return;
        }
        try {
            // Find active (DELIVERED) contract for this serial number
            String sqlFind = "SELECT rc.rental_contract_id, rc.contract_code FROM rental_contracts rc "
                    + "JOIN rental_contract_details rcd ON rc.rental_contract_id = rcd.rental_contract_id "
                    + "WHERE rc.status = 'DELIVERED' AND rcd.serial_number = ? "
                    + "LIMIT 1";
            int contractId = 0;
            String contractCode = "";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                ps.setString(1, serialNumber.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        contractId = rs.getInt("rental_contract_id");
                        contractCode = rs.getString("contract_code");
                    }
                }
            }

            if (contractId > 0) {
                // Check if all generators in this contract are now returned (none are EXPORTED)
                String sqlCheckGens = "SELECT COUNT(*) FROM rental_contract_details rcd "
                        + "JOIN generator_barcodes gb ON rcd.serial_number = gb.serial_number "
                        + "WHERE rcd.rental_contract_id = ? AND gb.status = 'EXPORTED'";
                boolean allReturned = true;
                try (Connection conn = DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sqlCheckGens)) {
                    ps.setInt(1, contractId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            allReturned = false;
                        }
                    }
                }

                if (allReturned) {
                    updateContractStatus(contractId, "COMPLETED", userId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
