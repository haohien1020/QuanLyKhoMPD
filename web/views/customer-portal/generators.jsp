<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.CustomerRentedGenerator" %>

<%
    List<CustomerRentedGenerator> rentedGenerators = (List<CustomerRentedGenerator>) request.getAttribute("rentedGenerators");
    String customerPortalError = (String) request.getAttribute("customerPortalError");
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Máy phát đang thuê | Generator Management System</title>
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
                <h1 class="h3 mb-4 text-gray-800"><i class="fas fa-bolt text-primary"></i> Máy phát đang thuê</h1>

                <% if (customerPortalError != null) { %>
                <div class="alert alert-warning"><%= html(customerPortalError) %></div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Danh sách máy đang thuê</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="generatorsTable" width="100%" cellspacing="0">
                                <thead class="thead-light">
                                <tr>
                                    <th>Tên máy</th>
                                    <th>Serial</th>
                                    <th>Thương hiệu</th>
                                    <th>Công suất</th>
                                    <th>Nhiên liệu</th>
                                    <th>Hợp đồng</th>
                                    <th>Ngày thuê</th>
                                    <th>Ngày trả dự kiến</th>
                                    <th>Giá thuê</th>
                                    <th>Trạng thái</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (rentedGenerators != null) {
                                    for (CustomerRentedGenerator g : rentedGenerators) { %>
                                <tr>
                                    <td class="font-weight-bold"><%= html(g.getGeneratorName()) %></td>
                                    <td><code><%= g.getSerialNumber() != null && !g.getSerialNumber().isEmpty() ? html(g.getSerialNumber()) : "-" %></code></td>
                                    <td><%= html(g.getBrand()) %></td>
                                    <td><%= html(g.getPowerValue()) %></td>
                                    <td><%= html(g.getFuelType()) %></td>
                                    <td><%= code(g.getContractCode(), g.getRentalContractId()) %></td>
                                    <td><%= g.getStartDate() != null ? df.format(g.getStartDate()) : "-" %></td>
                                    <td><%= g.getExpectedReturnDate() != null ? df.format(g.getExpectedReturnDate()) : "-" %></td>
                                    <td class="text-right"><%= g.getRentalPrice() != null ? g.getRentalPrice() : "-" %></td>
                                    <td class="text-center"><span class="badge badge-success"><%= html(g.getGeneratorStatus()) %></span></td>
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
        $('#generatorsTable').DataTable({pageLength: 10, ordering: false});
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
