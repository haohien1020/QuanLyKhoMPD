package model;

public class PurchaseRequestDetail {

    private int detailId;
    private int purchaseRequestId;
    private Integer partId;
    private String itemName;
    private int quantity;

    public PurchaseRequestDetail() {
    }

    public PurchaseRequestDetail(int detailId, int purchaseRequestId, Integer partId, String itemName, int quantity) {
        this.detailId = detailId;
        this.purchaseRequestId = purchaseRequestId;
        this.partId = partId;
        this.itemName = itemName;
        this.quantity = quantity;
    }

    public int getDetailId() {
        return detailId;
    }

    public void setDetailId(int detailId) {
        this.detailId = detailId;
    }

    public int getPurchaseRequestId() {
        return purchaseRequestId;
    }

    public void setPurchaseRequestId(int purchaseRequestId) {
        this.purchaseRequestId = purchaseRequestId;
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
}