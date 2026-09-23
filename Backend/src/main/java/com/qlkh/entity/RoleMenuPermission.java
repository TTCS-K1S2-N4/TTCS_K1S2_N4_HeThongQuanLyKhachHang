package com.qlkh.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "role_menu_permissions")
@Getter
@Setter
public class RoleMenuPermission {

    @EmbeddedId
    private RoleMenuId id = new RoleMenuId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("roleId")
    @JoinColumn(name = "role_id")
    private Role role;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("menuId")
    @JoinColumn(name = "menu_id")
    private MenuItem menuItem;

    @Embeddable
    @Getter
    @Setter
    public static class RoleMenuId implements Serializable {
        @Column(name = "role_id")
        private Long roleId;

        @Column(name = "menu_id")
        private Long menuId;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof RoleMenuId)) return false;
            RoleMenuId that = (RoleMenuId) o;
            return Objects.equals(roleId, that.roleId) && Objects.equals(menuId, that.menuId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(roleId, menuId);
        }
    }
}
