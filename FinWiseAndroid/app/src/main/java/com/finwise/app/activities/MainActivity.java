package com.finwise.app.activities;

import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.finwise.app.fragments.AddTransactionDialogFragment;
import com.finwise.app.fragments.BudgetFragment;
import com.finwise.app.fragments.HomeFragment;
import com.finwise.app.fragments.InsightsFragment;
import com.finwise.app.fragments.SimulatorFragment;
import com.finwise.app.models.ApiResponse;
import com.finwise.app.models.User;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.AuthService;
import com.finwise.app.ui.BottomNavBarView;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

/**
 * Screen 4 Host Activity: Main Dashboard Activity
 * Programmatically manages Top Bar, Fragment Transitions, and Bottom Navigation.
 */
public class MainActivity extends AppCompatActivity implements HomeFragment.DashboardNavigationListener {

    private static final int CONTAINER_ID = 0x7F0A0001;

    private SessionManager sessionManager;
    private BottomNavBarView bottomNavBar;
    private int currentTab = BottomNavBarView.TAB_HOME;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        sessionManager = new SessionManager(this);
        if (!sessionManager.isLoggedIn()) {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        buildProgrammaticUi();

        if (savedInstanceState == null) {
            switchFragment(HomeFragment.newInstance(), false);
        }
    }

