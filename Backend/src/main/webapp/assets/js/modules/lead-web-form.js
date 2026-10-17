// lead-web-form.js
// Hỗ trợ chức năng sao chép mã nhúng và chống double-submit cho Web Form (S4-01)

document.addEventListener("DOMContentLoaded", function() {
    
    // 1. Sao chép mã nhúng (Embed Code Copy)
    const btnCopyEmbed = document.getElementById("btnCopyEmbed");
    const embedSnippet = document.getElementById("embedSnippet");
    const copyFeedback = document.getElementById("copyFeedback");

    function showFeedback(text, isSuccess) {
        if (!copyFeedback) return;
        copyFeedback.textContent = text;
        copyFeedback.style.color = isSuccess ? "#16a34a" : "#dc2626";
        copyFeedback.style.display = "inline";
        setTimeout(function() {
            copyFeedback.style.display = "none";
        }, 2500);
    }

    function fallbackCopy(text) {
        try {
            const successful = document.execCommand("copy");
            if (successful) {
                showFeedback("Đã sao chép vào bộ nhớ tạm!", true);
            } else {
                showFeedback("Không thể sao chép tự động. Vui lòng copy thủ công.", false);
            }
        } catch (err) {
            showFeedback("Không thể sao chép tự động. Vui lòng copy thủ công.", false);
        }
    }

    if (btnCopyEmbed && embedSnippet) {
        btnCopyEmbed.addEventListener("click", function() {
            const textToCopy = embedSnippet.value;
            if (!textToCopy || textToCopy.trim() === "") {
                showFeedback("Không có mã nhúng để sao chép.", false);
                return;
            }

            embedSnippet.select();
            embedSnippet.setSelectionRange(0, 99999); /* Dành cho thiết bị di động */

            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(textToCopy).then(function() {
                    showFeedback("Đã sao chép vào bộ nhớ tạm!", true);
                }).catch(function() {
                    fallbackCopy(textToCopy);
                });
            } else {
                fallbackCopy(textToCopy);
            }
        });
    }

    // 2. Chống double-submit cho Public Lead Form
    const publicLeadForm = document.getElementById("publicLeadForm");
    if (publicLeadForm) {
        publicLeadForm.addEventListener("submit", function(e) {
            // Nếu form có native HTML validation không hợp lệ, không disable nút
            if (typeof this.checkValidity === "function" && !this.checkValidity()) {
                return;
            }

            const btnSubmit = this.querySelector('button[type="submit"]');
            if (btnSubmit) {
                if (btnSubmit.disabled) {
                    e.preventDefault(); // Ngăn submit lặp nếu nút đã bị vô hiệu hóa
                    return;
                }
                btnSubmit.disabled = true;
                btnSubmit.setAttribute("aria-disabled", "true");
                btnSubmit.textContent = "Đang gửi...";
            }
        });
    }
});
