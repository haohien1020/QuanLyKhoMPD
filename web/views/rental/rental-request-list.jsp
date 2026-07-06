<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Danh sách thuê máy | Generator Management System</title>
            <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css"
                rel="stylesheet">
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
                                        <h1 class="h3 mb-0 text-gray-800">Quản lý Thuê phát điện</h1>
                                        <div>
                                            <span class="badge badge-info p-2">Kho:
                                                ${managedWarehouse.warehouseName}</span>
                                        </div>
                                    </div>

                                    <c:if test="${param.success == 'staff_assigned'}">
                                        <div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã phân
                                            công nhân viên kỹ thuật kiểm tra máy thành công!</div>
                                    </c:if>
                                    <c:if test="${param.success == 'approved'}">
                                        <div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã duyệt
                                            hợp đồng thuê máy thành công!</div>
                                    </c:if>
                                    <c:if test="${param.success == 'rejected'}">
                                        <div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã từ chối yêu cầu thuê máy thành công!</div>
                                    </c:if>
                                    <c:if test="${param.error == 'reject_failed'}">
                                        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Từ chối yêu cầu thuê máy thất bại!</div>
                                    </c:if>
                                    <c:if test="${param.success == 'delivered'}">
                                        <div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã xác nhận
                                            bàn giao máy cho khách thuê! Máy phát điện đã được cập nhật trạng thái xuất
                                            kho.</div>
                                    </c:if>
                                    <c:if test="${param.success == 'returned'}">
                                        <div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã xác nhận
                                            nhận lại máy phát điện hoàn chỉnh. Trạng thái máy đã cập nhật về trong kho.
                                        </div>
                                    </c:if>
                                    <c:if test="${param.error == 'no_staff_assigned'}">
                                        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Không thể duyệt hợp đồng! Vui lòng phân công nhân viên kỹ thuật trước khi duyệt.</div>
                                    </c:if>

                                    <c:if test="${not empty error}">
                                        <div class="alert alert-danger">${error}</div>
                                    </c:if>

                                    <!-- Contracts List -->
                                    <div class="card shadow mb-4">
                                        <div class="card-header py-3">
                                            <h6 class="m-0 font-weight-bold text-primary">Các yêu cầu từ khách hàng</h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="table-responsive">
                                                <table class="table table-bordered table-striped" width="100%"
                                                    cellspacing="0">
                                                    <thead>
                                                        <tr>
                                                            <th>Mã hợp đồng</th>
                                                            <th>Khách hàng</th>
                                                            <th>Ngày bắt đầu</th>
                                                            <th>Ngày trả dự kiến</th>
                                                            <th>Trạng thái</th>
                                                            <th>Hành động</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="contract" items="${contracts}">
                                                            <tr>
                                                                <td><strong>${contract.contractCode}</strong></td>
                                                                <td>${contract.customerName}</td>
                                                                <td>${contract.startDate}</td>
                                                                <td>${contract.expectedReturnDate}</td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${contract.status == 'PENDING'}">
                                                                            <span class="badge badge-warning">Chờ xử
                                                                                lý</span>
                                                                        </c:when>
                                                                        <c:when test="${contract.status == 'APPROVED'}">
                                                                            <span class="badge badge-primary">Đã duyệt
                                                                                (Chờ giao máy)</span>
                                                                        </c:when>
                                                                        <c:when
                                                                            test="${contract.status == 'DELIVERED'}">
                                                                            <span class="badge badge-info">Đang
                                                                                thuê</span>
                                                                        </c:when>
                                                                        <c:when
                                                                            test="${contract.status == 'COMPLETED'}">
                                                                            <span class="badge badge-success">Đã hoàn
                                                                                thành</span>
                                                                        </c:when>
                                                                        <c:when test="${contract.status == 'REJECTED'}">
                                                                            <span class="badge badge-danger">Đã từ chối</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                class="badge badge-secondary">${contract.status}</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <button type="button"
                                                                        class="btn btn-info btn-sm mr-1 mb-1"
                                                                        onclick="openDetailModal('${contract.contractCode}', '${contract.sellerName}', '${contract.customerName}', '${contract.customerPhone}', '${contract.customerEmail}', '${contract.brand} ${contract.generatorName}', '${contract.serialNumber}', '${contract.rentalPrice}', '${contract.depositAmount}', '${contract.totalAmount}', '${contract.startDate}', '${contract.expectedReturnDate}', '${contract.status}', '${contract.note}', false, '')"
                                                                        title="Xem chi tiết hợp đồng">
                                                                        <i class="fas fa-eye"></i> Chi tiết
                                                                    </button>

                                                                    <c:choose>
                                                                        <c:when test="${contract.status == 'PENDING'}">
                                                                            <a href="${pageContext.request.contextPath}/warehouse/rentals/action?action=assign-staff&contractId=${contract.rentalContractId}"
                                                                                class="btn btn-warning btn-sm mb-1"><i
                                                                                    class="fas fa-user-plus"></i> Phân công Staff</a>
                                                                            <c:if test="${not empty contract.assignedStaffName}">
                                                                                <div class="small text-muted mt-1 mb-1">
                                                                                    <i class="fas fa-user-check text-success"></i> Đã giao: <strong>${contract.assignedStaffName}</strong>
                                                                                </div>
                                                                            </c:if>
 
                                                                            <button type="button"
                                                                                class="btn btn-primary btn-sm mb-1 ml-1"
                                                                                ${(empty contract.assignedStaffId || contract.assignedStaffId == 0) ? 'disabled' : ''}
                                                                                onclick="openDetailModal('${contract.contractCode}', '${contract.sellerName}', '${contract.customerName}', '${contract.customerPhone}', '${contract.customerEmail}', '${contract.brand} ${contract.generatorName}', '${contract.serialNumber}', '${contract.rentalPrice}', '${contract.depositAmount}', '${contract.totalAmount}', '${contract.startDate}', '${contract.expectedReturnDate}', '${contract.status}', '${contract.note}', true, '${contract.rentalContractId}')"
                                                                                title="${(empty contract.assignedStaffId || contract.assignedStaffId == 0) ? 'Vui lòng phân công nhân viên kỹ thuật trước khi duyệt' : 'Xem chi tiết và duyệt hợp đồng'}">
                                                                                <i class="fas fa-check"></i> Duyệt hợp đồng
                                                                            </button>
                                                                            <form method="post"
                                                                                action="${pageContext.request.contextPath}/warehouse/rentals/action?action=reject"
                                                                                class="d-inline"
                                                                                onsubmit="return confirm('Xác nhận từ chối hợp đồng này?');">
                                                                                <input type="hidden" name="contractId"
                                                                                    value="${contract.rentalContractId}">
                                                                                <button type="submit"
                                                                                    class="btn btn-danger btn-sm mb-1 ml-1"><i
                                                                                        class="fas fa-times"></i> Từ chối</button>
                                                                            </form>
                                                                        </c:when>
                                                                        <c:when test="${contract.status == 'APPROVED'}">
                                                                            <form method="post"
                                                                                action="${pageContext.request.contextPath}/warehouse/rentals/action?action=deliver"
                                                                                class="d-inline"
                                                                                onsubmit="return confirm('Xác nhận bàn giao máy phát điện cho khách hàng?');">
                                                                                <input type="hidden" name="contractId"
                                                                                    value="${contract.rentalContractId}">
                                                                                <button type="submit"
                                                                                    class="btn btn-success btn-sm mb-1"><i
                                                                                        class="fas fa-truck-moving"></i>
                                                                                    Bàn giao máy (Xuất kho)</button>
                                                                            </form>
                                                                        </c:when>
                                                                        <c:when
                                                                            test="${contract.status == 'DELIVERED'}">
                                                                            <form method="post"
                                                                                action="${pageContext.request.contextPath}/warehouse/rentals/action?action=return"
                                                                                class="d-inline"
                                                                                onsubmit="return confirm('Xác nhận nhận lại máy phát điện và hoàn thành hợp đồng?');">
                                                                                <input type="hidden" name="contractId"
                                                                                    value="${contract.rentalContractId}">
                                                                                <button type="submit"
                                                                                    class="btn btn-info btn-sm mb-1"><i
                                                                                        class="fas fa-undo"></i> Xác nhận trả máy (Nhập kho)</button>
                                                                            </form>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="text-muted">Không có hành động</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <c:if test="${empty contracts}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted py-4">
                                                                    Không có yêu cầu thuê máy nào.</td>
                                                            </tr>
                                                        </c:if>
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
                    <div class="modal-content">
                        <div class="modal-header bg-gradient-info text-white">
                            <h5 class="modal-title"><i class="fas fa-file-contract"></i> Chi tiết Hợp đồng thuê: <span
                                    id="detailContractCode" class="font-weight-bold"></span></h5>
                            <button type="button" class="close text-white"
                                data-dismiss="modal"><span>&times;</span></button>
                        </div>
                        <div class="modal-body text-gray-900">
                            <div class="row mb-3">
                                <div class="col-md-6 border-right">
                                    <h6 class="font-weight-bold text-primary"><i class="fas fa-user-tie"></i> Nhân viên
                                        tạo hợp đồng (Seller)</h6>
                                    <table class="table table-sm table-borderless">
                                        <tr>
                                            <td class="text-muted" style="width: 120px;">Họ tên:</td>
                                            <td id="detailSellerName" class="font-weight-bold"></td>
                                        </tr>
                                    </table>

                                    <h6 class="font-weight-bold text-primary mt-3"><i class="fas fa-user"></i> Thông tin
                                        khách hàng (Người mua)</h6>
                                    <table class="table table-sm table-borderless">
                                        <tr>
                                            <td class="text-muted" style="width: 120px;">Họ tên:</td>
                                            <td id="detailCustomerName" class="font-weight-bold"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Số điện thoại:</td>
                                            <td id="detailCustomerPhone"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Email:</td>
                                            <td id="detailCustomerEmail"></td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="font-weight-bold text-primary"><i class="fas fa-bolt"></i> Thông tin máy
                                        phát điện thuê</h6>
                                    <table class="table table-sm table-borderless">
                                        <tr>
                                            <td class="text-muted" style="width: 120px;">Mẫu máy:</td>
                                            <td id="detailGeneratorName" class="font-weight-bold"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Số Serial:</td>
                                            <td id="detailSerialNumber" class="font-weight-bold text-danger"></td>
                                        </tr>
                                    </table>

                                    <h6 class="font-weight-bold text-primary mt-3"><i
                                            class="fas fa-money-bill-wave"></i> Giá trị hợp đồng</h6>
                                    <table class="table table-sm table-borderless">
                                        <tr>
                                            <td class="text-muted" style="width: 120px;">Đơn giá thuê:</td>
                                            <td id="detailRentalPrice" class="font-weight-bold text-success"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Tiền đặt cọc:</td>
                                            <td id="detailDepositAmount" class="font-weight-bold"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Tổng thanh toán:</td>
                                            <td id="detailTotalAmount" class="font-weight-bold text-primary"
                                                style="font-size: 1.1rem;"></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <hr>
                            <div class="row">
                                <div class="col-md-6">
                                    <h6 class="font-weight-bold text-primary"><i class="fas fa-calendar-alt"></i> Thời
                                        hạn thuê</h6>
                                    <table class="table table-sm table-borderless">
                                        <tr>
                                            <td class="text-muted" style="width: 120px;">Ngày bắt đầu:</td>
                                            <td id="detailStartDate"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Ngày trả dự kiến:</td>
                                            <td id="detailExpectedReturnDate"></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Trạng thái:</td>
                                            <td><span id="detailStatusText" class="badge"></span></td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="font-weight-bold text-primary"><i class="fas fa-sticky-note"></i> Ghi chú
                                        hợp đồng</h6>
                                    <div id="detailNote" class="p-2 border rounded bg-light text-break"
                                        style="min-height: 60px; white-space: pre-wrap;"></div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer bg-light">
                            <form id="approveContractForm" method="post"
                                action="${pageContext.request.contextPath}/warehouse/rentals/action?action=approve"
                                class="d-inline" style="display:none;"
                                onsubmit="return confirm('Xác nhận duyệt yêu cầu thuê này?');">
                                <input type="hidden" name="contractId" id="approveContractId" value="">
                                <button type="submit" class="btn btn-success"><i class="fas fa-check-circle"></i> Xác
                                    nhận duyệt hợp đồng</button>
                            </form>
                            <form id="rejectContractForm" method="post"
                                action="${pageContext.request.contextPath}/warehouse/rentals/action?action=reject"
                                class="d-inline" style="display:none;"
                                onsubmit="return confirm('Xác nhận từ chối yêu cầu thuê này?');">
                                <input type="hidden" name="contractId" id="rejectContractId" value="">
                                <button type="submit" class="btn btn-danger"><i class="fas fa-times-circle"></i> Từ chối</button>
                            </form>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                        </div>
                    </div>
                </div>
            </div>

            <script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
            <script
                src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
            <script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>

            <script>
                function openDetailModal(code, seller, customer, phone, email, genName, serial, price, deposit, total, start, expected, status, note, showApprove, contractId) {
                    $('#detailContractCode').text(code || '-');
                    $('#detailSellerName').text(seller || 'Hệ thống');
                    $('#detailCustomerName').text(customer || '-');
                    $('#detailCustomerPhone').text(phone || '-');
                    $('#detailCustomerEmail').text(email || '-');

                    $('#detailGeneratorName').text(genName || 'Chưa chọn máy');
                    
                    var serialEl = $('#detailSerialNumber');
                    serialEl.empty();
                    if (serial && serial !== 'Chưa cập nhật' && serial !== '-') {
                        var serials = serial.split(', ');
                        var html = '';
                        serials.forEach(function(s) {
                            html += '<div style="font-size: 0.78rem; font-weight: 600; line-height: 1.3; margin-bottom: 2px; color: #e74a3b;">- ' + s + '</div>';
                        });
                        serialEl.html(html);
                    } else {
                        serialEl.text(serial || '-');
                    }

                    var formattedPrice = price ? parseFloat(price).toLocaleString('vi-VN') + ' VNĐ/ngày' : '0 VNĐ/ngày';
                    $('#detailRentalPrice').text(formattedPrice);

                    var formattedDeposit = deposit ? parseFloat(deposit).toLocaleString('vi-VN') + ' VNĐ' : '0 VNĐ';
                    $('#detailDepositAmount').text(formattedDeposit);

                    var formattedTotal = total ? parseFloat(total).toLocaleString('vi-VN') + ' VNĐ' : '0 VNĐ';
                    $('#detailTotalAmount').text(formattedTotal);

                    // Format dates nicely
                    $('#detailStartDate').text(start ? start.substring(0, 16) : '-');
                    $('#detailExpectedReturnDate').text(expected ? expected.substring(0, 16) : '-');

                    var badgeClass = 'badge-secondary';
                    var statusVn = status;
                    if (status === 'PENDING') {
                        badgeClass = 'badge-warning';
                        statusVn = 'Chờ xử lý';
                    } else if (status === 'APPROVED') {
                        badgeClass = 'badge-primary';
                        statusVn = 'Đã duyệt (Chờ giao máy)';
                    } else if (status === 'DELIVERED') {
                        badgeClass = 'badge-info';
                        statusVn = 'Đang thuê';
                    } else if (status === 'COMPLETED') {
                        badgeClass = 'badge-success';
                        statusVn = 'Đã hoàn thành';
                    } else if (status === 'REJECTED') {
                        badgeClass = 'badge-danger';
                        statusVn = 'Cá nhân từ chối';
                        statusVn = 'Đã từ chối';
                    }
                    $('#detailStatusText').text(statusVn).attr('class', 'badge ' + badgeClass + ' p-2');

                    $('#detailNote').text(note || 'Không có ghi chú.');

                    if (showApprove && contractId) {
                        $('#approveContractId').val(contractId);
                        $('#approveContractForm').show();
                        $('#rejectContractId').val(contractId);
                        $('#rejectContractForm').show();
                    } else {
                        $('#approveContractId').val('');
                        $('#approveContractForm').hide();
                        $('#rejectContractId').val('');
                        $('#rejectContractForm').hide();
                    }

                    $('#contractDetailModal').modal('show');
                }
            </script>

            <!-- Modal Phân công Staff -->
            <div class="modal fade" id="assignStaffModal" tabindex="-1" role="dialog" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content text-gray-900">
                        <div class="modal-header bg-gradient-warning text-white">
                            <h5 class="modal-title font-weight-bold"><i class="fas fa-user-plus mr-2"></i>Phân công Nhân viên Kỹ thuật</h5>
                            <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/warehouse/rentals/action?action=assign-staff">
                            <input type="hidden" name="contractId" value="${assignContractId}">
                            <div class="modal-body text-left">
                                <div class="mb-3">
                                    <div class="small text-muted mb-1">Mã hợp đồng:</div>
                                    <div class="font-weight-bold text-gray-900" style="font-size: 1.1rem;">${assignContract.contractCode}</div>
                                </div>
                                <div class="mb-3">
                                    <div class="small text-muted mb-1">Khách hàng:</div>
                                    <div class="font-weight-bold text-gray-900">${assignContract.customerName}</div>
                                </div>
                                <div class="mb-3">
                                    <div class="small text-muted mb-1">Thiết bị:</div>
                                    <div class="text-gray-900">${assignContract.brand} ${assignContract.generatorName} (Serial: <span class="font-weight-bold text-danger">${assignContract.serialNumber}</span>)</div>
                                </div>
                                <hr>
                                <div class="form-group">
                                    <label class="font-weight-bold text-gray-800">Chọn nhân viên kỹ thuật (Staff) <span class="text-danger">*</span></label>
                                    <select name="staffId" class="form-control text-gray-900" required>
                                        <option value="">-- Chọn nhân viên --</option>
                                        <c:forEach var="s" items="${staffList}">
                                            <option value="${s.userId}" ${s.userId == assignContract.assignedStaffId ? 'selected' : ''}>${s.fullName} (${s.email})</option>
                                        </c:forEach>
                                    </select>
                                    <small class="form-text text-muted">Nhân viên được phân công sẽ nhận được thông báo thực hiện kiểm tra máy trước khi bàn giao.</small>
                                </div>
                            </div>
                            <div class="modal-footer bg-light">
                                <button type="submit" class="btn btn-warning font-weight-bold text-dark"><i class="fas fa-save mr-1"></i> Lưu phân công</button>
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <c:if test="${not empty assignContractId}">
                <script>
                    $(document).ready(function() {
                        $('#assignStaffModal').modal('show');
                    });
                </script>
            </c:if>
        </body>

        </html>