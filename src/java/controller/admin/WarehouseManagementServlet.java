package controller.admin;

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

@WebServlet(name = "WarehouseManagementServlet", urlPatterns = {
    "/admin/warehouses",
    "/admin/warehouse/create",
    "/admin/warehouse/update",
    "/admin/warehouse/toggle-status",
    "/admin/warehouse/delete"
})
public class WarehouseManagementServlet extends HttpServlet {

    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireAdmin(request, response);
        if (currentUser == null) {
            return;
        }

        try {
            showList(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống. Không thể tải danh sách kho.");
            try {
                request.setAttribute("warehouses", warehouseDAO.findAll());
                request.setAttribute("managers", userDAO.findUsersByRoleName("MANAGER"));
                request.setAttribute("warehouseManagers", userDAO.findUsersByRoleName("WAREHOUSE_MANAGER"));
                request.setAttribute("allStaff", userDAO.findUsersByRoleName("STAFF"));
                request.setAttribute("allSellers", userDAO.findUsersByRoleName("SELLER"));
            } catch (Exception ignored) {
            }
            request.getRequestDispatcher("/views/admin/warehouse-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireAdmin(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/admin/warehouse/create".equals(path)) {
                createWarehouse(request, response);
            } else if ("/admin/warehouse/update".equals(path)) {
                updateWarehouse(request, response);
            } else if ("/admin/warehouse/toggle-status".equals(path)) {
                toggleStatus(request, response);
            } else if ("/admin/warehouse/delete".equals(path)) {
                deleteWarehouse(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/warehouses");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=system_error");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String q = trim(request.getParameter("q"));
        String status = trim(request.getParameter("status"));

        List<Warehouse> list = warehouseDAO.findWarehouses(q, status);
        List<User> managers = userDAO.findUsersByRoleName("MANAGER");
        List<User> warehouseManagers = userDAO.findUsersByRoleName("WAREHOUSE_MANAGER");
        List<User> allStaff = userDAO.findUsersByRoleName("STAFF");
        List<User> allSellers = userDAO.findUsersByRoleName("SELLER");

        request.setAttribute("warehouses", list);
        request.setAttribute("managers", managers);
        request.setAttribute("warehouseManagers", warehouseManagers);
        request.setAttribute("allStaff", allStaff);
        request.setAttribute("allSellers", allSellers);
        request.setAttribute("q", q);
        request.setAttribute("statusFilter", status);

        request.getRequestDispatcher("/views/admin/warehouse-list.jsp").forward(request, response);
    }

    private void createWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String warehouseName = trim(request.getParameter("warehouseName"));
        String address = trim(request.getParameter("address"));
        Integer managerId = parseInt(request.getParameter("managerId"));
        Integer warehouseManagerId = parseInt(request.getParameter("warehouseManagerId"));
        String status = trim(request.getParameter("status"));

        if (status == null || status.isEmpty()) {
            status = "ACTIVE";
        }

        if (warehouseName == null || warehouseName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=name_empty");
            return;
        }
        if (warehouseName.length() < 3 || warehouseName.length() > 100) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=name_length");
            return;
        }
        if (warehouseDAO.existsByName(warehouseName, 0)) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=name_exists");
            return;
        }
        if (address == null || address.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=address_empty");
            return;
        }
        if (address.length() > 255) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=address_length");
            return;
        }
        if (warehouseDAO.existsByAddress(address, 0)) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=address_exists");
            return;
        }
        
        // Validate warehouse manager is not already assigned to another active warehouse
        if (warehouseManagerId != null && warehouseDAO.isWarehouseManagerAssignedToAnotherWarehouse(warehouseManagerId, 0)) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=warehouse_manager_assigned");
            return;
        }

        Warehouse item = new Warehouse();
        item.setWarehouseName(warehouseName);
        item.setAddress(address);
        item.setManagerId(managerId);
        item.setWarehouseManagerId(warehouseManagerId);
        item.setStatus(status);

        int generatedId = warehouseDAO.insert(item);
        if (generatedId > 0) {
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
            userDAO.updateWarehouseStaff(generatedId, selectedStaffIds);

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
            userDAO.updateWarehouseSellers(generatedId, selectedSellerIds);

            response.sendRedirect(request.getContextPath() + "/admin/warehouses?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=create_failed");
        }
    }

    private void updateWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("warehouseId"));
        String warehouseName = trim(request.getParameter("warehouseName"));
        String address = trim(request.getParameter("address"));
        Integer managerId = parseInt(request.getParameter("managerId"));
        Integer warehouseManagerId = parseInt(request.getParameter("warehouseManagerId"));
        String status = trim(request.getParameter("status"));

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses");
            return;
        }

        if (warehouseName == null || warehouseName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=name_empty");
            return;
        }
        if (warehouseName.length() < 3 || warehouseName.length() > 100) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=name_length");
            return;
        }
        if (warehouseDAO.existsByName(warehouseName, id)) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=name_exists");
            return;
        }
        if (address == null || address.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=address_empty");
            return;
        }
        if (address.length() > 255) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=address_length");
            return;
        }
        if (warehouseDAO.existsByAddress(address, id)) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=address_exists");
            return;
        }

        // Validate warehouse manager is not already assigned to another active warehouse
        if (warehouseManagerId != null && warehouseDAO.isWarehouseManagerAssignedToAnotherWarehouse(warehouseManagerId, id)) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=warehouse_manager_assigned");
            return;
        }

        Warehouse item = warehouseDAO.findById(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=not_found");
            return;
        }

        item.setWarehouseName(warehouseName);
        item.setAddress(address);
        item.setManagerId(managerId);
        item.setWarehouseManagerId(warehouseManagerId);
        if (status != null && !status.isEmpty()) {
            item.setStatus(status);
        }

        boolean updated = warehouseDAO.update(item);
        if (updated) {
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
            userDAO.updateWarehouseStaff(id, selectedStaffIds);

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
            userDAO.updateWarehouseSellers(id, selectedSellerIds);

            response.sendRedirect(request.getContextPath() + "/admin/warehouses?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=update_failed");
        }
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("warehouseId"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses");
            return;
        }

        Warehouse item = warehouseDAO.findById(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=not_found");
            return;
        }

        String newStatus = active ? "ACTIVE" : "INACTIVE";
        item.setStatus(newStatus);

        boolean updated = warehouseDAO.update(item);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?success=" + (active ? "activated" : "deactivated"));
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=toggle_failed");
        }
    }

    private void deleteWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("warehouseId"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses");
            return;
        }

        boolean success = warehouseDAO.delete(id);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses?error=delete_failed");
        }
    }

    private User requireAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        if (!currentUser.hasRole("ADMIN")) {
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

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
