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
                                                </div>

                                                <!-- Right side: Quick stats boxes -->
                                                <div class="col-md-5 d-flex flex-column justify-content-between">
                                                    <div class="row h-100">
                                                        <!-- Generators Count -->
                                                        <div class="col-6 mb-2">
                                                            <a href="${pageContext.request.contextPath}/generators?warehouseId=${w.warehouseId}" 
                                                               class="stat-box stat-box-primary d-flex flex-column align-items-center justify-content-center shadow-sm">
                                                                <i class="fas fa-bolt fa-2x mb-2"></i>
                                                                <span class="h5 mb-0 font-weight-bold">${w.totalGenerators}</span>
                                                                <span class="text-xs text-gray-800">Máy phát điện</span>
                                                            </a>
                                                        </div>

                                                        <!-- Parts Count -->
                                                        <div class="col-6 mb-2">
                                                            <a href="${pageContext.request.contextPath}/parts?warehouseId=${w.warehouseId}" 
                                                               class="stat-box stat-box-info d-flex flex-column align-items-center justify-content-center shadow-sm">
                                                                <i class="fas fa-cogs fa-2x mb-2"></i>
                                                                <span class="h5 mb-0 font-weight-bold">${w.totalParts}</span>
                                                                <span class="text-xs text-gray-800">Phụ tùng</span>
                                                            </a>
                                                        </div>

                                                        <!-- Low Stock Warnings -->
                                                        <div class="col-12 mt-1">
                                                            <c:choose>
                                                                <c:when test="${w.lowStockParts > 0}">
                                                                    <a href="${pageContext.request.contextPath}/parts?warehouseId=${w.warehouseId}" 
                                                                       class="stat-box stat-box-danger d-flex align-items-center justify-content-around shadow-sm">
                                                                        <div class="text-left py-1">
                                                                            <span class="h5 mb-0 font-weight-bold d-block">${w.lowStockParts}</span>
                                                                            <span class="text-xs text-gray-900 font-weight-bold">Cảnh báo thiếu hụt</span>
                                                                        </div>
                                                                        <i class="fas fa-exclamation-triangle fa-2x"></i>
                                                                    </a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="stat-box stat-box-success d-flex align-items-center justify-content-around shadow-sm" style="cursor: default;">
                                                                        <div class="text-left py-1">
                                                                            <span class="h6 mb-0 font-weight-bold d-block text-success">An toàn</span>
                                                                            <span class="text-xs text-muted">Đủ mức tồn kho tối thiểu</span>
                                                                        </div>
                                                                        <i class="fas fa-check-circle fa-2x"></i>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Card Footer -->
                                        <div class="card-footer bg-white border-top-0 d-flex justify-content-end pb-3">
                                            <a href="${pageContext.request.contextPath}/generators?warehouseId=${w.warehouseId}" class="btn btn-sm btn-primary mr-2 shadow-sm">
                                                <i class="fas fa-bolt mr-1"></i> Xem máy phát
                                            </a>
                                            <a href="${pageContext.request.contextPath}/parts?warehouseId=${w.warehouseId}" class="btn btn-sm btn-info mr-2 shadow-sm">
                                                <i class="fas fa-cogs mr-1"></i> Xem phụ tùng
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
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
</body>
</html>
