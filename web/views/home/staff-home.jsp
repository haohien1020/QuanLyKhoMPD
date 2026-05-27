<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Staff Home | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .home-hero { background:#fff; border-left:.25rem solid #36b9cc; }
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
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-2">Staff workspace</div>
                            <h1 class="h3 text-gray-900 mb-2">Daily Operations</h1>
                            <p class="mb-0 text-gray-700">View generators and parts, submit requests, report repairs and update assigned work.</p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0">
                            <div class="small text-muted">Welcome</div>
                            <div class="font-weight-bold">${sessionScope.currentUser.fullName}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty homeError}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${homeError}</div>
                </c:if>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Generators</div>
                                <div class="h4 font-weight-bold text-gray-800">${totalGenerators}</div>
                                <div class="small text-muted">Available for lookup</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Parts</div>
                                <div class="h4 font-weight-bold text-gray-800">${totalParts}</div>
                                <div class="small text-muted">${lowStockParts} low-stock items</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">My requests</div>
                                <div class="h4 font-weight-bold text-gray-800">${myPartRequests}</div>
                                <div class="small text-muted">${myPendingPartRequests} pending</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-danger shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Repair Work</div>
                                <div class="h4 font-weight-bold text-gray-800">${myRepairTasks}</div>
                                <div class="small text-muted">${myRepairReports} reports created</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-search text-primary"></i> Lookup Assets</h6>
                                <p class="small text-muted">Quickly check generator and part information before creating requests or repair reports.</p>
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
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-plus-circle text-warning"></i> Part Requests</h6>
                                <p class="small text-muted">Create part requests and follow approval status from your workspace.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/staff/part-request/create" class="btn btn-sm btn-warning">Create Request</a>
                                    <a href="${pageContext.request.contextPath}/staff/my-requests" class="btn btn-sm btn-outline-warning">My requests</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-dolly-flatbed text-success"></i> Inventory Work</h6>
                                <p class="small text-muted">${inventoryTransactions} inventory transactions exist in the system.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/inventory-transactions" class="btn btn-sm btn-success">Import / Export</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-wrench text-danger"></i> Repair Tasks</h6>
                                <p class="small text-muted">Report generator issues, view assigned repair work and update progress.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/staff/repair-request/create" class="btn btn-sm btn-danger">Report Issue</a>
                                    <a href="${pageContext.request.contextPath}/staff/repair-tasks" class="btn btn-sm btn-outline-danger">My Tasks</a>
                                    <a href="${pageContext.request.contextPath}/staff/repair-progress" class="btn btn-sm btn-outline-danger">Progress</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-body d-sm-flex justify-content-between align-items-center">
                        <div>
                            <div class="font-weight-bold text-gray-900">Notifications</div>
                            <div class="small text-muted">You have ${unreadNotifications} unread notification(s).</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/notifications" class="btn btn-sm btn-info mt-3 mt-sm-0">
                            <i class="fas fa-bell"></i> View Notifications
                        </a>
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
