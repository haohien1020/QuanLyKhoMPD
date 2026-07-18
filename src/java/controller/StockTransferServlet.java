package controller;

import dao.GeneratorDAO;
import dao.StockTransferDAO;
import dao.StockTransferDetailDAO;
import dao.WarehouseDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;
import model.Generator;
import model.StockTransfer;
import model.StockTransferDetail;
import model.User;
import model.Warehouse;

@WebServlet(name = "StockTransferServlet", urlPatterns = {
    "/stock-transfers",
    "/stock-transfers/create",
    "/stock-transfers/approve",
    "/stock-transfers/reject",
    "/stock-transfers/cancel"
})
public class StockTransferServlet extends HttpServlet {

    private final StockTransferDAO stockTransferDAO = new StockTransferDAO();
    private final StockTransferDetailDAO stockTransferDetailDAO = new StockTransferDetailDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();
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

        if (!currentUser.hasRole("WAREHOUSE_MANAGER") && !currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();

        try {
            Warehouse managedWarehouse = null;
            if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null) {
                    request.setAttribute("error", "Tài khoản của bạn chưa được chỉ định quản lý kho nào.");
                    request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
                    return;
                }
                request.setAttribute("managedWarehouse", managedWarehouse);
            }

            if ("/stock-transfers/create".equals(path)) {
                if (managedWarehouse == null) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Chỉ Thủ kho được tạo yêu cầu điều chuyển.");
                    return;
                }
                List<Warehouse> allWarehouses = warehouseDAO.findAll();
                List<Warehouse> destWarehouses = new ArrayList<>();
                for (Warehouse w : allWarehouses) {
                    if (w.getWarehouseId() != managedWarehouse.getWarehouseId() && "ACTIVE".equals(w.getStatus())) {
                        destWarehouses.add(w);
                    }
                }
                List<Generator> generators = generatorDAO.findGenerators("", managedWarehouse.getWarehouseId(), "IN_STOCK");

