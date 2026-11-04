package com.finwise.app.models;

import org.json.JSONObject;

/**
 * User Model
 */
public class User {
    private int id;
    private String fullName;
    private String email;
    private String matricId;
    private boolean emailVerified;

    public User() {}

    public User(int id, String fullName, String email, String matricId, boolean emailVerified) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.matricId = matricId;
        this.emailVerified = emailVerified;
    }

    public static User fromJson(JSONObject json) {
        if (json == null) return null;
        User user = new User();
        user.id = json.optInt("id", 0);
        user.fullName = json.optString("full_name", "");
        user.email = json.optString("email", "");
        user.matricId = json.optString("matric_id", "");
        user.emailVerified = json.optBoolean("email_verified", false) || json.optInt("email_verified", 0) == 1;
        return user;
    }

    public int getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getMatricId() { return matricId; }
    public boolean isEmailVerified() { return emailVerified; }

    public void setId(int id) { this.id = id; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public void setEmail(String email) { this.email = email; }
    public void setMatricId(String matricId) { this.matricId = matricId; }
    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }
}

