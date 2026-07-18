package controller;

import dao.PartDAO;
import dao.WarehouseDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Part;
import model.Warehouse;
import model.User;

@WebServlet(name = "StaffServlet", urlPatterns = {
    "/staff/rented-generators"
})
public class StaffServlet extends HttpServlet {

    private final PartDAO partDAO = new PartDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireRole(request, response, "STAFF");
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/staff/rented-generators".equals(path)) {
                showRentedGenerators(request, response, currentUser);
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/home");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireRole(request, response, "STAFF");
        if (currentUser == null) {
            return;
        }

        response.sendRedirect(request.getContextPath() + "/staff/home");
    }

    private void showRentedGenerators(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws Exception {
        dao.RentalContractDAO rentalContractDAO = new dao.RentalContractDAO();
        List<model.CustomerRentalContract> assignedContracts = rentalContractDAO.findContractsAssignedToStaff(currentUser.getUserId());
        request.setAttribute("assignedContracts", assignedContracts);

        dao.GeneratorDAO generatorDAO = new dao.GeneratorDAO();
        if (currentUser.getWarehouseId() != null) {
            List<model.GeneratorBarcode> staffBarcodes = generatorDAO.findBarcodes(currentUser.getWarehouseId(), "IN_STOCK");
            request.setAttribute("staffBarcodes", staffBarcodes);
        }
        request.getRequestDispatcher("/views/staff/rented-generators.jsp").forward(request, response);
    }

    private User requireLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }

        return currentUser;
    }

    private User requireRole(HttpServletRequest request, HttpServletResponse response, String role)
            throws IOException {
        User currentUser = requireLogin(request, response);
        if (currentUser == null) {
            return null;
        }

        if (!currentUser.hasRole(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        return currentUser;
    }
}
