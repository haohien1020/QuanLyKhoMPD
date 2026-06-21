package model;

public class GroupedGeneratorInventory {
    private String generatorName;
    private String brand;
    private String powerValue;
    private String fuelType;
    private int inStockCount;
    private int rentedCount;
    private int maintenanceCount;
    private int totalCount;

    public GroupedGeneratorInventory() {
    }

    public GroupedGeneratorInventory(String generatorName, String brand, String powerValue, String fuelType, int inStockCount, int rentedCount, int maintenanceCount, int totalCount) {
        this.generatorName = generatorName;
        this.brand = brand;
        this.powerValue = powerValue;
        this.fuelType = fuelType;
        this.inStockCount = inStockCount;
        this.rentedCount = rentedCount;
        this.maintenanceCount = maintenanceCount;
        this.totalCount = totalCount;
    }

    public String getGeneratorName() {
        return generatorName;
    }

    public void setGeneratorName(String generatorName) {
        this.generatorName = generatorName;
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

    public int getInStockCount() {
        return inStockCount;
    }

    public void setInStockCount(int inStockCount) {
        this.inStockCount = inStockCount;
    }

    public int getRentedCount() {
        return rentedCount;
    }

    public void setRentedCount(int rentedCount) {
        this.rentedCount = rentedCount;
    }

    public int getMaintenanceCount() {
        return maintenanceCount;
    }

    public void setMaintenanceCount(int maintenanceCount) {
        this.maintenanceCount = maintenanceCount;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }
}
