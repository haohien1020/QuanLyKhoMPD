<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Báo cáo tồn kho chi tiết theo kho | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
    <style>
        .stat-card {
            border-left: 4px solid #4e73df;
            transition: all 0.2s ease-in-out;
        }
        .stat-card:hover {
            transform: translateY(-2px);
        }
        .nav-pills .nav-link {
            border-radius: 8px;
            font-weight: 600;
            color: #6e707e;
            padding: 0.6rem 1.2rem;
            transition: all 0.2s;
        }
        .nav-pills .nav-link.active {
            background-color: #4e73df;
            color: #fff;
            box-shadow: 0 4px 6px rgba(78, 115, 223, 0.2);
        }
        .nav-pills .nav-link:hover:not(.active) {
            background-color: #eaecf4;
            color: #2e59d9;
        }
        .chart-container {
            position: relative;
            margin: auto;
            height: 250px;
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

                <!-- Page Header with Warehouse Filter -->
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-900 font-weight-bold">
                        <i class="fas fa-chart-line text-primary mr-2"></i>Báo cáo tồn kho theo từng kho
                    </h1>
                    <form method="get" action="${pageContext.request.contextPath}/reports" class="form-inline mt-2 mt-sm-0 bg-white p-2 rounded shadow-sm border">
                        <input type="hidden" name="type" value="inventory">
                        <label for="warehouseFilter" class="mr-2 font-weight-bold text-gray-700 small"><i class="fas fa-warehouse text-info mr-1"></i>Trực quan theo kho:</label>
                        <select id="warehouseFilter" name="warehouseId" class="form-control form-control-sm font-weight-bold text-gray-800" onchange="this.form.submit()">
                            <option value="ALL">-- Tất cả các kho hàng --</option>
                            <c:forEach var="wh" items="${supervisedWarehouses}">
                                <option value="${wh.warehouseId}" ${selectedWarehouseId == wh.warehouseId ? 'selected' : ''}>
                                    ${wh.warehouseName} (${wh.address})
                                </option>
                            </c:forEach>
                        </select>
                    </form>
                </div>

                <!-- Toast Alerts / Errors -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fas fa-exclamation-triangle mr-2"></i> ${error}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                <c:if test="${param.success eq 'min_stock_updated'}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fas fa-check-circle mr-2"></i> Cập nhật mức độ tồn kho tối thiểu cho mẫu máy phát điện thành công!
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>

                <!-- Summary Row -->
                <div class="row mb-4">
                    <!-- Total Generators -->
                    <div class="col-xl-6 col-md-6 mb-4">
                        <div class="card stat-card border-left-primary shadow-sm h-100 py-2 bg-white">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Tổng máy phát điện</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">${totalGenerators} máy</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-charging-station fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Total Parts -->
                    <div class="col-xl-6 col-md-6 mb-4">
                        <div class="card stat-card border-left-success shadow-sm h-100 py-2 bg-white">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Tổng phụ tùng tồn kho</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">${totalPartsQty} phụ tùng</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-tools fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Visual Charts Section -->
                <div class="row mb-4">
                    <!-- Generator Status Breakdown Chart -->
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow-sm h-100 bg-white">
                            <div class="card-header py-3 bg-white border-bottom-0">
                                <h6 class="m-0 font-weight-bold text-primary">
                                    <i class="fas fa-chart-pie mr-1"></i>Tình trạng máy phát điện
                                </h6>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${totalGenerators eq 0}">
                                        <p class="text-center text-muted font-italic py-5">Không có dữ liệu máy phát điện tại kho này để vẽ biểu đồ.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="chart-container">
                                            <canvas id="genStatusChart"></canvas>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Top Parts Quantity Chart -->
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow-sm h-100 bg-white">
                            <div class="card-header py-3 bg-white border-bottom-0">
                                <h6 class="m-0 font-weight-bold text-primary">
                                    <i class="fas fa-chart-bar mr-1"></i>Số lượng phụ tùng thực tế
                                </h6>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty partsData}">
                                        <p class="text-center text-muted font-italic py-5">Không có dữ liệu phụ tùng tại kho này để vẽ biểu đồ.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="chart-container">
                                            <canvas id="partsQtyChart"></canvas>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Detailed Tables Section -->
                <div class="row">
                    <div class="col-12">
                        <!-- Navigation Tabs -->
                        <ul class="nav nav-pills mb-4 p-2 bg-white rounded shadow-sm border" id="inventoryTabs" role="tablist">
                            <li class="nav-item mr-2">
                                <a class="nav-link active" id="gen-tab" data-toggle="pill" href="#gen-pane" role="tab" aria-controls="gen-pane" aria-selected="true">
                                    <i class="fas fa-charging-station mr-2"></i>Báo cáo Máy phát điện
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="parts-tab" data-toggle="pill" href="#parts-pane" role="tab" aria-controls="parts-pane" aria-selected="false">
                                    <i class="fas fa-tools mr-2"></i>Báo cáo Phụ tùng
                                </a>
                            </li>
                        </ul>

                        <!-- Tab Content -->
                        <div class="tab-content" id="inventoryTabContent">
                            
                            <!-- TAB 1: GENERATORS REPORT -->
                            <div class="tab-pane fade show active" id="gen-pane" role="tabpanel" aria-labelledby="gen-tab">
                                <div class="card shadow-sm border-0 bg-white">
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-bordered table-hover mb-0">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th>Tên mẫu máy phát</th>
                                                        <th>Thương hiệu</th>
                                                        <th>Công suất</th>
                                                        <th class="text-right">Giá thuê / ngày</th>
                                                        <th class="text-center">Sẵn sàng (Trong kho)</th>
                                                        <th class="text-center">Tồn tối thiểu</th>
                                                        <th class="text-center">Tổng số lượng</th>
                                                        <th class="text-center" style="width: 120px;">Hành động</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty genSpecsData}">
                                                            <tr>
                                                                <td colspan="8" class="text-center text-muted font-italic">Không tìm thấy dữ liệu máy phát điện nào</td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="gs" items="${genSpecsData}">
                                                                <tr class="${gs.availQty < gs.minStock ? 'table-danger' : ''}">
                                                                    <td>
                                                                        <strong class="text-gray-900">${gs.generatorName}</strong>
                                                                        <c:choose>
                                                                            <c:when test="${gs.availQty < gs.minStock}">
                                                                                <span class="badge badge-danger ml-2"><i class="fas fa-exclamation-triangle mr-1"></i>Dưới mức tối thiểu</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge badge-success ml-2"><i class="fas fa-check-circle mr-1"></i>An toàn</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>${gs.brand}</td>
                                                                    <td><span class="badge badge-info">${gs.powerValue}</span></td>
                                                                    <td class="text-right font-weight-bold text-gray-900">
                                                                        <fmt:formatNumber value="${gs.rentalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                                    </td>
                                                                    <td class="text-center font-weight-bold ${gs.availQty > 0 ? 'text-success' : 'text-danger'}">
                                                                        ${gs.availQty}
                                                                    </td>
                                                                    <td class="text-center font-weight-bold text-gray-900">${gs.minStock}</td>
                                                                    <td class="text-center font-weight-bold text-gray-900">${gs.totalQty}</td>
                                                                    <td class="text-center">
                                                                        <c:if test="${sessionScope.currentUser.hasRole('MANAGER')}">
                                                                            <button type="button" class="btn btn-sm btn-primary shadow-sm"
                                                                                    onclick="openEditMinStockModal('${gs.generatorName.replace("'", "\\'")}', '${gs.brand.replace("'", "\\'")}', '${gs.powerValue.replace("'", "\\'")}', ${gs.minStock})"
                                                                                    title="Thiết lập định mức tối thiểu">
                                                                                <i class="fas fa-cog"></i> Cấu hình
                                                                            </button>
                                                                        </c:if>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 2: PARTS REPORT -->
                            <div class="tab-pane fade" id="parts-pane" role="tabpanel" aria-labelledby="parts-tab">
                                <div class="card shadow-sm border-0 bg-white">
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-bordered table-hover mb-0">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th>Tên phụ tùng</th>
                                                        <th>Mã phụ tùng</th>
                                                        <th class="text-center">Số lượng tồn</th>
                                                        <th class="text-center">Mức tối thiểu</th>
                                                        <th>Đơn vị tính</th>
                                                        <th>Trạng thái</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty partsData}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted font-italic">Không tìm thấy dữ liệu phụ tùng nào</td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="p" items="${partsData}">
                                                                <tr class="${p.quantity < p.minQuantity ? 'table-danger' : ''}">
                                                                    <td>
                                                                        <strong class="text-gray-900">${p.partName}</strong>
                                                                        <c:choose>
                                                                            <c:when test="${p.quantity < p.minQuantity}">
                                                                                <span class="badge badge-danger ml-2"><i class="fas fa-arrow-down mr-1"></i>Thiếu hụt</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge badge-success ml-2"><i class="fas fa-check mr-1"></i>Đủ định mức</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td><code>${p.partCode}</code></td>
                                                                    <td class="text-center font-weight-bold text-gray-900">${p.quantity}</td>
                                                                    <td class="text-center">${p.minQuantity}</td>
                                                                    <td>${p.unit}</td>
                                                                    <td>
                                                                        <span class="badge ${p.status eq 'ACTIVE' ? 'badge-success' : 'badge-secondary'}">
                                                                            ${p.status eq 'ACTIVE' ? 'Hoạt động' : 'Bảo trì'}
                                                                        </span>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
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

