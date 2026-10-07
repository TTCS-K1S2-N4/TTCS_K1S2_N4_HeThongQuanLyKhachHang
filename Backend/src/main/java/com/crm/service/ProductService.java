package com.crm.service;

import com.crm.dao.ProductDAO;
import com.crm.dto.ProductRequest;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Account;
import com.crm.model.Product;

import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;
public class ProductService {

    private final ProductDAO productDAO;
    private PermissionService permissionService;

    public ProductService() {
        this.productDAO = new ProductDAO();
        this.permissionService = new PermissionService();
    }

    public ProductService(ProductDAO productDAO) {
        this.productDAO = Objects.requireNonNull(productDAO, "ProductDAO không được để null");
        this.permissionService = new PermissionService();
    }

    public ProductService(ProductDAO productDAO, PermissionService permissionService) {
        this.productDAO = Objects.requireNonNull(productDAO, "ProductDAO không được để null");
        this.permissionService = Objects.requireNonNull(permissionService, "PermissionService không được để null");
    }

    public void setPermissionService(PermissionService permissionService) {
        if (permissionService != null) {
            this.permissionService = permissionService;
        }
    }

    /**
     * Kiểm tra quyền quản lý danh mục sản phẩm (Tạo, Sửa, Đổi trạng thái).
     * Kiểm tra permission PRODUCT_MANAGE thông qua PermissionService.
     */
    public boolean canManageProducts(Account user) {
        if (user == null)
            return false;
        List<Integer> roleIds = user.getRoleIds();
        if (roleIds != null && !roleIds.isEmpty()) {
            return permissionService.hasPermissionForRoles(roleIds, "PRODUCT_MANAGE");
        }
        if (user.getRoleId() != null && user.getRoleId() > 0) {
            return permissionService.hasPermission(user.getRoleId(), "PRODUCT_MANAGE");
        }
        return false;
    }

    /**
     * CENTRALIZED PERMISSION CHECK FOR COST PRICE (SOURCE CONFLICT #1).
     * Theo Acceptance Criteria AC3: Giá vốn chỉ Giám đốc kinh doanh (DIRECTOR) xem
     * và sửa được.
     */
    public boolean isCostPriceAllowed(Account user) {
        if (user == null)
            return false;
        List<Integer> roleIds = user.getRoleIds();
        if (roleIds != null && !roleIds.isEmpty()) {
            if (permissionService.canViewProductCost(roleIds)) {
                return true;
            }
        }
        if (user.getRoleId() != null && user.getRoleId() > 0) {
            if (permissionService.hasPermission(user.getRoleId(), "PRODUCT_COST_VIEW")) {
                return true;
            }
        }
        List<String> roleCodes = user.getRoleCodes();
        if (roleCodes != null && !roleCodes.isEmpty()) {
            for (String code : roleCodes) {
                if ("DIRECTOR".equalsIgnoreCase(code) || "ADMIN".equalsIgnoreCase(code)) {
                    return true;
                }
            }
        }
        // Legacy fallback check
        if (user.getRoleName() != null) {
            String roleNameUpper = user.getRoleName().toUpperCase();
            if (roleNameUpper.contains("DIRECTOR") || roleNameUpper.contains("GIÁM ĐỐC KINH DOANH") || roleNameUpper.contains("ADMIN")) {
                return true;
            }
        }
        return false;
    }

    public List<Product> getProducts(String keyword, String productType, String status, int page, int pageSize,
            Account user) {
        boolean includeCostPrice = isCostPriceAllowed(user);
        int safePage = Math.max(1, page);
        int safePageSize = pageSize > 0 ? pageSize : 20;
        return productDAO.getList(keyword, productType, status, includeCostPrice, safePage, safePageSize);
    }

    public int getTotalCount(String keyword, String productType, String status) {
        return productDAO.count(keyword, productType, status);
    }

    public Product getProductById(int productId, Account user) {
        if (productId <= 0)
            return null;
        boolean includeCostPrice = isCostPriceAllowed(user);
        return productDAO.getById(productId, includeCostPrice);
    }

