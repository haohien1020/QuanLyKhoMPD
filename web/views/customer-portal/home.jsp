<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Customer" %>
<%@ page import="model.CustomerRentalContract" %>
<%@ page import="model.CustomerRentedGenerator" %>
<%@ page import="model.Notification" %>

<%
    Customer customerInfo = (Customer) request.getAttribute("customerInfo");
    List<CustomerRentalContract> contracts = (List<CustomerRentalContract>) request.getAttribute("contracts");
    List<CustomerRentedGenerator> rentedGenerators = (List<CustomerRentedGenerator>) request.getAttribute("rentedGenerators");
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    Integer totalContracts = (Integer) request.getAttribute("totalContracts");
    Integer activeGenerators = (Integer) request.getAttribute("activeGenerators");
    Integer unreadNotifications = (Integer) request.getAttribute("unreadNotifications");
    String customerPortalError = (String) request.getAttribute("customerPortalError");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cổng khách hàng | Generator Management System</title>
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
                    <h1 class="h3 mb-0 text-gray-800">
                        <i class="fas fa-home text-primary"></i> Tổng quan khách hàng
                    </h1>
                    <span class="text-muted small">${sessionScope.currentUser.email}</span>
                </div>

                <% if (customerPortalError != null) { %>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i> <%= html(customerPortalError) %>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-body">
                        <div class="d-sm-flex justify-content-between align-items-center">
                            <div>
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-2">Hồ sơ khách hàng</div>
                                <h2 class="h4 text-gray-900 mb-1"><%= customerInfo != null ? html(customerInfo.getCustomerName()) : "Chưa liên kết hồ sơ khách hàng" %></h2>
                                <div class="text-muted">
                                    <%= customerInfo != null && customerInfo.getPhone() != null ? html(customerInfo.getPhone()) : "-" %>
                                    <% if (customerInfo != null && customerInfo.getAddress() != null) { %>
                                    · <%= html(customerInfo.getAddress()) %>
                                    <% } %>
                                </div>
                            </div>
                            <div class="mt-3 mt-sm-0">
                                <span class="badge badge-success px-3 py-2">CUSTOMER</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xl-4 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Tổng hợp đồng</div>
                                        <div class="h4 mb-0 font-weight-bold text-gray-800"><%= totalContracts != null ? totalContracts : 0 %></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-file-contract fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Máy đang thuê</div>
                                        <div class="h4 mb-0 font-weight-bold text-gray-800"><%= activeGenerators != null ? activeGenerators : 0 %></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-bolt fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Thông báo chưa đọc</div>
                                        <div class="h4 mb-0 font-weight-bold text-gray-800"><%= unreadNotifications != null ? unreadNotifications : 0 %></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-bell fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">Hợp đồng gần đây</h6>
                            </div>
                            <div class="card-body">
                                <% if (contracts == null || contracts.isEmpty()) { %>
                                <p class="text-muted mb-0">Chưa có hợp đồng thuê nào.</p>
                                <% } else {
                                    int limit = Math.min(contracts.size(), 5);
                                    for (int i = 0; i < limit; i++) {
                                        CustomerRentalContract c = contracts.get(i);
                                %>
                                <div class="d-flex justify-content-between border-bottom py-2">
                                    <div>
                                        <div class="font-weight-bold text-gray-900"><%= code(c.getContractCode(), c.getRentalContractId()) %></div>
                                        <div class="small text-muted"><%= html(c.getWarehouseName()) %></div>
                                    </div>
                                    <span class="badge badge-info align-self-center"><%= html(c.getStatus()) %></span>
                                </div>
                                <% } } %>
                                <a href="${pageContext.request.contextPath}/customer/contracts" class="btn btn-sm btn-outline-primary mt-3">Xem tất cả</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">Máy đang thuê</h6>
                            </div>
                            <div class="card-body">
                                <% if (rentedGenerators == null || rentedGenerators.isEmpty()) { %>
                                <p class="text-muted mb-0">Hiện chưa có máy phát nào đang thuê.</p>
                                <% } else {
                                    int limit = Math.min(rentedGenerators.size(), 5);
                                    for (int i = 0; i < limit; i++) {
                                        CustomerRentedGenerator g = rentedGenerators.get(i);
                                %>
                                <div class="d-flex justify-content-between border-bottom py-2">
                                    <div>
                                        <div class="font-weight-bold text-gray-900"><%= html(g.getGeneratorName()) %></div>
                                        <div class="small text-muted"><%= g.getSerialNumber() != null && !g.getSerialNumber().isEmpty() ? html(g.getSerialNumber()) + " · " : "" %><%= html(g.getPowerValue()) %></div>
                                    </div>
                                    <span class="badge badge-success align-self-center"><%= html(g.getGeneratorStatus()) %></span>
                                </div>
                                <% } } %>
                                <a href="${pageContext.request.contextPath}/customer/generators" class="btn btn-sm btn-outline-primary mt-3">Xem máy đang thuê</a>
                                <a href="${pageContext.request.contextPath}/customer/rental-request" class="btn btn-sm btn-primary mt-3 ml-2">Tạo yêu cầu thuê</a>
                            </div>
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

<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String code(String contractCode, int id) {
        return contractCode != null && !contractCode.trim().isEmpty() ? html(contractCode) : "RC-" + id;
    }
%>
