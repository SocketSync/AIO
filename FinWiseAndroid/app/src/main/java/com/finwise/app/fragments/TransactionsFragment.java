package com.finwise.app.fragments;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.finwise.app.models.ApiResponse;
import com.finwise.app.models.DashboardData;
import com.finwise.app.models.Transaction;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.DashboardService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

import java.util.Locale;

/** User-owned transaction history with edit and delete actions. */
public class TransactionsFragment extends Fragment {
    private LinearLayout list;

    @Override public View onCreateView(android.view.LayoutInflater inflater, ViewGroup container, Bundle state) {
        ScrollView scroll = new ScrollView(requireContext());
        list = new LinearLayout(requireContext());
        list.setOrientation(LinearLayout.VERTICAL);
        list.setPadding(ViewFactory.dp(requireContext(), 16), ViewFactory.dp(requireContext(), 16), ViewFactory.dp(requireContext(), 16), ViewFactory.dp(requireContext(), 90));
        scroll.addView(list);
        return scroll;
    }

    @Override public void onResume() { super.onResume(); load(); }

    private void load() {
        if (list == null) return;
        DashboardService.fetchDashboard(new SessionManager(requireContext()).getToken(), new ApiClient.ApiCallback() {
            @Override public void onResponse(ApiResponse response) {
                if (!response.isSuccess()) { showMessage(response.getMessage()); return; }
                DashboardData data = DashboardData.fromJson(response.getData());
                list.removeAllViews();
                title("Transactions");
                if (data.getTransactions().isEmpty()) { showMessage("No transactions yet. Tap + to add your first transaction."); return; }
                for (Transaction transaction : data.getTransactions()) addRow(transaction);
            }
            @Override public void onError(String errorMessage) { showMessage(errorMessage); }
        });
    }

    private void title(String value) {
        TextView title = new TextView(requireContext());
        title.setText(value);
        title.setTextSize(24f);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setPadding(0, 0, 0, ViewFactory.dp(requireContext(), 12));
        list.addView(title);
    }

    private void showMessage(String message) {
        if (list != null) { list.removeAllViews(); title("Transactions"); }
        if (getContext() != null) Toast.makeText(getContext(), message, Toast.LENGTH_LONG).show();
    }

    private void addRow(Transaction transaction) {
        LinearLayout card = new LinearLayout(requireContext());
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(ViewFactory.dp(requireContext(), 14), ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 14), ViewFactory.dp(requireContext(), 10));
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(requireContext(), 12), ThemeColors.BORDER_NEUTRAL, 1));
        LinearLayout.LayoutParams cardParams = new LinearLayout.LayoutParams(-1, -2);
        cardParams.setMargins(0, 0, 0, ViewFactory.dp(requireContext(), 10));
        card.setLayoutParams(cardParams);

        LinearLayout top = new LinearLayout(requireContext());
        top.setGravity(Gravity.CENTER_VERTICAL);
        TextView name = text(transaction.getTransactionName(), 15, ThemeColors.TEXT_PRIMARY);
        name.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        top.addView(name, new LinearLayout.LayoutParams(0, -2, 1f));
        TextView amount = text(String.format(Locale.US, "%sRM %.2f", transaction.isExpense() ? "-" : "+", transaction.getAmount()), 15,
                transaction.isExpense() ? 0xFFB42318 : ThemeColors.SECONDARY);
        amount.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        top.addView(amount);
        card.addView(top);
        TextView details = text(transaction.getCategory() + "  •  " + transaction.getTransactionDate(), 12, ThemeColors.TEXT_MUTED);
        details.setPadding(0, ViewFactory.dp(requireContext(), 4), 0, ViewFactory.dp(requireContext(), 8));
        card.addView(details);

        LinearLayout actions = new LinearLayout(requireContext());
        actions.setGravity(Gravity.END);
        Button edit = ViewFactory.createSecondaryButton(requireContext(), "Edit", ThemeColors.SURFACE_HIGH, ThemeColors.NAVY_PRIMARY, 0);
        Button delete = ViewFactory.createSecondaryButton(requireContext(), "Delete", ThemeColors.SURFACE_HIGH, 0xFFB42318, 0);
        actions.addView(edit);
        actions.addView(delete);
        card.addView(actions);
        edit.setOnClickListener(v -> {
            if (getActivity() instanceof com.finwise.app.activities.MainActivity) ((com.finwise.app.activities.MainActivity) getActivity()).showEditor(transaction);
        });
        delete.setOnClickListener(v -> delete(transaction));
        list.addView(card);
    }

    private TextView text(String value, float size, int color) {
        TextView view = new TextView(requireContext());
        view.setText(value); view.setTextSize(size); view.setTextColor(color); return view;
    }

    private void delete(Transaction transaction) {
        DashboardService.deleteTransaction(new SessionManager(requireContext()).getToken(), transaction.getId(), new ApiClient.ApiCallback() {
            @Override public void onResponse(ApiResponse response) { Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_SHORT).show(); if (response.isSuccess()) load(); }
            @Override public void onError(String errorMessage) { Toast.makeText(requireContext(), errorMessage, Toast.LENGTH_LONG).show(); }
        });
    }
}
