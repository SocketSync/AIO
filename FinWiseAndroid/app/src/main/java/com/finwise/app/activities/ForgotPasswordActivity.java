package com.finwise.app.activities;

import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
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
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.AuthService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.ValidationUtils;

import java.util.Locale;

/**
 * Screen 5: Forgot Password Activity
 * Pure Java implementation for student password recovery.
 */
public class ForgotPasswordActivity extends AppCompatActivity {

    private EditText emailInput;
    private EditText otpInput;
    private EditText newPasswordInput;
    private EditText confirmPasswordInput;
    private LinearLayout resetSection;
    private Button actionButton;
    private Button resendCodeButton;
    private TextView resendCountdownLabel;
    private ProgressBar progressBar;

    private boolean isCodeRequested = false;
    private CountDownTimer resendTimer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        buildProgrammaticUi();
    }

    private void buildProgrammaticUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);
        root.addView(ViewFactory.createHeader(this, "Reset Password", true, v -> finish()));

        ScrollView scrollView = new ScrollView(this);
        scrollView.setFillViewport(true);
        scrollView.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
        ));

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        int pad = ViewFactory.dp(this, 16);
        content.setPadding(pad, pad, pad, ViewFactory.dp(this, 32));

        TextView desc = new TextView(this);
        desc.setText("Enter your registered student email. We will send a 6-digit reset code to your email.");
        desc.setTextColor(ThemeColors.TEXT_MUTED);
        desc.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        desc.setPadding(0, 0, 0, ViewFactory.dp(this, 16));
        content.addView(desc);

        emailInput = new EditText(this);
        emailInput.setHint("e.g. demo@finwise-app.xyz");
        emailInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        content.addView(ViewFactory.createInputContainer(this, "Student Email Address", "✉️", emailInput));

        resetSection = new LinearLayout(this);
        resetSection.setOrientation(LinearLayout.VERTICAL);
        resetSection.setVisibility(View.GONE);
        resetSection.setPadding(0, ViewFactory.dp(this, 16), 0, 0);

        otpInput = new EditText(this);
        otpInput.setHint("6-digit code");
        otpInput.setInputType(InputType.TYPE_CLASS_NUMBER);
        otpInput.setFilters(new InputFilter[]{new InputFilter.LengthFilter(6)});
        resetSection.addView(ViewFactory.createInputContainer(this, "Verification Code", "🔑", otpInput));

        newPasswordInput = new EditText(this);
        newPasswordInput.setHint("8+ characters: uppercase, lowercase & number");
        newPasswordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        LinearLayout passwordBox = ViewFactory.createInputContainer(this, "New Password", "🔒", newPasswordInput);
        LinearLayout.LayoutParams passwordParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        );
        passwordParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        passwordBox.setLayoutParams(passwordParams);
        resetSection.addView(passwordBox);

        confirmPasswordInput = new EditText(this);
        confirmPasswordInput.setHint("Repeat new password");
        confirmPasswordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        LinearLayout confirmBox = ViewFactory.createInputContainer(this, "Confirm New Password", "🔐", confirmPasswordInput);
        LinearLayout.LayoutParams confirmParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        );
        confirmParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        confirmBox.setLayoutParams(confirmParams);
        resetSection.addView(confirmBox);

        resendCountdownLabel = new TextView(this);
        resendCountdownLabel.setTextColor(ThemeColors.TEXT_MUTED);
        resendCountdownLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        resendCountdownLabel.setGravity(Gravity.CENTER);
        resendCountdownLabel.setPadding(0, ViewFactory.dp(this, 16), 0, ViewFactory.dp(this, 8));
        resetSection.addView(resendCountdownLabel);

        resendCodeButton = ViewFactory.createSecondaryButton(
                this, "Resend Reset Code", ThemeColors.SURFACE_HIGH, ThemeColors.TEXT_MUTED, 0
        );
        resendCodeButton.setEnabled(false);
        resendCodeButton.setOnClickListener(v -> handleResendCode());
        resetSection.addView(resendCodeButton);
        content.addView(resetSection);

        progressBar = new ProgressBar(this);
        progressBar.setVisibility(View.GONE);
        content.addView(progressBar);

        actionButton = ViewFactory.createPrimaryButton(
                this, "Send Reset Code →", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY
        );
        LinearLayout.LayoutParams buttonParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        );
        buttonParams.setMargins(0, ViewFactory.dp(this, 20), 0, 0);
        actionButton.setLayoutParams(buttonParams);
        actionButton.setOnClickListener(v -> handleActionButton());
        content.addView(actionButton);

        scrollView.addView(content);
        root.addView(scrollView);
        setContentView(root);
    }

    private void handleActionButton() {
        String email = emailInput.getText().toString().trim();
        if (!ValidationUtils.isValidEmail(email)) {
            Toast.makeText(this, "Invalid email address.", Toast.LENGTH_SHORT).show();
            return;
        }

        if (!isCodeRequested) {
            actionButton.setEnabled(false);
            actionButton.setText("Sending reset code...");
            progressBar.setVisibility(View.VISIBLE);
            AuthService.requestPasswordReset(email, new ApiClient.ApiCallback() {
                @Override
                public void onResponse(ApiResponse response) {
                    actionButton.setEnabled(true);
                    progressBar.setVisibility(View.GONE);
                    if (response.isSuccess()) {
                        showResetForm(response.getData().optInt("seconds_remaining", 60));
                        Toast.makeText(ForgotPasswordActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    } else {
                        actionButton.setText("Send Reset Code →");
                        Toast.makeText(ForgotPasswordActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                        if (response.getStatusCode() == 429 || response.getStatusCode() == 502) {
                            showResetForm(response.getData().optInt("seconds_remaining", 0));
                        }
                    }
                }

                @Override
                public void onError(String errorMessage) {
                    actionButton.setEnabled(true);
                    actionButton.setText("Send Reset Code →");
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(ForgotPasswordActivity.this, "Error: " + errorMessage, Toast.LENGTH_LONG).show();
                }
            });
            return;
        }

        String otp = otpInput.getText().toString().trim();
        String newPassword = newPasswordInput.getText().toString().trim();
        String confirmPassword = confirmPasswordInput.getText().toString().trim();

        if (!ValidationUtils.isValidOtp(otp)) {
            Toast.makeText(this, "Invalid verification code. Please try again.", Toast.LENGTH_SHORT).show();
            return;
        }
        if (!ValidationUtils.isValidPassword(newPassword)) {
            Toast.makeText(this, "Use at least 8 characters with uppercase, lowercase, and a number.", Toast.LENGTH_LONG).show();
            return;
        }
        if (!ValidationUtils.doPasswordsMatch(newPassword, confirmPassword)) {
            Toast.makeText(this, "Passwords do not match.", Toast.LENGTH_SHORT).show();
            return;
        }

        actionButton.setEnabled(false);
        actionButton.setText("Updating password...");
        progressBar.setVisibility(View.VISIBLE);
        AuthService.resetPassword(email, otp, newPassword, confirmPassword, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                actionButton.setEnabled(true);
                actionButton.setText("Reset Password ✓");
                progressBar.setVisibility(View.GONE);
                if (response.isSuccess()) {
                    Toast.makeText(ForgotPasswordActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    Intent intent = new Intent(ForgotPasswordActivity.this, LoginActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(intent);
                    finish();
                } else {
                    Toast.makeText(ForgotPasswordActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onError(String errorMessage) {
                actionButton.setEnabled(true);
                actionButton.setText("Reset Password ✓");
                progressBar.setVisibility(View.GONE);
                Toast.makeText(ForgotPasswordActivity.this, "Update error: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void showResetForm(int secondsRemaining) {
        isCodeRequested = true;
        emailInput.setEnabled(false);
        resetSection.setVisibility(View.VISIBLE);
        actionButton.setText("Reset Password ✓");
        startResendCountdown(secondsRemaining);
    }

    private void startResendCountdown(int seconds) {
        if (resendTimer != null) {
            resendTimer.cancel();
            resendTimer = null;
        }

        if (seconds <= 0) {
            resendCountdownLabel.setText("You can request a new reset code.");
            resendCodeButton.setEnabled(true);
            resendCodeButton.setTextColor(ThemeColors.NAVY_PRIMARY);
            return;
        }

        resendCodeButton.setEnabled(false);
        resendCodeButton.setTextColor(ThemeColors.TEXT_MUTED);
        resendTimer = new CountDownTimer(seconds * 1000L, 1000L) {
            @Override
            public void onTick(long millisUntilFinished) {
                long remaining = (millisUntilFinished + 999L) / 1000L;
                resendCountdownLabel.setText(String.format(
                        Locale.getDefault(), "Resend available in: 00:%02d", remaining
                ));
            }

            @Override
            public void onFinish() {
                resendTimer = null;
                resendCountdownLabel.setText("You can request a new reset code.");
                resendCodeButton.setEnabled(true);
                resendCodeButton.setTextColor(ThemeColors.NAVY_PRIMARY);
            }
        }.start();
    }

    private void handleResendCode() {
        resendCodeButton.setEnabled(false);
        resendCodeButton.setText("Sending reset code...");
        AuthService.resendPasswordResetCode(emailInput.getText().toString().trim(), new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                resendCodeButton.setText("Resend Reset Code");
                if (response.isSuccess()) {
                    Toast.makeText(ForgotPasswordActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    startResendCountdown(response.getData().optInt("seconds_remaining", 60));
                } else {
                    Toast.makeText(ForgotPasswordActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    if (response.getStatusCode() == 429 || response.getStatusCode() == 502) {
                        startResendCountdown(response.getData().optInt("seconds_remaining", 0));
                    } else {
                        resendCodeButton.setEnabled(true);
                        resendCodeButton.setTextColor(ThemeColors.NAVY_PRIMARY);
                    }
                }
            }

            @Override
            public void onError(String errorMessage) {
                resendCodeButton.setEnabled(true);
                resendCodeButton.setText("Resend Reset Code");
                resendCodeButton.setTextColor(ThemeColors.NAVY_PRIMARY);
                Toast.makeText(ForgotPasswordActivity.this, "Resend failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    protected void onDestroy() {
        if (resendTimer != null) {
            resendTimer.cancel();
        }
        super.onDestroy();
    }
}
