package controller;

import dao.GeneratorDAO;
import dao.WarehouseDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Generator;
import model.User;
import model.Warehouse;

@WebServlet(name = "WarehouseInventoryServlet", urlPatterns = {
    "/inventory/low-stock"
})
public class WarehouseInventoryServlet extends HttpServlet {

    private final GeneratorDAO generatorDAO = new GeneratorDAO();
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
                request.getRequestDispatcher("/views/inventory/low-stock.jsp").forward(request, response);
                return;
            }

            request.setAttribute("managedWarehouse", managedWarehouse);

            String q = request.getParameter("q");
            q = (q == null) ? "" : q.trim();

            if ("/inventory/low-stock".equals(path)) {
                List<Generator> lowStockGenerators = generatorDAO.findLowStockGenerators(managedWarehouse.getWarehouseId(), q);
                request.setAttribute("generators", lowStockGenerators);
                request.setAttribute("q", q);
                request.getRequestDispatcher("/views/inventory/low-stock.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải dữ liệu tồn kho: " + e.getMessage());
            request.getRequestDispatcher("/views/inventory/low-stock.jsp").forward(request, response);
        }
    }
}
