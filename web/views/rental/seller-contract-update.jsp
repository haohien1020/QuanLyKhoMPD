<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chỉnh sửa hợp đồng thuê | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
</head>
<body id="page-top">
<div id="wrapper">
    <%@ include file="/views/layout/sidebar.jsp" %>
    <div id="content-wrapper" class="d-flex flex-column">
        <div id="content">
            <%@ include file="/views/layout/topbar.jsp" %>
            <div class="container-fluid">
                <!-- Page Heading -->
                <div class="mb-4">
                    <h1 class="h3 mb-0 text-gray-800"><i class="fas fa-file-contract text-primary"></i> Chỉnh sửa Hợp đồng Thuê</h1>
                </div>

                <div class="card shadow mb-4 col-lg-8 p-0">
                    <div class="card-header py-3 bg-info text-white">
                        <h6 class="m-0 font-weight-bold">Hợp đồng: ${contract.contractCode} (Trạng thái: ${contract.status})</h6>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/seller/contracts/update" id="contractForm">
                            <input type="hidden" name="contractId" value="${contract.rentalContractId}">

                            <div class="form-group row">
                                <div class="col-sm-6">
                                    <label class="font-weight-bold">Khách hàng <span class="text-danger">*</span></label>
                                    <select name="customerId" class="form-control" required>
                                        <option value="">-- Chọn khách hàng --</option>
                                        <c:forEach var="c" items="${customers}">
                                            <option value="${c.customerId}" ${c.customerId == contract.customerId ? 'selected' : ''}>${c.customerName} (${c.phone})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-sm-6">
                                    <label class="font-weight-bold">Kho chi nhánh <span class="text-danger">*</span></label>
                                    <select name="warehouseId" class="form-control" required>
                                        <option value="">-- Chọn kho --</option>
                                        <c:forEach var="w" items="${warehouses}">
                                            <option value="${w.warehouseId}" ${w.warehouseId == contract.warehouseId ? 'selected' : ''}>${w.warehouseName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group row">
                                <div class="col-md-6">
                                    <label class="font-weight-bold">Mẫu máy phát (Thông số & Tồn kho) <span class="text-danger">*</span></label>
                                    <c:forEach var="g" items="${generators}">
                                        <c:if test="${g.generatorId == currentGenId}">
                                            <c:set var="curBrand" value="${g.brand}" />
                                            <c:set var="curName" value="${g.generatorName}" />
                                            <c:set var="curPower" value="${g.powerValue}" />
                                            <c:set var="curFuel" value="${g.fuelType}" />
                                        </c:if>
                                    </c:forEach>
                                    <select class="form-control" id="generatorGroupSelect" required>
                                        <option value="">-- Chọn mẫu máy --</option>
                                        <c:forEach var="group" items="${groupedInventories}">
                                            <c:set var="isSel" value="${group.brand == curBrand && group.generatorName == curName && group.powerValue == curPower && group.fuelType == curFuel}" />
                                            <c:if test="${group.inStockCount > 0 || isSel}">
                                                <option value="${group.brand}::${group.generatorName}::${group.powerValue}::${group.fuelType}" ${isSel ? 'selected' : ''}>
                                                    ${group.brand} ${group.generatorName} | ${group.powerValue} kVA | ${group.fuelType} (Sẵn có: ${group.inStockCount} | Đang thuê: ${group.rentedCount})
                                                </option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="font-weight-bold">Số Serial khả dụng <span class="text-danger">*</span></label>
                                    <select name="generatorId" class="form-control" id="generatorId" required>
                                        <option value="">-- Chọn số Serial --</option>
                                    </select>
                                    <div id="locationInfo" class="small text-muted mt-1 font-italic" style="display:none;">
                                        <i class="fas fa-map-marker-alt"></i> Vị trí chi tiết: <span id="locationSpan" class="font-weight-bold text-dark"></span>
                                    </div>
                                </div>
                            </div>

                            <fmt:formatDate value="${contract.startDate}" pattern="yyyy-MM-dd" var="formattedStartDate" />
                            <fmt:formatDate value="${contract.expectedReturnDate}" pattern="yyyy-MM-dd" var="formattedExpectedReturnDate" />

                            <div class="form-group row">
                                <div class="col-sm-6">
                                    <label class="font-weight-bold">Ngày bắt đầu <span class="text-danger">*</span></label>
                                    <input type="date" name="startDate" id="startDate" value="${formattedStartDate}" class="form-control" required>
                                </div>
                                <div class="col-sm-6">
                                    <label class="font-weight-bold">Ngày trả dự kiến <span class="text-danger">*</span></label>
                                    <input type="date" name="expectedReturnDate" id="expectedReturnDate" value="${formattedExpectedReturnDate}" class="form-control" required>
                                </div>
                            </div>

                            <div class="form-group row">
                                <div class="col-sm-4">
                                    <label class="font-weight-bold">Đơn giá thuê (VND) <span class="text-danger">*</span></label>
                                    <input type="number" step="1000" name="rentalPrice" id="rentalPrice" value="${rentalPrice}" class="form-control" required>
                                </div>
                                <div class="col-sm-4">
                                    <label class="font-weight-bold">Tiền đặt cọc (VND)</label>
                                    <input type="number" step="1000" name="depositAmount" id="depositAmount" value="${contract.depositAmount}" class="form-control">
                                </div>
                                <div class="col-sm-4">
                                    <label class="font-weight-bold">Tổng thanh toán (VND)</label>
                                    <input type="number" step="1000" name="totalAmount" id="totalAmount" value="${contract.totalAmount}" class="form-control">
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="font-weight-bold">Ghi chú</label>
                                <textarea name="note" class="form-control" rows="3">${contract.note}</textarea>
                            </div>

                            <div class="mt-4">
                                <button type="submit" class="btn btn-info"><i class="fas fa-save"></i> Cập nhật hợp đồng</button>
                                <a href="${pageContext.request.contextPath}/seller/contracts" class="btn btn-secondary"><i class="fas fa-times"></i> Hủy bỏ</a>
                            </div>
                        </form>
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
<script>
    // Preloaded available generators
    var allGenerators = [
        <c:forEach var="g" items="${generators}" varStatus="loop">
            {
                generatorId: "${g.generatorId}",
                generatorName: "<c:out value="${g.generatorName}" />",
                brand: "<c:out value="${g.brand}" />",
                powerValue: "<c:out value="${g.powerValue}" />",
                fuelType: "<c:out value="${g.fuelType}" />",
                serialNumber: "<c:out value="${g.serialNumber}" />",
                location: "<c:out value="${g.location}" />",
                status: "${g.status}",
                rentalPrice: "${g.rentalPrice}"
            }${not loop.last ? ',' : ''}
        </c:forEach>
    ];
    
    var currentGenId = "${currentGenId}";

    $(document).ready(function() {
        // Cascading logic for generator selection
        function filterSerial() {
            var groupKey = $('#generatorGroupSelect').val();
            var $serialSelect = $('#generatorId');
            var $locInfo = $('#locationInfo');
            
            $serialSelect.empty();
            $locInfo.hide();
            
            if (!groupKey) {
                $serialSelect.append('<option value="">-- Chọn mẫu máy trước --</option>').prop('disabled', true);
                return;
            }
            
            var parts = groupKey.split('::');
            var brand = parts[0];
            var name = parts[1];
            var power = parts[2];
            var fuel = parts[3];
            
            var filtered = allGenerators.filter(function(g) {
                return g.brand === brand && g.generatorName === name && g.powerValue === power && g.fuelType === fuel && (g.status === 'IN_STOCK' || g.generatorId === currentGenId);
            });
            
            if (filtered.length === 0) {
                $serialSelect.append('<option value="">-- Không có máy sẵn có --</option>').prop('disabled', true);
            } else {
                $serialSelect.append('<option value="">-- Chọn số Serial --</option>');
                filtered.forEach(function(g) {
                    var isSelected = (g.generatorId === currentGenId) ? 'selected' : '';
                    $serialSelect.append('<option value="' + g.generatorId + '" data-location="' + g.location + '" ' + isSelected + '>' + g.serialNumber + (g.generatorId === currentGenId ? ' (Máy hiện tại)' : '') + '</option>');
                });
                $serialSelect.prop('disabled', false);
                $serialSelect.trigger('change');
            }
        }

        $('#generatorGroupSelect').on('change', function() {
            filterSerial();
            
            // Auto update rental price of this model
            var groupKey = $(this).val();
            if (groupKey) {
                var parts = groupKey.split('::');
                var brand = parts[0];
                var name = parts[1];
                var power = parts[2];
                var fuel = parts[3];
                var filtered = allGenerators.filter(function(g) {
                    return g.brand === brand && g.generatorName === name && g.powerValue === power && g.fuelType === fuel;
                });
                if (filtered.length > 0) {
                    var modelPrice = filtered[0].rentalPrice || 0;
                    $('#rentalPrice').val(modelPrice).trigger('change');
                }
            }
        });
        
        $('#generatorId').on('change', function() {
            var selectedOption = $(this).find('option:selected');
            var location = selectedOption.data('location');
            var $locInfo = $('#locationInfo');
            var $locSpan = $('#locationSpan');
            
            if (location) {
                $locSpan.text(location);
                $locInfo.show();
            } else {
                $locInfo.hide();
            }
        });

        // Initialize serial dropdown
        filterSerial();
    });

    // Auto-calculate totalAmount = (rentalPrice * days) - depositAmount
    function calcTotal() {
        var start = document.getElementById('startDate').value;
        var end = document.getElementById('expectedReturnDate').value;
        var price = parseFloat(document.getElementById('rentalPrice').value) || 0;
        var deposit = parseFloat(document.getElementById('depositAmount').value) || 0;
        if (start && end && price > 0) {
            var days = Math.max(1, Math.ceil((new Date(end) - new Date(start)) / (1000 * 60 * 60 * 24)));
            var total = (price * days) - deposit;
            document.getElementById('totalAmount').value = Math.max(0, total);
        }
    }
    
    ['startDate', 'expectedReturnDate', 'rentalPrice', 'depositAmount'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.addEventListener('change', calcTotal);
    });
    
    // Validate return date >= start date
    if (document.getElementById('startDate')) {
        document.getElementById('startDate').addEventListener('change', function() {
            var retDate = document.getElementById('expectedReturnDate');
            if (retDate) retDate.setAttribute('min', this.value);
        });
        // Init min return date on load
        var startVal = document.getElementById('startDate').value;
        if (startVal) {
            var retDate = document.getElementById('expectedReturnDate');
            if (retDate) retDate.setAttribute('min', startVal);
        }
    }

    // Strict Date Validation on submit
    $('#contractForm').on('submit', function(e) {
        var startVal = document.getElementById('startDate').value;
        var endVal = document.getElementById('expectedReturnDate').value;
        if (startVal && endVal) {
            var start = new Date(startVal);
            var end = new Date(endVal);
            if (end < start) {
                e.preventDefault();
                alert('Ngày trả dự kiến không được nhỏ hơn ngày bắt đầu thuê!');
                return false;
            }
        }
    });
</script>
</body>
</html>
