package com.finwise.app.models;

import org.json.JSONArray;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;

/**
 * Dashboard Aggregate Data Model
 */
public class DashboardData {
    public static class OutflowDay {
        public String dayLetter;
        public String fullDay;
        public double amount;
        public boolean isToday;
        public boolean isPeak;
    }

    private String userName;
    private String campusInfo;
    private String period;
    private double totalBalance;
    private double totalIncome;
    private double totalExpense;
    private String balanceStatus;

    // AI Insight
    private String aiInsightTag;
    private String aiInsightMessage;
    private double aiInsightAmount;

    // 7-day trend
    private String trendAvg;
    private List<OutflowDay> trendDays = new ArrayList<>();

    // Recent transactions
    private List<Transaction> transactions = new ArrayList<>();

    public static DashboardData fromJson(JSONObject json) {
        DashboardData data = new DashboardData();
        if (json == null) return data;

        JSONObject userObj = json.optJSONObject("user");
        if (userObj != null) {
            data.userName = userObj.optString("full_name", "Student");
        }

        JSONObject campusObj = json.optJSONObject("campus_info");
        if (campusObj != null) {
            data.campusInfo = campusObj.optString("campus", "UTM Skudai Campus") + " • " + campusObj.optString("subtitle", "Financial Snapshot");
            data.period = campusObj.optString("period", "Nov 2024");
        }

        JSONObject balanceObj = json.optJSONObject("balance");
        if (balanceObj != null) {
            data.totalBalance = balanceObj.optDouble("total_available", 3420.50);
            data.totalIncome = balanceObj.optDouble("total_income", 2800.00);
            data.totalExpense = balanceObj.optDouble("total_expense", 1485.20);
            data.balanceStatus = balanceObj.optString("status", "Active");
        }

        JSONObject aiObj = json.optJSONObject("ai_insight");
        if (aiObj != null) {
            data.aiInsightTag = aiObj.optString("tag", "SMART SPEND ALERT");
            data.aiInsightMessage = aiObj.optString("message", "You've spent 20% less on food this week at UTM Arked. Great job! Move RM50 to your Emergency Fund?");
            data.aiInsightAmount = aiObj.optDouble("action_amount", 50.00);
        }

        JSONObject trendObj = json.optJSONObject("outflow_trend");
        if (trendObj != null) {
            data.trendAvg = trendObj.optString("daily_average", "RM 45/day");
            JSONArray daysArr = trendObj.optJSONArray("days");
            if (daysArr != null) {
                for (int i = 0; i < daysArr.length(); i++) {
                    JSONObject dObj = daysArr.optJSONObject(i);
                    if (dObj != null) {
                        OutflowDay d = new OutflowDay();
                        d.dayLetter = dObj.optString("day", "");
                        d.fullDay = dObj.optString("full_day", "");
                        d.amount = dObj.optDouble("amount", 0.0);
                        d.isToday = dObj.optBoolean("is_today", false);
                        d.isPeak = dObj.optBoolean("is_peak", false);
                        data.trendDays.add(d);
                    }
                }
            }
        }

        JSONArray txArr = json.optJSONArray("recent_transactions");
        if (txArr != null) {
            for (int i = 0; i < txArr.length(); i++) {
                JSONObject tObj = txArr.optJSONObject(i);
                if (tObj != null) {
                    data.transactions.add(Transaction.fromJson(tObj));
                }
            }
        }

        return data;
    }

    public String getUserName() { return userName != null ? userName : "Yeoh"; }
    public String getCampusInfo() { return campusInfo != null ? campusInfo : "UTM Skudai Campus • Financial Snapshot"; }
    public String getPeriod() { return period != null ? period : "Nov 2024"; }
    public double getTotalBalance() { return totalBalance; }
    public double getTotalIncome() { return totalIncome; }
    public double getTotalExpense() { return totalExpense; }
    public String getBalanceStatus() { return balanceStatus != null ? balanceStatus : "Active"; }
    public String getAiInsightTag() { return aiInsightTag; }
    public String getAiInsightMessage() { return aiInsightMessage; }
    public double getAiInsightAmount() { return aiInsightAmount; }
    public String getTrendAvg() { return trendAvg != null ? trendAvg : "RM 45/day"; }
    public List<OutflowDay> getTrendDays() { return trendDays; }
    public List<Transaction> getTransactions() { return transactions; }

    public void setTotalBalance(double totalBalance) { this.totalBalance = totalBalance; }
}

