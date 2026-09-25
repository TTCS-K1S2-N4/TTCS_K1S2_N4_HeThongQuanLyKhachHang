package com.crm.util;

public final class Constants {
    private Constants() {}

    public static final int DEFAULT_PAGE_SIZE = 20;

    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_LOCKED = "LOCKED";

    public static final String PERM_ACCOUNT_VIEW = "account.view";
    public static final String PERM_ACCOUNT_CREATE = "account.create";
    public static final String PERM_ACCOUNT_UPDATE = "account.update";
    public static final String PERM_ACCOUNT_LOCK = "account.lock";
    public static final String PERM_ROLE_ASSIGN = "role.assign";
}
