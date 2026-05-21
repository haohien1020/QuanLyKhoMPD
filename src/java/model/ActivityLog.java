package model;

import java.sql.Timestamp;

public class ActivityLog {

    private int logId;
    private Integer userId;
    private String action;
    private String tableName;
    private Integer recordId;
    private String description;
    private Timestamp createdAt;

    public ActivityLog() {
    }

    public ActivityLog(int logId, Integer userId, String action, String tableName, Integer recordId, String description, Timestamp createdAt) {
        this.logId = logId;
        this.userId = userId;
        this.action = action;
        this.tableName = tableName;
        this.recordId = recordId;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public Integer getRecordId() {
        return recordId;
    }

    public void setRecordId(Integer recordId) {
        this.recordId = recordId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}