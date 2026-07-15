<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách máy khách đang thuê | Generator Management System</title>

    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
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
        }

        body {
            background-color: #f8f9fc;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        .page-hero {
            background: var(--gradient-primary);
            color: white;
            border-radius: 15px !important;
            padding: 1.75rem 2rem !important;
            box-shadow: 0 10px 30px rgba(54, 185, 204, 0.2);
            margin-bottom: 1.75rem;
        }

        .kpi-card {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            transition: all 0.3s ease;
        }
        .kpi-card:hover {
            transform: translateY(-3px);
        }

        /* Status Badges */
        .badge-pill-custom {
            padding: 0.4em 0.8em;
            font-size: 0.78rem;
            font-weight: 600;
            border-radius: 50rem;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .badge-status-pending { background-color: #fff3cd; color: #856404; }
        .badge-status-approved { background-color: #cce5ff; color: #004085; }
        .badge-status-delivered { background-color: #d1ecf1; color: #0c5460; }
        .badge-status-completed { background-color: #d4edda; color: #155724; }
        .badge-status-cancelled { background-color: #f8d7da; color: #721c24; }

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

        .modal-header-gradient-info {
            background: linear-gradient(135deg, #36b9cc 0%, #1a7f8c 100%);
            border: none;
        }
        .modal-header-gradient-success {
            background: linear-gradient(135deg, #1cc88a 0%, #13855c 100%);
            border: none;
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

                <%-- Page Header Banner --%>
                <div class="page-hero">
                    <div class="d-sm-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-xs font-weight-bold text-uppercase mb-1" style="color: rgba(255,255,255,0.85); letter-spacing: 1px;">Phân công giao máy & Đang thuê</div>
                            <h1 class="h3 text-white mb-2 font-weight-bold"><i class="fas fa-file-contract mr-2"></i>Danh sách máy khách đang thuê</h1>
                            <p class="mb-0 small" style="opacity: 0.9;">Theo dõi toàn bộ thiết bị máy phát điện bạn phụ trách bàn giao, xuất kho và máy khách hàng đang thuê trong thời hạn.</p>
                        </div>
                    </div>
                </div>

                <%-- Notifications / Toast Alerts --%>
                <c:if test="${param.success eq 'generator_export_success'}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success mb-4" role="alert">
                        <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã xuất kho máy phát điện và chuyển trạng thái hợp đồng sang <strong>Đang thuê</strong>.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'generator_export_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger mb-4" role="alert">
                        <i class="fas fa-times-circle mr-2"></i> <strong>Lỗi!</strong> Thao tác xuất kho thất bại hoặc thiết bị không được phân công cho bạn.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>

                <%-- Calculate KPI Counts --%>
                <c:set var="totalCount" value="${assignedContracts.size()}" />
                <c:set var="deliveredCount" value="0" />
                <c:set var="approvedCount" value="0" />
                <c:set var="completedCount" value="0" />

                <c:forEach var="c" items="${assignedContracts}">
                    <c:if test="${c.status eq 'DELIVERED'}">
                        <c:set var="deliveredCount" value="${deliveredCount + 1}" />
                    </c:if>
                    <c:if test="${c.status eq 'APPROVED'}">
                        <c:set var="approvedCount" value="${approvedCount + 1}" />
                    </c:if>
                    <c:if test="${c.status eq 'COMPLETED'}">
                        <c:set var="completedCount" value="${completedCount + 1}" />
                    </c:if>
                </c:forEach>

                <%-- KPI Cards Summary --%>
                <div class="row mb-4">
                    <div class="col-xl-3 col-md-6 mb-3">
                        <div class="card kpi-card border-left-primary h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Tổng đơn được gán</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">${totalCount}</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-file-signature fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-3">
                        <div class="card kpi-card border-left-info h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Máy khách đang thuê</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">${deliveredCount}</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-truck-loading fa-2x text-info"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-3">
                        <div class="card kpi-card border-left-warning h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Chờ giao máy</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">${approvedCount}</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-clock fa-2x text-warning"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-3">
                        <div class="card kpi-card border-left-success h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Đã hoàn thành</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">${completedCount}</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-check-double fa-2x text-success"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Main Table Card --%>
                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-sm-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list mr-1"></i> Danh sách chi tiết hợp đồng thuê & Máy phát điện
                        </h6>
                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="rentedGeneratorsTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                    <tr>
                                        <th>Mã Hợp Đồng</th>
                                        <th>Khách Hàng</th>
                                        <th>Thông Tin Máy Phát Điện</th>
                                        <th style="width:105px">Ngày Thuê</th>
                                        <th style="width:105px">Ngày Trả</th>
                                        <th style="width:130px" class="text-center">Thời Hạn Còn Lại</th>
                                        <th style="width:110px">Trạng Thái</th>
                                        <th style="width:160px" class="text-center">Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${assignedContracts}">
                                        <tr>
                                            <td class="font-weight-bold text-primary">
                                                <code>${c.contractCode}</code>
                                            </td>
                                            <td>
                                                <div class="font-weight-bold text-gray-900">${c.customerName}</div>
                                                <c:if test="${not empty c.customerPhone}">
                                                    <div class="small text-muted"><i class="fas fa-phone fa-fw mr-1"></i>${c.customerPhone}</div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <div class="font-weight-bold text-dark"><i class="fas fa-bolt text-warning mr-1"></i>${c.brand} ${c.generatorName}</div>
                                                <div class="small text-muted">
                                                    <span>Serial: <strong>${not empty c.serialNumber ? c.serialNumber : 'Chưa gán'}</strong></span>
                                                    <c:if test="${not empty c.powerValue}">
                                                        | <span>${c.powerValue}</span>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="small"><i class="fas fa-calendar-alt text-muted mr-1"></i><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy" /></div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty c.actualReturnDate}">
                                                        <div class="small text-success"><i class="fas fa-check-circle mr-1"></i><fmt:formatDate value="${c.actualReturnDate}" pattern="dd/MM/yyyy" /></div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="small text-muted"><i class="fas fa-clock mr-1"></i><fmt:formatDate value="${c.expectedReturnDate}" pattern="dd/MM/yyyy" /> (Dự kiến)</div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center align-middle">
                                                <c:choose>
                                                    <c:when test="${c.status == 'DELIVERED'}">
                                                        <c:choose>
                                                            <c:when test="${c.daysRemaining > 0}">
                                                                <span class="badge badge-light border text-danger p-2 font-weight-bold" title="Còn ${c.daysRemaining} ngày nữa đến hạn trả máy">
                                                                    <i class="fas fa-clock text-danger mr-1"></i>Còn <span class="text-danger font-weight-bold" style="font-size: 1.05rem;">${c.daysRemaining}</span> ngày
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${c.daysRemaining == 0}">
                                                                <span class="badge badge-danger p-2 font-weight-bold" title="Hôm nay là hạn cuối cùng trả máy">
                                                                    <i class="fas fa-exclamation-triangle mr-1"></i>Hạn hôm nay
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-danger p-2 font-weight-bold" title="Đã quá hạn trả máy ${-c.daysRemaining} ngày!">
                                                                    <i class="fas fa-exclamation-circle mr-1"></i>Quá hạn <span style="font-size: 1.05rem;">${-c.daysRemaining}</span> ngày
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center align-middle">
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
                                                        <span class="badge badge-secondary">${c.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center text-nowrap align-middle">
                                                <button type="button" class="btn btn-action-view btn-sm mr-1 px-2"
                                                    onclick="openDetailModal('${c.contractCode}', '${c.sellerName}', '${c.customerName}', '${c.customerPhone}', '${c.customerEmail}', '${c.brand} ${c.generatorName}', '${c.serialNumber}', '${c.rentalPrice}', '${c.depositAmount}', '${c.totalAmount}', '<fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy" />', '<fmt:formatDate value="${c.expectedReturnDate}" pattern="dd/MM/yyyy" />', '${c.status}', '${c.note}')" title="Xem chi tiết">
                                                    <i class="fas fa-eye mr-1"></i> Chi tiết
                                                </button>
                                                <c:if test="${c.status == 'APPROVED'}">
                                                    <button type="button" class="btn btn-action-export btn-sm px-2"
                                                        onclick="openExportModal('${c.rentalContractId}', '${c.contractCode}', '${c.generatorId}', '${c.brand} ${c.generatorName}', '${c.serialNumber}')" title="Xuất kho bàn giao">
                                                        <i class="fas fa-truck-moving mr-1"></i> Xuất kho
                                                    </button>
                                                </c:if>
                                                <c:if test="${c.status == 'DELIVERED'}">
                                                    <a href="${pageContext.request.contextPath}/inventory-transactions"
                                                       class="btn btn-info btn-sm px-2 font-weight-bold"
                                                       title="Nhập kho nhận lại máy phát điện">
                                                        <i class="fas fa-undo mr-1"></i> Trả máy (Nhập kho)
                                                    </a>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
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
                            <tr><td width="35%">Ngày thuê:</td><td class="text-dark" id="detailStartDate"></td></tr>
                            <tr><td>Ngày trả dự kiến:</td><td class="text-dark" id="detailExpectedReturnDate"></td></tr>
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
                <input type="hidden" name="redirect" value="rented-generators">
                
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
                        <label class="font-weight-bold text-muted mb-2"><i class="fas fa-barcode mr-1"></i>Hình ảnh mã vạch Barcode các máy đã chọn:</label>
                        <div id="exportBarcodeListContainer"></div>
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
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>
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

    $(document).ready(function () {
        $('#rentedGeneratorsTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: true,
            language: {
                "emptyTable":     "Không tìm thấy dữ liệu máy khách đang thuê",
                "info":           "Hiển thị từ _START_ đến _END_ trong tổng số _TOTAL_ bản ghi",
                "infoEmpty":      "Hiển thị 0 đến 0 trong 0 bản ghi",
                "infoFiltered":   "(lọc từ _MAX_ bản ghi)",
                "lengthMenu":     "Hiển thị _MENU_ bản ghi",
                "search":         "Tìm kiếm nhanh:",
                "zeroRecords":    "Không tìm thấy dữ liệu phù hợp",
                "paginate": {
                    "first":      "Đầu",
                    "last":       "Cuối",
                    "next":       "Tiếp",
                    "previous":   "Trước"
                }
            }
        });
    });

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

    function renderBarcodeInModal(serials) {
        if (!serials) {
            $('#exportBarcodeGroup').hide();
            return;
        }
        var serialArray = Array.isArray(serials) ? serials : [serials];
        if (serialArray.length === 0) {
            $('#exportBarcodeGroup').hide();
            return;
        }

        var container = $('#exportBarcodeListContainer');
        container.empty();
        
        serialArray.forEach(function(s) {
            if (!s) return;
            try {
                var canvas = document.createElement('canvas');
                JsBarcode(canvas, s, {
                    format: 'CODE128',
                    width: 1.5,
                    height: 55,
                    displayValue: false,
                    margin: 10,
                    background: '#ffffff',
                    lineColor: '#000000'
                });
                
                var cardHtml = '<div class="text-center p-3 bg-light rounded border shadow-sm mb-2" style="max-width: 360px; margin: 0 auto;">'
                             + '<img src="' + canvas.toDataURL('image/png') + '" alt="Barcode" style="height: 55px; max-width: 100%; display: block; margin: 0 auto; background: #ffffff; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 4px; image-rendering: -webkit-optimize-contrast; image-rendering: pixelated;">'
                             + '<div class="font-weight-bold text-dark mt-2" style="font-size: 0.9rem; font-family: monospace; letter-spacing: 1.2px; background: #fff; padding: 3px 8px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-block;">' + s + '</div>'
                             + '</div>';
                container.append(cardHtml);
            } catch(e) {
                console.error('JsBarcode error:', e);
            }
        });
        
        $('#exportBarcodeGroup').show();
    }

    function openExportModal(contractId, contractCode, generatorId, genName, contractSerial) {
        $('#exportContractId').val(contractId);
        $('#exportContractCodeLabel').text(contractCode);
        $('#exportGenModelLabel').text(genName);
        $('#exportNote').val('Xuất kho bàn giao máy cho khách theo hợp đồng ' + contractCode);
        
        var selectEl = $('#exportBarcodeSelect');
        var hiddenEl = $('#exportBarcodeHidden');
        selectEl.empty();
        selectEl.removeAttr('multiple').css('min-height', '');
        selectEl.append('<option value="">-- Chọn máy phát điện sẵn sàng trong kho --</option>');
        
        $('#exportBarcodeGroup').hide();
        
        var designatedSerials = [];
        if (contractSerial) {
            var parts = contractSerial.toString().split(/,\s*/);
            parts.forEach(function(p) {
                p = p.trim();
                if (p) designatedSerials.push(p);
            });
        }
        
        var matchingBarcodes = [];
        if (designatedSerials.length > 0) {
            designatedSerials.forEach(function(s) {
                var match = staffBarcodes.find(function(b) { return b.serialNumber === s; });
                if (match) {
                    matchingBarcodes.push(match);
                }
            });
        }
        
        $('#exportGenModal').find('.dynamic-barcode-hidden').remove();
        
        if (matchingBarcodes.length > 0) {
            var isMulti = matchingBarcodes.length > 1;
            if (isMulti) {
                $('#exportBarcodeLabel').html('Máy phát điện được chỉ định bàn giao (Theo Hợp đồng) <span class="text-danger">*</span>');
                selectEl.attr('multiple', 'multiple').css('min-height', '120px');
            } else {
                $('#exportBarcodeLabel').html('Máy phát điện được chỉ định bàn giao (Theo Hợp đồng) <span class="text-danger">*</span>');
            }
            
            matchingBarcodes.forEach(function(b) {
                selectEl.append($('<option>', {
                    value: b.barcodeId,
                    text: b.generatorName + ' (Serial: ' + b.serialNumber + ')',
                    selected: true
                }));
                $('#exportGenModal form').append('<input type="hidden" name="barcodeId" class="dynamic-barcode-hidden" value="' + b.barcodeId + '">');
            });
            
            selectEl.prop('disabled', true);
            selectEl.removeAttr('name');
            hiddenEl.val('');
            hiddenEl.prop('disabled', true);
            $('#btnSubmitExport').prop('disabled', false);
            
            var selectedSerials = matchingBarcodes.map(function(b) { return b.serialNumber; });
            renderBarcodeInModal(selectedSerials);
        } else {
            var availableModelBarcodes = staffBarcodes.filter(function(b) {
                return b.generatorId == generatorId;
            });
            
            var reqCount = designatedSerials.length > 0 ? designatedSerials.length : 1;
            if (reqCount > 1 || availableModelBarcodes.length > 1) {
                $('#exportBarcodeLabel').html('Chọn máy phát điện sẵn sàng trong kho <span class="text-danger">*</span>');
                selectEl.attr('multiple', 'multiple').css('min-height', '120px');
            } else {
                $('#exportBarcodeLabel').html('Chọn máy phát điện sẵn sàng trong kho <span class="text-danger">*</span>');
            }
            
            if (availableModelBarcodes.length === 0) {
                selectEl.append('<option value="" disabled>Không có máy nào của mẫu này sẵn sàng trong kho</option>');
                $('#btnSubmitExport').prop('disabled', true);
                selectEl.prop('disabled', false);
                selectEl.attr('name', 'barcodeId');
                hiddenEl.val('');
                hiddenEl.prop('disabled', true);
            } else {
                availableModelBarcodes.forEach(function(b, idx) {
                    var isSelected = (idx < reqCount);
                    selectEl.append($('<option>', {
                        value: b.barcodeId,
                        text: b.generatorName + ' (Serial: ' + b.serialNumber + ')',
                        selected: isSelected
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
            if ($(this).prop('disabled')) {
                return;
            }
            var vals = $(this).val();
            if (vals) {
                var valArray = Array.isArray(vals) ? vals : [vals];
                var serials = [];
                valArray.forEach(function(v) {
                    var match = staffBarcodes.find(function(b) { return b.barcodeId == v; });
                    if (match && match.serialNumber) {
                        serials.push(match.serialNumber);
                    }
                });
                if (serials.length > 0) {
                    renderBarcodeInModal(serials);
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
