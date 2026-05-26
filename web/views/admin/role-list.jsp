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
    <title>Role Management | Generator Management System</title>

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
                        <i class="fas fa-user-shield text-primary"></i> Role Management
                    </h1>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Create Role
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
                    <i class="fas fa-check-circle"></i> Role created successfully.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Role updated successfully.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("activated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Role activated successfully.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deactivated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Role deactivated successfully.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("role_in_use".equals(errorParam)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> This role is assigned to users and cannot be deactivated.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_taken".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Role name already exists.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("name_format".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Role name must use uppercase letters, numbers, and underscores.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if (errorParam != null && !errorParam.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Could not complete the action. Please check your input.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Roles
                            <span class="badge badge-primary"><%= roles != null ? roles.size() : 0 %></span>
                        </h6>

                        <form class="form-inline" method="get" action="${pageContext.request.contextPath}/admin/roles">
                            <div class="form-group mr-2 mb-2">
                                <label for="q" class="mr-1">Search</label>
                                <input id="q" name="q" class="form-control form-control-sm"
                                       placeholder="Role / description"
                                       value="<%= q != null ? q : "" %>">
                            </div>
                            <div class="form-group mr-2 mb-2">
                                <label for="statusFilter" class="mr-1">Status</label>
                                <select id="statusFilter" name="status" class="form-control form-control-sm">
                                    <option value="" <%= statusFilter == null || statusFilter.isEmpty() ? "selected" : "" %>>All</option>
                                    <option value="active" <%= "active".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Active</option>
                                    <option value="inactive" <%= "inactive".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Inactive</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-sm btn-outline-primary mb-2">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                        </form>
                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="roleTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th style="width:80px">ID</th>
                                    <th>Role</th>
                                    <th>Description</th>
                                    <th style="width:120px">Users</th>
                                    <th style="width:130px">Status</th>
                                    <th style="width:150px">Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (roles == null || roles.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted">
                                        <i class="fas fa-inbox fa-3x mt-3 mb-3"></i>
                                        <p>No roles found.</p>
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
                                        <span class="badge badge-success">Active</span>
                                        <% } else { %>
                                        <span class="badge badge-secondary">Inactive</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-info"
                                                onclick="openEditModal(<%= role.getRoleId() %>, '<%= safeRoleName %>', '<%= safeDescription %>', '<%= role.getStatus() %>')"
                                                title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <% if (active) { %>
                                        <button type="button" class="btn btn-sm btn-warning"
                                                onclick="openToggleModal(<%= role.getRoleId() %>, '<%= safeRoleName %>', false, <%= userCount %>)"
                                                title="Deactivate">
                                            <i class="fas fa-ban"></i>
                                        </button>
                                        <% } else { %>
                                        <button type="button" class="btn btn-sm btn-success"
                                                onclick="openToggleModal(<%= role.getRoleId() %>, '<%= safeRoleName %>', true, <%= userCount %>)"
                                                title="Activate">
                                            <i class="fas fa-check"></i>
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

<div class="modal fade" id="roleModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form id="roleForm" method="post" action="${pageContext.request.contextPath}/admin/roles/create">
                <div class="modal-header">
                    <h5 class="modal-title" id="roleModalTitle">Create Role</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="roleId" name="roleId">

                    <div class="form-group">
                        <label for="roleName">Role name <span class="text-danger">*</span></label>
                        <input type="text" id="roleName" name="roleName" class="form-control"
                               maxlength="50" required placeholder="WAREHOUSE_MANAGER">
                        <small class="form-text text-muted">Use uppercase letters, numbers, and underscores.</small>
                    </div>

                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" class="form-control" rows="3" maxlength="255"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="status">Status</label>
                        <select id="status" name="status" class="form-control">
                            <option value="ACTIVE">Active</option>
                            <option value="INACTIVE">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save
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
                <h5 class="modal-title" id="toggleModalTitle">Confirm</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p id="toggleModalBody"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form id="toggleForm" action="${pageContext.request.contextPath}/admin/roles/toggle-status" method="post" class="d-inline">
                    <input type="hidden" id="toggleRoleId" name="roleId">
                    <input type="hidden" id="toggleActive" name="active">
                    <button type="submit" class="btn" id="toggleConfirmBtn">Confirm</button>
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
        $('#roleModalTitle').text('Create Role');
        $('#roleForm').attr('action', '${pageContext.request.contextPath}/admin/roles/create');
        $('#roleId').val('');
        $('#roleName').val('');
        $('#description').val('');
        $('#status').val('ACTIVE');
        $('#roleModal').modal('show');
    }

    function openEditModal(roleId, roleName, description, status) {
        $('#roleModalTitle').text('Edit Role');
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
            $('#toggleModalTitle').text('Activate role');
            $('#toggleModalBody').html('Activate role <strong>' + roleName + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-warning').addClass('btn-success').text('Activate');
        } else {
            $('#toggleModalTitle').text('Deactivate role');
            if (userCount > 0) {
                $('#toggleModalBody').html('Role <strong>' + roleName + '</strong> is assigned to <strong>' + userCount + '</strong> user(s). It cannot be deactivated until users are moved to another role.');
                $('#toggleConfirmBtn').prop('disabled', true).removeClass('btn-success').addClass('btn-warning').text('Cannot deactivate');
            } else {
                $('#toggleModalBody').html('Deactivate role <strong>' + roleName + '</strong>? It will no longer be available when creating users.');
                $('#toggleConfirmBtn').prop('disabled', false).removeClass('btn-success').addClass('btn-warning').text('Deactivate');
            }
        }
        if (setActive) {
            $('#toggleConfirmBtn').prop('disabled', false);
        }
        $('#toggleModal').modal('show');
    }
</script>

</body>
</html>
