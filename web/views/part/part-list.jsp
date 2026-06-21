<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.Part" %>
<%@ page import="model.Warehouse" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>

<%
    @SuppressWarnings("unchecked")
    List<Part> parts = (List<Part>) request.getAttribute("parts");
    @SuppressWarnings("unchecked")
    List<Warehouse> warehouses = (List<Warehouse>) request.getAttribute("warehouses");

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
    <title>Quản lý phụ tùng | Generator Management System</title>
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
                    <h1 class="h3 mb-0 text-gray-800"><i class="fas fa-cogs text-primary"></i> Quản lý danh mục phụ tùng</h1>
                    <% if (isWarehouseManager) { %>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Thêm phụ tùng mới
                    </button>
                    <% } %>
                </div>

                <!-- Notifications -->
                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Thêm phụ tùng mới thành công!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật thông tin thành công!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã xóa phụ tùng thành công!
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("code_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Mã phụ tùng này đã tồn tại trong hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if (errorParam != null && !errorParam.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Thao tác không thành công. Lỗi hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <!-- Filters -->
                <div class="card shadow mb-4">
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/parts" class="row">
                            <div class="form-group col-md-4">
                                <label for="q">Tìm kiếm</label>
                                <input type="text" id="q" name="q" class="form-control" placeholder="Tìm tên hoặc mã phụ tùng..." value="<%= q != null ? q : "" %>">
                            </div>
                            <div class="form-group col-md-3">
                                <label for="warehouseId">Kho lưu trữ</label>
                                <select id="warehouseId" name="warehouseId" class="form-control" <%= isWarehouseManager ? "disabled" : "" %>>
                                    <option value="">--- Tất cả kho ---</option>
                                    <% if (warehouses != null) {
                                        for (Warehouse w : warehouses) { %>
                                        <option value="<%= w.getWarehouseId() %>" <%= (warehouseIdFilter != null && warehouseIdFilter == w.getWarehouseId()) ? "selected" : "" %>><%= w.getWarehouseName() %></option>
                                    <% } } %>
                                </select>
                                <% if (isWarehouseManager) { %>
                                    <input type="hidden" name="warehouseId" value="<%= warehouseIdFilter %>">
                                <% } %>
                            </div>
                            <div class="form-group col-md-3">
                                <label for="status">Trạng thái</label>
                                <select id="status" name="status" class="form-control">
                                    <option value="">--- Tất cả ---</option>
                                    <option value="ACTIVE" <%= "ACTIVE".equals(statusFilter) ? "selected" : "" %>>Hoạt động (ACTIVE)</option>
                                    <option value="INACTIVE" <%= "INACTIVE".equals(statusFilter) ? "selected" : "" %>>Ngừng hoạt động (INACTIVE)</option>
                                </select>
                            </div>
                            <div class="form-group col-md-2 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100 shadow-sm"><i class="fas fa-search"></i> Lọc</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Table -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Danh mục linh kiện</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="partsTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                    <tr>
                                        <th>Mã phụ tùng</th>
                                        <th>Tên phụ tùng</th>
                                        <th>Số lượng</th>
                                        <th>Ngưỡng cảnh báo</th>
                                        <th>Đơn vị tính</th>
                                        <th>Kho</th>
                                        <th>Trạng thái</th>
                                        <% if (isWarehouseManager) { %>
                                        <th>Hành động</th>
                                        <% } %>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (parts != null) {
                                        for (Part p : parts) { 
                                            String whName = "Không xác định";
                                            if (warehouses != null) {
                                                for (Warehouse w : warehouses) {
                                                    if (w.getWarehouseId() == p.getWarehouseId()) {
                                                        whName = w.getWarehouseName();
                                                        break;
                                                    }
                                                }
                                            }
                                    %>
                                        <tr>
                                            <td><code><%= p.getPartCode() %></code></td>
                                            <td><strong><%= p.getPartName() %></strong></td>
                                            <td><%= p.getQuantity() %></td>
                                            <td><%= p.getMinQuantity() %></td>
                                            <td><%= p.getUnit() %></td>
                                            <td><%= whName %></td>
                                            <td>
                                                <span class="badge <%= "ACTIVE".equals(p.getStatus()) ? "badge-success" : "badge-secondary" %>"><%= p.getStatus() %></span>
                                            </td>
                                            <% if (isWarehouseManager) { %>
                                            <td>
                                                <button type="button" class="btn btn-info btn-sm shadow-sm" onclick="openEditModal(<%= p.getPartId() %>, '<%= p.getPartName().replace("'", "\\'") %>', '<%= p.getPartCode().replace("'", "\\'") %>', <%= p.getQuantity() %>, <%= p.getMinQuantity() %>, '<%= p.getUnit() %>', '<%= p.getStatus() %>')"><i class="fas fa-edit"></i></button>
                                                <button type="button" class="btn btn-danger btn-sm shadow-sm" onclick="openDeleteModal(<%= p.getPartId() %>, '<%= p.getPartName().replace("'", "\\'") %>')"><i class="fas fa-trash-alt"></i></button>
                                            </td>
                                            <% } %>
                                        </tr>
                                    <% } } %>
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
<!-- Add / Edit Modal -->
<div class="modal fade" id="partModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form id="partForm" method="post" action="${pageContext.request.contextPath}/parts/create">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="partModalTitle">Thêm phụ tùng</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="formPartId" name="partId">
                    
                    <div class="form-group">
                        <label for="formPartCode">Mã phụ tùng <span class="text-danger">*</span></label>
                        <input type="text" id="formPartCode" name="partCode" class="form-control" required maxlength="50">
                    </div>

                    <div class="form-group">
                        <label for="formPartName">Tên phụ tùng <span class="text-danger">*</span></label>
                        <input type="text" id="formPartName" name="partName" class="form-control" required maxlength="100">
                    </div>

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="formQuantity">Số lượng nhập ban đầu</label>
                            <input type="number" id="formQuantity" name="quantity" class="form-control" min="0" value="0">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formMinQuantity">Ngưỡng cảnh báo tối thiểu</label>
                            <input type="number" id="formMinQuantity" name="minQuantity" class="form-control" min="0" value="5">
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="formUnit">Đơn vị tính</label>
                            <select id="formUnit" name="unit" class="form-control">
                                <option value="Cai">Cái (Cai)</option>
                                <option value="Met">Mét (Met)</option>
                                <option value="Cuon">Cuộn (Cuon)</option>
                                <option value="Bo">Bộ (Bo)</option>
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="formStatus">Trạng thái</label>
                            <select id="formStatus" name="status" class="form-control">
                                <option value="ACTIVE">Hoạt động (ACTIVE)</option>
                                <option value="INACTIVE">Ngừng hoạt động (INACTIVE)</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Lưu dữ liệu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Modal -->
<div class="modal fade" id="deletePartModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/parts/delete">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">Xác nhận xóa phụ tùng</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="deletePartId" name="partId">
                    <p>Bạn có chắc chắn muốn xóa phụ tùng <strong id="deletePartName"></strong> ra khỏi danh mục?</p>
                    <div class="alert alert-warning">Lưu ý: Không thể xóa nếu linh kiện đã có lịch sử nhập xuất kho.</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-danger">Đồng ý xóa</button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script>
    function openCreateModal() {
        $('#partModalTitle').text('Thêm phụ tùng mới');
        $('#partForm').attr('action', '${pageContext.request.contextPath}/parts/create');
        $('#formPartId').val('');
        $('#formPartCode').val('').prop('readonly', false);
        $('#formPartName').val('');
        $('#formQuantity').val(0);
        $('#formMinQuantity').val(5);
        $('#formUnit').val('Cai');
        $('#formStatus').val('ACTIVE');
        $('#partModal').modal('show');
    }

    function openEditModal(partId, name, code, qty, minQty, unit, status) {
        $('#partModalTitle').text('Chỉnh sửa thông tin phụ tùng');
        $('#partForm').attr('action', '${pageContext.request.contextPath}/parts/update');
        $('#formPartId').val(partId);
        $('#formPartCode').val(code).prop('readonly', true);
        $('#formPartName').val(name);
        $('#formQuantity').val(qty);
        $('#formMinQuantity').val(minQty);
        $('#formUnit').val(unit);
        $('#formStatus').val(status);
        $('#partModal').modal('show');
    }

    function openDeleteModal(partId, name) {
        $('#deletePartId').val(partId);
        $('#deletePartName').text(name);
        $('#deletePartModal').modal('show');
    }
</script>
</body>
</html>
