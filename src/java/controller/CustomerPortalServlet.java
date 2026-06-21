package controller;

import dao.CustomerPortalDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import model.Customer;
import model.CustomerRentalContract;
import model.CustomerRentedGenerator;
import model.Notification;
import model.User;

@WebServlet(name = "CustomerPortalServlet", urlPatterns = {
    "/customer/home",
    "/customer/contracts",
    "/customer/generators",
    "/customer/notifications",
    "/customer/rental-request",
    "/customer/rental-request/create"
})
public class CustomerPortalServlet extends HttpServlet {

    private final CustomerPortalDAO customerPortalDAO = new CustomerPortalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireCustomer(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            Customer customer = customerPortalDAO.findCustomerByEmail(currentUser.getEmail());
            request.setAttribute("customerInfo", customer);

            if (customer == null) {
                request.setAttribute("customerPortalError",
                        "Tai khoan customer chua duoc lien ket voi ho so khach hang ACTIVE nao. Vui long lien he Manager.");
                forward(path, request, response);
                return;
            }

            List<CustomerRentalContract> contracts = customerPortalDAO.findContractsForCustomer(customer.getCustomerId());
            List<CustomerRentedGenerator> rentedGenerators = customerPortalDAO.findActiveGeneratorsForCustomer(customer.getCustomerId());
            List<Notification> notifications = customerPortalDAO.findNotificationsForUser(currentUser.getUserId());

            request.setAttribute("contracts", contracts);
            request.setAttribute("rentedGenerators", rentedGenerators);
            request.setAttribute("notifications", notifications);
            if ("/customer/rental-request".equals(path)) {
                request.setAttribute("availableGenerators", customerPortalDAO.findAvailableGeneratorsForRental());
            }
            request.setAttribute("totalContracts", contracts.size());
            request.setAttribute("activeGenerators", rentedGenerators.size());
            request.setAttribute("unreadNotifications", customerPortalDAO.countUnreadNotifications(currentUser.getUserId()));
            request.setAttribute("rentalSchemaReady", true);

            forward(path, request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("customerPortalError", "Khong tai duoc du lieu customer portal.");
            forward(path, request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireCustomer(request, response);
        if (currentUser == null) {
            return;
        }

        if (!"/customer/rental-request/create".equals(request.getServletPath())) {
            response.sendRedirect(request.getContextPath() + "/customer/home");
            return;
        }

        try {
            Customer customer = customerPortalDAO.findCustomerByEmail(currentUser.getEmail());
            if (customer == null) {
                response.sendRedirect(request.getContextPath() + "/customer/rental-request?error=customer_not_linked");
                return;
            }

            Integer generatorId = parseInt(request.getParameter("generatorId"));
            Timestamp startDate = parseDate(request.getParameter("startDate"));
            Timestamp expectedReturnDate = parseDate(request.getParameter("expectedReturnDate"));
            String note = trim(request.getParameter("note"));

            if (generatorId == null || startDate == null || expectedReturnDate == null) {
                response.sendRedirect(request.getContextPath() + "/customer/rental-request?error=missing_required");
                return;
            }

            if (!expectedReturnDate.after(startDate)) {
                response.sendRedirect(request.getContextPath() + "/customer/rental-request?error=invalid_date");
                return;
            }

            int contractId = customerPortalDAO.createRentalRequest(customer.getCustomerId(), currentUser.getUserId(),
                    generatorId, startDate, expectedReturnDate, note);
            if (contractId > 0) {
                response.sendRedirect(request.getContextPath() + "/customer/contracts?success=rental_requested");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/rental-request?error=generator_unavailable");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/rental-request?error=system_error");
        }
    }

    private void forward(String path, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/customer/contracts".equals(path)) {
            request.getRequestDispatcher("/views/customer-portal/contracts.jsp").forward(request, response);
        } else if ("/customer/generators".equals(path)) {
            request.getRequestDispatcher("/views/customer-portal/generators.jsp").forward(request, response);
        } else if ("/customer/notifications".equals(path)) {
            request.getRequestDispatcher("/views/customer-portal/notifications.jsp").forward(request, response);
        } else if ("/customer/rental-request".equals(path)) {
            request.getRequestDispatcher("/views/customer-portal/rental-request.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/customer-portal/home.jsp").forward(request, response);
        }
    }

    private User requireCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        if (!currentUser.hasRole("CUSTOMER")) {
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

    private Timestamp parseDate(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date date = sdf.parse(value.trim());
            return new Timestamp(date.getTime());
        } catch (Exception ex) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
