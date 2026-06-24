<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.Notification" %>

<%
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    String customerPortalError = (String) request.getAttribute("customerPortalError");
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thông báo của tôi | Generator Management System</title>
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
                <h1 class="h3 mb-4 text-gray-800"><i class="fas fa-bell text-primary"></i> Thông báo của tôi</h1>

                <% if (customerPortalError != null) { %>
                <div class="alert alert-warning"><%= html(customerPortalError) %></div>
                <% } %>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Danh sách thông báo</h6>
                    </div>
                    <div class="card-body">
                        <% if (notifications == null || notifications.isEmpty()) { %>
                        <div class="text-center text-muted py-5">
                            <i class="fas fa-inbox fa-3x mb-3 text-gray-300"></i>
                            <p class="mb-0">Bạn chưa có thông báo nào.</p>
                        </div>
                        <% } else {
                            for (Notification n : notifications) { %>
                        <div class="border-left-<%= n.isRead() ? "secondary" : "primary" %> border-bottom py-3 px-3 mb-2">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <div class="font-weight-bold text-gray-900">
                                        <%= html(n.getTitle()) %>
                                        <% if (!n.isRead()) { %>
                                        <span class="badge badge-primary ml-2">Mới</span>
                                        <% } %>
                                    </div>
                                    <div class="text-gray-700 mt-1"><%= html(n.getMessage()) %></div>
                                    <div class="small text-muted mt-2">
                                        <%= n.getCreatedAt() != null ? df.format(n.getCreatedAt()) : "" %>
                                        <% if (n.getType() != null) { %>
                                        · <%= html(n.getType()) %>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="ml-3">
                                    <i class="fas <%= n.isRead() ? "fa-envelope-open text-gray-400" : "fa-envelope text-primary" %>"></i>
                                </div>
                            </div>
                        </div>
                        <% } } %>
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
%>
