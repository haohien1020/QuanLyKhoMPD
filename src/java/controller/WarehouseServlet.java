package controller;

import dao.UserDAO;
import dao.WarehouseDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;
import model.Warehouse;

@WebServlet(name = "WarehouseServlet", urlPatterns = {"/warehouses"})
public class WarehouseServlet extends HttpServlet {

    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        // If user is ADMIN, redirect them to admin warehouses page
        if (currentUser.hasRole("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses");
            return;
        }

        // If user is WAREHOUSE_MANAGER, redirect them to warehouse dashboard
        if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
            response.sendRedirect(request.getContextPath() + "/warehouse/dashboard");
            return;
        }

        // Only allow MANAGER to view this custom supervising list
        if (!currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String q = request.getParameter("q");
            q = (q != null) ? q.trim() : "";

            List<Warehouse> supervisedWarehouses = warehouseDAO.findBySupervisingManager(currentUser.getUserId(), q);
            List<User> warehouseManagers = userDAO.findUsersByRoleName("WAREHOUSE_MANAGER");
            List<User> allStaff = userDAO.findUsersByRoleName("STAFF");
            List<User> allSellers = userDAO.findUsersByRoleName("SELLER");
            List<Warehouse> activeManagerAssignments = warehouseDAO.findActiveWarehouseManagerAssignments();

            request.setAttribute("warehouses", supervisedWarehouses);
            request.setAttribute("warehouseManagers", warehouseManagers);
            request.setAttribute("allStaff", allStaff);
            request.setAttribute("allSellers", allSellers);
            request.setAttribute("activeManagerAssignments", activeManagerAssignments);
            request.setAttribute("q", q);

            request.getRequestDispatcher("/views/warehouse/manager-warehouse-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải danh sách kho đang quản lý: " + e.getMessage());
            request.getRequestDispatcher("/views/warehouse/manager-warehouse-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        if (!currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("assignPersonnel".equals(action)) {
            try {
                Integer warehouseId = parseInt(request.getParameter("warehouseId"));
                if (warehouseId == null) {
                    response.sendRedirect(request.getContextPath() + "/warehouses?error=invalid_warehouse");
                    return;
                }

                // Security check: Verify that this manager supervises this warehouse
                Warehouse warehouse = warehouseDAO.findById(warehouseId);
                if (warehouse == null || warehouse.getManagerId() == null || warehouse.getManagerId() != currentUser.getUserId()) {
                    response.sendRedirect(request.getContextPath() + "/warehouses?error=permission_denied");
                    return;
                }

                Integer warehouseManagerId = parseInt(request.getParameter("warehouseManagerId"));

                // Validate warehouse manager is not assigned to another active warehouse
                if (warehouseManagerId != null) {
                    boolean isAssigned = warehouseDAO.isWarehouseManagerAssignedToAnotherWarehouse(warehouseManagerId, warehouseId);
                    if (isAssigned) {
                        response.sendRedirect(request.getContextPath() + "/warehouses?error=warehouse_manager_assigned");
                        return;
                    }
                }

                // 1. Update Warehouse Manager
                warehouse.setWarehouseManagerId(warehouseManagerId);
                warehouseDAO.update(warehouse);

                // 2. Update Staff
                String[] staffIdParams = request.getParameterValues("staffIds");
                List<Integer> selectedStaffIds = new java.util.ArrayList<>();
                if (staffIdParams != null) {
                    for (String p : staffIdParams) {
                        Integer sId = parseInt(p);
                        if (sId != null) {
                            selectedStaffIds.add(sId);
                        }
                    }
                }
                userDAO.updateWarehouseStaff(warehouseId, selectedStaffIds);

                // 3. Update Sellers
                String[] sellerIdParams = request.getParameterValues("sellerIds");
                List<Integer> selectedSellerIds = new java.util.ArrayList<>();
                if (sellerIdParams != null) {
                    for (String p : sellerIdParams) {
                        Integer sId = parseInt(p);
                        if (sId != null) {
                            selectedSellerIds.add(sId);
                        }
                    }
                }
                userDAO.updateWarehouseSellers(warehouseId, selectedSellerIds);

                response.sendRedirect(request.getContextPath() + "/warehouses?success=assigned");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/warehouses?error=system_error");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/warehouses");
        }
    }

    private Integer parseInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