                request.setAttribute("destWarehouses", destWarehouses);
                request.setAttribute("generators", generators);
                request.getRequestDispatcher("/views/transfer/stock-transfer-create.jsp").forward(request, response);
            } else {
                List<StockTransfer> list;
                if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                    list = stockTransferDAO.findTransfersByWarehouse(managedWarehouse.getWarehouseId());
                } else if (currentUser.hasRole("MANAGER")) {
                    list = stockTransferDAO.findTransfersByManager(currentUser.getUserId());
                } else {
                    list = stockTransferDAO.findAll();
                }
                
                java.util.Map<Integer, List<StockTransferDetail>> detailsMap = new java.util.HashMap<>();
                for (StockTransfer st : list) {
                    detailsMap.put(st.getTransferId(), stockTransferDetailDAO.findDetailsByTransferId(st.getTransferId()));
                }
                
                List<Generator> allGenerators = generatorDAO.findGenerators("", null, null);
                List<Warehouse> allWarehouses = warehouseDAO.findAll();
                
                request.setAttribute("transfers", list);
                request.setAttribute("detailsMap", detailsMap);
                request.setAttribute("allGenerators", allGenerators);
                request.setAttribute("warehouses", allWarehouses);
                request.getRequestDispatcher("/views/transfer/stock-transfer-list.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải trang: " + e.getMessage());
            request.getRequestDispatcher("/views/transfer/stock-transfer-list.jsp").forward(request, response);
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

        String path = request.getServletPath();

        if ("/stock-transfers/create".equals(path)) {
            if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            java.sql.Connection conn = null;
            try {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null) {
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=no_warehouse");
                    return;
                }

                int toWarehouseId = Integer.parseInt(request.getParameter("toWarehouseId"));
                String itemType = request.getParameter("itemType"); // GENERATOR

                conn = util.DBUtil.getConnection();
                conn.setAutoCommit(false);

                StockTransfer st = new StockTransfer();
                st.setFromWarehouseId(managedWarehouse.getWarehouseId());
                st.setToWarehouseId(toWarehouseId);
                st.setCreatedBy(currentUser.getUserId());
                st.setStatus("PENDING");

                int transferId = stockTransferDAO.insert(conn, st);
                if (transferId > 0) {
                    List<StockTransferDetail> detailsList = new ArrayList<>();
                    if ("GENERATOR".equals(itemType)) {
                        String[] generatorIds = request.getParameterValues("generatorId");
                        if (generatorIds != null) {
                            for (String gIdStr : generatorIds) {
                                if (gIdStr.isEmpty()) continue;
                                int gId = Integer.parseInt(gIdStr);

                                // Check stock in source warehouse
                                List<model.GeneratorBarcode> barcodes = generatorDAO.findBarcodes(managedWarehouse.getWarehouseId(), "IN_STOCK");
                                int avail = 0;
                                for (model.GeneratorBarcode gb : barcodes) {
                                    if (gb.getGeneratorId() == gId) {
                                        avail++;
                                    }
                                }
                                if (avail < 1) {
                                    throw new Exception("Không đủ máy phát điện trong kho để thực hiện điều chuyển.");
                                }

                                StockTransferDetail std = new StockTransferDetail();
                                std.setTransferId(transferId);
                                std.setItemType("GENERATOR");
                                std.setGeneratorId(gId);
                                std.setQuantity(1);
                                stockTransferDetailDAO.insert(conn, std);
                                detailsList.add(std);

                                // Lock barcode
                                boolean locked = generatorDAO.lockBarcodesForTransfer(conn, gId, 1, transferId);
                                if (!locked) {
                                    throw new Exception("Không thể khóa máy phát điện để chuyển.");
                                }
                            }
                        }
                    }

                    if (!detailsList.isEmpty()) {
                        inventoryTransactionDAO.createPendingTransactionsForTransfer(conn, transferId, managedWarehouse.getWarehouseId(), currentUser.getUserId(), detailsList);
                        conn.commit();

                        // Send notification to the manager supervising this warehouse
                        try {
                            if (managedWarehouse.getManagerId() != null) {
                                model.Notification notif = new model.Notification();
                                notif.setUserId(managedWarehouse.getManagerId());
                                notif.setTitle("Yêu cầu điều chuyển kho mới");
                                notif.setMessage("Yêu cầu điều chuyển mới TF-" + transferId + " từ kho " + managedWarehouse.getWarehouseName() + " đang chờ bạn phê duyệt.");
                                notif.setRead(false);
                                notif.setType("SYSTEM");
                                notif.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                                new dao.NotificationDAO().insert(notif);
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }

                        response.sendRedirect(request.getContextPath() + "/stock-transfers?success=created");
                    } else {
                        throw new Exception("Chưa chọn sản phẩm nào để điều chuyển.");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/stock-transfers/create?error=failed");
                }
            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ignored) {}
                }
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/stock-transfers/create?error=system_error&message=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            } finally {
                if (conn != null) {
                    try { conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
                }
            }
        } else if ("/stock-transfers/cancel".equals(path)) {
            if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            int transferId = Integer.parseInt(request.getParameter("transferId"));
            java.sql.Connection conn = null;
            try {
                conn = util.DBUtil.getConnection();
                conn.setAutoCommit(false);

                StockTransfer st = stockTransferDAO.findById(transferId);
                if (st == null || !"PENDING".equals(st.getStatus())) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=invalid_transfer");
                    return;
                }

                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null || st.getFromWarehouseId() != managedWarehouse.getWarehouseId()) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=forbidden");
                    return;
                }

                // Rollback / Cancel logic:
                // 1. Release barcodes (change status back to 'IN_STOCK', transfer_id = null)
                generatorDAO.releaseBarcodes(conn, transferId);

                // 2. Set pending export transactions to 'CANCELLED'
                inventoryTransactionDAO.updateStatusByTransferId(conn, transferId, "CANCELLED");

                // 3. Set the transfer status to 'CANCELLED'
                st.setStatus("CANCELLED");
                st.setApprovedBy(currentUser.getUserId()); // warehouse manager who cancelled it
                st.setApprovedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                stockTransferDAO.update(conn, st);

                conn.commit();
                response.sendRedirect(request.getContextPath() + "/stock-transfers?success=cancelled");
            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ignored) {}
                }
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/stock-transfers?error=cancel_error");
            } finally {
                if (conn != null) {
                    try { conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
                }
            }
        } else if ("/stock-transfers/approve".equals(path) || "/stock-transfers/reject".equals(path)) {
            if (!currentUser.hasRole("MANAGER")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            int transferId = Integer.parseInt(request.getParameter("transferId"));
            java.sql.Connection conn = null;
            try {
                conn = util.DBUtil.getConnection();
                conn.setAutoCommit(false);

                StockTransfer st = stockTransferDAO.findById(transferId);
                if (st == null || (!"PENDING".equals(st.getStatus()) && !"PENDING_RECEIVE".equals(st.getStatus()))) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=invalid_transfer");
                    return;
                }

                Warehouse fromWh = warehouseDAO.findById(st.getFromWarehouseId());
                Warehouse toWh = warehouseDAO.findById(st.getToWarehouseId());

                if ("/stock-transfers/approve".equals(path)) {
                    if ("PENDING".equals(st.getStatus())) {
                        // Check if the destination warehouse belongs to a different manager
                        if (fromWh != null && toWh != null && fromWh.getManagerId() != null && toWh.getManagerId() != null 
                                && !fromWh.getManagerId().equals(toWh.getManagerId())) {
                            
                            // Set status to PENDING_RECEIVE
                            st.setStatus("PENDING_RECEIVE");
                            st.setApprovedBy(currentUser.getUserId());
                            st.setApprovedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                            stockTransferDAO.update(conn, st);

                            // Send notification to Manager B
                            try {
                                model.Notification notif = new model.Notification();
                                notif.setUserId(toWh.getManagerId());
                                notif.setTitle("Yêu cầu nhận điều chuyển kho");
                                notif.setMessage("Yêu cầu điều chuyển TF-" + transferId + " từ kho " + fromWh.getWarehouseName() + " đang chờ bạn xác nhận nhận kho.");
                                notif.setRead(false);
                                notif.setType("SYSTEM");
                                notif.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                                new dao.NotificationDAO().insert(notif);
                            } catch (Exception ex) {
                                ex.printStackTrace();
                            }

                            conn.commit();
                            response.sendRedirect(request.getContextPath() + "/stock-transfers?success=approved");
                            return;
                        }
                    } else if ("PENDING_RECEIVE".equals(st.getStatus())) {
                        // Must be destination manager to approve receipt
                        if (toWh == null || toWh.getManagerId() == null || !toWh.getManagerId().equals(currentUser.getUserId())) {
                            conn.rollback();
                            response.sendRedirect(request.getContextPath() + "/stock-transfers?error=forbidden");
                            return;
                        }
                    }

                    // Run transfer logic
                    List<StockTransferDetail> details = stockTransferDetailDAO.findDetailsByTransferId(transferId);
                    for (StockTransferDetail detail : details) {
                        if ("GENERATOR".equals(detail.getItemType())) {
                            int sourceGeneratorId = detail.getGeneratorId();
                            int quantity = detail.getQuantity();

                            // Load source generator model details
                            Generator sourceGen = generatorDAO.findById(sourceGeneratorId);
                            if (sourceGen == null) {
                                throw new Exception("Không tìm thấy thông tin máy phát điện nguồn.");
                            }

                            // Check if the destination warehouse already has a matching model
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
                                // Clone model to destination warehouse
                                Generator cloneGen = new Generator();
                                cloneGen.setWarehouseId(st.getToWarehouseId());
                                cloneGen.setSupplierId(sourceGen.getSupplierId());
                                cloneGen.setGeneratorName(sourceGen.getGeneratorName());
                                cloneGen.setSerialNumber(sourceGen.getSerialNumber());
                                cloneGen.setBrand(sourceGen.getBrand());
                                cloneGen.setPowerValue(sourceGen.getPowerValue());
                                cloneGen.setFuelType(sourceGen.getFuelType());
                                cloneGen.setOriginType("TRANSFER");
                                cloneGen.setImportDate(new java.sql.Timestamp(System.currentTimeMillis()));
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

                            // Move barcodes
                            generatorDAO.transferBarcodes(conn, transferId, destGeneratorId);

                            // Log IMPORT transaction in inventory_transactions for destination warehouse
                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, quantity, note, status, transfer_id) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'GENERATOR', ?, ?, ?, 'COMPLETED', ?)";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển từ kho ID " + st.getFromWarehouseId() + " (Phiếu điều chuyển TF-" + transferId + ")");
                                ps.setInt(6, transferId);
                                ps.executeUpdate();
                            }
                        }
                    }

                    // Update pending EXPORT transactions to COMPLETED
                    inventoryTransactionDAO.updateStatusByTransferId(conn, transferId, "COMPLETED");

                    // Update transfer status
                    st.setStatus("APPROVED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?success=approved");
                } else if ("/stock-transfers/reject".equals(path)) {
                    if ("PENDING_RECEIVE".equals(st.getStatus())) {
                        // Must be destination manager to reject receipt
                        if (toWh == null || toWh.getManagerId() == null || !toWh.getManagerId().equals(currentUser.getUserId())) {
                            conn.rollback();
                            response.sendRedirect(request.getContextPath() + "/stock-transfers?error=forbidden");
                            return;
                        }
                    }

                    // Reject logic - Release barcodes
                    generatorDAO.releaseBarcodes(conn, transferId);

                    // Update pending EXPORT transactions to CANCELLED
                    inventoryTransactionDAO.updateStatusByTransferId(conn, transferId, "CANCELLED");

                    // Update transfer status
                    st.setStatus("REJECTED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?success=rejected");
                }
            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ignored) {}
                }
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/stock-transfers?error=approval_error");
            } finally {
                if (conn != null) {
                    try { conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }
}
