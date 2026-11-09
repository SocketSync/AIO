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

    public static void fetchDashboard(String token, String month, ApiCallback callback) {
        ApiClient.get("dashboard.php?month=" + month, token, callback);
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
        saveTransaction(token, 0, name, category, amount, type, "", callback);
    }

    public static void saveTransaction(String token, int id, String description, String category,
                                       double amount, String type, String date, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("action", id > 0 ? "update_transaction" : "add_transaction");
            if (id > 0) json.put("id", id);
            json.put("description", description);
            json.put("category", category);
            json.put("amount", amount);
            json.put("type", type);
            json.put("date", date);
            ApiClient.post("dashboard.php", json, token, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to record transaction: " + e.getMessage());
        }
    }

    public static void deleteTransaction(String token, int id, ApiCallback callback) {
        try {
            JSONObject json = new JSONObject();
            json.put("action", "delete_transaction");
            json.put("id", id);
            ApiClient.post("dashboard.php", json, token, callback);
        } catch (Exception e) {
            if (callback != null) callback.onError("Failed to delete transaction: " + e.getMessage());
        }
    }
}

