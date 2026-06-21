package controller;

import dao.GeneratorDAO;
import dao.WarehouseDAO;
import dao.SupplierDAO;
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
import model.Generator;
import model.User;
import model.Warehouse;
import model.Supplier;

@WebServlet(name = "GeneratorServlet", urlPatterns = {
    "/generators",
    "/generators/create",
    "/generators/update",
    "/generators/delete"
})
public class GeneratorServlet extends HttpServlet {

    private final GeneratorDAO generatorDAO = new GeneratorDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireLogin(request, response);
        if (currentUser == null) {
            return;
        }

        try {
            String q = trim(request.getParameter("q"));
            String status = trim(request.getParameter("status"));
            Integer warehouseId;
            boolean isSellerRestricted = false;
            boolean isWarehouseRestricted = false;
            Integer restrictedWarehouseId = null;

            if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse != null) {
                    restrictedWarehouseId = managedWarehouse.getWarehouseId();
                    isWarehouseRestricted = true;
                }
            } else if (currentUser.hasRole("STAFF")) {
                restrictedWarehouseId = currentUser.getWarehouseId();
                isWarehouseRestricted = true;
            } else if (currentUser.hasRole("SELLER")) {
                restrictedWarehouseId = currentUser.getWarehouseId();
                isSellerRestricted = true;
                isWarehouseRestricted = true;
            }

            if (isWarehouseRestricted) {
                warehouseId = restrictedWarehouseId;
            } else {
                warehouseId = parseInt(request.getParameter("warehouseId"));
            }

            List<Generator> generators = generatorDAO.findGenerators(q, warehouseId, status);
            List<Warehouse> warehouses;
            if (isWarehouseRestricted) {
                warehouses = new java.util.ArrayList<>();
                if (warehouseId != null) {
                    Warehouse wh = warehouseDAO.findById(warehouseId);
                    if (wh != null) warehouses.add(wh);
                }
            } else {
                warehouses = warehouseDAO.findAll();
            }
            List<Supplier> suppliers = supplierDAO.findAll();

            request.setAttribute("generators", generators);
            request.setAttribute("warehouses", warehouses);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("q", q);
            request.setAttribute("warehouseIdFilter", warehouseId);
            request.setAttribute("statusFilter", status);
            request.setAttribute("isSellerRestricted", isSellerRestricted);
            request.setAttribute("sellerWarehouseId", warehouseId);
            request.setAttribute("isWarehouseRestricted", isWarehouseRestricted);
            request.setAttribute("restrictedWarehouseId", restrictedWarehouseId);

            request.getRequestDispatcher("/views/generator/generator-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("/views/generator/generator-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireLogin(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/generators/create".equals(path)) {
                if (!currentUser.hasRole("WAREHOUSE_MANAGER") && !(currentUser.hasRole("STAFF") && currentUser.isCanImportGenerator())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                createGenerator(request, response, currentUser);
            } else {
                if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                if ("/generators/update".equals(path)) {
                    updateGenerator(request, response);
                } else if ("/generators/delete".equals(path)) {
                    deleteGenerator(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/generators");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/generators?error=system_error");
        }
    }

    private void createGenerator(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws Exception {
        Integer warehouseId = parseInt(request.getParameter("warehouseId"));
        Integer supplierId = parseInt(request.getParameter("supplierId"));
        String generatorName = trim(request.getParameter("generatorName"));
        String serialNumber = trim(request.getParameter("serialNumber"));
        String brand = trim(request.getParameter("brand"));
        String powerValue = trim(request.getParameter("powerValue"));
        String fuelType = trim(request.getParameter("fuelType"));
        String originType = trim(request.getParameter("originType"));
        String location = trim(request.getParameter("location"));
        String note = trim(request.getParameter("note"));
        String barcode = trim(request.getParameter("barcode"));

        Timestamp importDate = parseTimestamp(request.getParameter("importDate"));
        BigDecimal purchasePrice = parseBigDecimal(request.getParameter("purchasePrice"));
        BigDecimal rentalPrice = parseBigDecimal(request.getParameter("rentalPrice"));

        // Security check for warehouse restriction
        Integer restrictedWarehouseId = null;
        boolean isWarehouseRestricted = false;
        if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
            Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (managedWarehouse != null) {
                restrictedWarehouseId = managedWarehouse.getWarehouseId();
                isWarehouseRestricted = true;
            }
        } else if (currentUser.hasRole("STAFF")) {
            restrictedWarehouseId = currentUser.getWarehouseId();
            isWarehouseRestricted = true;
        }

        if (isWarehouseRestricted) {
            if (warehouseId == null || !warehouseId.equals(restrictedWarehouseId)) {
                response.sendRedirect(request.getContextPath() + "/generators?error=invalid_warehouse");
                return;
            }
        }

        if (warehouseId == null || generatorName == null || generatorName.isEmpty() || serialNumber == null || serialNumber.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/generators?error=missing_required");
            return;
        }

        if (generatorDAO.isSerialNumberUsed(serialNumber, 0)) {
            response.sendRedirect(request.getContextPath() + "/generators?error=serial_exists");
            return;
        }

        Generator g = new Generator();
        g.setWarehouseId(warehouseId);
        g.setSupplierId(supplierId);
        g.setGeneratorName(generatorName);
        g.setSerialNumber(serialNumber);
        g.setBrand(brand);
        g.setPowerValue(powerValue);
        g.setFuelType(fuelType);
        g.setOriginType(originType == null ? "SUPPLIER" : originType);
        g.setImportDate(importDate != null ? importDate : new Timestamp(System.currentTimeMillis()));
        g.setPurchasePrice(purchasePrice);
        g.setRentalPrice(rentalPrice != null ? rentalPrice : BigDecimal.ZERO);
        g.setLocation(location);
        g.setStatus("IN_STOCK");
        g.setNote(note);
        if (barcode == null || barcode.trim().isEmpty()) {
            barcode = util.BarcodeGenerator.generateCode39(serialNumber);
        }
        g.setBarcode(barcode);

        int id = generatorDAO.insertImportToStock(g, currentUser.getUserId());
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/generators?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/generators?error=create_failed");
        }
    }

    private void updateGenerator(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer generatorId = parseInt(request.getParameter("generatorId"));
        Integer warehouseId = parseInt(request.getParameter("warehouseId"));
        Integer supplierId = parseInt(request.getParameter("supplierId"));
        String generatorName = trim(request.getParameter("generatorName"));
        String serialNumber = trim(request.getParameter("serialNumber"));
        String brand = trim(request.getParameter("brand"));
        String powerValue = trim(request.getParameter("powerValue"));
        String fuelType = trim(request.getParameter("fuelType"));
        String originType = trim(request.getParameter("originType"));
        String location = trim(request.getParameter("location"));
        String status = trim(request.getParameter("status"));
        String note = trim(request.getParameter("note"));
        String barcode = trim(request.getParameter("barcode"));

        Timestamp importDate = parseTimestamp(request.getParameter("importDate"));
        BigDecimal purchasePrice = parseBigDecimal(request.getParameter("purchasePrice"));
        BigDecimal rentalPrice = parseBigDecimal(request.getParameter("rentalPrice"));

        if (generatorId == null || warehouseId == null || generatorName == null || generatorName.isEmpty() || serialNumber == null || serialNumber.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/generators?error=missing_required");
            return;
        }

        Generator existing = generatorDAO.findById(generatorId);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/generators?error=not_found");
            return;
        }

        // Security check for warehouse restriction
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser != null) {
            Integer restrictedWarehouseId = null;
            boolean isWarehouseRestricted = false;
            if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse != null) {
                    restrictedWarehouseId = managedWarehouse.getWarehouseId();
                    isWarehouseRestricted = true;
                }
            } else if (currentUser.hasRole("STAFF")) {
                restrictedWarehouseId = currentUser.getWarehouseId();
                isWarehouseRestricted = true;
            }

            if (isWarehouseRestricted) {
                if (existing.getWarehouseId() != restrictedWarehouseId || warehouseId == null || !warehouseId.equals(restrictedWarehouseId)) {
                    response.sendRedirect(request.getContextPath() + "/generators?error=invalid_warehouse");
                    return;
                }
            }
        }

        if (generatorDAO.isSerialNumberUsed(serialNumber, generatorId)) {
            response.sendRedirect(request.getContextPath() + "/generators?error=serial_exists");
            return;
        }

        existing.setWarehouseId(warehouseId);
        existing.setSupplierId(supplierId);
        existing.setGeneratorName(generatorName);
        existing.setSerialNumber(serialNumber);
        existing.setBrand(brand);
        existing.setPowerValue(powerValue);
        existing.setFuelType(fuelType);
        existing.setOriginType(originType);
        existing.setImportDate(importDate);
        existing.setPurchasePrice(purchasePrice);
        existing.setRentalPrice(rentalPrice != null ? rentalPrice : BigDecimal.ZERO);
        existing.setLocation(location);
        existing.setStatus(status);
        existing.setNote(note);
        if (barcode == null || barcode.trim().isEmpty() || !existing.getSerialNumber().equals(serialNumber)) {
            barcode = util.BarcodeGenerator.generateCode39(serialNumber);
        }
        existing.setBarcode(barcode);

        boolean success = generatorDAO.update(existing);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/generators?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/generators?error=update_failed");
        }
    }

    private void deleteGenerator(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer generatorId = parseInt(request.getParameter("generatorId"));
        if (generatorId == null) {
            response.sendRedirect(request.getContextPath() + "/generators?error=invalid_id");
            return;
        }

        Generator existing = generatorDAO.findById(generatorId);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/generators?error=not_found");
            return;
        }

        // Security check for warehouse restriction
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser != null) {
            Integer restrictedWarehouseId = null;
            boolean isWarehouseRestricted = false;
            if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse != null) {
                    restrictedWarehouseId = managedWarehouse.getWarehouseId();
                    isWarehouseRestricted = true;
                }
            }

            if (isWarehouseRestricted) {
                if (existing.getWarehouseId() != restrictedWarehouseId) {
                    response.sendRedirect(request.getContextPath() + "/generators?error=invalid_warehouse");
                    return;
                }
            }
        }

        boolean success = generatorDAO.delete(generatorId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/generators?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/generators?error=delete_failed");
        }
    }

    private User requireLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        return currentUser;
    }

    private User requireRole(HttpServletRequest request, HttpServletResponse response, String role)
            throws IOException {
        User currentUser = requireLogin(request, response);
        if (currentUser == null) {
            return null;
        }

        if (!currentUser.hasRole(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        return currentUser;
    }

    private Integer parseInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : new BigDecimal(value.trim());
        } catch (Exception ex) {
            return null;
        }
    }

    private Timestamp parseTimestamp(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date date = sdf.parse(value.trim());
            return new Timestamp(date.getTime());
        } catch (Exception ex) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