    public boolean createProduct(ProductRequest request, Account user)
            throws ValidationException, AuthorizationException {
        if (!canManageProducts(user)) {
            throw new AuthorizationException("Bạn không có quyền khai báo sản phẩm/dịch vụ mới.");
        }

        boolean includeCostPrice = isCostPriceAllowed(user);
        validateProductRequest(request, false, includeCostPrice);

        Product product = new Product();
        product.setProductCode(request.getProductCode().trim());
        product.setProductName(request.getProductName().trim());
        product.setProductType(request.getProductType().trim().toUpperCase());
        product.setUnit(request.getUnit().trim());
        product.setListPrice(request.getListPrice());
        product.setFloorPrice(request.getFloorPrice());

        if (includeCostPrice) {
            product.setCostPrice(request.getCostPrice());
        } else {
            product.setCostPrice(null);
        }

        String status = request.getStatus();
        if (status == null || status.trim().isEmpty()) {
            status = "ACTIVE";
        } else {
            status = status.trim().toUpperCase();
        }
        product.setStatus(status);

        com.crm.model.AuditLog log = new com.crm.model.AuditLog();
        log.setAction("DISCOUNT_CREATE");
        log.setUserId(user != null ? user.getAccountId() : 0);
        log.setDetails("Tạo sản phẩm và thiết lập chiết khấu/bảng giá mã " + product.getProductCode());
        log.setOldValue("N/A");
        log.setNewValue("ListPrice: " + product.getListPrice() + ", FloorPrice: " + product.getFloorPrice());

        return productDAO.create(product, includeCostPrice, log);
    }

    public boolean updateProduct(ProductRequest request, Account user)
            throws ValidationException, AuthorizationException {
        if (!canManageProducts(user)) {
            throw new AuthorizationException("Bạn không có quyền chỉnh sửa thông tin sản phẩm/dịch vụ.");
        }

        boolean includeCostPrice = isCostPriceAllowed(user);
        validateProductRequest(request, true, includeCostPrice);

        Product product = new Product();
        product.setProductId(request.getProductId());
        product.setProductCode(request.getProductCode().trim());
        product.setProductName(request.getProductName().trim());
        product.setProductType(request.getProductType().trim().toUpperCase());
        product.setUnit(request.getUnit().trim());
        product.setListPrice(request.getListPrice());
        product.setFloorPrice(request.getFloorPrice());

        if (includeCostPrice) {
            product.setCostPrice(request.getCostPrice());
        } else {
            product.setCostPrice(null);
        }

        String status = request.getStatus();
        if (status == null || status.trim().isEmpty()) {
            status = "ACTIVE";
        } else {
            status = status.trim().toUpperCase();
        }
        product.setStatus(status);

        Product oldProduct = productDAO.getById(product.getProductId(), true);

        com.crm.model.AuditLog log = new com.crm.model.AuditLog();
        log.setAction("DISCOUNT_UPDATE");
        log.setUserId(user != null ? user.getAccountId() : 0);
        log.setTargetUserId(product.getProductId());
        log.setDetails("Cập nhật chiết khấu/bảng giá cho sản phẩm mã " + product.getProductCode());
        if (oldProduct != null) {
            log.setOldValue("Giá niêm yết: " + oldProduct.getListPrice() + ", Giá sàn: " + oldProduct.getFloorPrice() + ", Trạng thái: " + oldProduct.getStatus());
        } else {
            log.setOldValue("Product ID: " + product.getProductId());
        }
        log.setNewValue("Giá niêm yết: " + product.getListPrice() + ", Giá sàn: " + product.getFloorPrice() + ", Trạng thái: " + product.getStatus());

        return productDAO.update(product, includeCostPrice, log);
    }

    public boolean updateProductStatus(int productId, String status, Account user)
            throws ValidationException, AuthorizationException {
        if (!canManageProducts(user)) {
            throw new AuthorizationException("Bạn không have quyền thay đổi trạng thái kinh doanh của sản phẩm.");
        }

        if (productId <= 0 || !productDAO.exists(productId)) {
            throw new ValidationException("Sản phẩm không tồn tại trong hệ thống.");
        }

        if (status == null
                || (!"ACTIVE".equalsIgnoreCase(status.trim()) && !"INACTIVE".equalsIgnoreCase(status.trim()))) {
            throw new ValidationException("Trạng thái sản phẩm không hợp lệ (chỉ nhận ACTIVE hoặc INACTIVE).");
        }

        Product oldProduct = productDAO.getById(productId, true);

        com.crm.model.AuditLog log = new com.crm.model.AuditLog();
        log.setAction("DISCOUNT_STATUS_CHANGE");
        log.setUserId(user != null ? user.getAccountId() : 0);
        log.setTargetUserId(productId);
        log.setDetails("Thay đổi trạng thái kinh doanh/chiết khấu sản phẩm " + (oldProduct != null ? oldProduct.getProductName() : ("ID " + productId)));
        log.setOldValue("Trạng thái: " + (oldProduct != null ? oldProduct.getStatus() : "N/A"));
        log.setNewValue("Trạng thái: " + status.trim().toUpperCase());

        return productDAO.updateStatus(productId, status.trim().toUpperCase(), log);
    }

