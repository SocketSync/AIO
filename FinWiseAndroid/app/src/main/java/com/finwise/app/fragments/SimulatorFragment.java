package com.finwise.app.fragments;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;

import java.util.Locale;

/**
 * Screen: Financial Simulator Fragment (Sprint 3 C++ Engine Foundation)
 * Simulates semester allowance runway, daily burn rates, and spending adjustments.
 */
public class SimulatorFragment extends Fragment {

    private EditText startingBalanceInput;
    private SeekBar dailySpendSeekBar;
    private TextView dailySpendLabel;
    private TextView resultRunway;
    private TextView resultSurplus;
    private TextView resultAssessment;

    private int selectedDailySpend = 45;

    public static SimulatorFragment newInstance() {
        return new SimulatorFragment();
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
        title.setText("Financial Scenario Simulator");
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        content.addView(title);

        TextView sub = new TextView(context);
        sub.setText("Engineered with C++ Simulation algorithms to forecast your monthly budget runway.");
        sub.setTextColor(ThemeColors.TEXT_MUTED);
        sub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        sub.setPadding(0, 0, 0, ViewFactory.dp(context, 16));
        content.addView(sub);

        // Input Card
        LinearLayout inputCard = new LinearLayout(context);
        inputCard.setOrientation(LinearLayout.VERTICAL);
        inputCard.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 12), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(context, 1)));
        inputCard.setPadding(ViewFactory.dp(context, 14), ViewFactory.dp(context, 14), ViewFactory.dp(context, 14), ViewFactory.dp(context, 14));

        // Starting Balance Input
        startingBalanceInput = new EditText(context);
        startingBalanceInput.setText("3420.50");
        startingBalanceInput.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
        inputCard.addView(ViewFactory.createInputContainer(context, "Current Available Funds (RM)", "💰", startingBalanceInput));

        // Daily Spend Slider
        TextView spendHeader = new TextView(context);
        spendHeader.setText("Simulated Daily Burn Rate (RM)");
        spendHeader.setTextColor(ThemeColors.TEXT_MUTED);
        spendHeader.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        spendHeader.setPadding(0, ViewFactory.dp(context, 14), 0, ViewFactory.dp(context, 4));
        inputCard.addView(spendHeader);

        dailySpendLabel = new TextView(context);
        dailySpendLabel.setText("RM 45.00 / day");
        dailySpendLabel.setTextColor(ThemeColors.NAVY_PRIMARY);
        dailySpendLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        dailySpendLabel.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        inputCard.addView(dailySpendLabel);

        dailySpendSeekBar = new SeekBar(context);
        dailySpendSeekBar.setMax(120);
        dailySpendSeekBar.setProgress(45);
        dailySpendSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                selectedDailySpend = Math.max(10, progress);
                dailySpendLabel.setText(String.format(Locale.getDefault(), "RM %d.00 / day", selectedDailySpend));
            }
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                runSimulation();
            }
        });
        LinearLayout.LayoutParams seekParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        seekParams.setMargins(0, ViewFactory.dp(context, 6), 0, ViewFactory.dp(context, 10));
        dailySpendSeekBar.setLayoutParams(seekParams);
        inputCard.addView(dailySpendSeekBar);

        // Run Button
        Button runBtn = ViewFactory.createPrimaryButton(context, "Simulate Semester Runway 🚀", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        runBtn.setOnClickListener(v -> runSimulation());
        inputCard.addView(runBtn);

        content.addView(inputCard);

        // Simulation Output Card
        LinearLayout resultCard = new LinearLayout(context);
        resultCard.setOrientation(LinearLayout.VERTICAL);
        resultCard.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.PRIMARY_CONTAINER, ViewFactory.dp(context, 14), 0, 0));
        resultCard.setPadding(ViewFactory.dp(context, 16), ViewFactory.dp(context, 16), ViewFactory.dp(context, 16), ViewFactory.dp(context, 16));
        LinearLayout.LayoutParams resParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        resParams.setMargins(0, ViewFactory.dp(context, 16), 0, 0);
        resultCard.setLayoutParams(resParams);

        TextView resTitle = new TextView(context);
        resTitle.setText("PROJECTION RESULTS (18 WEEKS / 126 DAYS)");
        resTitle.setTextColor(Color.parseColor("#B6C4FF"));
        resTitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        resTitle.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        resultCard.addView(resTitle);

        resultRunway = new TextView(context);
        resultRunway.setText("Runway: 76 Days of 126");
        resultRunway.setTextColor(Color.WHITE);
        resultRunway.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        resultRunway.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        resultRunway.setPadding(0, ViewFactory.dp(context, 8), 0, 0);
        resultCard.addView(resultRunway);

        resultSurplus = new TextView(context);
        resultSurplus.setText("Projected End Balance: -RM 2,249.50");
        resultSurplus.setTextColor(Color.parseColor("#FFDAD6"));
        resultSurplus.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        resultCard.addView(resultSurplus);

        resultAssessment = new TextView(context);
        resultAssessment.setText("At RM 45/day, current funds deplete before the 18-week semester finishes. Target daily spend should be under RM 27.15/day.");
        resultAssessment.setTextColor(Color.WHITE);
        resultAssessment.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        resultAssessment.setPadding(0, ViewFactory.dp(context, 10), 0, 0);
        resultCard.addView(resultAssessment);

        content.addView(resultCard);

        scrollView.addView(content);

        runSimulation();

        return scrollView;
    }

    private void runSimulation() {
        double balance = 3420.50;
        try {
            balance = Double.parseDouble(startingBalanceInput.getText().toString().trim());
        } catch (Exception ignored) {}

        int totalDays = 126; // 18 weeks monthly budget
        double dailyRate = selectedDailySpend;
        double finalBalance = balance - (dailyRate * totalDays);
        int daysUntilDepleted = (int) (balance / dailyRate);

        if (daysUntilDepleted < totalDays) {
            resultRunway.setText(String.format(Locale.getDefault(), "Runway: %d Days of %d (Shortage)", daysUntilDepleted, totalDays));
            resultSurplus.setText(String.format(Locale.getDefault(), "Deficit at Term End: -RM %,.2f", Math.abs(finalBalance)));
            resultSurplus.setTextColor(Color.parseColor("#FFDAD6"));
            double safeRate = balance / totalDays;
            resultAssessment.setText(String.format(Locale.getDefault(),
                    "⚠️ HIGH RISK: Current burn rate will exhaust semester funds on day %d. To last all 18 weeks, adjust daily spending to under RM %.2f/day.",
                    daysUntilDepleted, safeRate));
        } else {
            resultRunway.setText(String.format(Locale.getDefault(), "Runway: 100%% Sustainable (%d Days)", totalDays));
            resultSurplus.setText(String.format(Locale.getDefault(), "Projected Term Surplus: +RM %,.2f", finalBalance));
            resultSurplus.setTextColor(ThemeColors.MINT_SUBTLE);
            resultAssessment.setText("✅ HEALTHY: Your campus burn rate leaves a comfortable buffer for unforeseen emergencies and savings goals!");
        }
    }
}

