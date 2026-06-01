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
                        <i class="fas fa-bolt text-primary"></i> Quản lý máy phát điện
                    </h1>
                    <% if (isWarehouseManager) { %>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Thêm máy phát điện
                    </button>
                    <% } %>
                </div>

                <!-- Thông báo kết quả -->
                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Thêm máy phát điện mới thành công!
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
                                <select id="warehouseId" name="warehouseId" class="form-control">
                                    <option value="" <%= warehouseIdFilter == null ? "selected" : "" %>>--- Tất cả kho ---</option>
                                    <% if (warehouses != null) {
                                        for (Warehouse w : warehouses) { %>
                                        <option value="<%= w.getWarehouseId() %>" <%= warehouseIdFilter != null && warehouseIdFilter == w.getWarehouseId() ? "selected" : "" %>><%= w.getWarehouseName() %></option>
                                    <% } } %>
                                </select>
                            </div>
                            <div class="form-group col-md-3">
                                <label for="status">Trạng thái</label>
                                <select id="status" name="status" class="form-control">
                                    <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>--- Tất cả trạng thái ---</option>
                                    <option value="IN_STOCK" <%= "IN_STOCK".equals(statusFilter) ? "selected" : "" %>>Trong kho (IN_STOCK)</option>
                                    <option value="MAINTENANCE" <%= "MAINTENANCE".equals(statusFilter) ? "selected" : "" %>>Bảo trì (MAINTENANCE)</option>
                                    <option value="UNDER_REPAIR" <%= "UNDER_REPAIR".equals(statusFilter) ? "selected" : "" %>>Đang sửa chữa (UNDER_REPAIR)</option>
                                    <option value="EXPORTED" <%= "EXPORTED".equals(statusFilter) ? "selected" : "" %>>Đã xuất kho (EXPORTED)</option>
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
                                    <th class="text-center">Số Serial</th>
                                    <th class="text-center">Thương hiệu</th>
                                    <th class="text-center">Công suất</th>
                                    <th class="text-center">Nhiên liệu</th>
                                    <th class="text-center">Kho lưu trữ</th>
                                    <th class="text-center">Vị trí chi tiết</th>
                                    <th class="text-center" style="width: 130px;">Trạng thái</th>
                                    <% if (isWarehouseManager) { %>
                                    <th class="text-center" style="width: 120px;">Hành động</th>
                                    <% } %>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (generators == null || generators.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="<%= isWarehouseManager ? 10 : 9 %>" class="text-center text-muted py-4">
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
                                            } else if ("DAMAGED".equals(g.getStatus())) {
                                                badgeClass = "badge-dark";
                                                statusVn = "Đã hỏng";
                                            }

                                            // Escape strings for Javascript modal mapping
                                            String safeName = g.getGeneratorName().replace("'", "\\'");
                                            String safeSerial = g.getSerialNumber().replace("'", "\\'");
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
                                        <span class="font-weight-bold text-gray-900"><%= g.getGeneratorName() %></span>
                                    </td>
                                    <td class="text-center text-nowrap"><code class="text-xs font-weight-bold"><%= g.getSerialNumber() %></code></td>
                                    <td class="text-center text-nowrap"><%= g.getBrand() != null ? g.getBrand() : "-" %></td>
                                    <td class="text-center text-nowrap"><%= g.getPowerValue() != null ? g.getPowerValue() : "-" %></td>
                                    <td class="text-center text-nowrap"><%= g.getFuelType() != null ? g.getFuelType() : "-" %></td>
                                    <td class="text-left text-nowrap"><span class="badge badge-light border"><i class="fas fa-warehouse mr-1 text-gray-500"></i> <%= warehouseName %></span></td>
                                    <td><%= g.getLocation() != null && !g.getLocation().isEmpty() ? g.getLocation() : "-" %></td>
                                    <td class="text-center text-nowrap">
                                        <span class="badge <%= badgeClass %> px-2 py-1"><%= statusVn %></span>
                                    </td>
                                    <% if (isWarehouseManager) { %>
                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-info shadow-sm"
                                                onclick="openEditModal(<%= g.getGeneratorId() %>, <%= g.getWarehouseId() %>, <%= supplierIdVal %>, '<%= safeName %>', '<%= safeSerial %>', '<%= safeBrand %>', '<%= safePower %>', '<%= safeFuel %>', '<%= safeOrigin %>', '<%= importDateStr %>', '<%= purchasePriceStr %>', '<%= safeLocation %>', '<%= g.getStatus() %>', '<%= safeNote %>')"
                                                title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger shadow-sm"
                                                onclick="openDeleteModal(<%= g.getGeneratorId() %>, '<%= safeName %>', '<%= safeSerial %>')"
                                                title="Xóa bỏ">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </td>
                                    <% } %>
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

