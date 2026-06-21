<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách hợp đồng thuê | Generator Management System</title>
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
                    <h1 class="h3 mb-0 text-gray-800"><i class="fas fa-file-contract text-primary"></i> Quản lý Hợp đồng Thuê</h1>
                    <a href="${pageContext.request.contextPath}/seller/contracts/create" class="btn btn-primary btn-sm shadow-sm">
                        <i class="fas fa-plus fa-sm text-white-50"></i> Lập hợp đồng mới
                    </a>
                </div>

                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lập hợp đồng thuê thành công! Đang chờ Thủ kho duyệt để bàn giao.</div>
                </c:if>
                <c:if test="${param.success == 'updated'}">
                    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã cập nhật thông tin hợp đồng thành công!</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Contracts List -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Danh sách hợp đồng của khách hàng</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>Mã hợp đồng</th>
                                        <th>Khách hàng</th>
                                        <th>Kho lưu trữ</th>
                                        <th>Ngày bắt đầu</th>
                                        <th>Ngày trả dự kiến</th>
                                        <th>Tiền cọc</th>
                                        <th>Tổng thanh toán</th>
                                        <th>Trạng thái</th>
                                        <th style="width: 120px;">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="contract" items="${contracts}">
                                        <tr>
                                            <td><strong>${contract.contractCode}</strong></td>
                                            <td>${contract.customerName}</td>
                                            <td>${contract.warehouseName}</td>
                                            <td>${contract.startDate}</td>
                                            <td>${contract.expectedReturnDate}</td>
                                            <td>${contract.depositAmount} VND</td>
                                            <td>${contract.totalAmount} VND</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${contract.status == 'PENDING'}">
                                                        <span class="badge badge-warning">Chờ xử lý</span>
                                                    </c:when>
                                                    <c:when test="${contract.status == 'APPROVED'}">
                                                        <span class="badge badge-primary">Đã duyệt (Chờ giao máy)</span>
                                                    </c:when>
                                                    <c:when test="${contract.status == 'DELIVERED'}">
                                                        <span class="badge badge-info">Đang thuê</span>
                                                    </c:when>
                                                    <c:when test="${contract.status == 'COMPLETED'}">
                                                        <span class="badge badge-success">Đã hoàn thành</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${contract.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${contract.status == 'PENDING'}">
                                                        <a href="${pageContext.request.contextPath}/seller/contracts/update?contractId=${contract.rentalContractId}" class="btn btn-sm btn-info">
                                                            <i class="fas fa-edit"></i> Chỉnh sửa
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">Không cho phép sửa</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty contracts}">
                                        <tr>
                                            <td colspan="9" class="text-center text-muted py-4">Không có hợp đồng nào.</td>
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
