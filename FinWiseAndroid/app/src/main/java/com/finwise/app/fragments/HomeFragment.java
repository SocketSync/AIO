package com.finwise.app.fragments;

import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.finwise.app.adapters.TransactionAdapter;
import com.finwise.app.models.ApiResponse;
import com.finwise.app.models.DashboardData;
import com.finwise.app.models.Transaction;
import com.finwise.app.models.User;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.DashboardService;
import com.finwise.app.ui.BottomNavBarView;
import com.finwise.app.ui.OutflowTrendBarView;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

import java.util.Locale;

/**
 * Screen 4: Home Dashboard Fragment
 * Completely native Java implementation matching the FinWise Home Dashboard reference.
 */
public class HomeFragment extends Fragment {

    public interface DashboardNavigationListener {
        void navigateToTab(int tabIndex);
    }

    private SwipeRefreshLayout swipeRefresh;
    private TextView greetingName;
    private TextView balanceTextView;
    private TextView incomeTextView;
    private TextView expenseTextView;
    private TextView eyeToggleBtn;
    private LinearLayout aiInsightWidget;
    private Button transferQuickBtn;
    private OutflowTrendBarView outflowTrendView;
    private RecyclerView transactionsRecycler;
    private TransactionAdapter transactionAdapter;

    private boolean isBalanceHidden = false;
    private double currentBalance = 3420.50;
    private SessionManager sessionManager;
    private DashboardNavigationListener navListener;

    public static HomeFragment newInstance() {
        return new HomeFragment();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof DashboardNavigationListener) {
            navListener = (DashboardNavigationListener) context;
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Context context = requireContext();
        sessionManager = new SessionManager(context);

        swipeRefresh = new SwipeRefreshLayout(context);
        swipeRefresh.setColorSchemeColors(ThemeColors.NAVY_PRIMARY, ThemeColors.SECONDARY);

        ScrollView scrollView = new ScrollView(context);
        scrollView.setFillViewport(true);

        LinearLayout content = new LinearLayout(context);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setBackgroundColor(ThemeColors.BACKGROUND);
        int pad = ViewFactory.dp(context, 16);
        content.setPadding(pad, ViewFactory.dp(context, 12), pad, ViewFactory.dp(context, 80)); // 80dp space for bottom nav

        // 1. AI Pull-Down / Copilot Banner
        content.addView(createAiCopilotBanner(context));

        // 2. Greeting & Month Bar
        content.addView(createGreetingSection(context));

        // 3. Main Bento Hero Balance Card
        content.addView(createBalanceHeroCard(context));

        // 4. Smart Spend Alert Widget
        aiInsightWidget = createSmartSpendAlertWidget(context);
        content.addView(aiInsightWidget);

        // 5. 7-Day Outflow Trend Chart
        outflowTrendView = new OutflowTrendBarView(context);
        LinearLayout.LayoutParams trendParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        trendParams.setMargins(0, ViewFactory.dp(context, 16), 0, 0);
        outflowTrendView.setLayoutParams(trendParams);
        content.addView(outflowTrendView);

        // 6. Recent Transactions Section
        content.addView(createRecentTransactionsSection(context));

        scrollView.addView(content);
        swipeRefresh.addView(scrollView);

        swipeRefresh.setOnRefreshListener(this::loadDashboardData);

        return swipeRefresh;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        loadDashboardData();
    }

