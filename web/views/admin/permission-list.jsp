<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Warehouse" %>
<%@ page import="model.Permission" %>

<%
    @SuppressWarnings("unchecked")
    List<User> userList = (List<User>) request.getAttribute("userList");
    @SuppressWarnings("unchecked")
    List<Warehouse> warehouseList = (List<Warehouse>) request.getAttribute("warehouseList");
    @SuppressWarnings("unchecked")
    List<Permission> permissionList = (List<Permission>) request.getAttribute("permissionList");
    @SuppressWarnings("unchecked")
    List<String> allRoles = (List<String>) request.getAttribute("allRoles");
    String selectedRole = (String) request.getAttribute("selectedRole");
    
    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    User currentUser = (User) session.getAttribute("currentUser");
%>

<%!
    public String getWarehouseName(User u, List<Warehouse> warehouses) {
        if (u == null) return "<span class='text-muted'>Chưa phân kho</span>";
        
        if ("MANAGER".equals(u.getRoleName())) {
            java.util.List<String> names = new java.util.ArrayList<>();
            if (warehouses != null) {
                for (Warehouse w : warehouses) {
                    if (w.getManagerId() != null && w.getManagerId() == u.getUserId()) {
                        names.add(w.getWarehouseName());
                    }
                }
            }
            if (names.isEmpty()) {
                return "<span class='text-muted'>Chưa phân kho</span>";
            }
            return String.join(", ", names);
        } else if ("WAREHOUSE_MANAGER".equals(u.getRoleName())) {
            if (warehouses != null) {
                for (Warehouse w : warehouses) {
                    if (w.getWarehouseManagerId() != null && w.getWarehouseManagerId() == u.getUserId()) {
                        return w.getWarehouseName();
                    }
                }
            }
            return "<span class='text-muted'>Chưa phân kho</span>";
        } else {
            Integer whId = u.getWarehouseId();
            if (whId == null) return "<span class='text-muted'>Chưa phân kho</span>";
            if (warehouses != null) {
                for (Warehouse w : warehouses) {
                    if (w.getWarehouseId() == whId) {
                        return w.getWarehouseName();
                    }
                }
            }
            return "<span class='text-danger'>N/A</span>";
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Phân quyền người dùng | Generator Management System</title>

    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .table thead th {
            vertical-align: middle !important;
            text-align: center;
        }
        .table thead th.nowrap {
            white-space: nowrap;
        }
        .table tbody td {
            vertical-align: middle !important;
        }
        .text-nowrap {
            white-space: nowrap;
        }
        .permission-badge {
            font-size: 0.85rem;
            padding: 0.4em 0.8em;
            border-radius: 50rem;
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
                        <i class="fas fa-shield-alt text-primary"></i> Quản lý phân quyền người dùng
                    </h1>
                </div>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <% if ("permission_updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật quyền người dùng thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("invalid_user".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tài khoản không hợp lệ hoặc không thuộc hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("update_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Không thể cập nhật quyền. Vui lòng thử lại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("invalid_id".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> ID người dùng không hợp lệ.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <!-- Bộ lọc theo vai trò -->
                <div class="card shadow mb-4">
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/admin/permissions" id="filterForm">
                            <div class="row align-items-end">
                                <div class="col-md-4">
                                    <label for="roleSelect" class="font-weight-bold text-gray-700">Lọc theo vai trò:</label>
                                    <select name="role" id="roleSelect" class="form-control" onchange="document.getElementById('filterForm').submit()">
                                        <option value="ALL" <%= "ALL".equals(selectedRole) ? "selected" : "" %>>-- Tất cả vai trò --</option>
                                        <%
                                            if (allRoles != null) {
                                                for (String r : allRoles) {
                                        %>
                                                    <option value="<%= r %>" <%= r.equals(selectedRole) ? "selected" : "" %>><%= r %></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Danh sách tài khoản hiển thị
                            <span class="badge badge-primary"><%= (userList != null) ? userList.size() : 0 %></span>
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="staffTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th style="width: 60px;" class="nowrap">ID</th>
                                    <th style="width: 140px;" class="nowrap">Tài khoản</th>
                                    <th class="nowrap">Họ tên</th>
                                    <th style="width: 120px;" class="nowrap">Vai trò</th>
                                    <th style="width: 200px;" class="nowrap">Kho hàng trực thuộc</th>
                                    <th style="width: 110px;" class="nowrap">Trạng thái</th>
                                    <%
                                        if (permissionList != null) {
                                            for (Permission p : permissionList) {
                                    %>
                                                <th style="width: 160px; min-width: 160px; max-width: 160px; white-space: normal;"><%= p.getDescription() != null ? p.getDescription() : p.getPermissionName() %></th>
                                    <%
                                            }
                                        }
                                    %>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (userList == null || userList.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="<%= 6 + (permissionList != null ? permissionList.size() : 0) %>" class="text-center text-muted py-5">
                                        <i class="fas fa-user-friends fa-3x mb-3 text-gray-400"></i>
                                        <p class="mb-0">Không tìm thấy người dùng nào</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (User u : userList) {
                                %>
                                <tr>
                                    <td class="text-center"><%= u.getUserId() %></td>
                                    <td><strong><%= u.getUsername() %></strong></td>
                                    <td><%= u.getFullName() != null ? u.getFullName() : "-" %></td>
                                    <td class="text-center">
                                        <span class="badge badge-info text-uppercase"><%= u.getRoleName() %></span>
                                    </td>
                                    <td><%= getWarehouseName(u, warehouseList) %></td>
                                    <td class="text-center">
                                        <% if (u.isActive()) { %>
                                            <span class="badge badge-success">Hoạt động</span>
                                        <% } else { %>
                                            <span class="badge badge-danger">Đã khóa</span>
                                        <% } %>
                                    </td>
                                    
                                    <%
                                        if (permissionList != null) {
                                            for (Permission p : permissionList) {
                                                boolean isApplicable = p.getRoles().isEmpty() || p.getRoles().contains(u.getRoleName());
                                                boolean hasPerm = u.getPermissions().contains(p.getPermissionName());
                                                String pDesc = p.getDescription() != null ? p.getDescription() : p.getPermissionName();
                                    %>
                                                <td class="text-center">
                                                    <% if (isApplicable) { %>
                                                        <% if (hasPerm) { %>
                                                            <div class="d-flex flex-column align-items-center justify-content-center">
                                                                <span class="badge badge-primary px-2 py-1 mb-1 shadow-sm" style="font-size: 0.75rem;">
                                                                    <i class="fas fa-check-circle"></i> Được cấp
                                                                </span>
                                                                <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2 shadow-sm" style="font-size: 0.7rem; line-height: 1.2;" title="Thu hồi quyền"
                                                                        onclick="showToggleModal(<%= u.getUserId() %>, '<%= u.getUsername() %>', '<%= p.getPermissionName() %>', '<%= pDesc %>', false, '<%= selectedRole %>')">
                                                                    <i class="fas fa-times"></i> Thu hồi
                                                                </button>
                                                            </div>
                                                        <% } else { %>
                                                            <div class="d-flex flex-column align-items-center justify-content-center">
                                                                <span class="badge badge-secondary px-2 py-1 mb-1" style="font-size: 0.75rem; opacity: 0.85;">
                                                                    <i class="fas fa-times-circle"></i> Chưa cấp
                                                                </span>
                                                                <button type="button" class="btn btn-sm btn-outline-success py-0 px-2 shadow-sm" style="font-size: 0.7rem; line-height: 1.2;" title="Cấp quyền"
                                                                        onclick="showToggleModal(<%= u.getUserId() %>, '<%= u.getUsername() %>', '<%= p.getPermissionName() %>', '<%= pDesc %>', true, '<%= selectedRole %>')">
                                                                    <i class="fas fa-check"></i> Cấp quyền
                                                                </button>
                                                            </div>
                                                        <% } %>
                                                    <% } else { %>
                                                        <span class="text-muted small font-italic"><i class="fas fa-ban text-gray-400"></i> Không áp dụng</span>
                                                    <% } %>
                                                </td>
                                    <%
                                            }
                                        }
                                    %>
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

<!-- Modal xác nhận cấp/thu hồi quyền -->
<div class="modal fade" id="toggleModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="toggleModalTitle">Xác nhận quyền hạn</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p id="toggleModalBody"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="toggleForm" action="" method="post" class="d-inline">
                    <input type="hidden" id="toggleStaffId" name="staffId">
                    <button type="submit" class="btn" id="toggleConfirmBtn">Xác nhận</button>
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
        $('#staffTable').DataTable({
            "language": {
                "lengthMenu": "Hiển thị _MENU_ dòng mỗi trang",
                "zeroRecords": "Không tìm thấy dữ liệu",
                "info": "Trang _PAGE_ / _PAGES_",
                "infoEmpty": "Không có dữ liệu",
                "infoFiltered": "(lọc từ _MAX_ dòng)",
                "paginate": {
                    "first": "Đầu",
                    "last": "Cuối",
                    "next": "Sau",
                    "previous": "Trước"
                }
            },
            "pageLength": 10,
            "ordering": true,
            "searching": true
        });
    });

    function showToggleModal(staffId, username, permissionName, permissionDesc, setAllowed, selectedRole) {
        $('#toggleStaffId').val(staffId);
        
        var form = $('#toggleForm');
        form.find('input[type="hidden"]').not('#toggleStaffId').remove();
        
        form.append('<input type="hidden" name="permissionName" value="' + permissionName + '">');
        form.append('<input type="hidden" name="enable" value="' + setAllowed + '">');
        form.append('<input type="hidden" name="selectedRole" value="' + selectedRole + '">');
        
        var actionUrl = '${pageContext.request.contextPath}/admin/permissions/toggle';
        form.attr('action', actionUrl);
        
        var title = '';
        var bodyText = '';
        if (setAllowed) {
            title = 'Cấp quyền ' + permissionDesc;
            bodyText = 'Bạn có chắc muốn <strong>cấp quyền ' + permissionDesc + '</strong> cho người dùng <strong>' + username + '</strong>?';
        } else {
            title = 'Thu hồi quyền ' + permissionDesc;
            bodyText = 'Bạn có chắc muốn <strong>thu hồi quyền ' + permissionDesc + '</strong> từ người dùng <strong>' + username + '</strong>?';
        }
        
        $('#toggleModalTitle').text(title);
        $('#toggleModalBody').html(bodyText);
        
        if (setAllowed) {
            $('#toggleConfirmBtn').removeClass('btn-danger').addClass('btn-success').text('Cấp quyền');
        } else {
            $('#toggleConfirmBtn').removeClass('btn-success').addClass('btn-danger').text('Thu hồi');
        }
        $('#toggleModal').modal('show');
    }
</script>

</body>
</html>