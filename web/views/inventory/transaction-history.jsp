<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nhật ký Giao dịch Kho | Generator Management System</title>
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --card-shadow: 0 4px 20px 0 rgba(0,0,0,0.05);
        }
        
        .premium-card {
            border: none;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            background: var(--glass-bg);
        }
        
        .table thead th {
            white-space: nowrap;
            vertical-align: middle !important;
            text-align: center;
            background-color: #f8fafc;
            color: #475569;
            font-weight: 700;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .table tbody td {
            vertical-align: middle !important;
        }

        .badge-import {
            background-color: #d1fae5;
            color: #065f46;
            font-weight: 800;
            border: 1px solid #a7f3d0;
        }

        .badge-export {
            background-color: #fee2e2;
            color: #991b1b;
            font-weight: 800;
            border: 1px solid #fca5a5;
        }

        .badge-generator {
            background-color: #dbeafe;
            color: #1e40af;
            font-weight: bold;
        }

        .badge-part {
            background-color: #f1f5f9;
            color: #334155;
            font-weight: bold;
        }

        .hover-row:hover {
            background-color: #f8fafc;
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
                        <i class="fas fa-history text-primary mr-2"></i>Lịch sử Giao dịch Kho (Nhật ký Biến động)
                    </h1>
                    <div class="text-right">
                        <span class="badge badge-info p-2 font-weight-bold shadow-sm" style="font-size: 0.9rem;">
                            <i class="fas fa-warehouse mr-1"></i> Kho: ${managedWarehouse.warehouseName}
                        </span>
                    </div>
                </div>

                <!-- Filters -->
                <div class="card premium-card shadow mb-4">
                    <div class="card-header py-3 bg-white border-bottom">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-filter mr-1"></i> Bộ lọc nâng cao
                        </h6>
                    </div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/inventory-transactions/history" class="row">
                            <div class="form-group col-md-3">
                                <label class="font-weight-bold text-xs text-gray-700">Tìm kiếm từ khóa</label>
                                <input type="text" name="q" value="${q}" class="form-control" placeholder="Tên máy, sê-ri, phụ tùng, note...">
                            </div>
                            <div class="form-group col-md-2">
                                <label class="font-weight-bold text-xs text-gray-700">Loại giao dịch</label>
                                <select name="type" class="form-control">
                                    <option value="" ${empty typeFilter ? 'selected' : ''}>-- Tất cả --</option>
                                    <option value="IMPORT" ${typeFilter eq 'IMPORT' ? 'selected' : ''}>Nhập kho (IMPORT)</option>
                                    <option value="EXPORT" ${typeFilter eq 'EXPORT' ? 'selected' : ''}>Xuất kho (EXPORT)</option>
                                </select>
                            </div>
                            <div class="form-group col-md-2">
                                <label class="font-weight-bold text-xs text-gray-700">Loại thiết bị</label>
                                <select name="itemType" class="form-control">
                                    <option value="" ${empty itemTypeFilter ? 'selected' : ''}>-- Tất cả --</option>
                                    <option value="GENERATOR" ${itemTypeFilter eq 'GENERATOR' ? 'selected' : ''}>Máy phát điện</option>
                                    <option value="PART" ${itemTypeFilter eq 'PART' ? 'selected' : ''}>Phụ tùng / Linh kiện</option>
                                </select>
                            </div>
                            <div class="form-group col-md-2">
                                <label class="font-weight-bold text-xs text-gray-700">Từ ngày</label>
                                <input type="date" name="startDate" value="${startDateVal}" class="form-control">
                            </div>
                            <div class="form-group col-md-2">
                                <label class="font-weight-bold text-xs text-gray-700">Tới ngày</label>
                                <input type="date" name="endDate" value="${endDateVal}" class="form-control">
                            </div>
                            <div class="form-group col-md-1 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100 font-weight-bold shadow-sm">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Table Log -->
                <div class="card premium-card shadow mb-4">
                    <div class="card-header py-3 bg-white border-bottom d-flex align-items-center justify-content-between">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-list-ul mr-1"></i> Nhật ký biến động tồn kho
                        </h6>
                        <a href="${pageContext.request.contextPath}/inventory-transactions" class="btn btn-sm btn-outline-primary font-weight-bold">
                            <i class="fas fa-plus mr-1"></i> Thực hiện giao dịch mới
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="transactionTable" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th style="width: 60px;">ID</th>
                                        <th style="width: 150px;">Thời gian</th>
                                        <th>Loại GD</th>
                                        <th>Loại hàng</th>
                                        <th>Tên máy / Phụ tùng</th>
                                        <th style="width: 120px;">Mã / Sê-ri</th>
                                        <th>Số lượng</th>
                                        <th>Nhân viên</th>
                                        <th>Ghi chú lý do</th>
                                        <th style="width: 60px;">Xem</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="tx" items="${transactions}">
                                        <tr class="hover-row">
                                            <td class="text-center text-xs font-weight-bold text-gray-600">${tx.transactionId}</td>
                                            <td class="text-center text-xs text-gray-800">
                                                <fmt:formatDate value="${tx.transactionDate}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </td>
                                            <td class="text-center text-nowrap">
                                                <c:choose>
                                                    <c:when test="${tx.transactionType eq 'IMPORT'}">
                                                        <span class="badge badge-import px-2 py-1"><i class="fas fa-arrow-down mr-1"></i> NHẬP KHO</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-export px-2 py-1"><i class="fas fa-arrow-up mr-1"></i> XUẤT KHO</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center text-nowrap">
                                                <c:choose>
                                                    <c:when test="${tx.itemType eq 'GENERATOR'}">
                                                        <span class="badge badge-generator px-2 py-1"><i class="fas fa-bolt mr-1"></i> MÁY PHÁT</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-part px-2 py-1"><i class="fas fa-cog mr-1"></i> PHỤ TÙNG</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="font-weight-bold text-gray-900">
                                                    <c:choose>
                                                        <c:when test="${tx.itemType eq 'GENERATOR'}">${tx.generatorName}</c:when>
                                                        <c:otherwise>${tx.partName}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <code class="text-xs font-weight-bold">
                                                    <c:choose>
                                                        <c:when test="${tx.itemType eq 'GENERATOR'}">${tx.generatorSerial}</c:when>
                                                        <c:otherwise>${tx.partCode}</c:otherwise>
                                                    </c:choose>
                                                </code>
                                            </td>
                                            <td class="text-center font-weight-bold">
                                                <c:choose>
                                                    <c:when test="${tx.transactionType eq 'IMPORT'}">
                                                        <span class="text-success">+${tx.quantity}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-danger">-${tx.quantity}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center text-xs text-gray-700">${tx.creatorName}</td>
                                            <td class="text-xs text-muted text-truncate" style="max-width: 250px;" title="${tx.note}">${tx.note}</td>
                                            <td class="text-center">
                                                <button type="button" class="btn btn-sm btn-light border shadow-sm btn-circle"
                                                        onclick="viewTxDetail('${tx.transactionId}', '<fmt:formatDate value="${tx.transactionDate}" pattern="dd/MM/yyyy HH:mm:ss"/>', '${tx.transactionType}', '${tx.itemType}', '${tx.itemType eq 'GENERATOR' ? tx.generatorName : tx.partName}', '${tx.itemType eq 'GENERATOR' ? tx.generatorSerial : tx.partCode}', '${tx.quantity}', '${tx.creatorName}', '${tx.warehouseName}', '${tx.supplierName != null ? tx.supplierName : 'N/A'}', '${tx.note.replace('\'', '\\\'')}')"
                                                        title="Xem chi tiết">
                                                    <i class="fas fa-eye text-primary"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty transactions}">
                                        <tr>
                                            <td colspan="10" class="text-center text-muted py-5">
                                                <i class="fas fa-folder-open fa-3x mb-3 text-gray-300"></i>
                                                <p class="m-0">Không có giao dịch xuất nhập kho nào khớp với bộ lọc.</p>
                                            </td>
                                        </tr>
                                    </c:if>
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

<!-- Modal xem chi tiết giao dịch -->
<div class="modal fade" id="txDetailModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-gradient-primary text-white">
                <h5 class="modal-title font-weight-bold"><i class="fas fa-info-circle mr-1"></i> Chi tiết Giao dịch Xuất Nhập Kho</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body p-4 text-gray-900">
                <div class="row">
                    <div class="col-md-6 border-right">
                        <table class="table table-borderless table-sm">
                            <tbody>
                                <tr>
                                    <td class="font-weight-bold text-muted" style="width: 140px;">Mã giao dịch:</td>
                                    <td id="modalTxId" class="font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Thời gian thực hiện:</td>
                                    <td id="modalTxDate" class="small text-gray-800"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Loại giao dịch:</td>
                                    <td id="modalTxType"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nhân viên thực hiện:</td>
                                    <td id="modalTxCreator" class="font-weight-bold"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Kho hàng ghi nhận:</td>
                                    <td id="modalTxWarehouse"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Nhà cung cấp:</td>
                                    <td id="modalTxSupplier" class="text-gray-700"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h6 class="font-weight-bold text-primary mb-3"><i class="fas fa-boxes mr-1"></i> Thông tin hàng hóa</h6>
                        <table class="table table-borderless table-sm">
                            <tbody>
                                <tr>
                                    <td class="font-weight-bold text-muted" style="width: 140px;">Tên hàng hóa:</td>
                                    <td id="modalTxItemName" class="font-weight-bold text-gray-900"></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Mã / Sê-ri:</td>
                                    <td id="modalTxItemCode"><code class="text-xs font-weight-bold"></code></td>
                                </tr>
                                <tr>
                                    <td class="font-weight-bold text-muted">Số lượng biến động:</td>
                                    <td id="modalTxQty" class="h5 font-weight-bold"></td>
                                </tr>
                            </tbody>
                        </table>
                        
                        <!-- Barcode Area for Generator -->
                        <div id="modalBarcodeArea" class="p-3 border rounded text-center bg-light mt-3" style="display: none;">
                            <div class="text-xs font-weight-bold text-uppercase text-muted mb-2"><i class="fas fa-barcode mr-1"></i> Mã vạch Serial Number</div>
                            <img id="modalBarcodeImg" alt="Barcode Image" style="max-height: 48px; max-width: 100%;">
                        </div>
                    </div>
                </div>
                <hr class="my-3">
                <div class="form-group mb-0">
                    <label class="font-weight-bold text-muted">Ghi chú diễn giải chi tiết:</label>
                    <div id="modalTxNote" class="p-3 border rounded bg-light text-gray-800 text-break" style="white-space: pre-line; min-height: 60px;"></div>
                </div>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary px-4" data-dismiss="modal">Đóng cửa sổ</button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/vendor/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/sb-admin-2.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/datatables/dataTables.bootstrap4.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/JsBarcode.all.min.js"></script>

<script>
    $(document).ready(function () {
        $('#transactionTable').DataTable({
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

    function viewTxDetail(id, date, type, itemType, itemName, itemCode, qty, creator, warehouse, supplier, note) {
        $('#modalTxId').text('#' + id);
        $('#modalTxDate').text(date);
        $('#modalTxCreator').text(creator);
        $('#modalTxWarehouse').text(warehouse);
        $('#modalTxSupplier').text(supplier);
        $('#modalTxItemName').text(itemName);
        $('#modalTxItemCode').find('code').text(itemCode);
        $('#modalTxNote').text(note || 'Không có ghi chú diễn giải.');

        // Render badges
        var typeBadge = '';
        if (type === 'IMPORT') {
            typeBadge = '<span class="badge badge-import px-2 py-1"><i class="fas fa-arrow-down mr-1"></i> NHẬP KHO</span>';
            $('#modalTxQty').html('<span class="text-success">+' + qty + '</span>');
        } else {
            typeBadge = '<span class="badge badge-export px-2 py-1"><i class="fas fa-arrow-up mr-1"></i> XUẤT KHO</span>';
            $('#modalTxQty').html('<span class="text-danger">-' + qty + '</span>');
        }
        $('#modalTxType').html(typeBadge);

        // Render barcode if Generator
        if (itemType === 'GENERATOR' && itemCode) {
            try {
                var canvas = document.createElement('canvas');
                JsBarcode(canvas, itemCode, {
                    format: "CODE128",
                    width: 2,
                    height: 50,
                    displayValue: true,
                    fontSize: 12,
                    margin: 0
                });
                $('#modalBarcodeImg').attr('src', canvas.toDataURL("image/png"));
                $('#modalBarcodeArea').show();
            } catch (e) {
                console.error("Lỗi vẽ mã vạch: ", e);
                $('#modalBarcodeArea').hide();
            }
        } else {
            $('#modalBarcodeArea').hide();
        }

        $('#txDetailModal').modal('show');
    }
</script>
</body>
</html>
