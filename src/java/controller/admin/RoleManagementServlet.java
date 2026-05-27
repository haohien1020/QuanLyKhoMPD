package controller.admin;

import dao.RoleDAO;
import dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Role;
import model.User;

@WebServlet(name = "RoleManagementServlet", urlPatterns = {
    "/admin/roles",
    "/admin/roles/create",
    "/admin/roles/update",
    "/admin/roles/toggle-status"
})
public class RoleManagementServlet extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();
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
            request.setAttribute("error", "System error. Please try again later.");
            request.getRequestDispatcher("/views/admin/role-list.jsp").forward(request, response);
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
            if ("/admin/roles/create".equals(path)) {
                createRole(request, response);
            } else if ("/admin/roles/update".equals(path)) {
                updateRole(request, response);
            } else if ("/admin/roles/toggle-status".equals(path)) {
                toggleStatus(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/roles");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System error. Please try again later.");
            showFallbackList(request, response);
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String q = trim(request.getParameter("q"));
        String status = trim(request.getParameter("status"));
        List<Role> roles = roleDAO.findRoles(q, status);

        request.setAttribute("roles", roles);
        request.setAttribute("roleUserCounts", buildRoleUserCounts(roles));
        request.setAttribute("q", q);
        request.setAttribute("statusFilter", status);
        request.getRequestDispatcher("/views/admin/role-list.jsp").forward(request, response);
    }

    private void showFallbackList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Role> roles = roleDAO.findAll();
            request.setAttribute("roles", roles);
            request.setAttribute("roleUserCounts", buildRoleUserCounts(roles));
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        request.getRequestDispatcher("/views/admin/role-list.jsp").forward(request, response);
    }

    private void createRole(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String roleName = normalizeRoleName(request.getParameter("roleName"));
        String description = trim(request.getParameter("description"));
        String status = normalizeStatus(request.getParameter("status"));

        String error = validateRole(roleName, description, 0);
        if (error != null) {
            redirectWithError(response, request, error);
            return;
        }

        Role role = new Role();
        role.setRoleName(roleName);
        role.setDescription(description);
        role.setStatus(status);

        int id = roleDAO.insert(role);
        response.sendRedirect(request.getContextPath()
                + "/admin/roles?success=" + (id > 0 ? "created" : "create_failed"));
    }

    private void updateRole(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer roleId = parseInt(request.getParameter("roleId"));
        if (roleId == null) {
            redirectWithError(response, request, "invalid_id");
            return;
        }

        Role existing = roleDAO.findById(roleId);
        if (existing == null) {
            redirectWithError(response, request, "not_found");
            return;
        }

        String roleName = normalizeRoleName(request.getParameter("roleName"));
        String description = trim(request.getParameter("description"));
        String status = normalizeStatus(request.getParameter("status"));

        String error = validateRole(roleName, description, roleId);
        if (error != null) {
            redirectWithError(response, request, error);
            return;
        }

        if (!"ACTIVE".equals(status) && userDAO.countByRoleId(roleId) > 0) {
            redirectWithError(response, request, "role_in_use");
            return;
        }

        existing.setRoleName(roleName);
        existing.setDescription(description);
        existing.setStatus(status);

        boolean updated = roleDAO.update(existing);
        response.sendRedirect(request.getContextPath()
                + "/admin/roles?success=" + (updated ? "updated" : "update_failed"));
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer roleId = parseInt(request.getParameter("roleId"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));

        if (roleId == null) {
            redirectWithError(response, request, "invalid_id");
            return;
        }

        Role role = roleDAO.findById(roleId);
        if (role == null) {
            redirectWithError(response, request, "not_found");
            return;
        }

        if (!active && userDAO.countByRoleId(roleId) > 0) {
            redirectWithError(response, request, "role_in_use");
            return;
        }

        roleDAO.updateStatus(roleId, active ? "ACTIVE" : "INACTIVE");
        response.sendRedirect(request.getContextPath()
                + "/admin/roles?success=" + (active ? "activated" : "deactivated"));
    }

    private Map<Integer, Integer> buildRoleUserCounts(List<Role> roles) throws Exception {
        Map<Integer, Integer> counts = new HashMap<Integer, Integer>();
        if (roles != null) {
            for (Role role : roles) {
                counts.put(role.getRoleId(), userDAO.countByRoleId(role.getRoleId()));
            }
        }
        return counts;
    }

    private String validateRole(String roleName, String description, int roleId) throws Exception {
        if (roleName == null || roleName.isEmpty()) {
            return "name_required";
        }
        if (roleName.length() < 2 || roleName.length() > 50) {
            return "name_len";
        }
        if (!roleName.matches("^[A-Z][A-Z0-9_]*$")) {
            return "name_format";
        }
        if (description != null && description.length() > 255) {
            return "description_len";
        }
        if (roleDAO.isRoleNameUsedByAnotherRole(roleName, roleId)) {
            return "name_taken";
        }
        return null;
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

    private void redirectWithError(HttpServletResponse response, HttpServletRequest request, String error)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/roles?error=" + error);
    }

    private Integer parseInt(String value) {
        try {
            return value == null ? null : Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String normalizeRoleName(String value) {
        return value == null ? null : value.trim().toUpperCase().replace(' ', '_');
    }

    private String normalizeStatus(String value) {
        return "INACTIVE".equalsIgnoreCase(value) ? "INACTIVE" : "ACTIVE";
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
