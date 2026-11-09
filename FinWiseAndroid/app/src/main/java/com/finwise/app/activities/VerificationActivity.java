package com.finwise.app.activities;

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputFilter;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
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
import com.finwise.app.utils.CountdownManager;
import com.finwise.app.utils.SessionManager;
import com.finwise.app.utils.ValidationUtils;

import org.json.JSONObject;

/**
 * Screen 3: Email OTP Verification Activity
 * Implements strict 60-second resend countdown and 6-digit verification.
 */
public class VerificationActivity extends AppCompatActivity {

    private String email = "";
    private EditText otpInput;
    private Button verifyButton;
    private Button resendButton;
    private TextView countdownLabel;
    private ProgressBar progressBar;

    private CountdownManager countdownManager;
    private SessionManager sessionManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        email = getIntent().getStringExtra("email");
        if (!ValidationUtils.isValidEmail(email)) {
            Toast.makeText(this, "A valid email address is required for verification.", Toast.LENGTH_LONG).show();
            finish();
            return;
        }

        countdownManager = new CountdownManager(this);
        sessionManager = new SessionManager(this);

        buildProgrammaticUi();

        long secondsRemaining = Math.max(
                countdownManager.getRemainingSeconds(email),
                getIntent().getIntExtra("seconds_remaining", 0)
        );
        if (secondsRemaining > 0) {
            startResendCountdown((int) secondsRemaining);
        } else {
            countdownManager.resumeCountdownIfActive(email, createCountdownListener());
        }
    }

    private void buildProgrammaticUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);

        // Header
        LinearLayout header = ViewFactory.createHeader(this, "Verify Email", true, v -> finish());
        root.addView(header);

        ScrollView scrollView = new ScrollView(this);
        scrollView.setFillViewport(true);
        LinearLayout.LayoutParams scrollParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
        );
        scrollView.setLayoutParams(scrollParams);

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setGravity(Gravity.CENTER_HORIZONTAL);
        int pad = ViewFactory.dp(this, 20);
        content.setPadding(pad, pad, pad, ViewFactory.dp(this, 32));

        // Verification Icon Badge
        TextView iconBadge = new TextView(this);
        iconBadge.setText("✉️");
        iconBadge.setTextSize(TypedValue.COMPLEX_UNIT_SP, 32f);
        iconBadge.setGravity(Gravity.CENTER);
        int badgeSize = ViewFactory.dp(this, 64);
        LinearLayout.LayoutParams bParams = new LinearLayout.LayoutParams(badgeSize, badgeSize);
        bParams.setMargins(0, ViewFactory.dp(this, 12), 0, ViewFactory.dp(this, 16));
        iconBadge.setLayoutParams(bParams);
        iconBadge.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.PRIMARY_FIXED, ViewFactory.dp(this, 999), 0, 0));
        content.addView(iconBadge);

        // Main Heading
        TextView heading = new TextView(this);
        heading.setText("Verify Your Email");
        heading.setTextColor(ThemeColors.TEXT_PRIMARY);
        heading.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f);
        heading.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        heading.setGravity(Gravity.CENTER);
        content.addView(heading);

        // Explanatory Instructions
        TextView instructions = new TextView(this);
        instructions.setText("We have sent a 6-digit verification code to your registered student email address:\n\n" + email);
        instructions.setTextColor(ThemeColors.TEXT_MUTED);
        instructions.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        instructions.setGravity(Gravity.CENTER);
        instructions.setPadding(0, ViewFactory.dp(this, 8), 0, ViewFactory.dp(this, 24));
        content.addView(instructions);

        // 6-digit OTP Input Box
        LinearLayout otpBox = new LinearLayout(this);
        otpBox.setOrientation(LinearLayout.HORIZONTAL);
        otpBox.setGravity(Gravity.CENTER);
        otpBox.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(this, 12), ThemeColors.BORDER_NEUTRAL, ViewFactory.dp(this, 2)));
        otpBox.setPadding(ViewFactory.dp(this, 16), ViewFactory.dp(this, 8), ViewFactory.dp(this, 16), ViewFactory.dp(this, 8));
        LinearLayout.LayoutParams otpBoxParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewFactory.dp(this, 60));
        otpBox.setLayoutParams(otpBoxParams);

        otpInput = new EditText(this);
        otpInput.setHint("123456");
        otpInput.setTextColor(ThemeColors.NAVY_PRIMARY);
        otpInput.setTextSize(TypedValue.COMPLEX_UNIT_SP, 26f);
        otpInput.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
        otpInput.setGravity(Gravity.CENTER);
        otpInput.setInputType(InputType.TYPE_CLASS_NUMBER);
        otpInput.setFilters(new InputFilter[]{new InputFilter.LengthFilter(6)});
        otpInput.setBackground(null);
        otpBox.addView(otpInput, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        content.addView(otpBox);

        // Expiry notice
        TextView expNote = new TextView(this);
        expNote.setText("⏳ Code expires in 10 minutes");
        expNote.setTextColor(ThemeColors.TEXT_MUTED);
        expNote.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f);
        expNote.setPadding(0, ViewFactory.dp(this, 8), 0, ViewFactory.dp(this, 20));
        content.addView(expNote);

        // Progress Bar
        progressBar = new ProgressBar(this);
        progressBar.setVisibility(View.GONE);
        content.addView(progressBar);

        // Verify Button
        verifyButton = ViewFactory.createPrimaryButton(this, "Verify Email ✓", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        verifyButton.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        verifyButton.setOnClickListener(v -> handleVerification());
        content.addView(verifyButton);

        // Countdown & Resend Section
        countdownLabel = new TextView(this);
        countdownLabel.setText("Resend available in: 00:60");
        countdownLabel.setTextColor(ThemeColors.TEXT_MUTED);
        countdownLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        countdownLabel.setGravity(Gravity.CENTER);
        countdownLabel.setPadding(0, ViewFactory.dp(this, 16), 0, ViewFactory.dp(this, 8));
        content.addView(countdownLabel);

        resendButton = ViewFactory.createSecondaryButton(this, "🔄 Resend Code", ThemeColors.SURFACE_HIGH, ThemeColors.TEXT_MUTED, 0);
        resendButton.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        resendButton.setEnabled(false);
        resendButton.setOnClickListener(v -> handleResendCode());
        content.addView(resendButton);

        // Back to Login option
        TextView backToLogin = new TextView(this);
        backToLogin.setText("Back to Login");
        backToLogin.setTextColor(ThemeColors.NAVY_PRIMARY);
        backToLogin.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        backToLogin.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        backToLogin.setPadding(0, ViewFactory.dp(this, 24), 0, 0);
        backToLogin.setOnClickListener(v -> {
            Intent intent = new Intent(VerificationActivity.this, LoginActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
        });
        content.addView(backToLogin);

        scrollView.addView(content);
        root.addView(scrollView);

        setContentView(root);
    }

    private void startResendCountdown(int seconds) {
        resendButton.setEnabled(false);
        resendButton.setTextColor(ThemeColors.TEXT_MUTED);

        countdownManager.startCountdown(email, seconds, createCountdownListener());
    }

    private CountdownManager.CountdownListener createCountdownListener() {
        return new CountdownManager.CountdownListener() {
            @Override
            public void onTick(long secondsRemaining, String formatted) {
                countdownLabel.setText("Resend available in: " + formatted);
            }

            @Override
            public void onFinish() {
                countdownLabel.setText("You can now request a new verification code.");
                resendButton.setEnabled(true);
                resendButton.setTextColor(ThemeColors.NAVY_PRIMARY);
            }
        };
    }

    private void handleVerification() {
        String code = otpInput.getText().toString().trim();

        if (!ValidationUtils.isValidOtp(code)) {
            Toast.makeText(this, "Please enter a valid 6-digit verification code.", Toast.LENGTH_SHORT).show();
            otpInput.requestFocus();
            return;
        }

        verifyButton.setEnabled(false);
        verifyButton.setText("Verifying Code...");
        progressBar.setVisibility(View.VISIBLE);

        AuthService.verifyEmail(email, code, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                verifyButton.setEnabled(true);
                verifyButton.setText("Verify Email ✓");
                progressBar.setVisibility(View.GONE);

                if (response.isSuccess()) {
                    Toast.makeText(VerificationActivity.this, "Email verification successful.", Toast.LENGTH_LONG).show();

                    // Save session token
                    JSONObject data = response.getData();
                    String token = data.optString("token", "");
                    User user = User.fromJson(data.optJSONObject("user"));
                    if (token != null && !token.isEmpty()) {
                        sessionManager.saveLoginSession(token, user, true);
                    }

                    // Navigate to Dashboard
                    Intent intent = new Intent(VerificationActivity.this, MainActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    startActivity(intent);
                    finish();
                } else {
                    Toast.makeText(VerificationActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onError(String errorMessage) {
                verifyButton.setEnabled(true);
                verifyButton.setText("Verify Email ✓");
                progressBar.setVisibility(View.GONE);
                Toast.makeText(VerificationActivity.this, "Verification error: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void handleResendCode() {
        resendButton.setEnabled(false);
        resendButton.setText("Requesting new OTP...");

        AuthService.resendOtp(email, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                resendButton.setText("🔄 Resend Code");
                if (response.isSuccess()) {
                    Toast.makeText(VerificationActivity.this, "New code sent to " + email, Toast.LENGTH_SHORT).show();
                    startResendCountdown(60);
                } else {
                    Toast.makeText(VerificationActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    int secRemaining = response.getData().optInt("seconds_remaining", 60);
                    startResendCountdown(secRemaining);
                }
            }

            @Override
            public void onError(String errorMessage) {
                resendButton.setText("🔄 Resend Code");
                resendButton.setEnabled(true);
                Toast.makeText(VerificationActivity.this, "Resend failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (countdownManager != null) {
            countdownManager.stop();
        }
    }
}
