/**
 * =========================================================
 * CRM SYSTEM - LEAD SCORING JAVASCRIPT MODULE (S4-05)
 * Author: FE03 - Mạnh
 * Handlers: Scoring rules list/create/delete, threshold config, client validation
 * =========================================================
 */

(function (window, document) {
    'use strict';

    const LeadScoring = {
        contextPath: '',

        init: function (options) {
            this.contextPath = (options && options.contextPath) ? options.contextPath : '';
            this.bindEvents();
            this.updateCriterionOptions();
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
                    suggestions = ['Công nghệ thông tin', 'Tài chính / Ngân hàng', 'Bất động sản', 'Sản xuất', 'Bán lẻ', 'Y tế', 'Giáo dục', 'Khác'];
                } else if (selected === 'COMPANY_SIZE') {
                    suggestions = ['Dưới 10', '10-50', '50-100', '100-500', 'Trên 500'];
                } else if (selected === 'SOURCE') {
                    suggestions = ['Website', 'Facebook', 'Google Ads', 'Giới thiệu', 'Sự kiện', 'Email Marketing', 'Cold Call', 'Khác'];
                } else if (selected === 'INTEREST') {
                    suggestions = ['Cao', 'Trung bình', 'Thấp', 'Rất cao'];
                }

                suggestions.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item;
                    conditionValueDatalist.appendChild(opt);
                });
            }
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
                this.showNotification('Điểm số phải là số nguyên hợp lệ.', 'error');
                return;
            }

            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerText = 'Đang lưu...';
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
                console.warn('Backend endpoint /lead-scoring/rules response:', err);
                // Graceful fallback for demo or when backend is in candidate state
                form.submit();
            })
            .finally(() => {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerText = 'Lưu tiêu chí';
                }
            });
        },

        /**
         * Delete Scoring Rule
         */
        deleteRule: function (ruleId) {
            if (!confirm('Bạn có chắc chắn muốn xóa quy tắc chấm điểm này?')) return;

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
                console.warn('Backend endpoint /lead-scoring/rules/delete response:', err);
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
                this.showNotification('Ngưỡng Lead Nóng phải lớn hơn ngưỡng Lead Ấm.', 'error');
                return;
            }

            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerText = 'Đang lưu...';
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
                    this.showNotification('Cập nhật ngưỡng phân loại Nóng/Ấm/Lạnh thành công!', 'success');
                    setTimeout(() => window.location.reload(), 600);
                } else {
                    throw new Error('HTTP ' + res.status);
                }
            })
            .catch(err => {
                console.warn('Backend endpoint /lead-scoring/config response:', err);
                form.submit();
            })
            .finally(() => {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerText = 'Lưu ngưỡng phân loại';
                }
            });
        },

        /**
         * Helper display notification using Shared Toast
         */
        showNotification: function (message, type) {
            if (typeof window.showToast === 'function') {
                window.showToast(type || 'info', message);
                return;
            }
            console.warn('[LeadScoring] Toast notification:', type, message);
        }
    };

    window.LeadScoring = LeadScoring;
})(window, document);
