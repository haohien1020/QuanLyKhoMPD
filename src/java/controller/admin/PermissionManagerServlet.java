package controller.admin;

import dao.UserDAO;
import dao.RoleDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Permission;
import model.User;

@WebServlet(name = "PermissionManagerServlet", urlPatterns = {
    "/admin/permissions-manager",
    "/admin/permissions-manager/create",
    "/admin/permissions-manager/update",
    "/admin/permissions-manager/delete"
})
public class PermissionManagerServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireAdmin(request, response);
        if (currentUser == null) {
            return;
        }

        try {
            List<Permission> permissionList = userDAO.findAllPermissions();
            List<String> activeRoles = roleDAO.findActiveRoleNames();
            activeRoles.remove("ADMIN");

            request.setAttribute("permissionList", permissionList);
            request.setAttribute("allRoles", activeRoles);
            request.getRequestDispatcher("/views/admin/permission-crud.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể lấy danh sách quyền: " + e.getMessage());
            request.getRequestDispatcher("/views/admin/permission-crud.jsp").forward(request, response);
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
            if ("/admin/permissions-manager/create".equals(path)) {
                createPermission(request, response);
            } else if ("/admin/permissions-manager/update".equals(path)) {
                updatePermission(request, response);
            } else if ("/admin/permissions-manager/delete".equals(path)) {
                deletePermission(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/permissions-manager");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=action_failed");
        }
    }

    private void createPermission(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String name = trim(request.getParameter("name"));
        String description = trim(request.getParameter("description"));
        String[] roles = request.getParameterValues("roles");

        if (name == null || name.isEmpty() || !name.matches("^[A-Z0-9_]+$") 
                || description == null || description.isEmpty() 
                || roles == null || roles.length == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=invalid_input");
            return;
        }

        if (userDAO.isPermissionNameUsed(name, 0)) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=name_taken");
            return;
        }

        boolean success = userDAO.insertPermission(name, description, roles);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=action_failed");
        }
    }

    private void updatePermission(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        String name = trim(request.getParameter("name"));
        String description = trim(request.getParameter("description"));
        String[] roles = request.getParameterValues("roles");

        if (id == null || name == null || name.isEmpty() 
                || description == null || description.isEmpty() 
                || roles == null || roles.length == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=invalid_input");
            return;
        }

        boolean success = userDAO.updatePermission(id, name, description, roles);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=action_failed");
        }
    }

    private void deletePermission(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=invalid_input");
            return;
        }

        boolean success = userDAO.deletePermission(id);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/permissions-manager?error=action_failed");
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

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
