package com.finwise.app.fragments;

import android.graphics.Typeface;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.fragment.app.Fragment;

import com.finwise.app.models.ApiResponse;
import com.finwise.app.models.DashboardData;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.DashboardService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/** Monthly income, expense and category breakdown. */
public class SummaryFragment extends Fragment {
    private LinearLayout content;
    private EditText monthInput;

    @Override public View onCreateView(android.view.LayoutInflater inflater, ViewGroup container, android.os.Bundle state) {
        ScrollView scroll = new ScrollView(requireContext());
        content = new LinearLayout(requireContext());
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(ViewFactory.dp(requireContext(), 16), ViewFactory.dp(requireContext(), 16), ViewFactory.dp(requireContext(), 16), ViewFactory.dp(requireContext(), 90));
        LinearLayout monthRow = new LinearLayout(requireContext());
        monthRow.setGravity(Gravity.CENTER_VERTICAL);
        monthInput = new EditText(requireContext());
        monthInput.setHint("YYYY-MM");
        monthInput.setSingleLine(true);
        monthInput.setInputType(InputType.TYPE_CLASS_DATETIME | InputType.TYPE_DATETIME_VARIATION_DATE);
        monthRow.addView(monthInput, new LinearLayout.LayoutParams(0, ViewFactory.dp(requireContext(), 52), 1f));
        Button viewButton = ViewFactory.createPrimaryButton(requireContext(), "View", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        monthRow.addView(viewButton, new LinearLayout.LayoutParams(ViewFactory.dp(requireContext(), 100), ViewGroup.LayoutParams.WRAP_CONTENT));
        content.addView(monthRow);
        viewButton.setOnClickListener(v -> load(monthInput.getText().toString().trim()));
        scroll.addView(content);
        monthInput.setText(new SimpleDateFormat("yyyy-MM", Locale.US).format(new Date()));
        return scroll;
    }

    @Override public void onResume() { super.onResume(); if (monthInput != null) load(monthInput.getText().toString().trim()); }

    private void load(String month) {
        if (month == null || month.length() != 7) { Toast.makeText(requireContext(), "Use YYYY-MM format.", Toast.LENGTH_SHORT).show(); return; }
        DashboardService.fetchDashboard(new SessionManager(requireContext()).getToken(), month, new ApiClient.ApiCallback() {
            @Override public void onResponse(ApiResponse response) {
                if (!response.isSuccess()) { Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_LONG).show(); return; }
                render(DashboardData.fromJson(response.getData()));
            }
            @Override public void onError(String errorMessage) { Toast.makeText(requireContext(), errorMessage, Toast.LENGTH_LONG).show(); }
        });
    }

    private void render(DashboardData data) {
        while (content.getChildCount() > 1) content.removeViewAt(1);
        addText("Monthly Summary", 24, ThemeColors.TEXT_PRIMARY, true);
        addText("Income   RM " + money(data.getMonthlyIncome()), 16, ThemeColors.SECONDARY, false);
        addText("Expenses   RM " + money(data.getMonthlyExpense()), 16, 0xFFB42318, false);
        addText("Remaining Balance   RM " + money(data.getMonthlyBalance()), 18, ThemeColors.NAVY_PRIMARY, true);
        addText("Expense Breakdown", 18, ThemeColors.TEXT_PRIMARY, true);
        double max = 0;
        for (DashboardData.CategoryTotal item : data.getExpenseBreakdown()) max = Math.max(max, item.amount);
        if (data.getExpenseBreakdown().isEmpty()) addText("No expenses recorded for this month.", 14, ThemeColors.TEXT_MUTED, false);
        for (DashboardData.CategoryTotal item : data.getExpenseBreakdown()) {
            LinearLayout row = new LinearLayout(requireContext());
            row.setOrientation(LinearLayout.VERTICAL);
            row.setPadding(0, ViewFactory.dp(requireContext(), 6), 0, ViewFactory.dp(requireContext(), 6));
            LinearLayout labels = new LinearLayout(requireContext());
            addTextTo(labels, item.category, 14, ThemeColors.TEXT_PRIMARY, false);
            labels.addView(spacer(), new LinearLayout.LayoutParams(0, 1, 1f));
            addTextTo(labels, "RM " + money(item.amount), 15, 0xFFB42318, true);
            row.addView(labels);
            // A simple proportional bar with no boxed amount labels; the exact amount is shown above.
            LinearLayout track = new LinearLayout(requireContext());
            track.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(requireContext(), 8), 0, 0));
            LinearLayout.LayoutParams trackParams = new LinearLayout.LayoutParams(-1, ViewFactory.dp(requireContext(), 8));
            trackParams.setMargins(0, ViewFactory.dp(requireContext(), 5), 0, 0);
            track.setLayoutParams(trackParams);
            View bar = new View(requireContext());
            int width = max <= 0 ? 0 : Math.max(ViewFactory.dp(requireContext(), 4), (int)(ViewFactory.dp(requireContext(), 280) * item.amount / max));
            bar.setLayoutParams(new LinearLayout.LayoutParams(width, ViewFactory.dp(requireContext(), 8)));
            bar.setBackground(ViewFactory.createRoundedDrawable(0xFFB42318, ViewFactory.dp(requireContext(), 8), 0, 0));
            track.addView(bar);
            row.addView(track);
            content.addView(row);
        }
    }

    private TextView addText(String value, float size, int color, boolean bold) { return addTextTo(content, value, size, color, bold); }
    private TextView addTextTo(LinearLayout parent, String value, float size, int color, boolean bold) {
        TextView view = new TextView(requireContext()); view.setText(value); view.setTextSize(size); view.setTextColor(color);
        view.setTypeface(Typeface.DEFAULT, bold ? Typeface.BOLD : Typeface.NORMAL); view.setPadding(0, ViewFactory.dp(requireContext(), 8), 0, ViewFactory.dp(requireContext(), 4)); parent.addView(view); return view;
    }
    private View spacer() { return new View(requireContext()); }
    private String money(double value) { return String.format(Locale.US, "%.2f", value); }
}
