<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.PartRequest" %>
<%@ page import="model.Part" %>
<%@ page import="model.Warehouse" %>

<%
    @SuppressWarnings("unchecked")
    List<PartRequest> requests = (List<PartRequest>) request.getAttribute("requests");
    @SuppressWarnings("unchecked")
    List<Warehouse> warehouses = (List<Warehouse>) request.getAttribute("warehouses");
    @SuppressWarnings("unchecked")
    List<Part> parts = (List<Part>) request.getAttribute("parts");

    String successParam = request.getParameter("success");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu của tôi | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        .table thead th {
            white-space: nowrap;
            vertical-align: middle !important;
            text-align: center;
        }
        .table tbody td {
            vertical-align: middle !important;
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
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">
                        <i class="fas fa-list text-warning"></i> Danh sách yêu cầu phụ tùng của tôi
                    </h1>
                    <a href="${pageContext.request.contextPath}/staff/part-request/create" class="btn btn-warning btn-sm shadow-sm">
                        <i class="fas fa-plus"></i> Tạo yêu cầu mới
                    </a>
                </div>

                <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> Gửi phiếu yêu cầu phụ tùng thành công! Chờ duyệt từ Quản lý.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3 bg-white">
                        <h6 class="m-0 font-weight-bold text-warning">
                            <i class="fas fa-history"></i> Lịch sử yêu cầu linh kiện
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="requestTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>Mã phiếu</th>
                                    <th>Linh kiện yêu cầu</th>
                                    <th>Kho chứa hàng</th>
                                    <th>Số lượng</th>
                                    <th>Ngày yêu cầu</th>
                                    <th>Lý do yêu cầu</th>
                                    <th>Trạng thái</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    if (requests == null || requests.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">
                                        <i class="fas fa-inbox fa-3x mb-3 text-gray-300"></i>
                                        <p class="m-0">Bạn chưa gửi phiếu yêu cầu phụ tùng nào.</p>
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (PartRequest req : requests) {
                                            String partName = "Không rõ";
                                            String unit = "";
                                            if (parts != null) {
                                                for (Part p : parts) {
                                                    if (p.getPartId() == req.getPartId()) {
                                                        partName = p.getPartName();
                                                        unit = p.getUnit() != null ? p.getUnit() : "";
                                                        break;
                                                    }
                                                }
                                            }

                                            String warehouseName = "Không rõ";
                                            if (warehouses != null) {
                                                for (Warehouse w : warehouses) {
                                                    if (w.getWarehouseId() == req.getWarehouseId()) {
                                                        warehouseName = w.getWarehouseName();
                                                        break;
                                                    }
                                                }
                                            }

                                            String dateStr = req.getCreatedAt() != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(req.getCreatedAt()) : "-";
                                            
                                            String badgeClass = "badge-secondary";
                                            String statusVn = req.getStatus();
                                            if ("PENDING".equals(req.getStatus())) {
                                                badgeClass = "badge-warning";
                                                statusVn = "Chờ phê duyệt";
                                            } else if ("APPROVED".equals(req.getStatus())) {
                                                badgeClass = "badge-success";
                                                statusVn = "Đã được duyệt";
                                            } else if ("COMPLETED".equals(req.getStatus())) {
                                                badgeClass = "badge-info";
                                                statusVn = "Đã cấp phát";
                                            } else if ("REJECTED".equals(req.getStatus())) {
                                                badgeClass = "badge-danger";
                                                statusVn = "Bị từ chối";
                                            }
                                %>
                                <tr>
                                    <td class="text-center">#<%= req.getRequestId() %></td>
                                    <td><span class="font-weight-bold text-gray-900"><%= partName %></span></td>
                                    <td><span class="badge badge-light border"><i class="fas fa-warehouse mr-1 text-gray-500"></i> <%= warehouseName %></span></td>
                                    <td class="text-center"><%= req.getQuantity() %> <%= unit %></td>
                                    <td class="text-center"><%= dateStr %></td>
                                    <td><%= req.getReason() != null ? req.getReason() : "-" %></td>
                                    <td class="text-center">
                                        <span class="badge <%= badgeClass %> px-2 py-1"><%= statusVn %></span>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
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
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script>
    $(document).ready(function () {
        $('#requestTable').DataTable({
            pageLength: 10,
            ordering: false,
            searching: false,
            lengthChange: false,
            language: {
                paginate: {
                    next: "Sau",
                    previous: "Trước"
                },
                emptyTable: "Không có dữ liệu trong bảng",
                info: "Hiển thị từ dòng _START_ đến _END_ trên tổng số _TOTAL_ dòng",
                infoEmpty: "Không có dữ liệu hiển thị"
            }
        });
    });
</script>
</body>
</html>