    private void buildProgrammaticUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);

        // 1. Fixed Header (Matching Dashboard Reference: Logo, Notifications, Profile)
        root.addView(createTopDashboardHeader());

        // 2. Relative/Frame Container for Fragment and Bottom Nav
        FrameLayout mainArea = new FrameLayout(this);
        LinearLayout.LayoutParams mainAreaParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
        );
        mainArea.setLayoutParams(mainAreaParams);

        // Fragment Container
        FrameLayout fragmentContainer = new FrameLayout(this);
        fragmentContainer.setId(CONTAINER_ID);
        fragmentContainer.setLayoutParams(new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
        ));
        mainArea.addView(fragmentContainer);

        // 3. Fixed Bottom Navigation Bar
        bottomNavBar = new BottomNavBarView(this);
        FrameLayout.LayoutParams navParams = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        );
        navParams.gravity = Gravity.BOTTOM;
        bottomNavBar.setLayoutParams(navParams);

        bottomNavBar.setOnTabSelectedListener(this::handleTabSelection);
        mainArea.addView(bottomNavBar);

        root.addView(mainArea);
        setContentView(root);
    }

    private View createTopDashboardHeader() {
        LinearLayout header = new LinearLayout(this);
        header.setOrientation(LinearLayout.HORIZONTAL);
        header.setGravity(Gravity.CENTER_VERTICAL);
        header.setPadding(ViewFactory.dp(this, 16), ViewFactory.dp(this, 10), ViewFactory.dp(this, 16), ViewFactory.dp(this, 10));
        header.setBackgroundColor(ThemeColors.SURFACE_WHITE);
        header.setElevation(ViewFactory.dp(this, 2));

        // Brand Logo + FinWise Name
        LinearLayout brandBox = new LinearLayout(this);
        brandBox.setOrientation(LinearLayout.HORIZONTAL);
        brandBox.setGravity(Gravity.CENTER_VERTICAL);

        TextView logoIcon = new TextView(this);
        logoIcon.setText("FinWise");
        logoIcon.setTextColor(ThemeColors.NAVY_PRIMARY);
        logoIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 19f);
        logoIcon.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        brandBox.addView(logoIcon);

        TextView campusPill = ViewFactory.createPillBadge(this, "UTM", ThemeColors.MINT_SUBTLE, ThemeColors.SECONDARY, 9);
        LinearLayout.LayoutParams cParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        cParams.setMargins(ViewFactory.dp(this, 6), 0, 0, 0);
        campusPill.setLayoutParams(cParams);
        brandBox.addView(campusPill);

        LinearLayout.LayoutParams brandParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        brandBox.setLayoutParams(brandParams);
        header.addView(brandBox);

        // Notifications Button
        TextView notifBtn = new TextView(this);
        notifBtn.setText("🔔");
        notifBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        notifBtn.setPadding(ViewFactory.dp(this, 8), ViewFactory.dp(this, 4), ViewFactory.dp(this, 12), ViewFactory.dp(this, 4));
        notifBtn.setOnClickListener(v -> showNotificationsDialog());
        header.addView(notifBtn);

        // User Avatar Circle
        TextView avatar = new TextView(this);
        avatar.setText("👤");
        avatar.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f);
        avatar.setTextColor(ThemeColors.ON_PRIMARY);
        avatar.setGravity(Gravity.CENTER);
        int aSize = ViewFactory.dp(this, 34);
        avatar.setLayoutParams(new LinearLayout.LayoutParams(aSize, aSize));
        avatar.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.NAVY_PRIMARY, ViewFactory.dp(this, 999), 0, 0));
        avatar.setOnClickListener(v -> showUserProfileDialog());
        header.addView(avatar);

        return header;
    }

    private void handleTabSelection(int index) {
        if (index == BottomNavBarView.TAB_ADD) {
            // Open Add Transaction Modal
            AddTransactionDialogFragment dialog = AddTransactionDialogFragment.newInstance();
            dialog.setOnTransactionAddedListener(() -> {
                // If on home, refresh
                if (currentTab == BottomNavBarView.TAB_HOME) {
                    switchFragment(HomeFragment.newInstance(), false);
                }
            });
            dialog.show(getSupportFragmentManager(), "AddTransactionDialog");
            return;
        }

        if (index == currentTab) return;
        currentTab = index;

        switch (index) {
            case BottomNavBarView.TAB_HOME:
                switchFragment(HomeFragment.newInstance(), false);
                break;
            case BottomNavBarView.TAB_BUDGETS:
                switchFragment(BudgetFragment.newInstance(), false);
                break;
            case BottomNavBarView.TAB_INSIGHTS:
                switchFragment(InsightsFragment.newInstance(), false);
                break;
            case BottomNavBarView.TAB_SIMULATOR:
                switchFragment(SimulatorFragment.newInstance(), false);
                break;
        }
    }

    private void switchFragment(Fragment fragment, boolean addToBackStack) {
        FragmentManager fm = getSupportFragmentManager();
        var tx = fm.beginTransaction();
        tx.replace(CONTAINER_ID, fragment);
        if (addToBackStack) {
            tx.addToBackStack(null);
        }
        tx.commit();
    }

    @Override
    public void navigateToTab(int tabIndex) {
        if (bottomNavBar != null) {
            bottomNavBar.selectTab(tabIndex);
        }
    }

    private void showNotificationsDialog() {
        new AlertDialog.Builder(this)
                .setTitle("Campus Notifications")
                .setItems(new CharSequence[]{
                        "🎉 Sem 2 Allowance Sync completed from UTM Portal.",
                        "💡 Smart Spend Alert: 20% savings on food this week.",
                        "⚠️ Weekend peak warning: Grab expenses increased on Saturday.",
                        "🛡️ 256-bit AES encryption active on student device."
                }, null)
                .setPositiveButton("Dismiss All", null)
                .show();
    }

    private void showUserProfileDialog() {
        User user = sessionManager.getUser();
        String name = user != null ? user.getFullName() : "Yeoh Keng Wei";
        String email = user != null ? user.getEmail() : "yeoh.k@graduate.utm.my";
        String matric = user != null ? user.getMatricId() : "A23CS0123";

        new AlertDialog.Builder(this)
                .setTitle("Student Profile")
                .setMessage("Name: " + name + "\nEmail: " + email + "\nMatric ID: " + (matric != null && !matric.isEmpty() ? matric : "N/A") + "\nCampus: Universiti Teknologi Malaysia (UTM)\nVerification: Verified Student Account ✓")
                .setPositiveButton("Close", null)
                .setNegativeButton("Log Out", (dialog, which) -> handleLogout())
                .show();
    }

    private void handleLogout() {
        String token = sessionManager.getToken();
        AuthService.logout(token, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {}
            @Override
            public void onError(String errorMessage) {}
        });

        sessionManager.clearSession();
        Toast.makeText(this, "Logged out successfully.", Toast.LENGTH_SHORT).show();

        Intent intent = new Intent(this, LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    @Override
    public void onBackPressed() {
        if (currentTab != BottomNavBarView.TAB_HOME) {
            bottomNavBar.selectTab(BottomNavBarView.TAB_HOME);
        } else {
            super.onBackPressed();
        }
    }
}

