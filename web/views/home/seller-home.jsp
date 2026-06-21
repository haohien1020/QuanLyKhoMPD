<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SELLER Home | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .home-hero {
            background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%);
            border-radius: 12px;
            color: #fff;
        }
        .home-hero .hero-title { color: #fff; }
        .home-hero .hero-sub { color: rgba(255,255,255,0.85); }
        .home-hero .warehouse-badge {
            background: rgba(255,255,255,0.18);
            border: 1px solid rgba(255,255,255,0.35);
            border-radius: 8px;
            padding: 8px 16px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.88rem;
        }
        .btn-create-contract {
            background: #fff;
            color: #1e3a5f;
            font-weight: 700;
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            font-size: 1rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            transition: transform 0.15s, box-shadow 0.15s;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            width: 300px;
            justify-content: flex-start;
            white-space: nowrap;
        }
        .btn-create-contract:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
            color: #1e3a5f;
            text-decoration: none;
        }
        .btn-create-contract .btn-icon {
            background: #2563eb;
            color: #fff;
            border-radius: 50%;
            width: 32px; height: 32px;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 0.9rem;
            flex-shrink: 0;
        }
        .workflow-card { min-height: 160px; }
        .workflow-card .card-body { display:flex; flex-direction:column; }
        .workflow-actions { margin-top:auto; }
        .stat-card-number { font-size: 2rem; font-weight: 800; line-height: 1; }
        .alert-no-warehouse {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            border-radius: 8px;
            padding: 16px 20px;
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

                <%-- Hero Section --%>
                <div class="home-hero shadow p-4 mb-4">
                    <div class="d-sm-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-xs font-weight-bold text-uppercase mb-2" style="color:rgba(255,255,255,0.7);letter-spacing:1px">
                                SELLER Workspace
                            </div>
                            <h1 class="h3 hero-title mb-2">Xin chào, ${sessionScope.currentUser.fullName}! 👋</h1>
                            <p class="hero-sub mb-3">Tư vấn khách hàng, lập hợp đồng thuê máy phát điện.</p>
                            <c:choose>
                                <c:when test="${not empty sellerWarehouse}">
                                    <span class="warehouse-badge">
                                        <i class="fas fa-warehouse"></i>
                                        Kho của bạn: <strong>${sellerWarehouse.warehouseName}</strong>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="warehouse-badge" style="border-color:rgba(255,200,0,0.6);background:rgba(255,200,0,0.2)">
                                        <i class="fas fa-exclamation-triangle"></i>
                                        Chưa được gán kho — Liên hệ Thủ kho
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="text-sm-right mt-4 mt-sm-0">
                            <div class="mb-2">
                                <a href="${pageContext.request.contextPath}/customers?action=create"
                                   class="btn-create-contract" id="btn-new-customer">
                                    <span class="btn-icon" style="background: #28a745;"><i class="fas fa-user-plus"></i></span>
                                    Thêm khách hàng mới
                                </a>
                            </div>
                            <c:if test="${not empty sellerWarehouse}">
                                <div class="mb-2">
                                    <a href="${pageContext.request.contextPath}/seller/contracts/create"
                                       class="btn-create-contract" id="btn-new-contract">
                                        <span class="btn-icon"><i class="fas fa-plus"></i></span>
                                        Lập hợp đồng thuê mới
                                    </a>
                                </div>
                            </c:if>
                            <div class="small mt-3" style="color:rgba(255,255,255,0.7)">
                                Role: ${sessionScope.currentUser.roleName}
                            </div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty homeError}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${homeError}</div>
                </c:if>

                <c:if test="${empty sellerWarehouse}">
                    <div class="alert-no-warehouse mb-4">
                        <strong><i class="fas fa-exclamation-triangle text-warning"></i> Tài khoản chưa được gán kho!</strong>
                        <p class="mb-0 mt-1 text-muted small">Bạn cần được Warehouse Manager gán vào một kho để có thể lập hợp đồng thuê. Vui lòng liên hệ người quản lý kho của bạn.</p>
                    </div>
                </c:if>

                <%-- Stats Row --%>
                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Tổng hợp đồng</div>
                                <div class="stat-card-number text-gray-800 mb-1">${myTotalContracts}</div>
                                <div class="small text-muted">Tất cả hợp đồng cá nhân</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Chờ duyệt</div>
                                <div class="stat-card-number text-gray-800 mb-1">${myPendingContracts}</div>
                                <div class="small text-muted">Đang chờ Thủ kho duyệt</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-danger shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Đang thuê</div>
                                <div class="stat-card-number text-gray-800 mb-1">${myActiveContracts}</div>
                                <div class="small text-muted">Hợp đồng đang thực hiện</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Máy sẵn sàng</div>
                                <div class="stat-card-number text-gray-800 mb-1">${availableGenerators}</div>
                                <div class="small text-muted">
                                    <c:choose>
                                        <c:when test="${not empty sellerWarehouse}">Máy IN_STOCK tại kho của bạn</c:when>
                                        <c:otherwise>Chưa có kho được gán</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Workflow Cards --%>
                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-file-signature text-success"></i> Lập Hợp đồng Thuê mới</h6>
                                <p class="small text-muted">Lập hợp đồng thuê máy phát điện ngay cho khách hàng. Chỉ hiển thị máy sẵn sàng trong kho của bạn.</p>
                                <div class="workflow-actions">
                                    <c:choose>
                                        <c:when test="${not empty sellerWarehouse}">
                                            <a href="${pageContext.request.contextPath}/seller/contracts/create"
                                               class="btn btn-sm btn-success">
                                                <i class="fas fa-plus"></i> Lập hợp đồng mới
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-sm btn-secondary" disabled title="Chưa được gán kho">
                                                <i class="fas fa-lock"></i> Lập hợp đồng mới
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-file-contract text-warning"></i> Quản lý &amp; Cập nhật Hợp đồng</h6>
                                <p class="small text-muted">Xem danh sách hợp đồng thuê, theo dõi trạng thái và chỉnh sửa hợp đồng đang xử lý.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/seller/contracts" class="btn btn-sm btn-warning">Quản lý hợp đồng thuê</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-users text-primary"></i> Khách hàng &amp; Đăng ký</h6>
                                <p class="small text-muted">Quản lý hồ sơ khách hàng, cập nhật thông tin và tạo yêu cầu đăng ký tài khoản khách hàng mới.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/customers" class="btn btn-sm btn-primary">Danh sách khách hàng</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card workflow-card shadow h-100">
                            <div class="card-body">
                                <h6 class="font-weight-bold text-gray-900"><i class="fas fa-bolt text-info"></i> Máy phát điện sẵn có</h6>
                                <p class="small text-muted">Tra cứu danh sách máy phát điện có sẵn tại kho của bạn để phục vụ tư vấn khách hàng.</p>
                                <div class="workflow-actions">
                                    <a href="${pageContext.request.contextPath}/generators" class="btn btn-sm btn-info">Tra cứu máy phát</a>
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
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
</body>
</html>
