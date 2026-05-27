<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manager Home | Generator Management System</title>
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
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-2">Manager workspace</div>
                            <h1 class="h3 text-gray-900 mb-2">Approval and Operations Control</h1>
                            <p class="mb-0 text-gray-700">Review pending requests, track purchase flow, monitor inventory and repair workload.</p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0">
                            <div class="small text-muted">Signed in as</div>
                            <div class="font-weight-bold">${sessionScope.currentUser.fullName}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty homeError}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${homeError}</div>
                </c:if>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Pending approvals</div>
                                <div class="h4 font-weight-bold text-gray-800">${pendingPartRequests + pendingPurchaseRequests + pendingTransfers}</div>
                                <div class="small text-muted">Requests and transfers waiting</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Purchase orders</div>
                                <div class="h4 font-weight-bold text-gray-800">${pendingPurchaseOrders}</div>
                                <div class="small text-muted">Pending supplier orders</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-danger shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Repair workload</div>
                                <div class="h4 font-weight-bold text-gray-800">${pendingRepairs + inProgressRepairs}</div>
                                <div class="small text-muted">Pending and in progress</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Inventory watch</div>
                                <div class="h4 font-weight-bold text-gray-800">${lowStockParts}</div>
                                <div class="small text-muted">Parts at or below minimum</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-clipboard-check text-warning"></i> Requests and Approval</h6>
                                <p class="small text-muted">Prioritize part requests, purchase requests and warehouse transfers.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/manager/pending-requests" class="btn btn-sm btn-warning">Pending Queue</a>
                                    <a href="${pageContext.request.contextPath}/part-requests" class="btn btn-sm btn-outline-secondary">Part Requests</a>
                                    <a href="${pageContext.request.contextPath}/purchase-requests" class="btn btn-sm btn-outline-secondary">Purchase Requests</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-file-invoice text-primary"></i> Purchasing and Suppliers</h6>
                                <p class="small text-muted">Track supplier orders and keep procurement moving.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/purchase-orders" class="btn btn-sm btn-primary">Purchase orders</a>
                                    <a href="${pageContext.request.contextPath}/suppliers" class="btn btn-sm btn-outline-primary">Suppliers</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-warehouse text-success"></i> Warehouse Overview</h6>
                                <p class="small text-muted">${totalWarehouses} warehouses, ${totalGenerators} generators, ${lowStockParts} low-stock parts.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/warehouses" class="btn btn-sm btn-success">Kho</a>
                                    <a href="${pageContext.request.contextPath}/stock-transfers" class="btn btn-sm btn-outline-success">Transfers</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-chart-bar text-info"></i> Reports and Monitoring</h6>
                                <p class="small text-muted">${unreadNotifications} unread notifications. Review inventory, purchase and repair reports.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/reports?type=inventory" class="btn btn-sm btn-info">Inventory Report</a>
                                    <a href="${pageContext.request.contextPath}/reports?type=repair" class="btn btn-sm btn-outline-info">Repair Report</a>
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
