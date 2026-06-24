<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tạo yêu cầu mua hàng | Generator Management System</title>
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
                    <h1 class="h3 mb-0 text-gray-800">Tạo yêu cầu mua hàng mới</h1>
                    <a href="${pageContext.request.contextPath}/purchase-requests" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> Quay lại</a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Thông tin yêu cầu mua sắm</h6>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/purchase-requests/create">
                            <div class="form-group">
                                <label for="reason" class="font-weight-bold">Lý do yêu cầu mua hàng:</label>
                                <textarea name="reason" id="reason" rows="3" class="form-control" placeholder="Mô tả lý do cần mua thêm vật tư/phụ tùng này..." required></textarea>
                            </div>

                            <hr>
                            <h5 class="font-weight-bold text-gray-800 mt-4 mb-3">Danh sách linh kiện đề xuất mua:</h5>
                            
                            <table class="table table-bordered" id="itemsTable">
                                <thead>
                                    <tr>
                                        <th>Linh kiện có sẵn (Không bắt buộc)</th>
                                        <th>Tên linh kiện cần mua (Nhập nếu mua mới)</th>
                                        <th style="width: 150px;">Số lượng</th>
                                        <th style="width: 80px;">Xóa</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <select name="partId" class="form-control part-select" onchange="onPartSelected(this)">
                                                <option value="">-- Chọn linh kiện có sẵn --</option>
                                                <c:forEach var="part" items="${parts}">
                                                    <option value="${part.partId}" ${param.partId == part.partId ? 'selected' : ''}>${part.partName} (Mã: ${part.partCode})</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td>
                                            <input type="text" name="itemName" class="form-control item-name-input" placeholder="Tên phụ tùng mới..." required>
                                        </td>
                                        <td>
                                            <input type="number" name="quantity" class="form-control" value="${param.quantity != null ? param.quantity : 1}" min="1" required>
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-danger btn-sm btn-block disabled" disabled><i class="fas fa-trash"></i></button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                            <button type="button" class="btn btn-outline-primary btn-sm mb-4" onclick="addNewRow()"><i class="fas fa-plus"></i> Thêm linh kiện vào dòng mới</button>

                            <div class="text-right">
                                <button type="submit" class="btn btn-success btn-lg"><i class="fas fa-save"></i> Gửi yêu cầu mua hàng</button>
                            </div>
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
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script>
    function onPartSelected(selectObj) {
        var row = selectObj.closest('tr');
        var nameInput = row.querySelector('.item-name-input');
        if (selectObj.value) {
            nameInput.value = selectObj.options[selectObj.selectedIndex].text.split(' (Mã:')[0];
            nameInput.readOnly = true;
        } else {
            nameInput.value = '';
            nameInput.readOnly = false;
        }
    }

    function addNewRow() {
        var table = document.getElementById("itemsTable").getElementsByTagName('tbody')[0];
        var newRow = table.rows[0].cloneNode(true);
        
        // Reset values
        var select = newRow.querySelector('.part-select');
        select.value = "";
        var inputName = newRow.querySelector('.item-name-input');
        inputName.value = "";
        inputName.readOnly = false;
        var inputQty = newRow.querySelector('input[type="number"]');
        inputQty.value = 1;
        
        // Enable delete button
        var delBtn = newRow.querySelector('.btn-danger');
        delBtn.disabled = false;
        delBtn.classList.remove('disabled');
        delBtn.onclick = function() {
            this.closest('tr').remove();
        };

        table.appendChild(newRow);
    }

    // Run once on load to initialize first select box
    document.addEventListener("DOMContentLoaded", function() {
        var select = document.querySelector('.part-select');
        if (select.value) {
            onPartSelected(select);
        }
    });
</script>
</body>
</html>
