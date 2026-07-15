<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
                <!-- Page Heading -->
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800"><i class="fas fa-exchange-alt mr-2 text-primary"></i>Quản lý Điều chuyển kho</h1>
                </div>

                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success shadow-sm border-left-success"><i class="fas fa-check-circle mr-1"></i> Yêu cầu điều chuyển kho đã được tạo thành công và đang chờ Manager phê duyệt!</div>
                </c:if>
                <c:if test="${param.success == 'cancelled'}">
                    <div class="alert alert-warning shadow-sm border-left-warning"><i class="fas fa-exclamation-circle mr-1"></i> Đã hủy yêu cầu điều chuyển kho thành công! Thiết bị đã được hoàn trả lại trạng thái sẵn sàng ở kho.</div>
                </c:if>
                <c:if test="${param.success == 'approved'}">
                    <div class="alert alert-success shadow-sm border-left-success"><i class="fas fa-check-circle mr-1"></i> Phê duyệt yêu cầu điều chuyển kho thành công! Thiết bị đã được chuyển sang kho đích và cập nhật trạng thái hoạt động.</div>
                </c:if>
                <c:if test="${param.success == 'rejected'}">
                    <div class="alert alert-warning shadow-sm border-left-warning"><i class="fas fa-exclamation-circle mr-1"></i> Đã từ chối yêu cầu điều chuyển kho. Thiết bị đã được giải phóng trở lại trạng thái sẵn sàng ở kho nguồn.</div>
                </c:if>
                <c:if test="${param.error == 'approval_error'}">
                    <div class="alert alert-danger shadow-sm border-left-danger"><i class="fas fa-times-circle mr-1"></i> Thất bại! Có lỗi xảy ra trong quá trình xử lý yêu cầu điều chuyển kho.</div>
                </c:if>
                <c:if test="${param.error == 'invalid_transfer'}">
                    <div class="alert alert-danger shadow-sm border-left-danger"><i class="fas fa-times-circle mr-1"></i> Thất bại! Yêu cầu điều chuyển không hợp lệ hoặc đã được xử lý từ trước.</div>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger shadow-sm border-left-danger"><i class="fas fa-times-circle mr-1"></i> ${error}</div>
                </c:if>

                <!-- Data Table -->
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
                                        <th>Chi tiết thiết bị</th>
                                        <th class="text-center">Số lượng</th>
                                        <th>Ngày yêu cầu</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày phê duyệt</th>
                                        <c:if test="${sessionScope.currentUser.hasRole('MANAGER') || sessionScope.currentUser.hasRole('WAREHOUSE_MANAGER')}">
                                            <th class="text-center">Hành động</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="tf" items="${transfers}">
                                        <tr>
                                            <td><strong>TF-${tf.transferId}</strong></td>
                                            <td>
                                                <c:forEach var="w" items="${warehouses}">
                                                    <c:if test="${w.warehouseId == tf.fromWarehouseId}">
                                                        <strong>${w.warehouseName}</strong>
                                                    </c:if>
                                                </c:forEach>
                                            </td>
                                            <td>
                                                <c:forEach var="w" items="${warehouses}">
                                                    <c:if test="${w.warehouseId == tf.toWarehouseId}">
                                                        <strong>${w.warehouseName}</strong>
                                                    </c:if>
                                                </c:forEach>
                                            </td>
                                            <td>
                                                <c:set var="tDetails" value="${detailsMap[tf.transferId]}" />
                                                <ul class="list-unstyled mb-0" style="font-size: 0.9rem;">
                                                    <c:forEach var="det" items="${tDetails}">
                                                        <li>
                                                            <c:choose>
                                                                <c:when test="${det.itemType == 'GENERATOR'}">
                                                                    <i class="fas fa-bolt text-warning mr-1"></i>
                                                                    <c:forEach var="g" items="${allGenerators}">
                                                                        <c:if test="${g.generatorId == det.generatorId}">
                                                                            ${g.generatorName}
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="fas fa-cog text-info mr-1"></i>
                                                                    <c:forEach var="p" items="${allParts}">
                                                                        <c:if test="${p.partId == det.partId}">
                                                                            ${p.partName}
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </li>
                                                    </c:forEach>
                                                    <c:if test="${empty tDetails}">
                                                        <span class="text-muted">Không có chi tiết</span>
                                                    </c:if>
                                                </ul>
                                            </td>
                                            <td class="text-center font-weight-bold text-gray-900">
                                                <c:set var="totalQty" value="0" />
                                                <c:forEach var="det" items="${tDetails}">
                                                    <c:set var="totalQty" value="${totalQty + det.quantity}" />
                                                </c:forEach>
                                                ${totalQty}
                                            </td>
                                            <td><fmt:formatDate value="${tf.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${tf.status == 'PENDING'}">
                                                        <span class="badge badge-warning"><i class="fas fa-hourglass-half mr-1"></i> Chờ duyệt</span>
                                                    </c:when>
                                                    <c:when test="${tf.status == 'PENDING_RECEIVE'}">
                                                        <span class="badge badge-info"><i class="fas fa-truck mr-1"></i> Chờ nhận kho</span>
                                                    </c:when>
                                                    <c:when test="${tf.status == 'APPROVED'}">
                                                        <span class="badge badge-success"><i class="fas fa-check mr-1"></i> Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${tf.status == 'REJECTED'}">
                                                        <span class="badge badge-danger"><i class="fas fa-times mr-1"></i> Bị từ chối</span>
                                                    </c:when>
                                                    <c:when test="${tf.status == 'CANCELLED'}">
                                                        <span class="badge badge-secondary"><i class="fas fa-ban mr-1"></i> Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${tf.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${tf.approvedAt != null}">
                                                        <fmt:formatDate value="${tf.approvedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ---
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <c:if test="${sessionScope.currentUser.hasRole('MANAGER') || sessionScope.currentUser.hasRole('WAREHOUSE_MANAGER')}">
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${sessionScope.currentUser.hasRole('WAREHOUSE_MANAGER') && tf.status == 'PENDING' && tf.fromWarehouseId == managedWarehouse.warehouseId}">
                                                            <form method="post" action="${pageContext.request.contextPath}/stock-transfers/cancel" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn HỦY yêu cầu điều chuyển TF-${tf.transferId} này?');">
                                                                <input type="hidden" name="transferId" value="${tf.transferId}">
                                                                <button type="submit" class="btn btn-danger btn-sm font-weight-bold shadow-sm">
                                                                    <i class="fas fa-ban mr-1"></i> Hủy
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:when test="${sessionScope.currentUser.hasRole('MANAGER')}">
                                                            <c:choose>
                                                                <c:when test="${tf.status == 'PENDING'}">
                                                                    <div class="d-flex justify-content-center" style="gap: 6px;">
                                                                        <form method="post" action="${pageContext.request.contextPath}/stock-transfers/approve" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn PHÊ DUYỆT yêu cầu điều chuyển TF-${tf.transferId} này?');">
                                                                            <input type="hidden" name="transferId" value="${tf.transferId}">
                                                                            <button type="submit" class="btn btn-success btn-sm font-weight-bold shadow-sm">
                                                                                <i class="fas fa-check-circle mr-1"></i> Duyệt
                                                                            </button>
                                                                        </form>
                                                                        <form method="post" action="${pageContext.request.contextPath}/stock-transfers/reject" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn TỪ CHỐI yêu cầu điều chuyển TF-${tf.transferId} này?');">
                                                                            <input type="hidden" name="transferId" value="${tf.transferId}">
                                                                            <button type="submit" class="btn btn-danger btn-sm font-weight-bold shadow-sm">
                                                                                <i class="fas fa-times-circle mr-1"></i> Từ chối
                                                                            </button>
                                                                        </form>
                                                                    </div>
                                                                </c:when>
                                                                <c:when test="${tf.status == 'PENDING_RECEIVE'}">
                                                                    <c:forEach var="w" items="${warehouses}">
                                                                        <c:if test="${w.warehouseId == tf.toWarehouseId}">
                                                                            <c:choose>
                                                                                <c:when test="${w.managerId == sessionScope.currentUser.userId}">
                                                                                    <div class="d-flex justify-content-center" style="gap: 6px;">
                                                                                        <form method="post" action="${pageContext.request.contextPath}/stock-transfers/approve" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn XÁC NHẬN NHẬP KHO yêu cầu điều chuyển TF-${tf.transferId} này?');">
                                                                                            <input type="hidden" name="transferId" value="${tf.transferId}">
                                                                                            <button type="submit" class="btn btn-success btn-sm font-weight-bold shadow-sm">
                                                                                                <i class="fas fa-check-circle mr-1"></i> Nhập kho
                                                                                            </button>
                                                                                        </form>
                                                                                        <form method="post" action="${pageContext.request.contextPath}/stock-transfers/reject" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn TỪ CHỐI NHẬN yêu cầu điều chuyển TF-${tf.transferId} này?');">
                                                                                            <input type="hidden" name="transferId" value="${tf.transferId}">
                                                                                            <button type="submit" class="btn btn-danger btn-sm font-weight-bold shadow-sm">
                                                                                                <i class="fas fa-times-circle mr-1"></i> Từ chối
                                                                                            </button>
                                                                                        </form>
                                                                                    </div>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="text-muted" style="font-size: 0.85rem;">Chờ Manager kho nhận duyệt</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </if>
                                                                    </c:forEach>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted" style="font-size: 0.85rem;">Không có hành động</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">Không có hành động</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty transfers}">
                                        <tr>
                                            <c:choose>
                                                <c:when test="${sessionScope.currentUser.hasRole('MANAGER') || sessionScope.currentUser.hasRole('WAREHOUSE_MANAGER')}">
                                                    <td colspan="9" class="text-center text-muted">Không tìm thấy yêu cầu điều chuyển nào.</td>
                                                </c:when>
                                                <c:otherwise>
                                                    <td colspan="8" class="text-center text-muted">Không tìm thấy yêu cầu điều chuyển nào.</td>
                                                </c:otherwise>
                                            </c:choose>
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
