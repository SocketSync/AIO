package com.finwise.app.network;

import com.finwise.app.network.ApiClient.ApiCallback;

import org.json.JSONObject;

/**
 * Dashboard & Transaction Network Service
 */
public class DashboardService {

    public static void fetchDashboard(String token, ApiCallback callback) {
        ApiClient.get("dashboard.php", token, callback);
    }

    public static void quickTransferSavings(String token, double amount, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("action", "quick_transfer_savings");
            json.put("amount", amount);
            ApiClient.post("dashboard.php", json, token, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to execute transfer: " + e.getMessage());
        }
    }

    public static void addTransaction(String token, String name, String category, double amount, 
                                      String type, String method, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("action", "add_transaction");
            json.put("name", name);
            json.put("category", category);
            json.put("amount", amount);
            json.put("type", type);
            json.put("method", method);
            ApiClient.post("dashboard.php", json, token, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to record transaction: " + e.getMessage());
        }
    }
}

