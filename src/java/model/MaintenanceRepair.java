package model;

import java.sql.Timestamp;

public class MaintenanceRepair {

    private int repairId;
    private int generatorId;
    private int reportedBy;
    private Integer assignedTo;
    private String issueDescription;
    private String repairStatus;
    private Timestamp createdAt;
    private Timestamp completedAt;

    public MaintenanceRepair() {
    }

    public MaintenanceRepair(int repairId, int generatorId, int reportedBy, Integer assignedTo, String issueDescription, String repairStatus, Timestamp createdAt, Timestamp completedAt) {
        this.repairId = repairId;
        this.generatorId = generatorId;
        this.reportedBy = reportedBy;
        this.assignedTo = assignedTo;
        this.issueDescription = issueDescription;
        this.repairStatus = repairStatus;
        this.createdAt = createdAt;
        this.completedAt = completedAt;
    }

    public int getRepairId() {
        return repairId;
    }

    public void setRepairId(int repairId) {
        this.repairId = repairId;
    }

    public int getGeneratorId() {
        return generatorId;
    }

    public void setGeneratorId(int generatorId) {
        this.generatorId = generatorId;
    }

    public int getReportedBy() {
        return reportedBy;
    }

    public void setReportedBy(int reportedBy) {
        this.reportedBy = reportedBy;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public void setIssueDescription(String issueDescription) {
        this.issueDescription = issueDescription;
    }

    public String getRepairStatus() {
        return repairStatus;
    }

    public void setRepairStatus(String repairStatus) {
        this.repairStatus = repairStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }
}