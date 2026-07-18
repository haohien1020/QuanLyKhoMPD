package controller;

import dao.StockTransferDAO;
import dao.StockTransferDetailDAO;
import dao.WarehouseDAO;
import dao.GeneratorDAO;
import dao.UserDAO;
import model.StockTransfer;
import model.StockTransferDetail;
import model.User;
import model.Warehouse;
import model.Generator;

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

            List<Generator> allGenerators = generatorDAO.findGenerators("", null, null);
            Map<Integer, Generator> genMap = new HashMap<>();
            for (Generator g : allGenerators) {
                genMap.put(g.getGeneratorId(), g);
            }

            // Set attributes
            request.setAttribute("pendingTransfers", pendingTransfers);
            request.setAttribute("pendingReceiveTransfers", pendingReceiveTransfers);
            request.setAttribute("transferDetailsMap", transferDetailsMap);
            request.setAttribute("warehouseMap", warehouseMap);
            request.setAttribute("userMap", userMap);
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
        String type = request.getParameter("type"); // transfer, purchase
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

                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'GENERATOR', ?, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển từ kho ID " + st.getFromWarehouseId() + " (TF-" + id + ")");
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

                    try {
                        model.Notification notif = new model.Notification();
                        notif.setUserId(st.getCreatedBy());
                        notif.setTitle("Yêu cầu điều chuyển kho được phê duyệt");
                        notif.setMessage("Yêu cầu điều chuyển TF-" + id + " đã được phê duyệt bởi Quản lý " + currentUser.getFullName() + ".");
                        notif.setRead(false);
                        notif.setType("SYSTEM");
                        notif.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                        new dao.NotificationDAO().insert(notif);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

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

                    try {
                        model.Notification notif = new model.Notification();
                        notif.setUserId(st.getCreatedBy());
                        notif.setTitle("Yêu cầu điều chuyển kho bị từ chối");
                        notif.setMessage("Yêu cầu điều chuyển TF-" + id + " đã bị từ chối bởi Quản lý " + currentUser.getFullName() + ".");
                        notif.setRead(false);
                        notif.setType("SYSTEM");
                        notif.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                        new dao.NotificationDAO().insert(notif);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

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

                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'GENERATOR', ?, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển từ kho ID " + st.getFromWarehouseId() + " (TF-" + id + ")");
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

                    try {
                        model.Notification notif = new model.Notification();
                        notif.setUserId(st.getCreatedBy());
                        notif.setTitle("Yêu cầu nhận điều chuyển kho được xác nhận");
                        notif.setMessage("Yêu cầu nhận điều chuyển TF-" + id + " đã được xác nhận nhập kho thành công bởi Quản lý " + currentUser.getFullName() + ".");
                        notif.setRead(false);
                        notif.setType("SYSTEM");
                        notif.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                        new dao.NotificationDAO().insert(notif);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

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

                    try {
                        model.Notification notif = new model.Notification();
                        notif.setUserId(st.getCreatedBy());
                        notif.setTitle("Yêu cầu nhận điều chuyển kho bị từ chối");
                        notif.setMessage("Yêu cầu nhận điều chuyển TF-" + id + " đã bị từ chối nhận kho bởi Quản lý " + currentUser.getFullName() + ".");
                        notif.setRead(false);
                        notif.setType("SYSTEM");
                        notif.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                        new dao.NotificationDAO().insert(notif);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/manager/pending-requests?success=rejected");
                }
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
