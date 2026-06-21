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
import model.User;
import model.Warehouse;

@WebServlet(name = "PartServlet", urlPatterns = {
    "/parts",
    "/parts/create",
    "/parts/update",
    "/parts/delete"
})
public class PartServlet extends HttpServlet {

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

        try {
            String q = request.getParameter("q");
            q = (q == null) ? "" : q.trim();

            Integer warehouseId = null;
            String whParam = request.getParameter("warehouseId");
            if (whParam != null && !whParam.trim().isEmpty()) {
                warehouseId = Integer.parseInt(whParam.trim());
            }

            String status = request.getParameter("status");
            status = (status == null) ? "" : status.trim();

            // Warehouse Manager can only see/filter within their managed warehouse by default
            Warehouse managedWarehouse = null;
            if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse != null) {
                    warehouseId = managedWarehouse.getWarehouseId();
                    request.setAttribute("managedWarehouse", managedWarehouse);
                }
            }

            List<Part> parts = partDAO.findParts(q, warehouseId, status);
            List<Warehouse> warehouses = warehouseDAO.findAll();

            request.setAttribute("parts", parts);
            request.setAttribute("warehouses", warehouses);
            request.setAttribute("q", q);
            request.setAttribute("warehouseIdFilter", warehouseId);
            request.setAttribute("statusFilter", status);

            request.getRequestDispatcher("/views/part/part-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải danh sách phụ tùng: " + e.getMessage());
            request.getRequestDispatcher("/views/part/part-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

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
            if ("/parts/create".equals(path)) {
                createPart(request, response, currentUser);
            } else if ("/parts/update".equals(path)) {
                updatePart(request, response);
            } else if ("/parts/delete".equals(path)) {
                deletePart(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/parts");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/parts?error=system_error");
        }
    }

    private void createPart(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws Exception {
        Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
        if (managedWarehouse == null) {
            response.sendRedirect(request.getContextPath() + "/parts?error=no_warehouse");
            return;
        }

        String partName = request.getParameter("partName");
        String partCode = request.getParameter("partCode");
        String qtyStr = request.getParameter("quantity");
        String minQtyStr = request.getParameter("minQuantity");
        String unit = request.getParameter("unit");
        String status = request.getParameter("status");

        if (partName == null || partName.trim().isEmpty() || partCode == null || partCode.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/parts?error=missing_required");
            return;
        }

        if (partDAO.isPartCodeUsed(partCode, 0)) {
            response.sendRedirect(request.getContextPath() + "/parts?error=code_exists");
            return;
        }

        int qty = (qtyStr == null || qtyStr.trim().isEmpty()) ? 0 : Integer.parseInt(qtyStr.trim());
        int minQty = (minQtyStr == null || minQtyStr.trim().isEmpty()) ? 0 : Integer.parseInt(minQtyStr.trim());

        Part p = new Part();
        p.setWarehouseId(managedWarehouse.getWarehouseId());
        p.setPartName(partName.trim());
        p.setPartCode(partCode.trim());
        p.setQuantity(qty);
        p.setMinQuantity(minQty);
        p.setUnit(unit == null ? "Cai" : unit.trim());
        p.setStatus(status == null ? "ACTIVE" : status.trim());

        int id = partDAO.insert(p);
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/parts?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/parts?error=create_failed");
        }
    }

    private void updatePart(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer partId = Integer.parseInt(request.getParameter("partId"));
        String partName = request.getParameter("partName");
        String partCode = request.getParameter("partCode");
        String qtyStr = request.getParameter("quantity");
        String minQtyStr = request.getParameter("minQuantity");
        String unit = request.getParameter("unit");
        String status = request.getParameter("status");

        if (partName == null || partName.trim().isEmpty() || partCode == null || partCode.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/parts?error=missing_required");
            return;
        }

        Part existing = partDAO.findById(partId);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/parts?error=not_found");
            return;
        }

        if (partDAO.isPartCodeUsed(partCode, partId)) {
            response.sendRedirect(request.getContextPath() + "/parts?error=code_exists");
            return;
        }

        int qty = (qtyStr == null || qtyStr.trim().isEmpty()) ? 0 : Integer.parseInt(qtyStr.trim());
        int minQty = (minQtyStr == null || minQtyStr.trim().isEmpty()) ? 0 : Integer.parseInt(minQtyStr.trim());

        existing.setPartName(partName.trim());
        existing.setPartCode(partCode.trim());
        existing.setQuantity(qty);
        existing.setMinQuantity(minQty);
        existing.setUnit(unit == null ? "Cai" : unit.trim());
        existing.setStatus(status == null ? "ACTIVE" : status.trim());

        boolean success = partDAO.update(existing);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/parts?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/parts?error=update_failed");
        }
    }

    private void deletePart(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer partId = Integer.parseInt(request.getParameter("partId"));
        boolean success = partDAO.delete(partId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/parts?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/parts?error=delete_failed");
        }
    }
}
