package model;

import java.sql.Timestamp;

public class ReportExport {

    private int reportId;
    private int createdBy;
    private String reportName;
    private String reportType;
    private String fileType;
    private String filePath;
    private Timestamp createdAt;

    public ReportExport() {
    }

    public ReportExport(int reportId, int createdBy, String reportName, String reportType, String fileType, String filePath, Timestamp createdAt) {
        this.reportId = reportId;
        this.createdBy = createdBy;
        this.reportName = reportName;
        this.reportType = reportType;
        this.fileType = fileType;
        this.filePath = filePath;
        this.createdAt = createdAt;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getReportName() {
        return reportName;
    }

    public void setReportName(String reportName) {
        this.reportName = reportName;
    }

    public String getReportType() {
        return reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = reportType;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}