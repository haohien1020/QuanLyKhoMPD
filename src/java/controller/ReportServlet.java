package controller;

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
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.User;
import model.Warehouse;

@WebServlet(name = "ReportServlet", urlPatterns = {
    "/reports",
    "/asset-report",
    "/purchase-orders"
})
public class ReportServlet extends HttpServlet {

    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();
        if ("/purchase-orders".equals(path)) {
            response.sendRedirect(request.getContextPath() + "/manager/home?error=permission_denied");
            return;
        }

        String type = request.getParameter("type");
        if (type == null) {
            type = "inventory";
        }

        if ("purchase".equalsIgnoreCase(type)) {
            if (currentUser.hasRole("MANAGER")) {
                response.sendRedirect(request.getContextPath() + "/manager/home?error=permission_denied");
                return;
            }
            request.setAttribute("error", "Báo cáo mua sắm hiện đang được bảo trì hoặc nâng cấp hệ thống.");
            request.getRequestDispatcher("/views/report/asset-inventory.jsp").forward(request, response);
            return;
        }

        // Fetch Inventory report statistics
        try {
            // Get supervised warehouses for filter dropdown
            List<Warehouse> supervisedWarehouses;
            if (currentUser.hasRole("ADMIN")) {
                supervisedWarehouses = warehouseDAO.findAll();
            } else {
                supervisedWarehouses = warehouseDAO.findBySupervisingManager(currentUser.getUserId(), "");
            }
            request.setAttribute("supervisedWarehouses", supervisedWarehouses);

            // Read selected warehouse filter
            String warehouseIdStr = request.getParameter("warehouseId");
            Integer selectedWarehouseId = null;
            if (warehouseIdStr != null && !warehouseIdStr.trim().isEmpty() && !"ALL".equalsIgnoreCase(warehouseIdStr)) {
                selectedWarehouseId = Integer.parseInt(warehouseIdStr.trim());
            }
            request.setAttribute("selectedWarehouseId", selectedWarehouseId);

            // 1. Fetch Generator Status Breakdown
            List<Map<String, Object>> genStatusData = new ArrayList<>();
            int totalGenerators = 0;
            
            String genStatusSql;
            if (selectedWarehouseId != null) {
                genStatusSql = "SELECT gb.status, COUNT(*) AS count "
                        + "FROM generator_barcodes gb "
                        + "JOIN generators g ON gb.generator_id = g.generator_id "
                        + "WHERE g.warehouse_id = ? AND g.is_deleted = 0 "
                        + "GROUP BY gb.status";
            } else {
                if (currentUser.hasRole("ADMIN")) {
                    genStatusSql = "SELECT gb.status, COUNT(*) AS count "
                            + "FROM generator_barcodes gb "
                            + "JOIN generators g ON gb.generator_id = g.generator_id "
                            + "WHERE g.is_deleted = 0 "
                            + "GROUP BY gb.status";
                } else {
                    genStatusSql = "SELECT gb.status, COUNT(*) AS count "
                            + "FROM generator_barcodes gb "
                            + "JOIN generators g ON gb.generator_id = g.generator_id "
                            + "WHERE g.warehouse_id IN (SELECT warehouse_id FROM warehouses WHERE manager_id = ? AND is_deleted = 0) AND g.is_deleted = 0 "
                            + "GROUP BY gb.status";
                }
            }
            
            try (Connection conn = util.DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(genStatusSql)) {
                if (selectedWarehouseId != null) {
                    ps.setInt(1, selectedWarehouseId);
                } else {
                    if (!currentUser.hasRole("ADMIN")) {
                        ps.setInt(1, currentUser.getUserId());
                    }
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> map = new HashMap<>();
                        String status = rs.getString("status");
                        int count = rs.getInt("count");
                        map.put("status", status);
                        map.put("count", count);
                        genStatusData.add(map);
                        totalGenerators += count;
                    }
                }
            }

            // 2. Fetch Generator Specs Summary (including MAX(min_stock) AS min_stock)
            List<Map<String, Object>> genSpecsData = new ArrayList<>();
            
