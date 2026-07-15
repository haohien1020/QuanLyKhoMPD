package controller;

import dao.GeneratorDAO;
import dao.InventoryTransactionDAO;
import dao.NotificationDAO;
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
import model.Notification;
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

            if ("assign-staff".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                List<User> staffList = userDAO.findStaffByWarehouse(managedWarehouse.getWarehouseId());
                request.setAttribute("staffList", staffList);
                request.setAttribute("assignContractId", contractId);
                CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                request.setAttribute("assignContract", contract);
            }

            List<CustomerRentalContract> list = rentalContractDAO.findContractsByWarehouse(managedWarehouse.getWarehouseId());
            request.setAttribute("contracts", list);
            request.getRequestDispatcher("/views/rental/rental-request-list.jsp").forward(request, response);

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
            if ("approve".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                model.CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                if (contract == null || contract.getAssignedStaffId() == null || contract.getAssignedStaffId() == 0) {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=no_staff_assigned");
                    return;
                }
                boolean success = rentalContractDAO.updateContractStatus(contractId, "APPROVED", currentUser.getUserId());
                if (success) {
                    // Auto-grant Import Inventory permission to the assigned staff if they don't have it
                    try {
                        int staffId = contract.getAssignedStaffId();
                        User staff = userDAO.findById(staffId);
                        if (staff != null && !staff.isCanImportInventory()) {
                            userDAO.updateImportInventoryPermission(staffId, true);
                        }
                    } catch (Exception ex) {
                        System.err.println("Failed to auto-grant Import Inventory permission to staff " + contract.getAssignedStaffId() + ": " + ex.getMessage());
                        ex.printStackTrace();
                    }

                    try {
                        contract = rentalContractDAO.findContractById(contractId);
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
            } else if ("reject".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                if (contract != null) {
                    boolean success = rentalContractDAO.updateContractStatus(contractId, "REJECTED", currentUser.getUserId());
                    if (success) {
                        // Rollback generator barcode / unit statuses to IN_STOCK
                        try {
                            List<CustomerRentedGenerator> gens = rentalContractDAO.getGeneratorsForContract(contractId);
                            for (CustomerRentedGenerator cg : gens) {
                                if (cg.getSerialNumber() != null && !cg.getSerialNumber().isEmpty()) {
                                    String[] serials = cg.getSerialNumber().split(",");
                                    for (String s : serials) {
                                        s = s.trim();
                                        if (!s.isEmpty()) {
                                            generatorDAO.updateBarcodeStatus(s, "IN_STOCK");
                                        }
                                    }
                                }
                                Generator g = generatorDAO.findById(cg.getGeneratorId());
                                if (g != null && "EXPORTED".equals(g.getStatus())) {
                                    g.setStatus("IN_STOCK");
                                    generatorDAO.update(g);
                                }
                            }
                        } catch (Exception ex) {
                            System.err.println("Failed to rollback generator statuses on rejection: " + ex.getMessage());
                        }

                        // Send cancellation notification to assigned staff if any
                        if (contract.getAssignedStaffId() != null && contract.getAssignedStaffId() > 0) {
                            try {
                                NotificationDAO notificationDAO = new NotificationDAO();
                                Notification notif = new Notification();
                                notif.setUserId(contract.getAssignedStaffId());
                                notif.setTitle("Hủy hợp đồng thuê máy");
                                notif.setMessage("Hợp đồng " + contract.getContractCode() + " đã bị từ chối/hủy. Bạn không cần thực hiện bàn giao hợp đồng này nữa.");
                                notif.setType("RENTAL");
                                notif.setRead(false);
                                notificationDAO.insert(notif);
                            } catch (Exception ex) {
                                System.err.println("Failed to send cancellation notification to staff: " + ex.getMessage());
                            }
                        }

                        response.sendRedirect(request.getContextPath() + "/warehouse/rentals?success=rejected");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=reject_failed");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=reject_failed");
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
            } else if ("assign-staff".equals(action)) {
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                int staffId = Integer.parseInt(request.getParameter("staffId"));
                
                boolean success = rentalContractDAO.assignStaff(contractId, staffId);
                if (success) {
                    try {
                        CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                        NotificationDAO notificationDAO = new NotificationDAO();
                        Notification notif = new Notification();
                        notif.setUserId(staffId);
                        notif.setTitle("Phân công Kiểm tra & Bàn giao máy");
                        notif.setMessage("Bạn đã được phân công thực hiện kiểm tra máy trước khi bàn giao và giao máy cho khách hàng theo Hợp đồng: " 
                                + (contract != null ? contract.getContractCode() : ("ID " + contractId)));
                        notif.setType("RENTAL");
                        notif.setRead(false);
                        notificationDAO.insert(notif);
                    } catch (Exception ex) {
                        System.err.println("Failed to send assignment notification: " + ex.getMessage());
                        ex.printStackTrace();
                    }
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?success=staff_assigned");
                } else {
                    response.sendRedirect(request.getContextPath() + "/warehouse/rentals?error=assign_failed");
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
