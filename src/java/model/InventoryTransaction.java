package model;

import java.sql.Timestamp;

public class InventoryTransaction {

    private int transactionId;
    private int warehouseId;
    private Integer supplierId;
    private int createdBy;
    private String transactionType;
    private String itemType;
    private Integer generatorId;
    private Integer partId;
    private int quantity;
    private Timestamp transactionDate;
    private String note;
    private String status;

    public InventoryTransaction() {
    }

    public InventoryTransaction(int transactionId, int warehouseId, Integer supplierId, int createdBy, String transactionType, String itemType, Integer generatorId, Integer partId, int quantity, Timestamp transactionDate, String note, String status) {
        this.transactionId = transactionId;
        this.warehouseId = warehouseId;
        this.supplierId = supplierId;
        this.createdBy = createdBy;
        this.transactionType = transactionType;
        this.itemType = itemType;
        this.generatorId = generatorId;
        this.partId = partId;
        this.quantity = quantity;
        this.transactionDate = transactionDate;
        this.note = note;
        this.status = status;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
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

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public Integer getGeneratorId() {
        return generatorId;
    }

    public void setGeneratorId(Integer generatorId) {
        this.generatorId = generatorId;
    }

    public Integer getPartId() {
        return partId;
    }

    public void setPartId(Integer partId) {
        this.partId = partId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}