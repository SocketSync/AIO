package com.finwise.app.models;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/** Real user-scoped totals returned by the dashboard API. */
public class DashboardData {
    public static class CategoryTotal {
        public final String category;
        public final double amount;

        public CategoryTotal(String category, double amount) {
            this.category = category;
            this.amount = amount;
        }
    }

    private String userName = "Student";
    private double totalBalance;
    private double totalIncome;
    private double totalExpense;
    private double monthlyIncome;
    private double monthlyExpense;
    private double monthlyBalance;
    private String month = "";
    private final List<Transaction> transactions = new ArrayList<>();
    private final List<CategoryTotal> expenseBreakdown = new ArrayList<>();

    public static DashboardData fromJson(JSONObject json) {
        DashboardData data = new DashboardData();
        if (json == null) return data;

        JSONObject user = json.optJSONObject("user");
        if (user != null) data.userName = user.optString("full_name", "Student");

        JSONObject balance = json.optJSONObject("balance");
        if (balance != null) {
            data.totalIncome = balance.optDouble("total_income", 0.0);
            data.totalExpense = balance.optDouble("total_expense", 0.0);
            data.totalBalance = balance.optDouble("total_available", data.totalIncome - data.totalExpense);
        }

        JSONArray recent = json.optJSONArray("recent_transactions");
        if (recent != null) {
            for (int i = 0; i < recent.length(); i++) {
                Transaction transaction = Transaction.fromJson(recent.optJSONObject(i));
                if (transaction != null) data.transactions.add(transaction);
            }
        }

        JSONObject monthly = json.optJSONObject("monthly_summary");
        if (monthly != null) {
            data.month = monthly.optString("month", "");
            data.monthlyIncome = monthly.optDouble("total_income", 0.0);
            data.monthlyExpense = monthly.optDouble("total_expense", 0.0);
            data.monthlyBalance = monthly.optDouble("balance", data.monthlyIncome - data.monthlyExpense);
            JSONArray breakdown = monthly.optJSONArray("expense_breakdown");
            if (breakdown != null) {
                for (int i = 0; i < breakdown.length(); i++) {
                    JSONObject item = breakdown.optJSONObject(i);
                    if (item != null) data.expenseBreakdown.add(new CategoryTotal(
                            item.optString("category", "Other Expenses"), item.optDouble("amount", 0.0)));
                }
            }
        }
        return data;
    }

    public String getUserName() { return userName; }
    public double getTotalBalance() { return totalBalance; }
    public double getTotalIncome() { return totalIncome; }
    public double getTotalExpense() { return totalExpense; }
    public double getMonthlyIncome() { return monthlyIncome; }
    public double getMonthlyExpense() { return monthlyExpense; }
    public double getMonthlyBalance() { return monthlyBalance; }
    public String getMonth() { return month; }
    public List<Transaction> getTransactions() { return transactions; }
    public List<CategoryTotal> getExpenseBreakdown() { return expenseBreakdown; }
}