    private View createAiCopilotBanner(Context context) {
        LinearLayout banner = new LinearLayout(context);
        banner.setOrientation(LinearLayout.HORIZONTAL);
        banner.setGravity(Gravity.CENTER_VERTICAL);
        banner.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 12), ThemeColors.PRIMARY_CONTAINER, ViewFactory.dp(context, 1)));
        banner.setPadding(ViewFactory.dp(context, 12), ViewFactory.dp(context, 10), ViewFactory.dp(context, 12), ViewFactory.dp(context, 10));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, 0, 0, ViewFactory.dp(context, 14));
        banner.setLayoutParams(params);

        // Icon circle
        TextView icon = new TextView(context);
        icon.setText("✨");
        icon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        icon.setGravity(Gravity.CENTER);
        int iconSize = ViewFactory.dp(context, 32);
        icon.setLayoutParams(new LinearLayout.LayoutParams(iconSize, iconSize));
        icon.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.PRIMARY_CONTAINER, ViewFactory.dp(context, 999), 0, 0));
        banner.addView(icon);

        LinearLayout textCol = new LinearLayout(context);
        textCol.setOrientation(LinearLayout.VERTICAL);
        textCol.setPadding(ViewFactory.dp(context, 10), 0, 0, 0);
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        textCol.setLayoutParams(tParams);

        LinearLayout titleRow = new LinearLayout(context);
        titleRow.setOrientation(LinearLayout.HORIZONTAL);
        titleRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView title = new TextView(context);
        title.setText("Try FinWise AI Copilot ");
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        titleRow.addView(title);

        TextView newBadge = ViewFactory.createPillBadge(context, "NEW", ThemeColors.MINT_SUBTLE, ThemeColors.SECONDARY, 9);
        titleRow.addView(newBadge);
        textCol.addView(titleRow);

        TextView sub = new TextView(context);
        sub.setText("Pull down or tap to log via voice & receipt OCR");
        sub.setTextColor(ThemeColors.TEXT_MUTED);
        sub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        textCol.addView(sub);

        banner.addView(textCol);

        TextView openPrompt = new TextView(context);
        openPrompt.setText("Open ▾");
        openPrompt.setTextColor(ThemeColors.NAVY_PRIMARY);
        openPrompt.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        openPrompt.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        banner.addView(openPrompt);

        banner.setOnClickListener(v -> showAiCopilotDialog());
        return banner;
    }

    private View createGreetingSection(Context context) {
        LinearLayout row = new LinearLayout(context);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, 0, 0, ViewFactory.dp(context, 16));

        LinearLayout textCol = new LinearLayout(context);
        textCol.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        textCol.setLayoutParams(tParams);

        User user = sessionManager.getUser();
        String name = (user != null && user.getFullName() != null && !user.getFullName().isEmpty()) 
                ? user.getFullName().split(" ")[0] 
                : "Yeoh";

        greetingName = new TextView(context);
        greetingName.setText("Hello, " + name + "! 👋");
        greetingName.setTextColor(ThemeColors.TEXT_PRIMARY);
        greetingName.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        greetingName.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        textCol.addView(greetingName);

        TextView campusSub = new TextView(context);
        campusSub.setText("UTM Skudai Campus • Financial Snapshot");
        campusSub.setTextColor(ThemeColors.TEXT_MUTED);
        campusSub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        textCol.addView(campusSub);

        row.addView(textCol);

        // Month Selector Pill
        LinearLayout monthPill = new LinearLayout(context);
        monthPill.setOrientation(LinearLayout.HORIZONTAL);
        monthPill.setGravity(Gravity.CENTER_VERTICAL);
        monthPill.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_HIGH, ViewFactory.dp(context, 999), 0, 0));
        monthPill.setPadding(ViewFactory.dp(context, 10), ViewFactory.dp(context, 6), ViewFactory.dp(context, 10), ViewFactory.dp(context, 6));

        TextView calIcon = new TextView(context);
        calIcon.setText("📅 ");
        calIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        monthPill.addView(calIcon);

        TextView monthText = new TextView(context);
        monthText.setText("Nov 2024 ▾");
        monthText.setTextColor(ThemeColors.TEXT_PRIMARY);
        monthText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        monthText.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        monthPill.addView(monthText);

        monthPill.setOnClickListener(v -> Toast.makeText(context, "Billing Cycle: November 2024 (Active)", Toast.LENGTH_SHORT).show());
        row.addView(monthPill);

        return row;
    }

    private View createBalanceHeroCard(Context context) {
        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(ViewFactory.dp(context, 18), ViewFactory.dp(context, 18), ViewFactory.dp(context, 18), ViewFactory.dp(context, 18));
        card.setElevation(ViewFactory.dp(context, 6));

        // Deep Trust Blue Gradient
        GradientDrawable gradient = new GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{ThemeColors.PRIMARY_CONTAINER, ThemeColors.NAVY_PRIMARY}
        );
        gradient.setCornerRadius(ViewFactory.dp(context, 16));
        card.setBackground(gradient);

        // Top Row: Label, Active badge, Eye Toggle
        LinearLayout topRow = new LinearLayout(context);
        topRow.setOrientation(LinearLayout.HORIZONTAL);
        topRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView label = new TextView(context);
        label.setText("TOTAL AVAILABLE BALANCE");
        label.setTextColor(Color.parseColor("#DCE1FF"));
        label.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        label.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams lParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        label.setLayoutParams(lParams);
        topRow.addView(label);

        TextView activeBadge = ViewFactory.createPillBadge(context, "Active", Color.parseColor("#33FFFFFF"), Color.WHITE, 10);
        topRow.addView(activeBadge);

        eyeToggleBtn = new TextView(context);
        eyeToggleBtn.setText(" 👁️");
        eyeToggleBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f);
        eyeToggleBtn.setPadding(ViewFactory.dp(context, 8), 0, 0, 0);
        eyeToggleBtn.setOnClickListener(v -> toggleBalanceVisibility());
        topRow.addView(eyeToggleBtn);

        card.addView(topRow);

        // Balance Big Metric
        balanceTextView = new TextView(context);
        balanceTextView.setText("RM 3,420.50");
        balanceTextView.setTextColor(Color.WHITE);
        balanceTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 30f);
        balanceTextView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        balanceTextView.setPadding(0, ViewFactory.dp(context, 10), 0, ViewFactory.dp(context, 14));
        card.addView(balanceTextView);

        // Income vs Expenses Badges
        LinearLayout metricsRow = new LinearLayout(context);
        metricsRow.setOrientation(LinearLayout.HORIZONTAL);

        // Income Pill
        LinearLayout incPill = new LinearLayout(context);
        incPill.setOrientation(LinearLayout.HORIZONTAL);
        incPill.setGravity(Gravity.CENTER_VERTICAL);
        incPill.setBackground(ViewFactory.createRoundedDrawable(Color.parseColor("#26FFFFFF"), ViewFactory.dp(context, 10), 0, 0));
        incPill.setPadding(ViewFactory.dp(context, 10), ViewFactory.dp(context, 8), ViewFactory.dp(context, 10), ViewFactory.dp(context, 8));
        LinearLayout.LayoutParams incParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        incParams.setMargins(0, 0, ViewFactory.dp(context, 6), 0);
        incPill.setLayoutParams(incParams);

        TextView incIcon = new TextView(context);
        incIcon.setText("↗");
        incIcon.setTextColor(ThemeColors.SECONDARY);
        incIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        incIcon.setGravity(Gravity.CENTER);
        int iSize = ViewFactory.dp(context, 26);
        incIcon.setLayoutParams(new LinearLayout.LayoutParams(iSize, iSize));
        incIcon.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.MINT_SUBTLE, ViewFactory.dp(context, 999), 0, 0));
        incPill.addView(incIcon);

        LinearLayout incText = new LinearLayout(context);
        incText.setOrientation(LinearLayout.VERTICAL);
        incText.setPadding(ViewFactory.dp(context, 8), 0, 0, 0);

        TextView incLbl = new TextView(context);
        incLbl.setText("Income");
        incLbl.setTextColor(Color.parseColor("#B6C4FF"));
        incLbl.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        incText.addView(incLbl);

        incomeTextView = new TextView(context);
        incomeTextView.setText("+RM 2,800.00");
        incomeTextView.setTextColor(Color.WHITE);
        incomeTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        incomeTextView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        incText.addView(incomeTextView);
        incPill.addView(incText);

        metricsRow.addView(incPill);

        // Expense Pill
        LinearLayout expPill = new LinearLayout(context);
        expPill.setOrientation(LinearLayout.HORIZONTAL);
        expPill.setGravity(Gravity.CENTER_VERTICAL);
        expPill.setBackground(ViewFactory.createRoundedDrawable(Color.parseColor("#26FFFFFF"), ViewFactory.dp(context, 10), 0, 0));
        expPill.setPadding(ViewFactory.dp(context, 10), ViewFactory.dp(context, 8), ViewFactory.dp(context, 10), ViewFactory.dp(context, 8));
        LinearLayout.LayoutParams expParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        expParams.setMargins(ViewFactory.dp(context, 6), 0, 0, 0);
        expPill.setLayoutParams(expParams);

        TextView expIcon = new TextView(context);
        expIcon.setText("↘");
        expIcon.setTextColor(ThemeColors.ALERT_CORAL);
        expIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        expIcon.setGravity(Gravity.CENTER);
        expIcon.setLayoutParams(new LinearLayout.LayoutParams(iSize, iSize));
        expIcon.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.ALERT_CORAL_SUBTLE, ViewFactory.dp(context, 999), 0, 0));
        expPill.addView(expIcon);

        LinearLayout expText = new LinearLayout(context);
        expText.setOrientation(LinearLayout.VERTICAL);
        expText.setPadding(ViewFactory.dp(context, 8), 0, 0, 0);

        TextView expLbl = new TextView(context);
        expLbl.setText("Expenses");
        expLbl.setTextColor(Color.parseColor("#B6C4FF"));
        expLbl.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        expText.addView(expLbl);

        expenseTextView = new TextView(context);
        expenseTextView.setText("-RM 1,485.20");
        expenseTextView.setTextColor(Color.WHITE);
        expenseTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        expenseTextView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        expText.addView(expenseTextView);
        expPill.addView(expText);

        metricsRow.addView(expPill);

        card.addView(metricsRow);
        return card;
    }

    private LinearLayout createSmartSpendAlertWidget(Context context) {
        LinearLayout widget = new LinearLayout(context);
        widget.setOrientation(LinearLayout.HORIZONTAL);
        widget.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.MINT_SUBTLE, ViewFactory.dp(context, 14), 0, 0));
        widget.setPadding(ViewFactory.dp(context, 14), ViewFactory.dp(context, 12), ViewFactory.dp(context, 14), ViewFactory.dp(context, 12));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, ViewFactory.dp(context, 16), 0, 0);
        widget.setLayoutParams(params);

        // Lightbulb circle
        TextView bulb = new TextView(context);
        bulb.setText("💡");
        bulb.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        bulb.setGravity(Gravity.CENTER);
        int bSize = ViewFactory.dp(context, 36);
        bulb.setLayoutParams(new LinearLayout.LayoutParams(bSize, bSize));
        bulb.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 999), 0, 0));
        widget.addView(bulb);

        LinearLayout body = new LinearLayout(context);
        body.setOrientation(LinearLayout.VERTICAL);
        body.setPadding(ViewFactory.dp(context, 10), 0, 0, 0);
        LinearLayout.LayoutParams bParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        body.setLayoutParams(bParams);

        LinearLayout topInfo = new LinearLayout(context);
        topInfo.setOrientation(LinearLayout.HORIZONTAL);
        topInfo.setGravity(Gravity.CENTER_VERTICAL);

        TextView tag = new TextView(context);
        tag.setText("SMART SPEND ALERT");
        tag.setTextColor(ThemeColors.SECONDARY);
        tag.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        tag.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        tag.setLayoutParams(tParams);
        topInfo.addView(tag);

        TextView timeLbl = new TextView(context);
        timeLbl.setText("Just now");
        timeLbl.setTextColor(ThemeColors.SECONDARY);
        timeLbl.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        topInfo.addView(timeLbl);
        body.addView(topInfo);

        TextView msg = new TextView(context);
        msg.setText("You've spent 20% less on food this week at UTM Arked. Great job! Move RM50 to your Emergency Fund?");
        msg.setTextColor(ThemeColors.TEXT_PRIMARY);
        msg.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        msg.setPadding(0, ViewFactory.dp(context, 4), 0, ViewFactory.dp(context, 8));
        body.addView(msg);

        // Action Buttons Row
        LinearLayout btnRow = new LinearLayout(context);
        btnRow.setOrientation(LinearLayout.HORIZONTAL);

        transferQuickBtn = ViewFactory.createPrimaryButton(context, "Transfer RM50 →", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        transferQuickBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        transferQuickBtn.setMinHeight(ViewFactory.dp(context, 36));
        transferQuickBtn.setOnClickListener(v -> executeQuickTransfer());
        btnRow.addView(transferQuickBtn);

        TextView dismissBtn = new TextView(context);
        dismissBtn.setText("Dismiss");
        dismissBtn.setTextColor(ThemeColors.TEXT_MUTED);
        dismissBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        dismissBtn.setPadding(ViewFactory.dp(context, 14), ViewFactory.dp(context, 8), ViewFactory.dp(context, 14), ViewFactory.dp(context, 8));
        dismissBtn.setOnClickListener(v -> {
            widget.setVisibility(View.GONE);
            Toast.makeText(context, "Insight dismissed.", Toast.LENGTH_SHORT).show();
        });
        btnRow.addView(dismissBtn);

        body.addView(btnRow);
        widget.addView(body);

        return widget;
    }

    private View createRecentTransactionsSection(Context context) {
        LinearLayout section = new LinearLayout(context);
        section.setOrientation(LinearLayout.VERTICAL);
        section.setPadding(0, ViewFactory.dp(context, 20), 0, 0);

        // Title Row
        LinearLayout row = new LinearLayout(context);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, 0, 0, ViewFactory.dp(context, 8));

        TextView title = new TextView(context);
        title.setText("Recent Transactions");
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        title.setLayoutParams(tParams);
        row.addView(title);

        TextView count = new TextView(context);
        count.setText("Showing latest 4");
        count.setTextColor(ThemeColors.TEXT_MUTED);
        count.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        row.addView(count);

        section.addView(row);

        // RecyclerView Card Container
        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 14), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(context, 1)));

        transactionsRecycler = new RecyclerView(context);
        transactionsRecycler.setLayoutManager(new LinearLayoutManager(context));
        transactionsRecycler.setNestedScrollingEnabled(false);

        transactionAdapter = new TransactionAdapter();
        transactionAdapter.setOnTransactionClickListener(t -> {
            String details = t.getTransactionName() + "\nCategory: " + t.getCategory() 
                    + "\nAmount: RM " + String.format(Locale.getDefault(), "%.2f", t.getAmount())
                    + "\nMethod: " + t.getPaymentMethod();
            new AlertDialog.Builder(context)
                    .setTitle("Transaction Details")
                    .setMessage(details)
                    .setPositiveButton("Close", null)
                    .show();
        });
        transactionsRecycler.setAdapter(transactionAdapter);
        card.addView(transactionsRecycler);

        section.addView(card);

        // View All Transactions Button
        Button viewAllBtn = ViewFactory.createSecondaryButton(context, "View All Transactions →", ThemeColors.SURFACE_LOW, ThemeColors.PRIMARY_CONTAINER, 0);
        LinearLayout.LayoutParams vParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        vParams.setMargins(0, ViewFactory.dp(context, 8), 0, 0);
        viewAllBtn.setLayoutParams(vParams);
        viewAllBtn.setOnClickListener(v -> {
            if (navListener != null) {
                navListener.navigateToTab(BottomNavBarView.TAB_BUDGETS);
            }
        });
        section.addView(viewAllBtn);

        return section;
    }

    private void toggleBalanceVisibility() {
        isBalanceHidden = !isBalanceHidden;
        if (isBalanceHidden) {
            balanceTextView.setText("••••••••");
            eyeToggleBtn.setText(" 🙈");
        } else {
            balanceTextView.setText(String.format(Locale.getDefault(), "RM %,.2f", currentBalance));
            eyeToggleBtn.setText(" 👁️");
        }
    }

    private void executeQuickTransfer() {
        transferQuickBtn.setEnabled(false);
        transferQuickBtn.setText("Transferring...");

        String token = sessionManager.getToken();
        DashboardService.quickTransferSavings(token, 50.00, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                if (response.isSuccess()) {
                    currentBalance -= 50.00;
                    if (!isBalanceHidden) {
                        balanceTextView.setText(String.format(Locale.getDefault(), "RM %,.2f", currentBalance));
                    }
                    transferQuickBtn.setText("✓ Transferred RM 50.00");
                    Toast.makeText(requireContext(), "Demonstration: RM50 moved to Emergency Fund!", Toast.LENGTH_LONG).show();
                    aiInsightWidget.postDelayed(() -> {
                        if (aiInsightWidget != null) aiInsightWidget.setVisibility(View.GONE);
                    }, 2000);
                } else {
                    transferQuickBtn.setEnabled(true);
                    transferQuickBtn.setText("Transfer RM50 →");
                    Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onError(String errorMessage) {
                // In demo offline fallback mode, still perform state update gracefully
                currentBalance -= 50.00;
                if (!isBalanceHidden) {
                    balanceTextView.setText(String.format(Locale.getDefault(), "RM %,.2f", currentBalance));
                }
                transferQuickBtn.setText("✓ Transferred (Demo)");
                Toast.makeText(requireContext(), "RM 50.00 demonstration transfer recorded.", Toast.LENGTH_SHORT).show();
                aiInsightWidget.postDelayed(() -> {
                    if (aiInsightWidget != null) aiInsightWidget.setVisibility(View.GONE);
                }, 2000);
            }
        });
    }

    private void loadDashboardData() {
        swipeRefresh.setRefreshing(true);
        String token = sessionManager.getToken();

        DashboardService.fetchDashboard(token, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                swipeRefresh.setRefreshing(false);
                if (response.isSuccess()) {
                    DashboardData data = DashboardData.fromJson(response.getData());
                    populateDashboard(data);
                } else {
                    loadFallbackDemoData();
                }
            }

            @Override
            public void onError(String errorMessage) {
                swipeRefresh.setRefreshing(false);
                loadFallbackDemoData();
            }
        });
    }

    private void populateDashboard(DashboardData data) {
        currentBalance = data.getTotalBalance();
        if (!isBalanceHidden) {
            balanceTextView.setText(String.format(Locale.getDefault(), "RM %,.2f", currentBalance));
        }
        incomeTextView.setText(String.format(Locale.getDefault(), "+RM %,.2f", data.getTotalIncome()));
        expenseTextView.setText(String.format(Locale.getDefault(), "-RM %,.2f", data.getTotalExpense()));

        if (data.getTrendDays() != null && !data.getTrendDays().isEmpty()) {
            outflowTrendView.setDays(data.getTrendDays());
        }

        if (data.getTransactions() != null && !data.getTransactions().isEmpty()) {
            transactionAdapter.setTransactions(data.getTransactions());
        }
    }

    private void loadFallbackDemoData() {
        // Loads canonical sample data matching the screenshot
        currentBalance = 3420.50;
        if (!isBalanceHidden) {
            balanceTextView.setText("RM 3,420.50");
        }
        incomeTextView.setText("+RM 2,800.00");
        expenseTextView.setText("-RM 1,485.20");

        java.util.List<Transaction> defaultList = new java.util.ArrayList<>();
        defaultList.add(new Transaction(1, "UTM Arked Cengal - Lunch", "Food & Dining", 8.50, "expense", "Today, 1:15 PM", "Debit Card", "Savings target met"));
        defaultList.add(new Transaction(2, "Monthly Allowance", "Family Transfer", 800.00, "income", "Yesterday", "Bank Direct", "Family Transfer"));
        defaultList.add(new Transaction(3, "Campus Bookstore - Stationery", "Education", 34.00, "expense", "12 Nov", "Debit Card", "Debit Card"));
        defaultList.add(new Transaction(4, "Grab Ride to Senai", "Transport", 22.00, "expense", "10 Nov", "GrabPay", "GrabPay"));
        transactionAdapter.setTransactions(defaultList);
    }

    private void showAiCopilotDialog() {
        new AlertDialog.Builder(requireContext())
                .setTitle("FinWise AI Copilot")
                .setMessage("FinWise AI Copilot (Sprint 3)\n\n• Voice Transaction Logging: Speak 'Lunch RM8.50 at Arked Cengal'\n• Campus Receipt OCR: Scan your receipt to auto-extract items and tax\n• Spending Anomaly Detection: Get real-time alerts before overspending\n\nFull AI API model integration scheduled for Sprint 3.")
                .setPositiveButton("Awesome", null)
                .show();
    }
}

