package com.finwise.app.utils;

import android.util.Patterns;
import java.util.regex.Pattern;

/**
 * Validation Utilities for FinWise
 */
public final class ValidationUtils {
    private ValidationUtils() {}

    private static final Pattern OTP_PATTERN = Pattern.compile("^\\d{6}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,128}$"
    );

    public static boolean isValidFullName(String name) {
        return name != null && name.trim().length() >= 2;
    }

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        return !trimmed.isEmpty() && Patterns.EMAIL_ADDRESS.matcher(trimmed).matches();
    }

    public static boolean isUtmEmail(String email) {
        if (!isValidEmail(email)) return false;
        String lower = email.trim().toLowerCase();
        return lower.endsWith("@finwise-app.xyz") || lower.endsWith("@finwise-app.xyz");
    }

    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }

    public static boolean doPasswordsMatch(String p1, String p2) {
        return p1 != null && p1.equals(p2);
    }

    public static boolean isValidOtp(String otp) {
        return otp != null && OTP_PATTERN.matcher(otp.trim()).matches();
    }
}
