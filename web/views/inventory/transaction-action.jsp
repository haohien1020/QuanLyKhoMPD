<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <c:set var="isManager" value="${sessionScope.currentUser.hasRole('WAREHOUSE_MANAGER')}" />
            <c:set var="canImport" value="${isManager or sessionScope.currentUser.canImportInventory}" />
            <c:set var="canExport" value="${isManager or sessionScope.currentUser.canExportInventory}" />

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Nhập kho & Xuất kho | Generator Management System</title>
                <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css"
                    rel="stylesheet">
                <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
                <style>
                    :root {
                        --primary-gradient: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
                        --danger-gradient: linear-gradient(135deg, #7f1d1d 0%, #ef4444 100%);
                        --success-gradient: linear-gradient(135deg, #064e3b 0%, #10b981 100%);
                        --glass-bg: rgba(255, 255, 255, 0.9);
                        --card-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.05);
                    }

                    .premium-card {
                        border: none;
                        border-radius: 12px;
                        box-shadow: var(--card-shadow);
                        background: var(--glass-bg);
                        transition: transform 0.2s ease, box-shadow 0.2s ease;
                    }

                    .premium-card:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 6px 25px 0 rgba(0, 0, 0, 0.08);
                    }

                    .bg-import {
                        background: var(--success-gradient) !important;
                        color: #fff;
                    }

                    .bg-export {
                        background: var(--danger-gradient) !important;
                        color: #fff;
                    }

                    .bg-primary-grad {
                        background: var(--primary-gradient) !important;
                        color: #fff;
                    }

                    .badge-pending {
                        background-color: #fef3c7;
                        color: #d97706;
                        font-weight: bold;
                    }

                    .badge-approved {
                        background-color: #d1fae5;
                        color: #059669;
                        font-weight: bold;
                    }

                    .badge-delivered {
                        background-color: #dbeafe;
                        color: #2563eb;
                        font-weight: bold;
                    }

                    .action-icon {
                        font-size: 2rem;
                        opacity: 0.85;
                    }

                    .nav-pills .nav-link.active,
                    .nav-pills .show>.nav-link {
                        background: var(--primary-gradient);
                        box-shadow: 0 4px 10px rgba(59, 130, 246, 0.25);
                    }

                    .nav-pills .nav-link {
                        border-radius: 8px;
                        font-weight: bold;
                        color: #4b5563;
                    }

                    .nav-tabs .nav-link {
                        border: none;
                        color: #4b5563;
                        border-radius: 8px 8px 0 0;
                        transition: all 0.2s ease-in-out;
                    }

                    .nav-tabs .nav-link.active {
                        color: #1e3a8a !important;
                        font-weight: bold;
                        border-bottom: 3px solid #3b82f6;
                        background-color: transparent;
                    }

                    .hover-scale {
                        transition: all 0.2s ease-in-out;
                    }

                    .hover-scale:hover {
                        transform: scale(1.02);
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

                                        <!-- Page Heading -->
                                        <div class="d-sm-flex align-items-center justify-content-between mb-4">
                                            <h1 class="h3 mb-0 text-gray-800 font-weight-bold">
                                                <i class="fas fa-dolly text-primary mr-2"></i>Nghiệp vụ Nhập kho & Xuất
                                                kho
                                            </h1>
                                            <div class="text-right">
                                                <span class="badge badge-info p-2 font-weight-bold shadow-sm"
                                                    style="font-size: 0.9rem;">
                                                    <i class="fas fa-warehouse mr-1"></i> Kho quản lý:
                                                    ${managedWarehouse.warehouseName}
                                                </span>
                                            </div>
                                        </div>

                                        <!-- Toast Alerts for Success / Error -->
                                        <c:if test="${param.success eq 'import_success'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã
                                                nhập số lượng phụ tùng mua mới vào kho và lưu nhật ký.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.success eq 'generator_import_success'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã
                                                nhập máy phát điện trở lại kho và lưu nhật ký giao dịch.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.success eq 'generator_export_success'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã
                                                xuất kho máy phát điện và cập nhật trạng thái thiết bị.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.success eq 'generator_transfer_created'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã
                                                tạo yêu cầu điều chuyển máy phát điện sang kho khác và đang chờ phê
                                                duyệt.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.success eq 'export_success'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã
                                                xuất cấp phát phụ tùng và cập nhật số lượng tồn kho.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'invalid_quantity'}">
                                            <div class="alert alert-warning alert-dismissible fade show shadow-sm border-left-warning"
                                                role="alert">
                                                <i class="fas fa-exclamation-triangle mr-2"></i> <strong>Lưu ý:</strong>
                                                Số lượng nhập/xuất phải lớn hơn 0.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'insufficient_stock'}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-times-circle mr-2"></i> <strong>Thất bại!</strong> Số
                                                lượng tồn kho hiện tại của phụ tùng hoặc máy phát điện này không đủ để
                                                xuất kho/điều chuyển.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'serial_exists'}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-times-circle mr-2"></i> <strong>Thất bại!</strong> Số
                                                Serial này đã được sử dụng bởi một máy phát điện khác trong hệ thống.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'missing_required'}">
                                            <div class="alert alert-warning alert-dismissible fade show shadow-sm border-left-warning"
                                                role="alert">
                                                <i class="fas fa-exclamation-triangle mr-2"></i> <strong>Lưu ý:</strong>
                                                Vui lòng điền đầy đủ các trường thông tin bắt buộc (Tên máy phát điện,
                                                Số Serial).
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'generator_import_failed'}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-times-circle mr-2"></i> <strong>Thất bại!</strong>
                                                Không thể
                                                nhập máy phát điện vào kho. Vui lòng thử lại.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'generator_export_failed'}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-times-circle mr-2"></i> <strong>Thất bại!</strong>
                                                Không thể
                                                xuất kho máy phát điện (chỉ máy phát điện có trạng thái 'Trong kho' mới
                                                có thể xuất). Vui lòng thử lại.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'system_error' or not empty error}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-times-circle mr-2"></i> <strong>Lỗi hệ thống:</strong>
                                                ${error != null ? error : "Thao tác thất bại. Vui lòng kiểm tra lại kết
                                                nối DB."}
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>

                                        <!-- Shortcut Buttons Grid -->
                                        <div class="row mb-4">
                                            <div class="col-xl-4 col-md-6 mb-4 hover-scale">
                                                <div class="card premium-card border-left-primary h-100 py-2">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col mr-2">
                                                                <div
                                                                    class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                                    Máy phát điện</div>
                                                                <div class="h5 mb-1 font-weight-bold text-gray-800">Nhập
                                                                    máy mới mua</div>
                                                                <div class="text-xs text-muted mb-2">Đăng ký khai báo
                                                                    mới & tạo mã vạch</div>
                                                                <a href="${pageContext.request.contextPath}/generators"
                                                                    class="btn btn-primary btn-sm font-weight-bold">
                                                                    <i class="fas fa-plus-circle mr-1"></i> Thực hiện
                                                                    ngay
                                                                </a>
                                                            </div>
                                                            <div class="col-auto">
                                                                <i class="fas fa-bolt fa-2x text-gray-300"></i>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-xl-4 col-md-6 mb-4 hover-scale">
                                                <div class="card premium-card border-left-success h-100 py-2">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col mr-2">
                                                                <div
                                                                    class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                                    Hợp đồng khách hàng</div>
                                                                <div class="h5 mb-1 font-weight-bold text-gray-800">Giao
                                                                    máy / Thu hồi máy</div>
                                                                <div class="text-xs text-muted mb-2">Xuất kho cho thuê
                                                                    hoặc nhận máy trả về</div>
                                                                <a href="${pageContext.request.contextPath}/warehouse/rentals"
                                                                    class="btn btn-success btn-sm font-weight-bold">
                                                                    <i class="fas fa-file-contract mr-1"></i> Đi tới hợp
                                                                    đồng
                                                                </a>
                                                            </div>
                                                            <div class="col-auto">
                                                                <i class="fas fa-exchange-alt fa-2x text-gray-300"></i>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-xl-4 col-md-6 mb-4 hover-scale">
                                                <div class="card premium-card border-left-info h-100 py-2">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col mr-2">
                                                                <div
                                                                    class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                                                    Nhật ký biến động</div>
                                                                <div class="h5 mb-1 font-weight-bold text-gray-800">Lịch
                                                                    sử giao dịch kho</div>
                                                                <div class="text-xs text-muted mb-2">Tra cứu, in ấn lịch
                                                                    sử xuất nhập</div>
                                                                <a href="${pageContext.request.contextPath}/inventory-transactions/history"
                                                                    class="btn btn-info btn-sm font-weight-bold text-white">
                                                                    <i class="fas fa-history mr-1"></i> Xem lịch sử
                                                                </a>
                                                            </div>
                                                            <div class="col-auto">
                                                                <i class="fas fa-list-alt fa-2x text-gray-300"></i>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <!-- Left Column: Transactions -->
                                            <div class="col-lg-7 mb-4">
                                                <div class="card premium-card shadow mb-4">
                                                    <div class="card-header py-3 bg-white border-bottom">
                                                        <h6 class="m-0 font-weight-bold text-primary">
                                                            <i class="fas fa-bolt mr-1"></i> Giao dịch Máy phát điện
                                                        </h6>
                                                    </div>
                                                    <div class="card-body">
                                                        <ul class="nav nav-pills mb-4" id="pills-gen-tab"
                                                            role="tablist">
                                                            <c:if test="${canImport}">
                                                                <li class="nav-item" role="presentation">
                                                                    <a class="nav-link ${canImport ? 'active' : ''} mr-2"
                                                                        id="pills-gen-import-tab" data-toggle="pill"
                                                                        href="#pills-gen-import" role="tab"
                                                                        aria-controls="pills-gen-import"
                                                                        aria-selected="${canImport}">
                                                                        <i class="fas fa-download mr-1"></i> Nhập kho
                                                                        máy phát điện
                                                                    </a>
                                                                </li>
                                                            </c:if>
                                                            <c:if test="${canExport}">
                                                                <li class="nav-item" role="presentation">
                                                                    <a class="nav-link ${not canImport ? 'active' : ''}"
                                                                        id="pills-gen-export-tab" data-toggle="pill"
                                                                        href="#pills-gen-export" role="tab"
                                                                        aria-controls="pills-gen-export"
                                                                        aria-selected="${not canImport}">
                                                                        <i class="fas fa-upload mr-1"></i> Xuất kho máy
                                                                        phát điện
                                                                    </a>
                                                                </li>
                                                            </c:if>
                                                        </ul>

                                                        <div class="tab-content" id="pills-gen-tabContent">
                                                            <!-- TAB 1: IMPORT GENERATOR -->
                                                            <c:if test="${canImport}">
                                                                <div class="tab-pane fade ${canImport ? 'show active' : ''}"
                                                                    id="pills-gen-import" role="tabpanel"
                                                                    aria-labelledby="pills-gen-import-tab">
                                                                    <form method="post" id="importGenForm"
                                                                        action="${pageContext.request.contextPath}/inventory-transactions">
                                                                        <input type="hidden" name="action"
                                                                            value="import-generator">

                                                                        <div class="form-group">
                                                                            <label for="importTypeSelect"
                                                                                class="font-weight-bold text-gray-700">Loại
                                                                                nhập kho <span
                                                                                    class="text-danger">*</span></label>
                                                                            <select id="importTypeSelect"
                                                                                name="importType" class="form-control"
                                                                                required>
                                                                                <option value="">-- Chọn loại nhập kho
                                                                                    --</option>
                                                                                <option value="NEW_BATCH">Nhập lô máy
                                                                                    mới vào (Theo mẫu có sẵn)</option>
                                                                                <option value="RENTAL_RETURN">Nhập lại
                                                                                    máy khách thuê trả lại</option>
                                                                            </select>
                                                                        </div>

                                                                        <div id="importGenFieldsContainer"
                                                                            style="display: none;">
                                                                            <div class="form-group">
                                                                                <label id="importGenSelectLabel"
                                                                                    for="importGenSelect"
                                                                                    class="font-weight-bold text-gray-700">Chọn
                                                                                    máy phát điện cần nhập kho <span
                                                                                        class="text-danger">*</span></label>
                                                                                <select id="importGenSelect"
                                                                                    name="generatorId"
                                                                                    class="form-control" required
                                                                                    style="width: 100%;">
                                                                                    <option value="">-- Chọn máy phát
                                                                                        điện từ danh sách --</option>
                                                                                    <c:forEach var="gen"
                                                                                        items="${generators}">
                                                                                        <option
                                                                                            value="${gen.generatorId}"
                                                                                            data-status="${gen.status}">
                                                                                            ${gen.generatorName} ${not
                                                                                            empty gen.serialNumber ?
                                                                                            '('.concat(gen.serialNumber).concat(')')
                                                                                            : ''} - [${gen.brand}]
                                                                                            [${gen.powerValue}]
                                                                                            [${gen.fuelType}] - Trạng
                                                                                            thái:
                                                                                            <c:choose>
                                                                                                <c:when
                                                                                                    test="${gen.status eq 'IN_STOCK'}">
                                                                                                    Trong kho</c:when>
                                                                                                <c:when
                                                                                                    test="${gen.status eq 'EXPORTED'}">
                                                                                                    Đã xuất kho (Cho
                                                                                                    thuê)</c:when>
                                                                                                <c:otherwise>
                                                                                                    ${gen.status}
                                                                                                </c:otherwise>
                                                                                            </c:choose>
                                                                                        </option>
                                                                                    </c:forEach>
                                                                                </select>
                                                                            </div>

                                                                            <div class="form-group"
                                                                                id="importGenQtyContainer"
                                                                                style="display: none;">
                                                                                <label for="importGenQty"
                                                                                    class="font-weight-bold text-gray-700">Số
                                                                                    lượng nhập lô <span
                                                                                        class="text-danger">*</span></label>
                                                                                <input type="number" id="importGenQty"
                                                                                    name="quantity" class="form-control"
                                                                                    min="1" max="1000" value="1"
                                                                                    required>
                                                                                <small class="text-muted">Hệ thống sẽ tự
                                                                                    động nhân bản thông tin mẫu của máy
                                                                                    đã chọn và sinh tiếp các số serial
                                                                                    liên tiếp tương ứng.</small>
                                                                            </div>



                                                                            <div class="form-group">
                                                                                <label for="importGenNote"
                                                                                    class="font-weight-bold text-gray-700">Ghi
                                                                                    chú / Lý do nhập kho</label>
                                                                                <textarea id="importGenNote" name="note"
                                                                                    class="form-control" rows="3"
                                                                                    placeholder="Ghi chú thêm..."></textarea>
                                                                            </div>

                                                                            <div class="text-right">
                                                                                <button type="submit"
                                                                                    class="btn btn-success font-weight-bold px-4 shadow">
                                                                                    <i
                                                                                        class="fas fa-check-circle mr-1"></i>
                                                                                    Xác nhận Nhập Kho Máy Phát
                                                                                </button>
                                                                            </div>
                                                                        </div>
                                                                    </form>
                                                                </div>
                                                            </c:if>

                                                            <!-- TAB 2: EXPORT GENERATOR -->
                                                            <c:if test="${canExport}">
                                                                <div class="tab-pane fade ${not canImport ? 'show active' : ''}"
                                                                    id="pills-gen-export" role="tabpanel"
                                                                    aria-labelledby="pills-gen-export-tab">
                                                                    <form method="post"
                                                                        action="${pageContext.request.contextPath}/inventory-transactions">
                                                                        <input type="hidden" name="action"
                                                                            value="export-generator">

                                                                        <div class="form-group">
                                                                            <label for="exportStatus"
                                                                                class="font-weight-bold text-gray-700">Mục
                                                                                đích / Trạng thái xuất kho <span
                                                                                    class="text-danger">*</span></label>
                                                                            <select id="exportStatus"
                                                                                name="exportStatus" class="form-control"
                                                                                required>
                                                                                <option value="EXPORTED">Xuất giao cho
                                                                                    khách hàng (EXPORTED)</option>
                                                                                <c:if test="${isManager}">
                                                                                    <option value="TRANSFERRED">Xuất
                                                                                        sang kho khác (TRANSFERRED)
                                                                                    </option>
                                                                                </c:if>
                                                                            </select>
                                                                        </div>
                                                                        <div class="form-group"
                                                                            id="contractSelectContainer">
                                                                            <label for="exportContractSelect"
                                                                                class="font-weight-bold text-gray-700">Chọn
                                                                                hợp đồng thuê được duyệt <span
                                                                                    class="text-danger">*</span></label>
                                                                            <select id="exportContractSelect"
                                                                                name="contractId" class="form-control"
                                                                                required style="width: 100%;">
                                                                                <option value="">-- Chọn hợp đồng thuê
                                                                                    --</option>
                                                                                <c:forEach var="c"
                                                                                    items="${approvedRentals}">
                                                                                    <option
                                                                                        value="${c.rentalContractId}"
                                                                                        data-serial="${c.serialNumber}"
                                                                                        data-generatorid="${c.generatorId}"
                                                                                        data-code="${c.contractCode}">
                                                                                        ${c.contractCode} - Khách hàng:
                                                                                        ${c.customerName} (Serial chỉ
                                                                                        định: ${c.serialNumber})
                                                                                    </option>
                                                                                </c:forEach>
                                                                            </select>
                                                                        </div>

                                                                        <div id="exportBarcodeContainer">
                                                                            <div class="form-group">
                                                                                <label for="exportGenSelect"
                                                                                    id="exportGenSelectLabel"
                                                                                    class="font-weight-bold text-gray-700">Chọn
                                                                                    máy phát điện cần xuất kho <span
                                                                                        class="text-danger">*</span></label>
                                                                                <select id="exportGenSelect"
                                                                                    class="form-control" required
                                                                                    style="width: 100%;">
                                                                                    <option value="">-- Chọn máy phát
                                                                                        điện sẵn sàng trong kho --
                                                                                    </option>
                                                                                    <c:forEach var="gb"
                                                                                        items="${inStockBarcodes}">
                                                                                        <option value="${gb.barcodeId}">
                                                                                            ${gb.generatorName} (Serial:
                                                                                            ${gb.serialNumber})
                                                                                        </option>
                                                                                    </c:forEach>
                                                                                </select>
                                                                                <input type="hidden" name="barcodeId"
                                                                                    id="exportGenSelectHidden">

                                                                                <div class="form-group mt-3"
                                                                                    id="exportBarcodeGroup"
                                                                                    style="display:none;">
                                                                                    <label
                                                                                        class="font-weight-bold text-muted mb-2"><i
                                                                                            class="fas fa-barcode mr-1"></i>Hình
                                                                                        ảnh mã vạch Barcode các máy đã
                                                                                        chọn:</label>
                                                                                    <div
                                                                                        id="exportBarcodeListContainer">
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                        </div>

                                                                        <div id="exportTransferContainer"
                                                                            style="display: none;">
                                                                            <div class="form-group">
                                                                                <label for="exportModelSelect"
                                                                                    class="font-weight-bold text-gray-700">Chọn
                                                                                    mẫu máy phát điện trong kho <span
                                                                                        class="text-danger">*</span></label>
                                                                                <select id="exportModelSelect"
                                                                                    name="generatorId"
                                                                                    class="form-control"
                                                                                    style="width: 100%;">
                                                                                    <option value="">-- Chọn mẫu máy
                                                                                        phát điện để chuyển --</option>
                                                                                    <c:forEach var="gen"
                                                                                        items="${generators}">
                                                                                        <c:set var="availCount"
                                                                                            value="0" />
                                                                                        <c:forEach var="bc"
                                                                                            items="${inStockBarcodes}">
                                                                                            <c:if
                                                                                                test="${bc.generatorId == gen.generatorId}">
                                                                                                <c:set var="availCount"
                                                                                                    value="${availCount + 1}" />
                                                                                            </c:if>
                                                                                        </c:forEach>
                                                                                        <c:if test="${availCount > 0}">
                                                                                            <option
                                                                                                value="${gen.generatorId}"
                                                                                                data-avail="${availCount}">
                                                                                                ${gen.generatorName} -
                                                                                                [${gen.brand}]
                                                                                                [${gen.powerValue}] (Có
                                                                                                sẵn: ${availCount})
                                                                                            </option>
                                                                                        </c:if>
                                                                                    </c:forEach>
                                                                                </select>
                                                                            </div>

                                                                            <div class="row">
                                                                                <div class="form-group col-md-6">
                                                                                    <label for="exportQuantity"
                                                                                        class="font-weight-bold text-gray-700">Số
                                                                                        lượng cần chuyển <span
                                                                                            class="text-danger">*</span></label>
                                                                                    <input type="number"
                                                                                        id="exportQuantity"
                                                                                        name="quantity"
                                                                                        class="form-control" min="1"
                                                                                        value="1">
                                                                                </div>
                                                                                <div class="form-group col-md-6">
                                                                                    <label for="exportDestWarehouse"
                                                                                        class="font-weight-bold text-gray-700">Chọn
                                                                                        kho đích nhận điều chuyển <span
                                                                                            class="text-danger">*</span></label>
                                                                                    <select id="exportDestWarehouse"
                                                                                        name="toWarehouseId"
                                                                                        class="form-control">
                                                                                        <option value="">-- Chọn kho
                                                                                            đích --</option>
                                                                                        <c:forEach var="wh"
                                                                                            items="${destWarehouses}">
                                                                                            <option
                                                                                                value="${wh.warehouseId}">
                                                                                                ${wh.warehouseName}
                                                                                                (${wh.address})</option>
                                                                                        </c:forEach>
                                                                                    </select>
                                                                                </div>
                                                                            </div>
                                                                        </div>

                                                                        <div class="form-group">
                                                                            <label for="exportGenNote"
                                                                                class="font-weight-bold text-gray-700">Ghi
                                                                                chú / Lý do xuất kho <span
                                                                                    class="text-danger">*</span></label>
                                                                            <textarea id="exportGenNote" name="note"
                                                                                class="form-control" rows="3" required
                                                                                placeholder="Ví dụ: 'Xuất giao máy Cummins 150kVA đi bàn giao công trường theo HĐ-002' hoặc 'Xuất máy đi bảo dưỡng định kỳ sê-ri quý II'"></textarea>
                                                                        </div>

                                                                        <div class="text-right">
                                                                            <button type="submit"
                                                                                class="btn btn-danger font-weight-bold px-4 shadow">
                                                                                <i class="fas fa-check-circle mr-1"></i>
                                                                                Xác nhận Xuất Kho Máy Phát
                                                                            </button>
                                                                        </div>
                                                                    </form>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Right Column: Pending Rental/Return summary -->
                                            <div class="col-lg-5 mb-4">
                                                <div class="card premium-card shadow mb-4">
                                                    <div class="card-header py-3 bg-white border-bottom">
                                                        <h6 class="m-0 font-weight-bold text-success">
                                                            <i class="fas fa-clipboard-list mr-1"></i> Giám sát Hợp đồng
                                                            Thuê & Trả máy
                                                        </h6>
                                                    </div>
                                                    <div class="card-body" style="max-height: 480px; overflow-y: auto;">
                                                        <p class="text-xs text-muted mb-3"><i
                                                                class="fas fa-info-circle"></i> Danh sách hợp đồng liên
                                                            quan tới chi nhánh kho của bạn cần thực hiện xuất/nhập máy
                                                            vật lý.</p>

                                                        <c:forEach var="c" items="${pendingRentals}">
                                                            <div
                                                                class="card mb-3 shadow-sm hover-scale border-left-info">
                                                                <div class="card-body p-3">
                                                                    <div
                                                                        class="d-flex justify-content-between align-items-center mb-2">
                                                                        <span
                                                                            class="font-weight-bold text-gray-900">${c.contractCode}</span>
                                                                        <c:choose>
                                                                            <c:when test="${c.status eq 'PENDING'}">
                                                                                <span
                                                                                    class="badge badge-pending px-2 py-1">Chờ
                                                                                    Duyệt</span>
                                                                            </c:when>
                                                                            <c:when test="${c.status eq 'APPROVED'}">
                                                                                <span
                                                                                    class="badge badge-approved px-2 py-1">Đã
                                                                                    Duyệt (Chờ Giao)</span>
                                                                            </c:when>
                                                                            <c:when test="${c.status eq 'DELIVERED'}">
                                                                                <span
                                                                                    class="badge badge-delivered px-2 py-1">Đang
                                                                                    thuê (Chờ Nhận Trả)</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="badge badge-secondary px-2 py-1">${c.status}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <div class="small text-gray-700 mb-1">
                                                                        <i class="fas fa-user-circle mr-1"></i> Khách
                                                                        hàng: <strong>${c.customerName}</strong>
                                                                    </div>
                                                                    <div class="small text-gray-700 mb-2">
                                                                        <i class="fas fa-calendar-alt mr-1"></i> Ngày
                                                                        thuê:
                                                                        <fmt:formatDate value="${c.startDate}"
                                                                            pattern="dd/MM/yyyy" /> -
                                                                        <fmt:formatDate value="${c.expectedReturnDate}"
                                                                            pattern="dd/MM/yyyy" />
                                                                    </div>
                                                                    <div class="text-right">
                                                                        <a href="${pageContext.request.contextPath}/warehouse/rentals"
                                                                            class="btn btn-xs btn-outline-info font-weight-bold p-1 px-2"
                                                                            style="font-size: 0.75rem;">
                                                                            Chi tiết duyệt <i
                                                                                class="fas fa-arrow-right ml-1"></i>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                        <c:if test="${empty pendingRentals}">
                                                            <div class="text-center text-muted py-5">
                                                                <i class="fas fa-smile fa-3x mb-3 text-gray-300"></i>
                                                                <p class="m-0 small">Hiện không có hợp đồng thuê/trả nào
                                                                    đang hoạt động cần xử lý.</p>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                            </div>
                            <%@ include file="/views/layout/footer.jsp" %>
                        </div>
                </div>

                <script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
                <script
                    src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
                <script>
                    document.addEventListener("DOMContentLoaded", function () {
                        // 1. Đặt ngày nhập kho mặc định là hôm nay
                        var dateInput = document.getElementById("genImportDate");
                        if (dateInput) {
                            var today = new Date().toISOString().split('T')[0];
                            dateInput.value = today;
                        }

                        // 2. Tự xử lý chuyển đổi Pills con (Phần máy phát điện) bằng Vanilla JS
                        var genPillLinks = document.querySelectorAll('#pills-gen-tab .nav-link');
                        genPillLinks.forEach(function (link) {
                            link.addEventListener('click', function (e) {
                                e.preventDefault();

                                genPillLinks.forEach(function (l) {
                                    l.classList.remove('active');
                                    l.setAttribute('aria-selected', 'false');
                                });

                                this.classList.add('active');
                                this.setAttribute('aria-selected', 'true');

                                var panes = document.querySelectorAll('#pills-gen-tabContent > .tab-pane');
                                panes.forEach(function (pane) {
                                    pane.classList.remove('show', 'active');
                                });

                                var targetId = this.getAttribute('href');
                                var targetPane = document.querySelector(targetId);
                                if (targetPane) {
                                    targetPane.classList.add('show', 'active');
                                }
                            });
                        });

                        // 3. Kích hoạt tab tự động dựa trên kết quả phản hồi (Query Parameters)
                        var urlParams = new URLSearchParams(window.location.search);
                        var successParam = urlParams.get('success');
                        var errorParam = urlParams.get('error');

                        if (successParam === 'generator_export_success' ||
                            successParam === 'generator_transfer_created' ||
                            errorParam === 'generator_export_failed' ||
                            errorParam === 'generator_transfer_failed') {
                            var genExportPill = document.getElementById('pills-gen-export-tab');
                            if (genExportPill) {
                                genExportPill.click();
                            }
                        }

                        // Rebuild with data lists passed from servlet
                        var generatorModels = [
                            <c:forEach var="gen" items="${generators}" varStatus="loop">
                                {
                                    id: ${gen.generatorId},
                                name: '${gen.generatorName.replace("'", "\\'")}',
                                serial: '${gen.serialNumber != null ? gen.serialNumber.replace("'", "\\'") : ""}',
                                brand: '${gen.brand != null ? gen.brand.replace("'", "\\'") : ""}',
                                power: '${gen.powerValue != null ? gen.powerValue.replace("'", "\\'") : ""}',
                                fuel: '${gen.fuelType != null ? gen.fuelType.replace("'", "\\'") : ""}'
                                }${!loop.last ? ',' : ''}
                            </c:forEach>
                        ];

                        var notInStockBarcodes = [
                            <c:forEach var="gb" items="${notInStockBarcodes}" varStatus="loop">
                                {
                                    barcodeId: ${gb.barcodeId},
                                generatorId: ${gb.generatorId},
                                generatorName: '${gb.generatorName.replace("'", "\\'")}',
                                serialNumber: '${gb.serialNumber.replace("'", "\\'")}',
                                status: '${gb.status != null ? gb.status.replace("'", "\\'") : ""}'
                                }${!loop.last ? ',' : ''}
                            </c:forEach>
                        ];

                        var inStockBarcodes = [
                            <c:forEach var="gb" items="${inStockBarcodes}" varStatus="loop">
                                {
                                    barcodeId: ${gb.barcodeId},
                                generatorId: ${gb.generatorId},
                                generatorName: '${gb.generatorName.replace("'", "\\'")}',
                                serialNumber: '${gb.serialNumber.replace("'", "\\'")}'
                                }${!loop.last ? ',' : ''}
                            </c:forEach>
                        ];

                        function getStatusLabel(status) {
                            if (status === 'IN_STOCK') return 'Trong kho';
                            if (status === 'EXPORTED') return 'Đã xuất kho (Cho thuê)';
                            if (status === 'TRANSFERRED') return 'Đã chuyển kho';
                            return status;
                        }

                        $('#importTypeSelect').on('change', function () {
                            var type = $(this).val();
                            var selectEl = $('#importGenSelect');
                            var qtyContainer = $('#importGenQtyContainer');
                            var qtyInput = $('#importGenQty');
                            var labelEl = $('#importGenSelectLabel');

                            // Reset state
                            $('#importGenFieldsContainer').hide();
                            qtyContainer.hide();
                            qtyInput.prop('required', false);
                            selectEl.prop('required', false);

                            if (type === '') {
                                return;
                            }

                            $('#importGenFieldsContainer').show();
                            selectEl.prop('required', true);

                            if (type === 'NEW_BATCH') {
                                qtyContainer.show();
                                qtyInput.prop('required', true);
                                qtyInput.val('1');
                                labelEl.html('Chọn mẫu máy phát điện thiết lập sẵn <span class="text-danger">*</span>');
                                selectEl.attr('name', 'generatorId');

                                // Rebuild các options
                                selectEl.empty();
                                selectEl.append('<option value="">-- Chọn máy phát điện làm mẫu --</option>');
                                generatorModels.forEach(function (opt) {
                                    var text = opt.name + (opt.serial ? ' (' + opt.serial + ')' : '') + ' - [' + opt.brand + '] [' + opt.power + '] [' + opt.fuel + ']';
                                    selectEl.append($('<option>', {
                                        value: opt.id,
                                        text: text
                                    }));
                                });

                                // Ghi chú mẫu
                                $('#importGenNote').val('Nhập bổ sung lô máy mới theo mẫu.');
                            } else if (type === 'RENTAL_RETURN') {
                                labelEl.html('Chọn máy phát điện cần nhập kho <span class="text-danger">*</span>');
                                selectEl.attr('name', 'barcodeId');

                                // Rebuild các options
                                selectEl.empty();
                                selectEl.append('<option value="">-- Chọn máy phát điện từ danh sách --</option>');

                                var count = 0;
                                notInStockBarcodes.forEach(function (opt) {
                                    var match = (opt.status === 'EXPORTED');
                                    if (match) {
                                        selectEl.append($('<option>', {
                                            value: opt.barcodeId,
                                            text: opt.generatorName + ' (Serial: ' + opt.serialNumber + ')'
                                        }));
                                        count++;
                                    }
                                });
                                if (count === 0) {
                                    selectEl.append('<option value="" disabled>Không có máy nào đang cho thuê để nhập lại</option>');
                                }
                                $('#importGenNote').val('Nhập lại máy phát điện sau khi kết thúc thuê.');
                            }
                        });

                        function renderBarcodeInAction(serials) {
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

                            serialArray.forEach(function (s) {
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

                                    var cardHtml = '<div class="text-center p-3 bg-light rounded border shadow-sm mb-2" style="max-width: 360px;">'
                                        + '<img src="' + canvas.toDataURL('image/png') + '" alt="Barcode" style="height: 55px; max-width: 100%; display: block; margin: 0 auto; background: #ffffff; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 4px; image-rendering: -webkit-optimize-contrast; image-rendering: pixelated;">'
                                        + '<div class="font-weight-bold text-dark mt-2" style="font-size: 0.9rem; font-family: monospace; letter-spacing: 1.2px; background: #fff; padding: 3px 8px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-block;">' + s + '</div>'
                                        + '</div>';
                                    container.append(cardHtml);
                                } catch (e) {
                                    console.error('JsBarcode error:', e);
                                }
                            });

                            $('#exportBarcodeGroup').show();
                        }

                        $('#exportGenSelect').on('change', function () {
                            if ($(this).prop('disabled')) {
                                return;
                            }
                            var vals = $(this).val();
                            if (vals) {
                                var valArray = Array.isArray(vals) ? vals : [vals];
                                var serials = [];
                                valArray.forEach(function (v) {
                                    var match = inStockBarcodes.find(function (b) { return b.barcodeId == v; });
                                    if (match && match.serialNumber) {
                                        serials.push(match.serialNumber);
                                    }
                                });
                                if (serials.length > 0) {
                                    renderBarcodeInAction(serials);
                                } else {
                                    $('#exportBarcodeGroup').hide();
                                }
                            } else {
                                $('#exportBarcodeGroup').hide();
                            }
                        });

                        $('#exportContractSelect').on('change', function () {
                            var selectedOpt = $(this).find('option:selected');
                            var serial = selectedOpt.data('serial');
                            var generatorId = selectedOpt.data('generatorid');
                            var code = selectedOpt.data('code');

                            var selectEl = $('#exportGenSelect');
                            var hiddenEl = $('#exportGenSelectHidden');
                            var labelEl = $('#exportGenSelectLabel');

                            selectEl.empty();
                            selectEl.removeAttr('multiple').removeAttr('size').css('min-height', '');

                            $('#exportBarcodeContainer').find('.dynamic-barcode-hidden').remove();

                            if (!$(this).val()) {
                                labelEl.html('Chọn máy phát điện cần xuất kho <span class="text-danger">*</span>');
                                selectEl.append('<option value="">-- Chọn máy phát điện sẵn sàng trong kho --</option>');
                                inStockBarcodes.forEach(function (b) {
                                    selectEl.append($('<option>', {
                                        value: b.barcodeId,
                                        text: b.generatorName + ' (Serial: ' + b.serialNumber + ')'
                                    }));
                                });
                                selectEl.prop('disabled', false);
                                selectEl.attr('name', 'barcodeId');
                                hiddenEl.val('');
                                hiddenEl.prop('disabled', true);
                                selectEl.trigger('change');
                                return;
                            }

                            var designatedSerials = [];
                            if (serial) {
                                var parts = serial.toString().split(/,\s*/);
                                parts.forEach(function (p) {
                                    p = p.trim();
                                    if (p) designatedSerials.push(p);
                                });
                            }

                            var matchingBarcodes = [];
                            if (designatedSerials.length > 0) {
                                designatedSerials.forEach(function (s) {
                                    var match = inStockBarcodes.find(function (b) { return b.serialNumber === s; });
                                    if (match) {
                                        matchingBarcodes.push(match);
                                    }
                                });
                            }

                            if (matchingBarcodes.length > 0) {
                                var isMulti = matchingBarcodes.length > 1;
                                if (isMulti) {
                                    labelEl.html('Chọn máy phát điện của mẫu theo Hợp đồng: ' + code + ' <span class="text-danger">*</span>');
                                    selectEl.attr('multiple', 'multiple').css('min-height', '120px');
                                } else {
                                    labelEl.html('Chọn máy phát điện của mẫu theo Hợp đồng: ' + code + ' <span class="text-danger">*</span>');
                                }

                                matchingBarcodes.forEach(function (b) {
                                    selectEl.append($('<option>', {
                                        value: b.barcodeId,
                                        text: b.generatorName + ' (Serial: ' + b.serialNumber + ')',
                                        selected: true
                                    }));
                                    $('#exportBarcodeContainer').append('<input type="hidden" name="barcodeId" class="dynamic-barcode-hidden" value="' + b.barcodeId + '">');
                                });

                                selectEl.prop('disabled', true);
                                selectEl.removeAttr('name');
                                hiddenEl.val('');
                                hiddenEl.prop('disabled', true);

                                var selectedSerials = matchingBarcodes.map(function (b) { return b.serialNumber; });
                                renderBarcodeInAction(selectedSerials);
                            } else if (generatorId) {
                                var filtered = inStockBarcodes.filter(function (b) {
                                    return b.generatorId == generatorId;
                                });

                                var reqCount = designatedSerials.length > 0 ? designatedSerials.length : 1;
                                if (reqCount > 1 || filtered.length > 1) {
                                    labelEl.html('Chọn máy phát điện của mẫu theo Hợp đồng: ' + code + ' <span class="text-danger">*</span>');
                                    selectEl.attr('multiple', 'multiple').css('min-height', '120px');
                                    selectEl.append('<option value="" disabled>-- Chọn máy phát điện cho mẫu này --</option>');
                                } else {
                                    labelEl.html('Chọn máy phát điện của mẫu theo Hợp đồng: ' + code + ' <span class="text-danger">*</span>');
                                    selectEl.append('<option value="">-- Chọn máy phát điện cho mẫu này --</option>');
                                }

                                if (filtered.length === 0) {
                                    selectEl.append('<option value="" disabled>Không có máy nào thuộc mẫu này sẵn sàng trong kho</option>');
                                } else {
                                    filtered.forEach(function (b) {
                                        selectEl.append($('<option>', {
                                            value: b.barcodeId,
                                            text: b.generatorName + ' (Serial: ' + b.serialNumber + ')'
                                        }));
                                    });
                                }
                                selectEl.prop('disabled', false);
                                selectEl.attr('name', 'barcodeId');
                                hiddenEl.val('');
                                hiddenEl.prop('disabled', true);
                            }

                            if (!selectEl.prop('disabled')) {
                                selectEl.trigger('change');
                            }
                        });

                        // Generator Export Form Toggle Logic for Transfers
                        $('#exportStatus').on('change', function () {
                            var status = $(this).val();
                            if (status === 'TRANSFERRED') {
                                $('#exportBarcodeContainer').hide();
                                $('#exportGenSelect').prop('required', false);
                                $('#contractSelectContainer').hide();
                                $('#exportContractSelect').prop('required', false).val('').trigger('change');

                                $('#exportTransferContainer').show();
                                $('#exportModelSelect').prop('required', true);
                                $('#exportQuantity').prop('required', true);
                                $('#exportDestWarehouse').prop('required', true);
                            } else {
                                $('#exportTransferContainer').hide();
                                $('#exportModelSelect').prop('required', false);
                                $('#exportQuantity').prop('required', false);
                                $('#exportDestWarehouse').prop('required', false);

                                $('#contractSelectContainer').show();
                                $('#exportContractSelect').prop('required', true);
                                $('#exportBarcodeContainer').show();
                                $('#exportGenSelect').prop('required', true);
                            }
                        });

                        // Trigger on load
                        $('#exportStatus').trigger('change');

                        $('#exportModelSelect').on('change', function () {
                            var selectedOpt = $(this).find('option:selected');
                            var avail = selectedOpt.data('avail') || 1;
                            $('#exportQuantity').attr('max', avail);
                            $('#exportQuantity').val(1);
                        });
                    });
                </script>
            </body>

            </html>