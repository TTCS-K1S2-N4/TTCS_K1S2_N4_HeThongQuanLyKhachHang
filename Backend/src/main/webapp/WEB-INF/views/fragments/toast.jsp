<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty requestScope.__crmToastComponentRendered}">
<c:set var="__crmToastComponentRendered" value="true" scope="request"/>
<style>
/* TOAST NOTIFICATION STYLES */
.toast-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
    display: flex;
    flex-direction: column;
    gap: 10px;
    pointer-events: none;
}

.toast {
    position: relative;
    display: flex;
    align-items: flex-start;
    gap: 12px;
    min-width: 300px;
    max-width: 400px;
    padding: 16px;
    background: #ffffff;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    border-left: 4px solid #3b82f6;
    pointer-events: auto;
    transform: translateX(120%);
    opacity: 0;
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
}

.toast.toast-show {
    transform: translateX(0);
    opacity: 1;
}

.toast.toast-hiding {
    transform: translateX(120%);
    opacity: 0;
}

.toast-success {
    border-left-color: #10b981;
}

.toast-error {
    border-left-color: #ef4444;
}

.toast-warning {
    border-left-color: #f59e0b;
}

.toast-info {
    border-left-color: #3b82f6;
}

.toast-icon {
    flex-shrink: 0;
    font-size: 1.25rem;
}

.toast-success .toast-icon { color: #10b981; }
.toast-error .toast-icon { color: #ef4444; }
.toast-warning .toast-icon { color: #f59e0b; }
.toast-info .toast-icon { color: #3b82f6; }

.toast-content {
    flex-grow: 1;
    font-family: 'Inter', system-ui, -apple-system, sans-serif;
}

.toast-title {
    font-weight: 600;
    font-size: 0.95rem;
    color: #1e293b;
    margin-bottom: 4px;
}

.toast-message {
    font-size: 0.875rem;
    color: #475569;
    line-height: 1.4;
}

.toast-close {
    flex-shrink: 0;
    background: transparent;
    border: none;
    color: #94a3b8;
    cursor: pointer;
    padding: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    transition: color 0.2s, background-color 0.2s;
}

.toast-close:hover {
    color: #475569;
    background-color: #f1f5f9;
}

@media (max-width: 480px) {
    .toast-container {
        top: 20px;
        left: 20px;
        right: 20px;
        align-items: center;
    }
    .toast {
        width: 100%;
        min-width: unset;
        max-width: 100%;
        transform: translateY(-120%);
    }
    .toast.toast-show {
        transform: translateY(0);
    }
    .toast.toast-hiding {
        transform: translateY(-120%);
    }
}
</style>

<div id="toast-container" class="toast-container" aria-live="polite"></div>

<script>
    (function() {
        if (window.__crmToastInitialized) {
            return;
        }
        window.__crmToastInitialized = true;

        const ICONS = {
            success: '<i class="fas fa-check-circle"></i>',
            error: '<i class="fas fa-exclamation-circle"></i>',
            warning: '<i class="fas fa-exclamation-triangle"></i>',
            info: '<i class="fas fa-info-circle"></i>'
        };

        const TITLES = {
            success: 'Thành công',
            error: 'Lỗi',
            warning: 'Cảnh báo',
            info: 'Thông báo'
        };

        const VALID_TYPES = ['success', 'error', 'warning', 'info'];

        window.showToast = function(type, message, autoDismiss = true) {
            // Defensive handling if caller passed (message, type)
            if (VALID_TYPES.includes(message) && !VALID_TYPES.includes(type)) {
                const temp = type;
                type = message;
                message = temp;
            }
            if (type === 'danger') {
                type = 'error';
            }
            if (!VALID_TYPES.includes(type)) {
                type = 'info';
            }

            if (!message) return;
            
            let container = document.getElementById('toast-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toast-container';
                container.className = 'toast-container';
                container.setAttribute('aria-live', 'polite');
                (document.body || document.documentElement).appendChild(container);
            }

            const toast = document.createElement('div');
            toast.className = 'toast toast-' + type;
            
            if (type === 'error') {
                toast.setAttribute('role', 'alert');
            }

            toast.innerHTML = `
                <div class="toast-icon">\${ICONS[type] || ICONS.info}</div>
                <div class="toast-content">
                    <div class="toast-title">\${TITLES[type] || TITLES.info}</div>
                    <div class="toast-message"></div>
                </div>
                <button class="toast-close" aria-label="Đóng"><i class="fas fa-times"></i></button>
            `;
            
            // Set message safely using textContent
            toast.querySelector('.toast-message').textContent = message;

            const closeBtn = toast.querySelector('.toast-close');
            
            const removeToast = () => {
                toast.classList.remove('toast-show');
                toast.classList.add('toast-hiding');
                setTimeout(() => {
                    if (toast.parentNode) {
                        toast.parentNode.removeChild(toast);
                    }
                }, 300);
            };

            closeBtn.addEventListener('click', removeToast);

            container.appendChild(toast);

            // Trigger reflow for animation
            void toast.offsetWidth;
            toast.classList.add('toast-show');

            if (autoDismiss && type !== 'error') {
                setTimeout(removeToast, 5000);
            } else if (type === 'error') {
                // Give errors more time
                setTimeout(removeToast, 10000);
            }
        };

        function handleInitialToasts() {
            // Automatically show toasts if global variables are set from backend
            const successInputs = document.querySelectorAll('.global-success-message');
            successInputs.forEach(input => {
                if (input.value && input.value.trim() !== '') {
                    window.showToast('success', input.value.trim());
                }
            });
            
            const errorInputs = document.querySelectorAll('.global-error-message');
            errorInputs.forEach(input => {
                if (input.value && input.value.trim() !== '') {
                    window.showToast('error', input.value.trim());
                }
            });

            // S3-09: Specific handling for /customers/care with success=config
            try {
                const currentPath = window.location.pathname;
                if (currentPath.indexOf('/customers/care') !== -1) {
                    const searchParams = new URLSearchParams(window.location.search);
                    if (searchParams.get('success') === 'config') {
                        window.showToast('success', 'Cập nhật cấu hình ngày định kỳ thành công!');
                        if (window.history && window.history.replaceState) {
                            searchParams.delete('success');
                            const remainingQuery = searchParams.toString();
                            const newUrl = window.location.pathname + (remainingQuery ? ('?' + remainingQuery) : '') + window.location.hash;
                            window.history.replaceState(null, document.title, newUrl);
                        }
                    }
                }
            } catch (e) {
                console.error('Error handling URL toast notification:', e);
            }
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', handleInitialToasts);
        } else {
            handleInitialToasts();
        }
    })();
</script>

<!-- HIDDEN INPUTS FOR SERVER MESSAGES -->
<input type="hidden" class="global-success-message" value="<c:out value='${successMessage}'/>">
<input type="hidden" class="global-error-message" value="<c:out value='${errorMessage}'/>">
<% if (request.getAttribute("loginError") != null) { %>
    <input type="hidden" class="global-error-message" value="<%= request.getAttribute("loginError") %>">
<% } %>
</c:if>
