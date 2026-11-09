package com.finwise.app.ui;

import android.content.Context;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

/** FinWise five-item personal expense tracker navigation. */
public class BottomNavBarView extends FrameLayout {
    public interface OnTabSelectedListener { void onTabSelected(int index); }

    public static final int TAB_HOME = 0;
    public static final int TAB_TRANSACTIONS = 1;
    public static final int TAB_ADD = 2;
    public static final int TAB_SUMMARY = 3;
    public static final int TAB_PROFILE = 4;

    private int selectedTab = TAB_HOME;
    private OnTabSelectedListener listener;
    private final TextView[] labels = new TextView[5];

    public BottomNavBarView(Context context) {
        super(context);
        setBackgroundColor(ThemeColors.SURFACE_WHITE);
        setElevation(ViewFactory.dp(context, 8));

        LinearLayout bar = new LinearLayout(context);
        bar.setGravity(Gravity.CENTER_VERTICAL);
        bar.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, ViewFactory.dp(context, 64)));
        bar.addView(createTab("⌂", "Home", TAB_HOME));
        bar.addView(createTab("≡", "Transactions", TAB_TRANSACTIONS));
        bar.addView(createAddTab());
        bar.addView(createTab("▥", "Summary", TAB_SUMMARY));
        bar.addView(createTab("●", "Profile", TAB_PROFILE));
        addView(bar);
        updateStyles();
    }

    public void setOnTabSelectedListener(OnTabSelectedListener listener) { this.listener = listener; }

    private View createTab(String iconText, String labelText, int index) {
        LinearLayout tab = new LinearLayout(getContext());
        tab.setOrientation(LinearLayout.VERTICAL);
        tab.setGravity(Gravity.CENTER);
        tab.setLayoutParams(new LinearLayout.LayoutParams(0, LayoutParams.MATCH_PARENT, 1f));
        TextView icon = new TextView(getContext());
        icon.setText(iconText);
        icon.setGravity(Gravity.CENTER);
        icon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        tab.addView(icon);
        TextView label = new TextView(getContext());
        label.setText(labelText);
        label.setGravity(Gravity.CENTER);
        label.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        tab.addView(label);
        labels[index] = label;
        tab.setOnClickListener(v -> selectTab(index));
        return tab;
    }

    private View createAddTab() {
        FrameLayout container = new FrameLayout(getContext());
        container.setLayoutParams(new LinearLayout.LayoutParams(0, LayoutParams.MATCH_PARENT, 1f));
        TextView add = new TextView(getContext());
        add.setText("+");
        add.setTextColor(ThemeColors.ON_PRIMARY);
        add.setTextSize(TypedValue.COMPLEX_UNIT_SP, 26f);
        add.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        add.setGravity(Gravity.CENTER);
        int size = ViewFactory.dp(getContext(), 48);
        LayoutParams addParams = new LayoutParams(size, size);
        addParams.gravity = Gravity.CENTER;
        add.setLayoutParams(addParams);
        add.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.PRIMARY_CONTAINER, ViewFactory.dp(getContext(), 999), 0, 0));
        add.setOnClickListener(v -> selectTab(TAB_ADD));
        container.addView(add);
        return container;
    }

    public void selectTab(int index) {
        if (index != TAB_ADD) {
            selectedTab = index;
            updateStyles();
        }
        if (listener != null) listener.onTabSelected(index);
    }

    private void updateStyles() {
        for (int i = 0; i < labels.length; i++) {
            if (labels[i] != null) {
                labels[i].setTextColor(i == selectedTab ? ThemeColors.NAVY_PRIMARY : ThemeColors.TEXT_MUTED);
                labels[i].setTypeface(Typeface.DEFAULT, i == selectedTab ? Typeface.BOLD : Typeface.NORMAL);
            }
        }
    }
}
