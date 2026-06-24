package controller;

import dao.SupplierDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Supplier;
import model.User;

@WebServlet(name = "SupplierManagementServlet", urlPatterns = {
    "/suppliers",
    "/suppliers/create",
    "/suppliers/update",
    "/suppliers/status",
    "/suppliers/delete"
})
public class SupplierManagementServlet extends HttpServlet {

    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireAuthorizedRole(request, response);
        if (currentUser == null) {
            return;
        }

        try {
            String q = trim(request.getParameter("q"));
            String status = trim(request.getParameter("status"));
            List<Supplier> suppliers = supplierDAO.findSuppliers(q, status);

            request.setAttribute("suppliers", suppliers);
            request.setAttribute("q", q);
            request.setAttribute("statusFilter", status);
            request.getRequestDispatcher("/views/supplier/supplier-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "system_error");
            request.getRequestDispatcher("/views/supplier/supplier-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireAuthorizedRole(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/suppliers/create".equals(path)) {
                createSupplier(request, response);
            } else if ("/suppliers/update".equals(path)) {
                updateSupplier(request, response);
            } else if ("/suppliers/status".equals(path)) {
                updateSupplierStatus(request, response);
            } else if ("/suppliers/delete".equals(path)) {
                deleteSupplier(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/suppliers");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/suppliers?error=system_error");
        }
    }

    private void createSupplier(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String supplierName = trim(request.getParameter("supplierName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String address = trim(request.getParameter("address"));
        String status = trim(request.getParameter("status"));

        if (supplierName == null || supplierName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=missing_required");
            return;
        }

        if (supplierDAO.isEmailUsedByAnotherSupplier(email, 0)) {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=email_exists");
            return;
        }

        Supplier supplier = new Supplier();
        supplier.setSupplierName(supplierName);
        supplier.setPhone(phone);
        supplier.setEmail(email);
        supplier.setAddress(address);
        supplier.setStatus(status == null || status.isEmpty() ? "ACTIVE" : status);

        int id = supplierDAO.insert(supplier);
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/suppliers?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=create_failed");
        }
    }

    private void updateSupplier(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer supplierId = parseInt(request.getParameter("supplierId"));
        String supplierName = trim(request.getParameter("supplierName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String address = trim(request.getParameter("address"));
        String status = trim(request.getParameter("status"));

        if (supplierId == null || supplierName == null || supplierName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=missing_required");
            return;
        }

        Supplier existing = supplierDAO.findById(supplierId);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=not_found");
            return;
        }

        if (supplierDAO.isEmailUsedByAnotherSupplier(email, supplierId)) {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=email_exists");
            return;
        }

        existing.setSupplierName(supplierName);
        existing.setPhone(phone);
        existing.setEmail(email);
        existing.setAddress(address);
        existing.setStatus(status == null || status.isEmpty() ? "ACTIVE" : status);

        boolean success = supplierDAO.update(existing);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/suppliers?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=update_failed");
        }
    }

    private void updateSupplierStatus(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer supplierId = parseInt(request.getParameter("supplierId"));
        String status = trim(request.getParameter("status"));

        if (supplierId == null || (!"ACTIVE".equals(status) && !"INACTIVE".equals(status))) {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=invalid_status");
            return;
        }

        boolean success = supplierDAO.updateStatus(supplierId, status);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/suppliers?success=status_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=update_failed");
        }
    }

    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Integer supplierId = parseInt(request.getParameter("supplierId"));
        if (supplierId == null) {
            response.sendRedirect(request.getContextPath() + "/suppliers");
            return;
        }

        boolean success = supplierDAO.delete(supplierId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/suppliers?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/suppliers?error=delete_failed");
        }
    }

    private User requireAuthorizedRole(HttpServletRequest request, HttpServletResponse response)
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
