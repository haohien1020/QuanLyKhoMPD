package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class User {

    private int userId;
    private int roleId;
    private String roleName;
    private String fullName;
    private String email;
    private String username;
    private String password;
    private String phone;
    private String address;
    private String avatar;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String resetToken;
    private Timestamp resetTokenExpiry;

    public User() {
    }

    public User(int userId, int roleId, String roleName, String fullName,
                String email, String username, String phone,
                String address, String avatar, String status) {
        this(userId, roleId, roleName, fullName, email, username, null, phone,
                address, avatar, status, null, null, null, null);
    }

    public User(int userId, int roleId, String roleName, String fullName,
                String email, String username, String password, String phone,
                String address, String avatar, String status, Timestamp createdAt,
                Timestamp updatedAt, String resetToken, Timestamp resetTokenExpiry) {
        this.userId = userId;
        this.roleId = roleId;
        this.roleName = roleName;
        this.fullName = fullName;
        this.email = email;
        this.username = username;
        this.password = password;
        this.phone = phone;
        this.address = address;
        this.avatar = avatar;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.resetToken = resetToken;
        this.resetTokenExpiry = resetTokenExpiry;
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

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public Timestamp getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(Timestamp resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }
}
