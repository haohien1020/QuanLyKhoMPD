package controller;

import dao.RoleDAO;
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
import model.Role;
import model.User;
import model.Warehouse;

@WebServlet(name = "ManagerEmployeeServlet", urlPatterns = {
    "/manager/employees",
    "/manager/employee/create",
    "/manager/employee/update",
    "/manager/employee/toggle-status",
    "/manager/employee/assign",
    "/manager/employee/delete"
})
public class ManagerEmployeeServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireManager(request, response);
        if (currentUser == null) {
            return;
        }

        try {
            showEmployees(request, response, currentUser);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống. Không thể tải danh sách nhân viên.");
            request.getRequestDispatcher("/views/warehouse/manager-employee-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireManager(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/manager/employee/create".equals(path)) {
                createEmployee(request, response, currentUser);
            } else if ("/manager/employee/update".equals(path)) {
                updateEmployee(request, response, currentUser);
            } else if ("/manager/employee/toggle-status".equals(path)) {
                toggleStatus(request, response, currentUser);
            } else if ("/manager/employee/assign".equals(path)) {
                assignEmployee(request, response, currentUser);
            } else if ("/manager/employee/delete".equals(path)) {
                deleteEmployee(request, response, currentUser);
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/employees");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=system_error");
        }
    }

    private void showEmployees(HttpServletRequest request, HttpServletResponse response, User manager)
            throws Exception {
        List<User> employees = userDAO.findEmployeesBySupervisingManager(manager.getUserId());
        List<User> warehouseManagers = userDAO.findWarehouseManagersBySupervisingManager(manager.getUserId());

        // For each warehouse manager, attach the warehouse name they manage
        for (User wm : warehouseManagers) {
            Warehouse w = warehouseDAO.findWarehouseByManager(wm.getUserId());
            if (w != null) {
                wm.setWarehouseName(w.getWarehouseName());
                wm.setWarehouseId(w.getWarehouseId());
            }
        }

        request.setAttribute("employees", employees);
        request.setAttribute("warehouseManagers", warehouseManagers);
        request.getRequestDispatcher("/views/warehouse/manager-employee-list.jsp").forward(request, response);
    }

    private void createEmployee(HttpServletRequest request, HttpServletResponse response, User manager)
            throws Exception {
        String roleName = trim(request.getParameter("roleName"));
        Integer warehouseManagerId = parseInt(request.getParameter("warehouseManagerId"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String username = trim(request.getParameter("username"));
        String password = request.getParameter("password");

        // Basic Validations
        if (username == null || username.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=username_empty");
            return;
        }
        if (username.length() < 3 || username.length() > 30 || !username.matches("^[A-Za-z0-9_.-]+$")) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=username_len");
            return;
        }
        if (userDAO.isUsernameUsedByAnotherUser(username, 0)) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=username_exists");
            return;
        }
        if (password == null || password.length() < 6 || !password.matches(".*[A-Z].*") || !password.matches(".*\\d.*")) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=password_invalid");
            return;
        }
        if (fullName == null || fullName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=fullname_empty");
            return;
        }
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=email_invalid");
            return;
        }
        if (userDAO.isEmailUsedByAnotherUser(email, 0)) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=email_exists");
            return;
        }
        if (phone != null && !phone.isEmpty() && !phone.matches("^(\\+84\\s?\\d{9}|84\\d{9}|0\\d{9})$")) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=phone_invalid");
            return;
        }

        // 1. Get warehouse from selected warehouse manager (if assigned)
        Integer warehouseId = null;
        if (warehouseManagerId != null) {
            Warehouse warehouse = warehouseDAO.findWarehouseByManager(warehouseManagerId);
            if (warehouse == null || warehouse.getManagerId() == null || warehouse.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=no_warehouse");
                return;
            }
            warehouseId = warehouse.getWarehouseId();
        }

        // 2. Get role ID
        Role role = roleDAO.findByName(roleName);
        if (role == null || (!"STAFF".equals(roleName) && !"SELLER".equals(roleName))) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=system_error");
            return;
        }

        // 3. Create the user
        int generatedId = userDAO.insertUser(role.getRoleId(), fullName, email, username, password, phone, "ACTIVE", warehouseId);
        if (generatedId > 0) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=create_failed");
        }
    }

    private void updateEmployee(HttpServletRequest request, HttpServletResponse response, User manager)
            throws Exception {
        Integer userId = parseInt(request.getParameter("userId"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        Integer warehouseManagerId = parseInt(request.getParameter("warehouseManagerId"));

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/manager/employees");
            return;
        }

        // Security check: Verify employee is under this Manager (if they are assigned to a warehouse)
        User targetUser = userDAO.findById(userId);
        if (targetUser == null || (!"STAFF".equals(targetUser.getRoleName()) && !"SELLER".equals(targetUser.getRoleName()))) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
            return;
        }
        if (targetUser.getWarehouseId() != null) {
            Warehouse currentWh = warehouseDAO.findById(targetUser.getWarehouseId());
            if (currentWh == null || currentWh.getManagerId() == null || currentWh.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
                return;
            }
        }

        // Validations
        if (fullName == null || fullName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=fullname_empty");
            return;
        }
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=email_invalid");
            return;
        }
        if (userDAO.isEmailUsedByAnotherUser(email, userId)) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=email_exists");
            return;
        }
        if (phone != null && !phone.isEmpty() && !phone.matches("^(\\+84\\s?\\d{9}|84\\d{9}|0\\d{9})$")) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=phone_invalid");
            return;
        }

        // Get new warehouse (optional)
        Integer warehouseId = null;
        if (warehouseManagerId != null) {
            Warehouse newWh = warehouseDAO.findWarehouseByManager(warehouseManagerId);
            if (newWh == null || newWh.getManagerId() == null || newWh.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=no_warehouse");
                return;
            }
            warehouseId = newWh.getWarehouseId();
        }

        // Update employee
        boolean updated = userDAO.updateEmployeeByManager(userId, fullName, email, phone, warehouseId);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=update_failed");
        }
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response, User manager)
            throws Exception {
        Integer userId = parseInt(request.getParameter("userId"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/manager/employees");
            return;
        }

        // Security check
        User targetUser = userDAO.findById(userId);
        if (targetUser == null || (!"STAFF".equals(targetUser.getRoleName()) && !"SELLER".equals(targetUser.getRoleName()))) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
            return;
        }
        if (targetUser.getWarehouseId() != null) {
            Warehouse currentWh = warehouseDAO.findById(targetUser.getWarehouseId());
            if (currentWh == null || currentWh.getManagerId() == null || currentWh.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
                return;
            }
        }

        String newStatus = active ? "ACTIVE" : "BANNED";
        boolean updated = userDAO.updateStatus(userId, newStatus);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?success=status_changed");
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=system_error");
        }
    }

    private void assignEmployee(HttpServletRequest request, HttpServletResponse response, User manager)
            throws Exception {
        Integer userId = parseInt(request.getParameter("userId"));
        Integer warehouseManagerId = parseInt(request.getParameter("warehouseManagerId"));

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/manager/employees");
            return;
        }

        // Security check
        User targetUser = userDAO.findById(userId);
        if (targetUser == null || (!"STAFF".equals(targetUser.getRoleName()) && !"SELLER".equals(targetUser.getRoleName()))) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
            return;
        }
        if (targetUser.getWarehouseId() != null) {
            Warehouse currentWh = warehouseDAO.findById(targetUser.getWarehouseId());
            if (currentWh == null || currentWh.getManagerId() == null || currentWh.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
                return;
            }
        }

        // Get new warehouse (optional)
        Integer warehouseId = null;
        if (warehouseManagerId != null) {
            Warehouse newWh = warehouseDAO.findWarehouseByManager(warehouseManagerId);
            if (newWh == null || newWh.getManagerId() == null || newWh.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=no_warehouse");
                return;
            }
            warehouseId = newWh.getWarehouseId();
        }

        boolean updated = userDAO.updateEmployeeWarehouse(userId, warehouseId);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=system_error");
        }
    }

    private void deleteEmployee(HttpServletRequest request, HttpServletResponse response, User manager)
            throws Exception {
        Integer userId = parseInt(request.getParameter("userId"));
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/manager/employees");
            return;
        }

        // Security check
        User targetUser = userDAO.findById(userId);
        if (targetUser == null || (!"STAFF".equals(targetUser.getRoleName()) && !"SELLER".equals(targetUser.getRoleName()))) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
            return;
        }
        if (targetUser.getWarehouseId() != null) {
            Warehouse currentWh = warehouseDAO.findById(targetUser.getWarehouseId());
            if (currentWh == null || currentWh.getManagerId() == null || currentWh.getManagerId() != manager.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/manager/employees?error=permission_denied");
                return;
            }
        }

        boolean success = userDAO.delete(userId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/manager/employees?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/employees?error=delete_failed");
        }
    }

    private User requireManager(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        if (!currentUser.hasRole("MANAGER")) {
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
