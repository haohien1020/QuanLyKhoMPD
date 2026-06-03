package controller;

import dao.CustomerDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Customer;
import model.User;

@WebServlet(name = "CustomerServlet", urlPatterns = {
    "/customers",
    "/customers/create",
    "/customers/update",
    "/customers/status"
})
public class CustomerServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireCustomerManagerRole(request, response);
        if (currentUser == null) {
            return;
        }

        try {
            String q = trim(request.getParameter("q"));
            String status = trim(request.getParameter("status"));
            List<Customer> customers = customerDAO.findCustomers(q, status);

            request.setAttribute("customers", customers);
            request.setAttribute("q", q);
            request.setAttribute("statusFilter", status);
            request.getRequestDispatcher("/views/customer/customer-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "system_error");
            request.getRequestDispatcher("/views/customer/customer-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireCustomerManagerRole(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/customers/create".equals(path)) {
                createCustomer(request, response);
            } else if ("/customers/update".equals(path)) {
                updateCustomer(request, response);
            } else if ("/customers/status".equals(path)) {
                updateCustomerStatus(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/customers");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customers?error=system_error");
        }
    }

    private void createCustomer(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String customerName = trim(request.getParameter("customerName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String address = trim(request.getParameter("address"));
        String status = trim(request.getParameter("status"));

        if (customerName == null || customerName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customers?error=missing_required");
            return;
        }

        if (customerDAO.isEmailUsedByAnotherCustomer(email, 0)) {
            response.sendRedirect(request.getContextPath() + "/customers?error=email_exists");
            return;
        }

        Customer customer = new Customer();
        customer.setCustomerName(customerName);
        customer.setPhone(phone);
        customer.setEmail(email);
        customer.setAddress(address);
        customer.setStatus(status == null || status.isEmpty() ? "ACTIVE" : status);

        int id = customerDAO.insert(customer);
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/customers?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/customers?error=create_failed");
        }
    }

    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer customerId = parseInt(request.getParameter("customerId"));
        String customerName = trim(request.getParameter("customerName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String address = trim(request.getParameter("address"));
        String status = trim(request.getParameter("status"));

        if (customerId == null || customerName == null || customerName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customers?error=missing_required");
            return;
        }

        Customer existing = customerDAO.findById(customerId);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/customers?error=not_found");
            return;
        }

        if (customerDAO.isEmailUsedByAnotherCustomer(email, customerId)) {
            response.sendRedirect(request.getContextPath() + "/customers?error=email_exists");
            return;
        }

        existing.setCustomerName(customerName);
        existing.setPhone(phone);
        existing.setEmail(email);
        existing.setAddress(address);
        existing.setStatus(status == null || status.isEmpty() ? "ACTIVE" : status);

        boolean success = customerDAO.update(existing);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/customers?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/customers?error=update_failed");
        }
    }

    private void updateCustomerStatus(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer customerId = parseInt(request.getParameter("customerId"));
        String status = trim(request.getParameter("status"));

        if (customerId == null || (!"ACTIVE".equals(status) && !"INACTIVE".equals(status))) {
            response.sendRedirect(request.getContextPath() + "/customers?error=invalid_status");
            return;
        }

        boolean success = customerDAO.updateStatus(customerId, status);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/customers?success=status_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/customers?error=update_failed");
        }
    }

    private User requireCustomerManagerRole(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        if (!currentUser.hasRole("ADMIN")
                && !currentUser.hasRole("MANAGER")
                && !currentUser.hasRole("WAREHOUSE_MANAGER")) {
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
