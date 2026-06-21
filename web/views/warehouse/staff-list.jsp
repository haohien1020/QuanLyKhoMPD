<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Warehouse" %>

<%
    @SuppressWarnings("unchecked")
    List<User> staffList = (List<User>) request.getAttribute("staffList");
    Warehouse warehouse = (Warehouse) request.getAttribute("warehouse");
    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    User currentUser = (User) session.getAttribute("currentUser");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Nhân viên trong kho | Generator Management System</title>

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
                        <i class="fas fa-users text-primary"></i> Quản lý nhân viên trong kho
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
                    <i class="fas fa-check-circle"></i> Cập nhật quyền nhập máy phát điện thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("no_warehouse".equals(errorParam)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> Bạn chưa được phân công quản lý kho nào.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("invalid_user".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Tài khoản không hợp lệ hoặc không thuộc kho của bạn.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("update_failed".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Không thể cập nhật quyền. Vui lòng thử lại.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("invalid_id".equals(errorParam)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> ID nhân viên không hợp lệ.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Danh sách STAFF tại kho: 
                            <span class="text-dark font-weight-bold"><%= (warehouse != null) ? warehouse.getWarehouseName() : "N/A" %></span>
                            <span class="badge badge-primary"><%= (staffList != null) ? staffList.size() : 0 %></span>
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="staffTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Tài khoản</th>
                                    <th>Họ tên</th>
                                    <th>Email</th>
                                    <th>SĐT</th>
                                    <th>Trạng thái</th>
                                    <th style="min-width: 200px;">Quyền nhập máy phát</th>
                                    <th>Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (staffList == null || staffList.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="8" class="text-center text-muted py-5">
                                        <i class="fas fa-user-friends fa-3x mb-3 text-gray-400"></i>
                                        <p class="mb-0">Chưa có nhân viên kỹ thuật (STAFF) nào thuộc kho này</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (User u : staffList) {
                                %>
                                <tr>
                                    <td class="text-center"><%= u.getUserId() %></td>
                                    <td><strong><%= u.getUsername() %></strong></td>
                                    <td><%= u.getFullName() != null ? u.getFullName() : "-" %></td>
                                    <td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                                    <td class="text-center"><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                                    <td class="text-center">
                                        <% if (u.isActive()) { %>
                                            <span class="badge badge-success">Hoạt động</span>
                                        <% } else { %>
                                            <span class="badge badge-danger">Đã khóa</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center">
                                        <% if (u.isCanImportGenerator()) { %>
                                            <span class="badge badge-primary permission-badge">
                                                <i class="fas fa-check-circle"></i> Được cho phép
                                            </span>
                                        <% } else { %>
                                            <span class="badge badge-secondary permission-badge">
                                                <i class="fas fa-times-circle"></i> Không được phép
                                            </span>
                                        <% } %>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <% if (u.isCanImportGenerator()) { %>
                                        <button type="button" class="btn btn-sm btn-danger shadow-sm" title="Thu hồi quyền nhập máy phát"
                                                onclick="showToggleModal(<%= u.getUserId() %>, '<%= u.getUsername() %>', false)">
                                            <i class="fas fa-times"></i> Thu hồi quyền
                                        </button>
                                        <% } else { %>
                                        <button type="button" class="btn btn-sm btn-success shadow-sm" title="Cấp quyền nhập máy phát"
                                                onclick="showToggleModal(<%= u.getUserId() %>, '<%= u.getUsername() %>', true)">
                                            <i class="fas fa-check"></i> Cấp quyền
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
                <form id="toggleForm" action="${pageContext.request.contextPath}/warehouse/staff/toggle-import" method="post" class="d-inline">
                    <input type="hidden" id="toggleStaffId" name="staffId">
                    <input type="hidden" id="toggleCanImport" name="canImport">
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
                "lengthMenu": "Hiển thị _MENU_ nhân viên mỗi trang",
                "zeroRecords": "Không tìm thấy nhân viên nào",
                "info": "Trang _PAGE_ / _PAGES_",
                "infoEmpty": "Không có dữ liệu",
                "infoFiltered": "(lọc từ _MAX_ nhân viên)",
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

    function showToggleModal(staffId, username, setCanImport) {
        $('#toggleStaffId').val(staffId);
        $('#toggleCanImport').val(setCanImport);
        if (setCanImport) {
            $('#toggleModalTitle').text('Cấp quyền Nhập máy phát');
            $('#toggleModalBody').html('Bạn có chắc muốn <strong>cấp quyền nhập máy phát điện</strong> cho nhân viên <strong>' + username + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-danger').addClass('btn-success').text('Cấp quyền');
        } else {
            $('#toggleModalTitle').text('Thu hồi quyền Nhập máy phát');
            $('#toggleModalBody').html('Bạn có chắc muốn <strong>thu hồi quyền nhập máy phát điện</strong> từ nhân viên <strong>' + username + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-success').addClass('btn-danger').text('Thu hồi');
        }
        $('#toggleModal').modal('show');
    }
</script>

</body>
</html>
