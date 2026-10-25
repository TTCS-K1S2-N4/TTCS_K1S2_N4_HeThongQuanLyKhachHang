package com.crm.dto;

import java.math.BigDecimal;

public class ProductRequest {
    private Integer productId;
    private String productCode;
    private String productName;
    private String productType; // ONE_TIME | SUBSCRIPTION
    private String unit;
    private BigDecimal listPrice;
    private BigDecimal floorPrice;
    private BigDecimal costPrice;
    private String status; // ACTIVE | INACTIVE

    public ProductRequest() {
    }

    public ProductRequest(Integer productId, String productCode, String productName, String productType,
                          String unit, BigDecimal listPrice, BigDecimal floorPrice, BigDecimal costPrice,
                          String status) {
        this.productId = productId;
        this.productCode = productCode;
        this.productName = productName;
        this.productType = productType;
        this.unit = unit;
        this.listPrice = listPrice;
        this.floorPrice = floorPrice;
        this.costPrice = costPrice;
        this.status = status;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public void setListPrice(BigDecimal listPrice) {
        this.listPrice = listPrice;
    }

    public BigDecimal getFloorPrice() {
        return floorPrice;
    }

    public void setFloorPrice(BigDecimal floorPrice) {
        this.floorPrice = floorPrice;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
