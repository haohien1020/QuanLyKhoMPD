package model;

import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

public class Permission {
    private int permissionId;
    private String permissionName;
    private String description;
    private Timestamp createdAt;
    private Set<String> roles = new HashSet<>();

    public Permission() {}

    public Permission(int permissionId, String permissionName, String description) {
        this.permissionId = permissionId;
        this.permissionName = permissionName;
        this.description = description;
    }

    public Permission(int permissionId, String permissionName, String description, Set<String> roles) {
        this.permissionId = permissionId;
        this.permissionName = permissionName;
        this.description = description;
        this.roles = roles;
    }

    public int getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(int permissionId) {
        this.permissionId = permissionId;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Set<String> getRoles() {
        return roles;
    }

    public void setRoles(Set<String> roles) {
        this.roles = roles;
    }
}
