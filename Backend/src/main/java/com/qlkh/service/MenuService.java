package com.qlkh.service;

import com.qlkh.entity.MenuItem;
import com.qlkh.entity.User;
import com.qlkh.repository.MenuItemRepository;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * S1-06 - Menu theo quyền.
 * Trả về danh sách menu mà user hiện tại được phép thấy, đã lọc theo Role,
 * để controller đưa vào model cho JSP render (ẩn hẳn mục không có quyền,
 * không chỉ disable).
 */
@Service
public class MenuService {

    private final MenuItemRepository menuItemRepository;

    public MenuService(MenuItemRepository menuItemRepository) {
        this.menuItemRepository = menuItemRepository;
    }

    /**
     * Danh sách menu (đã lọc theo quyền) cho user hiện tại, sắp theo orderIndex.
     * Dùng trực tiếp trong Controller: model.addAttribute("menuItems", ...)
     */
    public List<MenuItem> getMenuForUser(User user) {
        return menuItemRepository.findAllByRoleId(user.getRole().getId())
                .stream()
                .sorted(Comparator.comparingInt(MenuItem::getOrderIndex))
                .collect(Collectors.toList());
    }

    /** Tập mã menu user được phép truy cập — dùng để interceptor kiểm tra quyền. */
    public Set<String> getAllowedMenuCodes(User user) {
        return getMenuForUser(user).stream()
                .map(MenuItem::getCode)
                .collect(Collectors.toSet());
    }
}
