package com.finwise.app.models;

import org.json.JSONObject;

/**
 * Transaction Model
 */
public class Transaction {
    private int id;
    private String transactionName;
    private String category;
    private double amount;
    private String transactionType; // "income" or "expense"
    private String transactionDate;
    private String paymentMethod;
    private String note;

    public Transaction() {}

    public Transaction(int id, String transactionName, String category, double amount, 
                       String transactionType, String transactionDate, String paymentMethod, String note) {
        this.id = id;
        this.transactionName = transactionName;
        this.category = category;
        this.amount = amount;
        this.transactionType = transactionType;
        this.transactionDate = transactionDate;
        this.paymentMethod = paymentMethod;
        this.note = note;
    }

    public static Transaction fromJson(JSONObject json) {
        if (json == null) return null;
        Transaction t = new Transaction();
        t.id = json.optInt("id", 0);
        t.transactionName = json.optString("transaction_name", "Transaction");
        t.category = json.optString("category", "General");
        t.amount = json.optDouble("amount", 0.0);
        t.transactionType = json.optString("transaction_type", "expense");
        t.transactionDate = json.optString("transaction_date", "");
        t.paymentMethod = json.optString("payment_method", "Debit Card");
        t.note = json.optString("note", "");
        return t;
    }

    public int getId() { return id; }
    public String getTransactionName() { return transactionName; }
    public String getCategory() { return category; }
    public double getAmount() { return amount; }
    public String getTransactionType() { return transactionType; }
    public String getTransactionDate() { return transactionDate; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getNote() { return note; }

    public boolean isExpense() {
        return "expense".equalsIgnoreCase(transactionType);
    }
}

