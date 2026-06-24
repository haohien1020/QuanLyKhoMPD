<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu mua hàng | Generator Management System</title>
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
                    <h1 class="h3 mb-0 text-gray-800">Quản lý Yêu cầu mua sắm thiết bị</h1>
                    <c:if test="${sessionScope.currentUser.hasRole('WAREHOUSE_MANAGER')}">
                        <a href="${pageContext.request.contextPath}/purchase-requests/create" class="btn btn-primary btn-sm"><i class="fas fa-plus"></i> Tạo yêu cầu mua hàng</a>
                    </c:if>
                </div>

                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Yêu cầu mua hàng đã được tạo thành công và đang chờ Manager phê duyệt!</div>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Data Table -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Lịch sử các yêu cầu mua sắm</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>Mã yêu cầu</th>
                                        <th>Ngày yêu cầu</th>
                                        <th>Lý do mua hàng</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày phê duyệt</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="req" items="${requests}">
                                        <tr>
                                            <td><strong>PR-${req.purchaseRequestId}</strong></td>
                                            <td>${req.createdAt}</td>
                                            <td>${req.reason}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${req.status == 'PENDING'}">
                                                        <span class="badge badge-warning"><i class="fas fa-hourglass-half"></i> Chờ duyệt</span>
                                                    </c:when>
                                                    <c:when test="${req.status == 'APPROVED'}">
                                                        <span class="badge badge-success"><i class="fas fa-check"></i> Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${req.status == 'REJECTED'}">
                                                        <span class="badge badge-danger"><i class="fas fa-times"></i> Bị từ chối</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${req.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${req.approvedAt != null ? req.approvedAt : '---'}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty requests}">
                                        <tr>
                                            <td colspan="5" class="text-center text-muted">Không tìm thấy yêu cầu mua hàng nào.</td>
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
<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
</body>
</html>
