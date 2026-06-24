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

@WebServlet(name = "WarehouseStaffServlet", urlPatterns = {
    "/warehouse/staff",
    "/warehouse/staff/toggle-import",
    "/warehouse/staff/toggle-import-inventory",
    "/warehouse/staff/toggle-export-inventory"
})
public class WarehouseStaffServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireWarehouseManager(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            Warehouse warehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (warehouse == null) {
                request.setAttribute("error", "Bạn chưa được phân công quản lý kho nào. Vui lòng liên hệ Admin.");
                request.getRequestDispatcher("/views/warehouse/staff-list.jsp").forward(request, response);
                return;
            }

            if ("/warehouse/staff".equals(path)) {
                showList(request, response, warehouse);
            } else {
                response.sendRedirect(request.getContextPath() + "/warehouse/staff");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống gặp sự cố: " + e.getMessage());
            request.getRequestDispatcher("/views/warehouse/staff-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireWarehouseManager(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            Warehouse warehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (warehouse == null) {
                response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=no_warehouse");
                return;
            }

            if ("/warehouse/staff/toggle-import".equals(path)) {
                toggleImportPermission(request, response, warehouse);
            } else if ("/warehouse/staff/toggle-import-inventory".equals(path)) {
                toggleImportInventoryPermission(request, response, warehouse);
            } else if ("/warehouse/staff/toggle-export-inventory".equals(path)) {
                toggleExportInventoryPermission(request, response, warehouse);
            } else {
                response.sendRedirect(request.getContextPath() + "/warehouse/staff");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=system_error");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        List<User> staffList = userDAO.findStaffByWarehouse(warehouse.getWarehouseId());
        request.setAttribute("staffList", staffList);
        request.setAttribute("warehouse", warehouse);
        request.getRequestDispatcher("/views/warehouse/staff-list.jsp").forward(request, response);
    }

    private void toggleImportPermission(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        Integer staffId = parseInt(request.getParameter("staffId"));
        boolean canImport = Boolean.parseBoolean(request.getParameter("canImport"));

        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=invalid_id");
            return;
        }

        User viewUser = userDAO.findById(staffId);
        if (viewUser == null || !"STAFF".equals(viewUser.getRoleName()) || viewUser.getWarehouseId() == null || viewUser.getWarehouseId() != warehouse.getWarehouseId()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=invalid_user");
            return;
        }

        boolean updated = userDAO.updateImportPermission(staffId, canImport);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?success=permission_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=update_failed");
        }
    }

    private void toggleImportInventoryPermission(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        Integer staffId = parseInt(request.getParameter("staffId"));
        boolean canImportInventory = Boolean.parseBoolean(request.getParameter("canImportInventory"));

        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=invalid_id");
            return;
        }

        User viewUser = userDAO.findById(staffId);
        if (viewUser == null || !"STAFF".equals(viewUser.getRoleName()) || viewUser.getWarehouseId() == null || viewUser.getWarehouseId() != warehouse.getWarehouseId()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=invalid_user");
            return;
        }

        boolean updated = userDAO.updateImportInventoryPermission(staffId, canImportInventory);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?success=permission_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=update_failed");
        }
    }

    private void toggleExportInventoryPermission(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        Integer staffId = parseInt(request.getParameter("staffId"));
        boolean canExportInventory = Boolean.parseBoolean(request.getParameter("canExportInventory"));

        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=invalid_id");
            return;
        }

        User viewUser = userDAO.findById(staffId);
        if (viewUser == null || !"STAFF".equals(viewUser.getRoleName()) || viewUser.getWarehouseId() == null || viewUser.getWarehouseId() != warehouse.getWarehouseId()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=invalid_user");
            return;
        }

        boolean updated = userDAO.updateExportInventoryPermission(staffId, canExportInventory);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?success=permission_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/warehouse/staff?error=update_failed");
        }
    }

    private User requireWarehouseManager(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        return currentUser;
    }

    private Integer parseInt(String value) {
        try {
            return value == null ? null : Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
