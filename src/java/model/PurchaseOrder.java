package model;

import java.sql.Timestamp;

public class PurchaseOrder {

    private int purchaseOrderId;
    private int supplierId;
    private int warehouseId;
    private int createdBy;
    private String status;
    private Timestamp orderDate;
    private String note;

    public PurchaseOrder() {
    }

    public PurchaseOrder(int purchaseOrderId, int supplierId, int warehouseId, int createdBy, String status, Timestamp orderDate, String note) {
        this.purchaseOrderId = purchaseOrderId;
        this.supplierId = supplierId;
        this.warehouseId = warehouseId;
        this.createdBy = createdBy;
        this.status = status;
        this.orderDate = orderDate;
        this.note = note;
    }

    public int getPurchaseOrderId() {
        return purchaseOrderId;
    }

    public void setPurchaseOrderId(int purchaseOrderId) {
        this.purchaseOrderId = purchaseOrderId;
    }

    public int getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(int supplierId) {
        this.supplierId = supplierId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}