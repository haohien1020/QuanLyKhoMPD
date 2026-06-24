<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu điều chuyển kho | Generator Management System</title>
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
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">Tạo yêu cầu điều chuyển kho mới</h1>
                    <a href="${pageContext.request.contextPath}/stock-transfers" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> Quay lại</a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Thông tin phiếu chuyển kho</h6>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/stock-transfers/create">
                            <div class="row">
                                <div class="col-md-6 form-group">
                                    <label class="font-weight-bold">Kho gửi hàng (Kho của bạn):</label>
                                    <input type="text" class="form-control" value="${managedWarehouse.warehouseName}" disabled>
                                </div>
                                <div class="col-md-6 form-group">
                                    <label for="toWarehouseId" class="font-weight-bold">Chọn kho nhận hàng (Kho đích):</label>
                                    <select name="toWarehouseId" id="toWarehouseId" class="form-control" required>
                                        <option value="">-- Chọn kho đích --</option>
                                        <c:forEach var="w" items="${destWarehouses}">
                                            <option value="${w.warehouseId}">${w.warehouseName} (Địa chỉ: ${w.address})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group mt-3">
                                <label class="font-weight-bold d-block">Loại hàng hóa điều chuyển:</label>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="itemType" id="typeGenerator" value="GENERATOR" checked onchange="toggleItemType()">
                                    <label class="form-check-label" for="typeGenerator">Máy phát điện</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="itemType" id="typePart" value="PART" onchange="toggleItemType()">
                                    <label class="form-check-label" for="typePart">Linh kiện / Phụ tùng</label>
                                </div>
                            </div>

                            <hr>

                            <!-- Generator selection section -->
                            <div id="generatorSection" class="mt-4">
                                <h5 class="font-weight-bold text-gray-800 mb-3">Chọn máy phát điện cần chuyển:</h5>
                                <div class="form-group">
                                    <c:forEach var="gen" items="${generators}">
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="generatorId" value="${gen.generatorId}" id="gen-${gen.generatorId}">
                                            <label class="form-check-label" for="gen-${gen.generatorId}">
                                                <strong>${gen.generatorName}</strong> (Serial: ${gen.serialNumber}) - Hãng: ${gen.brand} - Vị trí: ${gen.location}
                                            </label>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty generators}">
                                        <p class="text-muted">Không có máy phát điện khả dụng (`IN_STOCK`) để điều chuyển.</p>
                                    </c:if>
                                </div>
                            </div>

                            <!-- Part selection section -->
                            <div id="partSection" class="mt-4 d-none">
                                <h5 class="font-weight-bold text-gray-800 mb-3">Chọn phụ tùng và số lượng cần chuyển:</h5>
                                <table class="table table-bordered" id="partsTable">
                                    <thead>
                                        <tr>
                                            <th>Chọn phụ tùng</th>
                                            <th style="width: 150px;">Số lượng chuyển</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="part" items="${parts}">
                                            <tr>
                                                <td>
                                                    <div class="form-check">
                                                        <input class="form-check-input part-checkbox" type="checkbox" name="partId" value="${part.partId}" id="part-${part.partId}" onchange="togglePartQty(this)">
                                                        <label class="form-check-label" for="part-${part.partId}">
                                                            <strong>${part.partName}</strong> (Mã: ${part.partCode}) - Tồn: ${part.quantity} ${part.unit}
                                                        </label>
                                                    </div>
                                                </td>
                                                <td>
                                                    <input type="number" name="quantity" class="form-control part-qty-input" value="1" min="1" max="${part.quantity}" disabled required>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty parts}">
                                            <tr>
                                                <td colspan="2" class="text-center text-muted">Không có phụ tùng nào khả dụng trong kho của bạn.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>

                            <div class="text-right mt-4">
                                <button type="submit" class="btn btn-success btn-lg"><i class="fas fa-paper-plane"></i> Gửi yêu cầu điều chuyển</button>
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
    function toggleItemType() {
        var isGen = document.getElementById("typeGenerator").checked;
        if (isGen) {
            document.getElementById("generatorSection").classList.remove("d-none");
            document.getElementById("partSection").classList.add("d-none");
        } else {
            document.getElementById("generatorSection").classList.add("d-none");
            document.getElementById("partSection").classList.remove("d-none");
        }
    }

    function togglePartQty(checkbox) {
        var row = checkbox.closest('tr');
        var qtyInput = row.querySelector('.part-qty-input');
        if (checkbox.checked) {
            qtyInput.disabled = false;
        } else {
            qtyInput.disabled = true;
        }
    }
</script>
</body>
</html>
