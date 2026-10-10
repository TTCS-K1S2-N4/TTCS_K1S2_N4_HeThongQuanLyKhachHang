// lead-import.js

document.addEventListener("DOMContentLoaded", function() {
    
    // Prevent double submit on preview form
    const importForm = document.getElementById("importForm");
    if (importForm) {
        importForm.addEventListener("submit", function(e) {
            const btnPreview = document.getElementById("btnPreview");
            if (btnPreview) {
                if (btnPreview.disabled) {
                    e.preventDefault();
                    return;
                }
                btnPreview.disabled = true;
                btnPreview.textContent = "Đang xử lý...";
            }
        });
    }

    // Prevent double submit on commit form
    const commitForm = document.getElementById("commitForm");
    if (commitForm) {
        commitForm.addEventListener("submit", function(e) {
            const btnCommit = document.getElementById("btnCommit");
            if (btnCommit) {
                if (btnCommit.disabled) {
                    e.preventDefault();
                    return;
                }
                btnCommit.disabled = true;
                btnCommit.textContent = "Đang lưu...";
            }
        });
    }
});
