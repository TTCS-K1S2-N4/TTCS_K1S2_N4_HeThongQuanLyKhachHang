<form
    action="${pageContext.request.contextPath}/auth/login"
    method="post">

    <div class="form-group">
        <label class="form-label" for="username">
            Tên đăng nhập
        </label>

        <input
            id="username"
            name="username"
            class="form-control"
            type="text"
            value="${username}"
            required>
    </div>

    <div class="form-group">
        <label class="form-label" for="password">
            Mật khẩu
        </label>

        <input
            id="password"
            name="password"
            class="form-control"
            type="password"
            required>
    </div>

    <button
        class="btn btn-primary"
        type="submit">
        Đăng nhập
    </button>

</form>