    private void validateProductRequest(ProductRequest request, boolean isUpdate, boolean includeCostPrice)
            throws ValidationException {
        if (request == null) {
            throw new ValidationException("Dữ liệu yêu cầu sản phẩm không được để null.");
        }

        if (isUpdate) {
            if (request.getProductId() == null || request.getProductId() <= 0) {
                throw new ValidationException("ID sản phẩm không hợp lệ.");
            }
            if (!productDAO.exists(request.getProductId())) {
                throw new ValidationException("Sản phẩm không tồn tại trong hệ thống.");
            }
        }

        if (request.getProductCode() == null || request.getProductCode().trim().isEmpty()) {
            throw new ValidationException("Mã sản phẩm không được để trống.");
        }

        if (request.getProductName() == null || request.getProductName().trim().isEmpty()) {
            throw new ValidationException("Tên sản phẩm không được để trống.");
        }

        String type = request.getProductType();
        if (type == null
                || (!"ONE_TIME".equalsIgnoreCase(type.trim()) && !"SUBSCRIPTION".equalsIgnoreCase(type.trim()))) {
            throw new ValidationException("Loại sản phẩm không hợp lệ (chỉ nhận ONE_TIME hoặc SUBSCRIPTION).");
        }

        if (request.getUnit() == null || request.getUnit().trim().isEmpty()) {
            throw new ValidationException("Đơn vị tính không được để trống.");
        }

        if (request.getListPrice() == null || request.getListPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new ValidationException("Giá niêm yết không hợp lệ và phải lớn hơn hoặc bằng 0.");
        }

        if (request.getFloorPrice() == null || request.getFloorPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new ValidationException("Giá sàn không hợp lệ và phải lớn hơn hoặc bằng 0.");
        }

        if (request.getListPrice() != null && request.getFloorPrice() != null) {
            if (request.getFloorPrice().compareTo(request.getListPrice()) > 0) {
                throw new ValidationException("Giá sàn không được lớn hơn giá niêm yết.");
            }
        }

        if (includeCostPrice && request.getCostPrice() != null) {
            if (request.getCostPrice().compareTo(BigDecimal.ZERO) < 0) {
                throw new ValidationException("Giá vốn không hợp lệ và phải lớn hơn hoặc bằng 0.");
            }
        }

        // Duplicate code check
        Integer excludeId = isUpdate ? request.getProductId() : null;
        if (productDAO.isCodeExists(request.getProductCode().trim(), excludeId)) {
            throw new ValidationException(
                    "Mã sản phẩm '" + request.getProductCode().trim() + "' đã tồn tại trong hệ thống.");
        }
    }

    public boolean deleteProduct(int productId, Account user) throws ValidationException, AuthorizationException {
        if (!canManageProducts(user)) {
            throw new AuthorizationException("Bạn không có quyền xóa sản phẩm/dịch vụ.");
        }

        if (productId <= 0 || !productDAO.exists(productId)) {
            throw new ValidationException("Sản phẩm không tồn tại trong hệ thống.");
        }

        if (productDAO.isProductUsedInQuotes(productId)) {
            throw new ValidationException("Sản phẩm đã xuất hiện trong báo giá, không thể xóa. Bạn chỉ có thể chuyển sang trạng thái Ngừng hoạt động (INACTIVE).");
        }

        Product oldProduct = productDAO.getById(productId, true);

        com.crm.model.AuditLog log = new com.crm.model.AuditLog();
        log.setAction("DISCOUNT_DELETE");
        log.setUserId(user != null ? user.getAccountId() : 0);
        log.setTargetUserId(productId);
        log.setDetails("Xóa sản phẩm " + (oldProduct != null ? oldProduct.getProductName() : ("ID " + productId)));
        log.setOldValue("Sản phẩm mã: " + (oldProduct != null ? oldProduct.getProductCode() : "N/A"));
        log.setNewValue("Đã xóa khỏi hệ thống");

        return productDAO.delete(productId, log);
    }
}
