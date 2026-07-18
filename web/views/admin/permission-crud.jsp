<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Permission" %>
<%@ page import="model.User" %>

<%
    @SuppressWarnings("unchecked")
    List<Permission> permissionList = (List<Permission>) request.getAttribute("permissionList");
    @SuppressWarnings("unchecked")
    List<String> allRoles = (List<String>) request.getAttribute("allRoles");
    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    User currentUser = (User) session.getAttribute("currentUser");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý danh sách quyền | Generator Management System</title>

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
                        <i class="fas fa-key text-primary"></i> Quản lý danh sách quyền hệ thống
                    </h1>
                    <button type="button" class="btn btn-primary btn-sm shadow-sm" onclick="showCreateModal()">
                        <i class="fas fa-plus fa-sm text-white-50"></i> Thêm quyền mới
                    </button>
                </div>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Tạo quyền mới thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật thông tin quyền thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Xóa quyền thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_taken".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên quyền đã tồn tại trong hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("invalid_input".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Dữ liệu nhập vào không hợp lệ hoặc thiếu vai trò áp dụng.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("action_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Thao tác thất bại. Vui lòng thử lại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Danh sách quyền hiện có
                            <span class="badge badge-primary"><%= (permissionList != null) ? permissionList.size() : 0 %></span>
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="permissionTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th style="width: 80px;">ID</th>
                                    <th>Mã quyền (permission_name)</th>
                                    <th>Mô tả / Tên hiển thị</th>
                                    <th>Vai trò áp dụng</th>
                                    <th style="width: 180px;">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (permissionList == null || permissionList.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-5">
                                        <i class="fas fa-key fa-3x mb-3 text-gray-400"></i>
                                        <p class="mb-0">Chưa có quyền hệ thống nào</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (Permission p : permissionList) {
                                            String rolesCsv = String.join(",", p.getRoles());
                                %>
                                <tr>
                                    <td class="text-center"><%= p.getPermissionId() %></td>
                                    <td><strong><%= p.getPermissionName() %></strong></td>
                                    <td><%= p.getDescription() != null ? p.getDescription() : "-" %></td>
                                    <td>
                                        <%
                                            if (p.getRoles().isEmpty()) {
                                        %>
                                                <span class="badge badge-secondary">Tất cả vai trò</span>
                                        <%
                                            } else {
                                                for (String rName : p.getRoles()) {
                                        %>
                                                    <span class="badge badge-info text-uppercase mr-1"><%= rName %></span>
                                        <%
                                                }
                                            }
                                        %>
                                    </td>
                                    <td class="text-center">
                                        <button type="button" class="btn btn-sm btn-info shadow-sm mr-1"
                                                onclick="showEditModal(<%= p.getPermissionId() %>, '<%= p.getPermissionName() %>', '<%= p.getDescription() != null ? p.getDescription() : "" %>', '<%= rolesCsv %>')">
                                            <i class="fas fa-edit fa-sm"></i> Sửa
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger shadow-sm"
                                                onclick="showDeleteModal(<%= p.getPermissionId() %>, '<%= p.getPermissionName() %>')">
                                            <i class="fas fa-trash fa-sm"></i> Xóa
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

<!-- Modal Thêm / Sửa Quyền -->
<div class="modal fade" id="permissionModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form id="permissionForm" action="" method="post">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">Thêm quyền hệ thống mới</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="permId" name="id">
                    
                    <div class="form-group">
                        <label for="permName" class="font-weight-bold text-gray-700">Mã quyền (Viết hoa, không dấu, gạch dưới)</label>
                        <input type="text" class="form-control" id="permName" name="name" required placeholder="Ví dụ: MANAGE_GENERATORS" pattern="^[A-Z0-9_]+$">
                        <small class="form-text text-muted">Chỉ cho phép ký tự viết hoa A-Z, số 0-9 và dấu gạch dưới _</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="permDesc" class="font-weight-bold text-gray-700">Mô tả / Tên hiển thị</label>
                        <input type="text" class="form-control" id="permDesc" name="description" required placeholder="Ví dụ: Quyền quản lý máy phát điện">
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold text-gray-700">Vai trò áp dụng <span class="text-danger">*</span></label>
                        <div class="border rounded p-3 bg-light">
                            <%
                                if (allRoles != null) {
                                    for (String rName : allRoles) {
                            %>
                                        <div class="custom-control custom-checkbox custom-control-inline">
                                            <input type="checkbox" class="custom-control-input role-chk" id="role_<%= rName %>" name="roles" value="<%= rName %>">
                                            <label class="custom-control-label font-weight-normal" for="role_<%= rName %>"><%= rName %></label>
                                        </div>
                            <%
                                    }
                                }
                            %>
                        </div>
                        <small class="form-text text-muted">Chọn các vai trò được phép có quyền này</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary" id="saveBtn">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Xác nhận xóa -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Xác nhận xóa quyền</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa quyền hệ thống <strong id="deletePermName" class="text-danger"></strong> không?</p>
                <p class="small text-muted"><i class="fas fa-exclamation-triangle text-warning"></i> <strong>Lưu ý:</strong> Hành động này sẽ tự động thu hồi quyền này từ tất cả tài khoản người dùng đang được gán quyền.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="deleteForm" action="" method="post" class="d-inline">
                    <input type="hidden" id="deletePermId" name="id">
                    <button type="submit" class="btn btn-danger">Xóa quyền</button>
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
        $('#permissionTable').DataTable({
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

    function showCreateModal() {
        $('#permissionForm')[0].reset();
        $('#permId').val('');
        $('#permName').prop('readonly', false);
        $('.role-chk').prop('checked', false);
        $('#modalTitle').text('Thêm quyền hệ thống mới');
        $('#permissionForm').attr('action', '${pageContext.request.contextPath}/admin/permissions-manager/create');
        $('#permissionModal').modal('show');
    }

    function showEditModal(id, name, description, rolesCsv) {
        $('#permissionForm')[0].reset();
        $('#permId').val(id);
        $('#permName').val(name).prop('readonly', true);
        $('#permDesc').val(description);
        
        $('.role-chk').prop('checked', false);
        if (rolesCsv) {
            var rolesArr = rolesCsv.split(',');
            rolesArr.forEach(function(roleName) {
                $('#role_' + roleName).prop('checked', true);
            });
        }
        
        $('#modalTitle').text('Chỉnh sửa quyền: ' + name);
        $('#permissionForm').attr('action', '${pageContext.request.contextPath}/admin/permissions-manager/update');
        $('#permissionModal').modal('show');
    }

    function showDeleteModal(id, name) {
        $('#deletePermId').val(id);
        $('#deletePermName').text(name);
        $('#deleteForm').attr('action', '${pageContext.request.contextPath}/admin/permissions-manager/delete');
        $('#deleteModal').modal('show');
    }
</script>

</body>
</html>
