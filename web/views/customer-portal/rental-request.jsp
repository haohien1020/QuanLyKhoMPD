<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Generator" %>

<%
    Customer customerInfo = (Customer) request.getAttribute("customerInfo");
    List<Generator> availableGenerators = (List<Generator>) request.getAttribute("availableGenerators");
    String customerPortalError = (String) request.getAttribute("customerPortalError");
    String errorParam = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu thuê máy | Generator Management System</title>
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
                        <i class="fas fa-plus-circle text-primary"></i> Yêu cầu thuê máy phát
                    </h1>
                    <a href="${pageContext.request.contextPath}/customer/contracts" class="btn btn-sm btn-outline-primary">
                        <i class="fas fa-file-contract"></i> Hợp đồng của tôi
                    </a>
                </div>

                <% if (customerPortalError != null) { %>
                <div class="alert alert-warning"><%= html(customerPortalError) %></div>
                <% } %>

                <% if ("missing_required".equals(errorParam)) { %>
                <div class="alert alert-warning">Vui lòng chọn máy và nhập đầy đủ ngày thuê/ngày trả dự kiến.</div>
                <% } else if ("invalid_date".equals(errorParam)) { %>
                <div class="alert alert-warning">Ngày trả dự kiến phải sau ngày bắt đầu thuê.</div>
                <% } else if ("generator_unavailable".equals(errorParam)) { %>
                <div class="alert alert-danger">Máy phát đã được thuê hoặc không còn khả dụng. Vui lòng chọn máy khác.</div>
                <% } else if ("customer_not_linked".equals(errorParam)) { %>
                <div class="alert alert-danger">Tài khoản chưa liên kết với hồ sơ khách hàng ACTIVE.</div>
                <% } else if ("system_error".equals(errorParam)) { %>
                <div class="alert alert-danger">Có lỗi xảy ra khi tạo yêu cầu thuê. Vui lòng thử lại.</div>
                <% } %>

                <div class="row">
                    <div class="col-lg-8">
                        <div class="card shadow mb-4">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">Thông tin yêu cầu thuê</h6>
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/customer/rental-request/create">
                                    <div class="form-group">
                                        <label for="generatorId">Máy phát muốn thuê <span class="text-danger">*</span></label>
                                        <select id="generatorId" name="generatorId" class="form-control" required>
                                            <option value="">-- Chọn máy đang có sẵn --</option>
                                            <% if (availableGenerators != null) {
                                                for (Generator g : availableGenerators) { %>
                                            <option value="<%= g.getGeneratorId() %>">
                                                <%= html(g.getGeneratorName()) %><%= g.getSerialNumber() != null && !g.getSerialNumber().isEmpty() ? " - " + html(g.getSerialNumber()) : "" %>
                                                <% if (g.getPowerValue() != null) { %> - <%= html(g.getPowerValue()) %><% } %>
                                                <% if (g.getFuelType() != null) { %> - <%= html(g.getFuelType()) %><% } %>
                                            </option>
                                            <% } } %>
                                        </select>
                                    </div>

                                    <div class="row">
                                        <div class="form-group col-md-6">
                                            <label for="startDate">Ngày bắt đầu thuê <span class="text-danger">*</span></label>
                                            <input type="date" id="startDate" name="startDate" class="form-control" required>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="expectedReturnDate">Ngày trả dự kiến <span class="text-danger">*</span></label>
                                            <input type="date" id="expectedReturnDate" name="expectedReturnDate" class="form-control" required>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="note">Ghi chú nhu cầu thuê</label>
                                        <textarea id="note" name="note" class="form-control" rows="4"
                                                  placeholder="Ví dụ: thuê phục vụ công trình 7 ngày, cần giao tại Đồng Nai..."></textarea>
                                    </div>

                                    <button type="submit" class="btn btn-primary" <%= availableGenerators == null || availableGenerators.isEmpty() ? "disabled" : "" %>>
                                        <i class="fas fa-paper-plane"></i> Gửi yêu cầu thuê
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card shadow mb-4">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">Thông tin khách hàng</h6>
                            </div>
                            <div class="card-body">
                                <div class="font-weight-bold text-gray-900"><%= customerInfo != null ? html(customerInfo.getCustomerName()) : "-" %></div>
                                <div class="text-muted small mt-1"><%= customerInfo != null ? html(customerInfo.getEmail()) : "" %></div>
                                <div class="text-muted small"><%= customerInfo != null ? html(customerInfo.getPhone()) : "" %></div>
                                <hr>
                                <p class="small text-gray-700 mb-0">
                                    Sau khi gửi, yêu cầu sẽ tạo hợp đồng thuê trạng thái <strong>PENDING</strong>.
                                    Manager hoặc Warehouse Manager sẽ kiểm tra và duyệt trước khi giao máy.
                                </p>
                            </div>
                        </div>

                        <div class="card border-left-info shadow">
                            <div class="card-body">
                                <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Máy khả dụng</div>
                                <div class="h4 font-weight-bold text-gray-800"><%= availableGenerators != null ? availableGenerators.size() : 0 %></div>
                                <div class="small text-muted">Chỉ hiển thị máy có trạng thái IN_STOCK.</div>
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
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
