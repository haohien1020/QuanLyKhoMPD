package model;

import java.sql.Timestamp;

public class Warehouse {

    private int warehouseId;
    private String warehouseName;
    private String address;
    private Integer managerId;
    private String status;
    private Timestamp createdAt;

    public Warehouse() {
    }

    public Warehouse(int warehouseId, String warehouseName, String address, Integer managerId, String status, Timestamp createdAt) {
        this.warehouseId = warehouseId;
        this.warehouseName = warehouseName;
        this.address = address;
        this.managerId = managerId;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Integer getManagerId() {
        return managerId;
    }

    public void setManagerId(Integer managerId) {
        this.managerId = managerId;
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
}