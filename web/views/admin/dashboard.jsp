<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tổng quan Admin | Generator Management System</title>

    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">

    <style>
        .overview-hero {
            background: #fff;
            border-left: .25rem solid var(--ui-primary, #4e73df);
        }
        .metric-card .metric-value {
            font-size: 1.35rem;
            line-height: 1.2;
        }
        .business-card {
            min-height: 168px;
        }
        .business-card .card-body {
            display: flex;
            flex-direction: column;
        }
        .business-card .module-actions {
            margin-top: auto;
        }
        .module-index {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            background: rgba(78, 115, 223, .1);
            color: var(--ui-primary, #4e73df);
        }
        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 6px;
        }
        .status-dot.warn { background: #f6c23e; }
        .status-dot.ok { background: #1cc88a; }
        .status-dot.info { background: #36b9cc; }
        .status-dot.danger { background: #e74a3b; }
    </style>
</head>

<body id="page-top">

<div id="wrapper">

    <%@ include file="/views/layout/sidebar.jsp" %>

    <div id="content-wrapper" class="d-flex flex-column">
        <div id="content">

            <%@ include file="/views/layout/topbar.jsp" %>

            <div class="container-fluid">

                <div class="overview-hero shadow-sm rounded p-4 mb-4">
                    <div class="d-sm-flex align-items-start justify-content-between">
                        <div>
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-2">
                                Trang chủ Admin
                            </div>
                            <h1 class="h3 mb-2 text-gray-900">Generator Management System</h1>
                            <p class="mb-0 text-gray-700">
                                Trung tâm điều phối nghiệp vụ cho người dùng, kho hàng, máy phát điện, vận hành tồn kho,
                                phê duyệt, mua hàng, báo cáo và nhật ký hệ thống.
                            </p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0">
                            <div class="text-muted small">Đăng nhập với tên</div>
                            <div class="font-weight-bold text-gray-900">${sessionScope.currentUser.fullName}</div>
                            <div class="small text-muted">${sessionScope.currentUser.roleName}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty dashboardError}">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> ${dashboardError}
                    </div>
                </c:if>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card metric-card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Người dùng / Vai trò</div>
                                        <div class="metric-value font-weight-bold text-gray-800">${totalUsers}</div>
                                        <div class="small text-muted">${activeUsers} tài khoản hoạt động, ${activeRoles}/${totalRoles} vai trò hoạt động</div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-users-cog fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card metric-card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Tài sản (Máy phát)</div>
                                        <div class="metric-value font-weight-bold text-gray-800">${totalGenerators}</div>
                                        <div class="small text-muted">${inStockGenerators} sẵn sàng trong kho</div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-bolt fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card metric-card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Công việc chờ xử lý</div>
                                        <div class="metric-value font-weight-bold text-gray-800">${pendingWork}</div>
                                        <div class="small text-muted">yêu cầu và điều chuyển đang đợi</div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-clipboard-check fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card metric-card border-left-info shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Giám sát & Nhật ký</div>
                                        <div class="metric-value font-weight-bold text-gray-800">${unreadNotifications}</div>
                                        <div class="small text-muted">${activityLogs} nhật ký thao tác, ${totalReports} báo cáo</div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-bell fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xl-8 col-lg-7 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">
                                    <i class="fas fa-project-diagram"></i> Sơ đồ luồng nghiệp vụ
                                </h6>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <div class="card business-card border-left-primary h-100">
                                            <div class="card-body">
                                                <div class="mb-2"><span class="module-index">1</span></div>
                                                <h6 class="font-weight-bold text-gray-900">Người dùng & Phân quyền</h6>
                                                <p class="small text-muted mb-3">Xác thực tài khoản, quyền hạn và phân quyền người dùng.</p>
                                                <div class="module-actions">
                                                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm btn-primary mr-1">Người dùng</a>
                                                    <a href="${pageContext.request.contextPath}/admin/roles" class="btn btn-sm btn-outline-primary">Vai trò</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <div class="card business-card border-left-success h-100">
                                            <div class="card-body">
                                                <div class="mb-2"><span class="module-index">2</span></div>
                                                <h6 class="font-weight-bold text-gray-900">Kho hàng & Tồn kho</h6>
                                                <p class="small text-muted mb-3">${totalWarehouses} kho hàng.</p>
                                                <div class="module-actions">
                                                    <a href="${pageContext.request.contextPath}/admin/warehouses" class="btn btn-sm btn-outline-success">Quản lý kho</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <div class="card business-card border-left-info h-100">
                                            <div class="card-body">
                                                <div class="mb-2"><span class="module-index">3</span></div>
                                                <h6 class="font-weight-bold text-gray-900">Quản lý Tài sản</h6>
                                                <p class="small text-muted mb-3">Đang quản lý ${totalGenerators} máy phát điện (${damagedGenerators} máy bị hỏng).</p>
                                                <div class="module-actions">
                                                    <a href="${pageContext.request.contextPath}/generators" class="btn btn-sm btn-outline-info">Máy phát điện</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <div class="card business-card border-left-warning h-100">
                                            <div class="card-body">
                                                <div class="mb-2"><span class="module-index">4</span></div>
                                                <h6 class="font-weight-bold text-gray-900">Vận hành Kho hàng</h6>
                                                <p class="small text-muted mb-3">${inventoryTransactions} giao dịch nhập/xuất, ${pendingTransfers} yêu cầu điều chuyển.</p>
                                                <div class="module-actions">
                                                    <a href="${pageContext.request.contextPath}/inventory-transactions" class="btn btn-sm btn-outline-warning">Giao dịch kho</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>


                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-4 col-lg-5 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">
                                    <i class="fas fa-chart-pie"></i> Trạng thái hoạt động máy phát
                                </h6>
                            </div>
                            <div class="card-body">
                                <div class="chart-pie pt-2 pb-3">
                                    <canvas id="healthChart"></canvas>
                                </div>
                                <div class="small">
                                    <div class="mb-2"><span class="status-dot ok"></span>Máy sẵn sàng trong kho: ${inStockGenerators}</div>
                                    <div class="mb-2"><span class="status-dot danger"></span>Máy bị hỏng: ${damagedGenerators}</div>
                                    <div><span class="status-dot info"></span>Công việc đang chờ xử lý: ${pendingWork}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xl-4 col-lg-6 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">
                                    <i class="fas fa-bolt"></i> Máy phát điện mới thêm
                                </h6>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty recentGenerators}">
                                        <div class="text-center text-muted py-3">Không có dữ liệu máy phát điện.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="generator" items="${recentGenerators}">
                                            <div class="mb-3 pb-2 border-bottom">
                                                <div class="font-weight-bold text-gray-900">${generator.generatorName}</div>
                                                <div class="small text-muted">
                                                    S/N: ${generator.serialNumber} · Hãng: ${generator.brand} · Trạng thái: ${generator.status}
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-4 col-lg-6 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">
                                    <i class="fas fa-bell"></i> Thông báo mới nhất
                                </h6>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty recentNotifications}">
                                        <div class="text-center text-muted py-3">Không có thông báo mới nào.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="noti" items="${recentNotifications}">
                                            <div class="mb-3 pb-2 border-bottom">
                                                <div class="font-weight-bold text-gray-900">
                                                    ${noti.title}
                                                    <c:if test="${!noti.read}">
                                                        <span class="badge badge-warning ml-1">Mới</span>
                                                    </c:if>
                                                </div>
                                                <div class="small text-muted">${noti.message}</div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
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
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/chart.js/Chart.min.js"></script>

<script>
    Chart.defaults.global.defaultFontFamily = 'Nunito, Arial, sans-serif';
    Chart.defaults.global.defaultFontColor = '#858796';

    var healthCtx = document.getElementById('healthChart');
    if (healthCtx) {
        new Chart(healthCtx, {
            type: 'doughnut',
            data: {
                labels: ['Sẵn sàng trong kho', 'Bị hỏng', 'Công việc chờ xử lý'],
                datasets: [{
                    data: [
                        Number('${inStockGenerators}' || 0),
                        Number('${damagedGenerators}' || 0),
                        Number('${pendingWork}' || 0)
                    ],
                    backgroundColor: ['#1cc88a', '#e74a3b', '#36b9cc'],
                    hoverBackgroundColor: ['#17a673', '#be2617', '#2c9faf'],
                    hoverBorderColor: 'rgba(234, 236, 244, 1)'
                }]
            },
            options: {
                maintainAspectRatio: false,
                legend: { display: false },
                cutoutPercentage: 72,
                tooltips: {
                    backgroundColor: 'rgb(255,255,255)',
                    bodyFontColor: '#858796',
                    borderColor: '#dddfeb',
                    borderWidth: 1,
                    displayColors: false
                }
            }
        });
    }
</script>

</body>
</html>
