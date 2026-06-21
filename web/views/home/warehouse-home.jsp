<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chủ Thủ kho | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .home-hero { background:#fff; border-left:.25rem solid #1cc88a; }
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
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-2">Không gian làm việc của Thủ kho</div>
                            <h1 class="h3 text-gray-900 mb-2">
                                Kiểm soát Kho: 
                                <c:choose>
                                    <c:when test="${not empty managedWarehouse}">
                                        <span class="text-primary">${managedWarehouse.warehouseName}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-warning">Chưa gán kho</span>
                                    </c:otherwise>
                                </c:choose>
                            </h1>
                            <p class="mb-0 text-gray-700">Quản lý kho hàng, máy phát điện, phụ tùng linh kiện, điều chuyển kho và yêu cầu mua sắm.</p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0">
                            <div class="small text-muted">Vai trò hiện tại</div>
                            <div class="font-weight-bold">${sessionScope.currentUser.roleName}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty homeError}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${homeError}</div>
                </c:if>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Kho</div>
                                <div class="h4 font-weight-bold text-gray-800">${totalWarehouses}</div>
                                <div class="small text-muted">Địa điểm lưu trữ</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Máy phát điện</div>
                                <div class="h4 font-weight-bold text-gray-800">${totalGenerators}</div>
                                <div class="small text-muted">${inStockGenerators} trong kho</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Sắp hết hàng</div>
                                <div class="h4 font-weight-bold text-gray-800">${lowStockParts}</div>
                                <div class="small text-muted">Tổng số ${totalParts} phụ tùng</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-info shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Giao dịch kho</div>
                                <div class="h4 font-weight-bold text-gray-800">${inventoryTransactions}</div>
                                <div class="small text-muted">${pendingTransfers} yêu cầu chuyển kho chờ duyệt</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-bolt text-primary"></i> Quản lý tài sản</h6>
                                <p class="small text-muted">Theo dõi máy phát điện và phụ tùng. Hiện có ${maintenanceGenerators} máy đang bảo trì hoặc sửa chữa.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/generators" class="btn btn-sm btn-primary">Máy phát điện</a>
                                    <a href="${pageContext.request.contextPath}/parts" class="btn btn-sm btn-outline-primary">Phụ tùng</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-boxes text-warning"></i> Nghiệp vụ kho hàng</h6>
                                <p class="small text-muted">Thực hiện nhập kho/xuất kho và theo dõi lịch sử biến động tồn kho.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/inventory-transactions" class="btn btn-sm btn-warning">Nhập / Xuất kho</a>
                                    <a href="${pageContext.request.contextPath}/inventory-transactions/history" class="btn btn-sm btn-outline-warning">Lịch sử</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-shopping-cart text-success"></i> Yêu cầu mua sắm & Điều chuyển</h6>
                                <p class="small text-muted">Có ${pendingPurchaseRequests} yêu cầu mua sắm và ${pendingTransfers} yêu cầu điều chuyển kho đang chờ duyệt.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/purchase-requests" class="btn btn-sm btn-success">Yêu cầu mua sắm</a>
                                    <a href="${pageContext.request.contextPath}/stock-transfers" class="btn btn-sm btn-outline-success">Điều chuyển kho</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-truck text-info"></i> Nhà cung cấp</h6>
                                <p class="small text-muted">Tổng số ${totalSuppliers} nhà cung cấp có sẵn phục vụ luồng mua hàng.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/suppliers" class="btn btn-sm btn-info">Nhà cung cấp</a>
                                    <a href="${pageContext.request.contextPath}/inventory/low-stock" class="btn btn-sm btn-outline-info">Cảnh báo tồn kho</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-file-contract text-danger"></i> Thuê & Trả máy phát điện</h6>
                                <p class="small text-muted">Bàn giao máy phát, tiếp nhận hoàn trả, phân công Staff pre-delivery check-up.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/warehouse/rentals" class="btn btn-sm btn-danger">Yêu cầu thuê & Trả máy</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-users-cog text-primary"></i> Nhân viên kinh doanh (SELLER)</h6>
                                <p class="small text-muted">Quản lý và cấp tài khoản cho nhân viên kinh doanh thuộc kho của bạn.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/warehouse/sellers" class="btn btn-sm btn-primary">Quản lý Seller</a>
                                    <a href="${pageContext.request.contextPath}/warehouse/sellers/create" class="btn btn-sm btn-outline-primary">Thêm Seller mới</a>
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
