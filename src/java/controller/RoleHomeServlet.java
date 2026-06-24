package controller;

import dao.DashboardDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "RoleHomeServlet", urlPatterns = {
    "/manager/home",
    "/warehouse/dashboard",
    "/staff/home",
    "/seller/home"
})
public class RoleHomeServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();

        try {
            if ("/manager/home".equals(path)) {
                requireRole(currentUser, response, "MANAGER");
                loadManagerData(request);
                request.getRequestDispatcher("/views/home/manager-home.jsp").forward(request, response);
            } else if ("/warehouse/dashboard".equals(path)) {
                requireRole(currentUser, response, "WAREHOUSE_MANAGER");
                loadWarehouseData(request, currentUser);
                request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
            } else if ("/staff/home".equals(path)) {
                requireRole(currentUser, response, "STAFF");
                loadStaffData(request, currentUser);
                request.getRequestDispatcher("/views/home/staff-home.jsp").forward(request, response);
            } else if ("/seller/home".equals(path)) {
                requireRole(currentUser, response, "SELLER");
                loadSellerData(request, currentUser);
                request.getRequestDispatcher("/views/home/seller-home.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        } catch (IllegalAccessException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("homeError", "Homepage data could not be loaded. Please check database connectivity.");
            forwardFallback(path, request, response);
        }
    }

    private void loadManagerData(HttpServletRequest request) throws Exception {
        request.setAttribute("pendingPartRequests", dashboardDAO.countWhere("part_requests", "status = 'PENDING'"));
        request.setAttribute("pendingPurchaseRequests", dashboardDAO.countWhere("purchase_requests", "status = 'PENDING'"));
        request.setAttribute("pendingTransfers", dashboardDAO.countWhere("stock_transfers", "status = 'PENDING'"));
        request.setAttribute("totalWarehouses", dashboardDAO.count("warehouses"));
        request.setAttribute("totalGenerators", dashboardDAO.count("generators"));
        request.setAttribute("lowStockParts", dashboardDAO.countWhere("parts", "quantity <= min_quantity"));
        request.setAttribute("pendingPurchaseOrders", dashboardDAO.countWhere("purchase_orders", "status = 'PENDING'"));
        request.setAttribute("unreadNotifications", dashboardDAO.countWhere("notifications", "is_read = 0"));
    }

    private void loadWarehouseData(HttpServletRequest request, User currentUser) throws Exception {
        dao.WarehouseDAO warehouseDAO = new dao.WarehouseDAO();
        model.Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
        request.setAttribute("managedWarehouse", managedWarehouse);

        request.setAttribute("totalWarehouses", dashboardDAO.count("warehouses"));
        request.setAttribute("totalGenerators", dashboardDAO.count("generators"));
        request.setAttribute("inStockGenerators", dashboardDAO.countWhere("generators", "status = 'IN_STOCK'"));
        request.setAttribute("totalParts", dashboardDAO.count("parts"));
        request.setAttribute("lowStockParts", dashboardDAO.countWhere("parts", "quantity <= min_quantity"));
        request.setAttribute("inventoryTransactions", dashboardDAO.count("inventory_transactions"));
        request.setAttribute("pendingTransfers", dashboardDAO.countWhere("stock_transfers", "status = 'PENDING'"));
        request.setAttribute("pendingPurchaseRequests", dashboardDAO.countWhere("purchase_requests", "status = 'PENDING'"));
        request.setAttribute("totalSuppliers", dashboardDAO.count("suppliers"));
    }

    private void loadStaffData(HttpServletRequest request, User currentUser) throws Exception {
        int userId = currentUser.getUserId();
        request.setAttribute("totalGenerators", dashboardDAO.count("generators"));
        request.setAttribute("totalParts", dashboardDAO.count("parts"));
        request.setAttribute("lowStockParts", dashboardDAO.countWhere("parts", "quantity <= min_quantity"));
        request.setAttribute("myPartRequests", dashboardDAO.countWhereInt("part_requests", "requested_by = ?", userId));
        request.setAttribute("myPendingPartRequests",
                dashboardDAO.countWhereInt("part_requests", "requested_by = ? AND status = 'PENDING'", userId));
        request.setAttribute("inventoryTransactions", dashboardDAO.count("inventory_transactions"));
        request.setAttribute("unreadNotifications",
                dashboardDAO.countWhereInt("notifications", "user_id = ? AND is_read = 0", userId));
    }

    private void loadSellerData(HttpServletRequest request, User currentUser) throws Exception {
        int userId = currentUser.getUserId();
        Integer warehouseId = currentUser.getWarehouseId();
        request.setAttribute("sellerWarehouseId", warehouseId);

        // Count contracts created by this seller
        request.setAttribute("myTotalContracts", dashboardDAO.countWhere("rental_contracts", "created_by = " + userId));
        request.setAttribute("myPendingContracts", dashboardDAO.countWhere("rental_contracts", "created_by = " + userId + " AND status = 'PENDING'"));
        request.setAttribute("myActiveContracts", dashboardDAO.countWhere("rental_contracts", "created_by = " + userId + " AND status = 'DELIVERED'"));

        // Only count generators in seller's own warehouse
        if (warehouseId != null) {
            request.setAttribute("availableGenerators", dashboardDAO.countWhere("generators",
                    "status = 'IN_STOCK' AND warehouse_id = " + warehouseId));
            // Also get warehouse name for display
            dao.WarehouseDAO warehouseDAO = new dao.WarehouseDAO();
            model.Warehouse sellerWarehouse = warehouseDAO.findById(warehouseId);
            request.setAttribute("sellerWarehouse", sellerWarehouse);
        } else {
            request.setAttribute("availableGenerators", 0);
        }
    }
 
    private void forwardFallback(String path, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/manager/home".equals(path)) {
            request.getRequestDispatcher("/views/home/manager-home.jsp").forward(request, response);
        } else if ("/warehouse/dashboard".equals(path)) {
            request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
        } else if ("/seller/home".equals(path)) {
            request.getRequestDispatcher("/views/home/seller-home.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/home/staff-home.jsp").forward(request, response);
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("currentUser") : null;
    }

    private void requireRole(User user, HttpServletResponse response, String role) throws IllegalAccessException {
        if (!user.hasRole(role)) {
            throw new IllegalAccessException("Forbidden");
        }
    }
}
