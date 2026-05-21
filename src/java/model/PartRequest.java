package model;

import java.sql.Timestamp;

public class PartRequest {

    private int requestId;
    private int warehouseId;
    private int partId;
    private int requestedBy;
    private Integer approvedBy;
    private int quantity;
    private String reason;
    private String status;
    private Timestamp createdAt;
    private Timestamp approvedAt;

    public PartRequest() {
    }

    public PartRequest(int requestId, int warehouseId, int partId, int requestedBy, Integer approvedBy, int quantity, String reason, String status, Timestamp createdAt, Timestamp approvedAt) {
        this.requestId = requestId;
        this.warehouseId = warehouseId;
        this.partId = partId;
        this.requestedBy = requestedBy;
        this.approvedBy = approvedBy;
        this.quantity = quantity;
        this.reason = reason;
        this.status = status;
        this.createdAt = createdAt;
        this.approvedAt = approvedAt;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
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

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
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