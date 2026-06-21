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
                        <form method="post" action="${pageContext.request.contextPath}/seller/contracts/update">
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
                                <div class="col-sm-12">
                                    <label class="font-weight-bold">Máy phát điện khả dụng <span class="text-danger">*</span></label>
                                    <select name="generatorId" class="form-control" required>
                                        <option value="">-- Chọn máy phát điện --</option>
                                        <c:forEach var="g" items="${generators}">
                                            <option value="${g.generatorId}" ${g.generatorId == currentGenId ? 'selected' : ''}>${g.generatorName} - Brand: ${g.brand} - Công suất: ${g.powerValue} (Loc: ${g.location})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <fmt:formatDate value="${contract.startDate}" pattern="yyyy-MM-dd" var="formattedStartDate" />
                            <fmt:formatDate value="${contract.expectedReturnDate}" pattern="yyyy-MM-dd" var="formattedExpectedReturnDate" />

                            <div class="form-group row">
                                <div class="col-sm-6">
                                    <label class="font-weight-bold">Ngày bắt đầu <span class="text-danger">*</span></label>
                                    <input type="date" name="startDate" value="${formattedStartDate}" class="form-control" required>
                                </div>
                                <div class="col-sm-6">
                                    <label class="font-weight-bold">Ngày trả dự kiến <span class="text-danger">*</span></label>
                                    <input type="date" name="expectedReturnDate" value="${formattedExpectedReturnDate}" class="form-control" required>
                                </div>
                            </div>

                            <div class="form-group row">
                                <div class="col-sm-4">
                                    <label class="font-weight-bold">Đơn giá thuê (VND) <span class="text-danger">*</span></label>
                                    <input type="number" step="1000" name="rentalPrice" value="${rentalPrice}" class="form-control" required>
                                </div>
                                <div class="col-sm-4">
                                    <label class="font-weight-bold">Tiền đặt cọc (VND)</label>
                                    <input type="number" step="1000" name="depositAmount" value="${contract.depositAmount}" class="form-control">
                                </div>
                                <div class="col-sm-4">
                                    <label class="font-weight-bold">Tổng thanh toán (VND)</label>
                                    <input type="number" step="1000" name="totalAmount" value="${contract.totalAmount}" class="form-control">
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
</body>
</html>
