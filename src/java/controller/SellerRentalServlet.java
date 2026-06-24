package controller;

import dao.CustomerDAO;
import dao.GeneratorDAO;
import dao.RentalContractDAO;
import dao.WarehouseDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import model.Customer;
import model.CustomerRentalContract;
import model.CustomerRentedGenerator;
import model.Generator;
import model.GroupedGeneratorInventory;
import model.User;
import model.Warehouse;

@WebServlet(name = "SellerRentalServlet", urlPatterns = {
    "/seller/contracts",
    "/seller/contracts/create",
    "/seller/contracts/update"
})
public class SellerRentalServlet extends HttpServlet {

    private final RentalContractDAO rentalContractDAO = new RentalContractDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final GeneratorDAO generatorDAO = new GeneratorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = requireSeller(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/seller/contracts/create".equals(path)) {
                showCreateForm(request, response, currentUser);
            } else if ("/seller/contracts/update".equals(path)) {
                showUpdateForm(request, response, currentUser);
            } else {
                showList(request, response, currentUser);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                showList(request, response, currentUser);
            } catch (Exception ex) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = requireSeller(request, response);
        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/seller/contracts/create".equals(path)) {
                createContract(request, response, currentUser);
            } else if ("/seller/contracts/update".equals(path)) {
                updateContract(request, response, currentUser);
            } else {
                response.sendRedirect(request.getContextPath() + "/seller/contracts");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/seller/contracts?error=system_error");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, User currentUser) throws Exception {
        Integer sellerWarehouseId = currentUser.getWarehouseId();
        List<CustomerRentalContract> list;
        if (sellerWarehouseId != null) {
            list = rentalContractDAO.findContractsByWarehouse(sellerWarehouseId);
        } else {
            list = new java.util.ArrayList<>();
        }
        request.setAttribute("contracts", list);
        request.getRequestDispatcher("/views/rental/seller-contract-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, User currentUser) throws Exception {
        List<Customer> customers = customerDAO.findCustomers(null, "ACTIVE");
        
        Integer sellerWarehouseId = currentUser.getWarehouseId();
        List<Warehouse> warehouses = new java.util.ArrayList<>();
        if (sellerWarehouseId != null) {
            Warehouse w = warehouseDAO.findById(sellerWarehouseId);
            if (w != null) {
                warehouses.add(w);
            }
        }

        List<Generator> generators = new java.util.ArrayList<>();
        List<GroupedGeneratorInventory> groupedInventories = new java.util.ArrayList<>();
        if (sellerWarehouseId != null) {
            generators = generatorDAO.findAvailableUnitsForRent(sellerWarehouseId);
            groupedInventories = generatorDAO.findGroupedInventory(sellerWarehouseId);
        }

        request.setAttribute("customers", customers);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("generators", generators);
        request.setAttribute("groupedInventories", groupedInventories);
        request.getRequestDispatcher("/views/rental/seller-contract-create.jsp").forward(request, response);
    }

    private void showUpdateForm(HttpServletRequest request, HttpServletResponse response, User currentUser) throws Exception {
        int contractId = Integer.parseInt(request.getParameter("contractId"));
        CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
        if (contract == null) {
            response.sendRedirect(request.getContextPath() + "/seller/contracts?error=not_found");
            return;
        }

        Integer sellerWarehouseId = currentUser.getWarehouseId();
        if (sellerWarehouseId == null || contract.getWarehouseId() != sellerWarehouseId) {
            response.sendRedirect(request.getContextPath() + "/seller/contracts?error=invalid_warehouse");
            return;
        }

        List<CustomerRentedGenerator> currentGenerators = rentalContractDAO.getGeneratorsForContract(contractId);
        List<Customer> customers = customerDAO.findCustomers(null, "ACTIVE");
        
        List<Warehouse> warehouses = new java.util.ArrayList<>();
        Warehouse w = warehouseDAO.findById(sellerWarehouseId);
        if (w != null) {
            warehouses.add(w);
        }

        List<Generator> generators = generatorDAO.findAvailableUnitsForRent(sellerWarehouseId);
        List<GroupedGeneratorInventory> groupedInventories = new java.util.ArrayList<>();
        if (sellerWarehouseId != null) {
            groupedInventories = generatorDAO.findGroupedInventory(sellerWarehouseId);
        }

        // Include current generator in option list even if it is not IN_STOCK
        if (!currentGenerators.isEmpty()) {
            int currentGenId = currentGenerators.get(0).getGeneratorId();
            boolean exists = false;
            for (Generator g : generators) {
                if (g.getGeneratorId() == currentGenId) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                Generator currentGen = generatorDAO.findById(currentGenId);
                if (currentGen != null) {
                    generators.add(0, currentGen);
                }
            }
            request.setAttribute("currentGenId", currentGenId);
            request.setAttribute("rentalPrice", currentGenerators.get(0).getRentalPrice());
        }

        request.setAttribute("contract", contract);
        request.setAttribute("customers", customers);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("generators", generators);
        request.setAttribute("groupedInventories", groupedInventories);
        request.getRequestDispatcher("/views/rental/seller-contract-update.jsp").forward(request, response);
    }

    private void createContract(HttpServletRequest request, HttpServletResponse response, User currentUser) throws Exception {
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        int warehouseId = Integer.parseInt(request.getParameter("warehouseId"));
        int generatorId = Integer.parseInt(request.getParameter("generatorId"));
        Timestamp startDate = parseDate(request.getParameter("startDate"));
        Timestamp expectedReturnDate = parseDate(request.getParameter("expectedReturnDate"));
        double depositAmount = parseDouble(request.getParameter("depositAmount"));
        double totalAmount = parseDouble(request.getParameter("totalAmount"));
        double rentalPrice = parseDouble(request.getParameter("rentalPrice"));
        String note = request.getParameter("note");

        Integer sellerWarehouseId = currentUser.getWarehouseId();
        if (sellerWarehouseId == null || warehouseId != sellerWarehouseId) {
            response.sendRedirect(request.getContextPath() + "/seller/contracts/create?error=invalid_warehouse");
            return;
        }

        String contractCode = "CTR-SEL-" + System.currentTimeMillis();

        int contractId = rentalContractDAO.createContract(customerId, warehouseId, currentUser.getUserId(),
                contractCode, startDate, expectedReturnDate, depositAmount, totalAmount, note, generatorId, rentalPrice);

        if (contractId > 0) {
            try {
                Customer customer = customerDAO.findById(customerId);
                Generator generator = generatorDAO.findById(generatorId);
                Warehouse warehouse = warehouseDAO.findById(warehouseId);
                CustomerRentalContract contract = rentalContractDAO.findContractById(contractId);
                
                if (customer != null && customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) {
                    util.EmailUtil.sendContractEmailAsync(customer, generator, warehouse, contract, currentUser, rentalPrice);
                }
            } catch (Exception ex) {
                System.err.println("Failed to initiate contract email sending: " + ex.getMessage());
                ex.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/seller/contracts?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/seller/contracts/create?error=create_failed");
        }
    }

    private void updateContract(HttpServletRequest request, HttpServletResponse response, User currentUser) throws Exception {
        int contractId = Integer.parseInt(request.getParameter("contractId"));
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        int warehouseId = Integer.parseInt(request.getParameter("warehouseId"));
        int generatorId = Integer.parseInt(request.getParameter("generatorId"));
        Timestamp startDate = parseDate(request.getParameter("startDate"));
        Timestamp expectedReturnDate = parseDate(request.getParameter("expectedReturnDate"));
        double depositAmount = parseDouble(request.getParameter("depositAmount"));
        double totalAmount = parseDouble(request.getParameter("totalAmount"));
        double rentalPrice = parseDouble(request.getParameter("rentalPrice"));
        String note = request.getParameter("note");

        Integer sellerWarehouseId = currentUser.getWarehouseId();
        if (sellerWarehouseId == null || warehouseId != sellerWarehouseId) {
            response.sendRedirect(request.getContextPath() + "/seller/contracts/update?contractId=" + contractId + "&error=invalid_warehouse");
            return;
        }

        boolean success = rentalContractDAO.updateContract(contractId, customerId, warehouseId, startDate,
                expectedReturnDate, depositAmount, totalAmount, note, generatorId, rentalPrice);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/seller/contracts?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/seller/contracts/update?contractId=" + contractId + "&error=update_failed");
        }
    }

    private User requireSeller(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }
        if (!currentUser.hasRole("SELLER")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return currentUser;
    }

    private Timestamp parseDate(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date date = sdf.parse(value.trim());
            return new Timestamp(date.getTime());
        } catch (Exception ex) {
            return null;
        }
    }

    private double parseDouble(String value) {
        try {
            return value == null || value.trim().isEmpty() ? 0.0 : Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return 0.0;
        }
    }
}
