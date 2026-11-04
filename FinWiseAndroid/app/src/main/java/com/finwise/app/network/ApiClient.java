package com.finwise.app.network;

import android.os.Handler;
import android.os.Looper;

import com.finwise.app.models.ApiResponse;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Android Native Java HTTP API Client
 * Uses pure Java HttpURLConnection without external JS/Node dependencies.
 */
public class ApiClient {
    public interface ApiCallback {
        void onResponse(ApiResponse response);
        void onError(String errorMessage);
    }

    // Default base URL points to standard local development server
    // For Android Emulator: 10.0.2.2 accesses host machine localhost
    private static String baseUrl = "http://10.0.2.2:8000/backend/api/";

    private static final ExecutorService executor = Executors.newCachedThreadPool();
    private static final Handler mainHandler = new Handler(Looper.getMainLooper());

    public static void setBaseUrl(String url) {
        if (url != null && !url.isEmpty()) {
            if (!url.endsWith("/")) url += "/";
            baseUrl = url;
        }
    }

    public static String getBaseUrl() {
        return baseUrl;
    }

    public static void post(String endpoint, JSONObject jsonBody, String authToken, ApiCallback callback) {
        executeRequest("POST", endpoint, jsonBody != null ? jsonBody.toString() : null, authToken, callback);
    }

    public static void get(String endpoint, String authToken, ApiCallback callback) {
        executeRequest("GET", endpoint, null, authToken, callback);
    }

    private static void executeRequest(String method, String endpoint, String requestBody, String authToken, ApiCallback callback) {
        executor.execute(() -> {
            HttpURLConnection conn = null;
            try {
                String fullUrl = baseUrl + endpoint;
                URL url = new URL(fullUrl);
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod(method);
                conn.setConnectTimeout(10000); // 10 seconds
                conn.setReadTimeout(15000);    // 15 seconds
                conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                conn.setRequestProperty("Accept", "application/json");

                if (authToken != null && !authToken.trim().isEmpty()) {
                    conn.setRequestProperty("Authorization", "Bearer " + authToken.trim());
                }

                if ("POST".equalsIgnoreCase(method) && requestBody != null) {
                    conn.setDoOutput(true);
                    byte[] outputBytes = requestBody.getBytes(StandardCharsets.UTF_8);
                    conn.setFixedLengthStreamingMode(outputBytes.length);
                    try (OutputStream os = conn.getOutputStream()) {
                        os.write(outputBytes);
                        os.flush();
                    }
                }

                int statusCode = conn.getResponseCode();
                InputStream is = (statusCode >= 200 && statusCode < 400) 
                        ? conn.getInputStream() 
                        : conn.getErrorStream();

                StringBuilder sb = new StringBuilder();
                if (is != null) {
                    try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            sb.append(line);
                        }
                    }
                }

                ApiResponse response = ApiResponse.parse(sb.toString(), statusCode);
                mainHandler.post(() -> {
                    if (callback != null) {
                        callback.onResponse(response);
                    }
                });

            } catch (Exception e) {
                mainHandler.post(() -> {
                    if (callback != null) {
                        callback.onError("Connection error: " + e.getMessage());
                    }
                });
            } finally {
                if (conn != null) {
                    conn.disconnect();
                }
            }
        });
    }
}
