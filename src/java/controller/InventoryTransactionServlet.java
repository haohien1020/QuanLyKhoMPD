package controller;

import dao.InventoryTransactionDAO;
import dao.PartDAO;
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
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import model.InventoryTransaction;
import model.Part;
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
    private final PartDAO partDAO = new PartDAO();
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

        if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();

        try {
            Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (managedWarehouse == null) {
                request.setAttribute("error", "Tài khoản của bạn chưa được chỉ định quản lý bất kỳ kho hàng nào.");
                request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
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
                List<Part> parts = partDAO.findParts("", managedWarehouse.getWarehouseId(), "ACTIVE");
                List<Supplier> suppliers = supplierDAO.findAll();

                // Get summary of rental contracts to help users find relevant rental actions
                List<CustomerRentalContract> pendingRentals = rentalContractDAO
                        .findContractsByWarehouse(managedWarehouse.getWarehouseId());

                request.setAttribute("parts", parts);
                request.setAttribute("suppliers", suppliers);
                request.setAttribute("pendingRentals", pendingRentals);

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

        if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        try {
            Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (managedWarehouse == null) {
                response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=no_managed_warehouse");
                return;
            }

            if ("import-part".equals(action)) {
                int partId = Integer.parseInt(request.getParameter("partId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String supplierIdStr = request.getParameter("supplierId");
                Integer supplierId = (supplierIdStr == null || supplierIdStr.trim().isEmpty()) ? null
                        : Integer.parseInt(supplierIdStr.trim());
                String note = request.getParameter("note");
                note = (note == null) ? "" : note.trim();

                if (quantity <= 0) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=invalid_quantity");
                    return;
                }

                // Append general note for tracking
                if (note.isEmpty()) {
                    note = "Nhập bổ sung số lượng phụ tùng mua mới";
                }

                boolean success = transactionDAO.importPart(partId, quantity, managedWarehouse.getWarehouseId(),
                        supplierId, currentUser.getUserId(), note);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?success=import_success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=import_failed");
                }
            } else if ("export-part".equals(action)) {
                int partId = Integer.parseInt(request.getParameter("partId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String note = request.getParameter("note");
                note = (note == null) ? "" : note.trim();

                if (quantity <= 0) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=invalid_quantity");
                    return;
                }

                if (note.isEmpty()) {
                    note = "Xuất cấp phát linh kiện phụ tùng cho kỹ thuật viên sửa chữa";
                }

                boolean success = transactionDAO.exportPart(partId, quantity, managedWarehouse.getWarehouseId(),
                        currentUser.getUserId(), note);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?success=export_success");
                } else {
                    response.sendRedirect(
                            request.getContextPath() + "/inventory-transactions?error=insufficient_stock");
                }
            } else if ("import-generator".equals(action)) {
                String generatorName = request.getParameter("generatorName");
                String serialNumber = request.getParameter("serialNumber");
                String brand = request.getParameter("brand");
                String powerValue = request.getParameter("powerValue");
                String fuelType = request.getParameter("fuelType");
                
                String supplierIdStr = request.getParameter("supplierId");
                Integer supplierId = (supplierIdStr == null || supplierIdStr.trim().isEmpty()) ? null
                        : Integer.parseInt(supplierIdStr.trim());
                
                String purchasePriceStr = request.getParameter("purchasePrice");
                BigDecimal purchasePrice = (purchasePriceStr == null || purchasePriceStr.trim().isEmpty()) ? null
                        : new BigDecimal(purchasePriceStr.trim());
                
                String rentalPriceStr = request.getParameter("rentalPrice");
                BigDecimal rentalPrice = (rentalPriceStr == null || rentalPriceStr.trim().isEmpty()) ? null
                        : new BigDecimal(rentalPriceStr.trim());
                        
                String location = request.getParameter("location");
                String note = request.getParameter("note");
                String barcode = request.getParameter("barcode");
                
                String importDateStr = request.getParameter("importDate");
                Timestamp importDate = null;
                if (importDateStr != null && !importDateStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    Date parsed = sdf.parse(importDateStr.trim());
                    importDate = new Timestamp(parsed.getTime());
                } else {
                    importDate = new Timestamp(System.currentTimeMillis());
                }

                generatorName = (generatorName == null) ? "" : generatorName.trim();
                serialNumber = (serialNumber == null) ? "" : serialNumber.trim();
                brand = (brand == null) ? "" : brand.trim();
                powerValue = (powerValue == null) ? "" : powerValue.trim();
                fuelType = (fuelType == null) ? "" : fuelType.trim();
                location = (location == null) ? "" : location.trim();
                note = (note == null) ? "" : note.trim();
                barcode = (barcode == null) ? "" : barcode.trim();

                if (generatorName.isEmpty() || serialNumber.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=missing_required");
                    return;
                }

                if (generatorDAO.isSerialNumberUsed(serialNumber, 0)) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=serial_exists");
                    return;
                }

                Generator g = new Generator();
                g.setWarehouseId(managedWarehouse.getWarehouseId());
                g.setSupplierId(supplierId);
                g.setGeneratorName(generatorName);
                g.setSerialNumber(serialNumber);
                g.setBrand(brand);
                g.setPowerValue(powerValue);
                g.setFuelType(fuelType);
                g.setOriginType("SUPPLIER");
                g.setImportDate(importDate);
                g.setPurchasePrice(purchasePrice);
                g.setRentalPrice(rentalPrice != null ? rentalPrice : BigDecimal.ZERO);
                g.setLocation(location);
                g.setStatus("IN_STOCK");
                g.setNote(note);
                if (barcode.isEmpty()) {
                    barcode = util.BarcodeGenerator.generateCode39(serialNumber);
                }
                g.setBarcode(barcode);

                int id = generatorDAO.insertImportToStock(g, currentUser.getUserId());
                if (id > 0) {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?success=generator_import_success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/inventory-transactions?error=generator_import_failed");
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
