<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách kho quản lý | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .warehouse-card {
            border-left: .25rem solid #1cc88a; /* Green success accent */
            transition: all 0.3s ease;
        }
        .warehouse-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.1) !important;
        }
        .stat-box {
            border-radius: 8px;
            padding: 12px;
            text-align: center;
            transition: background-color 0.2s;
            cursor: pointer;
            height: 100%;
        }
        .stat-box:hover {
            filter: brightness(0.95);
            text-decoration: none;
        }
        .stat-box-primary {
            background-color: #eaecf4;
            color: #4e73df;
        }
        .stat-box-info {
            background-color: #ddf3f5;
            color: #36b9cc;
        }
        .stat-box-warning {
            background-color: #fdf5e2;
            color: #f6c23e;
        }
        .stat-box-danger {
            background-color: #fadbd8;
            color: #e74a3b;
        }
        .stat-box-success {
            background-color: #d4efdf;
            color: #28b463;
        }
        .contact-info p {
            margin-bottom: 0.3rem;
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
                    <div>
                        <h1 class="h3 mb-0 text-gray-800">Kho máy phát điện đang quản lý</h1>
                        <p class="text-muted mb-0 small">Xem thông tin chi tiết, trạng thái tồn kho và thông tin liên hệ thủ kho các kho thuộc phạm vi quản lý của bạn.</p>
                    </div>
                </div>

                <!-- Error alert if any -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger shadow-sm">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <c:if test="${param.success eq 'assigned'}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm">
                        <i class="fas fa-check-circle"></i> Phân công nhân sự kho hàng thành công.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'warehouse_manager_assigned'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                        <i class="fas fa-exclamation-circle"></i> Nhân viên Quản lý kho (Warehouse Manager) này đã được gán quản lý một kho hoạt động khác!
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'permission_denied'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                        <i class="fas fa-exclamation-circle"></i> Bạn không có quyền phân công nhân sự cho kho hàng này.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'invalid_warehouse'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                        <i class="fas fa-exclamation-circle"></i> Không tìm thấy thông tin kho hàng hợp lệ.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'system_error'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                        <i class="fas fa-exclamation-circle"></i> Lỗi hệ thống. Vui lòng thử lại sau.
                        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                    </div>
                </c:if>

                <!-- Search Filter Form -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/warehouses" class="form-inline">
                            <div class="input-group w-100" style="max-width: 500px;">
                                <input type="text" name="q" class="form-control bg-light border-0 small" 
                                       placeholder="Tìm kiếm theo tên kho hoặc địa chỉ..." value="${q}">
                                <div class="input-group-append">
                                    <button class="btn btn-primary" type="submit">
                                        <i class="fas fa-search fa-sm"></i> Tìm kiếm
                                    </button>
                                </div>
                                <c:if test="${not empty q}">
                                    <a href="${pageContext.request.contextPath}/warehouses" class="btn btn-link text-secondary ml-2">Xóa tìm kiếm</a>
                                </c:if>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Warehouse Grid -->
                <div class="row">
                    <c:choose>
                        <c:when test="${empty warehouses}">
                            <div class="col-12">
                                <div class="card shadow-sm border-left-warning py-3">
                                    <div class="card-body text-center">
                                        <i class="fas fa-warehouse fa-3x text-gray-300 mb-3"></i>
                                        <h5 class="text-gray-800 font-weight-bold">Không tìm thấy kho nào!</h5>
                                        <p class="text-muted mb-0">Bạn chưa được phân quyền quản lý kho nào hoặc không tìm thấy kho phù hợp với từ khóa.</p>
                                    </div>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="w" items="${warehouses}">
                                <div class="col-xl-6 col-lg-12 mb-4">
                                    <div class="card warehouse-card shadow h-100">
                                        
                                        <!-- Card Header -->
                                        <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between bg-white border-bottom-0">
                                            <h5 class="m-0 font-weight-bold text-success">
                                                <i class="fas fa-warehouse mr-2"></i> ${w.warehouseName}
                                            </h5>
                                            <c:choose>
                                                <c:when test="${w.status eq 'ACTIVE'}">
                                                    <span class="badge badge-pill badge-success">Đang hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-pill badge-secondary">Ngưng hoạt động</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <!-- Card Body -->
                                        <div class="card-body">
                                            <div class="row">
                                                <!-- Left side: Information -->
                                                <div class="col-md-7 mb-3 mb-md-0 border-right">
                                                    <p class="mb-2"><strong class="text-gray-800">Địa chỉ:</strong> ${w.address}</p>
                                                    <p class="mb-3 text-xs text-muted">
                                                        <strong>Ngày tạo:</strong> 
                                                        <fmt:formatDate value="${w.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </p>

                                                    <!-- Warehouse Manager contact details -->
                                                    <div class="p-3 bg-light rounded contact-info">
                                                        <h6 class="font-weight-bold text-gray-800 text-xs text-uppercase mb-2">
                                                            <i class="fas fa-user-tie text-info mr-1"></i> Thủ kho phụ trách
                                                        </h6>
                                                        <c:choose>
                                                            <c:when test="${not empty w.warehouseManagerName}">
                                                                <h6 class="font-weight-bold text-dark mb-1">${w.warehouseManagerName}</h6>
                                                                <p class="small text-muted mb-1">
                                                                    <i class="fas fa-phone fa-fw mr-1"></i> ${not empty w.warehouseManagerPhone ? w.warehouseManagerPhone : 'N/A'}
                                                                </p>
                                                                <p class="small text-muted mb-0">
                                                                    <i class="fas fa-envelope fa-fw mr-1"></i> ${not empty w.warehouseManagerEmail ? w.warehouseManagerEmail : 'N/A'}
                                                                </p>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <p class="text-danger small mb-0 font-weight-bold">
                                                                    <i class="fas fa-exclamation-triangle mr-1"></i> Chưa phân công thủ kho
                                                                </p>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>

                                                    <!-- Staff and Sellers list -->
                                                    <div class="mt-3 p-3 bg-light rounded border-left-primary">
                                                        <h6 class="font-weight-bold text-gray-800 text-xs text-uppercase mb-2">
                                                            <i class="fas fa-users text-primary mr-1"></i> Nhân sự kho hàng
                                                        </h6>
                                                        <div class="small mb-2">
                                                            <strong class="text-gray-700">Kỹ thuật (Staff):</strong>
                                                            <c:set var="hasStaff" value="false"/>
                                                            <c:forEach var="s" items="${allStaff}">
                                                                <c:if test="${s.warehouseId eq w.warehouseId}">
                                                                    <span class="badge badge-info border mr-1 px-2 py-1"><i class="fas fa-user-cog mr-1"></i>${s.fullName}</span>
                                                                    <c:set var="hasStaff" value="true"/>
                                                                </c:if>
                                                            </c:forEach>
                                                            <c:if test="${not hasStaff}">
                                                                <span class="text-muted font-italic">Chưa có</span>
                                                            </c:if>
                                                        </div>
                                                        <div class="small">
                                                            <strong class="text-gray-700">Bán hàng (Seller):</strong>
                                                            <c:set var="hasSeller" value="false"/>
                                                            <c:forEach var="sel" items="${allSellers}">
                                                                <c:if test="${sel.warehouseId eq w.warehouseId}">
                                                                    <span class="badge badge-success border mr-1 px-2 py-1"><i class="fas fa-store mr-1"></i>${sel.fullName}</span>
                                                                    <c:set var="hasSeller" value="true"/>
                                                                </c:if>
                                                            </c:forEach>
                                                            <c:if test="${not hasSeller}">
                                                                <span class="text-muted font-italic">Chưa có</span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Right side: Quick stats boxes -->
                                                <div class="col-md-5 d-flex flex-column justify-content-center">
                                                    <div class="row">
                                                        <!-- Generators Count -->
                                                        <div class="col-12">
                                                            <a href="${pageContext.request.contextPath}/generators?warehouseId=${w.warehouseId}" 
                                                               class="stat-box stat-box-primary d-flex flex-column align-items-center justify-content-center shadow-sm py-4">
                                                                <i class="fas fa-bolt fa-3x mb-2"></i>
                                                                <span class="h4 mb-0 font-weight-bold">${w.totalGenerators} mẫu máy</span>
                                                                <span class="text-xs text-gray-800 font-weight-bold">Máy khả dụng: <strong>${w.totalBarcodes}</strong></span>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Card Footer -->
                                        <div class="card-footer bg-white border-top-0 d-flex justify-content-end pb-3">
                                            <button type="button" class="btn btn-sm btn-warning mr-2 shadow-sm font-weight-bold text-dark"
                                                    onclick="openPersonnelModal(${w.warehouseId}, '${w.warehouseName.replace("'", "\\'")}', ${w.warehouseManagerId != null ? w.warehouseManagerId : 0})">
                                                <i class="fas fa-users-cog mr-1"></i> Phân công nhân sự
                                            </button>
                                            <a href="${pageContext.request.contextPath}/generators?warehouseId=${w.warehouseId}" class="btn btn-sm btn-primary mr-2 shadow-sm">
                                                <i class="fas fa-bolt mr-1"></i> Xem máy phát
                                            </a>
                                            <a href="${pageContext.request.contextPath}/stock-transfers" class="btn btn-sm btn-success shadow-sm">
                                                <i class="fas fa-exchange-alt mr-1"></i> Xem điều chuyển
                                            </a>
                                        </div>

                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>
        <%@ include file="/views/layout/footer.jsp" %>
    </div>
</div>

<%-- Personnel Assignment Modal --%>
<div class="modal fade" id="personnelModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content border-left-warning shadow">
            <form id="personnelForm" method="post" action="${pageContext.request.contextPath}/warehouses">
                <input type="hidden" name="action" value="assignPersonnel">
                <input type="hidden" id="modalWarehouseId" name="warehouseId">
                
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title font-weight-bold" id="personnelModalTitle"><i class="fas fa-users-cog mr-2"></i>Phân công nhân sự</h5>
                    <button type="button" class="close text-dark" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="warehouseManagerId" class="font-weight-bold text-gray-800">Thủ kho phụ trách (Warehouse Manager)</label>
                        <select id="warehouseManagerId" name="warehouseManagerId" class="form-control">
                            <!-- Options filled dynamically -->
                        </select>
                        <small class="form-text text-muted">Mỗi Warehouse Manager chỉ có thể quản lý tối đa 1 kho hoạt động.</small>
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold text-gray-800">Phân công Nhân viên Kỹ thuật (STAFF)</label>
                        <div id="staffContainer" class="border rounded p-3" style="max-height: 150px; overflow-y: auto; background-color: #f8f9fc;">
                            <!-- Staff checkboxes filled dynamically -->
                        </div>
                        <small class="form-text text-muted">Chọn nhân viên kỹ thuật làm việc tại kho này.</small>
                    </div>

                    <div class="form-group mb-0">
                        <label class="font-weight-bold text-gray-800">Phân công Nhân viên Bán hàng (SELLER)</label>
                        <div id="sellerContainer" class="border rounded p-3" style="max-height: 150px; overflow-y: auto; background-color: #f8f9fc;">
                            <!-- Seller checkboxes filled dynamically -->
                        </div>
                        <small class="form-text text-muted">Chọn nhân viên bán hàng làm việc tại kho này.</small>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary shadow-sm" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning text-dark font-weight-bold shadow-sm">
                        <i class="fas fa-save mr-1"></i> Lưu phân công
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>

<script>
    const activeManagerAssignments = [
        <c:forEach var="a" items="${activeManagerAssignments}" varStatus="loop">
            { warehouseId: ${a.warehouseId}, managerId: ${a.warehouseManagerId} }${not loop.last ? ',' : ''}
        </c:forEach>
    ];

    function isManagerAssignedToOtherWarehouse(managerId, currentWarehouseId) {
        return activeManagerAssignments.some(function (assignment) {
            return assignment.managerId === managerId && assignment.warehouseId !== currentWarehouseId;
        });
    }

    const allWarehouseManagers = [
        <c:forEach var="wm" items="${warehouseManagers}" varStatus="loop">
            { id: ${wm.userId}, name: '${wm.fullName.replace("'", "\\'")} (${wm.username.replace("'", "\\'")})' }${not loop.last ? ',' : ''}
        </c:forEach>
    ];

    const allStaff = [
        <c:forEach var="s" items="${allStaff}" varStatus="loop">
            { id: ${s.userId}, name: '${s.fullName.replace("'", "\\'")} (${s.username.replace("'", "\\'")})', warehouseId: ${s.warehouseId != null ? s.warehouseId : 'null'} }${not loop.last ? ',' : ''}
        </c:forEach>
    ];

    const allSellers = [
        <c:forEach var="sel" items="${allSellers}" varStatus="loop">
            { id: ${sel.userId}, name: '${sel.fullName.replace("'", "\\'")} (${sel.username.replace("'", "\\'")})', warehouseId: ${sel.warehouseId != null ? sel.warehouseId : 'null'} }${not loop.last ? ',' : ''}
        </c:forEach>
    ];

    function openPersonnelModal(warehouseId, warehouseName, warehouseManagerId) {
        $('#modalWarehouseId').val(warehouseId);
        $('#personnelModalTitle').html('<i class="fas fa-users-cog mr-2"></i>Phân công nhân sự - ' + warehouseName);

        // 1. Build Warehouse Manager dropdown
        const select = $('#warehouseManagerId');
        select.empty();
        select.append('<option value="">-- Chưa phân công --</option>');
        allWarehouseManagers.forEach(function (wm) {
            if (!isManagerAssignedToOtherWarehouse(wm.id, warehouseId)) {
                select.append('<option value="' + wm.id + '">' + wm.name + '</option>');
            }
        });
        select.val(warehouseManagerId > 0 ? warehouseManagerId : '');

        // 2. Build Staff checkboxes
        const staffContainer = $('#staffContainer');
        staffContainer.empty();
        let hasStaff = false;
        allStaff.forEach(function (s) {
            if (s.warehouseId === null || s.warehouseId === warehouseId) {
                const checked = s.warehouseId === warehouseId ? 'checked' : '';
                staffContainer.append(
                    '<div class="form-check mb-1">' +
                    '<input class="form-check-input" type="checkbox" name="staffIds" value="' + s.id + '" id="staff_' + s.id + '" ' + checked + '>' +
                    '<label class="form-check-label ml-1 text-gray-800" for="staff_' + s.id + '">' + s.name + '</label>' +
                    '</div>'
                );
                hasStaff = true;
            }
        });
        if (!hasStaff) {
            staffContainer.html('<p class="text-muted small italic mb-0">Không có nhân viên STAFF khả dụng.</p>');
        }

        // 3. Build Seller checkboxes
        const sellerContainer = $('#sellerContainer');
        sellerContainer.empty();
        let hasSeller = false;
        allSellers.forEach(function (sel) {
            if (sel.warehouseId === null || sel.warehouseId === warehouseId) {
                const checked = sel.warehouseId === warehouseId ? 'checked' : '';
                sellerContainer.append(
                    '<div class="form-check mb-1">' +
                    '<input class="form-check-input" type="checkbox" name="sellerIds" value="' + sel.id + '" id="seller_' + sel.id + '" ' + checked + '>' +
                    '<label class="form-check-label ml-1 text-gray-800" for="seller_' + sel.id + '">' + sel.name + '</label>' +
                    '</div>'
                );
                hasSeller = true;
            }
        });
        if (!hasSeller) {
            sellerContainer.html('<p class="text-muted small italic mb-0">Không có nhân viên SELLER khả dụng.</p>');
        }

        $('#personnelModal').modal('show');
    }
</script>
</body>
</html>
