// lead-import.js
// Quản lý tương tác và chống double-submit cho luồng Import Lead (S4-02)

document.addEventListener("DOMContentLoaded", function() {
    
    // 1. Quản lý form Xem trước (Preview Phase)
    const importForm = document.getElementById("importForm");
    const excelFile = document.getElementById("excelFile");
    const btnPreview = document.getElementById("btnPreview");

    if (importForm) {
        importForm.addEventListener("submit", function(e) {
            // Client validation kiểm tra file đầu vào trước khi submit
            if (excelFile && excelFile.files) {
                if (excelFile.files.length === 0) {
                    e.preventDefault();
                    alert("Vui lòng chọn file Excel để xem trước dữ liệu.");
                    return;
                }

                const fileName = excelFile.files[0].name.toLowerCase();
                if (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls")) {
                    e.preventDefault();
                    alert("Định dạng file không hợp lệ. Vui lòng chọn file Excel có đuôi .xlsx hoặc .xls.");
                    return;
                }
            }

            // Chống double-submit cho nút Xem trước
            if (btnPreview) {
                if (btnPreview.disabled) {
                    e.preventDefault();
                    return;
                }
                btnPreview.disabled = true;
                btnPreview.setAttribute("aria-disabled", "true");
                btnPreview.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang xem trước...';
            }
        });
    }

    // 2. Quản lý form Lưu dữ liệu (Commit Phase)
    const commitForm = document.getElementById("commitForm");
    const btnCommit = document.getElementById("btnCommit");

    if (commitForm) {
        commitForm.addEventListener("submit", function(e) {
            // Chống double-submit hoặc submit khi nút đang bị disabled từ JSP
            if (btnCommit) {
                if (btnCommit.disabled) {
                    e.preventDefault();
                    return;
                }
                btnCommit.disabled = true;
                btnCommit.setAttribute("aria-disabled", "true");
                btnCommit.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang import...';
            }
        });
    }
});
