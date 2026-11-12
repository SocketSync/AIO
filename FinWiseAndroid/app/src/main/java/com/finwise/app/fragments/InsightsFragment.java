package com.finwise.app.fragments;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;

/**
 * Screen: Insights Fragment (Sprint 3 Foundation)
 * AI Financial Intelligence & Spending Pattern Analysis.
 */
public class InsightsFragment extends Fragment {

    public static InsightsFragment newInstance() {
        return new InsightsFragment();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Context context = requireContext();

        ScrollView scrollView = new ScrollView(context);
        scrollView.setFillViewport(true);

        LinearLayout content = new LinearLayout(context);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setBackgroundColor(ThemeColors.BACKGROUND);
        int pad = ViewFactory.dp(context, 16);
        content.setPadding(pad, ViewFactory.dp(context, 16), pad, ViewFactory.dp(context, 80));

        // Header Title
        TextView title = new TextView(context);
        title.setText("AI Financial Insights");
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        content.addView(title);

        TextView sub = new TextView(context);
        sub.setText("Powered by FinWise Campus Intelligence Engine");
        sub.setTextColor(ThemeColors.TEXT_MUTED);
        sub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        sub.setPadding(0, 0, 0, ViewFactory.dp(context, 16));
        content.addView(sub);

        // Financial Health Score Card
        content.addView(createScoreCard(context));

        // Insight 1: Dining Optimization
        content.addView(createInsightCard(context, "🍔 Meal Spending Optimization", 
                "You spend an average of RM 8.50 per meal at Central Cafe versus RM 16.00 outside campus. Eating on campus 3 more times per week can save you ~RM 90/month.", 
                ThemeColors.SECONDARY, "HIGH IMPACT"));

        // Insight 2: Weekend Peak Warning
        content.addView(createInsightCard(context, "⚠️ Weekend Spend Spikes", 
                "Saturday outflows average RM 78.50, which is 74% higher than your weekday average (RM 45.00). Setting a weekend spending cap will stabilize your runway.", 
                ThemeColors.ALERT_CORAL, "BEHAVIOUR ALERT"));

        // Insight 3: Allowance Runway
        content.addView(createInsightCard(context, "🎓 Semester Allowance Health", 
                "With RM 3,420.50 remaining and 78 days left in Sem 2, your safe daily burn rate is RM 43.85. You are currently on track to maintain an end-of-term surplus of RM 450.00.", 
                ThemeColors.NAVY_PRIMARY, "HEALTHY FORECAST"));

        scrollView.addView(content);
        return scrollView;
    }

    private View createScoreCard(Context context) {
        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.HORIZONTAL);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.PRIMARY_CONTAINER, ViewFactory.dp(context, 14), 0, 0));
        card.setPadding(ViewFactory.dp(context, 16), ViewFactory.dp(context, 16), ViewFactory.dp(context, 16), ViewFactory.dp(context, 16));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, 0, 0, ViewFactory.dp(context, 16));
        card.setLayoutParams(params);

        // Circular Score Badge
        TextView score = new TextView(context);
        score.setText("82");
        score.setTextColor(ThemeColors.NAVY_PRIMARY);
        score.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f);
        score.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        score.setGravity(Gravity.CENTER);
        int sSize = ViewFactory.dp(context, 60);
        score.setLayoutParams(new LinearLayout.LayoutParams(sSize, sSize));
        score.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.MINT_SUBTLE, ViewFactory.dp(context, 999), 0, 0));
        card.addView(score);

        LinearLayout textCol = new LinearLayout(context);
        textCol.setOrientation(LinearLayout.VERTICAL);
        textCol.setPadding(ViewFactory.dp(context, 14), 0, 0, 0);

        TextView label = new TextView(context);
        label.setText("CAMPUS FINANCIAL HEALTH");
        label.setTextColor(Color.parseColor("#B6C4FF"));
        label.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        label.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        textCol.addView(label);

        TextView status = new TextView(context);
        status.setText("Excellent • Top 10% Saver");
        status.setTextColor(Color.WHITE);
        status.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f);
        status.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        textCol.addView(status);

        card.addView(textCol);
        return card;
    }

    private View createInsightCard(Context context, String title, String body, int accentColor, String badgeText) {
        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 12), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(context, 1)));
        card.setPadding(ViewFactory.dp(context, 14), ViewFactory.dp(context, 14), ViewFactory.dp(context, 14), ViewFactory.dp(context, 14));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, 0, 0, ViewFactory.dp(context, 12));
        card.setLayoutParams(params);

        LinearLayout topRow = new LinearLayout(context);
        topRow.setOrientation(LinearLayout.HORIZONTAL);
        topRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView titleView = new TextView(context);
        titleView.setText(title);
        titleView.setTextColor(ThemeColors.TEXT_PRIMARY);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        titleView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        titleView.setLayoutParams(tParams);
        topRow.addView(titleView);

        TextView badge = ViewFactory.createPillBadge(context, badgeText, ThemeColors.SURFACE_LOW, accentColor, 10);
        topRow.addView(badge);
        card.addView(topRow);

        TextView bodyView = new TextView(context);
        bodyView.setText(body);
        bodyView.setTextColor(ThemeColors.TEXT_MUTED);
        bodyView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        bodyView.setPadding(0, ViewFactory.dp(context, 8), 0, 0);
        card.addView(bodyView);

        return card;
    }
}

