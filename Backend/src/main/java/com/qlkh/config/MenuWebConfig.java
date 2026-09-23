package com.qlkh.config;

import com.qlkh.interceptor.MenuInterceptor;
import com.qlkh.interceptor.PermissionInterceptor;
import com.qlkh.service.MenuService;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Map;

@Configuration
public class MenuWebConfig implements WebMvcConfigurer {

    private final MenuService menuService;

    public MenuWebConfig(MenuService menuService) {
        this.menuService = menuService;
    }

    // TODO: bổ sung/đổi lại cho khớp với route thật của các module khác trong dự án
    private static final Map<String, String> URL_TO_MENU_CODE = Map.of(
            "/customers", "CUSTOMER_LIST",
            "/opportunities", "OPPORTUNITY",
            "/reports", "REPORT",
            "/admin/users", "USER_MGMT",
            "/admin/teams", "TEAM_MGMT"
    );

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new MenuInterceptor(menuService))
                .addPathPatterns("/**");

        registry.addInterceptor(new PermissionInterceptor(menuService, URL_TO_MENU_CODE))
                .addPathPatterns("/**")
                .excludePathPatterns("/login", "/logout", "/access-denied", "/assets/**", "/css/**", "/js/**");
    }
}
