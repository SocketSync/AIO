package com.finwise.app.ui;

import android.content.Context;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * 5-Item Bottom Navigation Bar Component
 * Pure programmatic Java implementation matching the FinWise navigation bar.
 */
public class BottomNavBarView extends FrameLayout {

    public interface OnTabSelectedListener {
        void onTabSelected(int index);
    }

    public static final int TAB_HOME = 0;
    public static final int TAB_BUDGETS = 1;
    public static final int TAB_ADD = 2;
    public static final int TAB_INSIGHTS = 3;
    public static final int TAB_SIMULATOR = 4;

    private int selectedTab = TAB_HOME;
    private OnTabSelectedListener listener;

    private final TextView[] iconViews = new TextView[5];
    private final TextView[] labelViews = new TextView[5];

    public BottomNavBarView(Context context) {
        super(context);
        init();
    }

    public void setOnTabSelectedListener(OnTabSelectedListener listener) {
        this.listener = listener;
    }

    private void init() {
        int navHeight = ViewFactory.dp(getContext(), 64);
        setBackgroundColor(ThemeColors.SURFACE_WHITE);
        setElevation(ViewFactory.dp(getContext(), 8));

        // Horizontal bar
        LinearLayout bar = new LinearLayout(getContext());
        bar.setOrientation(LinearLayout.HORIZONTAL);
        bar.setGravity(Gravity.CENTER_VERTICAL);
        LayoutParams barParams = new LayoutParams(LayoutParams.MATCH_PARENT, navHeight);
        bar.setLayoutParams(barParams);

        // 1. Home
        bar.addView(createStandardTab("🏠", "Home", TAB_HOME));

        // 2. Budgets
        bar.addView(createStandardTab("👛", "Budgets", TAB_BUDGETS));

        // 3. Add Transaction (Prominent Center Button)
        bar.addView(createCenterAddButton());

        // 4. Insights
        bar.addView(createStandardTab("✨", "Insights", TAB_INSIGHTS));

        // 5. Simulator
        bar.addView(createStandardTab("📈", "Simulator", TAB_SIMULATOR));

        addView(bar);
        updateTabStyles();
    }

    private View createStandardTab(String iconText, String labelText, int tabIndex) {
        LinearLayout tab = new LinearLayout(getContext());
        tab.setOrientation(LinearLayout.VERTICAL);
        tab.setGravity(Gravity.CENTER);
        tab.setPadding(0, ViewFactory.dp(getContext(), 4), 0, ViewFactory.dp(getContext(), 4));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(0, LayoutParams.MATCH_PARENT, 1f);
        tab.setLayoutParams(params);

        TextView icon = new TextView(getContext());
        icon.setText(iconText);
        icon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        icon.setGravity(Gravity.CENTER);
        tab.addView(icon);
        iconViews[tabIndex] = icon;

        TextView label = new TextView(getContext());
        label.setText(labelText);
        label.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        label.setGravity(Gravity.CENTER);
        label.setPadding(0, ViewFactory.dp(getContext(), 2), 0, 0);
        tab.addView(label);
        labelViews[tabIndex] = label;

        tab.setOnClickListener(v -> selectTab(tabIndex));
        return tab;
    }

    private View createCenterAddButton() {
        FrameLayout container = new FrameLayout(getContext());
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(0, LayoutParams.MATCH_PARENT, 1f);
        container.setLayoutParams(params);

        int btnSize = ViewFactory.dp(getContext(), 48);
        TextView addBtn = new TextView(getContext());
        addBtn.setText("+");
        addBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 26f);
        addBtn.setTextColor(ThemeColors.ON_PRIMARY);
        addBtn.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        addBtn.setGravity(Gravity.CENTER);
        addBtn.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.PRIMARY_CONTAINER, ViewFactory.dp(getContext(), 999), 0, 0));
        addBtn.setElevation(ViewFactory.dp(getContext(), 4));

        LayoutParams btnParams = new LayoutParams(btnSize, btnSize);
        btnParams.gravity = Gravity.CENTER;
        addBtn.setLayoutParams(btnParams);

        addBtn.setOnClickListener(v -> {
            if (listener != null) {
                listener.onTabSelected(TAB_ADD);
            }
        });

        container.addView(addBtn);
        return container;
    }

    public void selectTab(int index) {
        if (index == TAB_ADD) {
            if (listener != null) listener.onTabSelected(TAB_ADD);
            return;
        }
        this.selectedTab = index;
        updateTabStyles();
        if (listener != null) {
            listener.onTabSelected(index);
        }
    }

    private void updateTabStyles() {
        for (int i = 0; i < 5; i++) {
            if (i == TAB_ADD) continue;
            boolean isSelected = (i == selectedTab);
            if (labelViews[i] != null) {
                labelViews[i].setTextColor(isSelected ? ThemeColors.NAVY_PRIMARY : ThemeColors.TEXT_MUTED);
                labelViews[i].setTypeface(Typeface.create("sans-serif-medium", isSelected ? Typeface.BOLD : Typeface.NORMAL));
            }
        }
    }
}

