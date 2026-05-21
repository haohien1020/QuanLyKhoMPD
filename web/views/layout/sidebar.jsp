<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String uiPrimaryColor = (String) request.getAttribute("uiPrimaryColor");
    if (uiPrimaryColor == null || !uiPrimaryColor.matches("^#[0-9a-fA-F]{6}$")) {
        uiPrimaryColor = "#4e73df";
    }
%>

<style>
    :root {
        --primary: <%= uiPrimaryColor %>;
        --blue: <%= uiPrimaryColor %>;
        --ui-primary: <%= uiPrimaryColor %>;
    }

    /* sb-admin-2.min.css hard-codes màu #4e73df.
       Override bằng !important để theme đổi ngay lập tức. */
    .bg-gradient-primary {
        background-color: var(--primary) !important;
        background-image: linear-gradient(180deg, var(--primary) 10%, #224abe 100%) !important;
        background-size: cover !important;
    }
    .text-primary {
        color: var(--primary) !important;
    }
    .bg-primary {
        background-color: var(--primary) !important;
        border-color: var(--primary) !important;
    }
    .btn-primary {
        background-color: var(--primary) !important;
        border-color: var(--primary) !important;
        color: #fff !important;
    }
    .btn-primary:hover,
    .btn-primary:focus,
    .btn-primary.focus,
    .btn-primary:not(:disabled):not(.disabled):active,
    .btn-primary:not(:disabled):not(.disabled).active {
        background-color: var(--primary) !important;
        border-color: var(--primary) !important;
        color: #fff !important;
    }
    .border-left-primary {
        border-left-color: var(--primary) !important;
    }
    .sidebar .nav-item .collapse .collapse-inner .collapse-item.active,
    .sidebar .nav-item .collapsing .collapse-inner .collapse-item.active {
        color: var(--primary) !important;
        font-weight: 700 !important;
    }
</style>

<ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

    <!-- Brand -->
    <a class="sidebar-brand d-flex align-items-center justify-content-center"
       href="${pageContext.request.contextPath}/admin/dashboard">
        <div class="sidebar-brand-icon rotate-n-15">
            <i class="fas fa-bolt"></i>
        </div>
        <div class="sidebar-brand-text mx-3">Generator Management System</div>
    </a>

    <hr class="sidebar-divider my-0">

    <% 
        model.User sidebarUser = (model.User) session.getAttribute("currentUser");
        java.util.List<String> sidebarRoles = (sidebarUser != null) ? sidebarUser.getRoles() : null;
    %>

    <!-- Dashboard (ALL USERS) -->
    <li class="nav-item active">
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">
            <i class="fas fa-fw fa-tachometer-alt"></i>
            <span>Trang tổng quan</span>
        </a>
    </li>

    <hr class="sidebar-divider">

    <!-- ADMIN MENU -->
    <% if (sidebarRoles != null && sidebarRoles.contains("ADMIN")) { %>

    <div class="sidebar-heading">
        Quản trị hệ thống
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/users">
            <i class="fas fa-fw fa-users"></i>
            <span>Quản lý người dùng</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/roles">
            <i class="fas fa-user-shield"></i>
            <span>Quản lý vai trò</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/permissions">
            <i class="fas fa-lock"></i>
            <span>Phân quyền truy cập</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Quản lý kho
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/warehouses">
            <i class="fas fa-warehouse"></i>
            <span>Quản lý kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/suppliers">
            <i class="fas fa-truck"></i>
            <span>Quản lý nhà cung cấp</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Báo cáo & Nhật ký
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/reports">
            <i class="fas fa-file-alt"></i>
            <span>Báo cáo hệ thống</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/activity-logs">
            <i class="fas fa-history"></i>
            <span>Nhật ký hoạt động</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/settings">
            <i class="fas fa-cogs"></i>
            <span>Cài đặt hệ thống</span>
        </a>
    </li>

    <hr class="sidebar-divider">

    <% } %>

    <!-- MANAGER MENU -->
    <% if (sidebarRoles != null && sidebarRoles.contains("MANAGER") && !sidebarRoles.contains("ADMIN")) { %>

    <div class="sidebar-heading">
        Phê duyệt & Yêu cầu
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/manager/pending-requests">
            <i class="fas fa-clipboard-check"></i>
            <span>Danh sách yêu cầu chờ duyệt</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/part-requests">
            <i class="fas fa-tools"></i>
            <span>Yêu cầu phụ tùng</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/purchase-requests">
            <i class="fas fa-shopping-cart"></i>
            <span>Yêu cầu mua hàng</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/purchase-orders">
            <i class="fas fa-file-invoice"></i>
            <span>Đơn đặt hàng</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Kho & Điều chuyển
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/stock-transfers">
            <i class="fas fa-exchange-alt"></i>
            <span>Điều chuyển kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/warehouses">
            <i class="fas fa-warehouse"></i>
            <span>Quản lý kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/suppliers">
            <i class="fas fa-truck"></i>
            <span>Quản lý nhà cung cấp</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Báo cáo
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/reports?type=inventory">
            <i class="fas fa-chart-bar"></i>
            <span>Báo cáo tồn kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/reports?type=purchase">
            <i class="fas fa-file-invoice-dollar"></i>
            <span>Báo cáo mua hàng</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/reports?type=repair">
            <i class="fas fa-wrench"></i>
            <span>Báo cáo sửa chữa</span>
        </a>
    </li>

    <hr class="sidebar-divider">

    <% } %>

    <!-- WAREHOUSE_MANAGER MENU -->
    <% if (sidebarRoles != null && sidebarRoles.contains("WAREHOUSE_MANAGER") && !sidebarRoles.contains("ADMIN")) { %>

    <div class="sidebar-heading">
        Quản lý kho
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/warehouse/dashboard">
            <i class="fas fa-warehouse"></i>
            <span>Quản lý kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/generators">
            <i class="fas fa-bolt"></i>
            <span>Quản lý máy phát điện</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/parts">
            <i class="fas fa-cogs"></i>
            <span>Quản lý phụ tùng</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Tồn kho
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/inventory">
            <i class="fas fa-boxes"></i>
            <span>Theo dõi tồn kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/inventory/low-stock">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Cảnh báo tồn kho tối thiểu</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/inventory-transactions">
            <i class="fas fa-dolly"></i>
            <span>Nhập kho / Xuất kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/inventory-transactions/history">
            <i class="fas fa-history"></i>
            <span>Lịch sử giao dịch kho</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Yêu cầu & Mua hàng
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/purchase-requests">
            <i class="fas fa-shopping-cart"></i>
            <span>Yêu cầu mua hàng</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/stock-transfers">
            <i class="fas fa-exchange-alt"></i>
            <span>Điều chuyển kho</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/suppliers">
            <i class="fas fa-truck"></i>
            <span>Nhà cung cấp</span>
        </a>
    </li>

    <hr class="sidebar-divider">

    <% } %>

    <!-- STAFF MENU -->
    <% if (sidebarRoles != null && sidebarRoles.contains("STAFF") && !sidebarRoles.contains("ADMIN") && !sidebarRoles.contains("MANAGER") && !sidebarRoles.contains("WAREHOUSE_MANAGER")) { %>

    <div class="sidebar-heading">
        Danh sách
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/generators">
            <i class="fas fa-bolt"></i>
            <span>Danh sách máy phát điện</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/parts">
            <i class="fas fa-tools"></i>
            <span>Danh sách phụ tùng</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Yêu cầu
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/part-request/create">
            <i class="fas fa-plus-circle"></i>
            <span>Tạo yêu cầu phụ tùng</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/my-requests">
            <i class="fas fa-list"></i>
            <span>Yêu cầu của tôi</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/inventory-transactions">
            <i class="fas fa-dolly-flatbed"></i>
            <span>Nhập kho / Xuất kho</span>
        </a>
    </li>

    <div class="sidebar-heading">
        Sửa chữa
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/repair-request/create">
            <i class="fas fa-wrench"></i>
            <span>Yêu cầu sửa chữa</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/repair-tasks">
            <i class="fas fa-tasks"></i>
            <span>Nhiệm vụ sửa chữa của tôi</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/repair-progress">
            <i class="fas fa-spinner"></i>
            <span>Tiến độ sửa chữa</span>
        </a>
    </li>

    <hr class="sidebar-divider">

    <% } %>

    <!-- ALL USERS -->
    <div class="sidebar-heading">
        Cài đặt
    </div>

    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/notifications">
            <i class="fas fa-bell"></i>
            <span>Thông báo</span>
        </a>
    </li>
    <li class="nav-item">
        <a class="nav-link" href="${pageContext.request.contextPath}/change-password">
            <i class="fas fa-key"></i>
            <span>Thay đổi mật khẩu</span>
        </a>
    </li>

    <hr class="sidebar-divider d-none d-md-block">

    <div class="text-center d-none d-md-inline">
        <button class="rounded-circle border-0" id="sidebarToggle"></button>
    </div>
</ul>
