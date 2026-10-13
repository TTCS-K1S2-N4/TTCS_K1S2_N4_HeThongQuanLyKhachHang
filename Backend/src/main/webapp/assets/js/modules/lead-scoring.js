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

                // Inline validation check
                if (thresholdWarning) {
                    if (!isNaN(hotVal) && !isNaN(warmVal) && hotVal <= warmVal) {
                        thresholdWarning.style.display = 'block';
                        thresholdWarning.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Ngưỡng Lead Nóng (' + hotVal + ') phải lớn hơn ngưỡng Lead Ấm (' + warmVal + ').';
                    } else {
                        thresholdWarning.style.display = 'none';
                    }
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
         * Helper display notification with auto-dismiss and close icon
         */
        showNotification: function (message, type) {
            const existingAlert = document.getElementById('leadScoringAlert');
            if (existingAlert) {
                if (this.notificationTimeout) {
                    clearTimeout(this.notificationTimeout);
                }
                const isError = (type === 'error');
                existingAlert.className = 'alert ' + (isError ? 'alert-danger' : 'alert-success') + ' scoring-notification-banner';
                existingAlert.innerHTML = `
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas ${isError ? 'fa-exclamation-circle' : 'fa-check-circle'}"></i>
                        <span>${message}</span>
                    </div>
                    <button type="button" onclick="document.getElementById('leadScoringAlert').style.display='none'" style="background: none; border: none; font-size: 16px; cursor: pointer; color: inherit; opacity: 0.7;">&times;</button>
                `;
                existingAlert.style.display = 'flex';

                this.notificationTimeout = setTimeout(() => {
                    existingAlert.style.display = 'none';
                }, 4500);
                return;
            }
            alert(message);
        }
    };

    window.LeadScoring = LeadScoring;
})(window, document);
