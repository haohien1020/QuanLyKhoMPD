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

@WebServlet(name = "WarehouseSellerServlet", urlPatterns = {
    "/warehouse/sellers",
    "/warehouse/sellers/create",
    "/warehouse/sellers/update",
    "/warehouse/sellers/toggle-active"
})
public class WarehouseSellerServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final RoleDAO roleDAO = new RoleDAO();

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
                request.getRequestDispatcher("/views/warehouse/seller-list.jsp").forward(request, response);
                return;
            }

            if ("/warehouse/sellers/create".equals(path)) {
                showCreateForm(request, response);
            } else if ("/warehouse/sellers/update".equals(path)) {
                showUpdateForm(request, response, warehouse);
            } else {
                showList(request, response, warehouse);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống gặp sự cố: " + e.getMessage());
            request.getRequestDispatcher("/views/warehouse/seller-list.jsp").forward(request, response);
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
                response.sendRedirect(request.getContextPath() + "/warehouse/sellers?error=no_warehouse");
                return;
            }

            if ("/warehouse/sellers/create".equals(path)) {
                createSeller(request, response, warehouse);
            } else if ("/warehouse/sellers/update".equals(path)) {
                updateSeller(request, response, warehouse);
            } else if ("/warehouse/sellers/toggle-active".equals(path)) {
                toggleActive(request, response, warehouse);
            } else {
                response.sendRedirect(request.getContextPath() + "/warehouse/sellers");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers?error=system_error");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        List<User> sellers = userDAO.findSellersByWarehouse(warehouse.getWarehouseId());
        request.setAttribute("sellers", sellers);
        request.setAttribute("warehouse", warehouse);
        request.getRequestDispatcher("/views/warehouse/seller-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        request.getRequestDispatcher("/views/warehouse/seller-form.jsp").forward(request, response);
    }

    private void showUpdateForm(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers");
            return;
        }

        User viewUser = userDAO.findById(id);
        if (viewUser == null || !"SELLER".equals(viewUser.getRoleName()) || viewUser.getWarehouseId() == null || viewUser.getWarehouseId() != warehouse.getWarehouseId()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers?error=invalid_user");
            return;
        }

        request.setAttribute("viewUser", viewUser);
        request.getRequestDispatcher("/views/warehouse/seller-form.jsp").forward(request, response);
    }

    private void createSeller(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        String username = trim(request.getParameter("username"));
        String password = request.getParameter("password");
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        boolean active = "true".equalsIgnoreCase(request.getParameter("active"));

        keepInput(request, username, fullName, email, phone, active);

        String error = validateCreate(username, password, fullName, email, phone);
        if (error != null) {
            request.setAttribute("error", error);
            showCreateForm(request, response);
            return;
        }

        Role sellerRole = roleDAO.findByName("SELLER");
        if (sellerRole == null || !"ACTIVE".equalsIgnoreCase(sellerRole.getStatus())) {
            request.setAttribute("error", "Vai trò SELLER chưa hoạt động trên hệ thống.");
            showCreateForm(request, response);
            return;
        }

        String status = active ? "ACTIVE" : "BANNED";
        int userId = userDAO.insertUser(sellerRole.getRoleId(), fullName, email, username, password, phone, status, warehouse.getWarehouseId());
        if (userId == 0) {
            request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại.");
            showCreateForm(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/warehouse/sellers?success=created");
    }

    private void updateSeller(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers");
            return;
        }

        User viewUser = userDAO.findById(id);
        if (viewUser == null || !"SELLER".equals(viewUser.getRoleName()) || viewUser.getWarehouseId() == null || viewUser.getWarehouseId() != warehouse.getWarehouseId()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers?error=invalid_user");
            return;
        }

        String username = trim(request.getParameter("username"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));

        String errorCode = validateUpdate(id, username, fullName, email, phone);
        if (errorCode != null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers/update?id=" + id + "&error=" + errorCode);
            return;
        }

        boolean updated = userDAO.updateAdminUser(id, username, fullName, email, phone);
        if (!updated) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers/update?id=" + id + "&error=update_failed");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/warehouse/sellers?success=updated");
    }

    private void toggleActive(HttpServletRequest request, HttpServletResponse response, Warehouse warehouse)
            throws Exception {
        Integer id = parseInt(request.getParameter("id"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers");
            return;
        }

        User viewUser = userDAO.findById(id);
        if (viewUser == null || !"SELLER".equals(viewUser.getRoleName()) || viewUser.getWarehouseId() == null || viewUser.getWarehouseId() != warehouse.getWarehouseId()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/sellers?error=invalid_user");
            return;
        }

        String newStatus = active ? "ACTIVE" : "BANNED";
        userDAO.updateStatus(id, newStatus);
        response.sendRedirect(request.getContextPath()
                + "/warehouse/sellers?success=" + (active ? "unbanned" : "banned"));
    }

    private String validateCreate(String username, String password, String fullName, String email, String phone) throws Exception {
        String baseError = validateCommon(username, fullName, email, phone);
        if (baseError != null) {
            return baseError;
        }
        if (password == null || password.trim().isEmpty()) {
            return "Mật khẩu là bắt buộc.";
        }
        if (!isValidPassword(password)) {
            return "Mật khẩu phải chứa ít nhất 6 ký tự, có 1 chữ hoa và 1 chữ số.";
        }
        if (userDAO.isUsernameUsedByAnotherUser(username, 0)) {
            return "Tên tài khoản đã tồn tại.";
        }
        if (userDAO.isEmailUsedByAnotherUser(email, 0)) {
            return "Email đã được sử dụng.";
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
            return "Tên tài khoản là bắt buộc.";
        }
        if (username.length() < 3 || username.length() > 30) {
            return "Tên tài khoản phải từ 3 đến 30 ký tự.";
        }
        if (!username.matches("^[A-Za-z0-9_.-]+$")) {
            return "Tên tài khoản chỉ được chứa chữ cái, số, dấu chấm, dấu gạch dưới và gạch nối.";
        }
        if (fullName == null || fullName.isEmpty()) {
            return "Họ tên là bắt buộc.";
        }
        if (fullName.length() < 2 || fullName.length() > 100) {
            return "Họ tên phải từ 2 đến 100 ký tự.";
        }
        if (email == null || email.isEmpty()) {
            return "Email là bắt buộc.";
        }
        if (!isValidEmail(email)) {
            return "Địa chỉ email không hợp lệ.";
        }
        if (phone != null && !phone.isEmpty() && !isValidPhone(phone)) {
            return "Số điện thoại không hợp lệ.";
        }
        return null;
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

    private void keepInput(HttpServletRequest request, String username, String fullName,
            String email, String phone, boolean active) {
        request.setAttribute("f_username", username);
        request.setAttribute("f_fullName", fullName);
        request.setAttribute("f_email", email);
        request.setAttribute("f_phone", phone);
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
