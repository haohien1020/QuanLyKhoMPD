package model;

import java.math.BigDecimal;

public class PurchaseOrderDetail {

    private int detailId;
    private int purchaseOrderId;
    private Integer partId;
    private String itemName;
    private int quantity;
    private BigDecimal unitPrice;

    public PurchaseOrderDetail() {
    }

    public PurchaseOrderDetail(int detailId, int purchaseOrderId, Integer partId, String itemName, int quantity, BigDecimal unitPrice) {
        this.detailId = detailId;
        this.purchaseOrderId = purchaseOrderId;
        this.partId = partId;
        this.itemName = itemName;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public int getDetailId() {
        return detailId;
    }

    public void setDetailId(int detailId) {
        this.detailId = detailId;
    }

    public int getPurchaseOrderId() {
        return purchaseOrderId;
    }

    public void setPurchaseOrderId(int purchaseOrderId) {
        this.purchaseOrderId = purchaseOrderId;
    }

    public Integer getPartId() {
        return partId;
    }

    public void setPartId(Integer partId) {
        this.partId = partId;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
}