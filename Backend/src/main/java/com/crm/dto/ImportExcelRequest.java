package com.crm.dto;

import java.io.InputStream;

public class ImportExcelRequest {
    private String entityType; // CUSTOMER, PRODUCT, LEAD, etc.
    private String fileName;
    private InputStream fileStream;
    private long fileSize;
    private boolean updateExisting;

    public ImportExcelRequest() {}

    public ImportExcelRequest(String entityType, String fileName, InputStream fileStream, long fileSize, boolean updateExisting) {
        this.entityType = entityType;
        this.fileName = fileName;
        this.fileStream = fileStream;
        this.fileSize = fileSize;
        this.updateExisting = updateExisting;
    }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public InputStream getFileStream() { return fileStream; }
    public void setFileStream(InputStream fileStream) { this.fileStream = fileStream; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public boolean isUpdateExisting() { return updateExisting; }
    public void setUpdateExisting(boolean updateExisting) { this.updateExisting = updateExisting; }
}
