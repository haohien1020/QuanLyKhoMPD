package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class CustomerRentalContract {

    private int rentalContractId;
    private int customerId;
    private int warehouseId;
    private String contractCode;
    private String customerName;
    private String warehouseName;
    private Timestamp startDate;
    private Timestamp expectedReturnDate;
    private Timestamp actualReturnDate;
    private String status;
    private BigDecimal depositAmount;
    private BigDecimal totalAmount;
    private String note;
    private int generatorCount;

    public int getRentalContractId() {
        return rentalContractId;
    }

    public void setRentalContractId(int rentalContractId) {
        this.rentalContractId = rentalContractId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getContractCode() {
        return contractCode;
    }

    public void setContractCode(String contractCode) {
        this.contractCode = contractCode;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getExpectedReturnDate() {
        return expectedReturnDate;
    }

    public void setExpectedReturnDate(Timestamp expectedReturnDate) {
        this.expectedReturnDate = expectedReturnDate;
    }

    public Timestamp getActualReturnDate() {
        return actualReturnDate;
    }

    public void setActualReturnDate(Timestamp actualReturnDate) {
        this.actualReturnDate = actualReturnDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public int getGeneratorCount() {
        return generatorCount;
    }

    public void setGeneratorCount(int generatorCount) {
        this.generatorCount = generatorCount;
    }
}
