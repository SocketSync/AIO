package com.finwise.app.utils;

import android.content.Context;
import android.content.SharedPreferences;

import com.finwise.app.models.User;

/**
 * Session Manager
 * Encapsulates session token persistence, user credentials, and device preferences.
 */
public class SessionManager {
    private static final String PREF_NAME = "finwise_session_prefs";
    private static final String KEY_IS_LOGGED_IN = "is_logged_in";
    private static final String KEY_AUTH_TOKEN = "auth_token";
    private static final String KEY_USER_ID = "user_id";
    private static final String KEY_USER_NAME = "user_name";
    private static final String KEY_USER_EMAIL = "user_email";
    private static final String KEY_USER_MATRIC = "user_matric";
    private static final String KEY_REMEMBER_DEVICE = "remember_device";
    private static final String KEY_SAVED_IDENTIFIER = "saved_identifier";

    private final SharedPreferences prefs;

    public SessionManager(Context context) {
        this.prefs = context.getApplicationContext().getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
    }

    public void saveLoginSession(String token, User user, boolean rememberDevice) {
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean(KEY_IS_LOGGED_IN, true);
        editor.putString(KEY_AUTH_TOKEN, token);
        if (user != null) {
            editor.putInt(KEY_USER_ID, user.getId());
            editor.putString(KEY_USER_NAME, user.getFullName());
            editor.putString(KEY_USER_EMAIL, user.getEmail());
            editor.putString(KEY_USER_MATRIC, user.getMatricId());
            if (rememberDevice) {
                editor.putString(KEY_SAVED_IDENTIFIER, user.getEmail());
            }
        }
        editor.putBoolean(KEY_REMEMBER_DEVICE, rememberDevice);
        editor.apply();
    }

    public boolean isLoggedIn() {
        return prefs.getBoolean(KEY_IS_LOGGED_IN, false) && getToken() != null && !getToken().isEmpty();
    }

    public String getToken() {
        return prefs.getString(KEY_AUTH_TOKEN, null);
    }

    public User getUser() {
        if (!isLoggedIn()) return null;
        int id = prefs.getInt(KEY_USER_ID, 0);
        String name = prefs.getString(KEY_USER_NAME, "Student");
        String email = prefs.getString(KEY_USER_EMAIL, "");
        String matric = prefs.getString(KEY_USER_MATRIC, "");
        return new User(id, name, email, matric, true);
    }

    public String getSavedIdentifier() {
        return prefs.getString(KEY_SAVED_IDENTIFIER, "yeoh.k@graduate.utm.my");
    }

    public boolean isRememberDevice() {
        return prefs.getBoolean(KEY_REMEMBER_DEVICE, true);
    }

    public void setRememberDevice(boolean remember) {
        prefs.edit().putBoolean(KEY_REMEMBER_DEVICE, remember).apply();
    }

    public void clearSession() {
        boolean remember = isRememberDevice();
        String savedId = getSavedIdentifier();
        SharedPreferences.Editor editor = prefs.edit();
        editor.remove(KEY_IS_LOGGED_IN);
        editor.remove(KEY_AUTH_TOKEN);
        editor.remove(KEY_USER_ID);
        editor.remove(KEY_USER_NAME);
        editor.remove(KEY_USER_EMAIL);
        editor.remove(KEY_USER_MATRIC);
        if (!remember) {
            editor.remove(KEY_SAVED_IDENTIFIER);
            editor.remove(KEY_REMEMBER_DEVICE);
        }
        editor.apply();
    }
}

