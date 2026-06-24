<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Supplier" %>
<%@ page import="model.User" %>

<%
    @SuppressWarnings("unchecked")
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");

    String q = (String) request.getAttribute("q");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");

    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManageSuppliers = currentUser != null
            && (currentUser.hasRole("ADMIN")
            || currentUser.hasRole("MANAGER")
            || currentUser.hasRole("WAREHOUSE_MANAGER"));
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý nhà cung cấp | Generator Management System</title>

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
        .supplier-name-col {
            min-width: 190px;
            max-width: 280px;
        }
        .text-nowrap {
            white-space: nowrap;
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
                        <i class="fas fa-truck text-primary"></i> Quản lý nhà cung cấp
                    </h1>
                    <% if (canManageSuppliers) { %>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Thêm nhà cung cấp
                    </button>
                    <% } %>
                </div>

                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã thêm nhà cung cấp mới.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã cập nhật thông tin nhà cung cấp.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("status_updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã cập nhật trạng thái hoạt động nhà cung cấp.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Xóa nhà cung cấp thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("delete_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Xóa nhà cung cấp thất bại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("email_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Email nhà cung cấp đã tồn tại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("missing_required".equals(errorParam)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> Vui lòng nhập tên nhà cung cấp.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if (errorParam != null && !errorParam.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Có lỗi xảy ra khi xử lý dữ liệu nhà cung cấp.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 bg-white">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-filter"></i> Bộ lọc
                        </h6>
                    </div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/suppliers" class="row">
                            <div class="form-group col-md-6">
                                <label for="q">Tìm kiếm</label>
                                <input type="text" id="q" name="q" class="form-control"
                                       placeholder="Tên, email, số điện thoại, địa chỉ..."
                                       value="<%= q != null ? q : "" %>">
                            </div>
                            <div class="form-group col-md-3">
                                <label for="status">Trạng thái</label>
                                <select id="status" name="status" class="form-control">
                                    <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>Tất cả</option>
                                    <option value="ACTIVE" <%= "ACTIVE".equals(statusFilter) ? "selected" : "" %>>Đang hoạt động</option>
                                    <option value="INACTIVE" <%= "INACTIVE".equals(statusFilter) ? "selected" : "" %>>Ngừng hoạt động</option>
                                </select>
                            </div>
                            <div class="form-group col-md-3 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="fas fa-search"></i> Tìm kiếm
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Nhà cung cấp
                            <span class="badge badge-primary"><%= suppliers != null ? suppliers.size() : 0 %></span>
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="supplierTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>ID</th>
                                    <th class="supplier-name-col text-left">Tên nhà cung cấp</th>
                                    <th>Email</th>
                                    <th>Số điện thoại</th>
                                    <th>Địa chỉ</th>
                                    <th>Trạng thái</th>
                                    <% if (canManageSuppliers) { %>
                                    <th style="width: 150px;">Hành động</th>
                                    <% } %>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (suppliers == null || suppliers.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="<%= canManageSuppliers ? 7 : 6 %>" class="text-center text-muted py-4">
                                        <i class="fas fa-inbox fa-3x mb-3 text-gray-300"></i>
                                        <p class="m-0">Không tìm thấy nhà cung cấp nào.</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (Supplier s : suppliers) {
                                            String status = s.getStatus() != null ? s.getStatus() : "ACTIVE";
                                            String badgeClass = "ACTIVE".equals(status) ? "badge-success" : "badge-secondary";
                                            String statusText = "ACTIVE".equals(status) ? "Đang hoạt động" : "Ngừng hoạt động";

                                            String safeName = js(s.getSupplierName());
                                            String safePhone = js(s.getPhone());
                                            String safeEmail = js(s.getEmail());
                                            String safeAddress = js(s.getAddress());
                                %>
                                <tr>
                                    <td class="text-center text-nowrap"><%= s.getSupplierId() %></td>
                                    <td class="supplier-name-col">
                                        <span class="font-weight-bold text-gray-900"><%= html(s.getSupplierName()) %></span>
                                    </td>
                                    <td class="text-nowrap"><%= s.getEmail() != null && !s.getEmail().isEmpty() ? html(s.getEmail()) : "-" %></td>
                                    <td class="text-nowrap"><%= s.getPhone() != null && !s.getPhone().isEmpty() ? html(s.getPhone()) : "-" %></td>
                                    <td><%= s.getAddress() != null && !s.getAddress().isEmpty() ? html(s.getAddress()) : "-" %></td>
                                    <td class="text-center text-nowrap">
                                        <span class="badge <%= badgeClass %> px-2 py-1"><%= statusText %></span>
                                    </td>
                                    <% if (canManageSuppliers) { %>
                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-info"
                                                onclick="openEditModal(<%= s.getSupplierId() %>, '<%= safeName %>', '<%= safePhone %>', '<%= safeEmail %>', '<%= safeAddress %>', '<%= status %>')"
                                                title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <form method="post" action="${pageContext.request.contextPath}/suppliers/status" class="d-inline">
                                            <input type="hidden" name="supplierId" value="<%= s.getSupplierId() %>">
                                            <input type="hidden" name="status" value="<%= "ACTIVE".equals(status) ? "INACTIVE" : "ACTIVE" %>">
                                            <button type="submit"
                                                    class="btn btn-sm <%= "ACTIVE".equals(status) ? "btn-warning" : "btn-success" %>"
                                                    title="<%= "ACTIVE".equals(status) ? "Ngừng hoạt động" : "Kích hoạt lại" %>">
                                                <i class="fas <%= "ACTIVE".equals(status) ? "fa-ban" : "fa-check" %>"></i>
                                            </button>
                                        </form>
                                        <button type="button" class="btn btn-sm btn-danger"
                                                onclick="openDeleteModal(<%= s.getSupplierId() %>, '<%= safeName %>')"
                                                title="Xóa nhà cung cấp">
                                            <i class="fas fa-trash"></i>
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

<% if (canManageSuppliers) { %>
<div class="modal fade" id="supplierModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <form id="supplierForm" method="post" action="${pageContext.request.contextPath}/suppliers/create">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="supplierModalTitle">Thêm nhà cung cấp</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="supplierId" name="supplierId">

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="supplierName">Tên nhà cung cấp <span class="text-danger">*</span></label>
                            <input type="text" id="supplierName" name="supplierName" class="form-control" required maxlength="100">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" class="form-control" maxlength="100">
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="phone">Số điện thoại</label>
                            <input type="text" id="phone" name="phone" class="form-control" maxlength="20">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="statusInput">Trạng thái</label>
                            <select id="statusInput" name="status" class="form-control">
                                <option value="ACTIVE">Đang hoạt động</option>
                                <option value="INACTIVE">Ngừng hoạt động</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="address">Địa chỉ</label>
                        <input type="text" id="address" name="address" class="form-control" maxlength="255">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Lưu
                    </button>
                </div>
            </form>
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
        $('#supplierTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: false,
            lengthChange: false,
            language: {
                paginate: {
                    next: 'Sau',
                    previous: 'Trước'
                },
                emptyTable: 'Không có dữ liệu trong bảng',
                info: 'Hiển thị từ dòng _START_ đến _END_ trên tổng số _TOTAL_ dòng',
                infoEmpty: 'Không có dữ liệu hiển thị'
            }
        });
    });

    <% if (canManageSuppliers) { %>
    function openCreateModal() {
        $('#supplierModalTitle').text('Thêm nhà cung cấp');
        $('#supplierForm').attr('action', '${pageContext.request.contextPath}/suppliers/create');
        $('#supplierId').val('');
        $('#supplierName').val('');
        $('#phone').val('');
        $('#email').val('');
        $('#address').val('');
        $('#statusInput').val('ACTIVE');
        $('#supplierModal').modal('show');
    }

    function openEditModal(supplierId, supplierName, phone, email, address, status) {
        $('#supplierModalTitle').text('Cập nhật nhà cung cấp');
        $('#supplierForm').attr('action', '${pageContext.request.contextPath}/suppliers/update');
        $('#supplierId').val(supplierId);
        $('#supplierName').val(supplierName);
        $('#phone').val(phone);
        $('#email').val(email);
        $('#address').val(address);
        $('#statusInput').val(status || 'ACTIVE');
        $('#supplierModal').modal('show');
    }
    
    function openDeleteModal(supplierId, supplierName) {
        $('#deleteSupplierId').val(supplierId);
        $('#deleteSupplierName').text(supplierName);
        $('#deleteSupplierModal').modal('show');
    }
    <% } %>
</script>

<% if (canManageSuppliers) { %>
<div class="modal fade" id="deleteSupplierModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Xác nhận xóa nhà cung cấp</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa nhà cung cấp <strong id="deleteSupplierName"></strong>?</p>
                <p class="text-danger small"><i class="fas fa-exclamation-triangle"></i> Lưu ý: Hành động này là xóa mềm, nhà cung cấp sẽ không xuất hiện trên hệ thống nhưng dữ liệu vẫn được lưu trữ.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="deleteSupplierForm" action="${pageContext.request.contextPath}/suppliers/delete" method="post" class="d-inline">
                    <input type="hidden" id="deleteSupplierId" name="supplierId">
                    <button type="submit" class="btn btn-danger">Xóa nhà cung cấp</button>
                </form>
            </div>
        </div>
    </div>
</div>
<% } %>

</body>
</html>

<%!
    private String html(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String js(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
%>
