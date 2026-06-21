<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Theo dõi tồn kho | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .low-stock-alert { background-color: #fff3cd; color: #856404; font-weight: bold; }
        .normal-stock { background-color: #d4edda; color: #155724; }
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
                    <h1 class="h3 mb-0 text-gray-800">Theo dõi tồn kho linh kiện & phụ tùng</h1>
                    <div class="text-right">
                        <span class="badge badge-info p-2">Kho hiện tại: ${managedWarehouse.warehouseName}</span>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Search & Filters -->
                <div class="card shadow mb-4">
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/inventory" class="form-inline">
                            <input type="text" name="q" value="${q}" class="form-control mr-sm-2" placeholder="Tìm tên hoặc mã linh kiện..." style="min-width: 300px;">
                            <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm kiếm</button>
                            <a href="${pageContext.request.contextPath}/inventory" class="btn btn-secondary ml-2">Reset</a>
                        </form>
                    </div>
                </div>

                <!-- Data Table -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3 d-flex justify-content-between align-items-center">
                        <h6 class="m-0 font-weight-bold text-primary">Danh sách tồn kho vật tư</h6>
                        <a href="${pageContext.request.contextPath}/inventory/low-stock" class="btn btn-warning btn-sm"><i class="fas fa-exclamation-triangle"></i> Xem cảnh báo hết hàng</a>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>Mã linh kiện</th>
                                        <th>Tên linh kiện</th>
                                        <th>Số lượng trong kho</th>
                                        <th>Ngưỡng tối thiểu</th>
                                        <th>Đơn vị tính</th>
                                        <th>Trạng thái tồn kho</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="part" items="${parts}">
                                        <tr class="${part.quantity <= part.minQuantity ? 'low-stock-alert' : ''}">
                                            <td><strong>${part.partCode}</strong></td>
                                            <td>${part.partName}</td>
                                            <td>${part.quantity}</td>
                                            <td>${part.minQuantity}</td>
                                            <td>${part.unit}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${part.quantity <= part.minQuantity}">
                                                        <span class="badge badge-danger"><i class="fas fa-arrow-down"></i> Cần nhập thêm</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-success"><i class="fas fa-check-circle"></i> Đủ hàng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty parts}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted">Không tìm thấy linh kiện nào.</td>
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
