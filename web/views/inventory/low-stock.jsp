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
                    <h1 class="h3 mb-0 text-danger font-weight-bold"><i class="fas fa-exclamation-triangle"></i> Cảnh báo hết máy phát điện</h1>
                    <div class="text-right">
                        <span class="badge badge-danger p-2">Kho hiện tại: ${managedWarehouse.warehouseName}</span>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Bộ lọc tìm kiếm -->
                <div class="card shadow mb-4">
                    <div class="card-body py-3">
                        <form method="get" action="${pageContext.request.contextPath}/inventory/low-stock" class="row align-items-center">
                            <div class="form-group col-md-10 mb-0">
                                <input type="text" name="q" class="form-control form-control-sm" placeholder="Tìm kiếm theo tên máy phát điện, thương hiệu..." value="${q}">
                            </div>
                            <div class="form-group col-md-2 mb-0">
                                <button type="submit" class="btn btn-primary btn-sm w-100 shadow-sm"><i class="fas fa-search"></i> Tìm kiếm</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Data Table -->
                <div class="card shadow mb-4 border-left-danger">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-danger">Danh sách máy phát điện dưới ngưỡng tối thiểu</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" width="100%" cellspacing="0">
                                <thead>
                                    <tr class="thead-light">
                                        <th class="text-center" style="width: 80px;">ID</th>
                                        <th>Tên máy phát điện</th>
                                        <th class="text-center">Thương hiệu</th>
                                        <th class="text-center">Công suất</th>
                                        <th class="text-center" style="width: 150px;">Số lượng hiện tại</th>
                                        <th class="text-center" style="width: 150px;">Mức tối thiểu</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="gen" items="${generators}">
                                        <tr class="urgent-replenish">
                                            <td class="text-center align-middle"><strong>${gen.generatorId}</strong></td>
                                            <td class="align-middle">${gen.generatorName}</td>
                                            <td class="text-center align-middle">${gen.brand}</td>
                                            <td class="text-center align-middle">${gen.powerValue}</td>
                                            <td class="text-center align-middle font-weight-bold text-danger">${gen.quantity}</td>
                                            <td class="text-center align-middle">${gen.minStock}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty generators}">
                                        <tr>
                                            <td colspan="6" class="text-center text-success py-4">
                                                <i class="fas fa-check-circle fa-2x"></i> <br>
                                                <span class="d-block mt-2 font-weight-bold">Tồn kho an toàn! Không có máy phát điện nào dưới ngưỡng tối thiểu.</span>
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
