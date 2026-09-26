<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Không tìm thấy trang | CRM System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --secondary: #e2e8f0;
            --secondary-hover: #cbd5e1;
            --bg-gradient: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%);
            --card-bg: rgba(255, 255, 255, 0.96);
            --text-main: #1e293b;
            --text-muted: #64748b;
            --danger-bg: #fee2e2;
            --danger-color: #dc2626;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }

        body {
            min-height: 100vh;
            background: var(--bg-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
        }

        .error-card {
            width: 100%;
            max-width: 500px;
            background: var(--card-bg);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            padding: 3rem 2rem;
            text-align: center;
            backdrop-filter: blur(10px);
        }

        .error-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--danger-bg);
            color: var(--danger-color);
            padding: 0.5rem 1.25rem;
            border-radius: 9999px;
            font-weight: 700;
            font-size: 1.1rem;
            margin-bottom: 1.5rem;
        }

        .error-icon-wrapper {
            position: relative;
            width: 80px;
            height: 80px;
            margin: 0 auto 1.5rem;
            background: #e0e7ff;
            color: var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.25rem;
        }

        .error-title {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-main);
            margin-bottom: 0.75rem;
        }

        .error-description {
            font-size: 1rem;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 2rem;
        }

        .error-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.8rem 1.5rem;
            border-radius: 12px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
        }

        .btn-secondary {
            background: var(--secondary);
            color: var(--text-main);
        }

        .btn-secondary:hover {
            background: var(--secondary-hover);
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-hover);
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
        }
    </style>
</head>
<body>

<div class="error-card">
    <div class="error-badge">
        <i class="fa-solid fa-compass"></i> LỖI 404
    </div>

    <div class="error-icon-wrapper">
        <i class="fa-solid fa-magnifying-glass"></i>
    </div>

    <h1 class="error-title">Không tìm thấy trang</h1>

    <p class="error-description">
        <c:choose>
            <c:when test="${not empty errorMessage}">
                ${errorMessage}
            </c:when>
            <c:otherwise>
                Trang bạn đang tìm kiếm không tồn tại, đã được di chuyển hoặc đường dẫn không chính xác.
            </c:otherwise>
        </c:choose>
    </p>

    <div class="error-actions">
        <button type="button" class="btn btn-secondary" onclick="history.back()">
            <i class="fa-solid fa-arrow-left"></i> Quay lại
        </button>

        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
            <i class="fa-solid fa-house"></i> Về trang chủ
        </a>
    </div>
</div>

</body>
</html>
