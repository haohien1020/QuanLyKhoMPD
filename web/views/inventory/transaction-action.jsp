<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
                                                nhập máy phát điện mới vào kho và lưu nhật ký giao dịch.
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
                                                lượng tồn kho hiện tại của phụ tùng này không đủ để xuất kho.
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
                                                Vui lòng điền đầy đủ các trường thông tin bắt buộc (Tên máy phát điện, Số Serial).
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.error eq 'generator_import_failed'}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-times-circle mr-2"></i> <strong>Thất bại!</strong> Không thể
                                                nhập máy phát điện vào kho. Vui lòng thử lại.
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
                                                                    <i class="fas fa-history mr-1"></i> Xem lịch sử log
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
                                                    <div class="card-header py-2 bg-white border-bottom">
                                                        <ul class="nav nav-tabs card-header-tabs" id="main-tx-tabs" role="tablist">
                                                            <li class="nav-item">
                                                                <a class="nav-link active font-weight-bold" id="parts-tx-tab" data-toggle="tab" href="#parts-tx-pane" role="tab" aria-controls="parts-tx-pane" aria-selected="true">
                                                                    <i class="fas fa-tools mr-1"></i> Giao dịch Phụ tùng / Linh kiện
                                                                </a>
                                                            </li>
                                                            <li class="nav-item">
                                                                <a class="nav-link font-weight-bold" id="generator-tx-tab" data-toggle="tab" href="#generator-tx-pane" role="tab" aria-controls="generator-tx-pane" aria-selected="false">
                                                                    <i class="fas fa-bolt mr-1"></i> Giao dịch Máy phát điện
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                    <div class="card-body">
                                                        <div class="tab-content" id="main-tx-tabsContent">
                                                            <!-- Pane 1: Parts Transactions -->
                                                            <div class="tab-pane fade show active" id="parts-tx-pane" role="tabpanel" aria-labelledby="parts-tx-tab">
                                                                <ul class="nav nav-pills mb-4" id="pills-tab" role="tablist">
                                                                    <li class="nav-item" role="presentation">
                                                                        <a class="nav-link active mr-2" id="pills-import-tab"
                                                                            data-toggle="pill" href="#pills-import" role="tab"
                                                                            aria-controls="pills-import" aria-selected="true">
                                                                            <i class="fas fa-download mr-1"></i> Nhập kho phụ
                                                                            tùng mới
                                                                        </a>
                                                                    </li>
                                                                    <li class="nav-item" role="presentation">
                                                                        <a class="nav-link" id="pills-export-tab"
                                                                            data-toggle="pill" href="#pills-export" role="tab"
                                                                            aria-controls="pills-export" aria-selected="false">
                                                                            <i class="fas fa-upload mr-1"></i> Xuất phụ tùng sửa
                                                                            chữa
                                                                        </a>
                                                                    </li>
                                                                </ul>

                                                                <div class="tab-content" id="pills-tabContent">
                                                                    <!-- TAB 1: IMPORT PART -->
                                                                    <div class="tab-pane fade show active" id="pills-import"
                                                                        role="tabpanel" aria-labelledby="pills-import-tab">
                                                                        <form method="post"
                                                                            action="${pageContext.request.contextPath}/inventory-transactions">
                                                                            <input type="hidden" name="action"
                                                                                value="import-part">

                                                                            <div class="form-group">
                                                                                <label for="importPartSelect"
                                                                                    class="font-weight-bold text-gray-700">Chọn
                                                                                    phụ tùng cần nhập <span
                                                                                        class="text-danger">*</span></label>
                                                                                <select id="importPartSelect" name="partId"
                                                                                    class="form-control select2" required
                                                                                    style="width: 100%;">
                                                                                    <option value="">-- Chọn phụ tùng từ danh
                                                                                        sách --</option>
                                                                                    <c:forEach var="part" items="${parts}">
                                                                                        <option value="${part.partId}">
                                                                                            ${part.partName} (${part.partCode})
                                                                                            - Tồn kho: ${part.quantity}
                                                                                            ${part.unit}</option>
                                                                                    </c:forEach>
                                                                                </select>
                                                                                <small class="text-muted">Nếu phụ tùng chưa được
                                                                                    khai báo bao giờ, hãy vào <a
                                                                                        href="${pageContext.request.contextPath}/parts">Quản
                                                                                        lý phụ tùng</a> để khai báo
                                                                                    trước.</small>
                                                                            </div>

                                                                            <div class="row">
                                                                                <div class="form-group col-md-6">
                                                                                    <label for="importQty"
                                                                                        class="font-weight-bold text-gray-700">Số
                                                                                        lượng nhập thêm <span
                                                                                            class="text-danger">*</span></label>
                                                                                    <input type="number" id="importQty"
                                                                                        name="quantity" class="form-control"
                                                                                        min="1" required
                                                                                        placeholder="Ví dụ: 10">
                                                                                </div>
                                                                                <div class="form-group col-md-6">
                                                                                    <label for="importSupplier"
                                                                                        class="font-weight-bold text-gray-700">Nhà
                                                                                        cung cấp (Tùy chọn)</label>
                                                                                    <select id="importSupplier"
                                                                                        name="supplierId" class="form-control">
                                                                                        <option value="">-- Không chỉ định --
                                                                                        </option>
                                                                                        <c:forEach var="sup"
                                                                                            items="${suppliers}">
                                                                                            <option value="${sup.supplierId}">
                                                                                                ${sup.supplierName}</option>
                                                                                        </c:forEach>
                                                                                    </select>
                                                                                </div>
                                                                            </div>

                                                                            <div class="form-group">
                                                                                <label for="importNote"
                                                                                    class="font-weight-bold text-gray-700">Ghi
                                                                                    chú / Lý do nhập kho</label>
                                                                                <textarea id="importNote" name="note"
                                                                                    class="form-control" rows="3"
                                                                                    placeholder="Nhập lý do ví dụ: 'Nhập bổ sung lọc nhớt theo hóa đơn mua sắm sê-ri 9028'"></textarea>
                                                                            </div>

                                                                            <div class="text-right">
                                                                                <button type="submit"
                                                                                    class="btn btn-success font-weight-bold px-4 shadow">
                                                                                    <i class="fas fa-check-circle mr-1"></i> Xác
                                                                                    nhận Nhập Kho
                                                                                </button>
                                                                            </div>
                                                                        </form>
                                                                    </div>

                                                                    <!-- TAB 2: EXPORT PART -->
                                                                    <div class="tab-pane fade" id="pills-export" role="tabpanel"
                                                                        aria-labelledby="pills-export-tab">
                                                                        <form method="post"
                                                                            action="${pageContext.request.contextPath}/inventory-transactions">
                                                                            <input type="hidden" name="action"
                                                                                value="export-part">

                                                                            <div class="form-group">
                                                                                <label for="exportPartSelect"
                                                                                    class="font-weight-bold text-gray-700">Chọn
                                                                                    phụ tùng cần xuất <span
                                                                                        class="text-danger">*</span></label>
                                                                                <select id="exportPartSelect" name="partId"
                                                                                    class="form-control select2" required
                                                                                    style="width: 100%;">
                                                                                    <option value="">-- Chọn phụ tùng từ danh
                                                                                        sách --</option>
                                                                                    <c:forEach var="part" items="${parts}">
                                                                                        <c:if test="${part.quantity > 0}">
                                                                                            <option value="${part.partId}">
                                                                                                ${part.partName}
                                                                                                (${part.partCode}) - Hiện có:
                                                                                                ${part.quantity} ${part.unit}
                                                                                            </option>
                                                                                        </c:if>
                                                                                    </c:forEach>
                                                                                </select>
                                                                            </div>

                                                                            <div class="form-group">
                                                                                <label for="exportQty"
                                                                                    class="font-weight-bold text-gray-700">Số
                                                                                    lượng cần xuất <span
                                                                                        class="text-danger">*</span></label>
                                                                                <input type="number" id="exportQty"
                                                                                    name="quantity" class="form-control" min="1"
                                                                                    required placeholder="Ví dụ: 2">
                                                                            </div>

                                                                            <div class="form-group">
                                                                                <label for="exportNote"
                                                                                    class="font-weight-bold text-gray-700">Lý do
                                                                                    xuất phụ tùng / Giao cho ai <span
                                                                                        class="text-danger">*</span></label>
                                                                                <textarea id="exportNote" name="note"
                                                                                    class="form-control" rows="3" required
                                                                                    placeholder="Ví dụ: 'Cấp phát 2 lọc gió Honda cho kỹ thuật viên Nguyễn Văn A đi sửa chữa máy phát Honda Serial HD-123'"></textarea>
                                                                            </div>

                                                                            <div class="text-right">
                                                                                <button type="submit"
                                                                                    class="btn btn-danger font-weight-bold px-4 shadow">
                                                                                    <i class="fas fa-check-circle mr-1"></i> Xác
                                                                                    nhận Xuất Kho
                                                                                </button>
                                                                            </div>
                                                                        </form>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <!-- Pane 2: Generator Transactions -->
                                                            <div class="tab-pane fade" id="generator-tx-pane" role="tabpanel" aria-labelledby="generator-tx-tab">
                                                                <form method="post" action="${pageContext.request.contextPath}/inventory-transactions">
                                                                    <input type="hidden" name="action" value="import-generator">

                                                                    <div class="row">
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genName" class="font-weight-bold text-gray-700">Tên máy phát điện <span class="text-danger">*</span></label>
                                                                            <input type="text" id="genName" name="generatorName" class="form-control" required placeholder="Ví dụ: Cummins Power Generation 150kVA">
                                                                        </div>
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genSerial" class="font-weight-bold text-gray-700">Số Serial <span class="text-danger">*</span></label>
                                                                            <input type="text" id="genSerial" name="serialNumber" class="form-control" required placeholder="Ví dụ: CUM-2026-X999">
                                                                        </div>
                                                                    </div>

                                                                    <div class="row">
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genBrand" class="font-weight-bold text-gray-700">Thương hiệu</label>
                                                                            <input type="text" id="genBrand" name="brand" class="form-control" placeholder="Ví dụ: Cummins, Denyo, Honda">
                                                                        </div>
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genPower" class="font-weight-bold text-gray-700">Công suất (e.g. 10kW, 50kVA)</label>
                                                                            <input type="text" id="genPower" name="powerValue" class="form-control" placeholder="Ví dụ: 150 kVA">
                                                                        </div>
                                                                    </div>

                                                                    <div class="row">
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genFuel" class="font-weight-bold text-gray-700">Loại nhiên liệu</label>
                                                                            <select id="genFuel" name="fuelType" class="form-control">
                                                                                <option value="Diesel">Diesel</option>
                                                                                <option value="Xăng">Xăng</option>
                                                                                <option value="Khác">Khác</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genSupplier" class="font-weight-bold text-gray-700">Nhà cung cấp</label>
                                                                            <select id="genSupplier" name="supplierId" class="form-control">
                                                                                <option value="">-- Không chỉ định --</option>
                                                                                <c:forEach var="sup" items="${suppliers}">
                                                                                    <option value="${sup.supplierId}">${sup.supplierName}</option>
                                                                                </c:forEach>
                                                                            </select>
                                                                        </div>
                                                                    </div>

                                                                    <div class="row">
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genPurchasePrice" class="font-weight-bold text-gray-700">Giá mua (VNĐ)</label>
                                                                            <input type="number" id="genPurchasePrice" name="purchasePrice" class="form-control" min="0" step="0.01" placeholder="Ví dụ: 250000000">
                                                                        </div>
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genRentalPrice" class="font-weight-bold text-gray-700">Giá thuê định kỳ (VNĐ/ngày)</label>
                                                                            <input type="number" id="genRentalPrice" name="rentalPrice" class="form-control" min="0" step="0.01" placeholder="Ví dụ: 1500000">
                                                                        </div>
                                                                    </div>

                                                                    <div class="row">
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genLocation" class="font-weight-bold text-gray-700">Vị trí lưu trữ trong kho</label>
                                                                            <input type="text" id="genLocation" name="location" class="form-control" placeholder="Ví dụ: Khu A - Dãy 2">
                                                                        </div>
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genImportDate" class="font-weight-bold text-gray-700">Ngày nhập kho</label>
                                                                            <input type="date" id="genImportDate" name="importDate" class="form-control">
                                                                        </div>
                                                                    </div>

                                                                    <div class="row">
                                                                        <div class="form-group col-md-6">
                                                                            <label for="genBarcode" class="font-weight-bold text-gray-700">Mã vạch (Tự sinh nếu để trống)</label>
                                                                            <input type="text" id="genBarcode" name="barcode" class="form-control" placeholder="Để trống để tự động tạo từ Serial">
                                                                        </div>
                                                                    </div>

                                                                    <div class="form-group">
                                                                        <label for="genNote" class="font-weight-bold text-gray-700">Ghi chú / Thông tin thêm</label>
                                                                        <textarea id="genNote" name="note" class="form-control" rows="3" placeholder="Ví dụ: Máy mới 100% nhập khẩu từ Nhật Bản, đầy đủ chứng chỉ CO/CQ"></textarea>
                                                                    </div>

                                                                    <div class="text-right">
                                                                        <button type="submit" class="btn btn-primary bg-primary-grad font-weight-bold px-4 shadow">
                                                                            <i class="fas fa-check-circle mr-1"></i> Xác nhận Nhập Máy Phát Điện
                                                                        </button>
                                                                    </div>
                                                                </form>
                                                            </div>
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
                                                                        <fmt:formatDate value="${c.endDate}"
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
                    document.addEventListener("DOMContentLoaded", function() {
                        // 1. Đặt ngày nhập kho mặc định là hôm nay
                        var dateInput = document.getElementById("genImportDate");
                        if (dateInput) {
                            var today = new Date().toISOString().split('T')[0];
                            dateInput.value = today;
                        }

                        // 2. Tự xử lý chuyển đổi Tab ngoài bằng Vanilla JS để tránh xung đột thư viện
                        var tabLinks = document.querySelectorAll('#main-tx-tabs .nav-link');
                        tabLinks.forEach(function(link) {
                            link.addEventListener('click', function(e) {
                                e.preventDefault();
                                
                                // Hủy kích hoạt tất cả các tab links
                                tabLinks.forEach(function(l) {
                                    l.classList.remove('active');
                                    l.setAttribute('aria-selected', 'false');
                                });
                                
                                // Kích hoạt tab link hiện tại
                                this.classList.add('active');
                                this.setAttribute('aria-selected', 'true');
                                
                                // Ẩn tất cả các tab panes ngoài
                                var panes = document.querySelectorAll('#main-tx-tabsContent > .tab-pane');
                                panes.forEach(function(pane) {
                                    pane.classList.remove('show', 'active');
                                });
                                
                                // Hiển thị tab pane tương ứng
                                var targetId = this.getAttribute('href');
                                var targetPane = document.querySelector(targetId);
                                if (targetPane) {
                                    targetPane.classList.add('show', 'active');
                                }
                                
                                // Cập nhật URL Hash để giữ lại tab khi tải lại
                                if (history.pushState) {
                                    history.pushState(null, null, targetId);
                                } else {
                                    window.location.hash = targetId;
                                }
                            });
                        });

                        // 3. Tự xử lý chuyển đổi Pills con (Phần phụ tùng) bằng Vanilla JS
                        var pillLinks = document.querySelectorAll('#pills-tab .nav-link');
                        pillLinks.forEach(function(link) {
                            link.addEventListener('click', function(e) {
                                e.preventDefault();
                                
                                pillLinks.forEach(function(l) {
                                    l.classList.remove('active');
                                    l.setAttribute('aria-selected', 'false');
                                });
                                
                                this.classList.add('active');
                                this.setAttribute('aria-selected', 'true');
                                
                                var panes = document.querySelectorAll('#pills-tabContent > .tab-pane');
                                panes.forEach(function(pane) {
                                    pane.classList.remove('show', 'active');
                                });
                                
                                var targetId = this.getAttribute('href');
                                var targetPane = document.querySelector(targetId);
                                if (targetPane) {
                                    targetPane.classList.add('show', 'active');
                                }
                            });
                        });

                        // 4. Kích hoạt tab dựa trên Hash trên URL khi tải trang
                        var hash = window.location.hash;
                        if (hash) {
                            var initialLink = document.querySelector('#main-tx-tabs .nav-link[href="' + hash + '"]');
                            if (initialLink) {
                                initialLink.click();
                            }
                        }

                        // 5. Kích hoạt tab tự động dựa trên kết quả phản hồi (Query Parameters)
                        var urlParams = new URLSearchParams(window.location.search);
                        var successParam = urlParams.get('success');
                        var errorParam = urlParams.get('error');
                        
                        if (successParam === 'generator_import_success' || 
                            errorParam === 'serial_exists' || 
                            errorParam === 'generator_import_failed') {
                            
                            var genLink = document.getElementById('generator-tx-tab');
                            if (genLink) {
                                genLink.click();
                            }
                        } else if (successParam === 'import_success' || 
                                   successParam === 'export_success' || 
                                   errorParam === 'invalid_quantity' || 
                                   errorParam === 'insufficient_stock') {
                            
                            var partsLink = document.getElementById('parts-tx-tab');
                            if (partsLink) {
                                partsLink.click();
                            }
                        }
                    });
                </script>
            </body>

            </html>