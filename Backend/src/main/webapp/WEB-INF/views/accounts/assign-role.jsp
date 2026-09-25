<form
    action="${pageContext.request.contextPath}/accounts/assign-role"
    method="post">

    <input
        type="hidden"
        name="accountId"
        value="${account.id}">

    <div class="form-group">

        <label class="form-label" for="roleId">
            Vai trò
        </label>

        <select
            id="roleId"
            name="roleId"
            class="form-control"
            required>

            <option value="">
                -- Chọn vai trò --
            </option>

            <c:forEach var="role" items="${roles}">
                <option value="${role.id}">
                    ${role.name}
                </option>
            </c:forEach>

        </select>
    </div>

    <div class="form-group">

        <label class="form-label" for="teamId">
            Nhóm
        </label>

        <select
            id="teamId"
            name="teamId"
            class="form-control"
            required>

            <option value="">
                -- Chọn nhóm --
            </option>

            <c:forEach var="team" items="${teams}">
                <option value="${team.id}">
                    ${team.name}
                </option>
            </c:forEach>

        </select>
    </div>

    <button
        class="btn btn-primary"
        type="submit"
        data-permission="role.assign">

        Lưu thay đổi

    </button>

</form>