<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>

<!-- Scripts -->
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>

<!-- Charts Initialization -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // --- 1. Generator Status Chart ---
        var genLabels = [];
        var genData = [];
        var genColors = [];

        var statusColors = {
            'IN_STOCK': '#1cc88a', // green
            'EXPORTED': '#36b9cc', // cyan
            'TRANSFERRED': '#4e73df', // blue
            'DAMAGED': '#e74a3b', // red
            'MAINTENANCE': '#f6c23e', // yellow
            'REPAIR': '#858796' // gray
        };

        var statusLabelsVi = {
            'IN_STOCK': 'Sẵn sàng trong kho',
            'EXPORTED': 'Đang cho thuê',
            'TRANSFERRED': 'Đang điều chuyển',
            'DAMAGED': 'Đã hỏng',
            'MAINTENANCE': 'Đang bảo dưỡng',
            'REPAIR': 'Đang sửa chữa'
        };

        <c:forEach var="gs" items="${genStatusData}">
            var stat = '${gs.status}';
            genLabels.push(statusLabelsVi[stat] || stat);
            genData.push(${gs.count});
            genColors.push(statusColors[stat] || '#858796');
        </c:forEach>

        if (genData.length > 0) {
            new Chart(document.getElementById('genStatusChart'), {
                type: 'doughnut',
                data: {
                    labels: genLabels,
                    datasets: [{
                        data: genData,
                        backgroundColor: genColors,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: {
                                boxWidth: 12,
                                font: {
                                    size: 11
                                }
                            }
                        }
                    }
                }
            });
        }

        // --- 2. Parts Quantity Chart ---
        var partLabels = [];
        var partQtyData = [];
        var partMinData = [];

        <c:forEach var="p" items="${partsData}" varStatus="loop">
            <c:if test="${loop.index < 7}"> // Show top 7 parts only for readability
                partLabels.push('${p.partName}');
                partQtyData.push(${p.quantity});
                partMinData.push(${p.minQuantity});
            </c:if>
        </c:forEach>

        if (partQtyData.length > 0) {
            new Chart(document.getElementById('partsQtyChart'), {
                type: 'bar',
                data: {
                    labels: partLabels,
                    datasets: [
                        {
                            label: 'Tồn thực tế',
                            data: partQtyData,
                            backgroundColor: '#4e73df'
                        },
                        {
                            label: 'Mức tối thiểu',
                            data: partMinData,
                            backgroundColor: '#e74a3b'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }
    });

    function openEditMinStockModal(generatorName, brand, powerValue, currentMin) {
        document.getElementById('min_genName').value = generatorName;
        document.getElementById('min_brand').value = brand;
        document.getElementById('min_powerValue').value = powerValue;
        
        document.getElementById('min_display_genName').value = generatorName;
        document.getElementById('min_display_specs').value = brand + " - " + powerValue;
        document.getElementById('form_minStock').value = currentMin;
        
        $('#editMinStockModal').modal('show');
    }
</script>

<!-- Modal cấu hình định mức tối thiểu Máy phát điện -->
<div class="modal fade" id="editMinStockModal" tabindex="-1" role="dialog" aria-labelledby="editMinStockModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content shadow border-left-primary">
            <form method="post" action="${pageContext.request.contextPath}/reports">
                <input type="hidden" name="action" value="update-min-stock">
                <input type="hidden" id="min_genName" name="generatorName">
                <input type="hidden" id="min_brand" name="brand">
                <input type="hidden" id="min_powerValue" name="powerValue">
                
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title font-weight-bold" id="editMinStockModalLabel">
                        <i class="fas fa-cog mr-1"></i> Cấu hình tồn tối thiểu máy phát
                    </h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label class="font-weight-bold text-gray-800">Tên mẫu máy phát:</label>
                        <input type="text" id="min_display_genName" class="form-control bg-light" readonly>
                    </div>
                    <div class="form-group">
                        <label class="font-weight-bold text-gray-800">Thương hiệu & Công suất:</label>
                        <input type="text" id="min_display_specs" class="form-control bg-light" readonly>
                    </div>
                    <div class="form-group">
                        <label for="form_minStock" class="font-weight-bold text-gray-800">Mức tồn tối thiểu cảnh báo <span class="text-danger">*</span></label>
                        <input type="number" id="form_minStock" name="minStock" class="form-control" required min="0" max="9999" placeholder="Ví dụ: 4">
                        <small class="form-text text-muted">Khi số lượng máy phát điện sẵn sàng cho thuê (Trong kho) dưới mức này, hệ thống sẽ tự động hiển thị cảnh báo thiếu hàng cho mẫu máy này.</small>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary font-weight-bold">
                        <i class="fas fa-save mr-1"></i> Lưu cấu hình
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

</body>
</html>
