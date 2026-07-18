<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Thông báo hệ thống | Generator Management System</title>
                <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css"
                    rel="stylesheet">
                <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
                <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
                <style>
                    :root {
                        --primary-gradient: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
                        --danger-gradient: linear-gradient(135deg, #7f1d1d 0%, #ef4444 100%);
                        --card-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.05);
                    }

                    .premium-card {
                        border: none;
                        border-radius: 12px;
                        box-shadow: var(--card-shadow);
                        background: rgba(255, 255, 255, 0.95);
                        transition: transform 0.2s ease, box-shadow 0.2s ease;
                    }

                    .premium-card:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 6px 25px 0 rgba(0, 0, 0, 0.08);
                    }

                    .noti-card {
                        border: none;
                        border-radius: 10px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03);
                        background: #fff;
                        transition: all 0.2s ease;
                        border-left: 5px solid transparent;
                    }

                    .noti-card:hover {
                        transform: translateX(4px);
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.06);
                    }

                    .noti-unread {
                        background-color: #f8fafc;
                    }

                    /* Border colors based on notification type */
                    .noti-type-contract {
                        border-left-color: #3b82f6 !important;
                    }

                    .noti-type-system {
                        border-left-color: #8b5cf6 !important;
                    }

                    .noti-type-warning {
                        border-left-color: #f59e0b !important;
                    }

                    .noti-type-danger {
                        border-left-color: #ef4444 !important;
                    }

                    .noti-type-success {
                        border-left-color: #10b981 !important;
                    }

                    .noti-type-default {
                        border-left-color: #6b7280 !important;
                    }

                    .noti-icon {
                        width: 40px;
                        height: 40px;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 1.05rem;
                        flex-shrink: 0;
                    }

                    /* Icon colors */
                    .noti-icon-contract {
                        background-color: #dbeafe;
                        color: #1e40af;
                    }

                    .noti-icon-system {
                        background-color: #f3e8ff;
                        color: #6b21a8;
                    }

                    .noti-icon-warning {
                        background-color: #fef3c7;
                        color: #92400e;
                    }

                    .noti-icon-danger {
                        background-color: #fee2e2;
                        color: #991b1b;
                    }

                    .noti-icon-success {
                        background-color: #d1fae5;
                        color: #065f46;
                    }

                    .noti-icon-default {
                        background-color: #f3f4f6;
                        color: #374151;
                    }

                    .btn-action-noti {
                        width: 32px;
                        height: 32px;
                        border-radius: 50%;
                        padding: 0;
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        transition: all 0.2s ease;
                    }

                    .btn-action-noti:hover {
                        background-color: #f1f5f9;
                    }

                    .pulse-badge {
                        animation: pulse 2s infinite;
                    }

                    @keyframes pulse {
                        0% {
                            box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.4);
                        }

                        70% {
                            box-shadow: 0 0 0 8px rgba(59, 130, 246, 0);
                        }

                        100% {
                            box-shadow: 0 0 0 0 rgba(59, 130, 246, 0);
                        }
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

                                        <!-- Page Heading -->
                                        <div class="d-sm-flex align-items-center justify-content-between mb-4">
                                            <h1 class="h3 mb-0 text-gray-800 font-weight-bold">
                                                <i class="fas fa-bell text-primary mr-2"></i>Thông báo hệ thống
                                            </h1>
                                            <div class="text-right mt-2 mt-sm-0">
                                                <c:if test="${unreadCount > 0}">
                                                    <a href="${pageContext.request.contextPath}/notifications/mark-all-read"
                                                        class="btn btn-primary btn-sm font-weight-bold mr-2 shadow-sm">
                                                        <i class="fas fa-check-double mr-1"></i> Đọc tất cả
                                                    </a>
                                                </c:if>
                                                <c:if test="${not empty notifications}">
                                                    <button type="button"
                                                        class="btn btn-danger btn-sm font-weight-bold shadow-sm"
                                                        data-toggle="modal" data-target="#clearAllModal">
                                                        <i class="fas fa-trash-alt mr-1"></i> Xóa tất cả
                                                    </button>
                                                </c:if>
                                            </div>
                                        </div>

                                        <!-- Alerts -->
                                        <c:if test="${param.success eq 'marked_all_read'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> Đã đánh dấu đọc toàn bộ thông
                                                báo thành công.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.success eq 'cleared_all'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> Đã dọn dẹp sạch toàn bộ thông
                                                báo.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${param.success eq 'deleted'}">
                                            <div class="alert alert-success alert-dismissible fade show shadow-sm border-left-success"
                                                role="alert">
                                                <i class="fas fa-check-circle mr-2"></i> Đã xóa thông báo thành công.
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty error}">
                                            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-left-danger"
                                                role="alert">
                                                <i class="fas fa-exclamation-circle mr-2"></i> ${error}
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                        </c:if>

                                        <div class="row">
                                            <!-- Left panel: List of Notifications -->
                                            <div class="col-lg-9 mb-4">
                                                <div class="card premium-card shadow mb-4">
                                                    <div
                                                        class="card-header py-3 bg-white border-bottom d-flex justify-content-between align-items-center">
                                                        <h6 class="m-0 font-weight-bold text-primary">
                                                            <i class="fas fa-envelope-open-text mr-1"></i> Danh sách
                                                            thông báo
                                                        </h6>
                                                        <span class="badge badge-primary px-2 py-1 pulse-badge"
                                                            style="font-size: 0.8rem;">
                                                            ${unreadCount} chưa đọc
                                                        </span>
                                                    </div>
                                                    <div class="card-body">
                                                        <c:choose>
                                                            <c:when test="${empty notifications}">
                                                                <div class="text-center py-5 my-4">
                                                                    <i
                                                                        class="fas fa-inbox fa-4x text-gray-300 mb-3"></i>
                                                                    <h5 class="text-gray-500 font-weight-bold">Không có
                                                                        thông báo nào</h5>
                                                                    <p class="text-muted small">Hộp thư thông báo của
                                                                        bạn hiện đang trống sạch.</p>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="table-responsive">
                                                                    <table class="table table-borderless" id="notificationsTable" width="100%" cellspacing="0">
                                                                        <thead class="d-none">
                                                                            <tr>
                                                                                <th>Thông báo</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:forEach var="noti" items="${notifications}">
                                                                                <tr>
                                                                                    <td class="p-0">
                                                                                        <c:set var="typeLower"
                                                                                            value="${noti.type != null ? noti.type.toLowerCase() : 'default'}" />
                                                                                        <div class="card noti-card mb-2 noti-type-${typeLower} ${noti.read ? '' : 'noti-unread'}"
                                                                                            id="noti-item-${noti.notificationId}">
                                                                                            <div class="card-body p-3">
                                                                                                <div class="d-flex align-items-start">
                                                                                                    <!-- Icon indicator -->
                                                                                                    <div
                                                                                                        class="noti-icon noti-icon-${typeLower} mr-3 shadow-sm">
                                                                                                        <c:choose>
                                                                                                            <c:when
                                                                                                                test="${typeLower eq 'contract' or typeLower eq 'rental'}">
                                                                                                                <i
                                                                                                                    class="fas fa-file-contract"></i>
                                                                                                            </c:when>
                                                                                                            <c:when
                                                                                                                test="${typeLower eq 'system'}">
                                                                                                                <i
                                                                                                                    class="fas fa-laptop-code"></i>
                                                                                                            </c:when>
                                                                                                            <c:when
                                                                                                                test="${typeLower eq 'warning'}">
                                                                                                                <i
                                                                                                                    class="fas fa-exclamation-triangle"></i>
                                                                                                            </c:when>
                                                                                                            <c:when
                                                                                                                test="${typeLower eq 'danger'}">
                                                                                                                <i
                                                                                                                    class="fas fa-times-circle"></i>
                                                                                                            </c:when>
                                                                                                            <c:when
                                                                                                                test="${typeLower eq 'success'}">
                                                                                                                <i
                                                                                                                    class="fas fa-check-circle"></i>
                                                                                                            </c:when>
                                                                                                            <c:otherwise>
                                                                                                                <i
                                                                                                                    class="fas fa-bell"></i>
                                                                                                            </c:otherwise>
                                                                                                        </c:choose>
                                                                                                    </div>
                                                                                                    <!-- Content text -->
                                                                                                    <div class="flex-grow-1">
                                                                                                        <div
                                                                                                            class="d-flex justify-content-between align-items-start">
                                                                                                            <h6
                                                                                                                class="mb-1 font-weight-bold ${noti.read ? 'text-gray-700' : 'text-gray-900'}">
                                                                                                                <c:out
                                                                                                                    value="${noti.title}" />
                                                                                                                <c:if
                                                                                                                    test="${not noti.read}">
                                                                                                                    <span
                                                                                                                        class="badge badge-primary ml-1 badge-pill"
                                                                                                                        style="font-size: 0.65rem;">Mới</span>
                                                                                                                </c:if>
                                                                                                            </h6>
                                                                                                            <div class="d-flex ml-2">
                                                                                                                <!-- Mark read (AJAX) -->
                                                                                                                <c:if
                                                                                                                    test="${not noti.read}">
                                                                                                                    <button
                                                                                                                        type="button"
                                                                                                                        class="btn btn-action-noti text-primary mr-1"
                                                                                                                        onclick="ajaxMarkAsRead(${noti.notificationId})"
                                                                                                                        title="Đánh dấu đã đọc">
                                                                                                                        <i
                                                                                                                            class="fas fa-envelope-open-text"></i>
                                                                                                                    </button>
                                                                                                                </c:if>
                                                                                                                <!-- Delete form submit -->
                                                                                                                <form method="post"
                                                                                                                    action="${pageContext.request.contextPath}/notifications/delete"
                                                                                                                    style="display:inline;">
                                                                                                                    <input type="hidden"
                                                                                                                        name="notificationId"
                                                                                                                        value="${noti.notificationId}">
                                                                                                                    <button
                                                                                                                        type="submit"
                                                                                                                        class="btn btn-action-noti text-danger"
                                                                                                                        title="Xóa thông báo">
                                                                                                                        <i
                                                                                                                            class="fas fa-trash-alt"></i>
                                                                                                                    </button>
                                                                                                                </form>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <p
                                                                                                            class="text-gray-600 small mb-2">
                                                                                                            <c:out
                                                                                                                value="${noti.message}" />
                                                                                                        </p>
                                                                                                        <div
                                                                                                            class="d-flex justify-content-between align-items-center text-xs text-muted">
                                                                                                            <span>
                                                                                                                <i
                                                                                                                    class="far fa-clock mr-1"></i>
                                                                                                                <fmt:formatDate
                                                                                                                    value="${noti.createdAt}"
                                                                                                                    pattern="dd/MM/yyyy HH:mm" />
                                                                                                            </span>
                                                                                                            <span
                                                                                                                class="badge badge-light border text-uppercase px-2">
                                                                                                                ${noti.type != null ?
                                                                                                                noti.type : 'Thông báo'}
                                                                                                            </span>
                                                                                                        </div>
                                                                                                    </div>
                                                                                                </div>
                                                                                            </div>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Right panel: Quick Stats -->
                                            <div class="col-lg-3 mb-4">
                                                <div class="card premium-card shadow mb-4 border-left-primary">
                                                    <div class="card-body">
                                                        <h6 class="font-weight-bold text-primary mb-3">Tóm tắt hoạt động
                                                        </h6>
                                                        <div class="row align-items-center no-gutters mb-3">
                                                            <div class="col mr-2">
                                                                <div
                                                                    class="text-xs font-weight-bold text-muted text-uppercase mb-1">
                                                                    Tổng số thông báo
                                                                </div>
                                                                <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                                    ${empty notifications ? 0 : notifications.size()}
                                                                </div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <i class="fas fa-folder fa-2x text-gray-300"></i>
                                                            </div>
                                                        </div>
                                                        <div class="row align-items-center no-gutters">
                                                            <div class="col mr-2">
                                                                <div
                                                                    class="text-xs font-weight-bold text-muted text-uppercase mb-1">
                                                                    Chưa xem
                                                                </div>
                                                                <div class="h5 mb-0 font-weight-bold text-primary">
                                                                    ${unreadCount}
                                                                </div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <i class="fas fa-envelope fa-2x text-gray-300"></i>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                            </div>
                            <%@ include file="/views/layout/footer.jsp" %>
                        </div>
                </div>

                <!-- Modal confirm clear all -->
                <div class="modal fade" id="clearAllModal" tabindex="-1" role="dialog"
                    aria-labelledby="clearAllModalLabel" aria-hidden="true">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title font-weight-bold" id="clearAllModalLabel">Xác nhận dọn sạch hộp
                                    thư?</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body text-gray-700">
                                Hành động này sẽ xóa vĩnh viễn toàn bộ thông báo trong tài khoản của bạn. Bạn có chắc
                                chắn muốn dọn sạch không?
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary font-weight-bold"
                                    data-dismiss="modal">Hủy bỏ</button>
                                <a href="${pageContext.request.contextPath}/notifications/clear-all"
                                    class="btn btn-danger font-weight-bold px-4">Xác nhận dọn sạch</a>
                            </div>
                        </div>
                    </div>
                </div>

                <script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/vendor/jquery-easing/jquery.easing.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>

                <script>
                    $(document).ready(function () {
                        $('#notificationsTable').DataTable({
                            "language": {
                                "lengthMenu": "Hiển thị _MENU_ thông báo mỗi trang",
                                "zeroRecords": "Không tìm thấy thông báo nào",
                                "info": "Trang _PAGE_ / _PAGES_",
                                "infoEmpty": "Không có thông báo",
                                "infoFiltered": "(lọc từ _MAX_ thông báo)",
                                "paginate": {
                                    "first": "Đầu",
                                    "last": "Cuối",
                                    "next": "Sau",
                                    "previous": "Trước"
                                }
                            },
                            "pageLength": 10,
                            "ordering": false,
                            "searching": true
                        });
                    });

                    function ajaxMarkAsRead(notiId) {
                        if (!notiId) return;
                        $.ajax({
                            url: "${pageContext.request.contextPath}/notifications/mark-read",
                            type: "POST",
                            data: { notificationId: notiId },
                            success: function (response) {
                                if (response.trim() === "success") {
                                    var item = $("#noti-item-" + notiId);
                                    item.removeClass("noti-unread");
                                    item.find(".badge-primary").remove();
                                    item.find("button[onclick^='ajaxMarkAsRead']").fadeOut(200);

                                    // Reduce unread counter in page
                                    var badge = $(".pulse-badge");
                                    if (badge.length > 0) {
                                        var count = parseInt(badge.text().trim());
                                        if (!isNaN(count) && count > 0) {
                                            badge.text((count - 1) + " chưa đọc");
                                        }
                                    }
                                } else {
                                    console.error("Failed to mark as read: Server error");
                                }
                            },
                            error: function (xhr, status, error) {
                                console.error("AJAX Error: ", error);
                            }
                        });
                    }
                </script>
            </body>

            </html>