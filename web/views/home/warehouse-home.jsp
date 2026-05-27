<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Warehouse Home | Generator Management System</title>
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
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-2">Warehouse manager workspace</div>
                            <h1 class="h3 text-gray-900 mb-2">Warehouse and Inventory Control</h1>
                            <p class="mb-0 text-gray-700">Manage stock, generators, parts, warehouse transfers and purchase requests.</p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0">
                            <div class="small text-muted">Assigned role</div>
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
                                <div class="small text-muted">Storage locations</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Generators</div>
                                <div class="h4 font-weight-bold text-gray-800">${totalGenerators}</div>
                                <div class="small text-muted">${inStockGenerators} in stock</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Low stock</div>
                                <div class="h4 font-weight-bold text-gray-800">${lowStockParts}</div>
                                <div class="small text-muted">${totalParts} total part records</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-info shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Transactions</div>
                                <div class="h4 font-weight-bold text-gray-800">${inventoryTransactions}</div>
                                <div class="small text-muted">${pendingTransfers} transfers pending</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-bolt text-primary"></i> Asset Management</h6>
                                <p class="small text-muted">Track generators and parts. ${maintenanceGenerators} generators are currently in maintenance or repair.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/generators" class="btn btn-sm btn-primary">Generators</a>
                                    <a href="${pageContext.request.contextPath}/parts" class="btn btn-sm btn-outline-primary">Parts</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-boxes text-warning"></i> Inventory Operations</h6>
                                <p class="small text-muted">Create imports/exports and monitor stock movement history.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/inventory-transactions" class="btn btn-sm btn-warning">Import / Export</a>
                                    <a href="${pageContext.request.contextPath}/inventory-transactions/history" class="btn btn-sm btn-outline-warning">History</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-shopping-cart text-success"></i> Purchase and Transfer Requests</h6>
                                <p class="small text-muted">${pendingPurchaseRequests} purchase requests and ${pendingTransfers} warehouse transfers pending.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/purchase-requests" class="btn btn-sm btn-success">Purchase Requests</a>
                                    <a href="${pageContext.request.contextPath}/stock-transfers" class="btn btn-sm btn-outline-success">Stock Transfers</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-truck text-info"></i> Suppliers</h6>
                                <p class="small text-muted">${totalSuppliers} suppliers are available for purchase flow.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/suppliers" class="btn btn-sm btn-info">Suppliers</a>
                                    <a href="${pageContext.request.contextPath}/inventory/low-stock" class="btn btn-sm btn-outline-info">Low Stock Watch</a>
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
