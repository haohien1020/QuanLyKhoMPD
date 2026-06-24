<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cảnh báo tồn kho tối thiểu | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .urgent-replenish { background-color: #f8d7da; color: #721c24; font-weight: bold; }
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
                    <h1 class="h3 mb-0 text-danger font-weight-bold"><i class="fas fa-exclamation-triangle"></i> Cảnh báo hết hàng / Thiếu linh kiện</h1>
                    <div class="text-right">
                        <span class="badge badge-danger p-2">Kho hiện tại: ${managedWarehouse.warehouseName}</span>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Data Table -->
                <div class="card shadow mb-4 border-left-danger">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-danger">Danh sách linh kiện dưới ngưỡng tối thiểu</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" width="100%" cellspacing="0">
                                <thead>
                                    <tr class="thead-light">
                                        <th>Mã linh kiện</th>
                                        <th>Tên linh kiện</th>
                                        <th>Số lượng hiện tại</th>
                                        <th>Số lượng tối thiểu cần có</th>
                                        <th>Đơn vị tính</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="part" items="${parts}">
                                        <tr class="urgent-replenish">
                                            <td><strong>${part.partCode}</strong></td>
                                            <td>${part.partName}</td>
                                            <td>${part.quantity}</td>
                                            <td>${part.minQuantity}</td>
                                            <td>${part.unit}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty parts}">
                                        <tr>
                                            <td colspan="5" class="text-center text-success py-4">
                                                <i class="fas fa-check-circle fa-2x"></i> <br>
                                                <span class="d-block mt-2 font-weight-bold">Tồn kho an toàn! Không có linh kiện nào dưới ngưỡng tối thiểu.</span>
                                            </td>
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
