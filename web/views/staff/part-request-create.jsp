<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Part" %>
<%@ page import="model.Warehouse" %>

<%
    @SuppressWarnings("unchecked")
    List<Warehouse> warehouses = (List<Warehouse>) request.getAttribute("warehouses");
    @SuppressWarnings("unchecked")
    List<Part> parts = (List<Part>) request.getAttribute("parts");
    
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo yêu cầu phụ tùng | Generator Management System</title>
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
                        <i class="fas fa-plus-circle text-warning"></i> Tạo yêu cầu phụ tùng linh kiện
                    </h1>
                    <a href="${pageContext.request.contextPath}/staff/my-requests" class="btn btn-outline-warning btn-sm">
                        <i class="fas fa-list"></i> Yêu cầu của tôi
                    </a>
                </div>

                <% if ("invalid_input".equals(error)) { %>
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fas fa-exclamation-triangle"></i> Vui lòng kiểm tra lại thông tin nhập. Số lượng phải lớn hơn 0.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } else if ("create_failed".equals(error)) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> Gửi yêu cầu thất bại. Vui lòng thử lại sau.
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="row">
                    <div class="col-lg-8 mx-auto">
                        <div class="card shadow mb-4">
                            <div class="card-header bg-white py-3">
                                <h6 class="m-0 font-weight-bold text-warning">
                                    <i class="fas fa-edit"></i> Phiếu yêu cầu cấp phát phụ tùng
                                </h6>
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/staff/part-request/create">
                                    
                                    <div class="form-group">
                                        <label for="warehouseId">Kho lưu trữ phụ tùng <span class="text-danger">*</span></label>
                                        <select id="warehouseId" name="warehouseId" class="form-control" required>
                                            <option value="">--- Chọn kho lưu trữ phụ tùng ---</option>
                                            <% if (warehouses != null) {
                                                for (Warehouse w : warehouses) { %>
                                                <option value="<%= w.getWarehouseId() %>"><%= w.getWarehouseName() %></option>
                                            <% } } %>
                                        </select>
                                        <small class="form-text text-muted">Lựa chọn kho vật lý chứa linh kiện cần lấy.</small>
                                    </div>

                                    <div class="form-group">
                                        <label for="partId">Linh kiện / Phụ tùng yêu cầu <span class="text-danger">*</span></label>
                                        <select id="partId" name="partId" class="form-control" required>
                                            <option value="">--- Chọn phụ tùng cần yêu cầu ---</option>
                                            <% if (parts != null) {
                                                for (Part p : parts) { %>
                                                <option value="<%= p.getPartId() %>"><%= p.getPartName() %> (Mã: <%= p.getPartCode() %> - Còn lại: <%= p.getQuantity() %> <%= p.getUnit() %>)</option>
                                            <% } } %>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label for="quantity">Số lượng yêu cầu cấp <span class="text-danger">*</span></label>
                                        <input type="number" id="quantity" name="quantity" class="form-control" min="1" required placeholder="Ví dụ: 2">
                                    </div>

                                    <div class="form-group">
                                        <label for="reason">Lý do yêu cầu cấp phụ tùng</label>
                                        <textarea id="reason" name="reason" class="form-control" rows="4" placeholder="Ví dụ: Sử dụng thay thế chổi than hỏng cho máy phát điện số 5 tại Kho Đông..."></textarea>
                                    </div>

                                    <hr>

                                    <div class="d-flex justify-content-end">
                                        <a href="${pageContext.request.contextPath}/staff/home" class="btn btn-secondary mr-2">Hủy bỏ</a>
                                        <button type="submit" class="btn btn-warning px-4 shadow">
                                            <i class="fas fa-paper-plane"></i> Gửi yêu cầu
                                        </button>
                                    </div>
                                </form>
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
