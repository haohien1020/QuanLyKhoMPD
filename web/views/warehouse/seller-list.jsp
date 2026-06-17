<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Warehouse" %>

<%
    @SuppressWarnings("unchecked")
    List<User> sellers = (List<User>) request.getAttribute("sellers");
    Warehouse warehouse = (Warehouse) request.getAttribute("warehouse");
    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    User currentUser = (User) session.getAttribute("currentUser");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Nhân viên kinh doanh | Generator Management System</title>

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
                        <i class="fas fa-users-cog text-primary"></i> Quản lý nhân viên kinh doanh
                    </h1>
                    <a href="${pageContext.request.contextPath}/warehouse/sellers/create" class="btn btn-primary btn-sm">
                        <i class="fas fa-user-plus"></i> Tạo tài khoản SELLER
                    </a>
                </div>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Tạo tài khoản SELLER thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Cập nhật thông tin thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("banned".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã khóa tài khoản thành công.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("unbanned".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Đã mở khóa tài khoản thành công.
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
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list"></i> Danh sách SELLER tại kho: 
                            <span class="text-dark font-weight-bold"><%= (warehouse != null) ? warehouse.getWarehouseName() : "N/A" %></span>
                            <span class="badge badge-primary"><%= (sellers != null) ? sellers.size() : 0 %></span>
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="sellerTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Tài khoản</th>
                                    <th>Họ tên</th>
                                    <th>Email</th>
                                    <th>SĐT</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (sellers == null || sellers.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-5">
                                        <i class="fas fa-user-friends fa-3x mb-3 text-gray-400"></i>
                                        <p class="mb-0">Chưa có nhân viên kinh doanh nào tại kho này</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (User u : sellers) {
                                %>
                                <tr>
                                    <td><%= u.getUserId() %></td>
                                    <td><strong><%= u.getUsername() %></strong></td>
                                    <td><%= u.getFullName() != null ? u.getFullName() : "-" %></td>
                                    <td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                                    <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                                    <td class="text-center">
                                        <% if (u.isActive()) { %>
                                            <span class="badge badge-success">Hoạt động</span>
                                        <% } else { %>
                                            <span class="badge badge-danger">Đã khóa</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <a href="${pageContext.request.contextPath}/warehouse/sellers/update?id=<%= u.getUserId() %>"
                                           class="btn btn-sm btn-info" title="Sửa thông tin">
                                            <i class="fas fa-edit"></i>
                                        </a>

                                        <% if (u.isActive()) { %>
                                        <button type="button" class="btn btn-sm btn-danger" title="Khóa tài khoản"
                                                onclick="showToggleModal(<%= u.getUserId() %>, '<%= u.getUsername() %>', false)">
                                            <i class="fas fa-user-slash"></i>
                                        </button>
                                        <% } else { %>
                                        <button type="button" class="btn btn-sm btn-success" title="Mở khóa tài khoản"
                                                onclick="showToggleModal(<%= u.getUserId() %>, '<%= u.getUsername() %>', true)">
                                            <i class="fas fa-user-check"></i>
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

<!-- Modal xác nhận khóa / mở khóa -->
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
                <form id="toggleForm" action="${pageContext.request.contextPath}/warehouse/sellers/toggle-active" method="post" class="d-inline">
                    <input type="hidden" id="toggleId" name="id">
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
        $('#sellerTable').DataTable({
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

    function showToggleModal(userId, username, setActive) {
        $('#toggleId').val(userId);
        $('#toggleActive').val(setActive);
        if (setActive) {
            $('#toggleModalTitle').text('Mở khóa tài khoản');
            $('#toggleModalBody').html('Bạn có chắc muốn <strong>mở khóa</strong> tài khoản của <strong>' + username + '</strong>?');
            $('#toggleConfirmBtn').removeClass('btn-danger').addClass('btn-success').text('Mở khóa');
        } else {
            $('#toggleModalTitle').text('Khóa tài khoản');
            $('#toggleModalBody').html('Bạn có chắc muốn <strong>khóa</strong> tài khoản của <strong>' + username + '</strong>? Người dùng này sẽ không thể đăng nhập.');
            $('#toggleConfirmBtn').removeClass('btn-success').addClass('btn-danger').text('Khóa');
        }
        $('#toggleModal').modal('show');
    }
</script>

</body>
</html>
