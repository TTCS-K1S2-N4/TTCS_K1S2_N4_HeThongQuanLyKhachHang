document.addEventListener("DOMContentLoaded", function() {
    // Initialize
    const customerIdInput = document.getElementById('c360-customer-id');
    const customerId = customerIdInput ? customerIdInput.value : '';
    
    if (customerId) {
        loadTimeline(customerId, 1);
    } else {
        renderTimelineEmpty("Không xác định được khách hàng (Chưa có ID).");
    }
});

function switchOppTab(tab) {
    document.querySelectorAll('.c360-tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.c360-tab-content').forEach(content => {
        content.style.display = 'none';
        content.classList.remove('active');
    });

    if (tab === 'open') {
        document.querySelector('.c360-tab-btn:first-child').classList.add('active');
        document.getElementById('tab-opp-open').style.display = 'block';
        document.getElementById('tab-opp-open').classList.add('active');
    } else {
        document.querySelector('.c360-tab-btn:last-child').classList.add('active');
        document.getElementById('tab-opp-closed').style.display = 'block';
        document.getElementById('tab-opp-closed').classList.add('active');
    }
}

let currentTimelinePage = 1;

function loadTimeline(customerId, page) {
    const contextPathInput = document.getElementById('c360-context-path');
    const contextPath = contextPathInput ? contextPathInput.value : '';
    const container = document.getElementById('c360-timeline-container');
    
    // API endpoint is proposed
    const apiUrl = `${contextPath}/customers/${customerId}/timeline?page=${page}`;
    
    // Simulating fetch since backend API might not exist yet
    // Using fetch but catching error to show NOT VERIFIED / BLOCKED state gracefully
    fetch(apiUrl)
        .then(response => {
            if (!response.ok) {
                throw new Error("API not ready or returned error");
            }
            return response.json();
        })
        .then(data => {
            renderTimelineData(data, page);
        })
        .catch(error => {
            console.warn("Backend API for timeline is not ready or failed:", error);
            renderTimelineError("Chưa thể tải dữ liệu timeline (Backend chưa sẵn sàng).");
        });
}

function loadMoreTimeline() {
    const customerIdInput = document.getElementById('c360-customer-id');
    const customerId = customerIdInput ? customerIdInput.value : '';
    if (customerId) {
        currentTimelinePage++;
        // Add loading indicator to button
        const btn = document.querySelector('#c360-timeline-actions button');
        if (btn) btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang tải...';
        loadTimeline(customerId, currentTimelinePage);
    }
}

function renderTimelineData(data, page) {
    const container = document.getElementById('c360-timeline-container');
    const actions = document.getElementById('c360-timeline-actions');
    
    if (page === 1) {
        container.innerHTML = '';
    }
    
    if (!data || !data.activities || data.activities.length === 0) {
        if (page === 1) {
            renderTimelineEmpty("Chưa có hoạt động nào.");
        }
        if (actions) actions.style.display = 'none';
        return;
    }
    
    let ul = container.querySelector('ul.c360-timeline');
    if (!ul) {
        ul = document.createElement('ul');
        ul.className = 'c360-timeline';
        container.appendChild(ul);
    }
    
    data.activities.forEach(act => {
        const li = document.createElement('li');
        li.className = 'c360-timeline-item';
        
        // Escape content to prevent XSS
        const title = escapeHtml(act.title || 'Hoạt động');
        const date = escapeHtml(act.date || '');
        const content = escapeHtml(act.content || '');
        const user = escapeHtml(act.user || '');
        
        li.innerHTML = `
            <div class="c360-timeline-marker"></div>
            <div class="c360-timeline-content">
                <div class="c360-timeline-header">
                    <span class="c360-timeline-title">${title}</span>
                    <span class="c360-timeline-date">${date}</span>
                </div>
                <div class="c360-timeline-body">
                    <p>${content}</p>
                    <small class="text-gray">Thực hiện bởi: ${user}</small>
                </div>
            </div>
        `;
        ul.appendChild(li);
    });
    
    // Check if there are more pages
    if (data.hasMore && actions) {
        actions.style.display = 'block';
        const btn = actions.querySelector('button');
        if (btn) btn.innerHTML = 'Tải thêm';
    } else if (actions) {
        actions.style.display = 'none';
    }
}

function renderTimelineEmpty(message) {
    const container = document.getElementById('c360-timeline-container');
    container.innerHTML = `
        <div class="c360-empty-state">
            <i class="fa-solid fa-clock-rotate-left"></i>
            <p>${escapeHtml(message)}</p>
        </div>
    `;
    const actions = document.getElementById('c360-timeline-actions');
    if (actions) actions.style.display = 'none';
}

function renderTimelineError(message) {
    const container = document.getElementById('c360-timeline-container');
    // Don't overwrite if we already have data (just a load more error)
    if (currentTimelinePage === 1 || !container.querySelector('ul')) {
        container.innerHTML = `
            <div class="c360-error-state">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 2rem; margin-bottom: 12px; display: block;"></i>
                <p>${escapeHtml(message)}</p>
                <button class="btn btn-sm btn-secondary" style="margin-top: 12px;" onclick="loadTimeline(document.getElementById('c360-customer-id').value, 1)">Thử lại</button>
            </div>
        `;
        const actions = document.getElementById('c360-timeline-actions');
        if (actions) actions.style.display = 'none';
    } else {
        // Reset load more button
        const btn = document.querySelector('#c360-timeline-actions button');
        if (btn) {
            btn.innerHTML = 'Tải thêm (Lỗi)';
            setTimeout(() => { btn.innerHTML = 'Tải thêm'; }, 2000);
        }
    }
}

function escapeHtml(unsafe) {
    return (unsafe || '').toString()
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
}
