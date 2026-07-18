package controller.admin;

import dao.UserDAO;
import dao.WarehouseDAO;
import dao.RoleDAO;
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
import model.Permission;

@WebServlet(name = "PermissionManagementServlet", urlPatterns = {
    "/admin/permissions",
    "/admin/permissions/toggle"
})
public class PermissionManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireAdmin(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/admin/permissions".equals(path)) {
                showList(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/permissions");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống gặp sự cố: " + e.getMessage());
            showFallbackList(request, response);
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
            if ("/admin/permissions/toggle".equals(path)) {
                togglePermission(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/permissions");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/permissions?error=system_error");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String roleParam = request.getParameter("role");
        if (roleParam == null) {
            roleParam = "STAFF"; // Default to STAFF
        }

        List<User> userList;
        if ("ALL".equalsIgnoreCase(roleParam)) {
            userList = userDAO.findUsers(null, null, null);
        } else {
            userList = userDAO.findUsers(null, null, roleParam);
        }

        userList.removeIf(u -> "ADMIN".equals(u.getRoleName()));

        List<Warehouse> warehouseList = warehouseDAO.findAll();
        List<Permission> permissionList = userDAO.findAllPermissions();
        if (!"ALL".equalsIgnoreCase(roleParam)) {
            final String finalRole = roleParam;
            permissionList.removeIf(p -> !p.getRoles().contains(finalRole));
        }
        List<String> activeRoles = roleDAO.findActiveRoleNames();
        activeRoles.remove("ADMIN");
        
        request.setAttribute("userList", userList);
        request.setAttribute("warehouseList", warehouseList);
        request.setAttribute("permissionList", permissionList);
        request.setAttribute("allRoles", activeRoles);
        request.setAttribute("selectedRole", roleParam);
        
        request.getRequestDispatcher("/views/admin/permission-list.jsp").forward(request, response);
    }

    private void showFallbackList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String roleParam = request.getParameter("role");
            if (roleParam == null) {
                roleParam = "STAFF";
            }
            List<User> userList;
            if ("ALL".equalsIgnoreCase(roleParam)) {
                userList = userDAO.findUsers(null, null, null);
            } else {
                userList = userDAO.findUsers(null, null, roleParam);
            }
            userList.removeIf(u -> "ADMIN".equals(u.getRoleName()));

            List<Warehouse> warehouseList = warehouseDAO.findAll();
            List<Permission> permissionList = userDAO.findAllPermissions();
            if (!"ALL".equalsIgnoreCase(roleParam)) {
                final String finalRole = roleParam;
                permissionList.removeIf(p -> !p.getRoles().contains(finalRole));
            }
            List<String> activeRoles = roleDAO.findActiveRoleNames();
            activeRoles.remove("ADMIN");
            
            request.setAttribute("userList", userList);
            request.setAttribute("warehouseList", warehouseList);
            request.setAttribute("permissionList", permissionList);
            request.setAttribute("allRoles", activeRoles);
            request.setAttribute("selectedRole", roleParam);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        request.getRequestDispatcher("/views/admin/permission-list.jsp").forward(request, response);
    }

    private void togglePermission(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer staffId = parseInt(request.getParameter("staffId"));
        String permissionName = request.getParameter("permissionName");
        boolean enable = Boolean.parseBoolean(request.getParameter("enable"));
        String selectedRole = request.getParameter("selectedRole");
        if (selectedRole == null || selectedRole.trim().isEmpty()) {
            selectedRole = "STAFF";
        }

        if (staffId == null || permissionName == null || permissionName.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions?error=invalid_id&role=" + selectedRole);
            return;
        }

        User viewUser = userDAO.findById(staffId);
        if (viewUser == null || "ADMIN".equals(viewUser.getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions?error=invalid_user&role=" + selectedRole);
            return;
        }

        boolean updated = userDAO.updateUserPermission(staffId, permissionName.trim(), enable);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions?success=permission_updated&role=" + selectedRole);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/permissions?error=update_failed&role=" + selectedRole);
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
            return value == null ? null : Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
