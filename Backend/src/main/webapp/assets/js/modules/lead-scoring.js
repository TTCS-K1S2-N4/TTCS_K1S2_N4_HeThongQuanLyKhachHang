/**
 * =========================================================
 * CRM SYSTEM - LEAD SCORING JAVASCRIPT MODULE (S4-05)
 * Author: FE03 - Lead Scoring & Lead Filter
 * Handlers: Scoring rules list/create/delete, threshold config, client validation
 * =========================================================
 */

(function (window, document) {
    'use strict';

    const LeadScoring = {
        contextPath: '',
        notificationTimeout: null,

        init: function (options) {
            this.contextPath = (options && options.contextPath) ? options.contextPath : '';
            this.bindEvents();
            this.updateCriterionOptions();
            this.bindThresholdRealtimePreview();
        },

        bindEvents: function () {
            const criterionSelect = document.getElementById('criterionSelect');
            if (criterionSelect) {
                criterionSelect.addEventListener('change', () => this.updateCriterionOptions());
            }

            const ruleForm = document.getElementById('scoringRuleForm');
            if (ruleForm) {
                ruleForm.addEventListener('submit', (e) => this.handleRuleSubmit(e));
            }

            const thresholdForm = document.getElementById('thresholdConfigForm');
            if (thresholdForm) {
                thresholdForm.addEventListener('submit', (e) => this.handleThresholdSubmit(e));
            }

            // Event delegation cho nút Sửa quy tắc (đọc qua dataset / data-* attributes, chống lỗi nháy đơn/kép)
            document.addEventListener('click', (e) => {
                const editBtn = e.target.closest('.btn-edit-rule');
                if (editBtn) {
                    e.preventDefault();
                    const dataset = editBtn.dataset;
                    const ruleId = dataset.ruleId || editBtn.getAttribute('data-rule-id');
                    const criterion = dataset.criterion || editBtn.getAttribute('data-criterion');
                    const operator = dataset.operator || editBtn.getAttribute('data-operator');
                    const conditionValue = dataset.conditionValue || editBtn.getAttribute('data-condition-value');
                    const score = dataset.score || editBtn.getAttribute('data-score');
                    this.editRule(ruleId, criterion, operator, conditionValue, score);
                }
            });
        },

        /**
         * Real-time preview for Hot/Warm/Cold thresholds on the visual bar and badges
         */
        bindThresholdRealtimePreview: function () {
            const hotInput = document.querySelector('input[name="hotThreshold"]');
            const warmInput = document.querySelector('input[name="warmThreshold"]');
            const lblHot = document.getElementById('lblHotThreshold');
            const lblWarm = document.getElementById('lblWarmThreshold');
            const lblCold = document.getElementById('lblColdThreshold');
            const thresholdWarning = document.getElementById('thresholdWarning');

            const updateLabels = () => {
                if (!hotInput || !warmInput) return;
                const hotVal = parseInt(hotInput.value, 10);
                const warmVal = parseInt(warmInput.value, 10);

                if (!isNaN(hotVal) && lblHot) {
                    lblHot.textContent = hotVal;
                }
                if (!isNaN(warmVal) && lblWarm) {
                    lblWarm.textContent = warmVal;
                }
                if (!isNaN(warmVal) && lblCold) {
                    lblCold.textContent = '< ' + warmVal;
                }

                // Inline validation check & submit disable
                const thresholdSubmitBtn = document.querySelector('#thresholdConfigForm button[type="submit"]');
                const isInvalid = (!isNaN(hotVal) && !isNaN(warmVal) && hotVal <= warmVal);
                if (thresholdWarning) {
                    if (isInvalid) {
                        thresholdWarning.style.display = 'block';
                        thresholdWarning.textContent = '';
                        const warnIcon = document.createElement('i');
                        warnIcon.className = 'fas fa-exclamation-triangle';
                        warnIcon.style.marginRight = '6px';
                        thresholdWarning.appendChild(warnIcon);
                        thresholdWarning.appendChild(document.createTextNode('Ngưỡng Lead Nóng (' + hotVal + ') phải lớn hơn ngưỡng Lead Ấm (' + warmVal + ').'));
                        if (hotInput) hotInput.style.borderColor = '#ef4444';
                        if (warmInput) warmInput.style.borderColor = '#ef4444';
                    } else {
                        thresholdWarning.style.display = 'none';
                        thresholdWarning.textContent = '';
                        if (hotInput) hotInput.style.borderColor = '';
                        if (warmInput) warmInput.style.borderColor = '';
                    }
                }
                if (thresholdSubmitBtn) {
                    thresholdSubmitBtn.disabled = isInvalid;
                }
            };

            if (hotInput) {
                hotInput.addEventListener('input', updateLabels);
            }
            if (warmInput) {
                warmInput.addEventListener('input', updateLabels);
            }
        },

        /**
         * Update predefined options / helper text according to Criterion (Industry, Company Size, Source, Interest)
         */
        updateCriterionOptions: function () {
            const criterionSelect = document.getElementById('criterionSelect');
            const conditionValueInput = document.getElementById('conditionValueInput');
            const conditionValueDatalist = document.getElementById('criterionSuggestions');
            if (!criterionSelect || !conditionValueInput) return;

            const selected = criterionSelect.value;
            if (conditionValueDatalist) {
                conditionValueDatalist.innerHTML = '';
                let suggestions = [];

                if (selected === 'INDUSTRY') {
                    suggestions = ['Công nghệ thông tin', 'Tài chính / Ngân hàng', 'Bất động sản', 'Sản xuất', 'Bán lẻ', 'Y tế', 'Giáo dục', 'Xây dựng', 'Logistics', 'Khác'];
                    conditionValueInput.placeholder = 'VD: Công nghệ thông tin, Bất động sản...';
                } else if (selected === 'COMPANY_SIZE') {
                    suggestions = ['Dưới 10', '10-50', '50-100', '100-500', 'Trên 500'];
                    conditionValueInput.placeholder = 'VD: 100-500, Trên 500...';
                } else if (selected === 'SOURCE') {
                    suggestions = ['Website', 'Facebook', 'Google Ads', 'Giới thiệu', 'Sự kiện', 'Email Marketing', 'Cold Call', 'Khác'];
                    conditionValueInput.placeholder = 'VD: Website, Facebook, Google Ads...';
                } else if (selected === 'INTEREST') {
                    suggestions = ['Rất cao', 'Cao', 'Trung bình', 'Thấp'];
                    conditionValueInput.placeholder = 'VD: Rất cao, Cao...';
                }

                suggestions.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item;
                    conditionValueDatalist.appendChild(opt);
                });
            }
        },

        /**
         * Edit Scoring Rule: populate form, set edit mode UI, highlight row, and smooth scroll
         */
        editRule: function (ruleId, criterion, operator, conditionValue, score) {
            const form = document.getElementById('scoringRuleForm');
            if (!form) return;

            const ruleIdInput = form.querySelector('[name="ruleId"]');
            const criterionSelect = form.querySelector('[name="criterion"]');
            const operatorSelect = form.querySelector('[name="operator"]');
            const conditionValueInput = form.querySelector('[name="conditionValue"]');
            const scoreInput = form.querySelector('[name="score"]');
            const formTitle = document.getElementById('ruleFormTitle');
            const submitBtn = form.querySelector('button[type="submit"]');
            const cancelBtn = document.getElementById('btnCancelEditRule');

            if (ruleIdInput) ruleIdInput.value = ruleId || '';
            if (criterionSelect) {
                criterionSelect.value = criterion || 'INDUSTRY';
                this.updateCriterionOptions();
            }
            if (operatorSelect) operatorSelect.value = operator || 'EQUALS';
            if (conditionValueInput) conditionValueInput.value = conditionValue || '';
            if (scoreInput) scoreInput.value = (score !== undefined && score !== null) ? score : '';

            // Update UI state to Edit Mode safely without innerHTML
            if (formTitle) {
                formTitle.textContent = '';
                const editIcon = document.createElement('i');
                editIcon.className = 'fas fa-edit';
                editIcon.style.color = '#f59e0b';
                editIcon.style.marginRight = '6px';
                formTitle.appendChild(editIcon);

                const titleText = document.createTextNode('Chỉnh sửa tiêu chí #' + (ruleId || ''));
                formTitle.appendChild(titleText);

                const badge = document.createElement('span');
                badge.className = 'rule-edit-badge';
                const penIcon = document.createElement('i');
                penIcon.className = 'fas fa-pen';
                penIcon.style.marginRight = '4px';
                badge.appendChild(penIcon);
                badge.appendChild(document.createTextNode('Đang sửa'));
                formTitle.appendChild(badge);
            }
            if (submitBtn) {
                submitBtn.textContent = '';
                const checkIcon = document.createElement('i');
                checkIcon.className = 'fas fa-check';
                checkIcon.style.marginRight = '4px';
                submitBtn.appendChild(checkIcon);
                submitBtn.appendChild(document.createTextNode('Cập nhật quy tắc'));
            }
            if (cancelBtn) {
                cancelBtn.style.display = 'inline-flex';
            }

            // Highlight table row
            document.querySelectorAll('.rule-row-item').forEach(tr => tr.classList.remove('editing-rule-row'));
            const targetRow = document.getElementById('rule-row-' + ruleId);
            if (targetRow) {
                targetRow.classList.add('editing-rule-row');
            }

            // Smooth scroll to form
            form.scrollIntoView({ behavior: 'smooth', block: 'center' });
            if (conditionValueInput) conditionValueInput.focus();
        },

        /**
         * Cancel editing rule, revert to Create mode
         */
        cancelEdit: function () {
            const form = document.getElementById('scoringRuleForm');
            if (!form) return;

            form.reset();
            const ruleIdInput = form.querySelector('[name="ruleId"]');
            if (ruleIdInput) ruleIdInput.value = '';

            const formTitle = document.getElementById('ruleFormTitle');
            const submitBtn = form.querySelector('button[type="submit"]');
            const cancelBtn = document.getElementById('btnCancelEditRule');

            if (formTitle) {
                formTitle.textContent = '';
                const plusIcon = document.createElement('i');
                plusIcon.className = 'fas fa-plus-circle';
                plusIcon.style.color = 'var(--color-primary)';
                plusIcon.style.marginRight = '6px';
                formTitle.appendChild(plusIcon);
                formTitle.appendChild(document.createTextNode('Thêm mới hoặc chỉnh sửa tiêu chí'));
            }
            if (submitBtn) {
                submitBtn.textContent = '';
                const saveIcon = document.createElement('i');
                saveIcon.className = 'fas fa-plus';
                saveIcon.style.marginRight = '4px';
                submitBtn.appendChild(saveIcon);
                submitBtn.appendChild(document.createTextNode('Lưu tiêu chí'));
            }
            if (cancelBtn) {
                cancelBtn.style.display = 'none';
            }

            this.updateCriterionOptions();
            document.querySelectorAll('.rule-row-item').forEach(tr => tr.classList.remove('editing-rule-row'));
        },

        /**
         * Handle Creating or Updating a Scoring Rule
         */
        handleRuleSubmit: function (e) {
            e.preventDefault();
            const form = e.target;
            const criterion = form.querySelector('[name="criterion"]').value.trim();
            const operator = form.querySelector('[name="operator"]').value.trim();
            const conditionValue = form.querySelector('[name="conditionValue"]').value.trim();
            const scoreStr = form.querySelector('[name="score"]').value.trim();

            if (!criterion) {
                this.showNotification('Vui lòng chọn tiêu chí chấm điểm.', 'error');
                return;
            }
            if (!conditionValue) {
                this.showNotification('Vui lòng nhập giá trị điều kiện so khớp.', 'error');
                return;
            }
            if (scoreStr === '' || isNaN(parseInt(scoreStr, 10))) {
                this.showNotification('Điểm số phải là số nguyên hợp lệ (VD: 20 hoặc -10).', 'error');
                return;
            }

            const submitBtn = form.querySelector('button[type="submit"]');
            const originalBtnHtml = submitBtn ? submitBtn.innerHTML : '';
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';
            }

            const params = new URLSearchParams();
            params.append('criterion', criterion);
            params.append('operator', operator);
            params.append('conditionValue', conditionValue);
            params.append('score', scoreStr);

            const ruleIdField = form.querySelector('[name="ruleId"]');
            if (ruleIdField && ruleIdField.value) {
                params.append('ruleId', ruleIdField.value);
            }

            fetch(this.contextPath + '/lead-scoring/rules', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json, text/html, */*'
                },
                body: params
            })
            .then(res => {
                if (res.ok) {
                    return res.text();
                } else {
                    throw new Error('HTTP ' + res.status);
                }
            })
            .then(data => {
                this.showNotification('Lưu tiêu chí chấm điểm thành công!', 'success');
                setTimeout(() => window.location.reload(), 600);
            })
            .catch(err => {
                console.warn('Backend endpoint /lead-scoring/rules fallback to standard submit:', err);
                // Graceful fallback for standard form post
                form.submit();
            })
            .finally(() => {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalBtnHtml;
                }
            });
        },

        /**
         * Delete Scoring Rule
         */
        deleteRule: function (ruleId) {
            if (!confirm('Bạn có chắc chắn muốn xóa quy tắc chấm điểm này khỏi hệ thống?')) return;

            const params = new URLSearchParams();
            params.append('ruleId', ruleId);

            fetch(this.contextPath + '/lead-scoring/rules/delete', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json, text/html, */*'
                },
                body: params
            })
            .then(res => {
                if (res.ok) {
                    this.showNotification('Xóa quy tắc chấm điểm thành công!', 'success');
                    setTimeout(() => window.location.reload(), 500);
                } else {
                    throw new Error('HTTP ' + res.status);
                }
            })
            .catch(err => {
                console.warn('Backend endpoint /lead-scoring/rules/delete fallback:', err);
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = this.contextPath + '/lead-scoring/rules/delete';
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'ruleId';
                input.value = ruleId;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            });
        },

        /**
         * Handle updating classification thresholds (Hot / Warm / Cold)
         */
        handleThresholdSubmit: function (e) {
            e.preventDefault();
            const form = e.target;
            const hotInput = form.querySelector('[name="hotThreshold"]');
            const warmInput = form.querySelector('[name="warmThreshold"]');

            const hotVal = parseInt(hotInput.value, 10);
            const warmVal = parseInt(warmInput.value, 10);

            if (isNaN(hotVal) || isNaN(warmVal)) {
                this.showNotification('Vui lòng nhập ngưỡng điểm là số nguyên hợp lệ.', 'error');
                return;
            }

            if (hotVal <= warmVal) {
                this.showNotification('Ngưỡng Lead Nóng (' + hotVal + ') phải lớn hơn ngưỡng Lead Ấm (' + warmVal + ').', 'error');
                return;
            }

            const submitBtn = form.querySelector('button[type="submit"]');
            const originalBtnHtml = submitBtn ? submitBtn.innerHTML : '';
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';
            }

            const params = new URLSearchParams();
            params.append('hotThreshold', hotVal);
            params.append('warmThreshold', warmVal);

            fetch(this.contextPath + '/lead-scoring/config', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json, text/html, */*'
                },
                body: params
            })
            .then(res => {
                if (res.ok) {
                    this.showNotification('Cập nhật ngưỡng phân loại Nóng / Ấm / Lạnh thành công!', 'success');
                    setTimeout(() => window.location.reload(), 600);
                } else {
                    throw new Error('HTTP ' + res.status);
                }
            })
            .catch(err => {
                console.warn('Backend endpoint /lead-scoring/config fallback:', err);
                form.submit();
            })
            .finally(() => {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalBtnHtml;
                }
            });
        },

        /**
         * Helper display notification: prioritizes window.showToast if available.
         * Falls back to in-page banner #leadScoringAlert only when Toast is unavailable.
         * Uses safe DOM textContent to prevent XSS.
         */
        showNotification: function (message, type) {
            // 1. Ưu tiên Shared Toast nếu có để tránh hiển thị trùng lặp
            if (typeof window.showToast === 'function') {
                window.showToast(type || 'info', message);
                return;
            }

            // 2. Fallback: hiển thị banner #leadScoringAlert an toàn qua DOM API (chống XSS)
            const existingAlert = document.getElementById('leadScoringAlert');
            if (existingAlert) {
                if (this.notificationTimeout) {
                    clearTimeout(this.notificationTimeout);
                }
                const isError = (type === 'error');
                existingAlert.className = 'alert ' + (isError ? 'alert-danger' : 'alert-success') + ' scoring-notification-banner';
                existingAlert.replaceChildren();

                const contentWrapper = document.createElement('div');
                contentWrapper.style.display = 'flex';
                contentWrapper.style.alignItems = 'center';
                contentWrapper.style.gap = '8px';

                const icon = document.createElement('i');
                icon.className = 'fas ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle');

                const msgSpan = document.createElement('span');
                msgSpan.textContent = message;

                contentWrapper.appendChild(icon);
                contentWrapper.appendChild(msgSpan);

                const closeBtn = document.createElement('button');
                closeBtn.type = 'button';
                closeBtn.innerHTML = '&times;';
                closeBtn.setAttribute('aria-label', 'Đóng thông báo');
                closeBtn.style.background = 'none';
                closeBtn.style.border = 'none';
                closeBtn.style.fontSize = '16px';
                closeBtn.style.cursor = 'pointer';
                closeBtn.style.color = 'inherit';
                closeBtn.style.opacity = '0.7';
                closeBtn.addEventListener('click', function () {
                    existingAlert.style.display = 'none';
                });

                existingAlert.appendChild(contentWrapper);
                existingAlert.appendChild(closeBtn);
                existingAlert.style.display = 'flex';

                this.notificationTimeout = setTimeout(() => {
                    existingAlert.style.display = 'none';
                }, 4500);
                return;
            }

            // 3. Fallback cuối cùng nếu không có cả Toast lẫn banner container
            console.warn('[LeadScoring] Toast notification:', type, message);
        }
    };

    window.LeadScoring = LeadScoring;
})(window, document);
