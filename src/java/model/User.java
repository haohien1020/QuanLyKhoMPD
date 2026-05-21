package model;

import java.util.ArrayList;
import java.util.List;

public class User {

    private int userId;
    private int roleId;
    private String roleName;
    private String fullName;
    private String email;
    private String username;
    private String phone;
    private String address;
    private String avatar;
    private String status;

    public User() {
    }

    public User(int userId, int roleId, String roleName, String fullName,
                String email, String username, String phone,
                String address, String avatar, String status) {
        this.userId = userId;
        this.roleId = roleId;
        this.roleName = roleName;
        this.fullName = fullName;
        this.email = email;
        this.username = username;
        this.phone = phone;
        this.address = address;
        this.avatar = avatar;
        this.status = status;
    }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(status);
    }

    public boolean hasRole(String role) {
        return roleName != null && roleName.equalsIgnoreCase(role);
    }
  public List<String> getRoles() {
        List<String> roles = new ArrayList<>();
        if (roleName != null && !roleName.trim().isEmpty()) {
            roles.add(roleName);
        }
        return roles;
    }

    public int getUserId() {
        return userId;
    }

    public int getRoleId() {
        return roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getUsername() {
        return username;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }

    public String getAvatar() {
        return avatar;
    }

    public String getStatus() {
        return status;
    }
}