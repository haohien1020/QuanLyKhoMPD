package controller.admin;

import dao.ActivityLogDAO;
import dao.DashboardDAO;
import dao.GeneratorDAO;
import dao.NotificationDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.ActivityLog;
import model.Generator;
import model.Notification;
import model.User;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/admin/dashboard", "/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final ActivityLogDAO activityLogDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        if ("/dashboard".equals(request.getServletPath())) {
            redirectHomeByRole(request, response, currentUser);
            return;
        }

        if (!currentUser.hasRole("ADMIN")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setAttribute("currentUser", currentUser);
        loadDashboardData(request);
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    private void redirectHomeByRole(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String contextPath = request.getContextPath();
        if (user.hasRole("ADMIN")) {
            response.sendRedirect(contextPath + "/admin/dashboard");
        } else if (user.hasRole("MANAGER")) {
            response.sendRedirect(contextPath + "/manager/home");
        } else if (user.hasRole("WAREHOUSE_MANAGER")) {
            response.sendRedirect(contextPath + "/warehouse/dashboard");
        } else if (user.hasRole("STAFF")) {
            response.sendRedirect(contextPath + "/staff/home");
        } else if (user.hasRole("SELLER")) {
            response.sendRedirect(contextPath + "/seller/home");
        } else {
            response.sendRedirect(contextPath + "/profile");
        }
    }

    private void loadDashboardData(HttpServletRequest request) {
        try {
            request.setAttribute("totalUsers", dashboardDAO.count("users"));
            request.setAttribute("activeUsers", dashboardDAO.countWhere("users", "status = 'ACTIVE'"));
            request.setAttribute("totalRoles", dashboardDAO.count("roles"));
            request.setAttribute("activeRoles", dashboardDAO.countWhere("roles", "status = 'ACTIVE'"));

            request.setAttribute("totalWarehouses", dashboardDAO.count("warehouses"));
            request.setAttribute("totalSuppliers", dashboardDAO.count("suppliers"));
            request.setAttribute("totalGenerators", dashboardDAO.count("generators"));
            request.setAttribute("inStockGenerators", dashboardDAO.countWhere("generators", "status = 'IN_STOCK'"));
            request.setAttribute("damagedGenerators", dashboardDAO.countWhere("generators", "status = 'DAMAGED'"));

            request.setAttribute("totalParts", dashboardDAO.count("parts"));
            request.setAttribute("lowStockParts", dashboardDAO.countWhere("parts", "quantity <= min_quantity"));
            request.setAttribute("inventoryTransactions", dashboardDAO.count("inventory_transactions"));
            request.setAttribute("pendingTransfers", dashboardDAO.countWhere("stock_transfers", "status = 'PENDING'"));

            request.setAttribute("pendingWork", dashboardDAO.countPendingWork());

            request.setAttribute("unreadNotifications", dashboardDAO.countWhere("notifications", "is_read = 0"));
            request.setAttribute("totalReports", dashboardDAO.count("report_exports"));
            request.setAttribute("activityLogs", dashboardDAO.count("activity_logs"));

            request.setAttribute("recentGenerators", firstItems(generatorDAO.findAll(), 5));
            request.setAttribute("recentNotifications", firstItems(notificationDAO.findAll(), 5));
            request.setAttribute("recentLogs", firstItems(activityLogDAO.findAll(), 5));
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("dashboardError", "Dashboard data could not be loaded. Please check database connectivity.");
        }
    }

    private <T> List<T> firstItems(List<T> items, int limit) {
        if (items == null || items.isEmpty()) {
            return new ArrayList<T>();
        }
        return items.subList(0, Math.min(limit, items.size()));
    }
}
