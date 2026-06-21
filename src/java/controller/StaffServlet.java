package controller;

import dao.PartRequestDAO;
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
import model.PartRequest;
import model.Part;
import model.Warehouse;
import model.User;

@WebServlet(name = "StaffServlet", urlPatterns = {
    "/staff/part-request/create",
    "/staff/my-requests"
})
public class StaffServlet extends HttpServlet {

    private final PartRequestDAO partRequestDAO = new PartRequestDAO();
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
            if ("/staff/part-request/create".equals(path)) {
                showPartRequestForm(request, response);
            } else if ("/staff/my-requests".equals(path)) {
                showMyPartRequests(request, response, currentUser);
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

        String path = request.getServletPath();
        try {
            if ("/staff/part-request/create".equals(path)) {
                createPartRequest(request, response, currentUser);
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/home");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/staff/home?error=system_error");
        }
    }

    private void showPartRequestForm(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        List<Warehouse> warehouses = warehouseDAO.findAll();
        List<Part> parts = partDAO.findAll();
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("parts", parts);
        request.getRequestDispatcher("/views/staff/part-request-create.jsp").forward(request, response);
    }

    private void showMyPartRequests(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws Exception {
        List<PartRequest> requests = partRequestDAO.findPartRequests(currentUser.getUserId(), null);
        List<Warehouse> warehouses = warehouseDAO.findAll();
        List<Part> parts = partDAO.findAll();
        
        request.setAttribute("requests", requests);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("parts", parts);
        request.getRequestDispatcher("/views/staff/my-requests.jsp").forward(request, response);
    }

    private void createPartRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws Exception {
        Integer warehouseId = parseInt(request.getParameter("warehouseId"));
        Integer partId = parseInt(request.getParameter("partId"));
        Integer quantity = parseInt(request.getParameter("quantity"));
        String reason = trim(request.getParameter("reason"));

        if (warehouseId == null || partId == null || quantity == null || quantity <= 0) {
            response.sendRedirect(request.getContextPath() + "/staff/part-request/create?error=invalid_input");
            return;
        }

        PartRequest req = new PartRequest();
        req.setWarehouseId(warehouseId);
        req.setPartId(partId);
        req.setRequestedBy(currentUser.getUserId());
        req.setQuantity(quantity);
        req.setReason(reason);
        req.setStatus("PENDING");

        int id = partRequestDAO.insert(req);
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/staff/my-requests?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/part-request/create?error=create_failed");
        }
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
