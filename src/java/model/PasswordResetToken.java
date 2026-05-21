package model;

import java.sql.Timestamp;

public class PasswordResetToken {

    private int tokenId;
    private int userId;
    private String token;
    private Timestamp expiredAt;
    private boolean used;
    private Timestamp createdAt;

    public PasswordResetToken() {
    }

    public PasswordResetToken(int tokenId, int userId, String token, Timestamp expiredAt, boolean used, Timestamp createdAt) {
        this.tokenId = tokenId;
        this.userId = userId;
        this.token = token;
        this.expiredAt = expiredAt;
        this.used = used;
        this.createdAt = createdAt;
    }

    public int getTokenId() {
        return tokenId;
    }

    public void setTokenId(int tokenId) {
        this.tokenId = tokenId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Timestamp getExpiredAt() {
        return expiredAt;
    }

    public void setExpiredAt(Timestamp expiredAt) {
        this.expiredAt = expiredAt;
    }

    public boolean isUsed() {
        return used;
    }

    public void setUsed(boolean used) {
        this.used = used;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}