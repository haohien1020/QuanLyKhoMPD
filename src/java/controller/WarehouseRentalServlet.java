package controller;

import dao.GeneratorDAO;
import dao.InventoryTransactionDAO;
import dao.RentalContractDAO;
import dao.UserDAO;
import dao.WarehouseDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.CustomerRentalContract;
import model.CustomerRentedGenerator;
import model.Generator;
import model.InventoryTransaction;
import model.User;
import model.Warehouse;

@WebServlet(name = "WarehouseRentalServlet", urlPatterns = {
    "/warehouse/rentals",
    "/warehouse/rentals/action"
})
public class WarehouseRentalServlet extends HttpServlet {

    private final RentalContractDAO rentalContractDAO = new RentalContractDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final UserDAO userDAO = new UserDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();
    private final InventoryTransactionDAO inventoryTransactionDAO = new InventoryTransactionDAO();

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
        String action = request.getParameter("action");

        try {
            Warehouse managedWarehouse = warehouseDAO.findWarehouseByManager(currentUser.getUserId());
            if (managedWarehouse == null) {
                request.setAttribute("error", "Tài khoản của bạn chưa được chỉ định quản lý kho nào.");
                request.getRequestDispatcher("/views/home/warehouse-home.jsp").forward(request, response);
                return;
            }
            request.setAttribute("managedWarehouse", managedWarehouse);

            if ("/warehouse/rentals/action".equals(path) && "assign-staff".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                List<CustomerRentedGenerator> items = rentalContractDAO.getGeneratorsForContract(contractId);
                List<User> staffList = userDAO.findUsersByRoleName("STAFF");

                request.setAttribute("contract", contract);
                request.setAttribute("items", items);
                request.setAttribute("staffList", staffList);
                request.getRequestDispatcher("/views/maintenance/assign-task.jsp").forward(request, response);
            } else {
                List<CustomerRentalContract> list = rentalContractDAO.findContractsByWarehouse(managedWarehouse.getWarehouseId());
                request.setAttribute("contracts", list);
                request.getRequestDispatcher("/views/rental/rental-request-list.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/views/rental/rental-request-list.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        try {
            if ("assign-staff".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                int generatorId = Integer.parseInt(request.getParameter("generatorId"));
                int staffId = Integer.parseInt(request.getParameter("staffId"));
                String issue = request.getParameter("issueDescription");

                boolean success = rentalContractDAO.assignStaffToCheck(generatorId, currentUser.getUserId(), staffId, issue);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?success=staff_assigned");
                } else {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals/action?action=assign-staff&contractId=" + contractId + "&error=failed");
                }
            } else if ("approve".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                boolean success = rentalContractDAO.updateContractStatus(contractId, "APPROVED", currentUser.getUserId());
                if (success) {
                    try {
                        model.CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                        if (contract != null) {
                            model.Customer customer = new dao.CustomerDAO().findById(contract.getCustomerId());
                            List<model.CustomerRentedGenerator> gens = rentalContractDAO.getGeneratorsForContract(contractId);
                            if (customer != null && customer.getEmail() != null && !customer.getEmail().trim().isEmpty() && !gens.isEmpty()) {
                                model.CustomerRentedGenerator cg = gens.get(0);
                                model.Generator generator = generatorDAO.findById(cg.getGeneratorId());
                                model.Warehouse warehouse = warehouseDAO.findById(contract.getWarehouseId());
                                if (generator != null && warehouse != null) {
                                    util.EmailUtil.sendContractApprovedEmailAsync(customer, generator, warehouse, contract, cg.getRentalPrice().doubleValue());
                                }
                            }
                        }
                    } catch (Exception ex) {
                        System.err.println("Failed to initiate contract approval email: " + ex.getMessage());
                        ex.printStackTrace();
                    }
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?success=approved");
                } else {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=approve_failed");
                }
            } else if ("deliver".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                List<CustomerRentedGenerator> gens = rentalContractDAO.getGeneratorsForContract(contractId);

                boolean success = rentalContractDAO.updateContractStatus(contractId, "DELIVERED", currentUser.getUserId());
                if (success) {
                    for (CustomerRentedGenerator cg : gens) {
                        Generator generator = generatorDAO.findById(cg.getGeneratorId());
                        if (generator != null) {
                            generator.setStatus("EXPORTED");
                            generatorDAO.update(generator);

                            // Create Inventory transaction log
                            InventoryTransaction tx = new InventoryTransaction();
                            tx.setWarehouseId(generator.getWarehouseId());
                            tx.setCreatedBy(currentUser.getUserId());
                            tx.setTransactionType("EXPORT");
                            tx.setItemType("GENERATOR");
                            tx.setGeneratorId(generator.getGeneratorId());
                            tx.setQuantity(1);
                            tx.setNote("Xuất kho cho thuê - Hợp đồng: " + contract.getContractCode());
                            tx.setStatus("COMPLETED");
                            inventoryTransactionDAO.insert(tx);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?success=delivered");
                } else {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=deliver_failed");
                }
            } else if ("return".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                List<CustomerRentedGenerator> gens = rentalContractDAO.getGeneratorsForContract(contractId);

                boolean success = rentalContractDAO.updateContractStatus(contractId, "COMPLETED", currentUser.getUserId());
                if (success) {
                    for (CustomerRentedGenerator cg : gens) {
                        Generator generator = generatorDAO.findById(cg.getGeneratorId());
                        if (generator != null) {
                            generator.setStatus("IN_STOCK");
                            generatorDAO.update(generator);

                            // Create Inventory transaction log
                            InventoryTransaction tx = new InventoryTransaction();
                            tx.setWarehouseId(generator.getWarehouseId());
                            tx.setCreatedBy(currentUser.getUserId());
                            tx.setTransactionType("IMPORT");
                            tx.setItemType("GENERATOR");
                            tx.setGeneratorId(generator.getGeneratorId());
                            tx.setQuantity(1);
                            tx.setNote("Nhập lại kho từ khách thuê - Hợp đồng: " + contract.getContractCode());
                            tx.setStatus("COMPLETED");
                            inventoryTransactionDAO.insert(tx);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?success=returned");
                } else {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=return_failed");
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=system_error");
        }
    }
}
