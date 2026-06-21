<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lập hợp đồng thuê mới | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .form-card { border-radius: 10px; overflow: hidden; }
        .form-card .card-header { background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%); }
        .warehouse-info-box {
            background: #eef4ff;
            border: 1px solid #c7d8f8;
            border-radius: 8px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .warehouse-info-box .wh-icon {
            background: #2563eb;
            color: #fff;
            border-radius: 8px;
            width: 40px; height: 40px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .no-warehouse-warning {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            border-radius: 8px;
            padding: 16px 20px;
        }
        .no-generators-warning {
            background: #f8d7da;
            border-left: 4px solid #dc3545;
            border-radius: 8px;
            padding: 14px 18px;
        }
        .generator-option-label {
            font-size: 0.75rem;
            color: #858796;
            margin-bottom: 4px;
        }
        .btn-submit-contract {
            padding: 10px 28px;
            font-weight: 600;
            border-radius: 8px;
            font-size: 1rem;
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

                <%-- Page Heading --%>
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">
                        <i class="fas fa-file-contract text-primary"></i> Lập Hợp đồng Thuê mới
                    </h1>
                    <a href="${pageContext.request.contextPath}/seller/contracts" class="btn btn-sm btn-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>

                <%-- Error alerts --%>
                <c:if test="${param.error == 'invalid_warehouse'}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle"></i> Kho không hợp lệ! Bạn chỉ được phép tạo hợp đồng cho kho của mình.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'create_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle"></i> Có lỗi khi tạo hợp đồng. Vui lòng thử lại.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>

                <%-- No warehouse warning --%>
                <c:if test="${empty warehouses}">
                    <div class="no-warehouse-warning mb-4">
                        <strong><i class="fas fa-exclamation-triangle text-warning"></i> Bạn chưa được gán kho!</strong>
                        <p class="mb-0 mt-1 text-muted small">Không thể lập hợp đồng vì tài khoản của bạn chưa được liên kết với kho nào. Vui lòng liên hệ Warehouse Manager để được gán kho.</p>
                    </div>
                </c:if>

                <c:if test="${not empty warehouses}">
                    <div class="card form-card shadow mb-4 col-lg-9 p-0">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-white">
                                <i class="fas fa-edit mr-1"></i> Thông tin hợp đồng thuê
                            </h6>
                        </div>
                        <div class="card-body">
                            <form method="post" action="${pageContext.request.contextPath}/seller/contracts/create" id="contractForm">

                                <%-- Customer + Warehouse row --%>
                                <div class="form-group row">
                                    <div class="col-sm-6">
                                        <label class="font-weight-bold">Khách hàng <span class="text-danger">*</span></label>
                                        <select name="customerId" class="form-control" id="customerId" required>
                                            <option value="">-- Chọn khách hàng --</option>
                                            <c:forEach var="c" items="${customers}">
                                                <option value="${c.customerId}">${c.customerName} (${c.phone})</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="font-weight-bold">Kho chi nhánh</label>
                                        <%-- Show warehouse as read-only info box, not dropdown --%>
                                        <c:forEach var="w" items="${warehouses}" varStatus="loop">
                                            <input type="hidden" name="warehouseId" value="${w.warehouseId}">
                                            <div class="warehouse-info-box mt-1">
                                                <div class="wh-icon"><i class="fas fa-warehouse"></i></div>
                                                <div>
                                                    <div class="font-weight-bold text-gray-800">${w.warehouseName}</div>
                                                    <div class="small text-muted">Kho được gán cho tài khoản của bạn</div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>

                                 <%-- Generator selection --%>
                                <div class="form-group row">
                                    <div class="col-md-6">
                                        <label class="font-weight-bold">Mẫu máy phát (Thông số & Tồn kho) <span class="text-danger">*</span></label>
                                        <c:set var="hasAvailableModels" value="false" />
                                        <c:forEach var="group" items="${groupedInventories}">
                                            <c:if test="${group.inStockCount > 0}">
                                                <c:set var="hasAvailableModels" value="true" />
                                            </c:if>
                                        </c:forEach>
                                        <c:choose>
                                            <c:when test="${empty groupedInventories or not hasAvailableModels}">
                                                <div class="no-generators-warning mt-1">
                                                    <strong><i class="fas fa-times-circle text-danger"></i> Không có máy phát điện sẵn sàng!</strong>
                                                    <p class="mb-0 mt-1 small">Hiện tại kho không có máy phát điện nào với trạng thái IN_STOCK.</p>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <select class="form-control" id="generatorGroupSelect" required>
                                                    <option value="">-- Chọn mẫu máy --</option>
                                                    <c:forEach var="group" items="${groupedInventories}">
                                                        <c:if test="${group.inStockCount > 0}">
                                                            <option value="${group.brand}::${group.generatorName}::${group.powerValue}::${group.fuelType}">
                                                                ${group.brand} ${group.generatorName} | ${group.powerValue} kVA | ${group.fuelType} (Sẵn có: ${group.inStockCount} | Đang thuê: ${group.rentedCount})
                                                            </option>
                                                        </c:if>
                                                    </c:forEach>
                                                </select>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="font-weight-bold">Số Serial khả dụng <span class="text-danger">*</span></label>
                                        <select name="generatorId" class="form-control" id="generatorId" required disabled>
                                            <option value="">-- Chọn mẫu máy trước --</option>
                                        </select>
                                        <div id="locationInfo" class="small text-muted mt-1 font-italic" style="display:none;">
                                            <i class="fas fa-map-marker-alt"></i> Vị trí chi tiết: <span id="locationSpan" class="font-weight-bold text-dark"></span>
                                        </div>
                                    </div>
                                </div>

                                <%-- Dates --%>
                                <div class="form-group row">
                                    <div class="col-sm-6">
                                        <label class="font-weight-bold">Ngày bắt đầu <span class="text-danger">*</span></label>
                                        <input type="date" name="startDate" id="startDate" class="form-control" required>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="font-weight-bold">Ngày trả dự kiến <span class="text-danger">*</span></label>
                                        <input type="date" name="expectedReturnDate" id="expectedReturnDate" class="form-control" required>
                                    </div>
                                </div>

                                <%-- Pricing --%>
                                <div class="form-group row">
                                    <div class="col-sm-4">
                                        <label class="font-weight-bold">Đơn giá thuê (VND/ngày) <span class="text-danger">*</span></label>
                                        <input type="number" step="1000" min="0" name="rentalPrice" id="rentalPrice" class="form-control" placeholder="0" required>
                                    </div>
                                    <div class="col-sm-4">
                                        <label class="font-weight-bold">Tiền đặt cọc (VND)</label>
                                        <input type="number" step="1000" min="0" name="depositAmount" id="depositAmount" class="form-control" placeholder="0">
                                    </div>
                                    <div class="col-sm-4">
                                        <label class="font-weight-bold">Tổng thanh toán (VND)</label>
                                        <input type="number" step="1000" min="0" name="totalAmount" id="totalAmount" class="form-control" placeholder="Tự tính hoặc nhập tay">
                                    </div>
                                </div>

                                <%-- Note --%>
                                <div class="form-group">
                                    <label class="font-weight-bold">Ghi chú</label>
                                    <textarea name="note" class="form-control" rows="3" placeholder="Nhập ghi chú hợp đồng..."></textarea>
                                </div>

                                <hr>
                                <div class="d-flex gap-2 mt-3">
                                    <c:choose>
                                        <c:when test="${empty generators}">
                                            <button type="submit" class="btn btn-primary btn-submit-contract" disabled>
                                                <i class="fas fa-save"></i> Lập hợp đồng
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="submit" class="btn btn-primary btn-submit-contract" id="submitBtn">
                                                <i class="fas fa-save"></i> Lập hợp đồng
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <a href="${pageContext.request.contextPath}/seller/contracts" class="btn btn-secondary btn-submit-contract" style="font-weight:600">
                                        <i class="fas fa-times"></i> Hủy bỏ
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:if>

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

    $(document).ready(function() {
        // Cascading logic for generator selection
        $('#generatorGroupSelect').on('change', function() {
            var groupKey = $(this).val();
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
                return g.brand === brand && g.generatorName === name && g.powerValue === power && g.fuelType === fuel && g.status === 'IN_STOCK';
            });
            
            if (filtered.length === 0) {
                $serialSelect.append('<option value="">-- Không có máy sẵn có --</option>').prop('disabled', true);
            } else {
                $serialSelect.append('<option value="">-- Chọn số Serial --</option>');
                filtered.forEach(function(g) {
                    $serialSelect.append('<option value="' + g.generatorId + '" data-location="' + g.location + '">' + g.serialNumber + '</option>');
                });
                $serialSelect.prop('disabled', false);

                // Auto load rental price of this model
                var modelPrice = filtered[0].rentalPrice || 0;
                $('#rentalPrice').val(modelPrice).trigger('change');
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

    // Set min date for startDate to today (Local Timezone safe)
    var tzoffset = (new Date()).getTimezoneOffset() * 60000;
    var localISOTime = (new Date(Date.now() - tzoffset)).toISOString().slice(0, 10);
    if (document.getElementById('startDate')) {
        document.getElementById('startDate').setAttribute('min', localISOTime);
    }
    
    // Validate return date >= start date
    if (document.getElementById('startDate')) {
        document.getElementById('startDate').addEventListener('change', function() {
            var retDate = document.getElementById('expectedReturnDate');
            if (retDate) retDate.setAttribute('min', this.value);
        });
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
