package model;

import java.sql.Timestamp;

public class PurchaseRequest {

    private int purchaseRequestId;
    private int warehouseId;
    private int requestedBy;
    private Integer approvedBy;
    private String reason;
    private String status;
    private Timestamp createdAt;
    private Timestamp approvedAt;

    public PurchaseRequest() {
    }

    public PurchaseRequest(int purchaseRequestId, int warehouseId, int requestedBy, Integer approvedBy, String reason, String status, Timestamp createdAt, Timestamp approvedAt) {
        this.purchaseRequestId = purchaseRequestId;
        this.warehouseId = warehouseId;
        this.requestedBy = requestedBy;
        this.approvedBy = approvedBy;
        this.reason = reason;
        this.status = status;
        this.createdAt = createdAt;
        this.approvedAt = approvedAt;
    }

    public int getPurchaseRequestId() {
        return purchaseRequestId;
    }

    public void setPurchaseRequestId(int purchaseRequestId) {
        this.purchaseRequestId = purchaseRequestId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public int getRequestedBy() {
        return requestedBy;
    }

    public void setRequestedBy(int requestedBy) {
        this.requestedBy = requestedBy;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Timestamp approvedAt) {
        this.approvedAt = approvedAt;
    }
}