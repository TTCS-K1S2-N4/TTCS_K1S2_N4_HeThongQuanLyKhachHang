// lead-web-form.js

document.addEventListener("DOMContentLoaded", function() {
    // Copy embed code functionality
    const btnCopyEmbed = document.getElementById("btnCopyEmbed");
    const embedSnippet = document.getElementById("embedSnippet");
    const copyFeedback = document.getElementById("copyFeedback");

    if (btnCopyEmbed && embedSnippet) {
        btnCopyEmbed.addEventListener("click", function() {
            embedSnippet.select();
            embedSnippet.setSelectionRange(0, 99999); /* For mobile devices */

            try {
                navigator.clipboard.writeText(embedSnippet.value).then(function() {
                    copyFeedback.style.display = "inline";
                    setTimeout(function() {
                        copyFeedback.style.display = "none";
                    }, 2000);
                });
            } catch (err) {
                // Fallback for older browsers
                document.execCommand("copy");
                copyFeedback.style.display = "inline";
                setTimeout(function() {
                    copyFeedback.style.display = "none";
                }, 2000);
            }
        });
    }

    // Public form double submit prevention
    const publicLeadForm = document.getElementById("publicLeadForm");
    if (publicLeadForm) {
        publicLeadForm.addEventListener("submit", function(e) {
            const btnSubmit = this.querySelector('button[type="submit"]');
            if (btnSubmit) {
                if (btnSubmit.disabled) {
                    e.preventDefault(); // Prevent if already submitted
                    return;
                }
                btnSubmit.disabled = true;
                btnSubmit.textContent = "Đang gửi...";
            }
        });
    }
});
