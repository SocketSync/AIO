package com.finwise.app.fragments;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.ClipDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;

/**
 * Screen: Budgets Fragment (Sprint 2 Foundation)
 * Pure native Java implementation for category spending limits & monitoring.
 */
public class BudgetFragment extends Fragment {

    public static BudgetFragment newInstance() {
        return new BudgetFragment();
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
        title.setText("Monthly Budgets");
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        content.addView(title);

        TextView sub = new TextView(context);
        sub.setText("November 2024 • Overall Budget Utilisation: 53%");
        sub.setTextColor(ThemeColors.TEXT_MUTED);
        sub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        sub.setPadding(0, 0, 0, ViewFactory.dp(context, 16));
        content.addView(sub);

        // Category Cards
        content.addView(createBudgetCategoryCard(context, "🍽️ Food & Dining", 420.50, 700.00, ThemeColors.NAVY_PRIMARY));
        content.addView(createBudgetCategoryCard(context, "📚 Education & Books", 120.00, 300.00, ThemeColors.SECONDARY));
        content.addView(createBudgetCategoryCard(context, "🚕 Transport & Commute", 180.00, 250.00, Color.parseColor("#D97706")));
        content.addView(createBudgetCategoryCard(context, "🎮 Leisure & Social", 210.00, 200.00, ThemeColors.ALERT_CORAL)); // Over budget demo

        // Set New Budget Button
        Button addBudgetBtn = ViewFactory.createPrimaryButton(context, "+ Set Category Budget", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        btnParams.setMargins(0, ViewFactory.dp(context, 16), 0, 0);
        addBudgetBtn.setLayoutParams(btnParams);
        addBudgetBtn.setOnClickListener(v -> Toast.makeText(context, "Budget creation wizard will open in Sprint 2.", Toast.LENGTH_SHORT).show());
        content.addView(addBudgetBtn);

        scrollView.addView(content);
        return scrollView;
    }

    private View createBudgetCategoryCard(Context context, String categoryName, double spent, double limit, int accentColor) {
        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 12), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(context, 1)));
        card.setPadding(ViewFactory.dp(context, 14), ViewFactory.dp(context, 14), ViewFactory.dp(context, 14), ViewFactory.dp(context, 14));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, 0, 0, ViewFactory.dp(context, 12));
        card.setLayoutParams(params);

        // Title & Spent Row
        LinearLayout row1 = new LinearLayout(context);
        row1.setOrientation(LinearLayout.HORIZONTAL);
        row1.setGravity(Gravity.CENTER_VERTICAL);

        TextView catTitle = new TextView(context);
        catTitle.setText(categoryName);
        catTitle.setTextColor(ThemeColors.TEXT_PRIMARY);
        catTitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        catTitle.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams p1 = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        catTitle.setLayoutParams(p1);
        row1.addView(catTitle);

        TextView amounts = new TextView(context);
        amounts.setText(String.format("RM %.2f / RM %.2f", spent, limit));
        amounts.setTextColor(spent > limit ? ThemeColors.ALERT_CORAL : ThemeColors.TEXT_PRIMARY);
        amounts.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        amounts.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        row1.addView(amounts);
        card.addView(row1);

        // Progress Bar
        int progressPercent = (int) Math.min(100, (spent / limit) * 100);

        ProgressBar bar = new ProgressBar(context, null, android.R.attr.progressBarStyleHorizontal);
        bar.setMax(100);
        bar.setProgress(progressPercent);

        GradientDrawable bg = ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(context, 4), 0, 0);
        GradientDrawable fg = ViewFactory.createRoundedDrawable(spent > limit ? ThemeColors.ALERT_CORAL : accentColor, ViewFactory.dp(context, 4), 0, 0);
        ClipDrawable clip = new ClipDrawable(fg, Gravity.START, ClipDrawable.HORIZONTAL);
        bar.setProgressDrawable(new android.graphics.drawable.LayerDrawable(new android.graphics.drawable.Drawable[]{bg, clip}));

        LinearLayout.LayoutParams barParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewFactory.dp(context, 8));
        barParams.setMargins(0, ViewFactory.dp(context, 10), 0, ViewFactory.dp(context, 6));
        bar.setLayoutParams(barParams);
        card.addView(bar);

        // Status Subtitle
        TextView status = new TextView(context);
        if (spent > limit) {
            status.setText("⚠️ Over budget by RM " + String.format("%.2f", spent - limit));
            status.setTextColor(ThemeColors.ALERT_CORAL);
        } else {
            status.setText(String.format("%.0f%% used • RM %.2f remaining", (spent / limit) * 100, limit - spent));
            status.setTextColor(ThemeColors.TEXT_MUTED);
        }
        status.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        card.addView(status);

        return card;
    }
}

