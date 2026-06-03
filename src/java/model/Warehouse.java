package model;

import java.sql.Timestamp;

public class Warehouse {

    private int warehouseId;
    private String warehouseName;
    private String address;
    private Integer managerId;
    private String status;
    private Timestamp createdAt;
    private String managerName;
    private Integer warehouseManagerId;
    private String warehouseManagerName;

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

    public String getManagerName() {
        return managerName;
    }

    public void setManagerName(String managerName) {
        this.managerName = managerName;
    }

    public Integer getWarehouseManagerId() {
        return warehouseManagerId;
    }

    public void setWarehouseManagerId(Integer warehouseManagerId) {
        this.warehouseManagerId = warehouseManagerId;
    }

    public String getWarehouseManagerName() {
        return warehouseManagerName;
    }

    public void setWarehouseManagerName(String warehouseManagerName) {
        this.warehouseManagerName = warehouseManagerName;
    }

    private String warehouseManagerEmail;
    private String warehouseManagerPhone;

    public String getWarehouseManagerEmail() {
        return warehouseManagerEmail;
    }

    public void setWarehouseManagerEmail(String warehouseManagerEmail) {
        this.warehouseManagerEmail = warehouseManagerEmail;
    }

    public String getWarehouseManagerPhone() {
        return warehouseManagerPhone;
    }

    public void setWarehouseManagerPhone(String warehouseManagerPhone) {
        this.warehouseManagerPhone = warehouseManagerPhone;
    }

    private int totalGenerators;
    private int totalParts;
    private int lowStockParts;

    public int getTotalGenerators() {
        return totalGenerators;
    }

    public void setTotalGenerators(int totalGenerators) {
        this.totalGenerators = totalGenerators;
    }

    public int getTotalParts() {
        return totalParts;
    }

    public void setTotalParts(int totalParts) {
        this.totalParts = totalParts;
    }

    public int getLowStockParts() {
        return lowStockParts;
    }

    public void setLowStockParts(int lowStockParts) {
        this.lowStockParts = lowStockParts;
    }
}