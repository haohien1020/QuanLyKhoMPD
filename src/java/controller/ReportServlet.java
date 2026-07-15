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
            List<Warehouse> supervisedWarehouses = warehouseDAO.findBySupervisingManager(currentUser.getUserId(), "");
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
                genStatusSql = "SELECT status, COUNT(*) AS count FROM generators WHERE warehouse_id = ? AND is_deleted = 0 GROUP BY status";
            } else {
                genStatusSql = "SELECT status, COUNT(*) AS count FROM generators WHERE warehouse_id IN (SELECT warehouse_id FROM warehouses WHERE manager_id = ? AND is_deleted = 0) AND is_deleted = 0 GROUP BY status";
            }
            
            try (Connection conn = util.DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(genStatusSql)) {
                if (selectedWarehouseId != null) {
                    ps.setInt(1, selectedWarehouseId);
                } else {
                    ps.setInt(1, currentUser.getUserId());
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
                genSpecsSql = "SELECT generator_name, brand, power_value, rental_price, MAX(min_stock) AS min_stock, "
                        + "SUM(CASE WHEN status = 'IN_STOCK' THEN 1 ELSE 0 END) AS avail_qty, "
                        + "COUNT(*) AS total_qty "
                        + "FROM generators "
                        + "WHERE warehouse_id = ? AND is_deleted = 0 "
                        + "GROUP BY generator_name, brand, power_value, rental_price";
            } else {
                genSpecsSql = "SELECT generator_name, brand, power_value, rental_price, MAX(min_stock) AS min_stock, "
                        + "SUM(CASE WHEN status = 'IN_STOCK' THEN 1 ELSE 0 END) AS avail_qty, "
                        + "COUNT(*) AS total_qty "
                        + "FROM generators "
                        + "WHERE warehouse_id IN (SELECT warehouse_id FROM warehouses WHERE manager_id = ? AND is_deleted = 0) AND is_deleted = 0 "
                        + "GROUP BY generator_name, brand, power_value, rental_price";
            }
            
            try (Connection conn = util.DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(genSpecsSql)) {
                if (selectedWarehouseId != null) {
                    ps.setInt(1, selectedWarehouseId);
                } else {
                    ps.setInt(1, currentUser.getUserId());
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> map = new HashMap<>();
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

            // 3. Fetch Parts Summary
            List<Map<String, Object>> partsData = new ArrayList<>();
            
            String partsSql;
            if (selectedWarehouseId != null) {
                partsSql = "SELECT part_name, part_code, quantity, min_quantity, unit, status FROM parts WHERE warehouse_id = ? AND is_deleted = 0";
            } else {
                partsSql = "SELECT part_name, part_code, quantity, min_quantity, unit, status FROM parts WHERE warehouse_id IN (SELECT warehouse_id FROM warehouses WHERE manager_id = ? AND is_deleted = 0) AND is_deleted = 0";
            }
            
            int totalPartsQty = 0;
            int lowStockPartsCount = 0;
            try (Connection conn = util.DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(partsSql)) {
                if (selectedWarehouseId != null) {
                    ps.setInt(1, selectedWarehouseId);
                } else {
                    ps.setInt(1, currentUser.getUserId());
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> map = new HashMap<>();
                        String name = rs.getString("part_name");
                        String code = rs.getString("part_code");
                        int qty = rs.getInt("quantity");
                        int minQty = rs.getInt("min_quantity");
                        String unit = rs.getString("unit");
                        String status = rs.getString("status");
                        
                        map.put("partName", name);
                        map.put("partCode", code);
                        map.put("quantity", qty);
                        map.put("minQuantity", minQty);
                        map.put("unit", unit);
                        map.put("status", status);
                        
                        partsData.add(map);
                        totalPartsQty += qty;
                        if (qty < minQty) {
                            lowStockPartsCount++;
                        }
                    }
                }
            }

            request.setAttribute("genStatusData", genStatusData);
            request.setAttribute("genSpecsData", genSpecsData);
            request.setAttribute("partsData", partsData);
            request.setAttribute("totalGenerators", totalGenerators);
            request.setAttribute("totalPartsQty", totalPartsQty);
            request.setAttribute("lowStockPartsCount", lowStockPartsCount);

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
        if (currentUser == null || !currentUser.hasRole("MANAGER")) {
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

                // Update min_stock for all generators matching these specifications
                String updateSql = "UPDATE generators SET min_stock = ? WHERE generator_name = ? AND brand = ? AND power_value = ? AND is_deleted = 0";
                try (Connection conn = util.DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, minStock);
                    ps.setString(2, generatorName);
                    ps.setString(3, brand);
                    ps.setString(4, powerValue);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getContextPath() + "/reports?type=inventory&success=min_stock_updated");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/reports?type=inventory&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }
}
