package com.finwise.app.ui;

import android.content.Context;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.finwise.app.models.DashboardData.OutflowDay;

import java.util.ArrayList;
import java.util.List;

/**
 * 7-Day Outflow Trend Bar Chart Component
 * Native Java implementation reproducing the FinWise reference bar chart.
 */
public class OutflowTrendBarView extends LinearLayout {

    private final List<OutflowDay> days = new ArrayList<>();
    private LinearLayout chartRow;

    public OutflowTrendBarView(Context context) {
        super(context);
        init();
    }

    private void init() {
        setOrientation(VERTICAL);
        setPadding(ViewFactory.dp(getContext(), 14), ViewFactory.dp(getContext(), 14),
                   ViewFactory.dp(getContext(), 14), ViewFactory.dp(getContext(), 14));
        setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(getContext(), 14), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(getContext(), 1)));

        // Header Row: Title & Average badge
        LinearLayout headerRow = new LinearLayout(getContext());
        headerRow.setOrientation(HORIZONTAL);
        headerRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView iconView = new TextView(getContext());
        iconView.setText("📊 ");
        iconView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f);
        headerRow.addView(iconView);

        TextView titleView = new TextView(getContext());
        titleView.setText("7-Day Outflow Trend");
        titleView.setTextColor(ThemeColors.TEXT_PRIMARY);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        titleView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LayoutParams titleParams = new LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f);
        titleView.setLayoutParams(titleParams);
        headerRow.addView(titleView);

        // Avg badge
        TextView avgBadge = ViewFactory.createPillBadge(getContext(), "Avg: RM 45/day", ThemeColors.SURFACE_LOW, ThemeColors.TEXT_PRIMARY, 11);
        headerRow.addView(avgBadge);

        addView(headerRow);

        // Chart Bar Row
        chartRow = new LinearLayout(getContext());
        chartRow.setOrientation(HORIZONTAL);
        chartRow.setGravity(Gravity.BOTTOM);
        LayoutParams chartParams = new LayoutParams(LayoutParams.MATCH_PARENT, ViewFactory.dp(getContext(), 120));
        chartParams.setMargins(0, ViewFactory.dp(getContext(), 16), 0, 0);
        chartRow.setLayoutParams(chartParams);

        addView(chartRow);

        // Default demo days
        loadDefaultDays();
    }

    private void loadDefaultDays() {
        days.clear();
        addDay("M", "Mon", 35.00, false, false);
        addDay("T", "Tue", 52.00, false, false);
        addDay("W", "Wed", 24.50, false, false);
        addDay("T", "Thu", 62.00, false, false);
        addDay("F", "Fri", 41.00, false, false);
        addDay("S", "Sat", 78.50, false, true); // Peak
        addDay("S", "Sun", 30.50, true, false);  // Today
        renderBars();
    }

    private void addDay(String letter, String full, double amount, boolean isToday, boolean isPeak) {
        OutflowDay d = new OutflowDay();
        d.dayLetter = letter;
        d.fullDay = full;
        d.amount = amount;
        d.isToday = isToday;
        d.isPeak = isPeak;
        days.add(d);
    }

    public void setDays(List<OutflowDay> newDays) {
        if (newDays != null && !newDays.isEmpty()) {
            this.days.clear();
            this.days.addAll(newDays);
            renderBars();
        }
    }

    private void renderBars() {
        chartRow.removeAllViews();
        double maxAmount = 90.00; // Normalizing scale
        int maxBarHeightPx = ViewFactory.dp(getContext(), 90);

        for (OutflowDay day : days) {
            LinearLayout column = new LinearLayout(getContext());
            column.setOrientation(VERTICAL);
            column.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
            LayoutParams colParams = new LayoutParams(0, LayoutParams.MATCH_PARENT, 1f);
            colParams.setMargins(ViewFactory.dp(getContext(), 2), 0, ViewFactory.dp(getContext(), 2), 0);
            column.setLayoutParams(colParams);

            // Compute proportional bar height
            int barHeight = (int) ((day.amount / maxAmount) * maxBarHeightPx);
            if (barHeight < ViewFactory.dp(getContext(), 12)) {
                barHeight = ViewFactory.dp(getContext(), 12);
            }

            View bar = new View(getContext());
            LayoutParams barParams = new LayoutParams(ViewFactory.dp(getContext(), 26), barHeight);
            bar.setLayoutParams(barParams);

            int barColor;
            if (day.isPeak) {
                barColor = ThemeColors.ALERT_CORAL;
            } else if (day.isToday) {
                barColor = ThemeColors.PRIMARY_CONTAINER;
            } else {
                barColor = ThemeColors.SURFACE_HIGH;
            }

            GradientDrawable barDrawable = ViewFactory.createRoundedDrawable(barColor, ViewFactory.dp(getContext(), 6), 0, 0);
            bar.setBackground(barDrawable);

            bar.setOnClickListener(v -> {
                String desc = day.fullDay + ": RM " + String.format("%.2f", day.amount) + (day.isToday ? " (Today)" : (day.isPeak ? " (Peak)" : ""));
                Toast.makeText(getContext(), desc, Toast.LENGTH_SHORT).show();
            });

            column.addView(bar);

            // Day letter label
            TextView label = new TextView(getContext());
            label.setText(day.dayLetter);
            label.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
            label.setGravity(Gravity.CENTER);
            label.setPadding(0, ViewFactory.dp(getContext(), 6), 0, 0);

            if (day.isPeak) {
                label.setTextColor(ThemeColors.ALERT_CORAL);
                label.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
            } else if (day.isToday) {
                label.setTextColor(ThemeColors.NAVY_PRIMARY);
                label.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
            } else {
                label.setTextColor(ThemeColors.TEXT_MUTED);
                label.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL));
            }

            column.addView(label);
            chartRow.addView(column);
        }
    }
}

