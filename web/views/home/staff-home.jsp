<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chủ Nhân viên | Hệ thống Quản lý Máy phát điện</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4e73df;
            --success-color: #1cc88a;
            --info-color: #36b9cc;
            --warning-color: #f6c23e;
            --danger-color: #e74a3b;
            --dark-color: #5a5c69;
            --gradient-primary: linear-gradient(135deg, #1f3b5d 0%, #36b9cc 100%);
            --card-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            --card-hover-shadow: 0 0.5rem 2rem rgba(58, 59, 69, 0.15);
        }
        
        body {
            background-color: #f8f9fc;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        .home-hero {
            background: var(--gradient-primary);
            color: white;
            border: none;
            border-radius: 15px !important;
            padding: 2rem !important;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(54, 185, 204, 0.2);
        }

        .home-hero::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 300px;
            height: 300px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
            pointer-events: none;
        }

        .home-hero h1 {
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        .home-hero p {
            font-size: 1.05rem;
            opacity: 0.9;
        }

        .kpi-card {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            overflow: hidden;
        }

        .kpi-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--card-hover-shadow);
        }

        .kpi-card .card-body {
            padding: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .kpi-info {
            display: flex;
            flex-direction: column;
        }

        .kpi-icon-container {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            transition: all 0.3s ease;
        }

        /* KPI Specific Themes */
        .kpi-generators {
            border-left: 5px solid var(--primary-color);
        }
        .kpi-generators .kpi-icon-container {
            background-color: rgba(78, 115, 223, 0.1);
            color: var(--primary-color);
        }
        .kpi-generators:hover .kpi-icon-container {
            background-color: var(--primary-color);
            color: white;
        }

        .kpi-parts {
            border-left: 5px solid var(--success-color);
        }
        .kpi-parts .kpi-icon-container {
            background-color: rgba(28, 200, 138, 0.1);
            color: var(--success-color);
        }
        .kpi-parts:hover .kpi-icon-container {
            background-color: var(--success-color);
            color: white;
        }

        .kpi-deliveries {
            border-left: 5px solid var(--warning-color);
        }
        .kpi-deliveries .kpi-icon-container {
            background-color: rgba(246, 194, 62, 0.1);
            color: var(--warning-color);
        }
        .kpi-deliveries:hover .kpi-icon-container {
            background-color: var(--warning-color);
            color: white;
        }

        .workflow-card {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            transition: all 0.3s ease;
            min-height: 160px;
        }

        .workflow-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--card-hover-shadow);
        }

        .workflow-card .card-body {
            display: flex;
            flex-direction: column;
            padding: 1.5rem;
        }

        .workflow-actions {
            margin-top: auto;
            padding-top: 1rem;
        }

        /* Table custom styling */
        .card-custom {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
        }

        .card-custom .card-header {
            background-color: white !important;
            border-bottom: 1px solid #e3e6f0;
            padding: 1.25rem 1.5rem;
        }

        .table-custom {
            margin-bottom: 0;
        }

        .table-custom th {
            background-color: #f8f9fc;
            color: var(--dark-color);
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 0.5px;
            border-top: none;
            border-bottom: 2px solid #e3e6f0;
            padding: 1rem 1.25rem;
        }

        .table-custom td {
            padding: 1rem 1.25rem;
            vertical-align: middle;
            color: #4a5568;
            font-size: 0.9rem;
            border-bottom: 1px solid #e3e6f0;
        }

        .table-custom tbody tr {
            transition: background-color 0.2s ease;
        }

        .table-custom tbody tr:hover {
            background-color: #f8fafc;
        }

        /* Pill Badges */
        .badge-pill-custom {
            padding: 0.4em 0.8em;
            font-size: 0.75rem;
            font-weight: 600;
            border-radius: 50rem;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .badge-status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        .badge-status-approved {
            background-color: #cce5ff;
            color: #004085;
        }
        .badge-status-delivered {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        .badge-status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        .badge-status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
        }

        /* Custom buttons */
        .btn-action-view {
            color: var(--info-color);
            background-color: transparent;
            border: 1px solid var(--info-color);
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .btn-action-view:hover {
            color: white;
            background-color: var(--info-color);
            box-shadow: 0 4px 10px rgba(54, 185, 204, 0.25);
        }

        .btn-action-export {
            color: var(--success-color);
            background-color: transparent;
            border: 1px solid var(--success-color);
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .btn-action-export:hover {
            color: white;
            background-color: var(--success-color);
            box-shadow: 0 4px 10px rgba(28, 200, 138, 0.25);
        }

        /* Notification block styling */
        .notification-card {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            background: linear-gradient(90deg, #f8f9fc 0%, #ffffff 100%);
            border-left: 4px solid var(--info-color);
        }

        /* Modals style enhancement */
        .modal-header-gradient-info {
            background: linear-gradient(135deg, #36b9cc 0%, #1a7f8c 100%);
            border: none;
        }
        .modal-header-gradient-success {
            background: linear-gradient(135deg, #1cc88a 0%, #13855c 100%);
            border: none;
        }
        .modal-content {
            border: none;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        .modal-body h6 {
            letter-spacing: 0.5px;
            font-size: 0.85rem;
            margin-bottom: 0.5rem;
        }
        .modal-body table td {
            font-size: 0.95rem;
            color: #2d3748;
        }
        .info-box-light {
            background-color: #f7fafc;
            border: 1px solid #edf2f7;
            padding: 12px;
            border-radius: 8px;
            font-size: 0.9rem;
            color: #4a5568;
            min-height: 50px;
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
                
                <div class="home-hero rounded p-4 mb-4">
                    <div class="d-sm-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-xs font-weight-bold text-uppercase mb-2" style="color: rgba(255,255,255,0.85); letter-spacing: 1px;">Không gian làm việc Nhân viên</div>
                            <h1 class="h3 text-white mb-2">Nhiệm vụ hàng ngày của bạn</h1>
                            <p class="mb-0">Kiểm tra tồn kho máy phát điện, tra cứu phụ tùng, xem và xử lý các đơn giao máy phát điện cho khách hàng được phân công.</p>
                        </div>
                        <div class="text-sm-right mt-3 mt-sm-0 bg-white p-3 rounded shadow-sm" style="min-width: 180px; background: rgba(255,255,255,0.15) !important; backdrop-filter: blur(5px); border: 1px solid rgba(255,255,255,0.2);">
                            <div class="small text-white-50">Xin chào</div>
                            <div class="font-weight-bold text-white h6 mb-0">${sessionScope.currentUser.fullName}</div>
                        </div>
                    </div>
                </div>

                <!-- Toast Alerts for Success / Error -->
                <c:if test="${param.success eq 'generator_export_success'}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success" role="alert">
                        <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã xuất kho máy phát điện và cập nhật trạng thái hợp đồng thành Đang thuê.
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'generator_export_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger" role="alert">
                        <i class="fas fa-times-circle mr-2"></i> <strong>Lỗi!</strong> Xuất kho máy phát điện thất bại hoặc thiết bị không được phân công cho bạn.
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                <c:if test="${not empty homeError}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-circle mr-2"></i> ${homeError}</div>
                </c:if>

                <!-- KPI Cards -->
                <div class="row">
                    <div class="col-xl-4 col-md-6 mb-4">
                        <div class="card kpi-card kpi-generators h-100">
                            <div class="card-body">
                                <div class="kpi-info">
                                    <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Máy phát điện</div>
                                    <div class="h4 font-weight-bold text-gray-800 mb-1">${totalGenerators}</div>
                                    <div class="small text-muted">Có sẵn để tra cứu</div>
                                </div>
                                <div class="kpi-icon-container">
                                    <i class="fas fa-bolt"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-md-6 mb-4">
                        <div class="card kpi-card kpi-parts h-100">
                            <div class="card-body">
                                <div class="kpi-info">
                                    <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Phụ tùng / Linh kiện</div>
                                    <div class="h4 font-weight-bold text-gray-800 mb-1">${totalParts}</div>
                                    <div class="small text-muted">${lowStockParts} phụ tùng sắp hết hàng</div>
                                </div>
                                <div class="kpi-icon-container">
                                    <i class="fas fa-tools"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-md-6 mb-4">
                        <div class="card kpi-card kpi-deliveries h-100">
                            <div class="card-body">
                                <div class="kpi-info">
                                    <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Đơn giao máy của tôi</div>
                                    <div class="h4 font-weight-bold text-gray-800 mb-1">${assignedContracts.size()}</div>
                                    <div class="small text-muted">Được gán giao cho khách hàng</div>
                                </div>
                                <div class="kpi-icon-container">
                                    <i class="fas fa-shipping-fast"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Action Cards -->
                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900 mb-2"><i class="fas fa-search text-primary mr-2"></i>Tra cứu tài sản</h6>
                                <p class="small text-muted">Kiểm tra nhanh thông tin thiết bị máy phát điện và linh kiện phụ tùng có sẵn tại chi nhánh.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/generators" class="btn btn-sm btn-primary px-3 mr-2">Máy phát điện</a>
                                    <a href="${pageContext.request.contextPath}/parts" class="btn btn-sm btn-outline-primary px-3 mr-2">Phụ tùng</a>
                                    <a href="${pageContext.request.contextPath}/staff/rented-generators" class="btn btn-sm btn-info px-3">Máy khách đang thuê</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <c:if test="${sessionScope.currentUser.canImportInventory or sessionScope.currentUser.canExportInventory}">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900 mb-2"><i class="fas fa-dolly-flatbed text-success mr-2"></i>Nghiệp vụ xuất nhập kho</h6>
                                <p class="small text-muted">Đang có ${inventoryTransactions} lịch sử giao dịch được ghi nhận trong hệ thống.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/inventory-transactions" class="btn btn-sm btn-success px-3">Nhập kho / Xuất kho</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    </c:if>
                </div>

                <!-- Assigned Deliveries List -->
                <div class="card card-custom shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-info"><i class="fas fa-shipping-fast mr-2"></i>Danh sách giao máy phát điện cho khách</h6>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-custom table-hover" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>Mã hợp đồng</th>
                                        <th>Khách hàng</th>
                                        <th>Thiết bị yêu cầu</th>
                                        <th>Ngày bắt đầu</th>
                                        <th>Trạng thái</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${assignedContracts}">
                                        <tr>
                                            <td><strong>${c.contractCode}</strong></td>
                                            <td>${c.customerName}</td>
                                            <td>${c.brand} ${c.generatorName}</td>
                                            <td>
                                                <fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy" />
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.status == 'PENDING'}">
                                                        <span class="badge-pill-custom badge-status-pending"><i class="fas fa-clock mr-1"></i>Chờ xử lý</span>
                                                    </c:when>
                                                    <c:when test="${c.status == 'APPROVED'}">
                                                        <span class="badge-pill-custom badge-status-approved"><i class="fas fa-check mr-1"></i>Chờ giao máy</span>
                                                    </c:when>
                                                    <c:when test="${c.status == 'DELIVERED'}">
                                                        <span class="badge-pill-custom badge-status-delivered"><i class="fas fa-truck mr-1"></i>Đang thuê</span>
                                                    </c:when>
                                                    <c:when test="${c.status == 'COMPLETED'}">
                                                        <span class="badge-pill-custom badge-status-completed"><i class="fas fa-check-double mr-1"></i>Đã hoàn thành</span>
                                                    </c:when>
                                                    <c:when test="${c.status == 'CANCELLED'}">
                                                        <span class="badge-pill-custom badge-status-cancelled"><i class="fas fa-times mr-1"></i>Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-pill-custom badge-secondary">${c.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <button type="button" class="btn btn-action-view btn-sm mr-2 px-2"
                                                    onclick="openDetailModal('${c.contractCode}', '${c.sellerName}', '${c.customerName}', '${c.customerPhone}', '${c.customerEmail}', '${c.brand} ${c.generatorName}', '${c.serialNumber}', '${c.rentalPrice}', '${c.depositAmount}', '${c.totalAmount}', '<fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy" />', '<fmt:formatDate value="${c.expectedReturnDate}" pattern="dd/MM/yyyy" />', '${c.status}', '${c.note}')">
                                                    <i class="fas fa-eye mr-1"></i> Chi tiết
                                                </button>
                                                <c:if test="${c.status == 'APPROVED'}">
                                                    <button type="button" class="btn btn-action-export btn-sm px-2"
                                                        onclick="openExportModal('${c.rentalContractId}', '${c.contractCode}', '${c.generatorId}', '${c.brand} ${c.generatorName}', '${c.serialNumber}')">
                                                        <i class="fas fa-truck-moving mr-1"></i> Xuất kho
                                                    </button>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty assignedContracts}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-5">
                                                <i class="fas fa-check-circle text-success fa-3x mb-3"></i>
                                                <div class="font-weight-bold">Không có đơn giao máy nào</div>
                                                <div class="small">Bạn đã hoàn thành hoặc chưa được phân công đơn giao máy nào tại thời điểm này.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Notifications Summary -->
                <div class="card notification-card shadow-sm mb-4">
                    <div class="card-body d-sm-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="font-weight-bold text-gray-900"><i class="fas fa-bell text-info mr-2"></i>Thông báo hệ thống</div>
                            <div class="small text-muted">Bạn đang có ${unreadNotifications} thông báo chưa đọc.</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/notifications" class="btn btn-sm btn-info px-3 mt-3 mt-sm-0">
                            <i class="fas fa-bell mr-1"></i> Xem tất cả thông báo
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <%@ include file="/views/layout/footer.jsp" %>
    </div>
</div>

<!-- Modal Chi tiết Hợp đồng -->
<div class="modal fade" id="contractDetailModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content text-gray-900">
            <div class="modal-header modal-header-gradient-info text-white">
                <h5 class="modal-title"><i class="fas fa-file-contract mr-2"></i>Chi tiết Hợp đồng: <span id="detailContractCode" class="font-weight-bold"></span></h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6 border-right">
                        <h6 class="font-weight-bold text-primary"><i class="fas fa-user-tie mr-2"></i>Nhân viên kinh doanh (Seller)</h6>
                        <p class="mb-3 font-weight-bold text-dark" id="detailSellerName"></p>
                        
                        <h6 class="font-weight-bold text-primary"><i class="fas fa-user mr-2"></i>Thông tin khách hàng</h6>
                        <table class="table table-sm table-borderless">
                            <tr><td width="35%">Họ tên:</td><td class="font-weight-bold text-dark" id="detailCustomerName"></td></tr>
                            <tr><td>Điện thoại:</td><td class="text-dark" id="detailCustomerPhone"></td></tr>
                            <tr><td>Email:</td><td class="text-dark" id="detailCustomerEmail"></td></tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h6 class="font-weight-bold text-primary"><i class="fas fa-bolt mr-2"></i>Thiết bị thuê</h6>
                        <p class="mb-1 font-weight-bold text-dark" id="detailGeneratorName"></p>
                        <p class="mb-3 text-muted small">Số Serial: <span class="font-weight-bold text-dark" id="detailSerialNumber"></span></p>
                        
                        <h6 class="font-weight-bold text-primary"><i class="fas fa-calendar-alt mr-2"></i>Thời gian thuê</h6>
                        <table class="table table-sm table-borderless">
                            <tr><td width="35%">Bắt đầu:</td><td class="text-dark" id="detailStartDate"></td></tr>
                            <tr><td>Trả dự kiến:</td><td class="text-dark" id="detailExpectedReturnDate"></td></tr>
                            <tr><td>Trạng thái:</td><td id="detailStatus"></td></tr>
                        </table>
                    </div>
                </div>
                <hr>
                <div class="row">
                    <div class="col-12">
                        <h6 class="font-weight-bold text-primary"><i class="fas fa-sticky-note mr-2"></i>Ghi chú bàn giao / hợp đồng</h6>
                        <div class="info-box-light" id="detailNote"></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Xuất kho bàn giao máy -->
<div class="modal fade" id="exportGenModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content text-gray-900">
            <div class="modal-header modal-header-gradient-success text-white">
                <h5 class="modal-title"><i class="fas fa-truck-moving mr-2"></i>Xuất kho bàn giao máy</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/inventory-transactions">
                <input type="hidden" name="action" value="export-generator">
                <input type="hidden" name="exportStatus" value="EXPORTED">
                <input type="hidden" name="contractId" id="exportContractId">
                <input type="hidden" name="redirect" value="home">
                
                <div class="modal-body">
                    <div class="form-group mb-3">
                        <label class="font-weight-bold text-muted mb-1">Mã hợp đồng:</label>
                        <div class="h6 font-weight-bold text-primary" id="exportContractCodeLabel"></div>
                    </div>
                    <div class="form-group mb-3">
                        <label class="font-weight-bold text-muted mb-1">Mẫu máy phát điện yêu cầu:</label>
                        <div class="h6 font-weight-bold text-info" id="exportGenModelLabel"></div>
                    </div>
                    <div class="form-group mb-3">
                        <label for="exportBarcodeSelect" class="font-weight-bold" id="exportBarcodeLabel">Chọn máy phát điện sẵn sàng trong kho <span class="text-danger">*</span></label>
                        <select id="exportBarcodeSelect" class="form-control" required>
                            <!-- Tùy chọn tải động -->
                        </select>
                        <input type="hidden" name="barcodeId" id="exportBarcodeHidden">
                    </div>
                    <div class="form-group mb-3" id="exportBarcodeGroup" style="display:none;">
                        <label class="font-weight-bold text-muted mb-1">Mã vạch Barcode:</label>
                        <div class="text-center p-3 bg-light rounded border shadow-sm">
                            <img id="exportBarcodeImg" src="" alt="Barcode" style="height: 60px; max-width: 100%; width: auto; display: block; margin: 0 auto; background: #ffffff; padding: 6px 12px; border: 1px solid #cbd5e1; border-radius: 6px; image-rendering: -webkit-optimize-contrast; image-rendering: pixelated;">
                            <div class="font-weight-bold text-dark mt-2" id="exportBarcodeLabelText" style="font-size: 0.92rem; font-family: 'Courier New', monospace; letter-spacing: 1.2px; word-break: break-all; background: #fff; padding: 4px 10px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-block;"></div>
                        </div>
                    </div>
                    <div class="form-group mb-3">
                        <label for="exportNote" class="font-weight-bold">Ghi chú xuất kho <span class="text-danger">*</span></label>
                        <textarea id="exportNote" name="note" class="form-control" rows="3" placeholder="Nhập ghi chú xuất kho bàn giao..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success px-4" id="btnSubmitExport">Xác nhận Xuất kho</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/JsBarcode.all.min.js"></script>

<script>
    var staffBarcodes = [
        <c:forEach var="gb" items="${staffBarcodes}" varStatus="loop">
            {
                barcodeId: ${gb.barcodeId},
                generatorId: ${gb.generatorId},
                generatorName: '${gb.generatorName.replace("'", "\\'")}',
                serialNumber: '${gb.serialNumber.replace("'", "\\'")}',
                barcode: '${gb.barcode != null ? gb.barcode.replace("'", "\\'") : ""}'
            }${!loop.last ? ',' : ''}
        </c:forEach>
    ];

    function openDetailModal(code, sellerName, custName, custPhone, custEmail, genName, serial, price, deposit, total, start, end, status, note) {
        $('#detailContractCode').text(code);
        $('#detailSellerName').text(sellerName && sellerName !== 'null' && sellerName !== '' ? sellerName : 'Chưa xác định');
        $('#detailCustomerName').text(custName);
        $('#detailCustomerPhone').text(custPhone && custPhone !== 'null' && custPhone !== '' ? custPhone : 'Chưa cập nhật');
        $('#detailCustomerEmail').text(custEmail && custEmail !== 'null' && custEmail !== '' ? custEmail : 'Chưa cập nhật');
        $('#detailGeneratorName').text(genName);
        
        var serialEl = $('#detailSerialNumber');
        serialEl.empty();
        if (serial && serial !== 'null' && serial !== '' && serial !== 'Chưa cập nhật') {
            var serials = serial.split(', ');
            var html = '';
            serials.forEach(function(s) {
                html += '<div style="font-size: 0.78rem; font-weight: 600; line-height: 1.3; margin-top: 2px; color: #2d3748;">- ' + s + '</div>';
            });
            serialEl.html(html);
        } else {
            serialEl.text('Chưa cập nhật');
        }
        $('#detailStartDate').text(start);
        $('#detailExpectedReturnDate').text(end);
        
        var statusText = status;
        var statusClass = 'badge-status-pending';
        var statusIcon = 'fa-clock';
        if (status === 'PENDING') { statusText = 'Chờ xử lý'; statusClass = 'badge-status-pending'; statusIcon = 'fa-clock'; }
        else if (status === 'APPROVED') { statusText = 'Chờ giao máy'; statusClass = 'badge-status-approved'; statusIcon = 'fa-check'; }
        else if (status === 'DELIVERED') { statusText = 'Đang thuê'; statusClass = 'badge-status-delivered'; statusIcon = 'fa-truck'; }
        else if (status === 'COMPLETED') { statusText = 'Đã hoàn thành'; statusClass = 'badge-status-completed'; statusIcon = 'fa-check-double'; }
        else if (status === 'CANCELLED') { statusText = 'Đã hủy'; statusClass = 'badge-status-cancelled'; statusIcon = 'fa-times'; }
        
        $('#detailStatus').html('<span class="badge-pill-custom ' + statusClass + '"><i class="fas ' + statusIcon + ' mr-1"></i>' + statusText + '</span>');
        $('#detailNote').text(note && note !== 'null' && note !== '' ? note : 'Không có ghi chú');
        $('#contractDetailModal').modal('show');
    }

    function renderBarcodeInModal(serial) {
        if (serial) {
            try {
                var canvas = document.createElement('canvas');
                JsBarcode(canvas, serial, {
                    format: 'CODE128',
                    width: 1.5,
                    height: 60,
                    displayValue: false,
                    margin: 10,
                    background: '#ffffff',
                    lineColor: '#000000'
                });
                $('#exportBarcodeImg').attr('src', canvas.toDataURL('image/png')).show();
                $('#exportBarcodeLabelText').text(serial);
                $('#exportBarcodeGroup').show();
            } catch(e) {
                console.error('JsBarcode error:', e);
                $('#exportBarcodeGroup').hide();
            }
        } else {
            $('#exportBarcodeGroup').hide();
        }
    }

    function openExportModal(contractId, contractCode, generatorId, genName, contractSerial) {
        $('#exportContractId').val(contractId);
        $('#exportContractCodeLabel').text(contractCode);
        $('#exportGenModelLabel').text(genName);
        $('#exportNote').val('Xuất kho bàn giao máy cho khách theo hợp đồng ' + contractCode);
        
        var selectEl = $('#exportBarcodeSelect');
        var hiddenEl = $('#exportBarcodeHidden');
        selectEl.empty();
        selectEl.append('<option value="">-- Chọn máy phát điện sẵn sàng trong kho --</option>');
        
        $('#exportBarcodeGroup').hide();
        
        var matchingBarcodes = staffBarcodes.filter(function(b) {
            return b.generatorId == generatorId;
        });
        
        var exactMatch = null;
        if (contractSerial) {
            matchingBarcodes.forEach(function(b) {
                if (b.serialNumber === contractSerial) {
                    exactMatch = b;
                }
            });
        }
        
        if (contractSerial && !exactMatch) {
            $('#exportBarcodeLabel').html('Máy phát điện được chỉ định bàn giao (Theo Hợp đồng) <span class="text-danger">*</span>');
            selectEl.append($('<option>', {
                value: "",
                text: genName + ' (Số Serial: ' + contractSerial + ' - Không sẵn sàng trong kho)',
                selected: true,
                disabled: true
            }));
            selectEl.prop('disabled', true);
            selectEl.removeAttr('name');
            hiddenEl.val('');
            hiddenEl.prop('disabled', true);
            $('#btnSubmitExport').prop('disabled', true);
        } else if (contractSerial && exactMatch) {
            $('#exportBarcodeLabel').html('Máy phát điện được chỉ định bàn giao (Theo Hợp đồng) <span class="text-danger">*</span>');
            selectEl.append($('<option>', {
                value: exactMatch.barcodeId,
                text: exactMatch.generatorName + ' (Mã vạch: ' + exactMatch.serialNumber + ')',
                selected: true
            }));
            selectEl.prop('disabled', true);
            selectEl.removeAttr('name');
            hiddenEl.val(exactMatch.barcodeId);
            hiddenEl.prop('disabled', false);
            $('#btnSubmitExport').prop('disabled', false);
            
            renderBarcodeInModal(exactMatch.serialNumber);
        } else {
            $('#exportBarcodeLabel').html('Chọn máy phát điện sẵn sàng trong kho <span class="text-danger">*</span>');
            if (matchingBarcodes.length === 0) {
                selectEl.append('<option value="" disabled>Không có máy nào của mẫu này sẵn sàng trong kho</option>');
                $('#btnSubmitExport').prop('disabled', true);
                selectEl.prop('disabled', false);
                selectEl.attr('name', 'barcodeId');
                hiddenEl.val('');
                hiddenEl.prop('disabled', true);
            } else {
                matchingBarcodes.forEach(function(b) {
                    selectEl.append($('<option>', {
                        value: b.barcodeId,
                        text: b.generatorName + ' (Mã vạch: ' + b.serialNumber + ')'
                    }));
                });
                selectEl.prop('disabled', false);
                selectEl.attr('name', 'barcodeId');
                hiddenEl.val('');
                hiddenEl.prop('disabled', true);
                $('#btnSubmitExport').prop('disabled', false);
                selectEl.trigger('change');
            }
        }
        
        $('#exportGenModal').modal('show');
    }

    $(document).ready(function() {
        $('#exportBarcodeSelect').on('change', function() {
            var barcodeId = $(this).val();
            if (barcodeId) {
                var match = staffBarcodes.find(function(b) { return b.barcodeId == barcodeId; });
                if (match && match.serialNumber) {
                    renderBarcodeInModal(match.serialNumber);
                } else {
                    $('#exportBarcodeGroup').hide();
                }
            } else {
                $('#exportBarcodeGroup').hide();
            }
        });
    });
</script>
</body>
</html>
