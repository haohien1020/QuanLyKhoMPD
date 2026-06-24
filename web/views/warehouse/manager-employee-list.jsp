<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Warehouse" %>

<%
    @SuppressWarnings("unchecked")
    List<User> employees = (List<User>) request.getAttribute("employees");
    @SuppressWarnings("unchecked")
    List<User> warehouseManagers = (List<User>) request.getAttribute("warehouseManagers");

    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý nhân viên | Generator Management System</title>
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
                        <i class="fas fa-users text-primary"></i> Quản lý nhân viên
                    </h1>
                    <button type="button" class="btn btn-primary btn-sm shadow-sm" onclick="openCreateModal()">
                        <i class="fas fa-user-plus mr-1"></i> Thêm nhân viên mới
                    </button>
                </div>

                <%-- Error Notification from Controller --%>
                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <%-- Query parameters notifications --%>
                <% if ("username_empty".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Tên đăng nhập không được để trống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("username_len".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Tên đăng nhập từ 3 đến 30 ký tự và chỉ chứa chữ cái, số, gạch dưới, gạch ngang, dấu chấm.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("username_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Tên đăng nhập đã tồn tại trong hệ thống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("password_invalid".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Mật khẩu tối thiểu 6 ký tự, có ít nhất 1 chữ hoa và 1 chữ số.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("fullname_empty".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Họ tên không được để trống.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("email_invalid".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Địa chỉ email không hợp lệ.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("email_exists".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Email đã được sử dụng bởi người dùng khác.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("phone_invalid".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Số điện thoại không hợp lệ.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("no_warehouse".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Không thể xác định kho của Thủ kho được chọn.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("create_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Thêm mới nhân viên thất bại. Vui lòng thử lại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("update_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Cập nhật thông tin nhân viên thất bại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("system_error".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Lỗi hệ thống. Vui lòng liên hệ quản trị viên.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <%-- Success Notifications --%>
                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm">
                    <i class="fas fa-check-circle"></i> Tạo tài khoản nhân viên mới thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm">
                    <i class="fas fa-check-circle"></i> Cập nhật thông tin nhân viên thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("status_changed".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm">
                    <i class="fas fa-check-circle"></i> Thay đổi trạng thái tài khoản thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm">
                    <i class="fas fa-check-circle"></i> Xóa nhân viên thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("delete_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-circle"></i> Xóa nhân viên thất bại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list mr-1"></i> Danh sách nhân sự chi nhánh của bạn
                        </h6>
                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="employeeTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th style="width:50px">ID</th>
                                    <th>Họ Tên</th>
                                    <th>Tên Đăng Nhập</th>
                                    <th>Vai Trò</th>
                                    <th>Liên Hệ</th>
                                    <th>Thủ Kho Trực Tiếp</th>
                                    <th>Kho Hàng</th>
                                    <th style="width:110px">Trạng Thái</th>
                                    <th style="width:160px">Hành Động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (employees != null && !employees.isEmpty()) {
                                        for (User emp : employees) {
                                            boolean active = "ACTIVE".equalsIgnoreCase(emp.getStatus());
                                            String roleBadge = "STAFF".equals(emp.getRoleName()) 
                                                ? "<span class='badge badge-info'><i class='fas fa-user-cog mr-1'></i>Kỹ thuật</span>" 
                                                : "<span class='badge badge-success'><i class='fas fa-store mr-1'></i>Bán hàng</span>";
                                            
                                            String safeFullName = emp.getFullName().replace("\\", "\\\\").replace("'", "\\'");
                                            String safeEmail = emp.getEmail() != null ? emp.getEmail().replace("'", "\\'") : "";
                                            String safePhone = emp.getPhone() != null ? emp.getPhone().replace("'", "\\'") : "";
                                %>
                                <tr>
                                    <td><%= emp.getUserId() %></td>
                                    <td><span class="font-weight-bold text-gray-900"><%= emp.getFullName() %></span></td>
                                    <td><code><%= emp.getUsername() %></code></td>
                                    <td><%= roleBadge %></td>
                                    <td>
                                        <div class="small"><i class="fas fa-envelope fa-fw text-muted mr-1"></i><%= emp.getEmail() %></div>
                                        <% if (emp.getPhone() != null && !emp.getPhone().isEmpty()) { %>
                                        <div class="small mt-1"><i class="fas fa-phone fa-fw text-muted mr-1"></i><%= emp.getPhone() %></div>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (emp.getWarehouseManagerName() != null) { %>
                                        <span class="badge badge-light border text-gray-800">
                                            <i class="fas fa-user-tie text-info mr-1"></i> <%= emp.getWarehouseManagerName() %>
                                        </span>
                                        <% } else { %>
                                        <span class="text-muted font-italic">Chưa gán</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (emp.getWarehouseName() != null) { %>
                                        <span class="badge badge-light border text-gray-800">
                                            <i class="fas fa-warehouse text-primary mr-1"></i> <%= emp.getWarehouseName() %>
                                        </span>
                                        <% } else { %>
                                        <span class="text-muted font-italic">Chưa gán</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center">
                                        <% if (active) { %>
                                        <span class="badge badge-success px-2 py-1">Hoạt động</span>
                                        <% } else { %>
                                        <span class="badge badge-danger px-2 py-1">Tạm khóa</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <button type="button" class="btn btn-sm btn-primary"
                                                onclick="openAssignModal(<%= emp.getUserId() %>, '<%= safeFullName %>', <%= emp.getWarehouseId() != null ? emp.getWarehouseId() : 0 %>)"
                                                title="Gán thủ kho">
                                            <i class="fas fa-link"></i>
                                        </button>

                                        <button type="button" class="btn btn-sm btn-info"
                                                onclick="openEditModal(<%= emp.getUserId() %>, '<%= safeFullName %>', '<%= safeEmail %>', '<%= safePhone %>', <%= emp.getWarehouseId() != null ? emp.getWarehouseId() : 0 %>)"
                                                title="Sửa thông tin">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <% if (active) { %>
                                        <button type="button" class="btn btn-sm btn-warning"
                                                onclick="openToggleStatusModal(<%= emp.getUserId() %>, '<%= safeFullName %>', false)"
                                                title="Tạm khóa">
                                            <i class="fas fa-ban"></i>
                                        </button>
                                        <% } else { %>
                                        <button type="button" class="btn btn-sm btn-success"
                                                onclick="openToggleStatusModal(<%= emp.getUserId() %>, '<%= safeFullName %>', true)"
                                                title="Kích hoạt">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <% } %>

                                        <button type="button" class="btn btn-sm btn-danger"
                                                onclick="openDeleteModal(<%= emp.getUserId() %>, '<%= safeFullName %>')"
                                                title="Xóa nhân viên">
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

<%-- Create Employee Modal --%>
<div class="modal fade" id="createEmployeeModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content border-left-primary shadow">
            <form method="post" action="${pageContext.request.contextPath}/manager/employee/create">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title font-weight-bold"><i class="fas fa-user-plus mr-2"></i>Thêm nhân viên mới</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="c_roleName" class="font-weight-bold text-gray-800">Vai Trò <span class="text-danger">*</span></label>
                        <select id="c_roleName" name="roleName" class="form-control" required>
                            <option value="STAFF">Nhân viên Kỹ thuật (STAFF)</option>
                            <option value="SELLER">Nhân viên Bán hàng (SELLER)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="c_warehouseManagerId" class="font-weight-bold text-gray-800">Quản lý trực tiếp (Warehouse Manager)</label>
                        <select id="c_warehouseManagerId" name="warehouseManagerId" class="form-control">
                            <option value="">-- Chưa gán (Phân công sau) --</option>
                            <% if (warehouseManagers != null) {
                                for (User wm : warehouseManagers) {
                            %>
                            <option value="<%= wm.getUserId() %>"><%= wm.getFullName() %> (<%= wm.getUsername() %>)</option>
                            <% } } %>
                        </select>
                        <small class="form-text text-muted">Không bắt buộc. Bạn có thể chọn Warehouse Manager phụ trách ngay hoặc gán sau.</small>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label for="c_fullName" class="font-weight-bold text-gray-800">Họ Tên <span class="text-danger">*</span></label>
                        <input type="text" id="c_fullName" name="fullName" class="form-control" maxlength="100" required placeholder="Ví dụ: Nguyễn Văn A">
                    </div>

                    <div class="form-group">
                        <label for="c_email" class="font-weight-bold text-gray-800">Email <span class="text-danger">*</span></label>
                        <input type="email" id="c_email" name="email" class="form-control" maxlength="100" required placeholder="Ví dụ: vana@gmail.com">
                    </div>

                    <div class="form-group">
                        <label for="c_phone" class="font-weight-bold text-gray-800">Số Điện Thoại</label>
                        <input type="text" id="c_phone" name="phone" class="form-control" maxlength="20" placeholder="Ví dụ: 0912345678">
                    </div>

                    <div class="form-group">
                        <label for="c_username" class="font-weight-bold text-gray-800">Tên Đăng Nhập <span class="text-danger">*</span></label>
                        <input type="text" id="c_username" name="username" class="form-control" minlength="3" maxlength="30" required placeholder="Ví dụ: nva_staff">
                    </div>

                    <div class="form-group mb-0">
                        <label for="c_password" class="font-weight-bold text-gray-800">Mật Khẩu <span class="text-danger">*</span></label>
                        <input type="password" id="c_password" name="password" class="form-control" minlength="6" required placeholder="Nhập mật khẩu tài khoản">
                        <small class="form-text text-muted">Mật khẩu dài tối thiểu 6 ký tự, có 1 chữ hoa và 1 chữ số.</small>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary shadow-sm" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary shadow-sm font-weight-bold">
                        <i class="fas fa-save mr-1"></i> Lưu tài khoản
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Edit Employee Modal --%>
<div class="modal fade" id="editEmployeeModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content border-left-info shadow">
            <form method="post" action="${pageContext.request.contextPath}/manager/employee/update">
                <input type="hidden" id="e_userId" name="userId">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title font-weight-bold"><i class="fas fa-edit mr-2"></i>Sửa thông tin nhân viên</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="e_fullName" class="font-weight-bold text-gray-800">Họ Tên <span class="text-danger">*</span></label>
                        <input type="text" id="e_fullName" name="fullName" class="form-control" maxlength="100" required>
                    </div>

                    <div class="form-group">
                        <label for="e_email" class="font-weight-bold text-gray-800">Email <span class="text-danger">*</span></label>
                        <input type="email" id="e_email" name="email" class="form-control" maxlength="100" required>
                    </div>

                    <div class="form-group">
                        <label for="e_phone" class="font-weight-bold text-gray-800">Số Điện Thoại</label>
                        <input type="text" id="e_phone" name="phone" class="form-control" maxlength="20">
                    </div>

                    <div class="form-group mb-0">
                        <label for="e_warehouseManagerId" class="font-weight-bold text-gray-800">Quản lý trực tiếp (Warehouse Manager)</label>
                        <select id="e_warehouseManagerId" name="warehouseManagerId" class="form-control">
                            <option value="">-- Chưa gán (Hủy phân công) --</option>
                            <% if (warehouseManagers != null) {
                                for (User wm : warehouseManagers) {
                            %>
                            <option value="<%= wm.getUserId() %>" data-whid="<%= wm.getWarehouseId() != null ? wm.getWarehouseId() : 0 %>">
                                <%= wm.getFullName() %> (<%= wm.getUsername() %>) - [<%= wm.getWarehouseName() != null ? wm.getWarehouseName() : "Kho chưa rõ" %>]
                            </option>
                            <% } } %>
                        </select>
                        <small class="form-text text-muted">Chọn Warehouse Manager phụ trách hoặc hủy phân công để chuyển về trạng thái chưa gán.</small>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary shadow-sm" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-info shadow-sm font-weight-bold">
                        <i class="fas fa-save mr-1"></i> Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Quick Assign Warehouse Manager Modal --%>
<div class="modal fade" id="assignManagerModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content border-left-primary shadow">
            <form method="post" action="${pageContext.request.contextPath}/manager/employee/assign">
                <input type="hidden" id="a_userId" name="userId">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title font-weight-bold"><i class="fas fa-link mr-2"></i>Gán Thủ kho phụ trách</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <p class="small text-muted mb-3">Chọn Warehouse Manager sẽ quản lý trực tiếp nhân viên <strong id="a_employeeName"></strong>. Nhân viên sẽ tự động được xếp vào làm việc tại kho tương ứng.</p>
                    <div class="form-group mb-0">
                        <label for="a_warehouseManagerId" class="font-weight-bold text-gray-800">Thủ kho trực tiếp (Warehouse Manager)</label>
                        <select id="a_warehouseManagerId" name="warehouseManagerId" class="form-control">
                            <option value="">-- Chưa gán (Hủy phân công) --</option>
                            <% if (warehouseManagers != null) {
                                for (User wm : warehouseManagers) {
                            %>
                            <option value="<%= wm.getUserId() %>" data-whid="<%= wm.getWarehouseId() != null ? wm.getWarehouseId() : 0 %>">
                                <%= wm.getFullName() %> (<%= wm.getUsername() %>) - [<%= wm.getWarehouseName() != null ? wm.getWarehouseName() : "Kho chưa rõ" %>]
                            </option>
                            <% } } %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary shadow-sm" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary shadow-sm font-weight-bold">
                        <i class="fas fa-check mr-1"></i> Xác nhận gán
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Confirm Toggle Status Modal --%>
<div class="modal fade" id="toggleStatusModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title font-weight-bold" id="toggleTitle">Xác nhận thao tác</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p id="toggleBody"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary shadow-sm" data-dismiss="modal">Hủy</button>
                <form id="toggleForm" action="${pageContext.request.contextPath}/manager/employee/toggle-status" method="post" class="d-inline">
                    <input type="hidden" id="toggleUserId" name="userId">
                    <input type="hidden" id="toggleActive" name="active">
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
        $('#employeeTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: true,
            language: {
                "decimal":        "",
                "emptyTable":     "Không có dữ liệu nhân viên trong danh sách",
                "info":           "Hiển thị từ _START_ đến _END_ trong tổng số _TOTAL_ nhân viên",
                "infoEmpty":      "Hiển thị 0 đến 0 trong tổng số 0 dòng",
                "infoFiltered":   "(lọc từ tổng số _MAX_ dòng)",
                "infoPostFix":    "",
                "thousands":      ",",
                "lengthMenu":     "Hiển thị _MENU_ dòng",
                "loadingRecords": "Đang tải...",
                "processing":     "Đang xử lý...",
                "search":         "Tìm nhanh:",
                "zeroRecords":    "Không tìm thấy nhân viên phù hợp",
                "paginate": {
                    "first":      "Đầu",
                    "last":       "Cuối",
                    "next":       "Tiếp",
                    "previous":   "Trước"
                }
            }
        });
    });

    function openCreateModal() {
        $('#c_roleName').val('STAFF');
        $('#c_warehouseManagerId').val('');
        $('#c_fullName').val('');
        $('#c_email').val('');
        $('#c_phone').val('');
        $('#c_username').val('');
        $('#c_password').val('');
        $('#createEmployeeModal').modal('show');
    }

    function openEditModal(userId, fullName, email, phone, currentWarehouseId) {
        $('#e_userId').val(userId);
        $('#e_fullName').val(fullName);
        $('#e_email').val(email);
        $('#e_phone').val(phone);

        // Find the warehouse manager corresponding to the current warehouse ID
        let foundManagerId = '';
        if (currentWarehouseId > 0) {
            $('#e_warehouseManagerId option').each(function() {
                let whId = parseInt($(this).data('whid'));
                if (whId === currentWarehouseId) {
                    foundManagerId = $(this).val();
                }
            });
        }
        $('#e_warehouseManagerId').val(foundManagerId);

        $('#editEmployeeModal').modal('show');
    }

    function openAssignModal(userId, fullName, currentWarehouseId) {
        $('#a_userId').val(userId);
        $('#a_employeeName').text(fullName);

        // Find the warehouse manager corresponding to the current warehouse ID
        let foundManagerId = '';
        if (currentWarehouseId > 0) {
            $('#a_warehouseManagerId option').each(function() {
                let whId = parseInt($(this).data('whid'));
                if (whId === currentWarehouseId) {
                    foundManagerId = $(this).val();
                }
            });
        }
        $('#a_warehouseManagerId').val(foundManagerId);

        $('#assignManagerModal').modal('show');
    }

    function openToggleStatusModal(userId, fullName, setActive) {
        $('#toggleUserId').val(userId);
        $('#toggleActive').val(setActive);
        if (setActive) {
            $('#toggleTitle').text('Mở khóa tài khoản');
            $('#toggleBody').html('Bạn có chắc muốn <strong>mở khóa</strong> tài khoản của nhân viên <strong>' + fullName + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-danger').addClass('btn-success').text('Mở khóa');
        } else {
            $('#toggleTitle').text('Khóa tài khoản');
            $('#toggleBody').html('Bạn có chắc muốn <strong>tạm khóa</strong> tài khoản của nhân viên <strong>' + fullName + '</strong>? Nhân viên sẽ không thể đăng nhập vào hệ thống.');
            $('#toggleConfirmBtn').removeClass('btn-success').addClass('btn-danger').text('Khóa');
        }
        $('#toggleStatusModal').modal('show');
    }

    function openDeleteModal(userId, fullName) {
        $('#deleteUserId').val(userId);
        $('#deleteEmployeeName').text(fullName);
        $('#deleteEmployeeModal').modal('show');
    }
</script>

<%-- Confirm Delete Employee Modal --%>
<div class="modal fade" id="deleteEmployeeModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Xác nhận xóa nhân viên</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa nhân viên <strong id="deleteEmployeeName"></strong>?</p>
                <p class="text-danger small"><i class="fas fa-exclamation-triangle"></i> Lưu ý: Hành động này là xóa mềm, tài khoản nhân viên sẽ không xuất hiện trên hệ thống nhưng dữ liệu vẫn được lưu trữ.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary shadow-sm" data-dismiss="modal">Hủy</button>
                <form id="deleteEmployeeForm" action="${pageContext.request.contextPath}/manager/employee/delete" method="post" class="d-inline">
                    <input type="hidden" id="deleteUserId" name="userId">
                    <button type="submit" class="btn btn-danger shadow-sm font-weight-bold">Xóa nhân viên</button>
                </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>
