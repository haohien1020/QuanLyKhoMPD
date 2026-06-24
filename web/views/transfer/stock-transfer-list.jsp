<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu điều chuyển | Generator Management System</title>
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
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">Quản lý Điều chuyển kho (Đơn giản)</h1>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Lịch sử các yêu cầu điều chuyển</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>Mã yêu cầu</th>
                                        <th>Kho nguồn</th>
                                        <th>Kho đích</th>
                                        <th>Ngày yêu cầu</th>
                                        <th>Trạng thái</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="tf" items="${transfers}">
                                        <tr>
                                            <td><strong>TF-${tf.transferId}</strong></td>
                                            <td>${tf.fromWarehouseId}</td>
                                            <td>${tf.toWarehouseId}</td>
                                            <td>${tf.createdAt}</td>
                                            <td>
                                                <span class="badge badge-warning">${tf.status}</span>
                                            </td>
                                            <td>
                                                <c:if test="${tf.status == 'PENDING'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/stock-transfers/approve" style="display:inline;">
                                                        <input type="hidden" name="transferId" value="${tf.transferId}">
                                                        <button type="submit" class="btn btn-success btn-sm">Duyệt</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/stock-transfers/reject" style="display:inline;">
                                                        <input type="hidden" name="transferId" value="${tf.transferId}">
                                                        <button type="submit" class="btn btn-danger btn-sm">Từ chối</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty transfers}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted">Không tìm thấy yêu cầu điều chuyển nào.</td>
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
