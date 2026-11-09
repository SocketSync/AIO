package com.finwise.app.fragments;

import android.graphics.Typeface;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
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

/** Personal expense tracker home dashboard. No demo values are used. */
public class HomeFragment extends Fragment {
    public interface DashboardNavigationListener { void navigateToTab(int tabIndex); }
    private LinearLayout content;
    private DashboardNavigationListener navListener;

    public static HomeFragment newInstance() { return new HomeFragment(); }
    @Override public void onAttach(android.content.Context context) { super.onAttach(context); if (context instanceof DashboardNavigationListener) navListener = (DashboardNavigationListener) context; }

    @Override public View onCreateView(android.view.LayoutInflater inflater, ViewGroup container, android.os.Bundle state) {
        ScrollView scroll = new ScrollView(requireContext());
        content = new LinearLayout(requireContext());
        content.setOrientation(LinearLayout.VERTICAL);
        content.setBackgroundColor(ThemeColors.BACKGROUND);
        int pad = ViewFactory.dp(requireContext(), 16);
        content.setPadding(pad, ViewFactory.dp(requireContext(), 16), pad, ViewFactory.dp(requireContext(), 90));
        scroll.addView(content);
        return scroll;
    }

    @Override public void onResume() { super.onResume(); loadDashboard(); }

    private void loadDashboard() {
        DashboardService.fetchDashboard(new SessionManager(requireContext()).getToken(), new ApiClient.ApiCallback() {
            @Override public void onResponse(ApiResponse response) {
                if (!response.isSuccess()) { Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_LONG).show(); return; }
                render(DashboardData.fromJson(response.getData()));
            }
            @Override public void onError(String errorMessage) { Toast.makeText(requireContext(), errorMessage, Toast.LENGTH_LONG).show(); }
        });
    }

    private void render(DashboardData data) {
        content.removeAllViews();
        addText("Hello, " + firstName(data.getUserName()) + "!", 20, ThemeColors.TEXT_PRIMARY, true);
        addText("Personal expense tracker", 13, ThemeColors.TEXT_MUTED, false);
        addText("Total Balance", 13, ThemeColors.TEXT_MUTED, false);
        addCard("RM " + money(data.getTotalBalance()), ThemeColors.NAVY_PRIMARY, 28);

        LinearLayout totals = new LinearLayout(requireContext());
        totals.setGravity(Gravity.CENTER_VERTICAL);
        addMetric(totals, "Income", data.getTotalIncome(), ThemeColors.SECONDARY);
        addMetric(totals, "Expenses", data.getTotalExpense(), 0xFFB42318);
        content.addView(totals);
        addText("Recent Transactions", 18, ThemeColors.TEXT_PRIMARY, true);
        if (data.getTransactions().isEmpty()) {
            addText("No transactions yet. Tap + to record your first income or expense.", 14, ThemeColors.TEXT_MUTED, false);
        } else {
            for (Transaction transaction : data.getTransactions()) addTransaction(transaction);
        }
    }

    private void addMetric(LinearLayout parent, String label, double amount, int color) {
        LinearLayout card = new LinearLayout(requireContext());
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 12));
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(requireContext(), 10), ThemeColors.BORDER_NEUTRAL, 1));
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(0, -2, 1f); p.setMargins(0, ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 8), 0); card.setLayoutParams(p);
        addTextTo(card, label, 12, ThemeColors.TEXT_MUTED, false); addTextTo(card, "RM " + money(amount), 16, color, true); parent.addView(card);
    }

    private void addTransaction(Transaction transaction) {
        LinearLayout row = new LinearLayout(requireContext());
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 10), ViewFactory.dp(requireContext(), 12), ViewFactory.dp(requireContext(), 10));
        row.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(requireContext(), 10), ThemeColors.BORDER_NEUTRAL, 1));
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, -2); p.setMargins(0, ViewFactory.dp(requireContext(), 8), 0, 0); row.setLayoutParams(p);
        LinearLayout details = new LinearLayout(requireContext()); details.setOrientation(LinearLayout.VERTICAL); row.addView(details, new LinearLayout.LayoutParams(0, -2, 1f));
        addTextTo(details, transaction.getTransactionName(), 14, ThemeColors.TEXT_PRIMARY, true);
        addTextTo(details, transaction.getCategory() + " • " + transaction.getTransactionDate(), 12, ThemeColors.TEXT_MUTED, false);
        addTextTo(row, String.format(Locale.US, "%sRM %.2f", transaction.isExpense() ? "-" : "+", transaction.getAmount()), 14, transaction.isExpense() ? 0xFFB42318 : ThemeColors.SECONDARY, true);
        content.addView(row);
    }

    private void addCard(String value, int color, float size) {
        TextView card = addText(value, size, ThemeColors.ON_PRIMARY, true);
        card.setGravity(Gravity.CENTER_VERTICAL); card.setPadding(ViewFactory.dp(requireContext(), 18), ViewFactory.dp(requireContext(), 14), ViewFactory.dp(requireContext(), 18), ViewFactory.dp(requireContext(), 14));
        card.setBackground(ViewFactory.createRoundedDrawable(color, ViewFactory.dp(requireContext(), 14), 0, 0));
    }
    private TextView addText(String value, float size, int color, boolean bold) { return addTextTo(content, value, size, color, bold); }
    private TextView addTextTo(LinearLayout parent, String value, float size, int color, boolean bold) { TextView v = new TextView(requireContext()); v.setText(value); v.setTextSize(size); v.setTextColor(color); v.setTypeface(Typeface.DEFAULT, bold ? Typeface.BOLD : Typeface.NORMAL); parent.addView(v); return v; }
    private String firstName(String name) { return name == null || name.trim().isEmpty() ? "there" : name.trim().split("\\s+")[0]; }
    private String money(double amount) { return String.format(Locale.US, "%.2f", amount); }
}
