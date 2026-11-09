package com.finwise.app.ui;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.RippleDrawable;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.cardview.widget.CardView;

/**
 * Programmatic View Factory
 * Assembles modern, responsive Material-style Android widgets entirely in Java.
 */
public final class ViewFactory {
    private ViewFactory() {}

    public static int dp(Context context, int dp) {
        return (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                dp,
                context.getResources().getDisplayMetrics()
        );
    }

    public static float sp(Context context, float sp) {
        return sp;
    }

    /**
     * Create rounded background drawable
     */
    public static GradientDrawable createRoundedDrawable(int bgColor, int cornerRadiusPx, int strokeColor, int strokeWidthPx) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setColor(bgColor);
        drawable.setCornerRadius(cornerRadiusPx);
        if (strokeWidthPx > 0 && strokeColor != 0) {
            drawable.setStroke(strokeWidthPx, strokeColor);
        }
        return drawable;
    }

    /**
     * Create card container with rounded corners and elevation
     */
    public static CardView createCard(Context context, int cornerRadiusDp, int elevationDp, int bgColor) {
        CardView card = new CardView(context);
        card.setRadius(dp(context, cornerRadiusDp));
        card.setCardElevation(dp(context, elevationDp));
        card.setMaxCardElevation(dp(context, elevationDp + 2));
        card.setCardBackgroundColor(bgColor);
        card.setUseCompatPadding(true);
        card.setPreventCornerOverlap(true);
        return card;
    }

    /**
     * Create pill badge
     */
    public static TextView createPillBadge(Context context, String text, int bgColor, int textColor, int textSizeSp) {
        TextView badge = new TextView(context);
        badge.setText(text);
        badge.setTextColor(textColor);
        badge.setTextSize(TypedValue.COMPLEX_UNIT_SP, textSizeSp);
        badge.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        badge.setGravity(Gravity.CENTER);
        int padH = dp(context, 8);
        int padV = dp(context, 3);
        badge.setPadding(padH, padV, padH, padV);
        badge.setBackground(createRoundedDrawable(bgColor, dp(context, 999), 0, 0));
        return badge;
    }

    /**
     * Create primary rounded button
     */
    public static Button createPrimaryButton(Context context, String text, int bgColor, int textColor) {
        Button button = new Button(context);
        button.setText(text);
        button.setTextColor(textColor);
        button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f);
        button.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        button.setAllCaps(false);
        int height = dp(context, 48);
        button.setMinHeight(height);

        GradientDrawable bg = createRoundedDrawable(bgColor, dp(context, 10), 0, 0);
        GradientDrawable rippleMask = createRoundedDrawable(0xFFFFFFFF, dp(context, 10), 0, 0);
        ColorStateList rippleColors = ColorStateList.valueOf(0x33FFFFFF);
        RippleDrawable ripple = new RippleDrawable(rippleColors, bg, rippleMask);

        button.setBackground(ripple);
        button.setElevation(dp(context, 2));
        return button;
    }

    /**
     * Create secondary rounded button (light surface or outline)
     */
    public static Button createSecondaryButton(Context context, String text, int bgColor, int textColor, int strokeColor) {
        Button button = new Button(context);
        button.setText(text);
        button.setTextColor(textColor);
        button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        button.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        button.setAllCaps(false);
        int height = dp(context, 44);
        button.setMinHeight(height);

        GradientDrawable bg = createRoundedDrawable(bgColor, dp(context, 8), strokeColor, strokeColor != 0 ? dp(context, 1) : 0);
        GradientDrawable rippleMask = createRoundedDrawable(0xFFFFFFFF, dp(context, 8), 0, 0);
        ColorStateList rippleColors = ColorStateList.valueOf(0x22000000);
        RippleDrawable ripple = new RippleDrawable(rippleColors, bg, rippleMask);

        button.setBackground(ripple);
        button.setElevation(0);
        return button;
    }

    /**
     * Create programmatic form input container with icon and hint
     */
    public static LinearLayout createInputContainer(Context context, String label, String iconSymbol, EditText editText) {
        LinearLayout container = new LinearLayout(context);
        container.setOrientation(LinearLayout.VERTICAL);

        // Label row
        if (label != null && !label.isEmpty()) {
            TextView labelView = new TextView(context);
            labelView.setText(label);
            labelView.setTextColor(ThemeColors.TEXT_MUTED);
            labelView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
            labelView.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL));
            labelView.setPadding(0, 0, 0, dp(context, 6));
            container.addView(labelView);
        }

        // Input Box Frame
        LinearLayout box = new LinearLayout(context);
        box.setOrientation(LinearLayout.HORIZONTAL);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(createRoundedDrawable(ThemeColors.SURFACE_WHITE, dp(context, 10), ThemeColors.BORDER_NEUTRAL, dp(context, 1)));
        box.setPadding(dp(context, 12), dp(context, 2), dp(context, 12), dp(context, 2));

        if (iconSymbol != null && !iconSymbol.isEmpty()) {
            TextView iconView = new TextView(context);
            iconView.setText(iconSymbol);
            iconView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
            iconView.setTextColor(ThemeColors.TEXT_MUTED);
            iconView.setPadding(0, 0, dp(context, 8), 0);
            box.addView(iconView);
        }

        editText.setBackground(null);
        editText.setTextColor(ThemeColors.TEXT_PRIMARY);
        editText.setHintTextColor(ThemeColors.OUTLINE);
        editText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        LinearLayout.LayoutParams editParams = new LinearLayout.LayoutParams(0, dp(context, 48), 1f);
        editText.setLayoutParams(editParams);
        box.addView(editText);

        container.addView(box);
        return container;
    }

    /**
     * Create screen top bar header with back arrow, title, and optional action
     */
    public static LinearLayout createHeader(Context context, String title, boolean showBack, View.OnClickListener onBackClickListener) {
        LinearLayout header = new LinearLayout(context);
        header.setOrientation(LinearLayout.HORIZONTAL);
        header.setGravity(Gravity.CENTER_VERTICAL);
        header.setPadding(dp(context, 16), dp(context, 12), dp(context, 16), dp(context, 12));
        header.setBackgroundColor(ThemeColors.SURFACE_WHITE);
        header.setElevation(dp(context, 3));

        if (showBack) {
            TextView backBtn = new TextView(context);
            backBtn.setText("←");
            backBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f);
            backBtn.setTextColor(ThemeColors.TEXT_PRIMARY);
            backBtn.setPadding(dp(context, 4), dp(context, 4), dp(context, 12), dp(context, 4));
            backBtn.setClickable(true);
            backBtn.setFocusable(true);
            if (onBackClickListener != null) {
                backBtn.setOnClickListener(onBackClickListener);
            }
            header.addView(backBtn);
        }

        TextView titleView = new TextView(context);
        titleView.setText(title);
        titleView.setTextColor(ThemeColors.TEXT_PRIMARY);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        titleView.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        titleView.setLayoutParams(titleParams);
        header.addView(titleView);

        // Small Brand avatar circle
        TextView brandIcon = new TextView(context);
        brandIcon.setText("👤");
        brandIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        brandIcon.setGravity(Gravity.CENTER);
        int avatarSize = dp(context, 32);
        LinearLayout.LayoutParams avatarParams = new LinearLayout.LayoutParams(avatarSize, avatarSize);
        brandIcon.setLayoutParams(avatarParams);
        brandIcon.setBackground(createRoundedDrawable(ThemeColors.NAVY_PRIMARY, dp(context, 999), 0, 0));
        brandIcon.setTextColor(ThemeColors.ON_PRIMARY);
        header.addView(brandIcon);

        return header;
    }
}

