package com.finwise.app.network;

import com.finwise.app.network.ApiClient.ApiCallback;

import org.json.JSONObject;

/**
 * Authentication Network Service
 */
public class AuthService {

    public static void login(String identifier, String password, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("email", identifier);
            json.put("password", password);
            ApiClient.post("login.php", json, null, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to build request: " + e.getMessage());
        }
    }

    public static void register(String fullName, String email, String matricId, 
                                String password, String confirmPassword, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("full_name", fullName);
            json.put("email", email);
            json.put("matric_id", matricId);
            json.put("password", password);
            json.put("confirm_password", confirmPassword);
            ApiClient.post("register.php", json, null, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to build request: " + e.getMessage());
        }
    }

    public static void verifyEmail(String email, String otp, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("email", email);
            json.put("otp", otp);
            json.put("purpose", "registration");
            ApiClient.post("verify_email.php", json, null, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to build request: " + e.getMessage());
        }
    }

    public static void resendOtp(String email, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("email", email);
            json.put("purpose", "registration");
            ApiClient.post("resend_otp.php", json, null, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to build request: " + e.getMessage());
        }
    }

    public static void requestPasswordReset(String email, ApiCallback callback) {
        requestPasswordResetCode(email, "request_code", callback);
    }

    public static void resendPasswordResetCode(String email, ApiCallback callback) {
        requestPasswordResetCode(email, "resend_code", callback);
    }

    private static void requestPasswordResetCode(String email, String action, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("email", email);
            json.put("action", action);
            ApiClient.post("forgot_password.php", json, null, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to build request: " + e.getMessage());
        }
    }

    public static void resetPassword(String email, String otp, String newPassword, String confirmPassword, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("email", email);
            json.put("action", "reset_password");
            json.put("otp", otp);
            json.put("new_password", newPassword);
            json.put("confirm_password", confirmPassword);
            ApiClient.post("forgot_password.php", json, null, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to build request: " + e.getMessage());
        }
    }

    public static void logout(String token, ApiCallback callback) {
        ApiClient.post("logout.php", new JSONObject(), token, callback);
    }
}