<% if (isWarehouseManager) { %>
<!-- Modal thêm/sửa máy phát điện -->
<div class="modal fade" id="generatorModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <form id="generatorForm" method="post" action="${pageContext.request.contextPath}/generators/create">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="generatorModalTitle">Thêm máy phát điện</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="generatorId" name="generatorId">

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="formName">Tên máy phát điện <span class="text-danger">*</span></label>
                            <input type="text" id="formName" name="generatorName" class="form-control" required maxlength="100" placeholder="Ví dụ: Máy Phát Điện Honda EN-2500">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formSerial">Số Serial <span class="text-danger">*</span></label>
                            <input type="text" id="formSerial" name="serialNumber" class="form-control" required maxlength="100" placeholder="Ví dụ: HD-EN25-99882">
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-4">
                            <label for="formBrand">Thương hiệu</label>
                            <input type="text" id="formBrand" name="brand" class="form-control" maxlength="100" placeholder="Ví dụ: Honda, Hyundai">
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formPower">Công suất</label>
                            <input type="text" id="formPower" name="powerValue" class="form-control" maxlength="50" placeholder="Ví dụ: 5.5 kW, 20 kVA">
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formFuel">Loại nhiên liệu</label>
                            <select id="formFuel" name="fuelType" class="form-control">
                                <option value="Diesel">Dầu Diesel (Diesel)</option>
                                <option value="Gasoline">Xăng (Gasoline)</option>
                                <option value="Biogas">Khí sinh học (Biogas)</option>
                                <option value="Solar">Điện mặt trời / Hybrid</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="formWarehouse">Kho lưu trữ <span class="text-danger">*</span></label>
                            <select id="formWarehouse" name="warehouseId" class="form-control" required>
                                <option value="">--- Chọn kho lưu trữ ---</option>
                                <% if (warehouses != null) {
                                    for (Warehouse w : warehouses) { %>
                                    <option value="<%= w.getWarehouseId() %>"><%= w.getWarehouseName() %></option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formSupplier">Nhà cung cấp</label>
                            <select id="formSupplier" name="supplierId" class="form-control">
                                <option value="">--- Trống / Tự chuyển giao ---</option>
                                <% if (suppliers != null) {
                                    for (Supplier s : suppliers) { %>
                                    <option value="<%= s.getSupplierId() %>"><%= s.getSupplierName() %></option>
                                <% } } %>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-4">
                            <label for="formOrigin">Nguồn gốc máy</label>
                            <select id="formOrigin" name="originType" class="form-control">
                                <option value="SUPPLIER">Nhà cung cấp (SUPPLIER)</option>
                                <option value="TRANSFER">Điều chuyển nội bộ (TRANSFER)</option>
                                <option value="RETURN">Thu hồi bảo dưỡng (RETURN)</option>
                                <option value="OTHER">Khác (OTHER)</option>
                            </select>
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formImportDate">Ngày nhập kho</label>
                            <input type="date" id="formImportDate" name="importDate" class="form-control">
                        </div>
                        <div class="form-group col-md-4">
                            <label for="formPrice">Giá mua (VNĐ)</label>
                            <input type="number" id="formPrice" name="purchasePrice" class="form-control" min="0" step="0.01" placeholder="Ví dụ: 15000000.00">
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="formLocation">Vị trí chi tiết trong kho</label>
                            <input type="text" id="formLocation" name="location" class="form-control" maxlength="100" placeholder="Ví dụ: Kệ A1-02, Gian máy phát lớn">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formStatus">Trạng thái vận hành</label>
                            <select id="formStatus" name="status" class="form-control">
                                <option value="IN_STOCK">Trong kho (IN_STOCK)</option>
                                <option value="MAINTENANCE">Bảo trì hệ thống (MAINTENANCE)</option>
                                <option value="UNDER_REPAIR">Đang sửa chữa (UNDER_REPAIR)</option>
                                <option value="EXPORTED">Đã xuất xưởng / Sử dụng (EXPORTED)</option>
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

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>

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
    });

    <% if (isWarehouseManager) { %>
    function openCreateModal() {
        $('#generatorModalTitle').text('Thêm máy phát điện mới');
        $('#generatorForm').attr('action', '${pageContext.request.contextPath}/generators/create');
        $('#generatorId').val('');
        $('#formName').val('');
        $('#formSerial').val('').prop('readonly', false);
        $('#formBrand').val('');
        $('#formPower').val('');
        $('#formFuel').val('Diesel');
        $('#formWarehouse').val('');
        $('#formSupplier').val('');
        $('#formOrigin').val('SUPPLIER');
        $('#formImportDate').val('');
        $('#formPrice').val('');
        $('#formLocation').val('');
        $('#formStatus').val('IN_STOCK');
        $('#formNote').val('');
        $('#generatorModal').modal('show');
    }

    function openEditModal(generatorId, warehouseId, supplierId, name, serial, brand, power, fuel, origin, importDate, price, location, status, note) {
        $('#generatorModalTitle').text('Chỉnh sửa thông tin máy phát điện');
        $('#generatorForm').attr('action', '${pageContext.request.contextPath}/generators/update');
        $('#generatorId').val(generatorId);
        $('#formName').val(name);
        $('#formSerial').val(serial).prop('readonly', true); // Serial number is usually read-only upon edit
        $('#formBrand').val(brand);
        $('#formPower').val(power);
        $('#formFuel').val(fuel ? fuel : 'Diesel');
        $('#formWarehouse').val(warehouseId);
        $('#formSupplier').val(supplierId !== -1 ? supplierId : '');
        $('#formOrigin').val(origin ? origin : 'SUPPLIER');
        $('#formImportDate').val(importDate);
        $('#formPrice').val(price);
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
