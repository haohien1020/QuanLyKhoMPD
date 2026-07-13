<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.Generator" %>
<%@ page import="model.Warehouse" %>
<%@ page import="model.Supplier" %>
<%@ page import="model.User" %>

<%
    @SuppressWarnings("unchecked")
    List<Generator> generators = (List<Generator>) request.getAttribute("generators");
    @SuppressWarnings("unchecked")
    List<Warehouse> warehouses = (List<Warehouse>) request.getAttribute("warehouses");
    @SuppressWarnings("unchecked")
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");

    String q = (String) request.getAttribute("q");
    Integer warehouseIdFilter = (Integer) request.getAttribute("warehouseIdFilter");
    String statusFilter = (String) request.getAttribute("statusFilter");
    
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");

    User currentUser = (User) session.getAttribute("currentUser");
    boolean isWarehouseManager = currentUser != null && currentUser.hasRole("WAREHOUSE_MANAGER");
    boolean isStaffWithImport = currentUser != null && currentUser.hasRole("STAFF") && currentUser.isCanImportGenerator();
    boolean canImportGenerator = isWarehouseManager || isStaffWithImport;
    boolean isSellerRestricted = Boolean.TRUE.equals(request.getAttribute("isSellerRestricted"));
    Integer sellerWarehouseId = (Integer) request.getAttribute("sellerWarehouseId");
    boolean isWarehouseRestricted = Boolean.TRUE.equals(request.getAttribute("isWarehouseRestricted"));
    Integer restrictedWarehouseId = (Integer) request.getAttribute("restrictedWarehouseId");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý máy phát điện | Generator Management System</title>

    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .table thead th {
            white-space: nowrap;
            vertical-align: middle !important;
            text-align: center;
        }
        .table tbody td {
            vertical-align: middle !important;
        }
        .text-nowrap {
            white-space: nowrap;
        }
        .generator-name-col {
            min-width: 180px;
            max-width: 250px;
        }
        @media (min-width: 992px) {
            .modal-lg {
                max-width: 1000px;
            }
        }
        .confirm-table td {
            padding: 6px 12px !important;
            border: none;
        }
    </style>
</head>

<body id="page-top">

