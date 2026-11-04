package com.finwise.app.activities;

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
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

/**
 * Screen 2: Registration Activity
 * Pure native Java implementation for student onboarding.
 */
public class RegisterActivity extends AppCompatActivity {

    private EditText nameInput;
    private EditText emailInput;
    private EditText matricInput;
    private EditText passwordInput;
    private EditText confirmPasswordInput;
    private Button registerButton;
    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        buildProgrammaticUi();
    }

    private void buildProgrammaticUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);

        // Header with Back arrow
        LinearLayout header = ViewFactory.createHeader(this, "Create Student Account", true, v -> finish());
        root.addView(header);

        ScrollView scrollView = new ScrollView(this);
        scrollView.setFillViewport(true);
        LinearLayout.LayoutParams scrollParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
        );
        scrollView.setLayoutParams(scrollParams);

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        int pad = ViewFactory.dp(this, 16);
        content.setPadding(pad, pad, pad, ViewFactory.dp(this, 32));

        // Subheading
        TextView subHeading = new TextView(this);
        subHeading.setText("Join FinWise Campus Banking. Track your semester allowance, optimize meal spending, and reach savings milestones.");
        subHeading.setTextColor(ThemeColors.TEXT_MUTED);
        subHeading.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        subHeading.setPadding(0, 0, 0, ViewFactory.dp(this, 16));
        content.addView(subHeading);

        // 1. Full Name
        nameInput = new EditText(this);
        nameInput.setHint("e.g. Yeoh Keng Wei");
        nameInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_WORDS);
        content.addView(ViewFactory.createInputContainer(this, "Full Name *", "👤", nameInput));

        // 2. Student Email
        emailInput = new EditText(this);
        emailInput.setHint("e.g. yeoh.k@graduate.utm.my");
        emailInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        LinearLayout emailBox = ViewFactory.createInputContainer(this, "Student Email Address *", "✉️", emailInput);
        LinearLayout.LayoutParams emailParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        emailParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        emailBox.setLayoutParams(emailParams);
        content.addView(emailBox);

        // 3. Matric ID (Optional)
        matricInput = new EditText(this);
        matricInput.setHint("e.g. A23CS0123 (Optional)");
        matricInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS);
        LinearLayout matricBox = ViewFactory.createInputContainer(this, "Matric ID (Optional)", "🎓", matricInput);
        LinearLayout.LayoutParams matricParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        matricParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        matricBox.setLayoutParams(matricParams);
        content.addView(matricBox);

        // 4. Password
        passwordInput = new EditText(this);
        passwordInput.setHint("8+ characters with uppercase, lowercase & number");
        passwordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        LinearLayout passBox = ViewFactory.createInputContainer(this, "Password *", "🔒", passwordInput);
        LinearLayout.LayoutParams passParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        passParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        passBox.setLayoutParams(passParams);
        content.addView(passBox);

        // 5. Confirm Password
        confirmPasswordInput = new EditText(this);
        confirmPasswordInput.setHint("Repeat your password");
        confirmPasswordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        LinearLayout confirmBox = ViewFactory.createInputContainer(this, "Confirm Password *", "🔐", confirmPasswordInput);
        LinearLayout.LayoutParams confParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        confParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        confirmBox.setLayoutParams(confParams);
        content.addView(confirmBox);

        // Progress Bar
        progressBar = new ProgressBar(this);
        progressBar.setVisibility(View.GONE);
        content.addView(progressBar);

        // Register Button
        registerButton = ViewFactory.createPrimaryButton(this, "Create Account & Send OTP →", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        btnParams.setMargins(0, ViewFactory.dp(this, 20), 0, 0);
        registerButton.setLayoutParams(btnParams);
        registerButton.setOnClickListener(v -> handleRegistration());
        content.addView(registerButton);

        // Already have an account row
        LinearLayout loginRow = new LinearLayout(this);
        loginRow.setOrientation(LinearLayout.HORIZONTAL);
        loginRow.setGravity(Gravity.CENTER);
        loginRow.setPadding(0, ViewFactory.dp(this, 20), 0, 0);

        TextView loginPrompt = new TextView(this);
        loginPrompt.setText("Already have an account? ");
        loginPrompt.setTextColor(ThemeColors.TEXT_MUTED);
        loginPrompt.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        loginRow.addView(loginPrompt);

        TextView loginLink = new TextView(this);
        loginLink.setText("Log In");
        loginLink.setTextColor(ThemeColors.NAVY_PRIMARY);
        loginLink.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        loginLink.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        loginLink.setOnClickListener(v -> finish());
        loginRow.addView(loginLink);

        content.addView(loginRow);

        scrollView.addView(content);
        root.addView(scrollView);

        setContentView(root);
    }

    private void handleRegistration() {
        String fullName = nameInput.getText().toString().trim();
        String email = emailInput.getText().toString().trim();
        String matric = matricInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        String confirmPassword = confirmPasswordInput.getText().toString().trim();

        // 1. Validation
        if (!ValidationUtils.isValidFullName(fullName)) {
            Toast.makeText(this, "Please enter your full name.", Toast.LENGTH_SHORT).show();
            nameInput.requestFocus();
            return;
        }

        if (!ValidationUtils.isValidEmail(email)) {
            Toast.makeText(this, "Invalid email address.", Toast.LENGTH_SHORT).show();
            emailInput.requestFocus();
            return;
        }

        if (!ValidationUtils.isValidPassword(password)) {
            Toast.makeText(this, "Use at least 8 characters with uppercase, lowercase, and a number.", Toast.LENGTH_LONG).show();
            passwordInput.requestFocus();
            return;
        }

        if (!ValidationUtils.doPasswordsMatch(password, confirmPassword)) {
            Toast.makeText(this, "Passwords do not match.", Toast.LENGTH_SHORT).show();
            confirmPasswordInput.requestFocus();
            return;
        }

        // Show loading
        registerButton.setEnabled(false);
        registerButton.setText("Generating Campus OTP...");
        progressBar.setVisibility(View.VISIBLE);

        AuthService.register(fullName, email, matric, password, confirmPassword, new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                registerButton.setEnabled(true);
                registerButton.setText("Create Account & Send OTP →");
                progressBar.setVisibility(View.GONE);

                if (response.isSuccess()) {
                    Toast.makeText(RegisterActivity.this, "Verification code sent to " + email, Toast.LENGTH_LONG).show();
                    openVerification(email, response.getData().optInt("seconds_remaining", 60));
                } else {
                    Toast.makeText(RegisterActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    int statusCode = response.getStatusCode();
                    if (statusCode == 429 || (statusCode == 502 && response.getData().optBoolean("verification_pending"))) {
                        openVerification(
                                response.getData().optString("email", email),
                                response.getData().optInt("seconds_remaining", 0)
                        );
                    }
                }
            }

            @Override
            public void onError(String errorMessage) {
                registerButton.setEnabled(true);
                registerButton.setText("Create Account & Send OTP →");
                progressBar.setVisibility(View.GONE);
                Toast.makeText(RegisterActivity.this, "Registration failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void openVerification(String email, int secondsRemaining) {
        Intent intent = new Intent(RegisterActivity.this, VerificationActivity.class);
        intent.putExtra("email", email);
        intent.putExtra("seconds_remaining", secondsRemaining);
        startActivity(intent);
        finish();
    }
}
