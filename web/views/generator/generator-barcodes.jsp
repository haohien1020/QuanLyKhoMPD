<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Generator" %>
<%@ page import="model.GeneratorBarcode" %>

<%
    @SuppressWarnings("unchecked")
    List<GeneratorBarcode> barcodes = (List<GeneratorBarcode>) request.getAttribute("barcodes");
    @SuppressWarnings("unchecked")
    List<Generator> generators = (List<Generator>) request.getAttribute("generators");

    Integer filterGeneratorId = (Integer) request.getAttribute("filterGeneratorId");
    String filterStatus = (String) request.getAttribute("filterStatus");
    String filterKeyword = (String) request.getAttribute("filterKeyword");

    int totalCount = barcodes != null ? barcodes.size() : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách mã vạch & Serial | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
            --card-shadow: 0 4px 20px 0 rgba(0,0,0,0.06);
        }
        .premium-card {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
        }
        .page-header-gradient {
            background: var(--primary-gradient);
            border-radius: 12px;
            padding: 20px 28px;
            color: #fff;
            margin-bottom: 24px;
        }
        .stat-badge {
            background: rgba(255,255,255,0.18);
            border-radius: 8px;
            padding: 6px 16px;
            font-size: 0.95rem;
            font-weight: 600;
        }
        .table thead th {
            white-space: nowrap;
            vertical-align: middle !important;
            text-align: center;
            background: #f8faff;
        }
        .table tbody td {
            vertical-align: middle !important;
        }
        .filter-card {
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            background: #fff;
            padding: 16px 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .barcode-img-cell img, img.barcode-render {
            height: auto;
            max-width: 100%;
            width: auto;
            display: block;
            margin: 0 auto;
            image-rendering: -webkit-optimize-contrast;
            image-rendering: crisp-edges;
            image-rendering: pixelated;
            background-color: #ffffff;
            padding: 3px 8px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
        }
        .status-badge { font-size: 0.78rem; }
        .back-link {
            color: rgba(255,255,255,0.85);
            font-size: 0.85rem;
            text-decoration: none;
        }
        .back-link:hover { color: #fff; text-decoration: underline; }
        .generator-chip {
            display: inline-block;
            background: #eef2ff;
            border: 1px solid #c7d2fe;
            border-radius: 20px;
            padding: 2px 12px;
            font-size: 0.8rem;
            color: #4338ca;
            font-weight: 600;
            white-space: nowrap;
        }
        .search-box { position: relative; }
        .search-box .clear-btn {
            position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
            cursor: pointer; color: #aaa; background: none; border: none; font-size: 0.9rem;
            display: none;
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

                <!-- Page Header -->
                <div class="page-header-gradient d-flex align-items-center justify-content-between flex-wrap">
                    <div>
                        <a href="${pageContext.request.contextPath}/generators" class="back-link mb-1 d-inline-block">
                            <i class="fas fa-arrow-left mr-1"></i> Quay lại danh sách máy phát điện
                        </a>
                        <h1 class="h3 mb-0 font-weight-bold mt-1">
                            <i class="fas fa-barcode mr-2"></i>Danh sách mã vạch &amp; Serial
                        </h1>
                        <% if (filterGeneratorId != null && filterGeneratorId > 0 && generators != null) {
                            for (Generator g : generators) {
                                if (g.getGeneratorId() == filterGeneratorId) { %>
                        <div class="mt-1 small" style="opacity:0.85;">
                            Đang xem: <strong><%= g.getGeneratorName() %></strong>
                            &nbsp;|&nbsp; <%= g.getBrand() != null ? g.getBrand() : "" %>
                            &nbsp;<%= g.getPowerValue() != null ? g.getPowerValue() : "" %>
                        </div>
                        <%          break;
                                }
                            }
                        } %>
                    </div>
                    <div class="stat-badge mt-2 mt-sm-0">
                        <i class="fas fa-qrcode mr-1"></i>
                        Tổng: <strong><%= totalCount %></strong> mã vạch
                    </div>
                </div>

                <!-- Filter Card -->
                <div class="filter-card">
                    <form method="get" action="${pageContext.request.contextPath}/generators/barcodes" class="row align-items-end" id="filterForm">
                        <div class="form-group col-md-4 mb-2">
                            <label class="font-weight-bold text-gray-700 mb-1" style="font-size:0.85rem;">
                                <i class="fas fa-bolt mr-1 text-primary"></i> Mẫu máy phát điện
                            </label>
                            <select name="generatorId" id="generatorFilter" class="form-control form-control-sm" onchange="this.form.submit()">
                                <option value="">-- Tất cả mẫu máy --</option>
                                <% if (generators != null) {
                                    for (Generator g : generators) { %>
                                <option value="<%= g.getGeneratorId() %>"
                                    <%= (filterGeneratorId != null && filterGeneratorId == g.getGeneratorId()) ? "selected" : "" %>>
                                    <%= g.getGeneratorName() %>
                                    (<%= g.getBrand() != null ? g.getBrand() : "" %>
                                    <%= g.getPowerValue() != null ? g.getPowerValue() : "" %>)
                                </option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="form-group col-md-3 mb-2">
                            <label class="font-weight-bold text-gray-700 mb-1" style="font-size:0.85rem;">
                                <i class="fas fa-tag mr-1 text-warning"></i> Trạng thái
                            </label>
                            <select name="status" class="form-control form-control-sm" onchange="this.form.submit()">
                                <option value="" <%= (filterStatus == null || filterStatus.isEmpty()) ? "selected" : "" %>>-- Tất cả --</option>
                                <option value="IN_STOCK"    <%= "IN_STOCK".equals(filterStatus)    ? "selected" : "" %>>Trong kho</option>
                                <option value="EXPORTED"   <%= "EXPORTED".equals(filterStatus)   ? "selected" : "" %>>Đã xuất kho</option>
                                <option value="TRANSFERRED" <%= "TRANSFERRED".equals(filterStatus) ? "selected" : "" %>>Đã chuyển kho</option>
                                <option value="UNDER_REPAIR"<%= "UNDER_REPAIR".equals(filterStatus)? "selected":"" %>>Đang sửa chữa</option>
                                <option value="MAINTENANCE" <%= "MAINTENANCE".equals(filterStatus) ? "selected" : "" %>>Bảo trì</option>
                                <option value="DAMAGED"    <%= "DAMAGED".equals(filterStatus)    ? "selected" : "" %>>Đã hỏng</option>
                            </select>
                        </div>
                        <div class="form-group col-md-4 mb-2">
                            <label class="font-weight-bold text-gray-700 mb-1" style="font-size:0.85rem;">
                                <i class="fas fa-search mr-1 text-info"></i> Tìm kiếm
                            </label>
                            <div class="search-box">
                                <input type="text" name="q" id="searchInput" class="form-control form-control-sm"
                                       placeholder="Nhập serial, tên máy..."
                                       value="<%= filterKeyword != null ? filterKeyword : "" %>">
                                <button type="button" class="clear-btn" id="clearSearch" title="Xóa">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                        <div class="form-group col-md-1 mb-2">
                            <button type="submit" class="btn btn-primary btn-sm w-100">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </form>
                    <% if ((filterGeneratorId != null && filterGeneratorId > 0) || (filterStatus != null && !filterStatus.isEmpty()) || (filterKeyword != null && !filterKeyword.isEmpty())) { %>
                    <div class="mt-1">
                        <a href="${pageContext.request.contextPath}/generators/barcodes" class="btn btn-outline-secondary btn-xs py-0 px-2" style="font-size:0.8rem;">
                            <i class="fas fa-times-circle mr-1"></i> Xóa bộ lọc
                        </a>
                    </div>
                    <% } %>
                </div>

                <!-- Table Card -->
                <div class="card premium-card shadow mb-4">
                    <div class="card-header py-3 d-flex align-items-center justify-content-between bg-white">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list mr-1"></i> Danh sách mã vạch
                            <span class="badge badge-primary ml-1"><%= totalCount %></span>
                        </h6>
                        <div class="text-muted small">
                            <i class="fas fa-info-circle mr-1"></i>
                            Mỗi dòng là 1 máy phát điện vật lý riêng biệt
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover mb-0" id="barcodesTable">
                                <thead class="thead-light">
                                    <tr>
                                        <th class="text-center" style="width:50px;">#</th>
                                        <th class="text-center">Mẫu máy phát điện</th>
                                        <th class="text-center">Số Serial</th>
                                        <th class="text-center" style="min-width:140px;">Mã vạch</th>
                                        <th class="text-center">Trạng thái</th>
                                        <th class="text-center">Ngày tạo</th>
                                        <th class="text-center" style="width:80px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% if (barcodes == null || barcodes.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-5">
                                        <i class="fas fa-barcode fa-3x mb-3 text-gray-300 d-block"></i>
                                        Không tìm thấy mã vạch nào khớp với bộ lọc.
                                    </td>
                                </tr>
                                <% } else {
                                    int rowNum = 0;
                                    for (GeneratorBarcode gb : barcodes) {
                                        rowNum++;
                                        String statusBadge;
                                        switch (gb.getStatus() != null ? gb.getStatus() : "") {
                                            case "IN_STOCK":    statusBadge = "<span class='badge badge-success status-badge px-2 py-1'>Trong kho</span>"; break;
                                            case "EXPORTED":    statusBadge = "<span class='badge badge-secondary status-badge px-2 py-1'>Đã xuất kho</span>"; break;
                                            case "TRANSFERRED": statusBadge = "<span class='badge badge-info status-badge px-2 py-1'>Đã chuyển kho</span>"; break;
                                            case "UNDER_REPAIR":statusBadge = "<span class='badge badge-danger status-badge px-2 py-1'>Đang sửa chữa</span>"; break;
                                            case "MAINTENANCE": statusBadge = "<span class='badge badge-warning status-badge px-2 py-1'>Bảo trì</span>"; break;
                                            case "DAMAGED":     statusBadge = "<span class='badge badge-dark status-badge px-2 py-1'>Đã hỏng</span>"; break;
                                            default:            statusBadge = "<span class='badge badge-light status-badge px-2 py-1'>" + gb.getStatus() + "</span>"; break;
                                        }
                                        String createdStr = gb.getCreatedAt() != null
                                            ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(gb.getCreatedAt()) : "-";
                                %>
                                <%
                                        Generator genDetail = null;
                                        if (generators != null) {
                                            for (Generator gd : generators) {
                                                if (gd.getGeneratorId() == gb.getGeneratorId()) {
                                                    genDetail = gd;
                                                    break;
                                                }
                                            }
                                        }
                                        String safeGenName    = genDetail != null && genDetail.getGeneratorName() != null ? genDetail.getGeneratorName().replace("'", "\\'") : "-";
                                        String safeSerial     = gb.getSerialNumber() != null ? gb.getSerialNumber().replace("'", "\\'") : "-";
                                        String safeBrand      = genDetail != null && genDetail.getBrand() != null ? genDetail.getBrand().replace("'", "\\'") : "-";
                                        String safePower      = genDetail != null && genDetail.getPowerValue() != null ? genDetail.getPowerValue().replace("'", "\\'") : "-";
                                        String safeFuel       = genDetail != null && genDetail.getFuelType() != null ? genDetail.getFuelType().replace("'", "\\'") : "-";
                                        String safeLocation   = genDetail != null && genDetail.getLocation() != null ? genDetail.getLocation().replace("'", "\\'") : "-";
                                        String safeNote       = genDetail != null && genDetail.getNote() != null ? genDetail.getNote().replace("'", "\\'").replace("\n", " ") : "-";
                                        String priceStr       = genDetail != null && genDetail.getPurchasePrice() != null ? String.format("%,.0f", genDetail.getPurchasePrice()) : "-";
                                        String rentalPriceStr = genDetail != null && genDetail.getRentalPrice() != null ? String.format("%,.0f", genDetail.getRentalPrice()) : "-";
                                        String warehouseStr   = genDetail != null && genDetail.getWarehouseId() > 0 ? String.valueOf(genDetail.getWarehouseId()) : "-";
                                        String unitStatusBadge;
                                        switch (gb.getStatus() != null ? gb.getStatus() : "") {
                                            case "IN_STOCK":     unitStatusBadge = "badge-success"; break;
                                            case "EXPORTED":     unitStatusBadge = "badge-secondary"; break;
                                            case "TRANSFERRED":  unitStatusBadge = "badge-info"; break;
                                            case "UNDER_REPAIR": unitStatusBadge = "badge-danger"; break;
                                            case "MAINTENANCE":  unitStatusBadge = "badge-warning"; break;
                                            case "DAMAGED":      unitStatusBadge = "badge-dark"; break;
                                            default:             unitStatusBadge = "badge-light"; break;
                                        }
                                %>
                                <tr>
                                    <td class="text-center text-muted"><%= rowNum %></td>
                                    <td class="text-center">
                                        <span class="generator-chip">
                                            <i class="fas fa-bolt mr-1"></i><%= gb.getGeneratorName() != null ? gb.getGeneratorName() : "-" %>
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <code class="font-weight-bold text-gray-800"><%= gb.getSerialNumber() %></code>
                                    </td>
                                    <td class="barcode-img-cell text-center" style="cursor:pointer;" onclick="openBarcodeDetail('<%= safeGenName %>', '<%= safeSerial %>', '<%= safeBrand %>', '<%= safePower %>', '<%= safeFuel %>', '<%= priceStr %>', '<%= rentalPriceStr %>', '<%= safeLocation %>', '<%= safeNote %>', '<%= gb.getStatus() != null ? gb.getStatus() : "" %>', '<%= unitStatusBadge %>', '<%= createdStr %>')" title="Click để xem phóng to mã vạch">
                                        <img class="barcode-render" data-serial="<%= gb.getSerialNumber() %>" alt="<%= gb.getSerialNumber() %>">
                                        <div class="text-dark font-weight-bold mt-1" style="font-size:0.75rem; font-family: monospace; letter-spacing: 0.5px;"><%= gb.getSerialNumber() %></div>
                                    </td>
                                    <td class="text-center"><%=statusBadge%></td>
                                    <td class="text-center text-muted" style="font-size:0.82rem;"><%= createdStr %></td>
                                    <td class="text-center">
                                        <button type="button"
                                                class="btn btn-sm btn-light border shadow-sm"
                                                onclick="openBarcodeDetail(
                                                    '<%= safeGenName %>',
                                                    '<%= safeSerial %>',
                                                    '<%= safeBrand %>',
                                                    '<%= safePower %>',
                                                    '<%= safeFuel %>',
                                                    '<%= priceStr %>',
                                                    '<%= rentalPriceStr %>',
                                                    '<%= safeLocation %>',
                                                    '<%= safeNote %>',
                                                    '<%= gb.getStatus() != null ? gb.getStatus() : "" %>',
                                                    '<%= unitStatusBadge %>',
                                                    '<%= createdStr %>'
                                                )"
                                                title="Xem chi tiết">
                                            <i class="fas fa-eye text-primary"></i>
                                        </button>
                                    </td>
                                </tr>
                                <% }
                                } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

<!-- ===== Modal Chi tiết máy phát điện ===== -->
<div class="modal fade" id="barcodeDetailModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-gradient-primary text-white">
                <h5 class="modal-title"><i class="fas fa-info-circle mr-2"></i>Chi tiết máy phát điện</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-4">
                <div class="row">
                    <!-- Left: Generator template info -->
                    <div class="col-md-7 border-right">
                        <h5 class="font-weight-bold text-primary mb-3" id="mdGenName"></h5>
                        <table class="table table-borderless table-sm text-gray-900">
                            <tbody>
                                <tr>
                                    <td class="font-weight-bold text-muted" style="width:150px;">Thương hiệu:</td>
                                    <td id="mdBrand"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Công suất:</td>
                                    <td id="mdPower"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nhiên liệu:</td>
                                    <td id="mdFuel"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Vị trí:</td>
                                    <td id="mdLocation"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Giá mua:</td>
                                    <td id="mdPrice" class="font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Giá thuê:</td>
                                    <td id="mdRentalPrice" class="text-success font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Ghi chú:</td>
                                    <td id="mdNote" class="text-break" style="white-space:pre-line;"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- Right: Physical unit info -->
                    <div class="col-md-5 pl-4">
                        <h6 class="font-weight-bold text-secondary mb-3"><i class="fas fa-microchip mr-1"></i>Thông tin đơn vị vật lý</h6>
                        <div class="mb-3">
                            <div class="small text-muted font-weight-bold mb-1">Số Serial</div>
                            <code class="text-gray-800 font-weight-bold" id="mdSerial" style="font-size:1rem;"></code>
                        </div>
                        <div class="mb-3">
                            <div class="small text-muted font-weight-bold mb-1">Mã vạch Barcode</div>
                            <div class="text-center p-3 bg-light rounded border shadow-sm">
                                <img id="mdBarcodeImg" src="" alt="Barcode" style="height: 60px; max-width: 100%; width: auto; display: block; margin: 0 auto; background: #ffffff; padding: 6px 12px; border: 1px solid #cbd5e1; border-radius: 6px; image-rendering: -webkit-optimize-contrast; image-rendering: crisp-edges; image-rendering: pixelated;">
                                <div class="font-weight-bold text-dark mt-2" id="mdBarcodeLabel" style="font-size: 0.92rem; font-family: 'Courier New', monospace; letter-spacing: 1.2px; word-break: break-all; background: #fff; padding: 4px 10px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-block;"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="small text-muted font-weight-bold mb-1">Trạng thái</div>
                            <span id="mdStatusBadge"></span>
                        </div>
                        <div>
                            <div class="small text-muted font-weight-bold mb-1">Ngày nhập</div>
                            <span id="mdCreatedAt" class="text-gray-700"></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary px-4" data-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>
<!-- ===== end Modal ===== -->

            </div><!-- /container-fluid -->
        </div>
        <%@ include file="/views/layout/footer.jsp" %>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/JsBarcode.all.min.js"></script>

<script>
$(document).ready(function() {
    // DataTable
    $('#barcodesTable').DataTable({
        pageLength: 25,
        ordering: false,
        searching: false,
        lengthChange: true,
        lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'Tất cả']],
        language: {
            paginate: { next: 'Sau', previous: 'Trước' },
            emptyTable: 'Không có dữ liệu',
            info: 'Hiển thị _START_ - _END_ / _TOTAL_ mã',
            infoEmpty: 'Không có dữ liệu',
            lengthMenu: 'Hiển thị _MENU_ dòng'
        }
    });

    // Render barcodes in table cells with clear quiet zone & crisp resolution (larger size for scanning)
    $('.barcode-render').each(function() {
        var serial = $(this).data('serial');
        if (serial) {
            try {
                var canvas = document.createElement('canvas');
                JsBarcode(canvas, serial, {
                    format: 'CODE128',
                    width: 2.0,
                    height: 48,
                    displayValue: false,
                    margin: 10,
                    background: '#ffffff',
                    lineColor: '#000000'
                });
                $(this).attr('src', canvas.toDataURL('image/png'));
            } catch(e) {
                console.error('Barcode render error:', serial, e);
            }
        }
    });

    // Clear search button
    var searchInput = $('#searchInput');
    var clearBtn = $('#clearSearch');

    function toggleClearBtn() {
        clearBtn.toggle(searchInput.val().length > 0);
    }
    searchInput.on('input', toggleClearBtn);
    toggleClearBtn();

    clearBtn.on('click', function() {
        searchInput.val('');
        toggleClearBtn();
        searchInput.focus();
        $('#filterForm').submit();
    });

    // Submit on Enter
    searchInput.on('keydown', function(e) {
        if (e.key === 'Enter') {
            $('#filterForm').submit();
        }
    });

    // Auto-focus search field for instant hardware scanner input
    searchInput.focus();

    // Automatically open the detail modal if there is exactly 1 search result (e.g. after a barcode scan)
    <% if (filterKeyword != null && !filterKeyword.trim().isEmpty() && totalCount == 1) { 
        GeneratorBarcode uniqueGb = barcodes.get(0);
        Generator genDetail = null;
        if (generators != null) {
            for (Generator gd : generators) {
                if (gd.getGeneratorId() == uniqueGb.getGeneratorId()) {
                    genDetail = gd;
                    break;
                }
            }
        }
        String safeGenName    = genDetail != null && genDetail.getGeneratorName() != null ? genDetail.getGeneratorName().replace("'", "\\'") : "-";
        String safeSerial     = uniqueGb.getSerialNumber() != null ? uniqueGb.getSerialNumber().replace("'", "\\'") : "-";
        String safeBrand      = genDetail != null && genDetail.getBrand() != null ? genDetail.getBrand().replace("'", "\\'") : "-";
        String safePower      = genDetail != null && genDetail.getPowerValue() != null ? genDetail.getPowerValue().replace("'", "\\'") : "-";
        String safeFuel       = genDetail != null && genDetail.getFuelType() != null ? genDetail.getFuelType().replace("'", "\\'") : "-";
        String safeLocation   = genDetail != null && genDetail.getLocation() != null ? genDetail.getLocation().replace("'", "\\'") : "-";
        String safeNote       = genDetail != null && genDetail.getNote() != null ? genDetail.getNote().replace("'", "\\'").replace("\n", " ") : "-";
        String priceStr       = genDetail != null && genDetail.getPurchasePrice() != null ? String.format("%,.0f", genDetail.getPurchasePrice()) : "-";
        String rentalPriceStr = genDetail != null && genDetail.getRentalPrice() != null ? String.format("%,.0f", genDetail.getRentalPrice()) : "-";
        String unitStatusBadge;
        switch (uniqueGb.getStatus() != null ? uniqueGb.getStatus() : "") {
            case "IN_STOCK":     unitStatusBadge = "badge-success"; break;
            case "EXPORTED":     unitStatusBadge = "badge-secondary"; break;
            case "TRANSFERRED":  unitStatusBadge = "badge-info"; break;
            case "UNDER_REPAIR": unitStatusBadge = "badge-danger"; break;
            case "MAINTENANCE":  unitStatusBadge = "badge-warning"; break;
            case "DAMAGED":      unitStatusBadge = "badge-dark"; break;
            default:             unitStatusBadge = "badge-light"; break;
        }
        String createdStr = uniqueGb.getCreatedAt() != null
            ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(uniqueGb.getCreatedAt()) : "-";
    %>
        openBarcodeDetail(
            '<%= safeGenName %>',
            '<%= safeSerial %>',
            '<%= safeBrand %>',
            '<%= safePower %>',
            '<%= safeFuel %>',
            '<%= priceStr %>',
            '<%= rentalPriceStr %>',
            '<%= safeLocation %>',
            '<%= safeNote %>',
            '<%= uniqueGb.getStatus() != null ? uniqueGb.getStatus() : "" %>',
            '<%= unitStatusBadge %>',
            '<%= createdStr %>'
        );
    <% } %>
});

function openBarcodeDetail(genName, serial, brand, power, fuel, price, rentalPrice, location, note, status, badgeClass, createdAt) {
    // Fill generator template info
    $('#mdGenName').text(genName || '-');
    $('#mdBrand').text(brand || '-');
    $('#mdPower').text(power || '-');
    $('#mdFuel').text(fuel || '-');
    $('#mdLocation').text(location || '-');
    $('#mdPrice').text(price !== '-' ? price + ' VNĐ' : '-');
    $('#mdRentalPrice').text(rentalPrice !== '-' ? rentalPrice + ' VNĐ/ngày' : '-');
    $('#mdNote').text(note || '-');

    // Fill physical unit info
    $('#mdSerial').text(serial || '-');
    $('#mdCreatedAt').text(createdAt || '-');

    // Status badge
    var statusLabels = {
        'IN_STOCK': 'Trong kho',
        'EXPORTED': 'Đã xuất kho',
        'TRANSFERRED': 'Đã chuyển kho',
        'UNDER_REPAIR': 'Đang sửa chữa',
        'MAINTENANCE': 'Bảo trì',
        'DAMAGED': 'Đã hỏng'
    };
    var label = statusLabels[status] || status;
    $('#mdStatusBadge').html('<span class="badge ' + badgeClass + ' px-2 py-1" style="font-size:0.85rem;">' + label + '</span>');

    // Render barcode in detail modal with high-res crisp quiet zone (larger size for scanning)
    if (serial) {
        try {
            var canvas = document.createElement('canvas');
            JsBarcode(canvas, serial, {
                format: 'CODE128',
                width: 2.2,
                height: 70,
                displayValue: false,
                margin: 12,
                background: '#ffffff',
                lineColor: '#000000'
            });
            $('#mdBarcodeImg').attr('src', canvas.toDataURL('image/png')).show();
            $('#mdBarcodeLabel').text(serial);
        } catch(e) {
            $('#mdBarcodeImg').hide();
            $('#mdBarcodeLabel').text(serial);
        }
    } else {
        $('#mdBarcodeImg').hide();
        $('#mdBarcodeLabel').text('');
    }

    $('#barcodeDetailModal').modal('show');
}
</script>
</body>
</html>