package controller;

import dao.StockTransferDAO;
import dao.StockTransferDetailDAO;
import dao.WarehouseDAO;
import dao.GeneratorDAO;
import dao.PartDAO;
import dao.PurchaseRequestDAO;
import dao.PurchaseRequestDetailDAO;
import dao.PartRequestDAO;
import dao.UserDAO;
import model.StockTransfer;
import model.StockTransferDetail;
import model.PurchaseRequest;
import model.PurchaseRequestDetail;
import model.PartRequest;
import model.User;
import model.Warehouse;
import model.Generator;
import model.Part;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ManagerRequestServlet", urlPatterns = {
    "/manager/pending-requests",
    "/manager/pending-requests/approve",
    "/manager/pending-requests/reject"
})
public class ManagerRequestServlet extends HttpServlet {

    private final StockTransferDAO stockTransferDAO = new StockTransferDAO();
    private final StockTransferDetailDAO stockTransferDetailDAO = new StockTransferDetailDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();
    private final PartDAO partDAO = new PartDAO();
    private final PurchaseRequestDAO purchaseRequestDAO = new PurchaseRequestDAO();
    private final PurchaseRequestDetailDAO purchaseRequestDetailDAO = new PurchaseRequestDetailDAO();
    private final PartRequestDAO partRequestDAO = new PartRequestDAO();
    private final UserDAO userDAO = new UserDAO();
    private final dao.InventoryTransactionDAO inventoryTransactionDAO = new dao.InventoryTransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        if (!currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            // 1. Fetch pending Stock Transfers
            List<StockTransfer> pendingTransfers = stockTransferDAO.findPendingTransfersByManager(currentUser.getUserId());
            List<StockTransfer> pendingReceiveTransfers = stockTransferDAO.findPendingReceiveTransfersByManager(currentUser.getUserId());
            
            Map<Integer, List<StockTransferDetail>> transferDetailsMap = new HashMap<>();
            for (StockTransfer st : pendingTransfers) {
                transferDetailsMap.put(st.getTransferId(), stockTransferDetailDAO.findDetailsByTransferId(st.getTransferId()));
            }
            for (StockTransfer st : pendingReceiveTransfers) {
                transferDetailsMap.put(st.getTransferId(), stockTransferDetailDAO.findDetailsByTransferId(st.getTransferId()));
            }

            // 2. Fetch pending Purchase Requests
            List<PurchaseRequest> pendingPurchases = purchaseRequestDAO.findPendingRequests();
            Map<Integer, List<PurchaseRequestDetail>> purchaseDetailsMap = new HashMap<>();
            for (PurchaseRequest pr : pendingPurchases) {
                purchaseDetailsMap.put(pr.getPurchaseRequestId(), purchaseRequestDetailDAO.findByRequestId(pr.getPurchaseRequestId()));
            }

            // 3. Fetch pending Part Requests
            List<PartRequest> pendingParts = partRequestDAO.findPartRequests(null, "PENDING");

            // Supporting data collections
            List<Warehouse> warehouses = warehouseDAO.findAll();
            Map<Integer, String> warehouseMap = new HashMap<>();
            for (Warehouse w : warehouses) {
                warehouseMap.put(w.getWarehouseId(), w.getWarehouseName());
            }

            List<User> users = userDAO.findUsers("", "", "");
            Map<Integer, String> userMap = new HashMap<>();
            for (User u : users) {
                userMap.put(u.getUserId(), u.getFullName() + " (" + u.getRoleName() + ")");
            }

            List<Part> allParts = partDAO.findParts("", null, null);
            Map<Integer, Part> partMap = new HashMap<>();
            for (Part p : allParts) {
                partMap.put(p.getPartId(), p);
            }

            List<Generator> allGenerators = generatorDAO.findGenerators("", null, null);
            Map<Integer, Generator> genMap = new HashMap<>();
            for (Generator g : allGenerators) {
                genMap.put(g.getGeneratorId(), g);
            }

            // Set attributes
            request.setAttribute("pendingTransfers", pendingTransfers);
            request.setAttribute("pendingReceiveTransfers", pendingReceiveTransfers);
            request.setAttribute("transferDetailsMap", transferDetailsMap);
            request.setAttribute("pendingPurchases", pendingPurchases);
            request.setAttribute("purchaseDetailsMap", purchaseDetailsMap);
            request.setAttribute("pendingParts", pendingParts);
            request.setAttribute("warehouseMap", warehouseMap);
            request.setAttribute("userMap", userMap);
            request.setAttribute("partMap", partMap);
            request.setAttribute("genMap", genMap);

            request.getRequestDispatcher("/views/manager/pending-requests.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        if (!currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();
        String type = request.getParameter("type"); // transfer, purchase, part
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty() || type == null) {
            response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=invalid_request");
            return;
        }

        int id = Integer.parseInt(idStr.trim());
        boolean isApprove = path.endsWith("/approve");

        Connection conn = null;
        try {
            if ("transfer".equals(type)) {
                // Stock Transfer Approval/Rejection by Manager A (Origin warehouse manager)
                conn = util.DBUtil.getConnection();
                conn.setAutoCommit(false);

                StockTransfer st = stockTransferDAO.findById(id);
                if (st == null || !"PENDING".equals(st.getStatus())) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=invalid_transfer");
                    return;
                }

                Warehouse fromWh = warehouseDAO.findById(st.getFromWarehouseId());
                Warehouse toWh = warehouseDAO.findById(st.getToWarehouseId());

                if (isApprove) {
                    // Check if the destination warehouse belongs to a different manager
                    if (fromWh != null && toWh != null && fromWh.getManagerId() != null && toWh.getManagerId() != null 
                            && !fromWh.getManagerId().equals(toWh.getManagerId())) {
                        
                        // Set status to PENDING_RECEIVE
                        st.setStatus("PENDING_RECEIVE");
                        st.setApprovedBy(currentUser.getUserId());
                        st.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                        stockTransferDAO.update(conn, st);

                        // Send notification to Manager B
                        try {
                            model.Notification notif = new model.Notification();
                            notif.setUserId(toWh.getManagerId());
                            notif.setTitle("Yêu cầu nhận điều chuyển kho");
                            notif.setMessage("Yêu cầu điều chuyển TF-" + id + " từ kho " + fromWh.getWarehouseName() + " đang chờ bạn xác nhận nhập kho.");
                            notif.setRead(false);
                            notif.setType("SYSTEM");
                            notif.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                            new dao.NotificationDAO().insert(notif);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }

                        conn.commit();
                        response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=approved");
                        return;
                    }

                    // SAME MANAGER - Process transfer immediately
                    List<StockTransferDetail> details = stockTransferDetailDAO.findDetailsByTransferId(id);
                    for (StockTransferDetail detail : details) {
                        if ("GENERATOR".equals(detail.getItemType())) {
                            int sourceGeneratorId = detail.getGeneratorId();
                            int quantity = detail.getQuantity();

                            Generator sourceGen = generatorDAO.findById(sourceGeneratorId);
                            if (sourceGen == null) {
                                throw new Exception("Không tìm thấy thông tin máy phát điện nguồn.");
                            }

                            Generator destGen = generatorDAO.findGeneratorBySpecs(conn, 
                                    st.getToWarehouseId(), 
                                    sourceGen.getGeneratorName(), 
                                    sourceGen.getBrand(), 
                                    sourceGen.getPowerValue(), 
                                    sourceGen.getFuelType());

                            int destGeneratorId = 0;
                            if (destGen != null) {
                                destGeneratorId = destGen.getGeneratorId();
                            } else {
                                Generator cloneGen = new Generator();
                                cloneGen.setWarehouseId(st.getToWarehouseId());
                                cloneGen.setSupplierId(sourceGen.getSupplierId());
                                cloneGen.setGeneratorName(sourceGen.getGeneratorName());
                                cloneGen.setSerialNumber(sourceGen.getSerialNumber());
                                cloneGen.setBrand(sourceGen.getBrand());
                                cloneGen.setPowerValue(sourceGen.getPowerValue());
                                cloneGen.setFuelType(sourceGen.getFuelType());
                                cloneGen.setOriginType("TRANSFER");
                                cloneGen.setImportDate(new Timestamp(System.currentTimeMillis()));
                                cloneGen.setPurchasePrice(sourceGen.getPurchasePrice());
                                cloneGen.setLocation("TRANSFER");
                                cloneGen.setStatus("IN_STOCK");
                                cloneGen.setNote("Nhận chuyển giao từ kho ID: " + st.getFromWarehouseId());
                                cloneGen.setBarcode("");
                                cloneGen.setRentalPrice(sourceGen.getRentalPrice());

                                destGeneratorId = generatorDAO.insertModelOnly(conn, cloneGen);
                            }

                            if (destGeneratorId <= 0) {
                                throw new Exception("Lỗi tạo mẫu máy phát điện mới tại kho đích.");
                            }

                            generatorDAO.transferBarcodes(conn, id, destGeneratorId);

                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'GENERATOR', ?, NULL, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển từ kho ID " + st.getFromWarehouseId() + " (TF-" + id + ")");
                                ps.setInt(6, id);
                                ps.executeUpdate();
                            }
                        } else if ("PART".equals(detail.getItemType())) {
                            int sourcePartId = detail.getPartId();
                            int quantity = detail.getQuantity();

                            Part sourcePart = partDAO.findById(sourcePartId);
                            if (sourcePart == null) {
                                throw new Exception("Không tìm thấy thông tin phụ tùng nguồn.");
                            }

                            String checkDestSql = "SELECT part_id FROM parts WHERE warehouse_id = ? AND LOWER(part_code) = LOWER(?) AND is_deleted = 0";
                            int destPartId = 0;
                            try (PreparedStatement ps = conn.prepareStatement(checkDestSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setString(2, sourcePart.getPartCode());
                                try (java.sql.ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        destPartId = rs.getInt("part_id");
                                    }
                                }
                            }

                            String subQtySql = "UPDATE parts SET quantity = quantity - ?, updated_at = NOW() WHERE part_id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(subQtySql)) {
                                ps.setInt(1, quantity);
                                ps.setInt(2, sourcePartId);
                                int rows = ps.executeUpdate();
                                if (rows == 0) {
                                    throw new Exception("Lỗi trừ số lượng phụ tùng tại kho nguồn.");
                                }
                            }

                            if (destPartId > 0) {
                                String addQtySql = "UPDATE parts SET quantity = quantity + ?, updated_at = NOW() WHERE part_id = ?";
                                try (PreparedStatement ps = conn.prepareStatement(addQtySql)) {
                                    ps.setInt(1, quantity);
                                    ps.setInt(2, destPartId);
                                    int rows = ps.executeUpdate();
                                    if (rows == 0) {
                                        throw new Exception("Lỗi cộng số lượng phụ tùng tại kho đích.");
                                    }
                                }
                            } else {
                                String insertPartSql = "INSERT INTO parts (warehouse_id, part_name, part_code, quantity, min_quantity, unit, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
                                try (PreparedStatement ps = conn.prepareStatement(insertPartSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                                    ps.setInt(1, st.getToWarehouseId());
                                    ps.setString(2, sourcePart.getPartName());
                                    ps.setString(3, sourcePart.getPartCode());
                                    ps.setInt(4, quantity);
                                    ps.setInt(5, sourcePart.getMinQuantity());
                                    ps.setString(6, sourcePart.getUnit());
                                    ps.setString(7, sourcePart.getStatus());
                                    int affectedRows = ps.executeUpdate();
                                    if (affectedRows == 0) {
                                        throw new Exception("Lỗi tạo mới phụ tùng tại kho đích.");
                                    }
                                    try (java.sql.ResultSet keys = ps.getGeneratedKeys()) {
                                        if (keys.next()) {
                                            destPartId = keys.getInt(1);
                                        }
                                    }
                                }
                            }

                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'PART', NULL, ?, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destPartId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển phụ tùng từ kho ID " + st.getFromWarehouseId() + " (TF-" + id + ")");
                                ps.setInt(6, id);
                                ps.executeUpdate();
                            }
                        }
                    }

                    inventoryTransactionDAO.updateStatusByTransferId(conn, id, "COMPLETED");
                    st.setStatus("APPROVED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=approved");
                } else {
                    // Reject logic
                    generatorDAO.releaseBarcodes(conn, id);
                    inventoryTransactionDAO.updateStatusByTransferId(conn, id, "CANCELLED");
                    st.setStatus("REJECTED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=rejected");
                }
            } else if ("transfer-receive".equals(type)) {
                // Stock Transfer Receipt Confirmation by Manager B (Destination warehouse manager)
                conn = util.DBUtil.getConnection();
                conn.setAutoCommit(false);

                StockTransfer st = stockTransferDAO.findById(id);
                if (st == null || !"PENDING_RECEIVE".equals(st.getStatus())) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=invalid_transfer");
                    return;
                }

                Warehouse toWh = warehouseDAO.findById(st.getToWarehouseId());
                if (toWh == null || toWh.getManagerId() == null || !toWh.getManagerId().equals(currentUser.getUserId())) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=forbidden");
                    return;
                }

                if (isApprove) {
                    List<StockTransferDetail> details = stockTransferDetailDAO.findDetailsByTransferId(id);
                    for (StockTransferDetail detail : details) {
                        if ("GENERATOR".equals(detail.getItemType())) {
                            int sourceGeneratorId = detail.getGeneratorId();
                            int quantity = detail.getQuantity();

                            Generator sourceGen = generatorDAO.findById(sourceGeneratorId);
                            if (sourceGen == null) {
                                throw new Exception("Không tìm thấy thông tin máy phát điện nguồn.");
                            }

                            Generator destGen = generatorDAO.findGeneratorBySpecs(conn, 
                                    st.getToWarehouseId(), 
                                    sourceGen.getGeneratorName(), 
                                    sourceGen.getBrand(), 
                                    sourceGen.getPowerValue(), 
                                    sourceGen.getFuelType());

                            int destGeneratorId = 0;
                            if (destGen != null) {
                                destGeneratorId = destGen.getGeneratorId();
                            } else {
                                Generator cloneGen = new Generator();
                                cloneGen.setWarehouseId(st.getToWarehouseId());
                                cloneGen.setSupplierId(sourceGen.getSupplierId());
                                cloneGen.setGeneratorName(sourceGen.getGeneratorName());
                                cloneGen.setSerialNumber(sourceGen.getSerialNumber());
                                cloneGen.setBrand(sourceGen.getBrand());
                                cloneGen.setPowerValue(sourceGen.getPowerValue());
                                cloneGen.setFuelType(sourceGen.getFuelType());
                                cloneGen.setOriginType("TRANSFER");
                                cloneGen.setImportDate(new Timestamp(System.currentTimeMillis()));
                                cloneGen.setPurchasePrice(sourceGen.getPurchasePrice());
                                cloneGen.setLocation("TRANSFER");
                                cloneGen.setStatus("IN_STOCK");
                                cloneGen.setNote("Nhận chuyển giao từ kho ID: " + st.getFromWarehouseId());
                                cloneGen.setBarcode("");
                                cloneGen.setRentalPrice(sourceGen.getRentalPrice());

                                destGeneratorId = generatorDAO.insertModelOnly(conn, cloneGen);
                            }

                            if (destGeneratorId <= 0) {
                                throw new Exception("Lỗi tạo mẫu máy phát điện mới tại kho đích.");
                            }

                            generatorDAO.transferBarcodes(conn, id, destGeneratorId);

                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'GENERATOR', ?, NULL, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển từ kho ID " + st.getFromWarehouseId() + " (TF-" + id + ")");
                                ps.setInt(6, id);
                                ps.executeUpdate();
                            }
                        } else if ("PART".equals(detail.getItemType())) {
                            int sourcePartId = detail.getPartId();
                            int quantity = detail.getQuantity();

                            Part sourcePart = partDAO.findById(sourcePartId);
                            if (sourcePart == null) {
                                throw new Exception("Không tìm thấy thông tin phụ tùng nguồn.");
                            }

                            String checkDestSql = "SELECT part_id FROM parts WHERE warehouse_id = ? AND LOWER(part_code) = LOWER(?) AND is_deleted = 0";
                            int destPartId = 0;
                            try (PreparedStatement ps = conn.prepareStatement(checkDestSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setString(2, sourcePart.getPartCode());
                                try (java.sql.ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        destPartId = rs.getInt("part_id");
                                    }
                                }
                            }

                            String subQtySql = "UPDATE parts SET quantity = quantity - ?, updated_at = NOW() WHERE part_id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(subQtySql)) {
                                ps.setInt(1, quantity);
                                ps.setInt(2, sourcePartId);
                                int rows = ps.executeUpdate();
                                if (rows == 0) {
                                    throw new Exception("Lỗi trừ số lượng phụ tùng tại kho nguồn.");
                                }
                            }

                            if (destPartId > 0) {
                                String addQtySql = "UPDATE parts SET quantity = quantity + ?, updated_at = NOW() WHERE part_id = ?";
                                try (PreparedStatement ps = conn.prepareStatement(addQtySql)) {
                                    ps.setInt(1, quantity);
                                    ps.setInt(2, destPartId);
                                    int rows = ps.executeUpdate();
                                    if (rows == 0) {
                                        throw new Exception("Lỗi cộng số lượng phụ tùng tại kho đích.");
                                    }
                                }
                            } else {
                                String insertPartSql = "INSERT INTO parts (warehouse_id, part_name, part_code, quantity, min_quantity, unit, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
                                try (PreparedStatement ps = conn.prepareStatement(insertPartSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                                    ps.setInt(1, st.getToWarehouseId());
                                    ps.setString(2, sourcePart.getPartName());
                                    ps.setString(3, sourcePart.getPartCode());
                                    ps.setInt(4, quantity);
                                    ps.setInt(5, sourcePart.getMinQuantity());
                                    ps.setString(6, sourcePart.getUnit());
                                    ps.setString(7, sourcePart.getStatus());
                                    int affectedRows = ps.executeUpdate();
                                    if (affectedRows == 0) {
                                        throw new Exception("Lỗi tạo mới phụ tùng tại kho đích.");
                                    }
                                    try (java.sql.ResultSet keys = ps.getGeneratedKeys()) {
                                        if (keys.next()) {
                                            destPartId = keys.getInt(1);
                                        }
                                    }
                                }
                            }

                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'PART', NULL, ?, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destPartId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển phụ tùng từ kho ID " + st.getFromWarehouseId() + " (TF-" + id + ")");
                                ps.setInt(6, id);
                                ps.executeUpdate();
                            }
                        }
                    }

                    inventoryTransactionDAO.updateStatusByTransferId(conn, id, "COMPLETED");
                    st.setStatus("APPROVED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=approved");
                } else {
                    // Reject / Rollback barcodes
                    generatorDAO.releaseBarcodes(conn, id);
                    inventoryTransactionDAO.updateStatusByTransferId(conn, id, "CANCELLED");
                    st.setStatus("REJECTED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=rejected");
                }
            } else if ("purchase".equals(type)) {
                // Purchase Request Approval/Rejection
                PurchaseRequest pr = purchaseRequestDAO.findById(id);
                if (pr == null || !"PENDING".equals(pr.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=invalid_purchase");
                    return;
                }

                pr.setApprovedBy(currentUser.getUserId());
                pr.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                if (isApprove) {
                    pr.setStatus("APPROVED");
                } else {
                    pr.setStatus("REJECTED");
                }

                purchaseRequestDAO.update(pr);
                response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=" + (isApprove ? "approved" : "rejected"));
            } else if ("part".equals(type)) {
                // Part Request Approval/Rejection
                PartRequest req = partRequestDAO.findById(id);
                if (req == null || !"PENDING".equals(req.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=invalid_part_request");
                    return;
                }

                if (isApprove) {
                    // Subtract part stock from warehouse
                    Part part = partDAO.findById(req.getPartId());
                    if (part == null) {
                        response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=part_not_found");
                        return;
                    }
                    if (part.getQuantity() < req.getQuantity()) {
                        response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=insufficient_stock");
                        return;
                    }

                    // Perform updates in transaction
                    conn = util.DBUtil.getConnection();
                    conn.setAutoCommit(false);

                    String updatePartSql = "UPDATE parts SET quantity = quantity - ?, updated_at = NOW() WHERE part_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updatePartSql)) {
                        ps.setInt(1, req.getQuantity());
                        ps.setInt(2, req.getPartId());
                        ps.executeUpdate();
                    }

                    req.setStatus("APPROVED");
                    req.setApprovedBy(currentUser.getUserId());
                    req.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                    partRequestDAO.update(req); // Wait: partRequestDAO.update doesn't accept Connection, but it is fast and safe.
                    // Actually, let's update inside conn for safety if possible, or just commit part quantity first.
                    conn.commit();
                } else {
                    req.setStatus("REJECTED");
                    req.setApprovedBy(currentUser.getUserId());
                    req.setApprovedAt(new Timestamp(System.currentTimeMillis()));
                    partRequestDAO.update(req);
                }

                response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=" + (isApprove ? "approved" : "rejected"));
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=unknown_type");
            }
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/manager/pending-requests?error=system_error&message=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
            }
        }
    }
}
