package controller;

import dao.WarehouseDAO;
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

@WebServlet(name = "WarehouseServlet", urlPatterns = {"/warehouses"})
public class WarehouseServlet extends HttpServlet {

    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        // If user is ADMIN, redirect them to admin warehouses page
        if (currentUser.hasRole("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/admin/warehouses");
            return;
        }

        // If user is WAREHOUSE_MANAGER, redirect them to warehouse dashboard
        if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
            response.sendRedirect(request.getContextPath() + "/warehouse/dashboard");
            return;
        }

        // Only allow MANAGER to view this custom supervising list
        if (!currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String q = request.getParameter("q");
            q = (q != null) ? q.trim() : "";

            List<Warehouse> supervisedWarehouses = warehouseDAO.findBySupervisingManager(currentUser.getUserId(), q);

            request.setAttribute("warehouses", supervisedWarehouses);
            request.setAttribute("q", q);

            request.getRequestDispatcher("/views/warehouse/manager-warehouse-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải danh sách kho đang quản lý: " + e.getMessage());
            request.getRequestDispatcher("/views/warehouse/manager-warehouse-list.jsp").forward(request, response);
        }
    }
}
