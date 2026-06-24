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
    "/generators/delete",
    "/generators/barcodes"
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
            // ===== /generators/barcodes =====
            String path = request.getServletPath();
            if ("/generators/barcodes".equals(path)) {
                Integer filterGeneratorId = parseInt(request.getParameter("generatorId"));
                String filterStatus = trim(request.getParameter("status"));
                String filterKeyword = trim(request.getParameter("q"));

                List<model.GeneratorBarcode> barcodes = generatorDAO.findBarcodesWithFilter(filterGeneratorId, filterStatus, filterKeyword);
                List<Generator> generators = generatorDAO.findAll();

                request.setAttribute("barcodes", barcodes);
                request.setAttribute("generators", generators);
                request.setAttribute("filterGeneratorId", filterGeneratorId);
                request.setAttribute("filterStatus", filterStatus);
                request.setAttribute("filterKeyword", filterKeyword);
                request.getRequestDispatcher("/views/generator/generator-barcodes.jsp").forward(request, response);
                return;
            }

            String action = trim(request.getParameter("action"));
            if ("next-serial".equals(action)) {
                String name = trim(request.getParameter("name"));
                Integer supplierId = parseInt(request.getParameter("supplierId"));
                String nextSerial = generatorDAO.generateNextSerialNumber(name, supplierId);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":true,\"serialNumber\":\"" + nextSerial + "\"}");
                return;
            }

            if ("check-name".equals(action)) {
                String name = trim(request.getParameter("name"));
                Integer generatorId = parseInt(request.getParameter("generatorId"));
                if (generatorId == null) {
                    generatorId = 0;
                }
                boolean used = generatorDAO.isNameUsed(name, generatorId);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":true,\"used\":" + used + "}");
                return;
            }

            if ("get-barcodes".equals(action)) {
                Integer generatorId = parseInt(request.getParameter("generatorId"));
                if (generatorId != null) {
                    List<model.GeneratorBarcode> barcodes = generatorDAO.findBarcodesByGeneratorId(generatorId);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    StringBuilder sb = new StringBuilder("[");
                    for (int i = 0; i < barcodes.size(); i++) {
                        model.GeneratorBarcode gb = barcodes.get(i);
                        sb.append("{");
                        sb.append("\"barcodeId\":").append(gb.getBarcodeId()).append(",");
                        sb.append("\"generatorId\":").append(gb.getGeneratorId()).append(",");
                        sb.append("\"serialNumber\":\"").append(gb.getSerialNumber()).append("\",");
                        sb.append("\"barcode\":\"").append(gb.getBarcode()).append("\",");
                        sb.append("\"status\":\"").append(gb.getStatus() == null ? "" : gb.getStatus()).append("\"");
                        sb.append("}");
                        if (i < barcodes.size() - 1) {
                            sb.append(",");
                        }
                    }
                    sb.append("]");
                    response.getWriter().write(sb.toString());
                    return;
                }
            }

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

        if (warehouseId == null || generatorName == null || generatorName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/generators?error=missing_required");
            return;
        }

        if (generatorDAO.isNameUsed(generatorName, 0)) {
            response.sendRedirect(request.getContextPath() + "/generators?error=name_exists");
            return;
        }

        if (serialNumber != null && !serialNumber.isEmpty()) {
            if (generatorDAO.isSerialNumberUsed(serialNumber, 0)) {
                response.sendRedirect(request.getContextPath() + "/generators?error=serial_exists");
                return;
            }
        } else {
            serialNumber = null;
            barcode = null;
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
        
        if (serialNumber != null && !serialNumber.isEmpty()) {
            if (barcode == null || barcode.trim().isEmpty()) {
                barcode = util.BarcodeGenerator.generateCode39(serialNumber);
            }
        } else {
            barcode = null;
        }
        g.setBarcode(barcode);

        int id = generatorDAO.insert(g);
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

        if (generatorId == null || warehouseId == null || generatorName == null || generatorName.isEmpty()) {
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

        if (generatorDAO.isNameUsed(generatorName, generatorId)) {
            response.sendRedirect(request.getContextPath() + "/generators?error=name_exists");
            return;
        }

        if (serialNumber != null && !serialNumber.isEmpty()) {
            if (generatorDAO.isSerialNumberUsed(serialNumber, generatorId)) {
                response.sendRedirect(request.getContextPath() + "/generators?error=serial_exists");
                return;
            }
        } else {
            serialNumber = null;
            barcode = null;
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

        if (serialNumber != null && !serialNumber.isEmpty()) {
            if (barcode == null || barcode.trim().isEmpty() || existing.getSerialNumber() == null || !existing.getSerialNumber().equals(serialNumber)) {
                barcode = util.BarcodeGenerator.generateCode39(serialNumber);
            }
        } else {
            barcode = null;
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
