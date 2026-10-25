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

    // 2. Chống double-submit, Validate và Gửi Lead qua AJAX cho Public Lead Form
    const publicLeadForm = document.getElementById("publicLeadForm");
    const clientAlertBox = document.getElementById("clientAlertBox");
    const clientAlertMsg = document.getElementById("clientAlertMsg");
    const serverAlertBox = document.getElementById("serverAlertBox");
    const ajaxSuccessBox = document.getElementById("ajaxSuccessBox");
    const ajaxSuccessMsg = document.getElementById("ajaxSuccessMsg");
    const btnSubmitAnother = document.getElementById("btnSubmitAnother");

    function showClientError(message, targetInput) {
        if (serverAlertBox) serverAlertBox.style.display = "none";
        if (clientAlertBox && clientAlertMsg) {
            clientAlertMsg.textContent = message;
            clientAlertBox.style.display = "flex";
            clientAlertBox.scrollIntoView({ behavior: "smooth", block: "center" });
        } else {
            alert(message);
        }
        if (targetInput && typeof targetInput.focus === "function") {
            targetInput.focus();
        }
    }

    function hideClientError() {
        if (clientAlertBox) clientAlertBox.style.display = "none";
        if (serverAlertBox) serverAlertBox.style.display = "none";
    }

    if (publicLeadForm) {
        const btnSubmit = document.getElementById("btnSubmitLead") || publicLeadForm.querySelector('button[type="submit"]');
        const originalBtnHtml = btnSubmit ? btnSubmit.innerHTML : "<span>Gửi thông tin tư vấn</span>";

        function resetSubmitButton() {
            if (btnSubmit) {
                btnSubmit.disabled = false;
                btnSubmit.removeAttribute("aria-disabled");
                btnSubmit.innerHTML = originalBtnHtml;
            }
        }

        publicLeadForm.addEventListener("submit", function(e) {
            e.preventDefault(); // Kiểm soát toàn bộ quá trình qua AJAX để có trải nghiệm tối ưu

            // Nếu đang trong quá trình gửi, ngăn chặn click đúp
            if (btnSubmit && btnSubmit.disabled) {
                return;
            }

            hideClientError();

            // Client-side Validation cơ bản
            const fullNameInput = document.getElementById("fullName");
            const emailInput = document.getElementById("email");
            const phoneInput = document.getElementById("phone");

            const fullName = fullNameInput ? fullNameInput.value.trim() : "";
            const email = emailInput ? emailInput.value.trim() : "";
            const phone = phoneInput ? phoneInput.value.trim() : "";

            if (!fullName) {
                showClientError("Vui lòng nhập Họ và tên của bạn.", fullNameInput);
                return;
            }

            if (!email) {
                showClientError("Vui lòng nhập Email liên hệ.", emailInput);
                return;
            }

            const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
            if (!emailRegex.test(email)) {
                showClientError("Địa chỉ email không đúng định dạng (VD: example@domain.com).", emailInput);
                return;
            }

            if (!phone) {
                showClientError("Vui lòng nhập Số điện thoại.", phoneInput);
                return;
            }

            const cleanPhone = phone.replace(/[\s\-\.]/g, "");
            const phoneRegex = /^(0|\+?84)[35789][0-9]{8}$/;
            if (!phoneRegex.test(cleanPhone)) {
                showClientError("Số điện thoại không hợp lệ. Vui lòng nhập 10 chữ số (VD: 0912345678).", phoneInput);
                return;
            }

            // Chuyển nút sang trạng thái đang xử lý
            if (btnSubmit) {
                btnSubmit.disabled = true;
                btnSubmit.setAttribute("aria-disabled", "true");
                btnSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> <span>Đang gửi thông tin...</span>';
            }

            // Đóng gói dữ liệu form
            const formData = new FormData(publicLeadForm);
            const searchParams = new URLSearchParams();
            for (const pair of formData.entries()) {
                searchParams.append(pair[0], pair[1]);
            }

            // Gửi dữ liệu thật tới endpoint backend
            fetch(publicLeadForm.action, {
                method: "POST",
                headers: {
                    "Accept": "application/json",
                    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: searchParams.toString()
            })
            .then(async function(response) {
                let data = null;
                try {
                    data = await response.json();
                } catch (parseErr) {
                    // Phản hồi không phải JSON
                }

                if (response.ok && data && data.status === "success") {
                    // Nếu biểu mẫu có cấu hình trang chuyển hướng thành công
                    if (data.redirectUrl && data.redirectUrl.trim() !== "") {
                        window.location.href = data.redirectUrl;
                        return;
                    }

                    // Chuyển sang giao diện thông báo thành công
                    publicLeadForm.style.display = "none";
                    if (ajaxSuccessBox) {
                        if (ajaxSuccessMsg && data.message) {
                            ajaxSuccessMsg.textContent = data.message;
                        }
                        ajaxSuccessBox.style.display = "block";
                        ajaxSuccessBox.scrollIntoView({ behavior: "smooth", block: "center" });
                    }
                } else {
                    const message = (data && data.message)
                        ? data.message
                        : ("Lỗi (" + response.status + "): Không thể gửi thông tin. Vui lòng thử lại sau.");
                    showClientError(message);
                    resetSubmitButton();
                }
            })
            .catch(function(err) {
                showClientError("Không thể kết nối đến máy chủ CRM. Vui lòng kiểm tra kết nối mạng và thử lại.");
                resetSubmitButton();
            });
        });

        // Xử lý nút "Gửi thêm phản hồi khác"
        if (btnSubmitAnother) {
            btnSubmitAnother.addEventListener("click", function() {
                publicLeadForm.reset();
                hideClientError();
                resetSubmitButton();
                if (ajaxSuccessBox) ajaxSuccessBox.style.display = "none";
                publicLeadForm.style.display = "block";
                publicLeadForm.scrollIntoView({ behavior: "smooth", block: "start" });
            });
        }
    }
});
