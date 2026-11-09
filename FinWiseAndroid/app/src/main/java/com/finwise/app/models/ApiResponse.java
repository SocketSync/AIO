package com.finwise.app.models;

import org.json.JSONObject;

/**
 * Standard API Response Wrapper
 */
public class ApiResponse {
    private final boolean success;
    private final String message;
    private final JSONObject data;
    private final int statusCode;

    public ApiResponse(boolean success, String message, JSONObject data, int statusCode) {
        this.success = success;
        this.message = message;
        this.data = data != null ? data : new JSONObject();
        this.statusCode = statusCode;
    }

    public static ApiResponse parse(String jsonString, int statusCode) {
        if (jsonString == null || jsonString.trim().isEmpty()) {
            return new ApiResponse(false, "Empty server response", null, statusCode);
        }
        try {
            JSONObject root = new JSONObject(jsonString);
            boolean success = root.optBoolean("success", statusCode >= 200 && statusCode < 300);
            String message = root.optString("message", success ? "Success" : "Request failed");
            JSONObject data = root.optJSONObject("data");
            return new ApiResponse(success, message, data, statusCode);
        } catch (Exception e) {
            return new ApiResponse(false, "Malformed server response: " + e.getMessage(), null, statusCode);
        }
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public JSONObject getData() { return data; }
    public int getStatusCode() { return statusCode; }
}