<div id="wrapper">

    <%@ include file="/views/layout/sidebar.jsp" %>

    <div id="content-wrapper" class="d-flex flex-column">
        <div id="content">

            <%@ include file="/views/layout/topbar.jsp" %>

            <div class="container-fluid">

                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">
                        <i class="fas fa-bolt text-primary"></i>
                        <% if (isSellerRestricted) { %>
                            Máy phát điện trong kho của tôi
                        <% } else { %>
                            Quản lý máy phát điện
                        <% } %>
                    </h1>
                    <% if (canImportGenerator) { %>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Thêm mẫu máy phát điện mới
                    </button>
                    <% } else if (isSellerRestricted) { %>
                    <a href="${pageContext.request.contextPath}/seller/contracts/create" class="btn btn-success btn-sm">
                        <i class="fas fa-plus"></i> Lập hợp đồng thuê mới
                    </a>
                    <% } %>
                </div>

                <!-- Thông báo kết quả -->
                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Thêm mẫu máy phát điện mới thành công!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật thông tin máy phát điện thành công!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Xóa máy phát điện thành công!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("serial_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Số serial này đã tồn tại trong hệ thống. Vui lòng nhập mã duy nhất khác.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên máy phát điện này đã tồn tại trong hệ thống. Vui lòng nhập tên khác.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("missing_required".equals(errorParam)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> Vui lòng điền đầy đủ các thông tin bắt buộc (*).
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if (errorParam != null && !errorParam.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Có lỗi xảy ra trong quá trình thao tác. Vui lòng kiểm tra lại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <!-- Bộ lọc tìm kiếm -->
                <% if (isSellerRestricted) { %>
                <!-- Seller: hiển thị banner kho cố định thay cho dropdown -->
                <div class="alert mb-4" style="background:#eef4ff;border:1px solid #c7d8f8;border-left:4px solid #2563eb;border-radius:8px;padding:12px 18px">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-warehouse fa-lg mr-3" style="color:#2563eb"></i>
                        <div class="flex-grow-1">
                            <strong>Bạn đang xem máy phát điện thuộc kho của mình.</strong>
                            <% if (warehouses != null && !warehouses.isEmpty()) { %>
                            <span class="badge badge-primary ml-2"><%= warehouses.get(0).getWarehouseName() %></span>
                            <% } %>
                            <div class="small text-muted mt-1">Chỉ hiển thị máy trong kho được gán — không thể xem kho khác.</div>
                        </div>
                        <form method="get" action="${pageContext.request.contextPath}/generators" class="d-flex ml-3" style="gap:8px">
                            <% if (sellerWarehouseId != null) { %>
                            <input type="hidden" name="warehouseId" value="<%= sellerWarehouseId %>">
                            <% } %>
                            <input type="text" name="q" class="form-control form-control-sm" placeholder="Tìm tên, serial..." value="<%= q != null ? q : "" %>" style="width:200px">
                            <select name="status" class="form-control form-control-sm" style="width:160px">
                                <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>-- Tất cả --</option>
                                <option value="IN_STOCK" <%= "IN_STOCK".equals(statusFilter) ? "selected" : "" %>>Trong kho</option>
                                <option value="MAINTENANCE" <%= "MAINTENANCE".equals(statusFilter) ? "selected" : "" %>>Bảo trì</option>
                                <option value="UNDER_REPAIR" <%= "UNDER_REPAIR".equals(statusFilter) ? "selected" : "" %>>Đang sửa</option>
                                <option value="EXPORTED" <%= "EXPORTED".equals(statusFilter) ? "selected" : "" %>>Đã xuất kho</option>
                                <option value="TRANSFERRED" <%= "TRANSFERRED".equals(statusFilter) ? "selected" : "" %>>Đã chuyển kho</option>
                                <option value="DAMAGED" <%= "DAMAGED".equals(statusFilter) ? "selected" : "" %>>Đã hỏng</option>
                            </select>
                            <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-search"></i></button>
                        </form>
                    </div>
                </div>
                <% } else { %>
                <div class="card shadow mb-4">
                    <div class="card-header py-3 bg-white">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-filter"></i> Bộ lọc danh sách
                        </h6>
                    </div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/generators" class="row">
                            <div class="form-group col-md-4">
                                <label for="q">Tìm kiếm</label>
                                <input type="text" id="q" name="q" class="form-control" 
                                       placeholder="Tên máy, số serial, thương hiệu..." 
                                       value="<%= q != null ? q : "" %>">
                            </div>
                            <div class="form-group col-md-3">
                                <label for="warehouseId">Kho lưu trữ</label>
                                <select id="warehouseId" name="warehouseId" class="form-control" <%= isWarehouseRestricted ? "disabled" : "" %>>
                                    <% if (!isWarehouseRestricted) { %>
                                    <option value="" <%= warehouseIdFilter == null ? "selected" : "" %>>--- Tất cả kho ---</option>
                                    <% } %>
                                    <% if (warehouses != null) {
                                        for (Warehouse w : warehouses) { %>
                                        <option value="<%= w.getWarehouseId() %>" <%= (warehouseIdFilter != null && warehouseIdFilter == w.getWarehouseId()) || (isWarehouseRestricted && warehouses.size() == 1) ? "selected" : "" %>><%= w.getWarehouseName() %></option>
                                    <% } } %>
                                </select>
                                <% if (isWarehouseRestricted && warehouses != null && !warehouses.isEmpty()) { %>
                                    <input type="hidden" name="warehouseId" value="<%= warehouses.get(0).getWarehouseId() %>">
                                <% } %>
                            </div>
                            <div class="form-group col-md-3">
                                <label for="status">Trạng thái</label>
                                <select id="status" name="status" class="form-control">
                                    <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>--- Tất cả trạng thái ---</option>
                                    <option value="IN_STOCK" <%= "IN_STOCK".equals(statusFilter) ? "selected" : "" %>>Trong kho (IN_STOCK)</option>
                                    <option value="MAINTENANCE" <%= "MAINTENANCE".equals(statusFilter) ? "selected" : "" %>>Bảo trì (MAINTENANCE)</option>
                                    <option value="UNDER_REPAIR" <%= "UNDER_REPAIR".equals(statusFilter) ? "selected" : "" %>>Đang sửa chữa (UNDER_REPAIR)</option>
                                    <option value="EXPORTED" <%= "EXPORTED".equals(statusFilter) ? "selected" : "" %>>Đã xuất kho (EXPORTED)</option>
                                    <option value="TRANSFERRED" <%= "TRANSFERRED".equals(statusFilter) ? "selected" : "" %>>Đã chuyển kho (TRANSFERRED)</option>
                                    <option value="DAMAGED" <%= "DAMAGED".equals(statusFilter) ? "selected" : "" %>>Đã hỏng (DAMAGED)</option>
                                </select>
                            </div>
                            <div class="form-group col-md-2 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100 shadow-sm">
                                    <i class="fas fa-search"></i> Tìm kiếm
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                <% } %>

                <!-- Bảng danh sách máy phát điện -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Danh sách máy phát điện
                            <span class="badge badge-primary"><%= generators != null ? generators.size() : 0 %></span>
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="generatorTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th class="text-center">ID</th>
                                    <th class="generator-name-col text-left">Tên máy phát</th>

                                    <th class="text-center">Thương hiệu</th>
                                    <th class="text-center">Công suất</th>
                                    <th class="text-center">Nhiên liệu</th>
                                    <th class="text-center">Giá thuê (VND/ngày)</th>
                                    <th class="text-center">Số lượng</th>
                                    <th class="text-center">Kho lưu trữ</th>
                                    <th class="text-center">Vị trí chi tiết</th>
                                    <th class="text-center" style="width: 140px;">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (generators == null || generators.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="10" class="text-center text-muted py-4">
                                         <i class="fas fa-inbox fa-3x mb-3 text-gray-300"></i>
                                         <p class="m-0">Không tìm thấy máy phát điện nào khớp với bộ lọc.</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (Generator g : generators) {
                                            String warehouseName = "Chưa rõ";
                                            if (warehouses != null) {
                                                for (Warehouse w : warehouses) {
                                                    if (w.getWarehouseId() == g.getWarehouseId()) {
                                                        warehouseName = w.getWarehouseName();
                                                        break;
                                                    }
                                                }
                                            }
                                            
                                            String badgeClass = "badge-secondary";
                                            String statusVn = g.getStatus();
                                            if ("IN_STOCK".equals(g.getStatus())) {
                                                badgeClass = "badge-success";
                                                statusVn = "Trong kho";
                                            } else if ("MAINTENANCE".equals(g.getStatus())) {
                                                badgeClass = "badge-warning";
                                                statusVn = "Bảo trì";
                                            } else if ("UNDER_REPAIR".equals(g.getStatus())) {
                                                badgeClass = "badge-danger";
                                                statusVn = "Đang sửa chữa";
                                            } else if ("EXPORTED".equals(g.getStatus())) {
                                                badgeClass = "badge-secondary";
                                                statusVn = "Đã xuất kho";
                                            } else if ("TRANSFERRED".equals(g.getStatus())) {
                                                badgeClass = "badge-info";
                                                statusVn = "Đã chuyển kho";
                                            } else if ("DAMAGED".equals(g.getStatus())) {
                                                badgeClass = "badge-dark";
                                                statusVn = "Đã hỏng";
                                            }

                                            // Escape strings for Javascript modal mapping
                                            String safeName = g.getGeneratorName().replace("'", "\\'");
                                            String safeSerial = g.getSerialNumber() != null ? g.getSerialNumber().replace("'", "\\'") : "";
                                            String safeBrand = g.getBrand() != null ? g.getBrand().replace("'", "\\'") : "";
                                            String safePower = g.getPowerValue() != null ? g.getPowerValue().replace("'", "\\'") : "";
                                            String safeFuel = g.getFuelType() != null ? g.getFuelType().replace("'", "\\'") : "";
                                            String safeOrigin = g.getOriginType() != null ? g.getOriginType().replace("'", "\\'") : "SUPPLIER";
                                            String safeLocation = g.getLocation() != null ? g.getLocation().replace("'", "\\'") : "";
                                            String safeNote = g.getNote() != null ? g.getNote().replace("'", "\\'").replace("\r", "").replace("\n", "\\n") : "";
                                            
                                            String importDateStr = g.getImportDate() != null ? new SimpleDateFormat("yyyy-MM-dd").format(g.getImportDate()) : "";
                                            String purchasePriceStr = g.getPurchasePrice() != null ? g.getPurchasePrice().toString() : "";
                                            int supplierIdVal = g.getSupplierId() != null ? g.getSupplierId() : -1;
                                %>
                                <tr>
                                    <td class="text-center text-nowrap"><%= g.getGeneratorId() %></td>
                                    <td class="generator-name-col">
                                        <a href="${pageContext.request.contextPath}/generators/barcodes?generatorId=<%= g.getGeneratorId() %>"
                                           class="font-weight-bold text-primary" style="text-decoration:none;"
                                           title="Xem danh sách mã vạch">
                                            <i class="fas fa-barcode mr-1" style="font-size:0.75rem;"></i><%= g.getGeneratorName() %>
                                        </a>
                                    </td>

                                    <td class="text-center text-nowrap"><%= g.getBrand() != null ? g.getBrand() : "-" %></td>
                                    <td class="text-center text-nowrap"><%= g.getPowerValue() != null ? g.getPowerValue() : "-" %></td>
                                    <td class="text-center text-nowrap"><%= g.getFuelType() != null ? g.getFuelType() : "-" %></td>
                                    <td class="text-right text-nowrap font-weight-bold text-success">
                                        <%= g.getRentalPrice() != null ? String.format("%,.0f", g.getRentalPrice()) : "0" %>
                                    </td>
                                    <td class="text-center text-nowrap"><%= g.getQuantity() %></td>
                                    <td class="text-left text-nowrap"><span class="badge badge-light border"><i class="fas fa-warehouse mr-1 text-gray-500"></i> <%= warehouseName %></span></td>
                                    <td><%= g.getLocation() != null && !g.getLocation().isEmpty() ? g.getLocation() : "-" %></td>

                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-light border shadow-sm"
                                                onclick="openDetailModal(<%= g.getGeneratorId() %>, '<%= safeName %>', '<%= safeSerial %>', '<%= g.getBarcode() != null ? g.getBarcode() : "" %>', '<%= safeBrand %>', '<%= safePower %>', '<%= safeFuel %>', '<%= warehouseName %>', '<%= safeLocation %>', '<%= statusVn %>', '<%= badgeClass %>', '<%= importDateStr %>', '<%= purchasePriceStr %>', '<%= safeNote %>', '<%= g.getRentalPrice() != null ? g.getRentalPrice().toString() : "0" %>')"
                                                title="Xem chi tiết">
                                            <i class="fas fa-eye text-primary"></i>
                                        </button>
                                        <% if (isWarehouseManager) { %>
                                        <button type="button" class="btn btn-sm btn-info shadow-sm"
                                                onclick="openEditModal(<%= g.getGeneratorId() %>, <%= g.getWarehouseId() %>, <%= supplierIdVal %>, '<%= safeName %>', '<%= safeSerial %>', '<%= safeBrand %>', '<%= safePower %>', '<%= safeFuel %>', '<%= safeOrigin %>', '<%= importDateStr %>', '<%= purchasePriceStr %>', '<%= safeLocation %>', '<%= g.getStatus() %>', '<%= safeNote %>', '<%= g.getBarcode() != null ? g.getBarcode() : "" %>', '<%= g.getRentalPrice() != null ? g.getRentalPrice().toString() : "0" %>')"
                                                title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger shadow-sm"
                                                onclick="openDeleteModal(<%= g.getGeneratorId() %>, '<%= safeName %>', '<%= safeSerial %>')"
                                                title="Xóa bỏ">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                        <% } %>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <%@ include file="/views/layout/footer.jsp" %>
    </div>
</div>

<% if (canImportGenerator) { %>
<!-- Modal thêm/sửa máy phát điện -->
<div class="modal fade" id="generatorModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <form id="generatorForm" method="post" action="${pageContext.request.contextPath}/generators/create">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="generatorModalTitle">Thêm mẫu máy phát điện mới</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="generatorId" name="generatorId">
                    <input type="hidden" id="formBarcode" name="barcode">
                    <canvas id="tempBarcodeCanvas" style="display:none;"></canvas>

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="formName">Tên máy phát điện <span class="text-danger">*</span></label>
                            <input type="text" id="formName" name="generatorName" class="form-control" required maxlength="100" placeholder="Ví dụ: Máy Phát Điện Honda EN-2500">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formSupplier">Nhà cung cấp <span class="text-danger">*</span></label>
                            <select id="formSupplier" name="supplierId" class="form-control" required>
                                <option value="">--- Chọn nhà cung cấp ---</option>
                                <% if (suppliers != null) {
                                    for (Supplier s : suppliers) { %>
                                    <option value="<%= s.getSupplierId() %>"><%= s.getSupplierName() %></option>
                                <% } } %>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-6" id="formSerialGroup">
                            <label for="formSerial">Số Serial <span class="text-muted">(Hệ thống tự động sinh)</span></label>
                            <input type="text" id="formSerial" name="serialNumber" class="form-control" readonly style="background-color: #e9ecef; cursor: not-allowed;" placeholder="Tự sinh sau khi chọn Tên & Nhà cung cấp">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formWarehouse">Kho lưu trữ <span class="text-danger">*</span></label>
                            <select id="formWarehouse" name="warehouseId" class="form-control" required>
                                <% if (!isWarehouseRestricted) { %>
                                <option value="">--- Chọn kho lưu trữ ---</option>
                                <% } %>
                                <% if (warehouses != null) {
                                    for (Warehouse w : warehouses) { %>
                                    <option value="<%= w.getWarehouseId() %>" <%= (isWarehouseRestricted && warehouses.size() == 1) ? "selected" : "" %>><%= w.getWarehouseName() %></option>
                                <% } } %>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-4">
                            <label for="formBrandSelect">Thương hiệu <span class="text-danger">*</span></label>
                            <select id="formBrandSelect" class="form-control" required onchange="handleBrandSelectChange()">
                                <option value="">--- Chọn thương hiệu ---</option>
                                <option value="Honda">Honda</option>
                                <option value="Hyundai">Hyundai</option>
                                <option value="Cummins">Cummins</option>
                                <option value="Mitsubishi">Mitsubishi</option>
                                <option value="Perkins">Perkins</option>
                                <option value="Denyo">Denyo</option>
                                <option value="Kipor">Kipor</option>
                                <option value="Yanmar">Yanmar</option>
                                <option value="Kohler">Kohler</option>
                                <option value="Other">Khác...</option>
                            </select>
                            <input type="text" id="formBrand" name="brand" class="form-control mt-2" placeholder="Nhập tên thương hiệu khác..." style="display:none;" required maxlength="100">
                        </div>
                        <div class="form-group col-md-4">
                            <label>Công suất <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" id="formPowerNumber" class="form-control" step="any" min="0.000001" required placeholder="Số" oninput="updateCombinedPower()" style="flex: 1.5 1 auto;">
                                <select id="formPowerUnit" class="form-control" required onchange="updateCombinedPower()" style="flex: 1 1 auto;">
                                    <option value="">-- Đơn vị --</option>
                                    <option value="kW">kW</option>
                                    <option value="kVA">kVA</option>
                                    <option value="HP">HP</option>
                                    <option value="W">W</option>
                                </select>
                            </div>
                            <input type="hidden" id="formPower" name="powerValue">
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formFuel">Loại nhiên liệu <span class="text-danger">*</span></label>
                            <select id="formFuel" name="fuelType" class="form-control" required>
                                <option value="">--- Chọn nhiên liệu ---</option>
                                <option value="Diesel">Dầu Diesel (Diesel)</option>
                                <option value="Gasoline">Xăng (Gasoline)</option>
                                <option value="Biogas">Khí sinh học (Biogas)</option>
                                <option value="Solar">Điện mặt trời / Hybrid</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-4">
                            <label for="formOrigin">Nguồn gốc máy <span class="text-danger">*</span></label>
                            <select id="formOrigin" name="originType" class="form-control" required>
                                <option value="">--- Chọn nguồn gốc ---</option>
                                <option value="SUPPLIER">Nhà cung cấp (SUPPLIER)</option>
                                <option value="TRANSFER">Điều chuyển nội bộ (TRANSFER)</option>
                                <option value="RETURN">Thu hồi bảo dưỡng (RETURN)</option>
                                <option value="OTHER">Khác (OTHER)</option>
                            </select>
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formImportDate">Ngày nhập kho <span class="text-danger">*</span></label>
                            <input type="date" id="formImportDate" name="importDate" class="form-control" required>
                        </div>
                        <div class="form-group col-md-4">
                            <label>Giá mua <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" id="formPriceNumber" class="form-control" step="any" min="0.000001" required placeholder="Số" oninput="updateCombinedPriceAndPrice()" style="flex: 1 1 auto;">
                                <select id="formPriceUnit" class="form-control" required onchange="updateCombinedPriceAndPrice()" style="flex: 1.8 1 auto;">
                                    <option value="1000000">Triệu VNĐ</option>
                                    <option value="100000">Trăm nghìn VNĐ</option>
                                    <option value="1">VNĐ</option>
                                </select>
                            </div>
                            <input type="hidden" id="formPrice" name="purchasePrice">
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-4">
                            <label for="formLocation">Vị trí chi tiết trong kho <span class="text-danger">*</span></label>
                            <input type="text" id="formLocation" name="location" class="form-control" required maxlength="100" placeholder="Ví dụ: Kệ A1-02">
                        </div>
                        <div class="form-group col-md-4">
                            <label>Giá cho thuê (VND/ngày) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" id="formRentalPriceNumber" class="form-control" step="any" min="0.000001" required placeholder="Số" oninput="updateCombinedRentalPrice()" style="flex: 1 1 auto;">
                                <select id="formRentalPriceUnit" class="form-control" required onchange="updateCombinedRentalPrice()" style="flex: 1.8 1 auto;">
                                    <option value="1000000">Triệu VNĐ</option>
                                    <option value="100000">Trăm nghìn VNĐ</option>
                                    <option value="1">VNĐ</option>
                                </select>
                            </div>
                            <input type="hidden" id="formRentalPrice" name="rentalPrice">
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formStatus">Trạng thái vận hành <span class="text-danger">*</span></label>
                            <select id="formStatus" name="status" class="form-control" required>
                                <option value="">--- Chọn trạng thái ---</option>
                                <option value="IN_STOCK">Trong kho (IN_STOCK)</option>
                                <option value="MAINTENANCE">Bảo trì hệ thống (MAINTENANCE)</option>
                                <option value="UNDER_REPAIR">Đang sửa chữa (UNDER_REPAIR)</option>
                                <option value="EXPORTED">Đã xuất xưởng / Sử dụng (EXPORTED)</option>
                                <option value="TRANSFERRED">Đã chuyển kho (TRANSFERRED)</option>
                                <option value="DAMAGED">Đã hỏng hóc (DAMAGED)</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="formNote">Mô tả / Ghi chú</label>
                        <textarea id="formNote" name="note" class="form-control" rows="3" placeholder="Thông số kỹ thuật bổ sung, lỗi hỏng hóc nếu có..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Lưu thông tin
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal xác nhận lưu thông tin máy phát điện -->
<div class="modal fade" id="confirmSaveModal" tabindex="-1" role="dialog" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-warning text-dark font-weight-bold">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle mr-2"></i> Xác nhận thông tin trước khi lưu</h5>
                <button type="button" class="close text-dark" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-4 text-gray-900">
                <div class="alert alert-info py-2 small">
                    <i class="fas fa-info-circle mr-1"></i> Vui lòng kiểm tra kỹ các thông tin dưới đây. Nếu đã chính xác, nhấn <strong>Xác nhận lưu</strong> để lưu vào cơ sở dữ liệu.
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <table class="table table-sm table-borderless confirm-table">
                            <tbody>
                                <tr>
                                    <td class="font-weight-bold text-muted" style="width: 150px;">Tên máy phát:</td>
                                    <td id="confirmName" class="font-weight-bold text-primary"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Số Serial:</td>
                                    <td id="confirmSerial" class="font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Thương hiệu:</td>
                                    <td id="confirmBrand"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Công suất:</td>
                                    <td id="confirmPower" class="text-success font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nhiên liệu:</td>
                                    <td id="confirmFuel"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Giá mua:</td>
                                    <td id="confirmPrice" class="text-danger font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Giá thuê:</td>
                                    <td id="confirmRentalPrice" class="text-success font-weight-bold"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-md-6 border-left">
                        <table class="table table-sm table-borderless confirm-table">
                            <tbody>
                                <tr>
                                    <td class="font-weight-bold text-muted" style="width: 150px;">Kho lưu trữ:</td>
                                    <td id="confirmWarehouse" class="font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nhà cung cấp:</td>
                                    <td id="confirmSupplier"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nguồn gốc máy:</td>
                                    <td id="confirmOrigin"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Ngày nhập kho:</td>
                                    <td id="confirmImportDate"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Vị trí chi tiết:</td>
                                    <td id="confirmLocation"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Trạng thái:</td>
                                    <td id="confirmStatus" class="font-weight-bold"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <hr class="my-2">
                <div class="form-group mb-0">
                    <label class="font-weight-bold text-muted">Mô tả / Ghi chú:</label>
                    <div id="confirmNote" class="p-2 border rounded bg-light text-break" style="white-space: pre-line; min-height: 50px;"></div>
                </div>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary px-4" data-dismiss="modal">Quay lại chỉnh sửa</button>
                <button type="button" class="btn btn-success px-4 font-weight-bold" id="btnConfirmSave">
                    <i class="fas fa-check-circle"></i> Xác nhận lưu
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal xác nhận xóa máy phát điện -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Xác nhận xóa máy phát</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa máy phát điện này ra khỏi cơ sở dữ liệu?</p>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i> 
                    Tên máy: <strong id="deleteGeneratorName"></strong><br>
                    Số Serial: <strong id="deleteGeneratorSerial"></strong>
                </div>
                <p class="text-danger small">Lưu ý: Thao tác này không thể hoàn tác nếu máy phát điện có lịch sử liên kết với phiếu xuất nhập kho.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy bỏ</button>
                <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/generators/delete" class="d-inline">
                    <input type="hidden" id="deleteGeneratorId" name="generatorId">
                    <button type="submit" class="btn btn-danger">Đồng ý xóa</button>
                </form>
            </div>
        </div>
    </div>
</div>
<% } %>

<!-- Modal xem chi tiết máy phát điện -->
<div class="modal fade" id="detailGeneratorModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-gradient-primary text-white">
                <h5 class="modal-title"><i class="fas fa-info-circle mr-1"></i> Chi tiết máy phát điện</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-4">
                <div class="row">
                    <div class="col-md-7 border-right">
                        <h4 class="font-weight-bold text-primary mb-3" id="detailName"></h4>
                        <table class="table table-borderless table-sm text-gray-900">
                            <tbody>
                                <tr>
                                    <td class="font-weight-bold text-muted" style="width: 150px;">Thương hiệu:</td>
                                    <td id="detailBrand"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Công suất:</td>
                                    <td id="detailPower"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nhiên liệu:</td>
                                    <td id="detailFuel"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Kho lưu trữ:</td>
                                    <td id="detailWarehouse"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Vị trí chi tiết:</td>
                                    <td id="detailLocation"></td>
                                </tr>

                                <tr>
                                    <td class="font-weight-bold text-muted">Ngày nhập:</td>
                                    <td id="detailImportDate"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Giá mua:</td>
                                    <td id="detailPrice"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Giá thuê:</td>
                                    <td id="detailRentalPrice" class="text-success font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Ghi chú:</td>
                                    <td id="detailNote" class="text-break" style="white-space: pre-line;"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-md-5 bg-light p-3 rounded border-left">
                        <div class="text-center font-weight-bold text-muted mb-2 small text-uppercase tracking-wider"><i class="fas fa-barcode mr-1"></i> Danh sách mã vạch & Serial</div>
                        <div class="input-group input-group-sm mb-2">
                            <div class="input-group-prepend">
                                <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                            </div>
                            <input type="text" id="barcodeSearchInput" class="form-control" placeholder="Tìm serial, trạng thái..." autocomplete="off">
                            <div class="input-group-append">
                                <span class="input-group-text bg-white text-muted" id="barcodeSearchCount" style="font-size:0.75rem;"></span>
                            </div>
                        </div>
                        <div class="table-responsive" style="max-height: 350px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 6px; background: white; padding: 5px;">
                            <table class="table table-sm table-bordered text-gray-900 mb-0" id="detailBarcodesTable" style="font-size: 0.85rem;">
                                <thead class="thead-light" style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th class="text-center" style="width:40px;">#</th>
                                        <th class="text-center">Số Serial</th>
                                        <th class="text-center">Mã vạch</th>
                                        <th class="text-center">Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody id="detailBarcodesList">
                                    <!-- Dynamic rows loaded via AJAX -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary px-4" data-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/JsBarcode.all.min.js"></script>

<script>
    $(document).ready(function () {
        $('#generatorTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: false,
            lengthChange: false,
            language: {
                paginate: {
                    next: "Sau",
                    previous: "Trước"
                },
                emptyTable: "Không có dữ liệu trong bảng",
                info: "Hiển thị từ dòng _START_ đến _END_ trên tổng số _TOTAL_ dòng",
                infoEmpty: "Không có dữ liệu hiển thị"
            }
        });

        // ===== Tìm kiếm realtime trong danh sách mã vạch =====
        $('#barcodeSearchInput').on('keyup input', function() {
            var query = $(this).val().trim().toLowerCase();
            var rows = $('#detailBarcodesList tr');
            var visibleCount = 0;

            rows.each(function() {
                var serial  = $(this).attr('data-serial') || '';
                var status  = $(this).attr('data-status') || '';
                var matched = serial.includes(query) || status.includes(query);
                $(this).toggle(matched);
                if (matched) visibleCount++;
            });

            var total = rows.filter('[data-serial]').length;
            if (query === '') {
                $('#barcodeSearchCount').text(total + ' mã');
            } else {
                $('#barcodeSearchCount').text(visibleCount + '/' + total + ' mã');
            }
        });

        // Tạo mã vạch Code 128 đồng bộ bằng JsBarcode cho tất cả các dòng (Có Quiet Zone để quét được)
        $('.barcode-render').each(function() {
            var serial = $(this).data('serial');
            if (serial) {
                try {
                    var canvas = document.createElement('canvas');
                    JsBarcode(canvas, serial, {
                        format: "CODE128",
                        width: 2,
                        height: 45,
                        displayValue: true,
                        font: "monospace",
                        fontSize: 12,
                        textMargin: 3,
                        margin: 12,
                        background: "#ffffff",
                        lineColor: "#000000"
                    });
                    $(this).attr('src', canvas.toDataURL("image/png"));
                } catch (e) {
                    console.error("Lỗi khi render mã vạch cho serial: " + serial, e);
                }
            }
        });

        // Tự động sinh số Serial khi nhập tên máy phát điện và chọn nhà cung cấp (chỉ áp dụng khi tạo mới)
        function tryGenerateSerial() {
            var generatorId = $('#generatorId').val();
            if (generatorId) {
                return; // Đang chỉnh sửa máy phát điện cũ, không tự sinh Serial
            }
            var name = $('#formName').val().trim();
            var supplier = $('#formSupplier').val();
            var serialInput = $('#formSerial');
            
            if (name && supplier) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/generators',
                    type: 'GET',
                    data: {
                        action: 'next-serial',
                        name: name,
                        supplierId: supplier
                    },
                    success: function(res) {
                        if (res.success && res.serialNumber) {
                            serialInput.val(res.serialNumber);
                            serialInput.trigger('change');
                        }
                    },
                    error: function(err) {
                        console.error('Lỗi khi sinh số Serial tự động:', err);
                    }
                });
            } else {
                serialInput.val('');
                serialInput.trigger('change');
            }
        }

        // Auto-generation disabled for model creation. Physical serial numbers will be generated during batch imports.
        // $('#formName, #formSupplier').on('blur change', function() {
        //     tryGenerateSerial();
        // });

        function validateGeneratorName() {
            var name = $('#formName').val();
            var generatorId = $('#generatorId').val() || 0;
            var inputEl = document.getElementById('formName');
            
            if (name && name.trim() !== '') {
                $.ajax({
                    url: '${pageContext.request.contextPath}/generators',
                    type: 'GET',
                    data: {
                        action: 'check-name',
                        name: name.trim(),
                        generatorId: generatorId
                    },
                    success: function(res) {
                        if (res && res.success) {
                            if (res.used) {
                                inputEl.setCustomValidity('Tên máy phát điện này đã tồn tại trong hệ thống.');
                                $('#formName').addClass('is-invalid');
                                if ($('#formNameFeedback').length === 0) {
                                    $('#formName').after('<div id="formNameFeedback" class="invalid-feedback">Tên máy phát điện này đã tồn tại trong hệ thống. Vui lòng nhập tên khác.</div>');
                                }
                            } else {
                                inputEl.setCustomValidity('');
                                $('#formName').removeClass('is-invalid');
                                $('#formNameFeedback').remove();
                            }
                        }
                    },
                    error: function(err) {
                        console.error('Lỗi khi kiểm tra trùng tên:', err);
                    }
                });
            } else {
                inputEl.setCustomValidity('');
                $('#formName').removeClass('is-invalid');
                $('#formNameFeedback').remove();
            }
        }

        $('#formName').on('blur change', function() {
            validateGeneratorName();
        });

        // Ngăn chặn nhập hoặc dán số âm cho công suất
        $('#formPowerNumber').on('keydown', function(e) {
            if (e.key === '-' || e.keyCode === 189 || e.keyCode === 109) {
                e.preventDefault();
            }
        });

        $('#formPowerNumber').on('input', function() {
            var val = $(this).val();
            if (val && parseFloat(val) < 0) {
                $(this).val('');
            }
        });

        // Ngăn chặn nhập hoặc dán số âm cho giá mua
        $('#formPriceNumber').on('keydown', function(e) {
            if (e.key === '-' || e.keyCode === 189 || e.keyCode === 109) {
                e.preventDefault();
            }
        });

        $('#formPriceNumber').on('input', function() {
            var val = $(this).val();
            if (val && parseFloat(val) < 0) {
                $(this).val('');
            }
            
            var inputEl = document.getElementById('formPriceNumber');
            if (val !== '') {
                var numVal = parseFloat(val);
                if (numVal <= 0 || isNaN(numVal)) {
                    inputEl.setCustomValidity('Giá mua phải lớn hơn 0.');
                } else {
                    inputEl.setCustomValidity('');
                }
            } else {
                inputEl.setCustomValidity('');
            }
        });

        // Ngăn chặn nhập hoặc dán số âm cho giá cho thuê
        $('#formRentalPriceNumber').on('keydown', function(e) {
            if (e.key === '-' || e.keyCode === 189 || e.keyCode === 109) {
                e.preventDefault();
            }
        });

        $('#formRentalPriceNumber').on('input', function() {
            var val = $(this).val();
            if (val && parseFloat(val) < 0) {
                $(this).val('');
            }
            
            var inputEl = document.getElementById('formRentalPriceNumber');
            if (val !== '') {
                var numVal = parseFloat(val);
                if (numVal <= 0 || isNaN(numVal)) {
                    inputEl.setCustomValidity('Giá cho thuê phải lớn hơn 0.');
                } else {
                    inputEl.setCustomValidity('');
                }
            } else {
                inputEl.setCustomValidity('');
            }
        });

        var isConfirmed = false;

        // Xử lý nút quay lại chỉnh sửa từ modal xác nhận
        $('#confirmSaveModal').on('click', '.btn-secondary, .close', function() {
            $('#confirmSaveModal').modal('hide');
            // Đợi hiệu ứng ẩn hoàn tất rồi hiện lại modal form chính
            setTimeout(function() {
                $('#generatorModal').modal('show');
            }, 300);
        });

        // Xử lý xác nhận lưu thực sự
        $('#btnConfirmSave').on('click', function() {
            isConfirmed = true;
            $('#confirmSaveModal').modal('hide');
            $('#generatorForm').submit();
        });

        // Generate barcode on submit & show confirmation modal
        $('#generatorForm').on('submit', function(e) {
            if (!this.checkValidity()) {
                return;
            }
            // Gộp phần số và đơn vị công suất trước khi submit
            var num = $('#formPowerNumber').val();
            var unit = $('#formPowerUnit').val();
            if (num && unit) {
                $('#formPower').val(num.trim() + ' ' + unit.trim());
            } else {
                $('#formPower').val('');
            }

            // Gộp phần số và hệ số giá mua trước khi submit
            var priceNum = $('#formPriceNumber').val();
            var priceMult = $('#formPriceUnit').val();
            if (priceNum && priceMult) {
                var finalPrice = parseFloat(priceNum) * parseFloat(priceMult);
                $('#formPrice').val(finalPrice);
            } else {
                $('#formPrice').val('');
            }

            // Gộp phần số và hệ số giá cho thuê trước khi submit
            var rentalPriceNum = $('#formRentalPriceNumber').val();
            var rentalPriceMult = $('#formRentalPriceUnit').val();
            if (rentalPriceNum && rentalPriceMult) {
                var finalRentalPrice = parseFloat(rentalPriceNum) * parseFloat(rentalPriceMult);
                $('#formRentalPrice').val(finalRentalPrice);
            } else {
                $('#formRentalPrice').val('');
            }

            var serial = $('#formSerial').val();
            if (serial) {
                try {
                    var canvas = document.getElementById('tempBarcodeCanvas');
                    JsBarcode(canvas, serial, {
                        format: "CODE128",
                        width: 2,
                        height: 50,
                        displayValue: true,
                        font: "monospace",
                        fontSize: 14,
                        margin: 12,
                        background: "#ffffff",
                        lineColor: "#000000"
                    });
                    var dataUrl = canvas.toDataURL("image/png");
                    var base64 = dataUrl.split(',')[1];
                    $('#formBarcode').val(base64);
                } catch (err) {
                    console.error("Error generating barcode: ", err);
                }
            }

            // Nếu chưa xác nhận, hiển thị modal xác nhận thông tin trước khi gửi lên server
            if (!isConfirmed) {
                e.preventDefault();

                // Đổ dữ liệu sang modal xác nhận
                $('#confirmName').text($('#formName').val() || '-');
                var serialVal = $('#formSerial').val();
                $('#confirmSerial').text(serialVal ? serialVal : 'Chưa có (Đăng ký mẫu máy mới)');
                
                var brandSelectVal = $('#formBrandSelect').val();
                if (brandSelectVal === 'Other') {
                    $('#confirmBrand').text($('#formBrand').val() || '-');
                } else {
                    $('#confirmBrand').text(brandSelectVal || '-');
                }

                $('#confirmPower').text($('#formPower').val() || '-');
                $('#confirmFuel').text($('#formFuel option:selected').text() || '-');
                $('#confirmWarehouse').text($('#formWarehouse option:selected').text() || '-');
                $('#confirmSupplier').text($('#formSupplier option:selected').text() || '-');
                $('#confirmOrigin').text($('#formOrigin option:selected').text() || '-');
                $('#confirmImportDate').text($('#formImportDate').val() || '-');

                var displayPrice = '-';
                if (priceNum) {
                    var priceVal = parseFloat(priceNum) * parseFloat(priceMult);
                    displayPrice = priceVal.toLocaleString('vi-VN') + ' VNĐ';
                }
                $('#confirmPrice').text(displayPrice);

                var rentalPriceVal = $('#formRentalPrice').val();
                var displayRentalPrice = '-';
                if (rentalPriceVal) {
                    displayRentalPrice = parseFloat(rentalPriceVal).toLocaleString('vi-VN') + ' VNĐ/ngày';
                }
                $('#confirmRentalPrice').text(displayRentalPrice);

                $('#confirmLocation').text($('#formLocation').val() || '-');
                $('#confirmStatus').text($('#formStatus option:selected').text() || '-');
                $('#confirmNote').text($('#formNote').val() || 'Không có ghi chú');

                // Ẩn modal chính và hiện modal xác nhận
                $('#generatorModal').modal('hide');
                setTimeout(function() {
                    $('#confirmSaveModal').modal('show');
                }, 300);
            }
        });
    });

    function openDetailModal(generatorId, name, serial, barcode, brand, power, fuel, warehouse, location, statusText, statusBadgeClass, importDate, price, note, rentalPrice) {
        $('#detailName').text(name || '-');
        $('#detailBrand').text(brand || '-');
        $('#detailPower').text(power || '-');
        $('#detailFuel').text(fuel || '-');
        $('#detailWarehouse').text(warehouse || '-');
        $('#detailLocation').text(location || '-');
        $('#detailStatus').text(statusText || '-').attr('class', 'badge ' + (statusBadgeClass || 'badge-secondary') + ' px-2 py-1');
        $('#detailImportDate').text(importDate || '-');
        
        var formattedPrice = '-';
        if (price) {
            try {
                formattedPrice = new Number(price).toLocaleString('vi-VN') + ' VNĐ';
            } catch(e) {
                formattedPrice = price + ' VNĐ';
            }
        }
        $('#detailPrice').text(formattedPrice);

        var formattedRentalPrice = '-';
        if (rentalPrice) {
            try {
                formattedRentalPrice = new Number(rentalPrice).toLocaleString('vi-VN') + ' VNĐ/ngày';
            } catch(e) {
                formattedRentalPrice = rentalPrice + ' VNĐ/ngày';
            }
        }
        $('#detailRentalPrice').text(formattedRentalPrice);
        $('#detailNote').text(note || '-');
        
        // Clear barcodes table, reset search, and show loader
        $('#barcodeSearchInput').val('');
        $('#barcodeSearchCount').text('');
        $('#detailBarcodesList').html('<tr><td colspan="4" class="text-center py-3"><i class="fas fa-spinner fa-spin mr-1"></i> Đang tải danh sách...</td></tr>');
        
        // Fetch barcodes via AJAX
        $.ajax({
            url: '${pageContext.request.contextPath}/generators',
            type: 'GET',
            data: {
                action: 'get-barcodes',
                generatorId: generatorId
            },
            success: function(res) {
                if (res && res.length > 0) {
                    var html = '';
                        var rowNum = 0;
                    res.forEach(function(item) {
                        rowNum++;
                        var statusBadge = '';
                        if (item.status === 'IN_STOCK') {
                            statusBadge = '<span class="badge badge-success px-2 py-1">Trong kho</span>';
                        } else if (item.status === 'MAINTENANCE') {
                            statusBadge = '<span class="badge badge-warning px-2 py-1">Bảo trì</span>';
                        } else if (item.status === 'UNDER_REPAIR') {
                            statusBadge = '<span class="badge badge-danger px-2 py-1">Đang sửa</span>';
                        } else if (item.status === 'EXPORTED') {
                            statusBadge = '<span class="badge badge-secondary px-2 py-1">Đã xuất</span>';
                        } else if (item.status === 'DAMAGED') {
                            statusBadge = '<span class="badge badge-dark px-2 py-1">Đã hỏng</span>';
                        } else {
                            statusBadge = '<span class="badge badge-light px-2 py-1">' + item.status + '</span>';
                        }
                        
                        html += '<tr data-serial="' + item.serialNumber.toLowerCase() + '" data-status="' + item.status.toLowerCase() + '">';
                        html += '<td class="text-center align-middle text-muted" style="width:40px;">' + rowNum + '</td>';
                        html += '<td class="text-center align-middle"><code class="font-weight-bold" style="font-size: 0.8rem;">' + item.serialNumber + '</code></td>';
                        html += '<td class="text-center align-middle">'
                             +  '<img class="modal-barcode-render" data-serial="' + item.serialNumber + '" style="height: 38px; max-width: 170px; display: block; margin: 0 auto; background: #fff; padding: 2px 6px; border: 1px solid #cbd5e1; border-radius: 4px; image-rendering: -webkit-optimize-contrast; image-rendering: pixelated;" alt="Barcode" />'
                             +  '<div class="text-dark font-weight-bold mt-1" style="font-size: 0.72rem; font-family: monospace; letter-spacing: 0.5px;">' + item.serialNumber + '</div>'
                             +  '</td>';
                        html += '<td class="text-center align-middle">' + statusBadge + '</td>';
                        html += '</tr>';
                    });
                    $('#detailBarcodesList').html(html);
                    
                    // Update total count
                    var totalCount = res.length;
                    $('#barcodeSearchCount').text(totalCount + ' mã');
                    
                    // Render barcodes
                    $('#detailBarcodesList .modal-barcode-render').each(function() {
                        var s = $(this).data('serial');
                        if (s) {
                            try {
                                var canvas = document.createElement('canvas');
                                JsBarcode(canvas, s, {
                                    format: "CODE128",
                                    width: 1.3,
                                    height: 36,
                                    displayValue: false,
                                    margin: 8,
                                    background: "#ffffff",
                                    lineColor: "#000000"
                                });
                                $(this).attr('src', canvas.toDataURL("image/png"));
                            } catch(e) {
                                console.error(e);
                            }
                        }
                    });
                } else {
                    $('#detailBarcodesList').html('<tr><td colspan="4" class="text-center text-muted py-3">Không tìm thấy mã vạch nào</td></tr>');
                    $('#barcodeSearchCount').text('0 mã');
                }
            },
            error: function(err) {
                console.error(err);
                $('#detailBarcodesList').html('<tr><td colspan="4" class="text-center text-danger py-3">Lỗi khi tải danh sách mã vạch</td></tr>');
                $('#barcodeSearchCount').text('');
            }
        });

        $('#detailGeneratorModal').modal('show');
    }

    function handleBrandSelectChange() {
        var selectVal = $('#formBrandSelect').val();
        if (selectVal === 'Other') {
            $('#formBrand').val('').show().focus();
        } else {
            $('#formBrand').val(selectVal).hide();
        }
    }

    function updateCombinedPower() {
        var num = $('#formPowerNumber').val();
        var unit = $('#formPowerUnit').val();
        
        var inputEl = document.getElementById('formPowerNumber');
        if (num !== '') {
            var val = parseFloat(num);
            if (val <= 0 || isNaN(val)) {
                inputEl.setCustomValidity('Công suất phải lớn hơn 0.');
            } else {
                inputEl.setCustomValidity('');
            }
        } else {
            inputEl.setCustomValidity('');
        }

        if (num && unit) {
            $('#formPower').val(num.trim() + ' ' + unit.trim());
        } else {
            $('#formPower').val('');
        }
    }

    function updateCombinedPriceAndPrice() {
        var num = $('#formPriceNumber').val();
        var multiplier = $('#formPriceUnit').val();
        
        var inputEl = document.getElementById('formPriceNumber');
        if (num !== '') {
            var val = parseFloat(num);
            if (val <= 0 || isNaN(val)) {
                inputEl.setCustomValidity('Giá mua phải lớn hơn 0.');
            } else {
                inputEl.setCustomValidity('');
            }
        } else {
            inputEl.setCustomValidity('');
        }

        if (num && multiplier) {
            var finalPrice = parseFloat(num) * parseFloat(multiplier);
            $('#formPrice').val(finalPrice);
        } else {
            $('#formPrice').val('');
        }
    }

    function updateCombinedRentalPrice() {
        var num = $('#formRentalPriceNumber').val();
        var multiplier = $('#formRentalPriceUnit').val();
        
        var inputEl = document.getElementById('formRentalPriceNumber');
        if (num !== '') {
            var val = parseFloat(num);
            if (val <= 0 || isNaN(val)) {
                inputEl.setCustomValidity('Giá cho thuê phải lớn hơn 0.');
            } else {
                inputEl.setCustomValidity('');
            }
        } else {
            inputEl.setCustomValidity('');
        }

        if (num && multiplier) {
            var finalPrice = parseFloat(num) * parseFloat(multiplier);
            $('#formRentalPrice').val(finalPrice);
        } else {
            $('#formRentalPrice').val('');
        }
    }

    <% if (canImportGenerator) { %>
    function openCreateModal() {
        isConfirmed = false;
        $('#generatorModalTitle').text('Thêm mẫu máy phát điện mới');
        $('#generatorForm').attr('action', '${pageContext.request.contextPath}/generators/create');
        $('#generatorId').val('');
        $('#formBarcode').val('');

        $('#formName').val('').removeClass('is-invalid');
        document.getElementById('formName').setCustomValidity('');
        $('#formNameFeedback').remove();
        // Ẩn trường Số Serial khi tạo mới vì là đăng ký mẫu máy
        $('#formSerialGroup').hide();
        $('#formSerial').val('');
        $('#formBrandSelect').val('');
        $('#formBrand').val('').hide();
        $('#formPowerNumber').val('');
        $('#formPowerUnit').val('');
        $('#formPower').val('');
        $('#formFuel').val('Diesel');
        $('#formWarehouse').val('<%= isWarehouseRestricted ? restrictedWarehouseId : "" %>');
        $('#formSupplier').val('');
        $('#formOrigin').val('SUPPLIER');
        $('#formImportDate').val('');
        $('#formPriceNumber').val('');
        $('#formPriceUnit').val('1000000'); // Mặc định là Triệu VNĐ
        $('#formPrice').val('');
        $('#formRentalPriceNumber').val('');
        $('#formRentalPriceUnit').val('100000'); // Mặc định là Trăm nghìn VNĐ
        $('#formRentalPrice').val('');
        $('#formLocation').val('');
        $('#formStatus').val('IN_STOCK');
        $('#formNote').val('');
        $('#generatorModal').modal('show');
    }
    <% } %>

    <% if (isWarehouseManager) { %>
    function openEditModal(generatorId, warehouseId, supplierId, name, serial, brand, power, fuel, origin, importDate, price, location, status, note, barcode, rentalPrice) {
        isConfirmed = false;
        $('#generatorModalTitle').text('Chỉnh sửa thông tin máy phát điện');
        $('#generatorForm').attr('action', '${pageContext.request.contextPath}/generators/update');
        $('#generatorId').val(generatorId);
        $('#formBarcode').val(barcode || '');
        

        $('#formName').val(name).removeClass('is-invalid');
        document.getElementById('formName').setCustomValidity('');
        $('#formNameFeedback').remove();
        if (serial && serial.trim() !== '') {
            $('#formSerialGroup').show();
            $('#formSerial').val(serial).prop('readonly', true);
        } else {
            $('#formSerialGroup').hide();
            $('#formSerial').val('');
        }
        
        var popularBrands = ['Honda', 'Hyundai', 'Cummins', 'Mitsubishi', 'Perkins', 'Denyo', 'Kipor', 'Yanmar', 'Kohler'];
        if (brand && brand.trim() !== '') {
            var trimmedBrand = brand.trim();
            if (popularBrands.indexOf(trimmedBrand) !== -1) {
                $('#formBrandSelect').val(trimmedBrand);
                $('#formBrand').val(trimmedBrand).hide();
            } else {
                $('#formBrandSelect').val('Other');
                $('#formBrand').val(trimmedBrand).show();
            }
        } else {
            $('#formBrandSelect').val('');
            $('#formBrand').val('').hide();
        }

        if (power && power.trim() !== '') {
            var trimmedPower = power.trim();
            $('#formPower').val(trimmedPower);
            // Tách phần số và phần đơn vị (Ví dụ: "5.5 kW" -> số "5.5", đơn vị "kW")
            var match = trimmedPower.match(/^([\d.,]+)\s*(.*)$/);
            if (match) {
                $('#formPowerNumber').val(match[1]);
                $('#formPowerUnit').val(match[2]);
            } else {
                $('#formPowerNumber').val(trimmedPower);
                $('#formPowerUnit').val('');
            }
        } else {
            $('#formPowerNumber').val('');
            $('#formPowerUnit').val('');
            $('#formPower').val('');
        }
        $('#formFuel').val(fuel ? fuel : 'Diesel');
        $('#formWarehouse').val(warehouseId);
        $('#formSupplier').val(supplierId !== -1 ? supplierId : '');
        $('#formOrigin').val(origin ? origin : 'SUPPLIER');
        $('#formImportDate').val(importDate);
        
        if (price && parseFloat(price) > 0) {
            var p = parseFloat(price);
            $('#formPrice').val(p);
            
            if (p >= 1000000 && p % 1000 === 0) {
                $('#formPriceNumber').val(p / 1000000);
                $('#formPriceUnit').val('1000000');
            } else if (p >= 100000 && p % 1000 === 0) {
                $('#formPriceNumber').val(p / 100000);
                $('#formPriceUnit').val('100000');
            } else {
                $('#formPriceNumber').val(p);
                $('#formPriceUnit').val('1');
            }
        } else {
            $('#formPriceNumber').val('');
            $('#formPriceUnit').val('1000000'); // Mặc định là Triệu VNĐ
            $('#formPrice').val('');
        }
        if (rentalPrice && parseFloat(rentalPrice) > 0) {
            var rp = parseFloat(rentalPrice);
            $('#formRentalPrice').val(rp);
            
            if (rp >= 1000000 && rp % 1000 === 0) {
                $('#formRentalPriceNumber').val(rp / 1000000);
                $('#formRentalPriceUnit').val('1000000');
            } else if (rp >= 100000 && rp % 1000 === 0) {
                $('#formRentalPriceNumber').val(rp / 100000);
                $('#formRentalPriceUnit').val('100000');
            } else {
                $('#formRentalPriceNumber').val(rp);
                $('#formRentalPriceUnit').val('1');
            }
        } else {
            $('#formRentalPriceNumber').val('');
            $('#formRentalPriceUnit').val('100000'); // Mặc định là Trăm nghìn VNĐ
            $('#formRentalPrice').val('');
        }
        $('#formLocation').val(location);
        $('#formStatus').val(status);
        $('#formNote').val(note);
        $('#generatorModal').modal('show');
    }

    function openDeleteModal(generatorId, name, serial) {
        $('#deleteGeneratorId').val(generatorId);
        $('#deleteGeneratorName').text(name);
        $('#deleteGeneratorSerial').text(serial);
        $('#deleteModal').modal('show');
    }
    <% } %>
</script>

</body>
</html>
