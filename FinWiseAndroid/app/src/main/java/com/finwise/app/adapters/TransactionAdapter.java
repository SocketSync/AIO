package com.finwise.app.adapters;

import android.content.Context;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.finwise.app.models.Transaction;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * Transaction RecyclerView Adapter
 * Constructed programmatically in Java without XML layout dependency.
 */
public class TransactionAdapter extends RecyclerView.Adapter<TransactionAdapter.ViewHolder> {

    public interface OnTransactionClickListener {
        void onTransactionClick(Transaction transaction);
    }

    private final List<Transaction> items = new ArrayList<>();
    private OnTransactionClickListener clickListener;

    public void setTransactions(List<Transaction> newItems) {
        this.items.clear();
        if (newItems != null) {
            this.items.addAll(newItems);
        }
        notifyDataSetChanged();
    }

    public void setOnTransactionClickListener(OnTransactionClickListener listener) {
        this.clickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Context context = parent.getContext();

        // Row container
        LinearLayout row = new LinearLayout(context);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(ViewFactory.dp(context, 14), ViewFactory.dp(context, 12),
                       ViewFactory.dp(context, 14), ViewFactory.dp(context, 12));
        row.setLayoutParams(new RecyclerView.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 
                ViewGroup.LayoutParams.WRAP_CONTENT
        ));

        // Category Icon Circle
        TextView iconView = new TextView(context);
        int iconSize = ViewFactory.dp(context, 40);
        LinearLayout.LayoutParams iconParams = new LinearLayout.LayoutParams(iconSize, iconSize);
        iconParams.setMargins(0, 0, ViewFactory.dp(context, 12), 0);
        iconView.setLayoutParams(iconParams);
        iconView.setGravity(Gravity.CENTER);
        iconView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        iconView.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(context, 999), 0, 0));
        row.addView(iconView);

        // Middle Text Details (Title & Category/Time)
        LinearLayout textCol = new LinearLayout(context);
        textCol.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams textParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        textCol.setLayoutParams(textParams);

        TextView titleView = new TextView(context);
        titleView.setTextColor(ThemeColors.TEXT_PRIMARY);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        titleView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        titleView.setSingleLine(true);
        textCol.addView(titleView);

        TextView subView = new TextView(context);
        subView.setTextColor(ThemeColors.TEXT_MUTED);
        subView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        subView.setSingleLine(true);
        subView.setPadding(0, ViewFactory.dp(context, 2), 0, 0);
        textCol.addView(subView);

        row.addView(textCol);

        // Right Amount & Note
        LinearLayout rightCol = new LinearLayout(context);
        rightCol.setOrientation(LinearLayout.VERTICAL);
        rightCol.setGravity(Gravity.END);
        rightCol.setPadding(ViewFactory.dp(context, 8), 0, 0, 0);

        TextView amountView = new TextView(context);
        amountView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        amountView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        rightCol.addView(amountView);

        TextView noteView = new TextView(context);
        noteView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        noteView.setPadding(0, ViewFactory.dp(context, 2), 0, 0);
        rightCol.addView(noteView);

        row.addView(rightCol);

        return new ViewHolder(row, iconView, titleView, subView, amountView, noteView);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Transaction item = items.get(position);
        holder.titleView.setText(item.getTransactionName());

        String sub = item.getCategory();
        if (item.getTransactionDate() != null && !item.getTransactionDate().isEmpty()) {
            sub += " • " + item.getTransactionDate();
        }
        holder.subView.setText(sub);

        if (item.isExpense()) {
            holder.amountView.setText(String.format("-RM %.2f", item.getAmount()));
            holder.amountView.setTextColor(ThemeColors.TEXT_PRIMARY);
            holder.noteView.setTextColor(ThemeColors.TEXT_MUTED);
            holder.noteView.setText(item.getNote() != null && !item.getNote().isEmpty() ? item.getNote() : item.getPaymentMethod());
        } else {
            holder.amountView.setText(String.format("+RM %.2f", item.getAmount()));
            holder.amountView.setTextColor(ThemeColors.SECONDARY);
            holder.noteView.setTextColor(ThemeColors.TEXT_MUTED);
            holder.noteView.setText(item.getPaymentMethod());
        }

        // Set Category Icon based on name/category
        String catLower = item.getCategory().toLowerCase();
        String nameLower = item.getTransactionName().toLowerCase();
        if (catLower.contains("food") || catLower.contains("dining") || nameLower.contains("arked") || nameLower.contains("lunch")) {
            holder.iconView.setText("🍽️");
            holder.iconView.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(holder.itemView.getContext(), 999), 0, 0));
        } else if (catLower.contains("transfer") || catLower.contains("allowance") || !item.isExpense()) {
            holder.iconView.setText("💵");
            holder.iconView.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.MINT_SUBTLE, ViewFactory.dp(holder.itemView.getContext(), 999), 0, 0));
        } else if (catLower.contains("edu") || catLower.contains("book") || nameLower.contains("stationery")) {
            holder.iconView.setText("📚");
            holder.iconView.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(holder.itemView.getContext(), 999), 0, 0));
        } else if (catLower.contains("transport") || nameLower.contains("grab")) {
            holder.iconView.setText("🚕");
            holder.iconView.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(holder.itemView.getContext(), 999), 0, 0));
        } else {
            holder.iconView.setText("💳");
            holder.iconView.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(holder.itemView.getContext(), 999), 0, 0));
        }

        holder.itemView.setOnClickListener(v -> {
            if (clickListener != null) {
                clickListener.onTransactionClick(item);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public final TextView iconView;
        public final TextView titleView;
        public final TextView subView;
        public final TextView amountView;
        public final TextView noteView;

        public ViewHolder(View itemView, TextView iconView, TextView titleView, 
                          TextView subView, TextView amountView, TextView noteView) {
            super(itemView);
            this.iconView = iconView;
            this.titleView = titleView;
            this.subView = subView;
            this.amountView = amountView;
            this.noteView = noteView;
        }
    }
}

