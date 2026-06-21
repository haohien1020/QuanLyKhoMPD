<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<%
    User u = (User) request.getAttribute("viewUser");
    boolean isEdit = (u != null);
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    String fUsername = "";
    String fFullName = "";
    String fEmail = "";
    String fPhone = "";
    boolean fActive = true;

    if (isEdit) {
        fUsername = u.getUsername();
        fFullName = u.getFullName();
        fEmail = u.getEmail();
        fPhone = u.getPhone() != null ? u.getPhone() : "";
        fActive = u.isActive();
    } else {
        fUsername = request.getAttribute("f_username") != null ? (String) request.getAttribute("f_username") : "";
        fFullName = request.getAttribute("f_fullName") != null ? (String) request.getAttribute("f_fullName") : "";
        fEmail    = request.getAttribute("f_email") != null ? (String) request.getAttribute("f_email") : "";
        fPhone    = request.getAttribute("f_phone") != null ? (String) request.getAttribute("f_phone") : "";
        fActive   = request.getAttribute("f_active") != null ? (Boolean) request.getAttribute("f_active") : true;
    }

    String errorParam = request.getParameter("error");
    if ("username_empty".equals(errorParam)) {
        error = "Tài khoản không được để trống.";
    } else if ("username_len".equals(errorParam)) {
        error = "Tài khoản phải từ 3 đến 30 ký tự.";
    } else if ("fullname_empty".equals(errorParam)) {
        error = "Họ tên không được để trống.";
    } else if ("fullname_len".equals(errorParam)) {
        error = "Họ tên phải từ 2 đến 100 ký tự.";
    } else if ("email_empty".equals(errorParam)) {
        error = "Email không được để trống.";
    } else if ("phone_invalid".equals(errorParam)) {
        error = "Số điện thoại không hợp lệ.";
    } else if ("username_taken".equals(errorParam)) {
        error = "Tài khoản đã tồn tại trên hệ thống.";
    } else if ("email_taken".equals(errorParam)) {
        error = "Email đã tồn tại trên hệ thống.";
    } else if ("update_failed".equals(errorParam)) {
        error = "Cập nhật thông tin thất bại. Vui lòng thử lại.";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "Cập nhật tài khoản SELLER" : "Tạo tài khoản SELLER" %> | Generator Management System</title>

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
                        <i class="fas <%= isEdit ? "fa-user-edit" : "fa-user-plus" %> text-primary"></i> 
                        <%= isEdit ? "Cập nhật tài khoản SELLER" : "Tạo tài khoản SELLER" %>
                    </h1>
                    <a href="${pageContext.request.contextPath}/warehouse/sellers" class="btn btn-secondary btn-sm">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <% if (success != null && !success.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fas fa-check-circle"></i> <%= success %>
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <%= isEdit ? "Thông tin tài khoản SELLER (ID: " + u.getUserId() + ")" : "Thông tin tài khoản SELLER mới" %>
                        </h6>
                    </div>
                    <div class="card-body">

                        <form method="post" action="${pageContext.request.contextPath}/warehouse/sellers/<%= isEdit ? "update" : "create" %>" autocomplete="off">
                            <% if (isEdit) { %>
                                <input type="hidden" name="id" value="<%= u.getUserId() %>">
                            <% } %>

                            <div class="form-group">
                                <label for="username">Tên tài khoản <span class="text-danger">*</span></label>
                                <input type="text" id="username" name="username" class="form-control"
                                       value="<%= fUsername %>" required autocomplete="off"
                                       minlength="3" maxlength="30" <%= isEdit ? "readonly" : "" %>>
                                <small class="form-text text-muted">3–30 ký tự, chỉ chứa chữ, số, dấu chấm, gạch dưới hoặc gạch ngang.</small>
                            </div>

                            <% if (!isEdit) { %>
                            <div class="form-group">
                                <label for="password">Mật khẩu <span class="text-danger">*</span></label>
                                <input type="password" id="password" name="password" class="form-control"
                                       required autocomplete="new-password">
                                <small class="form-text text-muted">Ít nhất 6 ký tự, có ít nhất 1 chữ hoa và 1 chữ số.</small>
                            </div>
                            <% } %>

                            <div class="form-group">
                                <label for="fullName">Họ tên nhân viên <span class="text-danger">*</span></label>
                                <input type="text" id="fullName" name="fullName" class="form-control"
                                       value="<%= fFullName %>" required
                                       minlength="2" maxlength="100">
                                <small class="form-text text-muted">2–100 ký tự.</small>
                            </div>

                            <div class="form-row">
                                <div class="form-group col-md-6">
                                    <label for="email">Email liên hệ <span class="text-danger">*</span></label>
                                    <input type="email" id="email" name="email" class="form-control"
                                           value="<%= fEmail %>" required>
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="phone">Số điện thoại</label>
                                    <input type="text" id="phone" name="phone" class="form-control"
                                           value="<%= fPhone %>"
                                           inputmode="tel"
                                           placeholder="09xxxxxxxx hoặc +84xxxxxxxxx">
                                </div>
                            </div>

                            <% if (!isEdit) { %>
                            <div class="form-group">
                                <label for="active">Trạng thái ban đầu</label>
                                <select id="active" name="active" class="form-control">
                                    <option value="true" <%= fActive ? "selected" : "" %>>Hoạt động (ACTIVE)</option>
                                    <option value="false" <%= !fActive ? "selected" : "" %>>Khóa (BANNED)</option>
                                </select>
                            </div>
                            <% } %>

                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> <%= isEdit ? "Lưu thay đổi" : "Tạo tài khoản" %>
                            </button>
                        </form>

                    </div>
                </div>

            </div>

        </div>

        <%@ include file="/views/layout/footer.jsp" %>

    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>

</body>
</html>
