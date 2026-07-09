<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách yêu cầu chờ duyệt | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .request-card {
            border-left: 4px solid #4e73df;
            transition: all 0.2s ease-in-out;
        }
        .request-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
        }
        .request-card.transfer { border-left-color: #36b9cc; }
        .request-card.purchase { border-left-color: #f6c23e; }
        .request-card.part { border-left-color: #1cc88a; }
        
        .badge-status {
            font-size: 0.8rem;
            padding: 0.35em 0.65em;
            border-radius: 30px;
        }
        .tab-icon {
            font-size: 1.1rem;
            margin-right: 0.5rem;
        }
        .nav-pills .nav-link {
            border-radius: 8px;
            font-weight: 600;
            color: #6e707e;
            padding: 0.6rem 1.2rem;
            transition: all 0.2s;
        }
        .nav-pills .nav-link.active {
            background-color: #4e73df;
            color: #fff;
            box-shadow: 0 4px 6px rgba(78, 115, 223, 0.2);
        }
        .nav-pills .nav-link:hover:not(.active) {
            background-color: #eaecf4;
            color: #2e59d9;
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

                <!-- Page Header -->
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-900 font-weight-bold">
                        <i class="fas fa-tasks text-primary mr-2"></i>Hàng đợi yêu cầu chờ duyệt
                    </h1>
                </div>

                <!-- Toast Alerts -->
                <c:if test="${param.success eq 'approved'}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success" role="alert">
                        <i class="fas fa-check-circle mr-2"></i> <strong>Thành công!</strong> Đã phê duyệt yêu cầu thành công.
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                <c:if test="${param.success eq 'rejected'}">
                    <div class="alert alert-warning alert-dismissible fade show shadow-sm border-left-warning" role="alert">
                        <i class="fas fa-info-circle mr-2"></i> <strong>Đã từ chối!</strong> Đã từ chối và hủy bỏ yêu cầu.
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'insufficient_stock'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger" role="alert">
                        <i class="fas fa-exclamation-triangle mr-2"></i> <strong>Lỗi tồn kho!</strong> Không đủ số lượng phụ tùng có sẵn tại kho nguồn để đáp ứng yêu cầu cấp phát.
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                <c:if test="${not empty param.error && param.error ne 'insufficient_stock'}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger" role="alert">
                        <i class="fas fa-times-circle mr-2"></i> <strong>Lỗi:</strong> ${param.message != null ? param.message : "Đã xảy ra lỗi trong quá trình xử lý phê duyệt."}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>

                <!-- Unified Pending Requests Hub -->
                <div class="row">
                    <div class="col-12">
                        <!-- Navigation Tabs (Pills style) -->
                        <ul class="nav nav-pills mb-4 p-2 bg-white rounded shadow-sm border" id="requestTabs" role="tablist">
                            <li class="nav-item mr-2">
                                <a class="nav-link active" id="transfer-tab" data-toggle="pill" href="#transfer-pane" role="tab" aria-controls="transfer-pane" aria-selected="true">
                                    <i class="fas fa-exchange-alt tab-icon"></i>Điều chuyển kho
                                    <span class="badge badge-danger badge-counter ml-1">${pendingTransfers.size()}</span>
                                </a>
                            </li>
                            <li class="nav-item mr-2">
                                <a class="nav-link" id="part-tab" data-toggle="pill" href="#part-pane" role="tab" aria-controls="part-pane" aria-selected="false">
                                    <i class="fas fa-tools tab-icon"></i>Cấp phát phụ tùng
                                    <span class="badge badge-success badge-counter ml-1">${pendingParts.size()}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="purchase-tab" data-toggle="pill" href="#purchase-pane" role="tab" aria-controls="purchase-pane" aria-selected="false">
                                    <i class="fas fa-shopping-cart tab-icon"></i>Yêu cầu mua sắm
                                    <span class="badge badge-warning badge-counter ml-1">${pendingPurchases.size()}</span>
                                </a>
                            </li>
                        </ul>

                        <!-- Tab Content -->
                        <div class="tab-content" id="requestTabContent">
                            
                            <!-- TAB 1: STOCK TRANSFERS -->
                            <div class="tab-pane fade show active" id="transfer-pane" role="tabpanel" aria-labelledby="transfer-tab">
                                <c:choose>
                                    <c:when test="${empty pendingTransfers}">
                                        <div class="card shadow-sm border-0 py-5 text-center bg-white rounded">
                                            <div class="card-body">
                                                <i class="fas fa-exchange-alt fa-3x text-muted mb-3"></i>
                                                <p class="text-gray-500 font-weight-bold mb-0">Không có yêu cầu điều chuyển kho nào đang chờ duyệt.</p>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="st" items="${pendingTransfers}">
                                            <div class="card request-card transfer shadow-sm mb-3 bg-white">
                                                <div class="card-body">
                                                    <div class="d-md-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                                                        <div>
                                                            <h5 class="font-weight-bold text-gray-900 mb-1">Yêu cầu Điều chuyển TF-${st.transferId}</h5>
                                                            <span class="small text-muted"><i class="far fa-clock mr-1"></i>Ngày tạo: <fmt:formatDate value="${st.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                                        </div>
                                                        <div class="text-md-right mt-2 mt-md-0">
                                                            <span class="badge-status bg-info text-white font-weight-bold">Chờ Manager duyệt</span>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="row mb-3">
                                                        <div class="col-md-4">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Kho gửi</div>
                                                            <div class="text-gray-800 font-weight-bold"><i class="fas fa-arrow-circle-up text-danger mr-1"></i>${warehouseMap[st.fromWarehouseId]}</div>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Kho nhận</div>
                                                            <div class="text-gray-800 font-weight-bold"><i class="fas fa-arrow-circle-down text-success mr-1"></i>${warehouseMap[st.toWarehouseId]}</div>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Người yêu cầu</div>
                                                            <div class="text-gray-800">${userMap[st.createdBy]}</div>
                                                        </div>
                                                    </div>

                                                    <!-- Details List of Transfer -->
                                                    <div class="table-responsive mb-3 bg-light p-2 rounded">
                                                        <table class="table table-bordered table-sm mb-0 bg-white">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th>Loại</th>
                                                                    <th>Tên sản phẩm</th>
                                                                    <th class="text-center" style="width: 100px;">Số lượng</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:forEach var="det" items="${transferDetailsMap[st.transferId]}">
                                                                    <tr>
                                                                        <td>
                                                                            <span class="badge ${det.itemType eq 'GENERATOR' ? 'badge-primary' : 'badge-success'}">
                                                                                ${det.itemType eq 'GENERATOR' ? 'Máy phát điện' : 'Phụ tùng'}
                                                                            </span>
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${det.itemType eq 'GENERATOR'}">
                                                                                    ${genMap[det.generatorId].generatorName} (Mẫu: [${genMap[det.generatorId].brand}] ${genMap[det.generatorId].powerValue})
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    ${partMap[det.partId].partName} (Mã: ${partMap[det.partId].partCode})
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td class="text-center font-weight-bold text-gray-900">${det.quantity}</td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </tbody>
                                                        </table>
                                                    </div>

                                                    <!-- Action buttons -->
                                                    <div class="text-right">
                                                        <form method="post" action="${pageContext.request.contextPath}/manager/pending-requests/reject" class="d-inline">
                                                            <input type="hidden" name="type" value="transfer">
                                                            <input type="hidden" name="id" value="${st.transferId}">
                                                            <button type="submit" class="btn btn-outline-danger btn-sm font-weight-bold mr-2" onclick="return confirm('Bạn chắc chắn muốn Từ chối yêu cầu điều chuyển TF-${st.transferId}?')">
                                                                <i class="fas fa-times-circle mr-1"></i>Từ chối
                                                            </button>
                                                        </form>
                                                        <form method="post" action="${pageContext.request.contextPath}/manager/pending-requests/approve" class="d-inline">
                                                            <input type="hidden" name="type" value="transfer">
                                                            <input type="hidden" name="id" value="${st.transferId}">
                                                            <button type="submit" class="btn btn-primary btn-sm font-weight-bold" onclick="return confirm('Bạn chắc chắn muốn Phê duyệt yêu cầu điều chuyển TF-${st.transferId}?')">
                                                                <i class="fas fa-check-circle mr-1"></i>Phê duyệt
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- TAB 2: PART REQUESTS -->
                            <div class="tab-pane fade" id="part-pane" role="tabpanel" aria-labelledby="part-tab">
                                <c:choose>
                                    <c:when test="${empty pendingParts}">
                                        <div class="card shadow-sm border-0 py-5 text-center bg-white rounded">
                                            <div class="card-body">
                                                <i class="fas fa-tools fa-3x text-muted mb-3"></i>
                                                <p class="text-gray-500 font-weight-bold mb-0">Không có yêu cầu cấp phát phụ tùng nào đang chờ duyệt.</p>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="pt" items="${pendingParts}">
                                            <div class="card request-card part shadow-sm mb-3 bg-white">
                                                <div class="card-body">
                                                    <div class="d-md-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                                                        <div>
                                                            <h5 class="font-weight-bold text-gray-900 mb-1">Yêu cầu Cấp phát Phụ tùng PR-${pt.requestId}</h5>
                                                            <span class="small text-muted"><i class="far fa-clock mr-1"></i>Ngày tạo: <fmt:formatDate value="${pt.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                                        </div>
                                                        <div class="text-md-right mt-2 mt-md-0">
                                                            <span class="badge-status bg-success text-white font-weight-bold">Chờ phê duyệt</span>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="row mb-3">
                                                        <div class="col-md-3">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Kho yêu cầu</div>
                                                            <div class="text-gray-800 font-weight-bold">${warehouseMap[pt.warehouseId]}</div>
                                                        </div>
                                                        <div class="col-md-3">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Tên phụ tùng</div>
                                                            <div class="text-gray-800 font-weight-bold">${partMap[pt.partId].partName} (Mã: ${partMap[pt.partId].partCode})</div>
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Số lượng yêu cầu</div>
                                                            <div class="text-danger font-weight-bold" style="font-size: 1.1rem;">${pt.quantity} ${partMap[pt.partId].unit}</div>
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Tồn kho hiện tại</div>
                                                            <div class="text-info font-weight-bold" style="font-size: 1.1rem;">${partMap[pt.partId].quantity} ${partMap[pt.partId].unit}</div>
                                                        </div>
                                                        <div class="col-md-2">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Nhân viên kỹ thuật</div>
                                                            <div class="text-gray-800">${userMap[pt.requestedBy]}</div>
                                                        </div>
                                                    </div>

                                                    <c:if test="${not empty pt.reason}">
                                                        <div class="p-3 bg-light rounded border mb-3">
                                                            <div class="small font-weight-bold text-muted text-uppercase mb-1"><i class="fas fa-comment-alt mr-1"></i>Lý do yêu cầu:</div>
                                                            <div class="text-gray-800" style="font-style: italic;">"${pt.reason}"</div>
                                                        </div>
                                                    </c:if>

                                                    <!-- Action buttons -->
                                                    <div class="text-right">
                                                        <form method="post" action="${pageContext.request.contextPath}/manager/pending-requests/reject" class="d-inline">
                                                            <input type="hidden" name="type" value="part">
                                                            <input type="hidden" name="id" value="${pt.requestId}">
                                                            <button type="submit" class="btn btn-outline-danger btn-sm font-weight-bold mr-2" onclick="return confirm('Bạn chắc chắn muốn Từ chối yêu cầu cấp phát PR-${pt.requestId}?')">
                                                                <i class="fas fa-times-circle mr-1"></i>Từ chối
                                                            </button>
                                                        </form>
                                                        <form method="post" action="${pageContext.request.contextPath}/manager/pending-requests/approve" class="d-inline">
                                                            <input type="hidden" name="type" value="part">
                                                            <input type="hidden" name="id" value="${pt.requestId}">
                                                            <button type="submit" class="btn btn-primary btn-sm font-weight-bold" ${partMap[pt.partId].quantity < pt.quantity ? 'disabled' : ''} onclick="return confirm('Bạn chắc chắn muốn Phê duyệt yêu cầu cấp phát PR-${pt.requestId}?')">
                                                                <i class="fas fa-check-circle mr-1"></i>Phê duyệt
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- TAB 3: PURCHASE REQUESTS -->
                            <div class="tab-pane fade" id="purchase-pane" role="tabpanel" aria-labelledby="purchase-tab">
                                <c:choose>
                                    <c:when test="${empty pendingPurchases}">
                                        <div class="card shadow-sm border-0 py-5 text-center bg-white rounded">
                                            <div class="card-body">
                                                <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                                                <p class="text-gray-500 font-weight-bold mb-0">Không có yêu cầu mua sắm nào đang chờ duyệt.</p>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="pr" items="${pendingPurchases}">
                                            <div class="card request-card purchase shadow-sm mb-3 bg-white">
                                                <div class="card-body">
                                                    <div class="d-md-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                                                        <div>
                                                            <h5 class="font-weight-bold text-gray-900 mb-1">Yêu cầu Mua sắm PC-${pr.purchaseRequestId}</h5>
                                                            <span class="small text-muted"><i class="far fa-clock mr-1"></i>Ngày tạo: <fmt:formatDate value="${pr.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                                        </div>
                                                        <div class="text-md-right mt-2 mt-md-0">
                                                            <span class="badge-status bg-warning text-dark font-weight-bold">Chờ Manager duyệt</span>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="row mb-3">
                                                        <div class="col-md-6">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Kho yêu cầu mua sắm</div>
                                                            <div class="text-gray-800 font-weight-bold"><i class="fas fa-warehouse mr-1 text-primary"></i>${warehouseMap[pr.warehouseId]}</div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="small font-weight-bold text-uppercase text-muted">Thủ kho đề xuất</div>
                                                            <div class="text-gray-800">${userMap[pr.requestedBy]}</div>
                                                        </div>
                                                    </div>

                                                    <c:if test="${not empty pr.reason}">
                                                        <div class="mb-3">
                                                            <div class="small font-weight-bold text-muted text-uppercase mb-1"><i class="fas fa-comment-alt mr-1"></i>Lý do mua sắm:</div>
                                                            <div class="text-gray-800 p-2 bg-light rounded" style="font-style: italic;">"${pr.reason}"</div>
                                                        </div>
                                                    </c:if>

                                                    <!-- Details List of Purchase Request -->
                                                    <div class="table-responsive mb-3 bg-light p-2 rounded">
                                                        <table class="table table-bordered table-sm mb-0 bg-white">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th>Sản phẩm / Phụ tùng</th>
                                                                    <th class="text-center" style="width: 120px;">Số lượng mua</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:forEach var="pdet" items="${purchaseDetailsMap[pr.purchaseRequestId]}">
                                                                    <tr>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${pdet.partId != null}">
                                                                                    <span class="badge badge-success mr-2">Phụ tùng</span> ${partMap[pdet.partId].partName} (Mã: ${partMap[pdet.partId].partCode})
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="badge badge-info mr-2">Mẫu mới</span> ${pdet.itemName}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td class="text-center font-weight-bold text-gray-900">${pdet.quantity}</td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </tbody>
                                                        </table>
                                                    </div>

                                                    <!-- Action buttons -->
                                                    <div class="text-right">
                                                        <form method="post" action="${pageContext.request.contextPath}/manager/pending-requests/reject" class="d-inline">
                                                            <input type="hidden" name="type" value="purchase">
                                                            <input type="hidden" name="id" value="${pr.purchaseRequestId}">
                                                            <button type="submit" class="btn btn-outline-danger btn-sm font-weight-bold mr-2" onclick="return confirm('Bạn chắc chắn muốn Từ chối yêu cầu mua sắm PC-${pr.purchaseRequestId}?')">
                                                                <i class="fas fa-times-circle mr-1"></i>Từ chối
                                                            </button>
                                                        </form>
                                                        <form method="post" action="${pageContext.request.contextPath}/manager/pending-requests/approve" class="d-inline">
                                                            <input type="hidden" name="type" value="purchase">
                                                            <input type="hidden" name="id" value="${pr.purchaseRequestId}">
                                                            <button type="submit" class="btn btn-primary btn-sm font-weight-bold" onclick="return confirm('Bạn chắc chắn muốn Phê duyệt yêu cầu mua sắm PC-${pr.purchaseRequestId}?')">
                                                                <i class="fas fa-check-circle mr-1"></i>Phê duyệt
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                        </div>
                    </div>
                </div>

            </div>
        </div>
        <%@ include file="/views/layout/footer.jsp" %>
    </div>
</div>

<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>

<!-- Scripts -->
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
</body>
</html>
