package controller;

import dao.PartDAO;
import dao.PurchaseRequestDAO;
import dao.PurchaseRequestDetailDAO;
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
import model.PurchaseRequest;
import model.PurchaseRequestDetail;
import model.User;
import model.Warehouse;

@WebServlet(name = "PurchaseRequestServlet", urlPatterns = {
        "/purchase-requests",
        "/purchase-requests/create"
})
public class PurchaseRequestServlet extends HttpServlet {

    private final PurchaseRequestDAO purchaseRequestDAO = new PurchaseRequestDAO();
    private final PurchaseRequestDetailDAO purchaseRequestDetailDAO = new PurchaseRequestDetailDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final PartDAO partDAO = new PartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        if (!currentUser.hasRole("WAREHOUSE_MANAGER") && !currentUser.hasRole("MANAGER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();

        try {
            // Find managed warehouse if user is WAREHOUSE_MANAGER
            Warehouse managedWarehouse = null;
            if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null) {
                    request.setAttribute("error", "Tài khoản của bạn chưa được chỉ định quản lý kho nào.");
                    request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
                    return;
                }
                request.setAttribute("managedWarehouse", managedWarehouse);
            }

            if ("/purchase-requests/create".equals(path)) {
                if (managedWarehouse == null) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Chỉ Thủ kho được tạo yêu cầu mua hàng.");
                    return;
                }
                List<Part> parts = partDAO.findParts("", managedWarehouse.getWarehouseId(), "ACTIVE");
                request.setAttribute("parts", parts);
                request.getRequestDispatcher("/views/purchase/purchase-request-create.jsp").forward(request, response);
            } else {
                List<PurchaseRequest> list;
                if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                    list = purchaseRequestDAO.findRequestsByWarehouse(managedWarehouse.getWarehouseId());
                } else {
                    list = purchaseRequestDAO.findAll();
                }
                request.setAttribute("requests", list);
                request.getRequestDispatcher("/views/purchase/purchase-request-list.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải trang: " + e.getMessage());
            request.getRequestDispatcher("/views/purchase/purchase-request-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
        if ("/purchase-requests/create".equals(path)) {
            try {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null) {
                    response.sendRedirect(request.getContextPath() + "/purchase-requests?error=no_warehouse");
                    return;
                }

                String reason = request.getParameter("reason");
                String[] partIds = request.getParameterValues("partId");
                String[] itemNames = request.getParameterValues("itemName");
                String[] quantities = request.getParameterValues("quantity");

                if (quantities == null || quantities.length == 0) {
                    response.sendRedirect(request.getContextPath() + "/purchase-requests/create?error=empty_items");
                    return;
                }

                PurchaseRequest pr = new PurchaseRequest();
                pr.setWarehouseId(managedWarehouse.getWarehouseId());
                pr.setRequestedBy(currentUser.getUserId());
                pr.setReason(reason == null ? "" : reason.trim());
                pr.setStatus("PENDING");

                int prId = purchaseRequestDAO.insert(pr);
                if (prId > 0) {
                    for (int i = 0; i < quantities.length; i++) {
                        int qty = Integer.parseInt(quantities[i]);
                        Integer pId = null;
                        if (partIds != null && i < partIds.length && !partIds[i].isEmpty()) {
                            pId = Integer.parseInt(partIds[i]);
                        }
                        String name = (itemNames != null && i < itemNames.length) ? itemNames[i] : "";

                        PurchaseRequestDetail prd = new PurchaseRequestDetail();
                        prd.setPurchaseRequestId(prId);
                        prd.setPartId(pId);
                        prd.setItemName(name);
                        prd.setQuantity(qty);

                        purchaseRequestDetailDAO.insert(prd);
                    }
                    response.sendRedirect(request.getContextPath() + "/purchase-requests?success=created");
                } else {
                    response.sendRedirect(request.getContextPath() + "/purchase-requests/create?error=failed");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/purchase-requests/create?error=system_error");
            }
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }
}
