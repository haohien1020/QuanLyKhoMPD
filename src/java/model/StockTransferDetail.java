package model;

public class StockTransferDetail {

    private int detailId;
    private int transferId;
    private String itemType;
    private Integer generatorId;
    private Integer partId;
    private int quantity;

    public StockTransferDetail() {
    }

    public StockTransferDetail(int detailId, int transferId, String itemType, Integer generatorId, Integer partId, int quantity) {
        this.detailId = detailId;
        this.transferId = transferId;
        this.itemType = itemType;
        this.generatorId = generatorId;
        this.partId = partId;
        this.quantity = quantity;
    }

    public int getDetailId() {
        return detailId;
    }

    public void setDetailId(int detailId) {
        this.detailId = detailId;
    }

    public int getTransferId() {
        return transferId;
    }

    public void setTransferId(int transferId) {
        this.transferId = transferId;
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
}