package controller;

import dao.GeneratorDAO;
import dao.PartDAO;
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
import model.Part;
import model.StockTransfer;
import model.StockTransferDetail;
import model.User;
import model.Warehouse;

@WebServlet(name = "StockTransferServlet", urlPatterns = {
    "/stock-transfers",
    "/stock-transfers/create",
    "/stock-transfers/approve",
    "/stock-transfers/reject"
})
public class StockTransferServlet extends HttpServlet {

    private final StockTransferDAO stockTransferDAO = new StockTransferDAO();
    private final StockTransferDetailDAO stockTransferDetailDAO = new StockTransferDetailDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();
    private final PartDAO partDAO = new PartDAO();

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
                List<Part> parts = partDAO.findParts("", managedWarehouse.getWarehouseId(), "ACTIVE");

                request.setAttribute("destWarehouses", destWarehouses);
                request.setAttribute("generators", generators);
                request.setAttribute("parts", parts);
                request.getRequestDispatcher("/views/transfer/stock-transfer-create.jsp").forward(request, response);
            } else {
                List<StockTransfer> list;
                if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                    list = stockTransferDAO.findTransfersByWarehouse(managedWarehouse.getWarehouseId());
                } else {
                    list = stockTransferDAO.findAll();
                }
                
                java.util.Map<Integer, List<StockTransferDetail>> detailsMap = new java.util.HashMap<>();
                for (StockTransfer st : list) {
                    detailsMap.put(st.getTransferId(), stockTransferDetailDAO.findDetailsByTransferId(st.getTransferId()));
                }
                
                List<Generator> allGenerators = generatorDAO.findGenerators("", null, null);
                List<Part> allParts = partDAO.findParts("", null, null);
                List<Warehouse> allWarehouses = warehouseDAO.findAll();
                
                request.setAttribute("transfers", list);
                request.setAttribute("detailsMap", detailsMap);
                request.setAttribute("allGenerators", allGenerators);
                request.setAttribute("allParts", allParts);
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
            try {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null) {
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=no_warehouse");
                    return;
                }

                int toWarehouseId = Integer.parseInt(request.getParameter("toWarehouseId"));
                String itemType = request.getParameter("itemType"); // GENERATOR or PART

                StockTransfer st = new StockTransfer();
                st.setFromWarehouseId(managedWarehouse.getWarehouseId());
                st.setToWarehouseId(toWarehouseId);
                st.setCreatedBy(currentUser.getUserId());
                st.setStatus("PENDING");

                int transferId = stockTransferDAO.insert(st);
                if (transferId > 0) {
                    if ("GENERATOR".equals(itemType)) {
                        String[] generatorIds = request.getParameterValues("generatorId");
                        if (generatorIds != null) {
                            for (String gIdStr : generatorIds) {
                                if (gIdStr.isEmpty()) continue;
                                int gId = Integer.parseInt(gIdStr);
                                StockTransferDetail std = new StockTransferDetail();
                                std.setTransferId(transferId);
                                std.setItemType("GENERATOR");
                                std.setGeneratorId(gId);
                                std.setPartId(null);
                                std.setQuantity(1);
                                stockTransferDetailDAO.insert(std);
                            }
                        }
                    } else {
                        String[] partIds = request.getParameterValues("partId");
                        String[] quantities = request.getParameterValues("quantity");
                        if (partIds != null && quantities != null) {
                            for (int i = 0; i < partIds.length; i++) {
                                if (partIds[i].isEmpty()) continue;
                                int pId = Integer.parseInt(partIds[i]);
                                int qty = Integer.parseInt(quantities[i]);

                                StockTransferDetail std = new StockTransferDetail();
                                std.setTransferId(transferId);
                                std.setItemType("PART");
                                std.setGeneratorId(null);
                                std.setPartId(pId);
                                std.setQuantity(qty);
                                stockTransferDetailDAO.insert(std);
                            }
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?success=created");
                } else {
                    response.sendRedirect(request.getContextPath() + "/stock-transfers/create?error=failed");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/stock-transfers/create?error=system_error");
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
                if (st == null || !"PENDING".equals(st.getStatus())) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=invalid_transfer");
                    return;
                }

                if ("/stock-transfers/approve".equals(path)) {
                    // Approve logic
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

                            // 2. Move barcodes
                            generatorDAO.transferBarcodes(conn, transferId, destGeneratorId);

                            // 3. Log transactions in inventory_transactions for EXPORT and IMPORT
                            // Source EXPORT transaction
                            String exportSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) "
                                             + "VALUES (?, NULL, ?, 'EXPORT', 'GENERATOR', ?, NULL, ?, ?, 'COMPLETED')";
                            try (PreparedStatement ps = conn.prepareStatement(exportSql)) {
                                ps.setInt(1, st.getFromWarehouseId());
                                ps.setInt(2, st.getCreatedBy());
                                ps.setInt(3, sourceGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Chuyển kho sang kho ID " + st.getToWarehouseId() + " (Phiếu điều chuyển TF-" + transferId + ")");
                                ps.executeUpdate();
                            }

                            // Destination IMPORT transaction
                            String importSql = "INSERT INTO inventory_transactions (warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) "
                                             + "VALUES (?, NULL, ?, 'IMPORT', 'GENERATOR', ?, NULL, ?, ?, 'COMPLETED')";
                            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                                ps.setInt(1, st.getToWarehouseId());
                                ps.setInt(2, currentUser.getUserId());
                                ps.setInt(3, destGeneratorId);
                                ps.setInt(4, quantity);
                                ps.setString(5, "Nhận điều chuyển từ kho ID " + st.getFromWarehouseId() + " (Phiếu điều chuyển TF-" + transferId + ")");
                                ps.executeUpdate();
                            }
                        }
                    }

                    // Update transfer status
                    st.setStatus("APPROVED");
                    st.setApprovedBy(currentUser.getUserId());
                    st.setApprovedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                    stockTransferDAO.update(conn, st);

                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?success=approved");
                } else if ("/stock-transfers/reject".equals(path)) {
                    // Reject logic - Release barcodes
                    generatorDAO.releaseBarcodes(conn, transferId);

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
