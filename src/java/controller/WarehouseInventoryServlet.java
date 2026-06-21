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
import java.util.ArrayList;
import java.util.List;
import model.Part;
import model.User;
import model.Warehouse;

@WebServlet(name = "WarehouseInventoryServlet", urlPatterns = {
    "/inventory",
    "/inventory/low-stock"
})
public class WarehouseInventoryServlet extends HttpServlet {

    private final PartDAO partDAO = new PartDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        if (!currentUser.hasRole("WAREHOUSE_MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();

        try {
            Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (managedWarehouse == null) {
                request.setAttribute("error", "Tài khoản của bạn chưa được chỉ định quản lý bất kỳ kho nào hoạt động.");
                request.getRequestDispatcher("/views/inventory/inventory-tracking.jsp").forward(request, response);
                return;
            }

            request.setAttribute("managedWarehouse", managedWarehouse);

            String q = request.getParameter("q");
            q = (q == null) ? "" : q.trim();

            List<Part> allParts = partDAO.findParts(q, managedWarehouse.getWarehouseId(), "ACTIVE");

            if ("/inventory/low-stock".equals(path)) {
                List<Part> lowStockParts = new ArrayList<>();
                for (Part part : allParts) {
                    if (part.getQuantity() <= part.getMinQuantity()) {
                        lowStockParts.add(part);
                    }
                }
                request.setAttribute("parts", lowStockParts);
                request.setAttribute("q", q);
                request.getRequestDispatcher("/views/inventory/low-stock.jsp").forward(request, response);
            } else {
                request.setAttribute("parts", allParts);
                request.setAttribute("q", q);
                request.getRequestDispatcher("/views/inventory/inventory-tracking.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải dữ liệu tồn kho: " + e.getMessage());
            request.getRequestDispatcher("/views/inventory/inventory-tracking.jsp").forward(request, response);
        }
    }
}