            String genSpecsSql;
            if (selectedWarehouseId != null) {
                genSpecsSql = "SELECT w.warehouse_name, g.warehouse_id, g.generator_name, g.brand, g.power_value, g.rental_price, MAX(g.min_stock) AS min_stock, "
                        + "SUM(CASE WHEN gb.status = 'IN_STOCK' THEN 1 ELSE 0 END) AS avail_qty, "
                        + "COUNT(gb.barcode_id) AS total_qty "
                        + "FROM generators g "
                        + "JOIN warehouses w ON g.warehouse_id = w.warehouse_id "
                        + "LEFT JOIN generator_barcodes gb ON g.generator_id = gb.generator_id "
                        + "WHERE g.warehouse_id = ? AND g.is_deleted = 0 AND w.is_deleted = 0 "
                        + "GROUP BY w.warehouse_name, g.warehouse_id, g.generator_name, g.brand, g.power_value, g.rental_price";
            } else {
                if (currentUser.hasRole("ADMIN")) {
                    genSpecsSql = "SELECT w.warehouse_name, g.warehouse_id, g.generator_name, g.brand, g.power_value, g.rental_price, MAX(g.min_stock) AS min_stock, "
                            + "SUM(CASE WHEN gb.status = 'IN_STOCK' THEN 1 ELSE 0 END) AS avail_qty, "
                            + "COUNT(gb.barcode_id) AS total_qty "
                            + "FROM generators g "
                            + "JOIN warehouses w ON g.warehouse_id = w.warehouse_id "
                            + "LEFT JOIN generator_barcodes gb ON g.generator_id = gb.generator_id "
                            + "WHERE g.is_deleted = 0 AND w.is_deleted = 0 "
                            + "GROUP BY w.warehouse_name, g.warehouse_id, g.generator_name, g.brand, g.power_value, g.rental_price";
                } else {
                    genSpecsSql = "SELECT w.warehouse_name, g.warehouse_id, g.generator_name, g.brand, g.power_value, g.rental_price, MAX(g.min_stock) AS min_stock, "
                            + "SUM(CASE WHEN gb.status = 'IN_STOCK' THEN 1 ELSE 0 END) AS avail_qty, "
                            + "COUNT(gb.barcode_id) AS total_qty "
                            + "FROM generators g "
                            + "JOIN warehouses w ON g.warehouse_id = w.warehouse_id "
                            + "LEFT JOIN generator_barcodes gb ON g.generator_id = gb.generator_id "
                            + "WHERE w.manager_id = ? AND g.is_deleted = 0 AND w.is_deleted = 0 "
                            + "GROUP BY w.warehouse_name, g.warehouse_id, g.generator_name, g.brand, g.power_value, g.rental_price";
                }
            }
            
            try (Connection conn = util.DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(genSpecsSql)) {
                if (selectedWarehouseId != null) {
                    ps.setInt(1, selectedWarehouseId);
                } else {
                    if (!currentUser.hasRole("ADMIN")) {
                        ps.setInt(1, currentUser.getUserId());
                    }
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("warehouseName", rs.getString("warehouse_name"));
                        map.put("warehouseId", rs.getInt("warehouse_id"));
                        map.put("generatorName", rs.getString("generator_name"));
                        map.put("brand", rs.getString("brand"));
                        map.put("powerValue", rs.getString("power_value"));
                        map.put("rentalPrice", rs.getBigDecimal("rental_price"));
                        map.put("minStock", rs.getInt("min_stock"));
                        map.put("availQty", rs.getInt("avail_qty"));
                        map.put("totalQty", rs.getInt("total_qty"));
                        genSpecsData.add(map);
                    }
                }
            }

            request.setAttribute("genStatusData", genStatusData);
            request.setAttribute("genSpecsData", genSpecsData);
            request.setAttribute("totalGenerators", totalGenerators);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi kết xuất dữ liệu tồn kho: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/report/asset-inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || (!currentUser.hasRole("MANAGER") && !currentUser.hasRole("ADMIN"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("update-min-stock".equals(action)) {
            try {
                String generatorName = request.getParameter("generatorName");
                String brand = request.getParameter("brand");
                String powerValue = request.getParameter("powerValue");
                int minStock = Integer.parseInt(request.getParameter("minStock"));
                String warehouseIdStr = request.getParameter("warehouseId");

                // Update min_stock for all generators matching these specifications (scoped to warehouse if specified)
                String updateSql;
                if (warehouseIdStr != null && !warehouseIdStr.trim().isEmpty()) {
                    updateSql = "UPDATE generators SET min_stock = ? WHERE generator_name = ? AND brand = ? AND power_value = ? AND warehouse_id = ? AND is_deleted = 0";
                } else {
                    updateSql = "UPDATE generators SET min_stock = ? WHERE generator_name = ? AND brand = ? AND power_value = ? AND is_deleted = 0";
                }
                try (Connection conn = util.DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, minStock);
                    ps.setString(2, generatorName);
                    ps.setString(3, brand);
                    ps.setString(4, powerValue);
                    if (warehouseIdStr != null && !warehouseIdStr.trim().isEmpty()) {
                        ps.setInt(5, Integer.parseInt(warehouseIdStr.trim()));
                    }
                    ps.executeUpdate();
                }
                
                String redirectUrl = request.getContextPath() + "/reports?type=inventory&success=min_stock_updated";
                if (warehouseIdStr != null && !warehouseIdStr.trim().isEmpty()) {
                    redirectUrl += "&warehouseId=" + warehouseIdStr.trim();
                }
                response.sendRedirect(redirectUrl);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/reports?type=inventory&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }
}
