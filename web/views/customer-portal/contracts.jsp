<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.CustomerRentalContract" %>

<%
    List<CustomerRentalContract> contracts = (List<CustomerRentalContract>) request.getAttribute("contracts");
    String customerPortalError = (String) request.getAttribute("customerPortalError");
    String successParam = request.getParameter("success");
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hợp đồng thuê của tôi | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
</head>
<body id="page-top">
<div id="wrapper">
    <%@ include file="/views/layout/sidebar.jsp" %>
    <div id="content-wrapper" class="d-flex flex-column">
        <div id="content">
            <%@ include file="/views/layout/topbar.jsp" %>
            <div class="container-fluid">
                <h1 class="h3 mb-4 text-gray-800"><i class="fas fa-file-contract text-primary"></i> Hợp đồng thuê của tôi</h1>

                <% if (customerPortalError != null) { %>
                <div class="alert alert-warning"><%= html(customerPortalError) %></div>
                <% } %>

                <% if ("rental_requested".equals(successParam)) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Đã gửi yêu cầu thuê máy. Hợp đồng đang chờ duyệt.
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Danh sách hợp đồng</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="contractsTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>Mã hợp đồng</th>
                                    <th>Kho phụ trách</th>
                                    <th>Ngày thuê</th>
                                    <th>Ngày trả dự kiến</th>
                                    <th>Ngày trả thực tế</th>
                                    <th>Số máy</th>
                                    <th>Tiền cọc</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (contracts != null) {
                                    for (CustomerRentalContract c : contracts) { %>
                                <tr>
                                    <td class="font-weight-bold"><%= code(c.getContractCode(), c.getRentalContractId()) %></td>
                                    <td><%= html(c.getWarehouseName()) %></td>
                                    <td><%= c.getStartDate() != null ? df.format(c.getStartDate()) : "-" %></td>
                                    <td><%= c.getExpectedReturnDate() != null ? df.format(c.getExpectedReturnDate()) : "-" %></td>
                                    <td><%= c.getActualReturnDate() != null ? df.format(c.getActualReturnDate()) : "-" %></td>
                                    <td class="text-center"><%= c.getGeneratorCount() %></td>
                                    <td class="text-right"><%= c.getDepositAmount() != null ? c.getDepositAmount() : "-" %></td>
                                    <td class="text-right"><%= c.getTotalAmount() != null ? c.getTotalAmount() : "-" %></td>
                                    <td class="text-center"><span class="badge badge-info"><%= html(c.getStatus()) %></span></td>
                                </tr>
                                <% } } %>
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
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>
<script>
    $(document).ready(function () {
        $('#contractsTable').DataTable({pageLength: 10, ordering: false});
    });
</script>
</body>
</html>

<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String code(String contractCode, int id) {
        return contractCode != null && !contractCode.trim().isEmpty() ? html(contractCode) : "RC-" + id;
    }
%>
