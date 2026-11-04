package com.finwise.app.activities;

import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.finwise.app.models.ApiResponse;
import com.finwise.app.models.User;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.AuthService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;
import com.finwise.app.utils.ValidationUtils;

import org.json.JSONObject;

/**
 * Screen 1: Login Activity
 * Completely native Java implementation matching the FinWise Login reference.
 */
public class LoginActivity extends AppCompatActivity {

    private EditText emailInput;
    private EditText passwordInput;
    private TextView togglePasswordBtn;
    private CheckBox rememberMeCheckbox;
    private Button loginButton;
    private ProgressBar progressBar;
    private boolean isPasswordVisible = false;

    private SessionManager sessionManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        sessionManager = new SessionManager(this);

        // Auto-navigate to Dashboard if already logged in and session valid
        if (sessionManager.isLoggedIn()) {
            startActivity(new Intent(this, MainActivity.class));
            finish();
            return;
        }

        buildProgrammaticUi();
    }

    private void buildProgrammaticUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);

        // 1. Fixed Top Header
        LinearLayout header = ViewFactory.createHeader(this, "Login", false, null);
        root.addView(header);

        // 2. Scrollable Body
        ScrollView scrollView = new ScrollView(this);
        scrollView.setFillViewport(true);
        LinearLayout.LayoutParams scrollParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 
                0, 1f
        );
        scrollView.setLayoutParams(scrollParams);

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        int pad = ViewFactory.dp(this, 16);
        content.setPadding(pad, pad, pad, ViewFactory.dp(this, 32));

        // Campus Context Card
        content.addView(createCampusContextCard());

        // Hero Titles
        TextView heroTitle = new TextView(this);
        heroTitle.setText("Welcome back");
        heroTitle.setTextColor(ThemeColors.TEXT_PRIMARY);
        heroTitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f);
        heroTitle.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        heroTitle.setPadding(0, ViewFactory.dp(this, 16), 0, ViewFactory.dp(this, 4));
        content.addView(heroTitle);

        TextView heroSubtitle = new TextView(this);
        heroSubtitle.setText("Take control of your campus finances and dynamic budget.");
        heroSubtitle.setTextColor(ThemeColors.TEXT_MUTED);
        heroSubtitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        heroSubtitle.setPadding(0, 0, 0, ViewFactory.dp(this, 16));
        content.addView(heroSubtitle);

        // Form Fields
        // Email/Matric Field
        emailInput = new EditText(this);
        emailInput.setHint("yeoh.k@graduate.utm.my");
        emailInput.setText(sessionManager.getSavedIdentifier());
        emailInput.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        LinearLayout emailContainer = ViewFactory.createInputContainer(this, "Student Email or Matric ID", "🪪", emailInput);
        content.addView(emailContainer);

        // Password Field with Toggle
        LinearLayout passLabelRow = new LinearLayout(this);
        passLabelRow.setOrientation(LinearLayout.HORIZONTAL);
        passLabelRow.setPadding(0, ViewFactory.dp(this, 12), 0, ViewFactory.dp(this, 6));

        TextView passLabel = new TextView(this);
        passLabel.setText("Password");
        passLabel.setTextColor(ThemeColors.TEXT_MUTED);
        passLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        passLabelRow.addView(passLabel);

        View spacer = new View(this);
        passLabelRow.addView(spacer, new LinearLayout.LayoutParams(0, 0, 1f));

        TextView forgotBtn = new TextView(this);
        forgotBtn.setText("Forgot Password?");
        forgotBtn.setTextColor(ThemeColors.NAVY_PRIMARY);
        forgotBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        forgotBtn.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        forgotBtn.setOnClickListener(v -> startActivity(new Intent(LoginActivity.this, ForgotPasswordActivity.class)));
        passLabelRow.addView(forgotBtn);

        content.addView(passLabelRow);

        // Password Input Box
        passwordInput = new EditText(this);
        passwordInput.setHint("••••••••••••");
        passwordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);

        LinearLayout passwordBox = new LinearLayout(this);
        passwordBox.setOrientation(LinearLayout.HORIZONTAL);
        passwordBox.setGravity(Gravity.CENTER_VERTICAL);
        passwordBox.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(this, 10), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(this, 1)));
        passwordBox.setPadding(ViewFactory.dp(this, 12), ViewFactory.dp(this, 2), ViewFactory.dp(this, 12), ViewFactory.dp(this, 2));

        TextView lockIcon = new TextView(this);
        lockIcon.setText("🔒");
        lockIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        lockIcon.setPadding(0, 0, ViewFactory.dp(this, 8), 0);
        passwordBox.addView(lockIcon);

        passwordInput.setBackground(null);
        passwordInput.setTextColor(ThemeColors.TEXT_PRIMARY);
        passwordInput.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        passwordBox.addView(passwordInput, new LinearLayout.LayoutParams(0, ViewFactory.dp(this, 48), 1f));

        togglePasswordBtn = new TextView(this);
        togglePasswordBtn.setText("👁️");
        togglePasswordBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        togglePasswordBtn.setPadding(ViewFactory.dp(this, 8), ViewFactory.dp(this, 8), ViewFactory.dp(this, 8), ViewFactory.dp(this, 8));
        togglePasswordBtn.setOnClickListener(v -> togglePasswordVisibility());
        passwordBox.addView(togglePasswordBtn);

        content.addView(passwordBox);

        // Remember Device & AES row
        LinearLayout optionsRow = new LinearLayout(this);
        optionsRow.setOrientation(LinearLayout.HORIZONTAL);
        optionsRow.setGravity(Gravity.CENTER_VERTICAL);
        optionsRow.setPadding(0, ViewFactory.dp(this, 10), 0, ViewFactory.dp(this, 16));

        rememberMeCheckbox = new CheckBox(this);
        rememberMeCheckbox.setText("Remember device");
        rememberMeCheckbox.setChecked(sessionManager.isRememberDevice());
        rememberMeCheckbox.setTextColor(ThemeColors.TEXT_PRIMARY);
        rememberMeCheckbox.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        optionsRow.addView(rememberMeCheckbox);

        View optionsSpacer = new View(this);
        optionsRow.addView(optionsSpacer, new LinearLayout.LayoutParams(0, 0, 1f));

        TextView aesBadge = ViewFactory.createPillBadge(this, "🛡️ 256-bit AES", ThemeColors.MINT_SUBTLE, ThemeColors.SECONDARY, 11);
        optionsRow.addView(aesBadge);

        content.addView(optionsRow);

        // Progress Bar
        progressBar = new ProgressBar(this);
        progressBar.setVisibility(View.GONE);
        content.addView(progressBar);

        // Log In Primary Action CTA
        loginButton = ViewFactory.createPrimaryButton(this, "Log In →", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        loginButton.setOnClickListener(v -> handleLogin());
        content.addView(loginButton);

        // Biometric Button
        Button biometricBtn = ViewFactory.createSecondaryButton(this, "👆 Log in with Touch ID / Face ID", ThemeColors.SURFACE_HIGH, ThemeColors.NAVY_PRIMARY, 0);
        LinearLayout.LayoutParams bioParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        bioParams.setMargins(0, ViewFactory.dp(this, 10), 0, 0);
        biometricBtn.setLayoutParams(bioParams);
        biometricBtn.setOnClickListener(v -> showBiometricsPrompt());
        content.addView(biometricBtn);

        // Divider
        content.addView(createOrDivider());

        // SSO Grid (UTM SSO & Google)
        content.addView(createSsoButtonsRow());

        // Recent Activity Banner
        content.addView(createRecentActivityCard());

        // Footer Link: Sign Up
        content.addView(createSignUpFooter());

        scrollView.addView(content);
        root.addView(scrollView);

        setContentView(root);
    }

    private View createCampusContextCard() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_LOW, ViewFactory.dp(this, 14), 0, 0));
        card.setPadding(ViewFactory.dp(this, 14), ViewFactory.dp(this, 14), ViewFactory.dp(this, 14), ViewFactory.dp(this, 14));

        LinearLayout topRow = new LinearLayout(this);
        topRow.setOrientation(LinearLayout.HORIZONTAL);
        topRow.setGravity(Gravity.CENTER_VERTICAL);

        // Wallet icon circle
        TextView walletIcon = new TextView(this);
        walletIcon.setText("👛");
        walletIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        walletIcon.setGravity(Gravity.CENTER);
        int iconSize = ViewFactory.dp(this, 38);
        walletIcon.setLayoutParams(new LinearLayout.LayoutParams(iconSize, iconSize));
        walletIcon.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.NAVY_PRIMARY, ViewFactory.dp(this, 999), 0, 0));
        topRow.addView(walletIcon);

        LinearLayout titleCol = new LinearLayout(this);
        titleCol.setOrientation(LinearLayout.VERTICAL);
        titleCol.setPadding(ViewFactory.dp(this, 10), 0, 0, 0);
        LinearLayout.LayoutParams titleColParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        titleCol.setLayoutParams(titleColParams);

        LinearLayout brandRow = new LinearLayout(this);
        brandRow.setOrientation(LinearLayout.HORIZONTAL);
        brandRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView brandText = new TextView(this);
        brandText.setText("FinWise ");
        brandText.setTextColor(ThemeColors.NAVY_PRIMARY);
        brandText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f);
        brandText.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        brandRow.addView(brandText);

        TextView campusBadge = ViewFactory.createPillBadge(this, "CAMPUS", ThemeColors.MINT_SUBTLE, ThemeColors.SECONDARY, 10);
        brandRow.addView(campusBadge);
        titleCol.addView(brandRow);

        TextView subBrand = new TextView(this);
        subBrand.setText("Student Smart Banking");
        subBrand.setTextColor(ThemeColors.TEXT_MUTED);
        subBrand.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        titleCol.addView(subBrand);

        topRow.addView(titleCol);

        TextView portalSync = ViewFactory.createPillBadge(this, "✓ UTM Portal Sync", ThemeColors.SURFACE_HIGHEST, ThemeColors.TEXT_MUTED, 10);
        topRow.addView(portalSync);

        card.addView(topRow);

        // Motivation snippet
        LinearLayout banner = new LinearLayout(this);
        banner.setOrientation(LinearLayout.HORIZONTAL);
        banner.setGravity(Gravity.CENTER_VERTICAL);
        banner.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(this, 8), 0, 0));
        banner.setPadding(ViewFactory.dp(this, 10), ViewFactory.dp(this, 8), ViewFactory.dp(this, 10), ViewFactory.dp(this, 8));
        LinearLayout.LayoutParams banParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        banParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        banner.setLayoutParams(banParams);

        TextView schoolIcon = new TextView(this);
        schoolIcon.setText("🎓 ");
        schoolIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        banner.addView(schoolIcon);

        LinearLayout bannerText = new LinearLayout(this);
        bannerText.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams bParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        bannerText.setLayoutParams(bParams);

        TextView bannerTitle = new TextView(this);
        bannerTitle.setText("SEMESTER ALLOWANCE FORECAST");
        bannerTitle.setTextColor(ThemeColors.SECONDARY);
        bannerTitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f);
        bannerTitle.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        bannerText.addView(bannerTitle);

        TextView bannerSub = new TextView(this);
        bannerSub.setText("Sem 2 budget active • UTM Skudai Campus");
        bannerSub.setTextColor(ThemeColors.TEXT_PRIMARY);
        bannerSub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        bannerText.addView(bannerSub);
        banner.addView(bannerText);

        View dot = new View(this);
        int dotSize = ViewFactory.dp(this, 8);
        LinearLayout.LayoutParams dotParams = new LinearLayout.LayoutParams(dotSize, dotSize);
        dot.setLayoutParams(dotParams);
        dot.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SECONDARY, ViewFactory.dp(this, 999), 0, 0));
        banner.addView(dot);

        card.addView(banner);
        return card;
    }

    private View createOrDivider() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, ViewFactory.dp(this, 20), 0, ViewFactory.dp(this, 16));

        View leftLine = new View(this);
        leftLine.setBackgroundColor(ThemeColors.SURFACE_HIGHEST);
        row.addView(leftLine, new LinearLayout.LayoutParams(0, ViewFactory.dp(this, 1), 1f));

        TextView text = new TextView(this);
        text.setText("  OR CONTINUE WITH  ");
        text.setTextColor(ThemeColors.TEXT_MUTED);
        text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        text.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        row.addView(text);

        View rightLine = new View(this);
        rightLine.setBackgroundColor(ThemeColors.SURFACE_HIGHEST);
        row.addView(rightLine, new LinearLayout.LayoutParams(0, ViewFactory.dp(this, 1), 1f));

        return row;
    }

    private View createSsoButtonsRow() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);

        // UTM SSO Button
        LinearLayout utmBtn = new LinearLayout(this);
        utmBtn.setOrientation(LinearLayout.VERTICAL);
        utmBtn.setGravity(Gravity.CENTER);
        utmBtn.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(this, 10), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(this, 1)));
        utmBtn.setPadding(ViewFactory.dp(this, 10), ViewFactory.dp(this, 12), ViewFactory.dp(this, 10), ViewFactory.dp(this, 12));
        LinearLayout.LayoutParams p1 = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        p1.setMargins(0, 0, ViewFactory.dp(this, 6), 0);
        utmBtn.setLayoutParams(p1);

        TextView utmIcon = new TextView(this);
        utmIcon.setText("🏛️");
        utmIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        utmBtn.addView(utmIcon);

        TextView utmLabel = new TextView(this);
        utmLabel.setText("UTM CIDOS SSO");
        utmLabel.setTextColor(ThemeColors.TEXT_PRIMARY);
        utmLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        utmLabel.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        utmBtn.addView(utmLabel);

        TextView utmSub = new TextView(this);
        utmSub.setText("Direct Student Auth");
        utmSub.setTextColor(ThemeColors.TEXT_MUTED);
        utmSub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        utmBtn.addView(utmSub);

        utmBtn.setOnClickListener(v -> showSsoNotice("UTM CIDOS Single Sign-On", 
                "Institutional SSO connects to the UTM CIDOS gateway. Please ensure OAuth credentials and university VPN proxy are registered for production deployment."));

        row.addView(utmBtn);

        // Google Button
        LinearLayout googleBtn = new LinearLayout(this);
        googleBtn.setOrientation(LinearLayout.VERTICAL);
        googleBtn.setGravity(Gravity.CENTER);
        googleBtn.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(this, 10), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(this, 1)));
        googleBtn.setPadding(ViewFactory.dp(this, 10), ViewFactory.dp(this, 12), ViewFactory.dp(this, 10), ViewFactory.dp(this, 12));
        LinearLayout.LayoutParams p2 = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        p2.setMargins(ViewFactory.dp(this, 6), 0, 0, 0);
        googleBtn.setLayoutParams(p2);

        TextView gIcon = new TextView(this);
        gIcon.setText("🌐");
        gIcon.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        googleBtn.addView(gIcon);

        TextView gLabel = new TextView(this);
        gLabel.setText("Google");
        gLabel.setTextColor(ThemeColors.TEXT_PRIMARY);
        gLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        gLabel.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        googleBtn.addView(gLabel);

        TextView gSub = new TextView(this);
        gSub.setText("Campus G-Suite");
        gSub.setTextColor(ThemeColors.TEXT_MUTED);
        gSub.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        googleBtn.addView(gSub);

        googleBtn.setOnClickListener(v -> showSsoNotice("Google Campus Account", 
                "Google G-Suite authentication requires configuring the client Google Services JSON in the UTM developer console for native OAuth exchange."));

        row.addView(googleBtn);
        return row;
    }

    private View createRecentActivityCard() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.HORIZONTAL);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_LOW, ViewFactory.dp(this, 12), 0, 0));
        card.setPadding(ViewFactory.dp(this, 12), ViewFactory.dp(this, 10), ViewFactory.dp(this, 12), ViewFactory.dp(this, 10));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, ViewFactory.dp(this, 16), 0, 0);
        card.setLayoutParams(params);

        TextView piggy = new TextView(this);
        piggy.setText("💰");
        piggy.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f);
        piggy.setGravity(Gravity.CENTER);
        int pSize = ViewFactory.dp(this, 32);
        piggy.setLayoutParams(new LinearLayout.LayoutParams(pSize, pSize));
        piggy.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.MINT_SUBTLE, ViewFactory.dp(this, 999), 0, 0));
        card.addView(piggy);

        LinearLayout textCol = new LinearLayout(this);
        textCol.setOrientation(LinearLayout.VERTICAL);
        textCol.setPadding(ViewFactory.dp(this, 10), 0, 0, 0);
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        textCol.setLayoutParams(tParams);

        TextView t1 = new TextView(this);
        t1.setText("RM 450.00 Saved this term");
        t1.setTextColor(ThemeColors.TEXT_PRIMARY);
        t1.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        t1.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        textCol.addView(t1);

        TextView t2 = new TextView(this);
        t2.setText("Top 10% saver in Kolej Tuanku Canselor");
        t2.setTextColor(ThemeColors.TEXT_MUTED);
        t2.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        textCol.addView(t2);

        card.addView(textCol);

        TextView arrow = new TextView(this);
        arrow.setText("›");
        arrow.setTextColor(ThemeColors.OUTLINE);
        arrow.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        card.addView(arrow);

        return card;
    }

    private View createSignUpFooter() {
        LinearLayout footer = new LinearLayout(this);
        footer.setOrientation(LinearLayout.VERTICAL);
        footer.setGravity(Gravity.CENTER);
        footer.setPadding(0, ViewFactory.dp(this, 24), 0, 0);

        LinearLayout linkRow = new LinearLayout(this);
        linkRow.setOrientation(LinearLayout.HORIZONTAL);
        linkRow.setGravity(Gravity.CENTER);

        TextView prompt = new TextView(this);
        prompt.setText("Don't have an account? ");
        prompt.setTextColor(ThemeColors.TEXT_MUTED);
        prompt.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        linkRow.addView(prompt);

        TextView signUpLink = new TextView(this);
        signUpLink.setText("Sign Up");
        signUpLink.setTextColor(ThemeColors.NAVY_PRIMARY);
        signUpLink.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        signUpLink.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        signUpLink.setOnClickListener(v -> startActivity(new Intent(LoginActivity.this, RegisterActivity.class)));
        linkRow.addView(signUpLink);

        footer.addView(linkRow);

        TextView version = new TextView(this);
        version.setText("🔒 FinWise for Higher Ed v2.4.1");
        version.setTextColor(ThemeColors.OUTLINE);
        version.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f);
        version.setPadding(0, ViewFactory.dp(this, 8), 0, 0);
        footer.addView(version);

        return footer;
    }

    private void togglePasswordVisibility() {
        isPasswordVisible = !isPasswordVisible;
        if (isPasswordVisible) {
            passwordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
            togglePasswordBtn.setText("🙈");
        } else {
            passwordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
            togglePasswordBtn.setText("👁️");
        }
        passwordInput.setSelection(passwordInput.getText().length());
    }

    private void showBiometricsPrompt() {
        new AlertDialog.Builder(this)
                .setTitle("Touch ID / Face ID")
                .setMessage("FinWise student biometric authentication uses Android BiometricPrompt hardware abstraction. Please log in with your password to register your biometric token.")
                .setPositiveButton("OK", null)
                .show();
    }

    private void showSsoNotice(String title, String message) {
        new AlertDialog.Builder(this)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton("Understood", null)
                .show();
    }

    private void handleLogin() {
        String identifier = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();

        // 1. Validation
        if (identifier.isEmpty()) {
            Toast.makeText(this, "Invalid email address.", Toast.LENGTH_SHORT).show();
            return;
        }

        if (identifier.contains("@") && !ValidationUtils.isValidEmail(identifier)) {
            Toast.makeText(this, "Invalid email address.", Toast.LENGTH_SHORT).show();
            emailInput.requestFocus();
            return;
        }

        if (password.isEmpty()) {
            Toast.makeText(this, "Incorrect email or password.", Toast.LENGTH_SHORT).show();
            return;
        }

        // Show loading state
        loginButton.setEnabled(false);
        loginButton.setText("Opening Campus Vault...");
        progressBar.setVisibility(View.VISIBLE);

        AuthService.login(identifier, password, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                loginButton.setEnabled(true);
                loginButton.setText("Log In →");
                progressBar.setVisibility(View.GONE);

                if (response.isSuccess()) {
                    JSONObject data = response.getData();
                    String token = data.optString("token", "");
                    User user = User.fromJson(data.optJSONObject("user"));

                    sessionManager.saveLoginSession(token, user, rememberMeCheckbox.isChecked());

                    Toast.makeText(LoginActivity.this, "Welcome, " + (user != null ? user.getFullName() : "Student") + "!", Toast.LENGTH_SHORT).show();

                    Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    startActivity(intent);
                    finish();
                } else {
                    String msg = response.getMessage();
                    if (response.getStatusCode() == 403 || msg.contains("verify your email")) {
                        // Unverified account: redirect directly to VerificationActivity
                        Toast.makeText(LoginActivity.this, "Please verify your email before logging in.", Toast.LENGTH_LONG).show();
                        Intent intent = new Intent(LoginActivity.this, VerificationActivity.class);
                        JSONObject data = response.getData();
                        intent.putExtra("email", data.optString("email", identifier));
                        intent.putExtra("seconds_remaining", data.optInt("seconds_remaining", 0));
                        startActivity(intent);
                    } else {
                        Toast.makeText(LoginActivity.this, msg, Toast.LENGTH_LONG).show();
                    }
                }
            }

            @Override
            public void onError(String errorMessage) {
                loginButton.setEnabled(true);
                loginButton.setText("Log In →");
                progressBar.setVisibility(View.GONE);
                Toast.makeText(LoginActivity.this, "Network error: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }
}
