package com.qlkh.repository;

import com.qlkh.entity.MenuItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface MenuItemRepository extends JpaRepository<MenuItem, Long> {

    @Query("SELECT DISTINCT m FROM MenuItem m JOIN RoleMenuPermission rmp ON rmp.menuItem = m " +
           "WHERE rmp.role.id = :roleId ORDER BY m.orderIndex ASC")
    List<MenuItem> findAllByRoleId(Long roleId);
}
