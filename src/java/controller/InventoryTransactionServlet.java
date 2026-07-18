package controller;

import dao.InventoryTransactionDAO;
import dao.SupplierDAO;
import dao.WarehouseDAO;
import dao.RentalContractDAO;
import dao.GeneratorDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import model.InventoryTransaction;
import model.Supplier;
import model.User;
import model.Warehouse;
import model.CustomerRentalContract;
import model.Generator;

@WebServlet(name = "InventoryTransactionServlet", urlPatterns = {
        "/inventory-transactions",
        "/inventory-transactions/history"
})
public class InventoryTransactionServlet extends HttpServlet {

    private final InventoryTransactionDAO transactionDAO = new InventoryTransactionDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final RentalContractDAO rentalContractDAO = new RentalContractDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        boolean isManager = currentUser.hasRole("WAREHOUSE_MANAGER");
        boolean isStaff = currentUser.hasRole("STAFF");
        if (!isManager && !isStaff) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (isStaff && !currentUser.isCanImportInventory() && !currentUser.isCanExportInventory()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        String path = request.getServletPath();

        try {
            Warehouse managedWarehouse = null;
            if (isManager) {
                managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            } else if (isStaff) {
                Integer whId = currentUser.getWarehouseId();
                if (whId != null) {
                    managedWarehouse = warehouseDAO.findById(whId);
                }
            }

            if (managedWarehouse == null) {
                request.setAttribute("error", "Tài khoản của bạn chưa được chỉ định hoặc liên kết với bất kỳ kho hàng nào.");
                if (isManager) {
                    request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/views/home/staff-home.jsp").forward(request, response);
                }
                return;
            }
            request.setAttribute("managedWarehouse", managedWarehouse);

            if ("/inventory-transactions/history".equals(path)) {
                // Handle history logging list
                String q = request.getParameter("q");
                q = (q == null) ? "" : q.trim();

                String type = request.getParameter("type");
                type = (type == null) ? "" : type.trim();

                String itemType = request.getParameter("itemType");
                itemType = (itemType == null) ? "" : itemType.trim();

                String startStr = request.getParameter("startDate");
                String endStr = request.getParameter("endDate");

                Timestamp startDate = null;
                Timestamp endDate = null;
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

                if (startStr != null && !startStr.trim().isEmpty()) {
                    Date parsed = sdf.parse(startStr.trim());
                    startDate = new Timestamp(parsed.getTime());
                }
                if (endStr != null && !endStr.trim().isEmpty()) {
                    Date parsed = sdf.parse(endStr.trim());
                    // End of the selected day
                    endDate = new Timestamp(parsed.getTime() + 24 * 60 * 60 * 1000L - 1);
                }

                List<InventoryTransaction> list = transactionDAO.findTransactions(
                        managedWarehouse.getWarehouseId(), type, itemType, q, startDate, endDate);

                request.setAttribute("transactions", list);
                request.setAttribute("q", q);
                request.setAttribute("typeFilter", type);
                request.setAttribute("itemTypeFilter", itemType);
                request.setAttribute("startDateVal", startStr);
                request.setAttribute("endDateVal", endStr);

                request.getRequestDispatcher("/views/inventory/transaction-history.jsp").forward(request, response);
            } else {
                // Handle transaction actions form
                List<Supplier> suppliers = supplierDAO.findAll();
                List<Generator> generators = generatorDAO.findGenerators("", managedWarehouse.getWarehouseId(), null);
                
                // Get other active warehouses for stock transfers
                List<Warehouse> allWarehouses = warehouseDAO.findAll();
                List<Warehouse> destWarehouses = new java.util.ArrayList<>();
                for (Warehouse w : allWarehouses) {
                    if (w.getWarehouseId() != managedWarehouse.getWarehouseId() && "ACTIVE".equals(w.getStatus())) {
                        destWarehouses.add(w);
                    }
                }
                request.setAttribute("destWarehouses", destWarehouses);

                // Get barcodes for separate selections
                List<model.GeneratorBarcode> allBarcodes = generatorDAO.findBarcodes(managedWarehouse.getWarehouseId(), null);
                List<model.GeneratorBarcode> inStockBarcodes = new java.util.ArrayList<>();
                List<model.GeneratorBarcode> notInStockBarcodes = new java.util.ArrayList<>();
                
                List<Integer> assignedGenIds = null;
                if (isStaff) {
                    assignedGenIds = rentalContractDAO.findAssignedGeneratorIds(currentUser.getUserId());
                }

                for (model.GeneratorBarcode gb : allBarcodes) {
                    if ("IN_STOCK".equals(gb.getStatus())) {
                        if (isStaff) {
                            if (assignedGenIds != null && assignedGenIds.contains(gb.getGeneratorId())) {
                                inStockBarcodes.add(gb);
                            }
                        } else {
                            inStockBarcodes.add(gb);
                        }
                    } else {
                        notInStockBarcodes.add(gb);
                    }
                }

                // Get summary of rental contracts to help users find relevant rental actions
                List<CustomerRentalContract> pendingRentals = rentalContractDAO
                        .findContractsByWarehouse(managedWarehouse.getWarehouseId());

                List<CustomerRentalContract> approvedRentals = new java.util.ArrayList<>();
                if (isStaff) {
                    List<CustomerRentalContract> staffContracts = rentalContractDAO.findContractsAssignedToStaff(currentUser.getUserId());
                    if (staffContracts != null) {
                        for (CustomerRentalContract c : staffContracts) {
                            if ("APPROVED".equals(c.getStatus())) {
                                approvedRentals.add(c);
                            }
                        }
                    }
                } else {
                    for (CustomerRentalContract c : pendingRentals) {
                        if ("APPROVED".equals(c.getStatus())) {
                            approvedRentals.add(c);
                        }
                    }
                }

                request.setAttribute("suppliers", suppliers);
                request.setAttribute("generators", generators);
                request.setAttribute("inStockBarcodes", inStockBarcodes);
                request.setAttribute("notInStockBarcodes", notInStockBarcodes);
                request.setAttribute("pendingRentals", pendingRentals);
                request.setAttribute("approvedRentals", approvedRentals);

                request.getRequestDispatcher("/views/inventory/transaction-action.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải dữ liệu xuất nhập kho: " + e.getMessage());
            request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        boolean isManager = currentUser.hasRole("WAREHOUSE_MANAGER");
        boolean isStaff = currentUser.hasRole("STAFF");
        if (!isManager && !isStaff) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (isStaff && !currentUser.isCanImportInventory() && !currentUser.isCanExportInventory()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        String action = request.getParameter("action");
        
        // Authorize action based on specific transaction permission for staff
        if (isStaff) {
            if ("import-generator".equals(action)) {
                if (!currentUser.isCanImportInventory()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động nhập kho này.");
                    return;
                }
            } else if ("export-generator".equals(action)) {
                if (!currentUser.isCanExportInventory()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động xuất kho này.");
                    return;
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }

        try {
            Warehouse managedWarehouse = null;
            if (isManager) {
                managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            } else if (isStaff) {
                Integer whId = currentUser.getWarehouseId();
                if (whId != null) {
                    managedWarehouse = warehouseDAO.findById(whId);
                }
            }

            if (managedWarehouse == null) {
                response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=no_managed_warehouse");
                return;
            }

            if ("import-generator".equals(action)) {
                String importType = request.getParameter("importType");
                String supplierIdStr = request.getParameter("supplierId");
                Integer supplierId = (supplierIdStr == null || supplierIdStr.trim().isEmpty()) ? null
                        : Integer.parseInt(supplierIdStr.trim());
                String note = request.getParameter("note");
                note = (note == null) ? "" : note.trim();

                boolean success;
                if ("NEW_BATCH".equals(importType)) {
                    int generatorId = Integer.parseInt(request.getParameter("generatorId"));
                    int quantity = 1;
                    try {
                        String qtyStr = request.getParameter("quantity");
                        if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                            quantity = Integer.parseInt(qtyStr.trim());
                        }
                    } catch (NumberFormatException e) {}

                    if (quantity <= 0 || quantity > 1000) {
                        response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=invalid_quantity");
                        return;
                    }

                    if (note.isEmpty()) {
                        note = "Nhập bổ sung lô máy mới theo mẫu";
                    }

                    success = transactionDAO.importGeneratorBatch(generatorId, quantity, managedWarehouse.getWarehouseId(),
                            supplierId, currentUser.getUserId(), note);
                } else {
                    int barcodeId = Integer.parseInt(request.getParameter("barcodeId"));
                    if (note.isEmpty()) {
                        note = "Nhập máy phát điện trở lại kho";
                    }
                    model.GeneratorBarcode gb = null;
                    try {
                        gb = generatorDAO.findBarcodeById(barcodeId);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    success = transactionDAO.importGenerator(barcodeId, managedWarehouse.getWarehouseId(),
                            supplierId, currentUser.getUserId(), note);
                    if (success && gb != null) {
                        try {
                            rentalContractDAO.checkAndCompleteContractForReturnedBarcode(gb.getSerialNumber(), currentUser.getUserId());
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }

                if (success) {
                    try {
                        dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                        if (managedWarehouse.getManagerId() != null) {
                            model.Notification notif = new model.Notification();
                            notif.setUserId(managedWarehouse.getManagerId());
                            notif.setTitle("Nhập kho máy phát điện");
                            notif.setMessage("Giao dịch nhập kho máy phát điện tại kho " + managedWarehouse.getWarehouseName() + " đã thực hiện thành công.");
                            notif.setType("SYSTEM");
                            notif.setRead(false);
                            notificationDAO.insert(notif);
                        }
                        if (managedWarehouse.getWarehouseManagerId() != null) {
                            model.Notification notif = new model.Notification();
                            notif.setUserId(managedWarehouse.getWarehouseManagerId());
                            notif.setTitle("Nhập kho máy phát điện");
                            notif.setMessage("Giao dịch nhập kho máy phát điện tại kho " + managedWarehouse.getWarehouseName() + " đã thực hiện thành công.");
                            notif.setType("SYSTEM");
                            notif.setRead(false);
                            notificationDAO.insert(notif);
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?success=generator_import_success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=generator_import_failed");
                }
            } else if ("export-generator".equals(action)) {
                String exportStatus = request.getParameter("exportStatus");
                String note = request.getParameter("note");
                note = (note == null) ? "" : note.trim();

                if (!"EXPORTED".equals(exportStatus) && !isManager) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hình thức xuất kho này.");
                    return;
                }

                boolean success = false;
                if ("TRANSFERRED".equals(exportStatus)) {
                    int generatorId = Integer.parseInt(request.getParameter("generatorId"));
                    int quantity = Integer.parseInt(request.getParameter("quantity"));
                    int toWarehouseId = Integer.parseInt(request.getParameter("toWarehouseId"));

                    if (quantity <= 0) {
                        response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=invalid_quantity");
                        return;
                    }

                    // Get available barcodes for this model
                    List<model.GeneratorBarcode> barcodes = generatorDAO.findBarcodes(managedWarehouse.getWarehouseId(), "IN_STOCK");
                    List<model.GeneratorBarcode> availableBarcodes = new java.util.ArrayList<>();
                    for (model.GeneratorBarcode gb : barcodes) {
                        if (gb.getGeneratorId() == generatorId) {
                            availableBarcodes.add(gb);
                        }
                    }

                    if (availableBarcodes.size() < quantity) {
                        response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=insufficient_stock");
                        return;
                    }

                    if (note.isEmpty()) {
                        note = "Điều chuyển máy phát điện sang kho khác";
                    }

                    // Create stock transfer request within transaction
                    java.sql.Connection conn = null;
                    try {
                        conn = util.DBUtil.getConnection();
                        conn.setAutoCommit(false);

                        model.StockTransfer st = new model.StockTransfer();
                        st.setFromWarehouseId(managedWarehouse.getWarehouseId());
                        st.setToWarehouseId(toWarehouseId);
                        st.setCreatedBy(currentUser.getUserId());
                        st.setStatus("PENDING");

                        dao.StockTransferDAO stDAO = new dao.StockTransferDAO();
                        int transferId = stDAO.insert(conn, st);

                        if (transferId > 0) {
                            model.StockTransferDetail std = new model.StockTransferDetail();
                            std.setTransferId(transferId);
                            std.setItemType("GENERATOR");
                            std.setGeneratorId(generatorId);
                            std.setQuantity(quantity);

                            dao.StockTransferDetailDAO stdDAO = new dao.StockTransferDetailDAO();
                            stdDAO.insert(conn, std);

                            // Lock barcodes
                            generatorDAO.lockBarcodesForTransfer(conn, generatorId, quantity, transferId);

                            // Create pending EXPORT transaction in inventory_transactions
                            List<model.StockTransferDetail> detailsList = new java.util.ArrayList<>();
                            detailsList.add(std);
                            transactionDAO.createPendingTransactionsForTransfer(conn, transferId, managedWarehouse.getWarehouseId(), currentUser.getUserId(), detailsList);

                             conn.commit();
                             success = true;

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
                        } else {
                            conn.rollback();
                        }
                    } catch (Exception e) {
                        if (conn != null) {
                            try { conn.rollback(); } catch (Exception ignored) {}
                        }
                        throw e;
                    } finally {
                        if (conn != null) {
                            try { conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
                        }
                    }

                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/inventory-transactions?success=generator_transfer_created");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=generator_transfer_failed");
                    }
                    return;
                } else {
                    String[] barcodeIdStrs = request.getParameterValues("barcodeId");
                    if (barcodeIdStrs == null || barcodeIdStrs.length == 0) {
                        response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=invalid_barcode");
                        return;
                    }

                    boolean allSuccess = true;
                    for (String bIdStr : barcodeIdStrs) {
                        if (bIdStr == null || bIdStr.trim().isEmpty()) continue;
                        int barcodeId = Integer.parseInt(bIdStr.trim());

                        if (isStaff) {
                            model.GeneratorBarcode gb = generatorDAO.findBarcodeById(barcodeId);
                            if (gb != null) {
                                List<Integer> assignedGenIds = rentalContractDAO.findAssignedGeneratorIds(currentUser.getUserId());
                                if (assignedGenIds == null || !assignedGenIds.contains(gb.getGeneratorId())) {
                                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không được phân công xuất máy phát điện này.");
                                    return;
                                }
                            }
                        }

                        model.GeneratorBarcode gb = generatorDAO.findBarcodeById(barcodeId);
                        if (gb != null) {
                            List<model.GeneratorBarcode> allModelBarcodes = generatorDAO.findBarcodesByGeneratorId(gb.getGeneratorId());
                            boolean hasRemainingInStock = false;
                            for (model.GeneratorBarcode r : allModelBarcodes) {
                                if ("IN_STOCK".equals(r.getStatus()) && r.getBarcodeId() != barcodeId) {
                                    hasRemainingInStock = true;
                                    break;
                                }
                            }
                            if (!hasRemainingInStock) {
                                model.Generator gen = generatorDAO.findById(gb.getGeneratorId());
                                if (gen != null) {
                                    gen.setStatus("EXPORTED");
                                    generatorDAO.update(gen);
                                }
                            }
                        }

                        String exportNote = note;
                        if (exportNote.isEmpty()) {
                            exportNote = "Xuất kho máy phát điện";
                        }
                        boolean s = transactionDAO.exportGenerator(barcodeId, managedWarehouse.getWarehouseId(),
                                exportStatus, currentUser.getUserId(), exportNote);
                        if (!s) {
                            allSuccess = false;
                        }
                    }
                    
                    if (allSuccess) {
                        String contractIdStr = request.getParameter("contractId");
                        if (contractIdStr != null && !contractIdStr.trim().isEmpty()) {
                            int contractId = Integer.parseInt(contractIdStr.trim());
                            rentalContractDAO.updateContractStatus(contractId, "DELIVERED", currentUser.getUserId());
                        }
                    }
                    success = allSuccess;
                    
                    String redirectUrl = request.getParameter("redirect");
                    if (success) {
                        try {
                            dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                            if (managedWarehouse.getManagerId() != null) {
                                model.Notification notif = new model.Notification();
                                notif.setUserId(managedWarehouse.getManagerId());
                                notif.setTitle("Xuất kho máy phát điện");
                                notif.setMessage("Giao dịch xuất kho máy phát điện tại kho " + managedWarehouse.getWarehouseName() + " đã thực hiện thành công.");
                                notif.setType("SYSTEM");
                                notif.setRead(false);
                                notificationDAO.insert(notif);
                            }
                            if (managedWarehouse.getWarehouseManagerId() != null) {
                                model.Notification notif = new model.Notification();
                                notif.setUserId(managedWarehouse.getWarehouseManagerId());
                                notif.setTitle("Xuất kho máy phát điện");
                                notif.setMessage("Giao dịch xuất kho máy phát điện tại kho " + managedWarehouse.getWarehouseName() + " đã thực hiện thành công.");
                                notif.setType("SYSTEM");
                                notif.setRead(false);
                                notificationDAO.insert(notif);
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                        if ("home".equals(redirectUrl)) {
                            response.sendRedirect(request.getContextPath() + "/staff/home?success=generator_export_success");
                        } else if ("rented-generators".equals(redirectUrl)) {
                            response.sendRedirect(request.getContextPath() + "/staff/rented-generators?success=generator_export_success");
                        } else {
                            response.sendRedirect(request.getContextPath() + "/inventory-transactions?success=generator_export_success");
                        }
                    } else {
                        if ("home".equals(redirectUrl)) {
                            response.sendRedirect(request.getContextPath() + "/staff/home?error=generator_export_failed");
                        } else if ("rented-generators".equals(redirectUrl)) {
                            response.sendRedirect(request.getContextPath() + "/staff/rented-generators?error=generator_export_failed");
                        } else {
                            response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=generator_export_failed");
                        }
                    }
                    return;
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=system_error");
        }
    }
}
