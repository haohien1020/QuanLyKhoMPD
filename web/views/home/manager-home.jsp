<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chủ Quản lý | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .home-hero { background:#fff; border-left:.25rem solid var(--ui-primary,#4e73df); }
        .workflow-card { min-height: 150px; }
        .workflow-card .card-body { display:flex; flex-direction:column; }
        .workflow-actions { margin-top:auto; }
    </style>
</head>
<body id="page-top">
<div id="wrapper">
    <%@ include file="/views/layout/sidebar.jsp" %>
    <div id="content-wrapper" class="d-flex flex-column">
        <div id="content">
            <%@ include file="/views/layout/topbar.jsp" %>
            <div class="container-fluid">
                <div class="home-hero shadow-sm rounded p-4 mb-4">
                    <div class="d-sm-flex justify-content-between">
                        <div>
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-2">Không gian làm việc của Quản lý</div>
                            <h1 class="h3 text-gray-900 mb-2">Phê duyệt và Kiểm soát vận hành</h1>
                            <p class="mb-0 text-gray-700">Xem xét các yêu cầu đang chờ xử lý, theo dõi luồng mua hàng và giám sát tồn kho các chi nhánh.</p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0">
                            <div class="small text-muted">Đăng nhập với tư cách</div>
                            <div class="font-weight-bold">${sessionScope.currentUser.fullName}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty homeError}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${homeError}</div>
                </c:if>

                <div class="row">
                    <div class="col-xl-6 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Yêu cầu chờ phê duyệt</div>
                                <div class="h4 font-weight-bold text-gray-800">${pendingTransfers}</div>
                                <div class="small text-muted">Các yêu cầu điều chuyển kho đang chờ duyệt</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-6 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Giám sát tồn kho</div>
                                <div class="h4 font-weight-bold text-gray-800">${lowStockParts}</div>
                                <div class="small text-muted">Phụ tùng đang ở hoặc dưới mức tối thiểu</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-clipboard-check text-warning"></i> Yêu cầu & Phê duyệt</h6>
                                <p class="small text-muted">Xem xét phê duyệt điều chuyển kho.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/manager/pending-requests" class="btn btn-sm btn-warning">Hàng đợi chờ duyệt</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-file-invoice text-primary"></i> Nhà cung cấp</h6>
                                <p class="small text-muted">Quản lý thông tin và danh sách các nhà cung cấp thiết bị.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/suppliers" class="btn btn-sm btn-primary">Nhà cung cấp</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-warehouse text-success"></i> Tổng quan Kho hàng</h6>
                                <p class="small text-muted">${totalWarehouses} kho hàng, ${totalGenerators} máy phát điện, ${lowStockParts} phụ tùng thiếu hụt.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/warehouses" class="btn btn-sm btn-success">Quản lý kho</a>
                                    <a href="${pageContext.request.contextPath}/manager/employees" class="btn btn-sm btn-outline-success">Quản lý nhân viên</a>
                                    <a href="${pageContext.request.contextPath}/stock-transfers" class="btn btn-sm btn-outline-success">Điều chuyển kho</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-chart-bar text-info"></i> Báo cáo & Giám sát</h6>
                                <p class="small text-muted">${unreadNotifications} thông báo chưa đọc. Xem xét các báo cáo thống kê tồn kho và mua sắm.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/reports?type=inventory" class="btn btn-sm btn-info">Báo cáo tồn kho</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%@ include file="/views/layout/footer.jsp" %>
    </div>
</div>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
</body>
</html>
