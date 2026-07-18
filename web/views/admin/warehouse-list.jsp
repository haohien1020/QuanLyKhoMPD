<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Warehouse" %>
<%@ page import="model.User" %>

<%
    @SuppressWarnings("unchecked")
    List<Warehouse> warehouses = (List<Warehouse>) request.getAttribute("warehouses");
    @SuppressWarnings("unchecked")
    List<User> managers = (List<User>) request.getAttribute("managers");
    @SuppressWarnings("unchecked")
    List<User> warehouseManagers = (List<User>) request.getAttribute("warehouseManagers");
    @SuppressWarnings("unchecked")
    List<User> allStaff = (List<User>) request.getAttribute("allStaff");
    @SuppressWarnings("unchecked")
    List<User> allSellers = (List<User>) request.getAttribute("allSellers");

    String q = (String) request.getAttribute("q");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý kho | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
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
                        <i class="fas fa-warehouse text-primary"></i> Quản lý kho
                    </h1>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Thêm kho mới
                    </button>
                </div>

                <%-- Error Notification from Controller --%>
                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <%-- Error query parameters --%>
                <% if ("name_empty".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên kho không được bỏ trống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_length".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên kho phải dài từ 3 đến 100 ký tự.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên kho đã tồn tại trong hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("address_empty".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Địa chỉ kho không được bỏ trống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("address_length".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Địa chỉ kho không được vượt quá 255 ký tự.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("address_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Địa chỉ kho đã tồn tại trong hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("not_found".equals(errorParam)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> Không tìm thấy kho yêu cầu.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("warehouse_manager_assigned".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Nhân viên Quản lý kho (Warehouse Manager) này đã được gán quản lý một kho hoạt động khác!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("create_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Thêm mới kho thất bại. Vui lòng kiểm tra lại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("update_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Cập nhật thông tin kho thất bại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("toggle_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Không thể thay đổi trạng thái kho hàng.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("system_error".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Lỗi hệ thống. Vui lòng liên hệ quản trị viên.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <%-- Success query parameters --%>
                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Tạo kho hàng mới thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật thông tin kho hàng thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("activated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã kích hoạt kho hàng hoạt động.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deactivated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã chuyển kho hàng về trạng thái ngưng hoạt động.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Xóa kho hàng thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("delete_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Xóa kho hàng thất bại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Danh sách kho hàng
                            <span class="badge badge-primary ml-1"><%= warehouses != null ? warehouses.size() : 0 %></span>
                        </h6>

                        <form class="form-inline" method="get" action="${pageContext.request.contextPath}/admin/warehouses">
                            <div class="form-group mr-2 mb-2">
                                <label for="q" class="mr-1">Tìm kiếm</label>
                                <input id="q" name="q" class="form-control form-control-sm"
                                       placeholder="Tên / Địa chỉ kho"
                                       value="<%= q != null ? q : "" %>">
                            </div>
                            <div class="form-group mr-2 mb-2">
                                <label for="statusFilter" class="mr-1">Trạng thái</label>
                                <select id="statusFilter" name="status" class="form-control form-control-sm">
                                    <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>Tất cả</option>
                                    <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Hoạt động</option>
                                    <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Ngưng hoạt động</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-sm btn-outline-primary mb-2">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                        </form>
                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="warehouseTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th style="width:50px">ID</th>
                                    <th>Tên Kho</th>
                                    <th>Địa Chỉ</th>
                                    <th>Quản Lý Trực Tiếp (Warehouse Manager)</th>
                                    <th>Người Giám Sát (Manager)</th>
                                    <th style="width:120px">Trạng Thái</th>
                                    <th style="width:130px">Hành Động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (warehouses == null || warehouses.isEmpty()) {
                                    } else {
                                        for (Warehouse wh : warehouses) {
                                            boolean active = "ACTIVE".equalsIgnoreCase(wh.getStatus());
                                            String whName = wh.getWarehouseName() != null ? wh.getWarehouseName() : "";
                                            String address = wh.getAddress() != null ? wh.getAddress() : "";
                                            
                                            String whManagerName = wh.getWarehouseManagerName() != null ? wh.getWarehouseManagerName() : "Chưa phân công";
                                            int whManagerId = wh.getWarehouseManagerId() != null ? wh.getWarehouseManagerId() : 0;
                                            
                                            String managerName = wh.getManagerName() != null ? wh.getManagerName() : "Chưa phân công";
                                            int managerId = wh.getManagerId() != null ? wh.getManagerId() : 0;
                                            
                                            String safeWhName = whName.replace("\\", "\\\\").replace("'", "\\'");
                                            String safeAddress = address.replace("\\", "\\\\").replace("'", "\\'");
                                %>
                                <tr>
                                    <td><%= wh.getWarehouseId() %></td>
                                    <td>
                                        <span class="font-weight-bold text-gray-900"><%= whName %></span>
                                    </td>
                                    <td><%= address.isEmpty() ? "-" : address %></td>
                                    <td>
                                        <% if (wh.getWarehouseManagerId() != null) { %>
                                        <span class="badge badge-light border text-gray-800">
                                            <i class="fas fa-user-cog text-info mr-1"></i> <%= whManagerName %>
                                        </span>
                                        <% } else { %>
                                        <span class="text-muted font-italic">Chưa phân công</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (wh.getManagerId() != null) { %>
                                        <span class="badge badge-light border text-gray-800">
                                            <i class="fas fa-user-tie text-primary mr-1"></i> <%= managerName %>
                                        </span>
                                        <% } else { %>
                                        <span class="text-muted font-italic">Chưa phân công</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center">
                                        <% if (active) { %>
                                        <span class="badge badge-success px-2 py-1">Hoạt động</span>
                                        <% } else { %>
                                        <span class="badge badge-secondary px-2 py-1">Ngưng hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-info"
                                                onclick="openEditModal(<%= wh.getWarehouseId() %>, '<%= safeWhName %>', '<%= safeAddress %>', <%= whManagerId %>, <%= managerId %>, '<%= wh.getStatus() %>')"
                                                title="Sửa thông tin">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <% if (active) { %>
                                        <button type="button" class="btn btn-sm btn-warning"
                                                onclick="openToggleModal(<%= wh.getWarehouseId() %>, '<%= safeWhName %>', false)"
                                                title="Ngưng hoạt động">
                                            <i class="fas fa-ban"></i>
                                        </button>
                                        <% } else { %>
                                        <button type="button" class="btn btn-sm btn-success"
                                                onclick="openToggleModal(<%= wh.getWarehouseId() %>, '<%= safeWhName %>', true)"
                                                title="Kích hoạt">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <% } %>
                                        <button type="button" class="btn btn-sm btn-danger"
                                                onclick="openDeleteModal(<%= wh.getWarehouseId() %>, '<%= safeWhName %>')"
                                                title="Xóa kho">
                                            <i class="fas fa-trash"></i>
                                        </button>
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

<%-- Create/Edit Warehouse Modal --%>
<div class="modal fade" id="warehouseModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <form id="warehouseForm" method="post" action="${pageContext.request.contextPath}/admin/warehouse/create">
                <div class="modal-header">
                    <h5 class="modal-title" id="warehouseModalTitle">Thêm kho mới</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="warehouseId" name="warehouseId">

                    <div class="form-group">
                        <label for="warehouseName">Tên Kho <span class="text-danger">*</span></label>
                        <input type="text" id="warehouseName" name="warehouseName" class="form-control"
                               maxlength="100" required placeholder="Ví dụ: Kho Chi Nhánh 1">
                        <small class="form-text text-muted">Tên kho chứa từ 3 đến 100 ký tự.</small>
                    </div>

                    <div class="form-group">
                        <label for="address">Địa Chỉ <span class="text-danger">*</span></label>
                        <input type="text" id="address" name="address" class="form-control"
                               maxlength="255" required placeholder="Ví dụ: 123 Đường ABC, Quận XYZ">
                    </div>

                    <div class="form-group">
                        <label for="warehouseManagerId">Quản Lý Trực Tiếp (Warehouse Manager)</label>
                        <select id="warehouseManagerId" name="warehouseManagerId" class="form-control">
                            <option value="">-- Chưa phân công --</option>
                            <% if (warehouseManagers != null) {
                                for (User wm : warehouseManagers) {
                            %>
                            <option value="<%= wm.getUserId() %>"><%= wm.getFullName() %> (<%= wm.getUsername() %>)</option>
                            <% } } %>
                        </select>
                        <small class="form-text text-muted">Warehouse Manager phụ trách trực tiếp các giao dịch xuất nhập kho.</small>
                    </div>

                    <div class="form-group">
                        <label for="managerId">Người Giám Sát (Manager)</label>
                        <select id="managerId" name="managerId" class="form-control">
                            <option value="">-- Chưa phân công --</option>
                            <% if (managers != null) {
                                for (User m : managers) {
                            %>
                            <option value="<%= m.getUserId() %>"><%= m.getFullName() %> (<%= m.getUsername() %>)</option>
                            <% } } %>
                        </select>
                        <small class="form-text text-muted">Manager có thể quản lý / giám sát cùng lúc nhiều kho.</small>
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold">Nhân viên Kỹ thuật (STAFF)</label>
                        <div id="staffContainer" class="border rounded p-3" style="max-height: 150px; overflow-y: auto; background-color: #f8f9fc;">
                            <!-- Load dynamic STAFF checkboxes -->
                        </div>
                        <small class="form-text text-muted">Chọn nhân viên kỹ thuật làm việc tại kho này.</small>
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold">Nhân viên Bán hàng (SELLER)</label>
                        <div id="sellerContainer" class="border rounded p-3" style="max-height: 150px; overflow-y: auto; background-color: #f8f9fc;">
                            <!-- Load dynamic SELLER checkboxes -->
                        </div>
                        <small class="form-text text-muted">Chọn nhân viên bán hàng làm việc tại kho này.</small>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng Thái</label>
                        <select id="status" name="status" class="form-control">
                            <option value="ACTIVE">Hoạt động</option>
                            <option value="INACTIVE">Ngưng hoạt động</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Lưu lại
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Confirm Toggle Status Modal --%>
<div class="modal fade" id="toggleModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="toggleModalTitle">Xác nhận thao tác</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p id="toggleModalBody"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="toggleForm" action="${pageContext.request.contextPath}/admin/warehouse/toggle-status" method="post" class="d-inline">
                    <input type="hidden" id="toggleWarehouseId" name="warehouseId">
                    <input type="hidden" id="toggleActive" name="active">
                    <button type="submit" class="btn" id="toggleConfirmBtn">Xác nhận</button>
                </form>
            </div>
        </div>
    </div>
</div>

<%-- Confirm Delete Warehouse Modal --%>
<div class="modal fade" id="deleteWarehouseModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Xác nhận xóa kho hàng</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa kho hàng <strong id="deleteWarehouseName"></strong>?</p>
                <p class="text-danger small"><i class="fas fa-exclamation-triangle"></i> Lưu ý: Hành động này là xóa mềm, kho hàng sẽ không xuất hiện trên hệ thống nhưng dữ liệu vẫn được lưu trữ.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="deleteWarehouseForm" action="${pageContext.request.contextPath}/admin/warehouse/delete" method="post" class="d-inline">
                    <input type="hidden" id="deleteWarehouseId" name="warehouseId">
                    <button type="submit" class="btn btn-danger">Xóa kho</button>
                </form>
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

<script>


    $(document).ready(function () {
        $('#warehouseTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: false,
            language: {
                "decimal":        "",
                "emptyTable":     "Không có dữ liệu trong bảng",
                "info":           "Hiển thị từ _START_ đến _END_ trong tổng số _TOTAL_ dòng",
                "infoEmpty":      "Hiển thị 0 đến 0 trong tổng số 0 dòng",
                "infoFiltered":   "(lọc từ tổng số _MAX_ dòng)",
                "infoPostFix":    "",
                "thousands":      ",",
                "lengthMenu":     "Hiển thị _MENU_ dòng",
                "loadingRecords": "Đang tải...",
                "processing":     "Đang xử lý...",
                "search":         "Tìm kiếm:",
                "zeroRecords":    "Không tìm thấy kết quả phù hợp",
                "paginate": {
                    "first":      "Đầu",
                    "last":       "Cuối",
                    "next":       "Tiếp",
                    "previous":   "Trước"
                }
            }
        });
    });

    const allStaff = [
        <% if (allStaff != null) {
            for (int i = 0; i < allStaff.size(); i++) {
                User s = allStaff.get(i);
        %>
            { id: <%= s.getUserId() %>, name: '<%= s.getFullName().replace("'", "\\'") %> (<%= s.getUsername().replace("'", "\\'") %>)', warehouseId: <%= s.getWarehouseId() != null ? s.getWarehouseId() : "null" %> }<%= i < allStaff.size() - 1 ? "," : "" %>
        <% } } %>
    ];

    const allSellers = [
        <% if (allSellers != null) {
            for (int i = 0; i < allSellers.size(); i++) {
                User sel = allSellers.get(i);
        %>
            { id: <%= sel.getUserId() %>, name: '<%= sel.getFullName().replace("'", "\\'") %> (<%= sel.getUsername().replace("'", "\\'") %>)', warehouseId: <%= sel.getWarehouseId() != null ? sel.getWarehouseId() : "null" %> }<%= i < allSellers.size() - 1 ? "," : "" %>
        <% } } %>
    ];

    function buildStaffAndSellerCheckboxes(warehouseId) {
        // 1. Build Staff checkboxes
        const staffContainer = $('#staffContainer');
        staffContainer.empty();
        let hasStaff = false;
        allStaff.forEach(function (s) {
            if (s.warehouseId === null || s.warehouseId === warehouseId) {
                const checked = s.warehouseId === warehouseId ? 'checked' : '';
                staffContainer.append(
                    '<div class="custom-control custom-checkbox mb-1">' +
                    '<input class="custom-control-input" type="checkbox" name="staffIds" value="' + s.id + '" id="staff_' + s.id + '" ' + checked + '>' +
                    '<label class="custom-control-label font-weight-normal text-gray-800" for="staff_' + s.id + '">' + s.name + '</label>' +
                    '</div>'
                );
                hasStaff = true;
            }
        });
        if (!hasStaff) {
            staffContainer.html('<p class="text-muted small italic mb-0">Không có nhân viên STAFF khả dụng.</p>');
        }

        // 2. Build Seller checkboxes
        const sellerContainer = $('#sellerContainer');
        sellerContainer.empty();
        let hasSeller = false;
        allSellers.forEach(function (sel) {
            if (sel.warehouseId === null || sel.warehouseId === warehouseId) {
                const checked = sel.warehouseId === warehouseId ? 'checked' : '';
                sellerContainer.append(
                    '<div class="custom-control custom-checkbox mb-1">' +
                    '<input class="custom-control-input" type="checkbox" name="sellerIds" value="' + sel.id + '" id="seller_' + sel.id + '" ' + checked + '>' +
                    '<label class="custom-control-label font-weight-normal text-gray-800" for="seller_' + sel.id + '">' + sel.name + '</label>' +
                    '</div>'
                );
                hasSeller = true;
            }
        });
        if (!hasSeller) {
            sellerContainer.html('<p class="text-muted small italic mb-0">Không có nhân viên SELLER khả dụng.</p>');
        }
    }

    function openCreateModal() {
        $('#warehouseModalTitle').text('Thêm kho mới');
        $('#warehouseForm').attr('action', '${pageContext.request.contextPath}/admin/warehouse/create');
        $('#warehouseId').val('');
        $('#warehouseName').val('');
        $('#address').val('');
        $('#warehouseManagerId').val('');
        $('#managerId').val('');
        buildStaffAndSellerCheckboxes(0);
        $('#status').val('ACTIVE');

        $('#warehouseModal').modal('show');
    }

    function openEditModal(warehouseId, warehouseName, address, warehouseManagerId, managerId, status) {
        $('#warehouseModalTitle').text('Cập nhật thông tin kho');
        $('#warehouseForm').attr('action', '${pageContext.request.contextPath}/admin/warehouse/update');
        $('#warehouseId').val(warehouseId);
        $('#warehouseName').val(warehouseName);
        $('#address').val(address);
        $('#warehouseManagerId').val(warehouseManagerId > 0 ? warehouseManagerId : '');
        $('#managerId').val(managerId > 0 ? managerId : '');
        buildStaffAndSellerCheckboxes(warehouseId);

        $('#status').val(status === 'ACTIVE' ? 'ACTIVE' : 'INACTIVE');
        $('#warehouseModal').modal('show');
     }

    function openToggleModal(warehouseId, warehouseName, setActive) {
        $('#toggleWarehouseId').val(warehouseId);
        $('#toggleActive').val(setActive);
        if (setActive) {
            $('#toggleModalTitle').text('Kích hoạt kho hàng');
            $('#toggleModalBody').html('Kích hoạt hoạt động lại cho kho hàng <strong>' + warehouseName + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-warning').addClass('btn-success').text('Kích hoạt');
        } else {
            $('#toggleModalTitle').text('Ngưng hoạt động kho');
            $('#toggleModalBody').html('Bạn có chắc chắn muốn ngưng hoạt động cho kho hàng <strong>' + warehouseName + '</strong>?<br><span class="text-danger small"><i class="fas fa-exclamation-triangle"></i> Lưu ý: Hành động này có thể làm ảnh hưởng các tài sản đang liên kết ở kho này.</span>');
            $('#toggleConfirmBtn').removeClass('btn-success').addClass('btn-warning').text('Ngưng hoạt động');
        }
        $('#toggleModal').modal('show');
    }

    function openDeleteModal(warehouseId, warehouseName) {
        $('#deleteWarehouseId').val(warehouseId);
        $('#deleteWarehouseName').text(warehouseName);
        $('#deleteWarehouseModal').modal('show');
    }
</script>

</body>
</html>
