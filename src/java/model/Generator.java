package model;

import java.sql.Timestamp;
import java.math.BigDecimal;

public class Generator {

    private int generatorId;
    private int warehouseId;
    private Integer supplierId;
    private String generatorName;
    private String serialNumber;
    private String brand;
    private String powerValue;
    private String fuelType;
    private String originType;
    private Timestamp importDate;
    private BigDecimal purchasePrice;
    private String location;
    private String status;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Generator() {
    }

    public Generator(int generatorId, int warehouseId, Integer supplierId, String generatorName, String serialNumber, String brand, String powerValue, String fuelType, String originType, Timestamp importDate, BigDecimal purchasePrice, String location, String status, String note, Timestamp createdAt, Timestamp updatedAt) {
        this.generatorId = generatorId;
        this.warehouseId = warehouseId;
        this.supplierId = supplierId;
        this.generatorName = generatorName;
        this.serialNumber = serialNumber;
        this.brand = brand;
        this.powerValue = powerValue;
        this.fuelType = fuelType;
        this.originType = originType;
        this.importDate = importDate;
        this.purchasePrice = purchasePrice;
        this.location = location;
        this.status = status;
        this.note = note;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getGeneratorId() {
        return generatorId;
    }

    public void setGeneratorId(int generatorId) {
        this.generatorId = generatorId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public String getGeneratorName() {
        return generatorName;
    }

    public void setGeneratorName(String generatorName) {
        this.generatorName = generatorName;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getPowerValue() {
        return powerValue;
    }

    public void setPowerValue(String powerValue) {
        this.powerValue = powerValue;
    }

    public String getFuelType() {
        return fuelType;
    }

    public void setFuelType(String fuelType) {
        this.fuelType = fuelType;
    }

    public String getOriginType() {
        return originType;
    }

    public void setOriginType(String originType) {
        this.originType = originType;
    }

    public Timestamp getImportDate() {
        return importDate;
    }

    public void setImportDate(Timestamp importDate) {
        this.importDate = importDate;
    }

    public BigDecimal getPurchasePrice() {
        return purchasePrice;
    }

    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.purchasePrice = purchasePrice;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
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