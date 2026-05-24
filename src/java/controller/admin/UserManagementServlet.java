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
import java.util.List;
import model.Role;
import model.User;

@WebServlet(name = "UserManagementServlet", urlPatterns = {
    "/admin/user",
    "/admin/users",
    "/admin/user/create",
    "/admin/user/detail",
    "/admin/user/update",
    "/admin/user/toggle-active"
})
public class UserManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
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
            if ("/admin/user/create".equals(path)) {
                showCreateForm(request, response);
            } else if ("/admin/user/detail".equals(path)) {
                showDetail(request, response);
            } else {
                showList(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System error. Please try again later.");
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
            if ("/admin/user/create".equals(path)) {
                createUser(request, response);
            } else if ("/admin/user/update".equals(path)) {
                updateUser(request, response);
            } else if ("/admin/user/toggle-active".equals(path)) {
                toggleActive(request, response, currentUser);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users");
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
        String role = trim(request.getParameter("role"));

        request.setAttribute("users", userDAO.findUsers(q, status, role));
        request.setAttribute("allRoles", roleDAO.findActiveRoleNames());
        request.setAttribute("q", q);
        request.setAttribute("statusFilter", status);
        request.setAttribute("roleFilter", role);
        request.getRequestDispatcher("/views/admin/user-list.jsp").forward(request, response);
    }

    private void showFallbackList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("users", userDAO.findUsers(null, null, null));
            request.setAttribute("allRoles", roleDAO.findActiveRoleNames());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        request.getRequestDispatcher("/views/admin/user-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        request.setAttribute("allRoles", roleDAO.findActiveRoleNames());
        request.getRequestDispatcher("/views/admin/user-form.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        request.setAttribute("viewUser", userDAO.findById(id));
        request.getRequestDispatcher("/views/admin/user-detail.jsp").forward(request, response);
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String username = trim(request.getParameter("username"));
        String password = request.getParameter("password");
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String roleName = trim(request.getParameter("role"));
        boolean active = "true".equalsIgnoreCase(request.getParameter("active"));

        keepCreateInput(request, username, fullName, email, phone, roleName, active);

        String error = validateCreate(username, password, fullName, email, phone, roleName);
        if (error != null) {
            request.setAttribute("error", error);
            showCreateForm(request, response);
            return;
        }

        Role role = roleDAO.findByName(roleName);
        if (role == null || !"ACTIVE".equalsIgnoreCase(role.getStatus())) {
            request.setAttribute("error", "Selected role is invalid.");
            showCreateForm(request, response);
            return;
        }

        String status = active ? "ACTIVE" : "BANNED";
        int userId = userDAO.insertUser(role.getRoleId(), fullName, email, username, password, phone, status);
        if (userId == 0) {
            request.setAttribute("error", "Could not create user. Please try again.");
            showCreateForm(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/users?success=created");
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        String username = trim(request.getParameter("username"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));

        String errorCode = validateUpdate(id, username, fullName, email, phone);
        if (errorCode != null) {
            response.sendRedirect(request.getContextPath() + "/admin/user/detail?id=" + id + "&error=" + errorCode);
            return;
        }

        boolean updated = userDAO.updateAdminUser(id, username, fullName, email, phone);
        if (!updated) {
            response.sendRedirect(request.getContextPath() + "/admin/user/detail?id=" + id + "&error=update_failed");
            return;
        }

        refreshCurrentUserIfNeeded(request, id);
        response.sendRedirect(request.getContextPath() + "/admin/user/detail?id=" + id + "&success=updated");
    }

    private void toggleActive(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        if (id == currentUser.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=self_toggle");
            return;
        }

        String newStatus = active ? "ACTIVE" : "BANNED";
        userDAO.updateStatus(id, newStatus);
        response.sendRedirect(request.getContextPath()
                + "/admin/users?success=" + (active ? "unbanned" : "banned"));
    }

    private String validateCreate(String username, String password, String fullName,
            String email, String phone, String roleName) throws Exception {
        String baseError = validateCommon(username, fullName, email, phone);
        if (baseError != null) {
            return baseError;
        }
        if (password == null || password.trim().isEmpty()) {
            return "Password is required.";
        }
        if (!isValidPassword(password)) {
            return "Password must be at least 6 characters and contain at least 1 uppercase letter and 1 number.";
        }
        if (roleName == null || roleName.isEmpty()) {
            return "Role is required.";
        }
        if (userDAO.isUsernameUsedByAnotherUser(username, 0)) {
            return "Username is already used.";
        }
        if (userDAO.isEmailUsedByAnotherUser(email, 0)) {
            return "Email is already used.";
        }
        return null;
    }

    private String validateUpdate(int userId, String username, String fullName, String email, String phone)
            throws Exception {
        if (username == null || username.isEmpty()) {
            return "username_empty";
        }
        if (username.length() < 3 || username.length() > 30) {
            return "username_len";
        }
        if (!username.matches("^[A-Za-z0-9_.-]+$")) {
            return "username_len";
        }
        if (fullName == null || fullName.isEmpty()) {
            return "fullname_empty";
        }
        if (fullName.length() < 2 || fullName.length() > 100) {
            return "fullname_len";
        }
        if (email == null || email.isEmpty()) {
            return "email_empty";
        }
        if (!isValidEmail(email)) {
            return "email_empty";
        }
        if (phone != null && !phone.isEmpty() && !isValidPhone(phone)) {
            return "phone_invalid";
        }
        if (userDAO.isUsernameUsedByAnotherUser(username, userId)) {
            return "username_taken";
        }
        if (userDAO.isEmailUsedByAnotherUser(email, userId)) {
            return "email_taken";
        }
        return null;
    }

    private String validateCommon(String username, String fullName, String email, String phone)
            throws Exception {
        if (username == null || username.isEmpty()) {
            return "Username is required.";
        }
        if (username.length() < 3 || username.length() > 30) {
            return "Username must be between 3 and 30 characters.";
        }
        if (!username.matches("^[A-Za-z0-9_.-]+$")) {
            return "Username can contain only letters, numbers, dot, underscore and hyphen.";
        }
        if (fullName == null || fullName.isEmpty()) {
            return "Full name is required.";
        }
        if (fullName.length() < 2 || fullName.length() > 100) {
            return "Full name must be between 2 and 100 characters.";
        }
        if (email == null || email.isEmpty()) {
            return "Email is required.";
        }
        if (!isValidEmail(email)) {
            return "Email address is invalid.";
        }
        if (phone != null && !phone.isEmpty() && !isValidPhone(phone)) {
            return "Phone number is invalid.";
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

    private void refreshCurrentUserIfNeeded(HttpServletRequest request, int changedUserId) throws Exception {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser != null && currentUser.getUserId() == changedUserId) {
            session.setAttribute("currentUser", userDAO.findById(changedUserId));
        }
    }

    private void keepCreateInput(HttpServletRequest request, String username, String fullName,
            String email, String phone, String roleName, boolean active) {
        request.setAttribute("f_username", username);
        request.setAttribute("f_fullName", fullName);
        request.setAttribute("f_email", email);
        request.setAttribute("f_phone", phone);
        request.setAttribute("selectedRole", roleName);
        request.setAttribute("f_active", active);
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

    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    private boolean isValidPassword(String password) {
        return password != null
                && password.length() >= 6
                && password.matches(".*[A-Z].*")
                && password.matches(".*\\d.*");
    }

    private boolean isValidPhone(String phone) {
        return phone != null && phone.matches("^(\\+84\\s?\\d{9}|84\\d{9}|0\\d{9})$");
    }
}
