<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Role" %>

<%
    @SuppressWarnings("unchecked")
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    @SuppressWarnings("unchecked")
    Map<Integer, Integer> roleUserCounts = (Map<Integer, Integer>) request.getAttribute("roleUserCounts");

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
    <title>Quản lý Vai trò | Generator Management System</title>

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
                        <i class="fas fa-user-shield text-primary"></i> Quản lý Vai trò
                    </h1>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Thêm Vai trò
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
                    <i class="fas fa-check-circle"></i> Thêm vai trò mới thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật vai trò thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("activated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Kích hoạt vai trò thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deactivated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Hủy kích hoạt vai trò thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Xóa vai trò thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("role_in_use".equals(errorParam)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> Vai trò này đang được gán cho người dùng và không thể hủy kích hoạt hoặc xóa.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_taken".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên vai trò đã tồn tại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_format".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tên vai trò phải sử dụng chữ viết hoa, chữ số và dấu gạch dưới.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("delete_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Không thể xóa vai trò. Vui lòng thử lại sau.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if (errorParam != null && !errorParam.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Không thể hoàn thành tác vụ. Vui lòng kiểm tra lại dữ liệu đầu vào.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Vai trò
                            <span class="badge badge-primary"><%= roles != null ? roles.size() : 0 %></span>
                        </h6>

                        <form class="form-inline" method="get" action="${pageContext.request.contextPath}/admin/roles">
                            <div class="form-group mr-2 mb-2">
                                <label for="q" class="mr-1">Tìm kiếm</label>
                                <input id="q" name="q" class="form-control form-control-sm"
                                       placeholder="Vai trò / mô tả"
                                       value="<%= q != null ? q : "" %>">
                            </div>
                            <div class="form-group mr-2 mb-2">
                                <label for="statusFilter" class="mr-1">Trạng thái</label>
                                <select id="statusFilter" name="status" class="form-control form-control-sm">
                                    <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>Tất cả</option>
                                    <option value="active" <%= "active".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Hoạt động</option>
                                    <option value="inactive" <%= "inactive".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Không hoạt động</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-sm btn-outline-primary mb-2">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                        </form>
                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="roleTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th style="width:80px">ID</th>
                                    <th>Vai trò</th>
                                    <th>Mô tả</th>
                                    <th style="width:120px">Người dùng</th>
                                    <th style="width:130px">Trạng thái</th>
                                    <th style="width:150px">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (roles == null || roles.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted">
                                        <i class="fas fa-inbox fa-3x mt-3 mb-3"></i>
                                        <p>Không tìm thấy vai trò nào.</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (Role role : roles) {
                                            int userCount = 0;
                                            if (roleUserCounts != null && roleUserCounts.get(role.getRoleId()) != null) {
                                                userCount = roleUserCounts.get(role.getRoleId());
                                            }
                                            boolean active = "ACTIVE".equalsIgnoreCase(role.getStatus());
                                            String roleName = role.getRoleName() != null ? role.getRoleName() : "";
                                            String description = role.getDescription() != null ? role.getDescription() : "";
                                            String safeRoleName = roleName.replace("\\", "\\\\").replace("'", "\\'");
                                            String safeDescription = description.replace("\\", "\\\\").replace("'", "\\'").replace("\r", "").replace("\n", "\\n");
                                %>
                                <tr>
                                    <td><%= role.getRoleId() %></td>
                                    <td>
                                        <span class="font-weight-bold text-gray-900"><%= roleName %></span>
                                    </td>
                                    <td><%= description.isEmpty() ? "-" : description %></td>
                                    <td>
                                        <span class="badge badge-light border">
                                            <i class="fas fa-users"></i> <%= userCount %>
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <% if (active) { %>
                                        <span class="badge badge-success">Hoạt động</span>
                                        <% } else { %>
                                        <span class="badge badge-secondary">Không hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-info"
                                                onclick="openEditModal(<%= role.getRoleId() %>, '<%= safeRoleName %>', '<%= safeDescription %>', '<%= role.getStatus() %>')"
                                                title="Sửa">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <% if (active) { %>
                                        <button type="button" class="btn btn-sm btn-warning"
                                                onclick="openToggleModal(<%= role.getRoleId() %>, '<%= safeRoleName %>', false, <%= userCount %>)"
                                                title="Hủy kích hoạt">
                                            <i class="fas fa-ban"></i>
                                        </button>
                                        <% } else { %>
                                        <button type="button" class="btn btn-sm btn-success"
                                                onclick="openToggleModal(<%= role.getRoleId() %>, '<%= safeRoleName %>', true, <%= userCount %>)"
                                                title="Kích hoạt">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <% } %>

                                        <button type="button" class="btn btn-sm btn-danger"
                                                <%= userCount > 0 ? "disabled" : "" %>
                                                onclick="openConfirmDeleteModal(<%= role.getRoleId() %>, '<%= safeRoleName %>')"
                                                title="<%= userCount > 0 ? "Không thể xóa vai trò đang sử dụng" : "Xóa" %>">
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

<div class="modal fade" id="roleModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form id="roleForm" method="post" action="${pageContext.request.contextPath}/admin/roles/create">
                <div class="modal-header">
                    <h5 class="modal-title" id="roleModalTitle">Thêm Vai trò</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="roleId" name="roleId">

                    <div class="form-group">
                        <label for="roleName">Tên vai trò <span class="text-danger">*</span></label>
                        <input type="text" id="roleName" name="roleName" class="form-control"
                               maxlength="50" required placeholder="WAREHOUSE_MANAGER">
                        <small class="form-text text-muted">Sử dụng chữ viết hoa, chữ số và dấu gạch dưới.</small>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" class="form-control" rows="3" maxlength="255"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng thái</label>
                        <select id="status" name="status" class="form-control">
                            <option value="ACTIVE">Hoạt động</option>
                            <option value="INACTIVE">Không hoạt động</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Lưu
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="toggleModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="toggleModalTitle">Xác nhận</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p id="toggleModalBody"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="toggleForm" action="${pageContext.request.contextPath}/admin/roles/toggle-status" method="post" class="d-inline">
                    <input type="hidden" id="toggleRoleId" name="roleId">
                    <input type="hidden" id="toggleActive" name="active">
                    <button type="submit" class="btn" id="toggleConfirmBtn">Xác nhận</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Delete Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title text-danger"><i class="fas fa-exclamation-triangle"></i> Xác nhận Xóa</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa vai trò <strong id="deleteRoleName"></strong>?</p>
                <p class="text-danger"><small>Hành động này không thể hoàn tác. Vai trò này sẽ bị xóa (soft-delete).</small></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <form id="deleteForm" action="${pageContext.request.contextPath}/admin/roles/delete" method="post" class="d-inline">
                    <input type="hidden" id="deleteRoleId" name="roleId">
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-trash"></i> Xóa
                    </button>
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
        $('#roleTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: false
        });
    });

    function openCreateModal() {
        $('#roleModalTitle').text('Thêm Vai trò');
        $('#roleForm').attr('action', '${pageContext.request.contextPath}/admin/roles/create');
        $('#roleId').val('');
        $('#roleName').val('');
        $('#description').val('');
        $('#status').val('ACTIVE');
        $('#roleModal').modal('show');
    }

    function openEditModal(roleId, roleName, description, status) {
        $('#roleModalTitle').text('Sửa Vai trò');
        $('#roleForm').attr('action', '${pageContext.request.contextPath}/admin/roles/update');
        $('#roleId').val(roleId);
        $('#roleName').val(roleName);
        $('#description').val(description);
        $('#status').val(status === 'ACTIVE' ? 'ACTIVE' : 'INACTIVE');
        $('#roleModal').modal('show');
    }

    function openToggleModal(roleId, roleName, setActive, userCount) {
        $('#toggleRoleId').val(roleId);
        $('#toggleActive').val(setActive);
        if (setActive) {
            $('#toggleModalTitle').text('Kích hoạt vai trò');
            $('#toggleModalBody').html('Kích hoạt vai trò <strong>' + roleName + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-warning').addClass('btn-success').text('Kích hoạt');
        } else {
            $('#toggleModalTitle').text('Hủy kích hoạt vai trò');
            if (userCount > 0) {
                $('#toggleModalBody').html('Vai trò <strong>' + roleName + '</strong> đang được gán cho <strong>' + userCount + '</strong> người dùng. Không thể hủy kích hoạt cho đến khi người dùng được chuyển sang vai trò khác.');
                $('#toggleConfirmBtn').prop('disabled', true).removeClass('btn-success').addClass('btn-warning').text('Không thể hủy kích hoạt');
            } else {
                $('#toggleModalBody').html('Hủy kích hoạt vai trò <strong>' + roleName + '</strong>? Vai trò này sẽ không thể chọn khi tạo người dùng mới.');
                $('#toggleConfirmBtn').prop('disabled', false).removeClass('btn-success').addClass('btn-warning').text('Hủy kích hoạt');
            }
        }
        if (setActive) {
            $('#toggleConfirmBtn').prop('disabled', false);
        }
        $('#toggleModal').modal('show');
    }

    function openConfirmDeleteModal(roleId, roleName) {
        $('#deleteRoleId').val(roleId);
        $('#deleteRoleName').text(roleName);
        $('#deleteModal').modal('show');
    }
</script>

</body>
</html>
