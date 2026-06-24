<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quản lý tài sản | Generator Management System</title>

    <!-- Font Awesome -->
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">

    <!-- SB Admin 2 CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">

    <!-- DataTables CSS -->
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
</head>

<body id="page-top">

<div id="wrapper">

    <!-- Sidebar -->
    <ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

        <a class="sidebar-brand d-flex align-items-center justify-content-center"
           href="${pageContext.request.contextPath}/">
            <div class="sidebar-brand-icon">
                <i class="fas fa-bolt"></i>
            </div>
            <div class="sidebar-brand-text mx-3">GMS</div>
        </a>

        <hr class="sidebar-divider my-0">

        <li class="nav-item active">
            <a class="nav-link" href="#">
                <i class="fas fa-fw fa-boxes"></i>
                <span>Quản lý tài sản</span>
            </a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="#">
                <i class="fas fa-fw fa-users"></i>
                <span>Người dùng</span>
            </a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="#">
                <i class="fas fa-fw fa-cog"></i>
                <span>Cài đặt</span>
            </a>
        </li>

        <hr class="sidebar-divider d-none d-md-block">

    </ul>
    <!-- End Sidebar -->

    <div id="content-wrapper" class="d-flex flex-column">

        <div id="content">

            <!-- Topbar -->
            <nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">

                <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
                    <i class="fa fa-bars"></i>
                </button>

                <h5 class="mb-0 text-gray-800">Generator Management System</h5>

                <ul class="navbar-nav ml-auto">
                    <li class="nav-item dropdown no-arrow">
                        <a class="nav-link dropdown-toggle" href="#">
                            <span class="mr-2 d-none d-lg-inline text-gray-600 small">Admin</span>
                            <i class="fas fa-user-circle fa-2x text-gray-600"></i>
                        </a>
                    </li>
                </ul>

            </nav>
            <!-- End Topbar -->

            <div class="container-fluid">

                <!-- Page Heading -->
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">
                        <i class="fas fa-boxes text-primary"></i> Quản lý tài sản
                    </h1>

                    <a href="#"
                       class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm">
                        <i class="fas fa-plus fa-sm text-white-50"></i> Thêm tài sản mới
                    </a>
                </div>

                <!-- Filter Card -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-filter"></i> Tìm kiếm & Lọc
                        </h6>
                    </div>

                    <div class="card-body">
                        <form method="get" action="#" class="form-inline">

                            <div class="form-group mr-3 mb-2">
                                <input type="text"
                                       name="keyword"
                                       class="form-control"
                                       placeholder="Tìm kiếm tên, mã, serial...">
                            </div>

                            <div class="form-group mr-3 mb-2">
                                <select name="status" class="form-control">
                                    <option value="">-- Tất cả trạng thái --</option>
                                    <option value="IN_STOCK">Trong kho</option>
                                    <option value="IN_USE">Đang sử dụng</option>
                                </select>
                            </div>

                            <div class="form-group mr-3 mb-2">
                                <select name="activeState" class="form-control">
                                    <option value="active">Đang hoạt động</option>
                                    <option value="inactive">Không hoạt động</option>
                                </select>
                            </div>

                            <button type="button" class="btn btn-primary mb-2 mr-2">
                                <i class="fas fa-search"></i> Tìm kiếm
                            </button>

                            <button type="button" class="btn btn-secondary mb-2">
                                <i class="fas fa-redo"></i> Đặt lại
                            </button>

                        </form>
                    </div>
                </div>

                <!-- Data Table Card -->
                <div class="card shadow mb-4">

                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-table"></i> Danh sách tài sản
                        </h6>
                    </div>

                    <div class="card-body">

                        <div class="table-responsive">

                            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>Mã tài sản</th>
                                    <th>Tên tài sản</th>
                                    <th>Danh mục</th>
                                    <th>Số lượng</th>
                                    <th>Đơn vị tính</th>
                                    <th>Số seri</th>
                                    <th>Model</th>
                                    <th>Hãng</th>
                                    <th>Trạng thái</th>
                                    <th>Phòng hiện tại</th>
                                    <th>Hoạt động</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>

                                <tbody>
                                <tr>
                                    <td colspan="12" class="text-center text-muted py-4">
                                        <i class="fas fa-info-circle"></i>
                                        Chưa có dữ liệu để hiển thị
                                    </td>
                                </tr>
                                </tbody>
                            </table>

                        </div>

                        <!-- Pagination UI mẫu -->
                        <nav aria-label="Page navigation">
                            <ul class="pagination justify-content-center mt-3">
                                <li class="page-item disabled">
                                    <a class="page-link" href="#">Trước</a>
                                </li>

                                <li class="page-item active">
                                    <a class="page-link" href="#">1</a>
                                </li>

                                <li class="page-item disabled">
                                    <a class="page-link" href="#">Sau</a>
                                </li>
                            </ul>
                        </nav>

                    </div>
                </div>

            </div>
        </div>

        <!-- Footer -->
        <footer class="sticky-footer bg-white">
            <div class="container my-auto">
                <div class="copyright text-center my-auto">
                    <span>Copyright &copy; Generator Management System 2026</span>
                </div>
            </div>
        </footer>

    </div>

</div>

<!-- Scripts -->
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>

<!-- DataTables -->
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>

</body>
</html>