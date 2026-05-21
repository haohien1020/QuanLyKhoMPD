package model;

import java.sql.Timestamp;

public class Part {

    private int partId;
    private int warehouseId;
    private String partName;
    private String partCode;
    private int quantity;
    private int minQuantity;
    private String unit;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Part() {
    }

    public Part(int partId, int warehouseId, String partName, String partCode, int quantity, int minQuantity, String unit, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.partId = partId;
        this.warehouseId = warehouseId;
        this.partName = partName;
        this.partCode = partCode;
        this.quantity = quantity;
        this.minQuantity = minQuantity;
        this.unit = unit;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getPartName() {
        return partName;
    }

    public void setPartName(String partName) {
        this.partName = partName;
    }

    public String getPartCode() {
        return partCode;
    }

    public void setPartCode(String partCode) {
        this.partCode = partCode;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getMinQuantity() {
        return minQuantity;
    }

    public void setMinQuantity(int minQuantity) {
        this.minQuantity = minQuantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}