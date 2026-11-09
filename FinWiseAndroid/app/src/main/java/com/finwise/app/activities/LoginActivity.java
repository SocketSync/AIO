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
import com.finwise.app.models.User;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.AuthService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;
import com.finwise.app.utils.ValidationUtils;

import org.json.JSONObject;

/** Simple native FinWise login. Authentication is performed by the PHP API. */
public class LoginActivity extends AppCompatActivity {
    private EditText emailInput;
    private EditText passwordInput;
    private Button loginButton;
    private ProgressBar progressBar;
    private SessionManager sessionManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        sessionManager = new SessionManager(this);
        if (sessionManager.isLoggedIn()) {
            startActivity(new Intent(this, MainActivity.class));
            finish();
            return;
        }
        buildUi();
    }

    private void buildUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);
        root.addView(ViewFactory.createHeader(this, "FinWise", false, null));

        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);
        scroll.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setGravity(Gravity.CENTER_HORIZONTAL);
        int padding = ViewFactory.dp(this, 24);
        content.setPadding(padding, ViewFactory.dp(this, 42), padding, ViewFactory.dp(this, 32));

        TextView logo = text("FinWise", 30, ThemeColors.NAVY_PRIMARY);
        logo.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        content.addView(logo);
        TextView subtitle = text("Your smarter student finance companion", 14, ThemeColors.TEXT_MUTED);
        subtitle.setPadding(0, ViewFactory.dp(this, 8), 0, ViewFactory.dp(this, 28));
        content.addView(subtitle);

        emailInput = field("Email", InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        content.addView(ViewFactory.createInputContainer(this, "Email", "", emailInput));

        passwordInput = field("Password", InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        LinearLayout passwordBox = ViewFactory.createInputContainer(this, "Password", "", passwordInput);
        LinearLayout.LayoutParams passwordParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        passwordParams.setMargins(0, ViewFactory.dp(this, 12), 0, 0);
        passwordBox.setLayoutParams(passwordParams);
        content.addView(passwordBox);

        progressBar = new ProgressBar(this);
        progressBar.setVisibility(View.GONE);
        content.addView(progressBar);

        loginButton = ViewFactory.createPrimaryButton(this, "Log In", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        LinearLayout.LayoutParams loginParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        loginParams.setMargins(0, ViewFactory.dp(this, 20), 0, 0);
        loginButton.setLayoutParams(loginParams);
        loginButton.setOnClickListener(v -> handleLogin());
        content.addView(loginButton);

        TextView forgot = link("Forgot Password?");
        forgot.setPadding(0, ViewFactory.dp(this, 16), 0, ViewFactory.dp(this, 24));
        forgot.setOnClickListener(v -> startActivity(new Intent(this, ForgotPasswordActivity.class)));
        content.addView(forgot);

        LinearLayout registerRow = new LinearLayout(this);
        registerRow.setGravity(Gravity.CENTER);
        registerRow.addView(text("Don't have an account? ", 14, ThemeColors.TEXT_MUTED));
        TextView register = link("Sign Up");
        register.setOnClickListener(v -> startActivity(new Intent(this, RegisterActivity.class)));
        registerRow.addView(register);
        content.addView(registerRow);

        scroll.addView(content);
        root.addView(scroll);
        setContentView(root);
    }

    private EditText field(String hint, int inputType) {
        EditText input = new EditText(this);
        input.setHint(hint);
        input.setInputType(inputType);
        input.setSingleLine(true);
        return input;
    }

    private TextView text(String value, float size, int color) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, size);
        view.setTextColor(color);
        return view;
    }

    private TextView link(String value) {
        TextView view = text(value, 14, ThemeColors.NAVY_PRIMARY);
        view.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        return view;
    }

    private void handleLogin() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString();
        if (email.isEmpty()) {
            showValidation("请输入 Email Address", emailInput);
            return;
        }
        if (!ValidationUtils.isValidEmail(email)) {
            showValidation("请输入正确的 Email Address", emailInput);
            return;
        }
        if (password.isEmpty()) {
            showValidation("请输入 Password", passwordInput);
            return;
        }

        loginButton.setEnabled(false);
        progressBar.setVisibility(View.VISIBLE);
        AuthService.login(email, password, new ApiClient.ApiCallback() {
            @Override public void onResponse(ApiResponse response) {
                loginButton.setEnabled(true);
                progressBar.setVisibility(View.GONE);
                if (!response.isSuccess()) {
                    Toast.makeText(LoginActivity.this, response.getMessage(), Toast.LENGTH_LONG).show();
                    return;
                }
                JSONObject data = response.getData();
                String token = data.optString("token", "");
                User user = User.fromJson(data.optJSONObject("user"));
                if (token.isEmpty() || user == null) {
                    Toast.makeText(LoginActivity.this, "Unable to start your session.", Toast.LENGTH_LONG).show();
                    return;
                }
                sessionManager.saveLoginSession(token, user, false);
                Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                finish();
            }
            @Override public void onError(String errorMessage) {
                loginButton.setEnabled(true);
                progressBar.setVisibility(View.GONE);
                Toast.makeText(LoginActivity.this, errorMessage, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void showValidation(String message, View target) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
        target.requestFocus();
    }
}
