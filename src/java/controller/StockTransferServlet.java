package controller;

import dao.GeneratorDAO;
import dao.PartDAO;
import dao.StockTransferDAO;
import dao.StockTransferDetailDAO;
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
import model.Generator;
import model.Part;
import model.StockTransfer;
import model.StockTransferDetail;
import model.User;
import model.Warehouse;

@WebServlet(name = "StockTransferServlet", urlPatterns = {
    "/stock-transfers",
    "/stock-transfers/create"
})
public class StockTransferServlet extends HttpServlet {

    private final StockTransferDAO stockTransferDAO = new StockTransferDAO();
    private final StockTransferDetailDAO stockTransferDetailDAO = new StockTransferDetailDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();
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

            if ("/stock-transfers/create".equals(path)) {
                if (managedWarehouse == null) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Chỉ Thủ kho được tạo yêu cầu điều chuyển.");
                    return;
                }
                List<Warehouse> allWarehouses = warehouseDAO.findAll();
                List<Warehouse> destWarehouses = new ArrayList<>();
                for (Warehouse w : allWarehouses) {
                    if (w.getWarehouseId() != managedWarehouse.getWarehouseId() && "ACTIVE".equals(w.getStatus())) {
                        destWarehouses.add(w);
                    }
                }
                List<Generator> generators = generatorDAO.findGenerators("", managedWarehouse.getWarehouseId(), "IN_STOCK");
                List<Part> parts = partDAO.findParts("", managedWarehouse.getWarehouseId(), "ACTIVE");

                request.setAttribute("destWarehouses", destWarehouses);
                request.setAttribute("generators", generators);
                request.setAttribute("parts", parts);
                request.getRequestDispatcher("/views/transfer/stock-transfer-create.jsp").forward(request, response);
            } else {
                List<StockTransfer> list;
                if (currentUser.hasRole("WAREHOUSE_MANAGER")) {
                    list = stockTransferDAO.findTransfersByWarehouse(managedWarehouse.getWarehouseId());
                } else {
                    list = stockTransferDAO.findAll();
                }
                request.setAttribute("transfers", list);
                request.getRequestDispatcher("/views/transfer/stock-transfer-list.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải trang: " + e.getMessage());
            request.getRequestDispatcher("/views/transfer/stock-transfer-list.jsp").forward(request, response);
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
        if ("/stock-transfers/create".equals(path)) {
            try {
                Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
                if (managedWarehouse == null) {
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?error=no_warehouse");
                    return;
                }

                int toWarehouseId = Integer.parseInt(request.getParameter("toWarehouseId"));
                String itemType = request.getParameter("itemType"); // GENERATOR or PART

                StockTransfer st = new StockTransfer();
                st.setFromWarehouseId(managedWarehouse.getWarehouseId());
                st.setToWarehouseId(toWarehouseId);
                st.setCreatedBy(currentUser.getUserId());
                st.setStatus("PENDING");

                int transferId = stockTransferDAO.insert(st);
                if (transferId > 0) {
                    if ("GENERATOR".equals(itemType)) {
                        String[] generatorIds = request.getParameterValues("generatorId");
                        if (generatorIds != null) {
                            for (String gIdStr : generatorIds) {
                                if (gIdStr.isEmpty()) continue;
                                int gId = Integer.parseInt(gIdStr);
                                StockTransferDetail std = new StockTransferDetail();
                                std.setTransferId(transferId);
                                std.setItemType("GENERATOR");
                                std.setGeneratorId(gId);
                                std.setPartId(null);
                                std.setQuantity(1);
                                stockTransferDetailDAO.insert(std);
                            }
                        }
                    } else {
                        String[] partIds = request.getParameterValues("partId");
                        String[] quantities = request.getParameterValues("quantity");
                        if (partIds != null && quantities != null) {
                            for (int i = 0; i < partIds.length; i++) {
                                if (partIds[i].isEmpty()) continue;
                                int pId = Integer.parseInt(partIds[i]);
                                int qty = Integer.parseInt(quantities[i]);

                                StockTransferDetail std = new StockTransferDetail();
                                std.setTransferId(transferId);
                                std.setItemType("PART");
                                std.setGeneratorId(null);
                                std.setPartId(pId);
                                std.setQuantity(qty);
                                stockTransferDetailDAO.insert(std);
                            }
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/stock-transfers?success=created");
                } else {
                    response.sendRedirect(request.getContextPath() + "/stock-transfers/create?error=failed");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/stock-transfers/create?error=system_error");
            }
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }
}
